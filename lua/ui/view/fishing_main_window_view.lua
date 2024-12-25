local UI = Z.UI
local super = require("ui.ui_view_base")
local Fishing_main_windowView = class("Fishing_main_windowView", super)
local itemClass = require("common.item_binder")
local fishingItemSelectView = require("ui/view/fishing_itemselect_tips_view")
local fishingCtrlBtn = require("ui/view/fishing_btn_ctrl_view")
local joysyickView = require("ui/view/fishing_touch_area_tpl_view")
local bottomUIView = require("ui/view/main_bottom_ui_sub_view")
local fishingSetting = require("ui/view/fishing_set_sub_view")
local mainShortcutView = require("ui/view/main_shortcut_key_view")

function Fishing_main_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fishing_main_window")
  self.baitItemClass_ = itemClass.new(self)
  self.fishRodItemClass_ = itemClass.new(self)
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.mainUiVm_ = Z.VMMgr.GetVM("mainui")
  self.joystickView_ = joysyickView.new()
  self.fishingCtrlBtn_ = fishingCtrlBtn.new()
  self.bottomUIView_ = bottomUIView.new()
  self.mainShortcutView_ = mainShortcutView.new()
  self.fishingSettingView_ = fishingSetting.new(self)
  self.isPlayStripAnim_ = false
  self.oldFishingProgress = 0
  self.curSliderState_ = E.FishingSliderState.None
  self.fishingSliderColor = {
    [E.FishingSliderState.None] = Color.New(0.023529411764705882, 1, 0.40784313725490196, 1),
    [E.FishingSliderState.Green] = Color.New(0.023529411764705882, 1, 0.40784313725490196, 1),
    [E.FishingSliderState.Yellow] = Color.New(0.9411764705882353, 0.803921568627451, 0.050980392156862744, 1),
    [E.FishingSliderState.Orange] = Color.New(0.9647058823529412, 0.44313725490196076, 0.054901960784313725, 1),
    [E.FishingSliderState.Red] = Color.New(0.8980392156862745, 0.0392156862745098, 0.03529411764705882, 1),
    [E.FishingSliderState.Flash] = Color.New(0.8980392156862745, 0.0392156862745098, 0.03529411764705882, 1)
  }
end

function Fishing_main_windowView:OnActive()
  Z.IgnoreMgr:SetInputIgnore(Panda.ZGame.EInputMask.UIInteract, true, Panda.ZGame.EIgnoreMaskSource.Fishing)
  Z.IgnoreMgr:SetInputIgnore(Panda.ZGame.EInputMask.QuickUseItem, true, Panda.ZGame.EIgnoreMaskSource.Fishing)
  Z.IgnoreMgr:SetInputIgnore(Panda.ZGame.EInputMask.NormalAttack, true, Panda.ZGame.EIgnoreMaskSource.Fishing)
  if Z.IsPCUI then
    self.uiBinder.node_item.localScale = Vector3.New(0.65, 0.65, 1)
    self.uiBinder.node_item.anchoredPosition = Vector2.New(0, -10, 1)
  end
  self:bindEvent()
  self:initbinder()
  self:AddClick(self.uiBinder.btn_return, function()
    self:startAnimatedHide()
  end)
  self:AddClick(self.uiBinder.node_lv.btn_func, function()
    self.fishingVM_.OpenMainFuncWindow()
  end)
  self:resetData()
  self:AddClick(self.uiBinder.fishing_item_bait.btn_self, function()
    self:showItemSelectView(E.FishingItemType.FishBait)
  end)
  self:AddClick(self.uiBinder.fishing_item_fishingrod.btn_self, function()
    self:showItemSelectView(E.FishingItemType.FishingRod)
  end)
  self:AddClick(self.uiBinder.btn_helpsys, function()
    local helpsysVM_ = Z.VMMgr.GetVM("helpsys")
    helpsysVM_.OpenMulHelpSysView(6050)
  end)
  self:AddClick(self.uiBinder.btn_set, function()
    self:OpenSettingView()
  end)
  self.fishingCtrlBtn_:Active(nil, self.uiBinder.fishing_btn_ctrl_holder)
  self.bottomUIView_:Active(nil, self.uiBinder.node_bottom_ui_sub)
  self.fishingVM_.ResetEntityAndUIVisible(true)
  Z.UIMgr:FadeOut()
  self:preLoadResultView()
