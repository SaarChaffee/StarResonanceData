local UI = Z.UI
local super = require("ui.ui_view_base")
local Worldquest_interactive_windowView = class("Worldquest_interactive_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local common_reward_loop_list_item = require("ui.component.common_reward_grid_list_item")

function Worldquest_interactive_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "worldquest_interactive_window")
  self.worldQuestVM_ = Z.VMMgr.GetVM("worldquest")
  self.worldQuestData_ = Z.DataMgr.Get("worldquest_data")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
end

function Worldquest_interactive_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  self.worldquestVM = Z.VMMgr.GetVM("worldquest")
  self:onStartAnimShow()
  self:bindEvent()
  self:AddClick(self.uiBinder.btn_close, function()
    self:closeView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_get_task, function()
    self:acceptWorldQuest()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(300009, self.uiBinder.btn_ask_trans)
  end)
  self:initLoopListView()
end

function Worldquest_interactive_windowView:OnDeActive()
  self:unInitLoopListView()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function Worldquest_interactive_windowView:OnRefresh()
  self:refreshUI()
end

function Worldquest_interactive_windowView:refreshUI()
  self:refreshFinishNum()
  self:refreshQuestAward()
  self:refreshRightUI()
end

function Worldquest_interactive_windowView:jumpMap(sceneId, entity)
  local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
  local entityType_ = entity[1]
  local entityUId_ = entity[2]
  local entNpcObjType = Z.PbEnum("EEntityType", "EntNpc")
  local entSceneObjType = Z.PbEnum("EEntityType", "EntSceneObject")
  local jumpParam_ = {}
  jumpParam_[1] = sceneId
  if entityType_ == entNpcObjType then
    jumpParam_[2] = E.TrackType.Npc
  elseif entityType_ == entSceneObjType then
    jumpParam_[2] = E.TrackType.SceneObject
  end
  jumpParam_[3] = entityUId_
  quickJumpVm.DoJumpByConfigParam(E.QuickJumpType.TraceSceneTarget, jumpParam_, {AutoTrack = false})
end

function Worldquest_interactive_windowView:refreshFinishNum()
  local finishCount_ = 0
  local eventCount_ = 0
  for k, v in pairs(Z.ContainerMgr.CharSerialize.worldEventMap.eventMap) do
    eventCount_ = eventCount_ + 1
    if v.award == 1 then
      finishCount_ = finishCount_ + 1
    end
  end
  self.uiBinder.lab_finished.text = finishCount_
  self.uiBinder.lab_needfinish.text = eventCount_
end

function Worldquest_interactive_windowView:refreshRightUI()
  local countTxt_ = Z.RichTextHelper.ApplyColorTag(Z.ContainerMgr.CharSerialize.worldEventMap.acceptCount, "#DDFF16")
  self.uiBinder.group_right.lab_num.text = countTxt_
  local index_ = 1
  local keys_ = {}
  for _, v in pairs(Z.ContainerMgr.CharSerialize.worldEventMap.eventMap) do
    table.insert(keys_, v)
  end
  table.sort(keys_, function(a, b)
    return a.id < b.id
  end)
  for _, v in pairs(keys_) do
    local eventInfo_ = Z.TableMgr.GetTable("DailyWorldEventTableMgr").GetRow(v.id)
    if eventInfo_ then
      self:refreshRightEventUI(index_, eventInfo_, v.award == 1)
      index_ = index_ + 1
    else
      logError("DailyWorldEventTable\230\156\170\232\142\183\229\143\150\229\136\176\230\149\176\230\141\174\239\188\140 id = " .. v.id)
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get_task, not self.worldQuestData_.AcceptWorldQuest)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_doing, self.worldQuestData_.AcceptWorldQuest)
  self.uiBinder.btn_get_task.IsDisabled = Z.ContainerMgr.CharSerialize.worldEventMap.acceptCount == 0
end

function Worldquest_interactive_windowView:refreshQuestAward()
  local questCfg_ = Z.TableMgr.GetTable("QuestTableMgr").GetRow(Z.Global.WorldEventQuestId)
  if questCfg_ then
    local awardList = self.awardPreviewVM_.GetAllAwardPreListByIds(questCfg_.AwardId)
    self.loopListView_:RefreshListView(awardList)
  end
end

function Worldquest_interactive_windowView:refreshRightEventUI(index, dailyEventCfg, isFinish)
  local binderName_ = "worldquest_list_tpl" .. index
  local binder = self.uiBinder.group_right[binderName_]
  if binder then
    binder.rimg_picture:SetImage(dailyEventCfg.EventBanner)
    binder.lab_player_name.text = dailyEventCfg.Name
    local showBtn_ = not isFinish and self.worldQuestData_.AcceptWorldQuest
    binder.Ref:SetVisible(binder.group_finish, not showBtn_)
    binder.Ref:SetVisible(binder.btn_ok, showBtn_)
    binder.Ref:SetVisible(binder.img_finish, isFinish)
    local dataList_ = self.awardPreviewVM_.GetAllAwardPreListByIds(dailyEventCfg.Award)
    self.loopListAwardEvent_[index]:RefreshListView(dataList_)
    binder.btn_ok:RemoveAllListeners()
    self:AddClick(binder.btn_ok, function()
      self:jumpMap(dailyEventCfg.Scene, dailyEventCfg.Entity)
      self:closeView()
    end)
  end
end

function Worldquest_interactive_windowView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, common_reward_loop_list_item, "com_item_square")
  self.loopListView_:Init({})
  self.loopListAwardEvent_ = {}
  for index = 1, 3 do
    local binderName_ = "worldquest_list_tpl" .. index
    local loopView_ = loopListView.new(self, self.uiBinder.group_right[binderName_].loop_item, common_reward_loop_list_item, "com_item_square_8")
    loopView_:Init({})
    table.insert(self.loopListAwardEvent_, loopView_)
  end
end

function Worldquest_interactive_windowView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
  for k, v in pairs(self.loopListAwardEvent_) do
    v:UnInit()
  end
  self.loopListAwardEvent_ = nil
end

function Worldquest_interactive_windowView:acceptWorldQuest()
  if self.worldQuestData_.AcceptWorldQuest or Z.ContainerMgr.CharSerialize.worldEventMap.acceptCount == 0 then
    return
  end
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("WorldQuestAcceptQuestTip"), function()
    local questVM = Z.VMMgr.GetVM("quest")
    local success_ = questVM.AsyncAcceptQuest(Z.Global.WorldEventQuestId)
    if success_ then
      Z.TipsVM.ShowTips(1381016)
    end
    Z.DialogViewDataMgr:CloseDialogView()
  end)
end

function Worldquest_interactive_windowView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.DeActiveOption, self.closeView, self)
  Z.EventMgr:Add(Z.ConstValue.NpcTalk.TalkStateEnd, self.closeView, self)
  Z.EventMgr:Add(Z.ConstValue.WorldQuestListChange, self.refreshUI, self)
end

function Worldquest_interactive_windowView:closeView()
  Z.UIMgr:CloseView("worldquest_interactive_window")
end

function Worldquest_interactive_windowView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Worldquest_interactive_windowView
