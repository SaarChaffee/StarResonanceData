local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_unionBgView = class("Camera_menu_container_unionBgView", super)
local camerasysData = Z.DataMgr.Get("camerasys_data")
local CameraUnionBgItem = require("ui.component.camerasys.camerasys_union_bg_item")
local loopGridView = require("ui.component.loop_grid_view")

function Camera_menu_container_unionBgView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_bg_sub", "photograph/camera_menu_container_bg_sub", UI.ECacheLv.None)
end

function Camera_menu_container_unionBgView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.cardLoopScroll_ = loopGridView.new(self, self.uiBinder.scrollview_filter, CameraUnionBgItem, "photo_idcard_bg_tpl")
  local data = self.cameraData_:GetUnionBgCfg()
  self.cardLoopScroll_:Init(data)
end

function Camera_menu_container_unionBgView:OnDeActive()
  self.cardLoopScroll_:UnInit()
  self.cardLoopScroll_ = nil
end

function Camera_menu_container_unionBgView:OnRefresh()
end

return Camera_menu_container_unionBgView
