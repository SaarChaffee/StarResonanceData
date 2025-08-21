local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_fishing_subView = class("Camera_menu_container_fishing_subView", super)
local loopScrollRect_ = require("ui.component.loop_grid_view")
local camera_fish_item_tpl_ = require("ui/component/camerasys/camera_fishing_action_item_tpl")
local camera_action_item_tpl_ = require("ui/component/camerasys/camera_setting_action_item_tpl")

function Camera_menu_container_fishing_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_fishing_sub", "photograph/camera_menu_container_fishing_sub", UI.ECacheLv.None)
  self.viewData = nil
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.fishing_data_ = Z.DataMgr.Get("fishing_data")
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.quickJumpVM_ = Z.VMMgr.GetVM("quick_jump")
end

function Camera_menu_container_fishing_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:initUi()
  self:initJumpParam()
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.setLabState, self)
end

function Camera_menu_container_fishing_subView:OnDeActive()
  if self.fishLoopScrollRect_ then
    self.fishLoopScrollRect_:UnInit()
    self.fishLoopScrollRect_ = nil
  end
  if self.actionLoopScrollRect_ then
    self.actionLoopScrollRect_:UnInit()
    self.actionLoopScrollRect_ = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, self.setLabState, self)
end

function Camera_menu_container_fishing_subView:OnRefresh()
  self:refreshActionScrollView()
  self:refreshFishingScrollView()
  self:setLabState()
end

function Camera_menu_container_fishing_subView:refreshActionScrollView()
  local isShowUnLock = self.viewData.OpenSourceType == E.ExpressionOpenSourceType.Expression
  local itemList = self.expressionVm_.GetExpressionShowDataByType(E.DisplayExpressionType.FishingAction, isShowUnLock)
  if not itemList then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_action, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.actionLoopScrollRect_, false)
    return
  end
  self.actionLoopScrollRect_:RefreshListView(itemList)
end

function Camera_menu_container_fishing_subView:refreshFishingScrollView()
  local itemList
  itemList = self.fishing_data_:GetActionFishList()
  if not itemList or next(itemList) == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_fish, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_fish, false)
    return
  end
  self.fishLoopScrollRect_:RefreshListView(itemList)
end

function Camera_menu_container_fishing_subView:initUi()
  self.fishLoopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.scrollview_fish, camera_fish_item_tpl_, "camera_fishing_action_item_tpl")
  self.fishLoopScrollRect_:Init({})
  self.actionLoopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.scrollview_action, camera_action_item_tpl_, "camera_setting_action_item_tpl")
  self.actionLoopScrollRect_:Init({})
  self.uiBinder.tog_big:AddListener(function(isOn)
    if isOn then
      self.fishing_data_:SetActionIsMaxSize(true)
    end
  end)
  self.uiBinder.tog_small:AddListener(function(isOn)
    if isOn then
      self.fishing_data_:SetActionIsMaxSize(false)
    end
  end)
  self:AddClick(self.uiBinder.btn_go, function()
    self.quickJumpVM_.DoJumpByConfigParam(self.jumpType_, self.jumpParam_)
  end)
  local isMaxSize = self.fishing_data_:GetActionIsMaxSize()
  if isMaxSize then
    self.uiBinder.tog_big.isOn = true
  else
    self.uiBinder.tog_small.isOn = true
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_action, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_fish, false)
  self:setLabState()
end

function Camera_menu_container_fishing_subView:setLabState()
  local isOpen = self.gotoFuncVM_.CheckFuncCanUse(E.FunctionID.FishingAction, true)
  self.uiBinder.canvas_tips.alpha = isOpen and 1 or 0.5
end

function Camera_menu_container_fishing_subView:initJumpParam()
  local jump = Z.Global.EmoteNoFishQuickJump
  self.jumpType_ = jump[1]
  self.jumpParam_ = {
    jump[2],
    jump[3],
    jump[4]
  }
end

return Camera_menu_container_fishing_subView
