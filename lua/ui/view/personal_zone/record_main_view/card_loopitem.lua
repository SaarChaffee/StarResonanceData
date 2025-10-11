local super = require("ui.component.loop_grid_view_item")
local PersonalZoneCard = class("PersonalZoneCard", super)
local PersonalZoneDefine = require("ui.model.personalzone_define")

function PersonalZoneCard:ctor()
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
end

function PersonalZoneCard:OnInit()
  self.currentSelect_ = 0
  self.view_ = self.parent.UIView
end

function PersonalZoneCard:OnPointerClick(go, eventData)
  if self.view_.selectId_ == self.data_.config.Id then
    return
  end
  self.view_:SetSelect(self.data_.config.Id)
end

function PersonalZoneCard:OnUnInit()
end

function PersonalZoneCard:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_photo:SetImage(Z.ConstValue.PersonalZone.PersonalCBg .. self.data_.config.Image)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_use, self.data_.config.Id == self.view_.currentCardId_)
  local isProfileImageUnlocked = self.personalZoneVM_.CheckProfileImageIsUnlock(self.data_.config.Id)
  local iconColor = isProfileImageUnlocked and PersonalZoneDefine.UnLockIconColorState.Unlock or PersonalZoneDefine.UnLockIconColorState.Unlocked
  local isGroupVisible = not isProfileImageUnlocked
  self.uiBinder.img_photo:SetColor(iconColor)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_unlocked, isGroupVisible)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.data_.select)
  if self.data_.select then
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  else
    self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Open)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reddot, self.personalZoneVM_.CheckSingleRedDot(self.data_.config.Id))
end

return PersonalZoneCard
