local UI = Z.UI
local super = require("ui.ui_view_base")
local Talk_dialog_windowView = class("Talk_dialog_windowView", super)
local CONTENT_PLAYBACK_SPEED = 40
local AUDIO_AUTO_PLAY_DELAY = 1
local TMP_AUTO_PLAY_DELAY = 2
local questTaskBtnCom = require("ui/view/quest_task/quest_task_btns_com")

function Talk_dialog_windowView:ctor()
  if Z.IsPCUI then
    Z.UIConfig.talk_dialog_window.PrefabPath = "npc/talk_dialog_window_pc"
  else
    Z.UIConfig.talk_dialog_window.PrefabPath = "npc/talk_dialog_window"
  end
  super.ctor(self, "talk_dialog_window")
  self.talkVM_ = Z.VMMgr.GetVM("talk")
  self.talkOptionVM_ = Z.VMMgr.GetVM("talk_option")
  self.talkData_ = Z.DataMgr.Get("talk_data")
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self.quest_task_btn_com_ = questTaskBtnCom.new()
  
  function self.onSpace_()
    if not self or not self.lab_content_ then
      return
    end
    self.lab_content_:SetTyperTimeScale(5)
    if self:isAllowNext() then
      Z.AudioMgr:Play("sys_general_click_dialog")
      Z.EPFlowBridge.OnTalkDialogClick()
    end
  end
end

function Talk_dialog_windowView:OnActive()
  self.autoPlay_ = self.settingVM_.Get(E.ClientSettingID.AutoPlay)
  self.curAudioEventId_ = 0
  self.isTyperComplete_ = false
  self.autoPlayTimer_ = nil
  self:initComps()
  self.uiBinder.Ref:SetVisible(self.img_fade_bg_, false)
  self.uiBinder.Ref:SetVisible(self.rimg_dialog_bg_, false)
  Z.EventMgr:Add("HideTalkArrowUI", self.hideArrowUI, self)
  Z.EventMgr:Add(Z.ConstValue.Talk.OnSetBackGround, self.onSetBackGround, self)
  Z.EventMgr:Add(Z.ConstValue.NpcTalk.OnAutoPlayChange, self.onAutoPlayChange, self)
  Z.EventMgr:Add(Z.ConstValue.NpcTalk.EPFlowVoiceEnd, self.onEPFlowVoiceEnd, self)
  Z.EventMgr:Add(Z.ConstValue.Talk.CloseTalkDialog, self.onCloseTalkDialog, self)
  self:AddClick(self.btn_go_, function()
    self.lab_content_:SetTyperTimeScale(5)
    if self:isAllowNext() then
      Z.AudioMgr:Play("sys_general_click_dialog")
      Z.EPFlowBridge.OnTalkDialogClick()
    end
  end)
  self.lab_content_:AddTyperCompleteListener(function()
    self.isTyperComplete_ = true
    self.uiBinder.Ref:SetVisible(self.img_arrow_, not self:isOptionActive())
    self.anim_:PlayByTime("talk_dialog_window_loop", -1)
    Z.EPFlowBridge.OnTalkDialogShowEnd()
    if self.viewData and not self.viewData.NeedWaitVoiceEnd then
      self:autoPlayNext()
    end
  end)
  self.quest_task_btn_com_:Init(E.QuestTaskBtnsSource.Talk, self.talk_btns_binder_, self.viewConfigKey)
end

function Talk_dialog_windowView:initComps()
  self.anim_ = self.uiBinder.anim
  self.img_fade_bg_ = self.uiBinder.img_fade_bg
  self.rimg_dialog_bg_ = self.uiBinder.rimg_dialog_bg
  self.btn_go_ = self.uiBinder.btn_go
  self.lab_content_ = self.uiBinder.lab_content
  self.dotween_fade_bg_ = self.uiBinder.dotween_fade_bg
  self.rect_content_ = self.uiBinder.rect_content
  self.rimg_item_icon_ = self.uiBinder.rimg_item_icon
  self.node_item_icon_ = self.uiBinder.node_item_icon
  self.talk_btns_binder_ = self.uiBinder.talk_btns_binder
  self.talk_btns_lab_prompt_ = self.uiBinder.talk_btns_binder.lab_prompt
  self.img_arrow_ = self.uiBinder.img_arrow
  self.lab_name_ = self.uiBinder.lab_name
