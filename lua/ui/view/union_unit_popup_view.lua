local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_unit_popupView = class("Union_unit_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local union_build_upgrade_item = require("ui.component.union.union_build_upgrade_item")
local union_build_buff_item = require("ui.component.union.union_build_buff_item")
local ICON_PATH = {
  [E.UnionBuildPopupType.Upgrade] = "ui/atlas/item/c_tab_icon/com_icon_tab_130",
  [E.UnionBuildPopupType.Buff] = "ui/atlas/item/c_tab_icon/com_icon_tab_120"
}
local CENTER_COUNT = 3

function Union_unit_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_unit_popup")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
end

function Union_unit_popupView:OnActive()
  self:initData()
  self:initComponent()
  self:onStartAnimShow()
  self:refreshTotalInfo()
end

function Union_unit_popupView:OnDeActive()
  self:unInitLoopListView()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_item_eff)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.img_depth_build)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.img_frame)
end

function Union_unit_popupView:OnRefresh()
end

function Union_unit_popupView:onStartAnimShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_item_eff)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.img_depth_build)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.img_frame)
  self.uiBinder.anim:PlayOnce("anim_union_unit_popup_open")
  self.uiBinder.anim_dotween:Restart(Z.DOTweenAnimType.Open)
end

function Union_unit_popupView:initData()
  self.popupType_ = self.viewData.Type
  self.buildId_ = self.viewData.BuildId
  self.extendParams_ = self.viewData.ExtendParams
  self.buildConfig_ = self.unionVM_:GetUnionBuildConfig(self.buildId_)
  self.buildInfo_ = self.unionVM_:GetBuildInfo(self.buildId_)
end

function Union_unit_popupView:initComponent()
  self.uiBinder.scenemask_bg:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_mask, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
end

function Union_unit_popupView:refreshTotalInfo()
  self.uiBinder.lab_build_name.text = self.buildConfig_.BuildingName
  self.uiBinder.img_build:SetImage(self.buildConfig_.SmallPicture)
  self.uiBinder.img_icon:SetImage(ICON_PATH[self.popupType_])
  if self.popupType_ == E.UnionBuildPopupType.Upgrade then
    self.uiBinder.lab_title.text = Lang("level_upgrade_success")
    self:refreshUpgradeInfo()
  elseif self.popupType_ == E.UnionBuildPopupType.Buff then
    self.uiBinder.lab_title.text = Lang("CongratulationsGetting")
    self:refreshBuffInfo()
  end
end

function Union_unit_popupView:refreshUpgradeInfo()
  local curLevel = self.buildInfo_.buildingLevel
  local dataList = {}
  dataList[1] = {Type = "Level", Value = curLevel}
  local diffInfoList = self.unionData_:GetUnionUpgradeDiffPurview(self.buildId_, curLevel)
  for i, v in ipairs(diffInfoList) do
    dataList[i + 1] = {Type = "Effect", Value = v}
  end
  self:initLoopListView(dataList)
end

function Union_unit_popupView:refreshBuffInfo()
  local buffInfo = self.extendParams_
  local configMgr = Z.TableMgr.GetTable("UnionTimelinessBuffTableMgr")
  local config = configMgr.GetRow(buffInfo.effectBuffId)
  local dataList = {}
  dataList[1] = {
    Type = "Time",
    Value = config.Time
  }
  dataList[2] = {Type = "Effect", Value = config}
  self:initLoopListView(dataList)
end

function Union_unit_popupView:initLoopListView(dataList)
  if self.popupType_ == E.UnionBuildPopupType.Upgrade then
    self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, union_build_upgrade_item, "union_unit_item_1_tpl")
  elseif self.popupType_ == E.UnionBuildPopupType.Buff then
    self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, union_build_buff_item, "union_unit_item_2_tpl")
  end
  self.loopListView_:Init(dataList)
  if #dataList > CENTER_COUNT then
    self.uiBinder.node_content:SetPivot(0, 1)
  else
    self.uiBinder.node_content:SetPivot(0, 0.5)
  end
end

function Union_unit_popupView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

return Union_unit_popupView
