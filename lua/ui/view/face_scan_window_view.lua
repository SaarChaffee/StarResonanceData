local UI = Z.UI
local super = require("ui.ui_view_base")
local Face_scan_windowView = class("Face_scan_windowView", super)

function Face_scan_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "face_scan_window")
end

function Face_scan_windowView:OnActive()
  self.widthMax_ = 960
  self.heightMax_ = 540
  self.funcVm_ = Z.VMMgr.GetVM("gotofunc")
  self.uiBinder.btn_return:AddListener(function()
    Z.UIMgr:CloseView("face_scan_window")
  end)
  self.uiBinder.btn_album:AddListener(function()
    Z.FaceShareHelper.OpenFaceShareFiler()
  end)
  self.uiBinder.node_qrcode:AddValueEndChangeListener(function(codeData)
    Z.FaceShareHelper.UseFaceShareCode(codeData)
    Z.UIMgr:CloseView("face_scan_window")
    Z.UIMgr:CloseView("face_share_popup")
  end)
  self:refreshAlbumBtn()
  self:refreshWebCamTexture()
end

function Face_scan_windowView:OnDeActive()
  self.uiBinder.node_qrcode:StopScanQrCode()
end

function Face_scan_windowView:refreshAlbumBtn()
  if Z.IsPreFaceMode then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_album, false)
    return
  end
  local functionId
  if Z.SDKDevices.RuntimeOS == E.OS.iOS then
    functionId = E.FunctionID.FaceShareLoadIOS
  elseif Z.SDKDevices.RuntimeOS == E.OS.Android then
    functionId = E.FunctionID.FaceShareLoadAndroid
  elseif Z.SDKDevices.RuntimeOS == E.OS.Windows then
    functionId = E.FunctionID.FaceShareLoadWin
  end
  if functionId and not self.funcVm_.FuncIsOn(functionId, true) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_album, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_album, true)
end

function Face_scan_windowView:refreshWebCamTexture()
  local rootCanvas = Z.UIRoot.RootCanvas.transform
  local width = math.floor(rootCanvas.rect.width * 100) / 100
  local height = math.floor(rootCanvas.rect.height * 100) / 100
  local rate = self.widthMax_ / self.heightMax_
  local scanWidth = self.widthMax_
  local scanHeight = self.heightMax_
  if rate < width / height then
    if height < self.heightMax_ then
      scanWidth = rate * height
      scanHeight = height
    end
  elseif width < self.widthMax_ then
    scanWidth = width
    scanHeight = scanWidth / rate
  end
  local isSuccess = self.uiBinder.node_qrcode:InitWebCamTexture(scanWidth, scanHeight)
  if isSuccess then
    self.uiBinder.node_qrcode:PlayScanQrCode()
  else
    Z.TipsVM.ShowTips(4401)
    Z.UIMgr:CloseView("face_scan_window")
  end
end

return Face_scan_windowView