end

function Talk_dialog_windowView:OnRefresh()
  self:SetAsFirstSibling()
  if self.autoPlayTimer_ then
    self.timerMgr:StopTimer(self.autoPlayTimer_)
    self.autoPlayTimer_ = nil
  end
  self.isCloseFlow_ = true
  self.quest_task_btn_com_:Refresh()
  self:refreshTalkerName(self.viewData.NpcIdList, self.viewData.OverrideTalkerName)
  self:refreshTalkContent(self.viewData.Content)
  self:refreshTalkAudio(self.viewData.AudioPath)
  self:refreshDialogShake(self.viewData.IsDialogShake)
  self:refreshTalkCamera(self.viewData.CameraTemplateId)
  self:refreshShowItem(self.viewData.ShowItemId)
end

function Talk_dialog_windowView:onCloseTalkDialog()
  self.isCloseFlow_ = false
  Z.UIMgr:CloseView("talk_dialog_window")
end

function Talk_dialog_windowView:OnDeActive()
  logGreen("[quest] Talk_dialog_windowView:OnDeActive")
  self.quest_task_btn_com_:UnInit()
  self.anim_:ResetAniState("talk_dialog_window_shock")
  self.lab_content_:RemoveAllListeners()
  self.talkOptionVM_.CloseOptionView()
  if self.autoPlayTimer_ then
    self.timerMgr:StopTimer(self.autoPlayTimer_)
    self.autoPlayTimer_ = nil
  end
  Z.AudioMgr:StopPlayingEvent(self.curAudioEventId_)
  Z.EventMgr:RemoveObjAll(self)
  if self.isCloseFlow_ then
    Z.EPFlowBridge.StopAllFlow()
    logGreen("[quest] Talk_dialog_windowView:OnDeActive StopAllFlow")
  end
  self.isCloseFlow_ = true
end

function Talk_dialog_windowView:hideArrowUI()
  self.uiBinder.Ref:SetVisible(self.img_arrow_, not self:isOptionActive())
end

function Talk_dialog_windowView:onAutoPlayChange()
  self.autoPlay_ = self.settingVM_.Get(E.ClientSettingID.AutoPlay)
  if self.autoPlay_ and self.isTyperComplete_ then
    Z.EPFlowBridge.OnTalkDialogClick()
  end
end

function Talk_dialog_windowView:onSetBackGround(data)
  local setBackground = function()
    self.uiBinder.Ref:SetVisible(self.rimg_dialog_bg_, data.IsOn)
    if data.IsOn then
      local config = Z.TableMgr.GetRow("DialoguePicTableMgr", data.BackGroundID)
      if config then
        self.rimg_dialog_bg_:SetImage(config.PicAddress)
      end
    end
  end
  if data.NeedFade then
    Z.CoroUtil.create_coro_xpcall(function()
      local coro = Z.CoroUtil.async_to_sync(self.dotween_fade_bg_.CoroPlay)
      coro(self.dotween_fade_bg_, Z.DOTweenAnimType.Open)
      setBackground()
      coro(self.dotween_fade_bg_, Z.DOTweenAnimType.Close)
    end)()
  else
    setBackground()
  end
end

function Talk_dialog_windowView:refreshTalkerName(npcIdList, overrideName)
  local name
  if overrideName and overrideName ~= "" then
    name = overrideName
  else
    name = self:getNameByNpcList(npcIdList)
  end
  self.lab_name_.text = name
end

function Talk_dialog_windowView:refreshTalkContent(content)
  local content = self.talkVM_.HandlePlaceholderStr(content)
  self:caleTextWidth(content)
  self.isTyperComplete_ = false
  self.lab_content_:SetTyperTimeScale(1)
  self.lab_content_:DoTextByPreSec(Z.TableMgr.DecodeLineBreak(content), CONTENT_PLAYBACK_SPEED, self.cancelSource:CreateToken())
  if self.autoPlayTimer_ then
    self.timerMgr:StopTimer(self.autoPlayTimer_)
    self.autoPlayTimer_ = nil
  end
  self.uiBinder.Ref:SetVisible(self.img_arrow_, false)
