local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_action_fishing_sub_pcView = class("Camera_menu_container_action_fishing_sub_pcView", super)
local loopScrollRect_ = require("ui.component.loop_grid_view")
local camera_fish_item_tpl_ = require("ui/component/camerasys/camera_fishing_action_item_tpl")
local camera_action_item_tpl_ = require("ui/component/camerasys/camera_action_item_tpl")

function Camera_menu_container_action_fishing_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_action_fishing_sub_pc", "photograph_pc/camera_menu_container_action_fishing_sub_pc", UI.ECacheLv.None)
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.fishing_data_ = Z.DataMgr.Get("fishing_data")
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.quickJumpVM_ = Z.VMMgr.GetVM("quick_jump")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
end

function Camera_menu_container_action_fishing_sub_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:initJumpParam()
  self:initUi()
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.setLabState, self)
end

function Camera_menu_container_action_fishing_sub_pcView:OnDeActive()
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

function Camera_menu_container_action_fishing_sub_pcView:OnRefresh()
  self:refreshActionScrollView()
  self:refreshFishingScrollView()
end

function Camera_menu_container_action_fishing_sub_pcView:initUi()
  self:AddClick(self.uiBinder.btn_reset, function()
    self:btnReset()
  end)
  self:AddClick(self.uiBinder.btn_go, function()
    self.quickJumpVM_.DoJumpByConfigParam(self.jumpType_, self.jumpParam_)
  end)
  self.fishLoopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.node_fishing_scrollview, camera_fish_item_tpl_, "camera_fishing_action_item_tpl_pc")
  self.fishLoopScrollRect_:Init({})
  self.actionLoopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.node_acion_scrollview, camera_action_item_tpl_, "expression_action_item_tpl")
  self.actionLoopScrollRect_:Init({})
  local pcPhotographUiTableRow = self.cameraVM_.GetPcPhotographUiTableRow(E.CameraSystemSubFunctionType.Fishing)
  if pcPhotographUiTableRow then
    self.uiBinder.lab_name.text = Lang(pcPhotographUiTableRow.Name)
  end
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
  local isMaxSize = self.fishing_data_:GetActionIsMaxSize()
  if isMaxSize then
    self.uiBinder.tog_big.isOn = true
  else
    self.uiBinder.tog_small.isOn = true
  end
  self:setLabState()
end

function Camera_menu_container_action_fishing_sub_pcView:refreshActionScrollView()
  local itemList
  itemList = self:initEmoteData()
  if not itemList then
    return
  end
  self.actionLoopScrollRect_:RefreshListView(itemList)
end

function Camera_menu_container_action_fishing_sub_pcView:refreshFishingScrollView()
  local itemList
  itemList = self.fishing_data_:GetActionFishList()
  if not itemList or next(itemList) == nil then
    self:setFishingEmptyState(true)
    return
  end
  self:setFishingEmptyState(false)
  self.fishLoopScrollRect_:RefreshListView(itemList)
end

function Camera_menu_container_action_fishing_sub_pcView:initEmoteData()
  local itemList = self.expressionVm_.GetExpressionShowDataByType(E.DisplayExpressionType.FishingAction, false)
  return itemList
end

function Camera_menu_container_action_fishing_sub_pcView:btnReset()
  self.expressionData_:SetCurPlayingId(-1)
  local logicExpressionType = self.expressionData_:GetLogicExpressionType()
  if logicExpressionType == E.ExpressionType.Action then
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.ActionReset)
  end
end

function Camera_menu_container_action_fishing_sub_pcView:setLabState()
  local isOpen = self.gotoFuncVM_.CheckFuncCanUse(E.FunctionID.FishingAction, true)
  self.uiBinder.canvas_tips.alpha = isOpen and 1 or 0.5
end

function Camera_menu_container_action_fishing_sub_pcView:setFishingEmptyState(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_fishing_scrollview, not isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, isShow)
end

function Camera_menu_container_action_fishing_sub_pcView:initJumpParam()
  local jump = Z.Global.EmoteNoFishQuickJump
  self.jumpType_ = jump[1]
  self.jumpParam_ = {
    jump[2],
    jump[3],
    jump[4]
  }
end

return Camera_menu_container_action_fishing_sub_pcView