end

function Fishing_main_windowView:OnDeActive()
  local fishingSourceEInt = Panda.ZGame.EIgnoreMaskSource.Fishing:ToInt()
  local sourceMask = 1 << fishingSourceEInt
  Z.IgnoreMgr:ClearAllIgnore(sourceMask)
  self:unbindEvent()
  self.joystickView_:DeActive()
  self.fishingCtrlBtn_:DeActive()
  self.bottomUIView_:DeActive()
  self.mainShortcutView_:DeActive()
  self.fishingData_.IgnoreInputBack = false
  self.fishingVM_.ResetEntityAndUIVisible()
  self:CloseSettingView()
  self:releaseResultView()
end

function Fishing_main_windowView:OnRefresh()
  self:refreshFishingBait()
  self:refreshFishingRod()
  self:refreshFishingSlider(0)
  self:refreshDirNoMatchEffect()
  self:setFishingStage()
  self:refreshFishingLevelUI()
  self:refreshFishingResearchUI()
  self:startAnimatedShow()
  self:refreshMainShortCutView()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FishingMainLevelBtn, self, self.uiBinder.node_lv.Trans)
end

function Fishing_main_windowView:refreshMainShortCutView()
  if Z.IsPCUI then
    local shortcutViewData = {
      keyList = Z.Global.SetKeyboardShowFishing,
      isShowShortcut = true
    }
    self.mainShortcutView_:Active(shortcutViewData, self.uiBinder.node_bottom_ui_sub)
  end
end

function Fishing_main_windowView:resetData()
  self.isPlayStripAnim_ = false
  self.oldFishingProgress = 0
  self.curSliderState_ = E.FishingSliderState.None
end

function Fishing_main_windowView:refreshFishingRod()
  local haveRod_ = self.fishingData_.FishingRod ~= nil and self.fishingData_.FishingRod ~= 0
  self.uiBinder.fishing_item_fishingrod.Ref:SetVisible(self.uiBinder.fishing_item_fishingrod.anim_item_node, haveRod_)
  self.uiBinder.fishing_item_fishingrod.Ref:SetVisible(self.uiBinder.fishing_item_fishingrod.img_empty, not haveRod_)
  if haveRod_ then
    local rodInfo_ = self.itemsVM_.GetItemTabDataByUuid(self.fishingData_.FishingRod)
    if rodInfo_ then
      local rodConfigId_ = rodInfo_.Id
      local itemTableBase = Z.TableMgr.GetTable("ItemTableMgr").GetRow(rodConfigId_)
      self.fishRodItemClass_:InitCircleItem(self.uiBinder.fishing_item_fishingrod, rodConfigId_, nil, itemTableBase.Quality, nil, Z.ConstValue.QualityImgRoundBg)
      self.uiBinder.fishing_item_fishingrod.img_on.fillAmount = self.fishingData_:GetFishingRodDurability(self.fishingData_.FishingRod) / 100
    else
      logError("\230\156\170\230\137\190\229\136\176uuid=" .. self.fishingData_.FishingRod .. "\231\154\132\233\133\141\231\189\174\230\149\176\230\141\174")
    end
  end
end

function Fishing_main_windowView:refreshFishingBait()
  local haveBaits_ = self.fishingData_.FishBait ~= nil and self.fishingData_.FishBait ~= 0
  self.uiBinder.fishing_item_bait.Ref:SetVisible(self.uiBinder.fishing_item_bait.anim_item_node, haveBaits_)
  self.uiBinder.fishing_item_bait.Ref:SetVisible(self.uiBinder.fishing_item_bait.img_empty, not haveBaits_)
  if haveBaits_ then
    local itemTableBase = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.fishingData_.FishBait)
    self.baitItemClass_:InitCircleItem(self.uiBinder.fishing_item_bait, self.fishingData_.FishBait, nil, itemTableBase.Quality, nil, Z.ConstValue.QualityImgRoundBg)
    self.uiBinder.fishing_item_bait.lab_content.text = self.itemsVM_.GetItemTotalCount(self.fishingData_.FishBait)
  end
