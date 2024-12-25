local UI = Z.UI
local super = require("ui.ui_subview_base")
local InteractionView = class("InteractionView", super)
local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")
local interactionItemHelper = require("ui.component.interaction.interaction_item_helper")

function InteractionView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "interaction_sub", "interaction/interaction_sub", UI.ECacheLv.High)
  self.interactionVm_ = Z.VMMgr.GetVM("interaction")
  self.interactionData_ = Z.DataMgr.Get("interaction_data")
  self.lastStateId_ = -1
  self.lockCameraZoom_ = false
  self.selectInteractionCount_ = 3
  self.selectInteractionHeight_ = 70
end

function InteractionView:OnActive()
  self.unitTokenDict_ = {}
  self:initOption()
  self:BindLuaAttrWatchers()
  self:BindEvents()
  self:checkProcess()
  local interactMgr = Panda.ZGame.ZInteractionMgr.Instance
  interactMgr:ResetInteractionIndex()
end

function InteractionView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.CreateOption, self.createOption, self)
  Z.EventMgr:Add(Z.ConstValue.RemoveOption, self.removeOption, self)
  Z.EventMgr:Add(Z.ConstValue.DeActiveOptionByName, self.deActiveOptionByName, self)
  Z.EventMgr:Add(Z.ConstValue.DeActiveOption, self.deActiveOption, self)
  Z.EventMgr:Add(Z.ConstValue.UIOpen, self.onReceiveEvent, self)
  Z.EventMgr:Add(Z.ConstValue.PointClickOption, self.onPointClickOption, self)
  Z.EventMgr:Add(Z.ConstValue.SelectInteractionOption, self.refreshInteractionView, self)
end

function InteractionView:BindLuaAttrWatchers()
  if Z.EntityMgr.PlayerEnt ~= nil then
    self.playerStateWatcher_ = self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrState")
    }, Z.EntityMgr.PlayerEnt, self.process)
    self.playerBattleWatcher_ = self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrCombatState")
    }, Z.EntityMgr.PlayerEnt, self.battleStateProcess)
  end
end

function InteractionView:OnDeActive()
  self:checkProgress(E.InteractionProgressCheckType.InteractionDeActive)
  self.lastStateId_ = -1
  local handleDataList = self.interactionData_:GetData()
  for i = 1, #handleDataList do
    handleDataList[i]:ClearUnit()
    local unit = handleDataList[i]:GetUnit()
    if unit then
      if Z.IsPCUI then
        unit.uisteer_node_pc:ClearAll()
      else
        unit.uisteer_node:ClearAll()
      end
    end
  end
  if self.lockCameraZoom_ then
    self.lockCameraZoom_ = false
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2, false)
  end
  Z.EventMgr:RemoveObjAll(self)
end

function InteractionView:OnShow()
  self:checkCameraZoom()
end

function InteractionView:OnHide()
  if self.lockCameraZoom_ then
    self.lockCameraZoom_ = false
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2, false)
  end
end

function InteractionView:initOption()
  local handleDataList = self:deActiveOption()
  for i = 1, #handleDataList do
    self:createOption(handleDataList[i])
  end
  self:checkCameraZoom()
end

function InteractionView:createOption(handleData)
  self:deActiveOption()
  self:setScrollViewVisible(true)
  if not handleData:CheckBtnShow() then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local unit = self:loadBtnUnit(handleData:GetUnitName(), handleData:GetContentStr(), handleData:GetIcon())
    if not unit then
      return
    end
    handleData:OnLoadUnit(unit)
    self.interactionVm_.RefreshSelectOption()
    self:AddAsyncClick(unit.btn_interaction, function()
      handleData:OnBtnClick(self.cancelSource)
      if handleData:GetInteractionBtnType() == E.InteractionBtnType.EProgress then
        self:refreshOptionProgress(unit, handleData:GetProgressTime())
      end
    end)
    self:refreshPos()
    Z.Delay(0.1, self.cancelSource:CreateToken())
    local replaceBtnId = handleData:GetReplaceBtnId()
    if Z.IsPCUI then
      Z.GuideMgr:SetSteerIdByComp(unit.uisteer_node_pc, E.DynamicSteerType.InteractionId, replaceBtnId)
    else
      Z.GuideMgr:SetSteerIdByComp(unit.uisteer_node, E.DynamicSteerType.InteractionId, replaceBtnId)
    end
  end)()
end

function InteractionView:loadBtnUnit(unitName, contentStr, iconPath)
  local parent = self.uiBinder.layout_content
  local token = self.cancelSource:CreateToken()
  self.unitTokenDict_[unitName] = token
  local itemPath = Z.IsPCUI and Z.ConstValue.NpcTalk.PCAddress or Z.ConstValue.NpcTalk.MobileAddress
  local path = GetLoadAssetPath(itemPath)
  local unit = self:AsyncLoadUiUnit(path, unitName, parent, token)
  if not unit then
    return
  end
  self.unitTokenDict_[unitName] = nil
  keyIconHelper.InitKeyIcon(self, unit.cont_key_icon, 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.main_mouse, Z.IsPCUI and table.zcount(self.units) >= 2)
  interactionItemHelper.InitInteractionItem(unit, contentStr, iconPath)
  interactionItemHelper.AddCommonListener(unit)
  unit.Ref.UIComp:SetVisible(true)
  self:checkCameraZoom()
  return unit
end