end

function Talk_dialog_windowView:caleTextWidth(str)
  local result = string.zsplit(str, "<br>")
  local max = 0
  for _, sub_str in pairs(result) do
    local noRichStr = string.gsub(sub_str, "%b<>", "")
    local num = string.zlenNormalize(noRichStr)
    max = max < num and num or max
  end
  max = 37 < max and 37 or max
  local singleWidth = self.lab_content_.fontSize
  self.rect_content_:SetWidth(singleWidth * max)
end

function Talk_dialog_windowView:getNameByNpcList(npcIdList)
  local entityVm = Z.VMMgr.GetVM("entity")
  local name = ""
  for _, npcId in pairs(npcIdList) do
    if npcId == 0 then
      local playName = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrName")).Value
      if playName == nil then
        logError("PlayerEnt AttrName is nil\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129")
      else
        name = name .. " " .. playName
      end
    else
      local npcName = entityVm.GetNpcName(npcId)
      if npcName then
        name = name .. " " .. npcName
      end
    end
  end
  return name
end

function Talk_dialog_windowView:refreshTalkAudio(audioPath)
  Z.AudioMgr:StopPlayingEvent(self.curAudioEventId_)
  if audioPath and audioPath ~= "" then
    self.curAudioEventId_ = Z.AudioMgr:PlayExternalVoiceWithEndCallback(audioPath, "Vo_Story", function(_, _)
      self:autoPlayNext(AUDIO_AUTO_PLAY_DELAY)
    end)
  else
    self.curAudioEventId_ = 0
  end
end

function Talk_dialog_windowView:onEPFlowVoiceEnd()
  if self.viewData and self.viewData.NeedWaitVoiceEnd then
    self:autoPlayNext(AUDIO_AUTO_PLAY_DELAY)
  end
end

function Talk_dialog_windowView:autoPlayNext(duration)
  if not self.IsActive then
    return
  end
  if self:isAllowNext(true) and self.autoPlay_ then
    if duration == nil or duration <= 0 then
      duration = TMP_AUTO_PLAY_DELAY
    end
    if self.autoPlayTimer_ == nil then
      self.autoPlayTimer_ = self.timerMgr:StartTimer(function()
        Z.EPFlowBridge.OnTalkDialogClick()
        self.autoPlayTimer_ = nil
      end, duration)
    end
  end
end

function Talk_dialog_windowView:refreshDialogShake(isShake)
  self.anim_:ResetAniState("talk_dialog_window_shock")
  if isShake then
    self.anim_:PlayOnce("talk_dialog_window_shock")
  end
end

function Talk_dialog_windowView:refreshTalkCamera(templateId)
  if 0 < templateId then
    Z.NpcBehaviourMgr:SetDialogCameraByConfigId(templateId)
  end
end

function Talk_dialog_windowView:refreshShowItem(itemId)
  local isVisible = false
  if 0 < itemId then
    local row = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId)
    if row then
      isVisible = true
      local itemsVM = Z.VMMgr.GetVM("items")
      self.rimg_item_icon_:SetImage(itemsVM.GetItemIcon(itemId))
    end
  else
    isVisible = false
  end
  self.uiBinder.Ref:SetVisible(self.node_item_icon_, isVisible)
end

function Talk_dialog_windowView:isAllowNext(notCheckTyper)
  if (self.isTyperComplete_ or notCheckTyper) and not self:isOptionActive() then
    if self.viewData and self.viewData.ParentView then
      return self.viewData.ParentView:IsTalkAllowClick()
    else
      return true
    end
  end
  return false
end

function Talk_dialog_windowView:OnTriggerInputAction(inputActionEventData)
  if inputActionEventData.ActionId == Z.InputActionIds.Jump then
    self.onSpace_(inputActionEventData)
  end
  if inputActionEventData.ActionId == Z.InputActionIds.Interact and inputActionEventData.EventType == Z.InputActionEventType.ButtonPressedForTimeJustReleased then
    self.onSpace_(inputActionEventData)
  end
end

function Talk_dialog_windowView:isOptionActive()
  return Z.UIMgr:IsActive("talk_option_window")
end

return Talk_dialog_windowView
