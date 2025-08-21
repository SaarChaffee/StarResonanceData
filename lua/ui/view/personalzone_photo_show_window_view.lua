local UI = Z.UI
local super = require("ui.ui_view_base")
local Personalzone_photo_show_windowView = class("Personalzone_photo_show_windowView", super)
local REPORTDEFINE = require("ui.model.report_define")

function Personalzone_photo_show_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "personalzone_photo_show_window")
  self.reportVm_ = Z.VMMgr.GetVM("report")
  self.albumMainVm_ = Z.VMMgr.GetVM("album_main")
end

function Personalzone_photo_show_windowView:OnActive()
  self:AddClick(self.uiBinder.btn_close_new, function()
    Z.UIMgr:CloseView("personalzone_photo_show_window")
  end)
  self:AddAsyncClick(self.uiBinder.btn_report, function()
    self.reportVm_.OpenReportPop(REPORTDEFINE.ReportScene.Photo, self.viewData.name, self.viewData.charId, {
      photoId = self.viewData.photoId,
      isUnion = false
    })
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_report, self.viewData.charId ~= Z.EntityMgr.PlayerEnt.EntId)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.photoNativeTextureId_ = nil
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncRefreshPhotoId(self.viewData.charId, self.viewData.photoId)
  end)()
end

function Personalzone_photo_show_windowView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self:releaseNativeTextures()
  self.getPhotoId_ = nil
end

function Personalzone_photo_show_windowView:OnRefresh()
end

function Personalzone_photo_show_windowView:asyncRefreshPhotoId(charId, getPhotoId)
  local ret = self.albumMainVm_.GetPhoto(charId, getPhotoId, self.cancelSource:CreateToken())
  if ret.errCode and ret.errCode ~= 0 then
    return
  end
  local url
  for _, photoValue in pairs(ret.photoGraph.images) do
    if photoValue.type == E.PictureType.ECameraRender then
      url = photoValue.cosUrl
      break
    end
  end
  if url then
    self.albumMainVm_.AsyncGetHttpAlbumPhoto(url, E.PictureType.ECameraThumbnail, E.NativeTextureCallToken.Personalzone_photo_show_view, self.cancelSource, self.onCallback, self)
  end
end

function Personalzone_photo_show_windowView:onCallback(photoId)
  self:releaseNativeTextures()
  self.photoId_ = photoId
  self.uiBinder.rimg_photo:SetNativeTexture(self.photoId_)
end

function Personalzone_photo_show_windowView:releaseNativeTextures()
  if self.photoId_ and self.photoId_ ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId_)
    self.photoId_ = 0
  end
end

return Personalzone_photo_show_windowView
