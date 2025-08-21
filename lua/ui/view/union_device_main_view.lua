local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_device_mainView = class("Union_device_mainView", super)
local unionBuffView = require("ui.view.union_device_buff_sub_view")
local unionBossBuffView = require("ui.view.union_device_battle_sub_view")

function Union_device_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_device_main")
end

function Union_device_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.commonVM = Z.VMMgr.GetVM("common")
  self.funcVm_ = Z.VMMgr.GetVM("gotofunc")
  self.buildConfig_ = self.unionVM_:GetUnionBuildConfig(E.UnionBuildId.Buff)
  local funcName = self.commonVM.GetTitleByConfig(E.UnionFuncId.Build)
  self.uiBinder.lab_title.text = string.zconcat(funcName, "/", self.buildConfig_.BuildingName)
  self.subViews_ = {
    [1] = unionBuffView.new(self),
    [2] = unionBossBuffView.new(self)
  }
  self.btnViewSelect_ = {
    [1] = self.uiBinder.union_device_tog_yield.node_tog,
    [2] = self.uiBinder.union_device_tog_battle.node_tog
  }
  self.btnViewSelect_[2].Ref.UIComp:SetVisible(self.funcVm_.CheckFuncCanUse(E.FunctionID.RaidDungeonBuff, true))
  self:initComponent()
  if self.buildConfig_.NpcUId and self.buildConfig_.NpcUId ~= 0 then
    Z.NpcBehaviourMgr:SetDialogCameraByConfigId(301, self.buildConfig_.NpcUId)
  else
    Z.CameraMgr:CameraInvoke(E.CameraState.Position, true, self.buildConfig_.CameraTemplateId, false)
  end
end

function Union_device_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.curSubView_ then
    self.curSubView_:DeActive()
    self.curSubView_ = nil
  end
  if self.buildConfig_.NpcId and self.buildConfig_.NpcId ~= 0 then
    Z.CameraMgr:CloseDialogCamera()
  else
    Z.CameraMgr:CameraInvoke(E.CameraState.Position, false, self.buildConfig_.CameraTemplateId, false)
  end
end

function Union_device_mainView:OnRefresh()
end

function Union_device_mainView:initComponent()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.OpenFullScreenTipsView(5001062)
  end)
  local selectIndex = 1
  for index, value in ipairs(self.btnViewSelect_) do
    value.Ref:SetVisible(value.node_off, selectIndex ~= index)
    value.Ref:SetVisible(value.node_on, selectIndex == index)
    self:AddAsyncClick(value.btn_click, function()
      value.Ref:SetVisible(value.node_off, false)
      value.Ref:SetVisible(value.node_on, true)
      if self.curViewSelect_ then
        self.curViewSelect_.Ref:SetVisible(self.curViewSelect_.node_off, true)
        self.curViewSelect_.Ref:SetVisible(self.curViewSelect_.node_on, false)
      end
      self.curViewSelect_ = value
      self:openRightSubView(index)
    end)
  end
  self.curViewSelect_ = self.btnViewSelect_[selectIndex]
  self:openRightSubView(selectIndex)
end

function Union_device_mainView:openRightSubView(index)
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  self.curSubView_ = self.subViews_[index]
  self.curSubView_:Active(nil, self.uiBinder.node_sub)
end

return Union_device_mainView
