local UI = Z.UI
local super = require("ui.ui_view_base")
local Camera_cloud_game_shareView = class("Camera_cloud_game_shareView", super)
local CLOUD_FACE_MODE_CHANNEL = "xf_channel"
local CloudChannel = {
  internal = "internal",
  external = "external",
  douyin = "douyin"
}

function Camera_cloud_game_shareView:ctor()
  self.uiBinder = nil
  super.ctor(self, "camera_cloud_game_share")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.faceVM_ = Z.VMMgr.GetVM("face")
end

function Camera_cloud_game_shareView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.property_ = Z.SDKDevices.GetCloudProperty(CLOUD_FACE_MODE_CHANNEL)
  self.isInternalChannels_ = self.property_ == CloudChannel.internal
  self:initView()
  self:initBtn()
end

function Camera_cloud_game_shareView:OnDeActive()
  Z.LuaBridge.ReleaseScreenShot(self.viewData.textureId)
  self:ClearAllUnits()
end

function Camera_cloud_game_shareView:OnRefresh()
end

function Camera_cloud_game_shareView:initBtn()
  self:AddClick(self.uiBinder.btn_back, function()
    Z.UIMgr:CloseView("camerasys")
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_share, function()
    self.cameraVM_.SendCloudFaceData(self.viewData.shareCode)
  end)
  self:AddClick(self.uiBinder.btn_copy, function()
    self:onClickCopyBtn()
  end)
  self:AddClick(self.uiBinder.btn_copy_1, function()
    self:onClickCopyBtn()
  end)
end

function Camera_cloud_game_shareView:initView()
  self:setNodeIsShowByChannel()
  self.uiBinder.lab_content.text = self.isInternalChannels_ and Lang("ConfirmCompletion") or Lang("Finish")
  if not self.viewData then
    return
  end
  self.uiBinder.rimg_half:SetNativeTexture(self.viewData.textureId)
end

function Camera_cloud_game_shareView:onClickCopyBtn()
  Z.LuaBridge.SystemCopy(self.viewData.shareCode)
  self.cameraVM_.SendCloudFaceCopyData(self.viewData.shareCode)
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("CopyCloudShareCode", {
    val = self.viewData.shareCode
  }))
end

function Camera_cloud_game_shareView:setNodeIsShowByChannel()
  self:SetUIVisible(self.uiBinder.rimg_bg_root, false)
  self:SetUIVisible(self.uiBinder.rimg_bg_root_1, false)
  self:SetUIVisible(self.uiBinder.rimg_bg_root_code, false)
  if self.property_ == CloudChannel.internal then
    self:SetUIVisible(self.uiBinder.rimg_bg_root, true)
  elseif self.property_ == CloudChannel.douyin then
    self:setQrCode()
    self:SetUIVisible(self.uiBinder.rimg_bg_root_code, true)
  else
    self:SetUIVisible(self.uiBinder.rimg_bg_root_1, true)
  end
end

function Camera_cloud_game_shareView:setQrCode()
  local rect = self.uiBinder.node_code.rect
  local colorData = Z.QrCodeUtil.GenerateQrCode(self.viewData.shareCode, rect.width, rect.height, 0)
  if not colorData then
    return
  end
  self.uiBinder.rimg_code:SetTextureByColor32(rect.width, rect.height, colorData)
end

return Camera_cloud_game_shareView
