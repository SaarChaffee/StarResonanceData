local UI = Z.UI
local super = require("ui.ui_view_base")
local Battle_hitView = class("Battle_hitView", super)
local hitNumberImgAddr_ = "ui/atlas/mainui/hit/hit_img_"

function Battle_hitView:ctor()
  self.uiBinder = nil
  super.ctor(self, "battle_hit")
end

function Battle_hitView:OnActive()
  self:startAnimatedShow()
  self.lastNumberChars_ = nil
  self.lastNumber_ = 0
  self.animNumbers_ = {
    [1] = self.uiBinder.anim_number_1,
    [2] = self.uiBinder.anim_number_2,
    [3] = self.uiBinder.anim_number_3,
    [4] = self.uiBinder.anim_number_4
  }
  self.slicedImgNumbers_ = {
    [1] = self.uiBinder.sliced_img_number_1,
    [2] = self.uiBinder.sliced_img_number_2,
    [3] = self.uiBinder.sliced_img_number_3,
    [4] = self.uiBinder.sliced_img_number_4
  }
  for index, value in ipairs(self.animNumbers_) do
    self:SetUIVisible(value, false)
  end
end

function Battle_hitView:OnDeActive()
  self.lastNumberChars_ = nil
  self.lastNumber_ = 0
  for index, value in ipairs(self.animNumbers_) do
    value:Stop()
    self:SetUIVisible(value, false)
  end
  self.animNumbers_ = nil
  self.slicedImgNumbers_ = nil
end

function Battle_hitView:startAnimatedShow()
  self.uiBinder.anim_main:PlayOnce("anim_fx_hit_number_enter")
end

function Battle_hitView:startAnimatedHide()
  local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.anim_main.CoroPlayOnce)
  asyncCall(self.uiBinder.anim_main, "anim_fx_hit_number_end", self.cancelSource:CreateToken())
end

function Battle_hitView:OnRefresh()
  if not self.viewData then
    return
  end
  if self.lastNumber_ == self.viewData.hitNumber then
    return
  end
  self.lastNumber_ = self.viewData.hitNumber
  local numberChars = string.ztoChars(self.viewData.hitNumber)
  if self.lastNumberChars_ == nil or #self.lastNumberChars_ ~= #numberChars then
    for index, value in ipairs(numberChars) do
      local slicedImg = self.slicedImgNumbers_[index]
      slicedImg:SetImage(hitNumberImgAddr_ .. value.char)
      local anim = self.animNumbers_[index]
      anim:PlayOnce("anim_fx_hit_number_change")
      self:SetUIVisible(anim, true)
    end
  else
    local minIndex = 10
    for index, value in ipairs(numberChars) do
      if value.char ~= self.lastNumberChars_[index].char and index < minIndex then
        minIndex = index
      end
    end
    for i = minIndex, #numberChars do
      local slicedImg = self.slicedImgNumbers_[i]
      slicedImg:SetImage(hitNumberImgAddr_ .. numberChars[i].char)
      local anim = self.animNumbers_[i]
      anim:PlayOnce("anim_fx_hit_number_change")
      self:SetUIVisible(anim, true)
    end
  end
  self.lastNumberChars_ = numberChars
end

return Battle_hitView