end

function Fishing_main_windowView:refreshFishingLevelUI()
  self.uiBinder.node_lv.lab_lv.text = self.fishingData_.FishingLevel
  self.uiBinder.node_lv.img_exp.fillAmount = self.fishingData_.PeripheralData.FishingLevelProgress[1]
end

function Fishing_main_windowView:refreshFishingResearchUI()
  local useFishResearch = self.fishingData_.QTEData.UseResearchFish ~= nil and self.fishingData_.QTEData.UseResearchFish ~= 0
  self.uiBinder.node_study.Ref:SetVisible(self.uiBinder.node_study.img_study, useFishResearch)
  self.uiBinder.node_study.Ref:SetVisible(self.uiBinder.node_study.img_empty, not useFishResearch)
  self.uiBinder.node_study.Ref:SetVisible(self.uiBinder.node_study.img_quality, useFishResearch)
  self.uiBinder.node_study.Ref:SetVisible(self.uiBinder.node_study.img_mask_icon, useFishResearch)
  if useFishResearch then
    local recordData_ = self.fishingData_.FishRecordDict[self.fishingData_.QTEData.UseResearchFish]
    self.uiBinder.node_study.img_study.fillAmount = recordData_.ResearchProgress[1]
    self.uiBinder.node_study.rimg_icon:SetImage(recordData_.FishCfg.FishingIcon)
  end
  self.uiBinder.node_study.btn_self:RemoveAllListeners()
  self:AddClick(self.uiBinder.node_study.btn_self, function()
    self.fishingVM_.OpenMainFuncWindow(E.FishingMainFunc.Research)
  end)
end

function Fishing_main_windowView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingStateChange, self.setFishingStage, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingRodChange, self.refreshFishingRod, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingBaitChange, self.refreshFishingBait, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingLevelChange, self.refreshFishingLevelUI, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingResearchUseChange, self.refreshFishingResearchUI, self)
end

function Fishing_main_windowView:unbindEvent()
  Z.EventMgr:RemoveObjAll()
end

function Fishing_main_windowView:initbinder()
  self.runAwayTip_ = self.uiBinder.lab_tips_01
  self.successTip_ = self.uiBinder.lab_tips_02
  self.hookingUpTip_ = self.uiBinder.lab_tips_03
end

function Fishing_main_windowView:refreshFishingSlider()
  local progress = self.fishingData_.QTEData.FishingProgress
  local rodTension = self.fishingData_.QTEData.FishRodTension
  self.uiBinder.lab_percentage.text = self.fishingData_.QTEData.FishRodTensionInt .. "%"
  self.uiBinder.img_strip.fillAmount = rodTension / 100
  self.uiBinder.img_strip_02.fillAmount = rodTension / 100
  local lastState = self.curSliderState_
  if rodTension > Z.Global.FishingTensionGreen[4] then
    self.curSliderState_ = E.FishingSliderState.Flash
  elseif rodTension > Z.Global.FishingTensionGreen[3] and rodTension < Z.Global.FishingTensionGreen[4] then
    self.curSliderState_ = E.FishingSliderState.Red
  elseif rodTension > Z.Global.FishingTensionGreen[2] and rodTension < Z.Global.FishingTensionGreen[3] then
    self.curSliderState_ = E.FishingSliderState.Orange
  elseif rodTension > Z.Global.FishingTensionGreen[1] and rodTension < Z.Global.FishingTensionGreen[2] then
    self.curSliderState_ = E.FishingSliderState.Yellow
  else
    self.curSliderState_ = E.FishingSliderState.Green
  end
  if self.curSliderState_ ~= lastState then
    self.uiBinder.img_strip:SetColor(self.fishingSliderColor[self.curSliderState_])
  end
  if self.curSliderState_ == E.FishingSliderState.Flash then
    if self.isPlayStripAnim_ == false then
      self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Tween_4)
      self.uiBinder.anim:Play(Z.DOTweenAnimType.Tween_4)
      self.isPlayStripAnim_ = true
    end
  elseif self.isPlayStripAnim_ == true then
    self.uiBinder.anim:Pause(Z.DOTweenAnimType.Tween_4)
    self.isPlayStripAnim_ = false
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_strip_02, self.curSliderState_ == E.FishingSliderState.Flash)
  self.uiBinder.node_icon:SetAnchors(1 - progress / 100, 1 - progress / 100, 0.5, 0.5)
  self.uiBinder.node_icon:SetAnchorPosition(0, 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_light, self.oldFishingProgress ~= progress)
  self.oldFishingProgress = progress
