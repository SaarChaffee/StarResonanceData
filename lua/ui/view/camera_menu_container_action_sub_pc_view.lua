local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_action_sub_pcView = class("Camera_menu_container_action_sub_pcView", super)
local loopScrollRect_ = require("ui.component.loop_grid_view")
local camera_action_item_tpl_ = require("ui/component/camerasys/camera_action_item_tpl")

function Camera_menu_container_action_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_action_sub_pc", "photograph_pc/camera_menu_container_action_sub_pc", UI.ECacheLv.None)
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.commonVm_ = Z.VMMgr.GetVM("common")
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.multActionData_ = Z.DataMgr.Get("multaction_data")
  self.multActionVm_ = Z.VMMgr.GetVM("multaction")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
end

function Camera_menu_container_action_sub_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.model_ = nil
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    self.model_ = self.cameraData_:GetUnionModel()
  end
  self:initUi()
end

function Camera_menu_container_action_sub_pcView:OnDeActive()
  if self.loopScrollRect_ then
    self.loopScrollRect_:UnInit()
    self.loopScrollRect_ = nil
  end
  self.model_ = nil
end

function Camera_menu_container_action_sub_pcView:OnRefresh()
  self:refreshLoopList()
  self:setSubViewName()
end

function Camera_menu_container_action_sub_pcView:setSubViewName()
  if self.cameraData_:GetSettingViewSecondaryLogicIndex() == -1 then
    return
  end
  local photoGraphUiTable = self.cameraVM_.GetPcPhotographUiTableRow(self.cameraData_:GetSettingViewSecondaryLogicIndex())
  if not photoGraphUiTable then
    return
  end
  self.uiBinder.lab_name.text = Lang(photoGraphUiTable.Name)
end

function Camera_menu_container_action_sub_pcView:initEmoteData()
  local displayExpressionType = self.expressionData_:GetDisplayExpressionType()
  local itemList = self.expressionVm_.GetExpressionShowDataByType(displayExpressionType, false)
  return itemList
end

function Camera_menu_container_action_sub_pcView:refreshLoopList()
  local itemList
  itemList = self:initEmoteData()
  if not itemList then
    return
  end
  self.loopScrollRect_:RefreshListView(itemList)
end

function Camera_menu_container_action_sub_pcView:initUi()
  self.loopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.loop_scrollview, camera_action_item_tpl_, "expression_action_item_tpl")
  self.loopScrollRect_:Init({})
  self:AddClick(self.uiBinder.btn_reset, function()
    self:btnReset()
  end)
end

function Camera_menu_container_action_sub_pcView:btnReset(isNotResetEmote)
  self.expressionData_:SetCurPlayingId(-1)
  local logicExpressionType = self.expressionData_:GetLogicExpressionType()
  if logicExpressionType == E.ExpressionType.Action then
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.ActionReset)
  else
    if isNotResetEmote then
      return
    end
    if self.model_ then
      Z.ZAnimActionPlayMgr:ResetEmote(self.model_)
    else
      Z.ZAnimActionPlayMgr:ResetEmote()
    end
  end
end

return Camera_menu_container_action_sub_pcView
