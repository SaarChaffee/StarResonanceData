local UI = Z.UI
local super = require("ui.ui_view_base")
local Cutscene_image_windowView = class("Cutscene_image_windowView", super)
local EImageType = Cutscene.EImageType

function Cutscene_image_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "cutscene_image_window")
end

function Cutscene_image_windowView:OnActive()
  self.imgGourp_ = {
    [1] = {
      binder = self.uiBinder.img_1,
      isPlaying = false
    },
    [2] = {
      binder = self.uiBinder.img_2,
      isPlaying = false
    }
  }
  self.uiBinder.img_1.Ref:SetVisible(self.uiBinder.img_1.cutscene_image, false)
  self.uiBinder.img_1.Ref:SetVisible(self.uiBinder.img_1.cutscene_rawImage, false)
  self.uiBinder.img_2.Ref:SetVisible(self.uiBinder.img_2.cutscene_image, false)
  self.uiBinder.img_2.Ref:SetVisible(self.uiBinder.img_2.cutscene_rawImage, false)
  self.addrImgDict_ = {}
  self:SetAsFirstSibling()
end

function Cutscene_image_windowView:OnDeActive()
  Z.UITimelineDisplay:ClearCutsceneImageDict()
end

function Cutscene_image_windowView:OnRefresh()
  if not self.addrImgDict_[self.viewData.trackData.ImageAddress] then
    for _, value in ipairs(self.imgGourp_) do
      if not value.isPlaying then
        self.addrImgDict_[self.viewData.trackData.ImageAddress] = value
        value.isPlaying = true
        break
      end
    end
    if self.viewData.trackData.ImageType == EImageType.FullScreen then
      self.image_ = self.addrImgDict_[self.viewData.trackData.ImageAddress].binder.cutscene_rawImage
      self.imgTrans_ = self.addrImgDict_[self.viewData.trackData.ImageAddress].binder.cutscene_rawImage_trans
      self.addrImgDict_[self.viewData.trackData.ImageAddress].binder.Ref:SetVisible(self.image_, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, true)
    else
      self.image_ = self.addrImgDict_[self.viewData.trackData.ImageAddress].binder.cutscene_image
      self.imgTrans_ = self.addrImgDict_[self.viewData.trackData.ImageAddress].binder.cutscene_image_trans
      self.addrImgDict_[self.viewData.trackData.ImageAddress].binder.Ref:SetVisible(self.image_, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, false)
    end
    self.image_:SetImage(self.viewData.trackData.ImageAddress)
    Z.UITimelineDisplay:SetCutsceneImageDict(self.viewData.trackData.ImageAddress, self.imgTrans_)
  end
end

return Cutscene_image_windowView
