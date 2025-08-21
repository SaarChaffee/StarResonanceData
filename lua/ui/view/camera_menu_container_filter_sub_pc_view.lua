local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_filter_sub_pcView = class("Camera_menu_container_filter_sub_pcView", super)
local filterPath = "ui/textures/photograph_decoration/filters/"
local loopScrollRect_ = require("ui.component.loop_grid_view")
local camera_menu_filter_item_tpl_ = require("ui/component/camerasys/camera_menu_filter_item_tpl_pc")

function Camera_menu_container_filter_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_filter_sub_pc", "photograph_pc/camera_menu_container_filter_sub_pc", UI.ECacheLv.None)
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.decorateData_ = Z.DataMgr.Get("decorate_add_data")
  self.secondaryData_ = Z.DataMgr.Get("photo_secondary_data")
  self.isToEditing_ = false
end

function Camera_menu_container_filter_sub_pcView:OnActive()
  self.uiBinder.rect_panel:SetOffsetMin(0, 0)
  self.uiBinder.rect_panel:SetOffsetMax(0, 0)
  self.loopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.scrollview_filter, camera_menu_filter_item_tpl_, "camera_menu_filter_item_tpl_pc")
  self.loopScrollRect_:Init({})
end

function Camera_menu_container_filter_sub_pcView:OnDeActive()
  if self.loopScrollRect_ then
    self.loopScrollRect_:UnInit()
    self.loopScrollRect_ = nil
  end
end

function Camera_menu_container_filter_sub_pcView:OnRefresh()
  if not self.viewData then
    self.isToEditing_ = false
  else
    self.isToEditing_ = self.viewData.isToEditing
    self.viewData = {}
  end
  self:refreshLoopList()
end

function Camera_menu_container_filter_sub_pcView:refreshLoopList()
  local data = self.cameraData_:GetFilterCfg()
  self.loopScrollRect_:RefreshListView(data)
end

return Camera_menu_container_filter_sub_pcView
