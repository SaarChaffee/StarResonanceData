local super = require("ui.ui_view_base")
local Camera_config_popupView = class("Camera_config_popupView", super)
local data = Z.DataMgr.Get("camerasys_data")

function Camera_config_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "camera_config_popup")
end

function Camera_config_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  local cameraConfigScrollRect = self.uiBinder.loopscroll_config
  self.cameraConfigScrollRect_ = require("ui/component/loopscrollrect").new(cameraConfigScrollRect, self, require("ui.component.camerasys.camera_config_select_item"))
  self.uiBinder.btn_save:AddListener(function()
    Z.VMMgr.GetVM("camerasys").SaveCameraSchemeInfo()
    Z.UIMgr:CloseView("camera_config_popup")
  end)
  self.uiBinder.btn_no:AddListener(function()
    Z.UIMgr:CloseView("camera_config_popup")
  end)
end

function Camera_config_popupView:OnDeActive()
end

function Camera_config_popupView:OnRefresh()
  local schemeInfoDatas = data:GetSchemeInfoDatas()
  local showDatas = {}
  for key, value in ipairs(schemeInfoDatas) do
    if value.id ~= -1 then
      showDatas[#showDatas + 1] = value
    end
  end
  table.sort(showDatas, function(a, b)
    return a.schemeTime < b.schemeTime
  end)
  self.cameraConfigScrollRect_:SetData(showDatas)
end

return Camera_config_popupView