end

function Fishing_main_windowView:refreshDirNoMatchEffect()
  if self.fishingData_.FishingStage == E.FishingStage.QTE and self.fishingData_.QTEData.ShowDirNoMatchEffect then
    local isLeft = self.fishingData_.TargetFish.dir < self.fishingData_.QTEData.playerSwingDir_
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_left, isLeft)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_right, not isLeft)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_left, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_right, false)
  end
end

function Fishing_main_windowView:refreshTips()
  self.uiBinder.Ref:SetVisible(self.runAwayTip_, false)
  self.uiBinder.Ref:SetVisible(self.successTip_, false)
  self.uiBinder.Ref:SetVisible(self.hookingUpTip_, false)
  self.uiBinder.eff_tips01:SetEffectGoVisible(false)
  self.uiBinder.eff_tips02:SetEffectGoVisible(false)
  self.uiBinder.eff_tips03:SetEffectGoVisible(false)
  if self.fishingData_.FishingStage == E.FishingStage.EndRodBreak then
    self.uiBinder.Ref:SetVisible(self.runAwayTip_, true)
    self.uiBinder.eff_tips01:SetEffectGoVisible(true)
    self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Tween_1)
    self.uiBinder.anim:Play(Z.DOTweenAnimType.Tween_1)
  elseif self.fishingData_.FishingStage == E.FishingStage.EndRunAway or self.fishingData_.FishingStage == E.FishingStage.EndBuoyDive then
    self.uiBinder.Ref:SetVisible(self.runAwayTip_, true)
    self.uiBinder.eff_tips01:SetEffectGoVisible(true)
    self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Tween_1)
    self.uiBinder.anim:Play(Z.DOTweenAnimType.Tween_1)
  elseif self.fishingData_.FishingStage == E.FishingStage.EndSuccess then
    Z.AudioMgr:Play("UI_Event_Fishing_Get")
    self.uiBinder.Ref:SetVisible(self.successTip_, true)
    self.uiBinder.eff_tips02:SetEffectGoVisible(true)
    self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Tween_2)
    self.uiBinder.anim:Play(Z.DOTweenAnimType.Tween_2)
  elseif self.fishingData_.FishingStage == E.FishingStage.QTE then
    self.uiBinder.Ref:SetVisible(self.hookingUpTip_, true)
    self.uiBinder.eff_tips03:SetEffectGoVisible(true)
    self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Tween_3)
    self.uiBinder.anim:Play(Z.DOTweenAnimType.Tween_3)
  end
end