function InteractionView:removeOption(handleData)
  local unitName = handleData:GetUnitName()
  if self.unitTokenDict_[unitName] then
    Z.CancelSource.ReleaseToken(self.unitTokenDict_[unitName])
  end
  local unit = self.units[unitName]
  if unit then
    if Z.IsPCUI then
      unit.uisteer_node_pc:ClearSteerList()
    else
      unit.uisteer_node:ClearSteerList()
    end
  end
  self:RemoveUiUnit(unitName)
  handleData:OnRemoveUnit()
  self.uiBinder.Ref:SetVisible(self.uiBinder.main_mouse, Z.IsPCUI and table.zcount(self.units) >= 2)
  self:checkCameraZoom()
end

function InteractionView:checkCameraZoom()
  if not Z.IsPCUI then
    return
  end
  if table.zcount(self.units) >= 2 then
    if not self.lockCameraZoom_ then
      self.lockCameraZoom_ = true
      Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2, true)
    end
  elseif self.lockCameraZoom_ then
    self.lockCameraZoom_ = false
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2, false)
  end
end

function InteractionView:deActiveOptionByName(unitName)
  self:RemoveUiUnit(unitName)
end

function InteractionView:refreshOptionProgress(unit, progressTime)
  if unit == nil then
    return
  end
  if progressTime and 0 < progressTime then
    unit.Ref:SetVisible(unit.cont_off, false)
    unit.Ref:SetVisible(unit.cont_on, false)
    unit.Ref:SetVisible(unit.cont_collecting, true)
    unit.img_progress.fillAmount = 0
    if self.progressTimer_ then
      self.timerMgr:StopTimer(self.progressTimer_)
      self.progressTimer_ = nil
    end
    self.progressTimer_ = self.timerMgr:StartTimer(function()
      unit.img_progress.fillAmount = unit.img_progress.fillAmount + 0.05 / progressTime
    end, 0.05, progressTime / 0.05)
  else
    unit.Ref:SetVisible(unit.cont_on, true)
    unit.Ref:SetVisible(unit.cont_collecting, false)
  end
end

function InteractionView:checkProgress(type)
  local handleDataList = self.interactionData_:GetData()
  for i = 1, #handleDataList do
    if handleDataList[i]:GetInteractionBtnType() == E.InteractionBtnType.EProgress then
      handleDataList[i]:ChangeProgress(type, self.cancelSource)
    end
  end
end

function InteractionView:deActiveOption()
  local handleDataList = self.interactionData_:GetData()
  if #handleDataList == 0 then
    self:setScrollViewVisible(false)
    self:ClearAllUnits()
    Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.KeyHintOpenChange, self)
    Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.KeySettingReset, self)
    self.uiBinder.Ref:SetVisible(self.uiBinder.main_mouse, false)
  end
  return handleDataList
end

function InteractionView:onReceiveEvent()
end

function InteractionView:process()
  local stateId = self:checkProcess()
  self:checkProgress(self.lastStateId_)
  self.lastStateId_ = stateId
end

function InteractionView:battleStateProcess()
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrCombatState")).Value
  self:setScrollViewVisible(stateId <= 0)
end

function InteractionView:checkProcess()
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrState")).Value
  if Z.PbEnum("EActorState", "ActorStateDefault") == stateId or Z.PbEnum("EActorState", "ActorStateRush") == stateId or Z.PbEnum("EActorState", "ActorStateCollection") == stateId then
    self:setScrollViewVisible(true)
  else
    self:setScrollViewVisible(false)
  end
  return stateId
end

function InteractionView:refreshPos()
  local handleDataList = self.interactionData_:GetData()
  for i = 1, #handleDataList do
    local unit = handleDataList[i]:GetUnit()
    if unit then
      unit.Trans:SetSiblingIndex(i)
    end
  end
end

function InteractionView:setScrollViewVisible(isVisible)
  if isVisible then
    local handleDataList = self.interactionData_:GetData()
    if 0 < #handleDataList then
      self.uiBinder.scroll_canvas.blocksRaycasts = true
      self.uiBinder.scroll_canvas.interactable = true
      self.uiBinder.scorll_doTween:DoCanvasGroup(1, 0.3)
    end
  else
    self.uiBinder.scroll_canvas.blocksRaycasts = false
    self.uiBinder.scroll_canvas.interactable = false
    self.uiBinder.scorll_doTween:DoCanvasGroup(0, 0.3)
  end
end

function InteractionView:onPointClickOption(index)
  Z.CoroUtil.create_coro_xpcall(function()
    local handleDataList = self.interactionData_:GetData()
    if not handleDataList[index] then
      return
    end
    handleDataList[index]:OnBtnClick(self.cancelSource)
  end)()
end

function InteractionView:refreshInteractionView(selectIndex)
  local _, y = self.uiBinder.layout_content:GetAnchorPosition(nil, nil)
  local startHeight = (selectIndex - 1) * self.selectInteractionHeight_
  if startHeight < 0 then
    startHeight = 0
  end
  local endHeight = selectIndex * self.selectInteractionHeight_
  local maxEndHeight = (self.selectInteractionCount_ - 1) * self.selectInteractionHeight_
  if y > startHeight then
    self.uiBinder.layout_content:SetAnchorPosition(0, startHeight)
  elseif endHeight > y + maxEndHeight then
    self.uiBinder.layout_content:SetAnchorPosition(0, endHeight)
  end
end

return InteractionView
