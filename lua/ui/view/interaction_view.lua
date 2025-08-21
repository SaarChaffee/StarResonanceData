local UI = Z.UI
local super = require("ui.ui_subview_base")
local InteractionView = class("InteractionView", super)
local loopListView = require("ui.component.loop_list_view")
local loopInteractionItem = require("ui/component/interaction/interaction_item")
local inputKeyDescComp = require("input.input_key_desc_comp")

function InteractionView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "interaction_sub", "interaction/interaction_sub", UI.ECacheLv.High, true)
  self.interactionVm_ = Z.VMMgr.GetVM("interaction")
  self.interactionData_ = Z.DataMgr.Get("interaction_data")
  self.lockCameraZoom_ = false
  self.navigateInputKeyDescComp_ = inputKeyDescComp.new()
end

function InteractionView:OnActive()
  self:initLoopComp()
  self:BindLuaAttrWatchers()
  self:BindEvents()
  self:refreshLoopList()
  local interactMgr = Panda.ZGame.ZInteractionMgr.Instance
  interactMgr:ResetInteractionIndex()
  self.navigateInputKeyDescComp_:Init(158, self.uiBinder.binder_navigate)
end

function InteractionView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.RefreshOption, self.refreshLoopList, self)
  Z.EventMgr:Add(Z.ConstValue.DeActiveOption, self.refreshLoopList, self)
  Z.EventMgr:Add(Z.ConstValue.PointClickOption, self.onPointClickOption, self)
  Z.EventMgr:Add(Z.ConstValue.SelectInteractionOption, self.refreshInteractionView, self)
end

function InteractionView:BindLuaAttrWatchers()
  if Z.EntityMgr.PlayerEnt ~= nil then
    self.playerBattleWatcher_ = self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrCombatState")
    }, Z.EntityMgr.PlayerEnt, self.battleStateProcess)
  end
end

function InteractionView:battleStateProcess()
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrCombatState")).Value
  self:setScrollViewVisible(stateId <= 0)
end

function InteractionView:UnBindLuaAttrWatchers()
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
  if self.playerBattleWatcher_ then
    self:UnBindEntityLuaAttrWatcher(self.playerBattleWatcher_)
    self.playerBattleWatcher_ = nil
  end
end

function InteractionView:OnDeActive()
  self.navigateInputKeyDescComp_:UnInit()
  self:UnBindLuaAttrWatchers()
  self:unInitLoopComp()
  self:checkProgress(E.InteractionProgressCheckType.InteractionDeActive)
  self.lastStateId_ = -1
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

function InteractionView:initLoopComp()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, loopInteractionItem, "interaction_item_tpl", true)
  self.loopListView_:Init({})
end

function InteractionView:refreshLoopList()
  local handleDataList = self.interactionData_:GetData()
  local count = #handleDataList
  local curSelectIndex = self.loopListView_:GetSelectedIndex()
  if curSelectIndex < 1 or count < curSelectIndex then
    curSelectIndex = 1
  end
  self.loopListView_:ClearAllSelect()
  self.loopListView_:RefreshListView(handleDataList)
  self.loopListView_:SetSelected(curSelectIndex)
  self:setScrollViewVisible(0 < count)
  self.uiBinder.Ref:SetVisible(self.uiBinder.main_mouse, Z.IsPCUI and 2 <= count)
  self:checkCameraZoom()
end

function InteractionView:unInitLoopComp()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function InteractionView:checkCameraZoom()
  if not Z.IsPCUI then
    return
  end
  local handleDataList = self.interactionData_:GetData()
  if 2 <= #handleDataList then
    if not self.lockCameraZoom_ then
      self.lockCameraZoom_ = true
      Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2, true)
    end
  elseif self.lockCameraZoom_ then
    self.lockCameraZoom_ = false
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2, false)
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

function InteractionView:setScrollViewVisible(isVisible)
  if isVisible then
    local handleDataList = self.interactionData_:GetData()
    if 0 < #handleDataList then
      self.uiBinder.scroll_canvas.blocksRaycasts = true
      self.uiBinder.scroll_canvas.interactable = true
      self.uiBinder.scroll_doTween:DoCanvasGroup(1, 0.3)
    end
  else
    self.uiBinder.scroll_canvas.blocksRaycasts = false
    self.uiBinder.scroll_canvas.interactable = false
    self.uiBinder.scroll_doTween:DoCanvasGroup(0, 0.3)
  end
end

function InteractionView:onPointClickOption(index)
  Z.CoroUtil.create_coro_xpcall(function()
    local handleData = self.loopListView_:GetDataByIndex(index)
    if handleData then
      handleData:OnBtnClick(self.cancelSource)
    end
  end)()
end

function InteractionView:refreshInteractionView(selectIndex)
  self.loopListView_:SetSelected(selectIndex)
  self.loopListView_:MovePanelToItemIndex(selectIndex, 0)
end

return InteractionView
