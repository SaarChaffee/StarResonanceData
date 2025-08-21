local UI = Z.UI
local super = require("ui.ui_subview_base")
local Expression_fishing_subView = class("Expression_fishing_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local expression_action_item_tpl = require("ui/component/expression/expression_action_item_tpl")
local camera_fish_item_tpl_ = require("ui/component/camerasys/camera_fishing_action_item_tpl")

function Expression_fishing_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "expression_fishing_sub", "expression_pc/expression_fishing_sub", UI.ECacheLv.None)
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.fishing_data_ = Z.DataMgr.Get("fishing_data")
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.quickJumpVM_ = Z.VMMgr.GetVM("quick_jump")
end

function Expression_fishing_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:initJumpParam()
  self:initUi()
  self:bindWatcher()
end

function Expression_fishing_subView:bindWatcher()
  function self.unlockTypeListChange(container, dirty)
    if dirty.unlockTypeList and self.expressionData_:GetLogicExpressionType() == E.ExpressionType.Action then
      self:refreshActionScrollView()
    end
  end
  
  Z.ContainerMgr.CharSerialize.showPieceData.Watcher:RegWatcher(self.unlockTypeListChange)
end

function Expression_fishing_subView:OnDeActive()
  if self.fishLoopScrollRect_ then
    self.fishLoopScrollRect_:UnInit()
    self.fishLoopScrollRect_ = nil
  end
  if self.actionLoopScrollRect_ then
    self.actionLoopScrollRect_:UnInit()
    self.actionLoopScrollRect_ = nil
  end
  self:unBindWatcher()
end

function Expression_fishing_subView:OnRefresh()
  self:refreshActionScrollView()
  self:refreshFishingScrollView()
end

function Expression_fishing_subView:refreshActionScrollView()
  local itemList = self.expressionVm_.GetExpressionShowDataByType(E.DisplayExpressionType.FishingAction, true)
  if not itemList then
    return
  end
  self.actionLoopScrollRect_:RefreshListView(itemList)
end

function Expression_fishing_subView:refreshFishingScrollView()
  local itemList
  itemList = self.fishing_data_:GetActionFishList()
  if not itemList or next(itemList) == nil then
    self:setFishingEmptyState(true)
    return
  end
  self:setFishingEmptyState(false)
  self.fishLoopScrollRect_:RefreshListView(itemList)
end

function Expression_fishing_subView:initUi()
  self.fishLoopScrollRect_ = loopGridView.new(self, self.uiBinder.scrollview_fishing, camera_fish_item_tpl_, "camera_fishing_action_item_tpl_pc")
  self.fishLoopScrollRect_:Init({})
  self.actionLoopScrollRect_ = loopGridView.new(self, self.uiBinder.scrollview_emote, expression_action_item_tpl, "expression_action_item_tpl")
  self.actionLoopScrollRect_:Init({})
  self:AddClick(self.uiBinder.btn_go, function()
    self.quickJumpVM_.DoJumpByConfigParam(self.jumpType_, self.jumpParam_)
  end)
end

function Expression_fishing_subView:initJumpParam()
  local jump = Z.Global.EmoteNoFishQuickJump
  self.jumpType_ = jump[1]
  self.jumpParam_ = {
    jump[2],
    jump[3],
    jump[4]
  }
end

function Expression_fishing_subView:setFishingEmptyState(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_fishing, not isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, isShow)
end

function Expression_fishing_subView:unBindWatcher()
  Z.ContainerMgr.CharSerialize.showPieceData.Watcher:UnregWatcher(self.unlockTypeListChange)
  self.unlockTypeListChange = nil
end

return Expression_fishing_subView
