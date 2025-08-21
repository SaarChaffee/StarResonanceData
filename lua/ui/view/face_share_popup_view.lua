local UI = Z.UI
local super = require("ui.ui_view_base")
local Face_share_popupView = class("Face_share_popupView", super)
local oldShareCodeLenght = 30

function Face_share_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "face_share_popup")
end

function Face_share_popupView:OnActive()
  self.faceVm_ = Z.VMMgr.GetVM("face")
  self.faceData_ = Z.DataMgr.Get("face_data")
  self.funcVm_ = Z.VMMgr.GetVM("gotofunc")
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.uiBinder.input_share.text = ""
  self:SetUIVisible(self.uiBinder.node_tips_prompt, Z.IsPreFaceMode)
  self:AddAsyncClick(self.uiBinder.btn_cancel, function()
    Z.UIMgr:CloseView("face_share_popup")
  end)
  self:AddAsyncClick(self.uiBinder.btn_confirm, function()
    if self.viewData == E.FaceShareType.Share then
      function self.faceData_.UploadFaceDataSuccess(key)
        Z.LuaBridge.SystemCopy(key)
        
        Z.TipsVM.ShowTips(120016)
      end
      
      self.faceVm_.UploadFaceData()
      Z.UIMgr:CloseView("face_share_popup")
    elseif self.viewData == E.FaceShareType.AutoShare then
      Z.UIMgr:CloseView("face_share_popup")
    elseif self.viewData == E.FaceShareType.Input then
      if not self.shareCode_ then
        Z.TipsVM.ShowTips(120019)
        return
      end
      if self:isNewVersionShareCode(string.len(self.shareCode_)) then
        local isSuccess = Z.FaceShareHelper.UseFaceShareCode(self.shareCode_)
        if isSuccess then
          Z.UIMgr:CloseView("face_share_popup")
        end
      else
        if Z.IsPreFaceMode then
          Z.TipsVM.ShowTips(120019)
          return
        end
        self.faceVm_.DownloadFaceData(self.shareCode_, self.cancelSource, function()
          Z.UIMgr:CloseView("face_share_popup")
        end)
      end
    end
  end)
  self:AddClick(self.uiBinder.btn_qr, function()
    if Z.IsPCUI then
      self:loadFaceShareFile()
    else
      self:openFaceShareScan()
    end
  end)
  if self.viewData == E.FaceShareType.AutoShare then
    self:refreshAutoShareState()
  elseif self.viewData == E.FaceShareType.Share then
    self:refreshShareState()
  else
    self:refreshInputState()
  end
end

function Face_share_popupView:OnDeActive()
  self.shareCode_ = nil
end

function Face_share_popupView:refreshAutoShareState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.input_share, false)
  self.uiBinder.input_share:RemoveAllListeners()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_share, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_cancel, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qr, false)
  self.uiBinder.lab_ok.text = Lang("BtnYes")
  if self.faceData_.FaceCosDataList and #self.faceData_.FaceCosDataList > 0 then
    local shareCode = self.faceData_.FaceCosDataList[1].shortGuid
    local param = {
      faceshare = Z.RichTextHelper.ApplyColorTag(shareCode, "#CCE992")
    }
    self.uiBinder.lab_share.text = Lang("face_share", param)
    self.uiBinder.lab_title.text = Lang("facesharetitle")
    self.uiBinder.lab_content.text = Lang("face_share_popup_auto_content")
    Z.LuaBridge.SystemCopy(shareCode)
    Z.TipsVM.ShowTips(120016)
    self:AddClick(self.uiBinder.btn_copy, function()
      Z.LuaBridge.SystemCopy(shareCode)
      Z.TipsVM.ShowTips(120016)
    end)
  end
end

function Face_share_popupView:refreshShareState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.input_share, false)
  self.uiBinder.input_share:RemoveAllListeners()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_share, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_cancel, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qr, false)
  local shareCode = ""
  if self.faceData_.FaceCosDataList and #self.faceData_.FaceCosDataList > 0 then
    shareCode = self.faceData_.FaceCosDataList[1].shortGuid
  end
  local param = {
    faceshare = Z.RichTextHelper.ApplyColorTag(shareCode, "#CCE992")
  }
  self.uiBinder.lab_share.text = Lang("face_share", param)
  self.uiBinder.lab_title.text = Lang("facesharetitle")
  self.uiBinder.lab_content.text = Lang("face_share_popup_content")
  self.uiBinder.lab_ok.text = Lang("face_share_ok")
  self:AddClick(self.uiBinder.btn_copy, function()
    Z.LuaBridge.SystemCopy(shareCode)
    Z.TipsVM.ShowTips(120016)
  end)
end

function Face_share_popupView:refreshInputState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.input_share, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_share, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_cancel, true)
  self.uiBinder.lab_title.text = Lang("faceinputtitle")
  self.uiBinder.lab_ok.text = Lang("BtnYes")
  self.uiBinder.input_share:AddListener(function(string)
    self.shareCode_ = string
  end)
  self.uiBinder.input_share:AddEndEditListener(function(text)
    self.uiBinder.input_share:MoveTextEnd(false)
  end)
  self:refreshFaceScanState()
end

function Face_share_popupView:openFaceShareScan()
  Z.PermissionUtils.CheckOrRequestPermission(Panda.SDK.PlatformPermission.Camera, function(isPermission)
    if isPermission then
      Z.UIMgr:OpenView("face_scan_window")
    else
      Z.TipsVM.ShowTips(4401)
    end
  end)
end

function Face_share_popupView:loadFaceShareFile()
  Z.FaceShareHelper.OpenFaceShareFiler()
end

function Face_share_popupView:refreshFaceScanState()
  if Z.IsPreFaceMode then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qr, false)
    return
  end
  local functionId
  if Z.SDKDevices.RuntimeOS == E.OS.iOS then
    functionId = E.FunctionID.FaceShareScanIOS
  elseif Z.SDKDevices.RuntimeOS == E.OS.Android then
    functionId = E.FunctionID.FaceShareScanAndroid
  elseif Z.SDKDevices.RuntimeOS == E.OS.Windows then
    functionId = E.FunctionID.FaceShareLoadWin
  end
  if functionId and not self.funcVm_.FuncIsOn(functionId, true) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qr, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_scan, not Z.IsPCUI)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_leading, Z.IsPCUI)
  self.uiBinder.lab_qrcode.text = Z.IsPCUI and Lang("LeadingQRCode") or Lang("ScanQRCode")
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qr, true)
end

function Face_share_popupView:isNewVersionShareCode(codeLength)
  return codeLength > oldShareCodeLenght
end

return Face_share_popupView