function Fishing_main_windowView:setFishingStage()
  self.uiBinder.fishing_item_bait.Ref.UIComp:SetVisible(self.fishingData_.FishingStage == E.FishingStage.EnterFishing)
  self.uiBinder.fishing_item_fishingrod.Ref.UIComp:SetVisible(self.fishingData_.FishingStage == E.FishingStage.EnterFishing)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_slider, self.fishingData_.FishingStage == E.FishingStage.QTE)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, self.fishingData_.FishingStage == E.FishingStage.EnterFishing)
  if self.fishingData_.FishingStage == E.FishingStage.QTE then
    self:resetData()
    self:clearQteTimer()
    self.refreshProgressTimer_ = self.timerMgr:StartFrameTimer(function()
      self:refreshFishingSlider()
      self:refreshDirNoMatchEffect()
    end, self.fishingData_.QTEData.UpdateRate, -1)
    self:openJoystick()
  else
    self:clearQteTimer()
    self:closeJoystick()
  end
  if self.fishingData_.FishingStage == E.FishingStage.EnterFishing then
    self.uiBinder.anim:Pause(Z.DOTweenAnimType.Tween_4)
    self.isPlayStripAnim_ = false
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_strip_02, false)
    self:refreshDirNoMatchEffect()
  end
  self:refreshTips()
  if self.fishingData_.FishingStage == E.FishingStage.Settlement then
    return
  end
end

function Fishing_main_windowView:clearQteTimer()
  if self.refreshProgressTimer_ then
    self.timerMgr:StopFrameTimer(self.refreshProgressTimer_)
    self.refreshProgressTimer_ = nil
  end
end

function Fishing_main_windowView:openJoystick()
  if not Z.IsPCUI then
    self.joystickView_:Active(nil, self.uiBinder.Trans)
  end
end

function Fishing_main_windowView:closeJoystick()
  if self.joystickView_.IsActive then
    self.joystickView_:DeActive()
  end
end

function Fishing_main_windowView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Fishing_main_windowView:startAnimatedHide()
  self.fishingVM_.QuitFishingState(self.cancelSource:CreateToken())
end

function Fishing_main_windowView:showItemSelectView(type)
  if self.itemSelectView_ == nil then
    self.itemSelectView_ = fishingItemSelectView.new()
  end
  local extraParams = {}
  local viewData_ = {}
  viewData_.selectType = type
  if type == E.FishingItemType.FishBait then
    extraParams = {
      fixedPos = Vector3.New(self.uiBinder.fishing_item_bait.Trans.position.x + 1, self.uiBinder.fishing_item_bait.Trans.position.y + 7, self.uiBinder.fishing_item_bait.Trans.position.z),
      pivotX = 0,
      pivotY = 1
    }
  else
    extraParams = {
      fixedPos = Vector3.New(self.uiBinder.fishing_item_fishingrod.Trans.position.x + 1, self.uiBinder.fishing_item_fishingrod.Trans.position.y + 7, self.uiBinder.fishing_item_fishingrod.Trans.position.z),
      pivotX = 0,
      pivotY = 1
    }
  end
  viewData_.extraParams = extraParams
  viewData_.parentView = self
  self.itemSelectView_:Active(viewData_, self.uiBinder.fishing_item_bait.Trans)
end

function Fishing_main_windowView:OnInputBack()
  if not self.fishingData_.IgnoreInputBack and self.IsResponseInput then
    self:startAnimatedHide()
  end
end

function Fishing_main_windowView:OpenSettingView()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_return, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_set, false)
  self.fishingSettingView_:Active(nil, self.uiBinder.Trans)
end

function Fishing_main_windowView:CloseSettingView()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_return, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_set, true)
  self.fishingSettingView_:DeActive()
end

function Fishing_main_windowView:preLoadResultView()
  self.resultGo_ = nil
  local viewConfigKey = "fishing_obtain_window"
  local prefabPath = Z.UIConfig[viewConfigKey].PrefabPath
  Z.UIMgr:LoadView(viewConfigKey, prefabPath, self.cancelSource:CreateToken(), function(go)
    Z.UIRoot:CacheUI(viewConfigKey, go)
    self.resultGo_ = go
  end)
end

function Fishing_main_windowView:releaseResultView()
  local viewConfigKey = "fishing_obtain_window"
  if self.resultGo_ then
    Z.UIRoot:GetCacheUI(viewConfigKey)
    Z.LuaBridge.ReleaseInstance(self.resultGo_)
    self.resultGo_ = nil
  end
end

return Fishing_main_windowView
