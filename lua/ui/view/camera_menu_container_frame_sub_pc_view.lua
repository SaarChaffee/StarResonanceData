local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_frame_sub_pcView = class("Camera_menu_container_frame_sub_pcView", super)
local loopScrollRect_ = require("ui.component.loop_grid_view")
local camera_frame_loop_item_ = require("ui/component/camerasys/camera_frame_loop_item")

function Camera_menu_container_frame_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_frame_sub_pc", "photograph_pc/camera_menu_container_frame_sub_pc", UI.ECacheLv.None)
  self.parent_ = parent
  self.isToEditing_ = false
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.decorateData_ = Z.DataMgr.Get("decorate_add_data")
  self.secondaryData_ = Z.DataMgr.Get("photo_secondary_data")
end

function Camera_menu_container_frame_sub_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_slider_transparency, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_current, false)
  self.loopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.scrollview_frame_item, camera_frame_loop_item_, "camera_setting_frame_item_tpl_pc")
  self.loopScrollRect_:Init({})
end

function Camera_menu_container_frame_sub_pcView:OnDeActive()
  if self.loopScrollRect_ then
    self.loopScrollRect_:UnInit()
    self.loopScrollRect_ = nil
  end
end

function Camera_menu_container_frame_sub_pcView:OnRefresh()
  self:refreshLoopList()
  if self.viewData and next(self.viewData) and self.viewData.isToEditing then
    self.isToEditing_ = true
    self.addViewData_ = self.secondaryData_
  else
    self.isToEditing_ = false
    self.addViewData_ = self.decorateData_
  end
end

function Camera_menu_container_frame_sub_pcView:refreshLoopList()
  local data = self.cameraData_:GetDecorateFrameCfg()
  if not data then
    return
  end
  self.loopScrollRect_:RefreshListView(data)
end

return Camera_menu_container_frame_sub_pcView
