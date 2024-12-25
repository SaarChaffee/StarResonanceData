local UI = Z.UI
local super = require("ui.ui_subview_base")
local Home_editor_right_subView = class("Home_editor_right_subView", super)
local wareHouseSubView = require("ui/view/home_editor_warehouse_sub_view")
local furnitureHouseSubView = require("ui/view/home_editor_furniture_sub_view")
local settingHouseSubView = require("ui/view/home_editor_setting_sub_view")

function Home_editor_right_subView:ctor(parent)
  self.uiBinder = nil
  self.parent = parent
  super.ctor(self, "home_editor_right_sub", "home_editor/home_editor_right_sub", UI.ECacheLv.None)
  self.subViews = {}
  self.subViews[E.EHomeRightSubType.Furniture] = furnitureHouseSubView.new(self)
  self.subViews[E.EHomeRightSubType.Warehouse] = wareHouseSubView.new(self)
  self.subViews[E.EHomeRightSubType.Setting] = settingHouseSubView.new(self)
end

function Home_editor_right_subView:initBinders()
  self.closeBtn_ = self.uiBinder.btn_close
  self.subViewNode_ = self.uiBinder.node_subview
  self.bgNode_ = self.uiBinder.node_bg
  self.uiBinder.Trans:SetSizeDelta(0, 0)
end

function Home_editor_right_subView:OnActive()
  self:initBinders()
  if self.viewData == E.EHomeRightSubType.Warehouse then
    self.bgNode_:SetWidth(330)
  else
    self.bgNode_:SetWidth(612)
  end
  self.subViews[self.viewData]:Active(nil, self.subViewNode_)
  self:AddClick(self.closeBtn_, function()
    self.parent:OnDeActiveRigtSubView()
  end)
end

function Home_editor_right_subView:OnDeActive()
  self.subViews[self.viewData]:DeActive()
end

function Home_editor_right_subView:OnRefresh()
end

return Home_editor_right_subView
