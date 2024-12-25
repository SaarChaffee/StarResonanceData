local UI = Z.UI
local super = require("ui.ui_view_base")
local Cutscene_image_windowView = class("Cutscene_image_windowView", super)
local EImageType = Cutscene.EImageType

function Cutscene_image_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "cutscene_image_window")
end

function Cutscene_image_windowView:OnActive()
  self:SetAsFirstSibling()
end

function Cutscene_image_windowView:OnDeActive()
end

function Cutscene_image_windowView:OnRefresh()
  if self.viewData.trackData.ImageType == EImageType.FullScreen then
    self.image_ = self.uiBinder.cutscene_rawImage
    self.uiBinder.Ref:SetVisible(self.uiBinder.cutscene_image, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.cutscene_rawImage, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, true)
  else
    self.image_ = self.uiBinder.cutscene_image
    self.uiBinder.Ref:SetVisible(self.uiBinder.cutscene_image, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.cutscene_rawImage, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, false)
  end
  self.image_:SetImage(self.viewData.trackData.ImageAddress)
end

return Cutscene_image_windowView
