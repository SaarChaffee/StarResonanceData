local UI = Z.UI
local super = require("ui.ui_view_base")
local Battle_hitView = class("Battle_hitView", super)
local hitNumberImgAddr_ = "ui/atlas/mainui/hit/hit_img_"

function Battle_hitView:ctor()
  self.panel = nil
  super.ctor(self, "battle_hit")
end

function Battle_hitView:OnActive()
  self:startAnimatedShow()
  self.lastNumberChars_ = nil
  self.lastNumber_ = 0
  self.numbers_ = {
    [1] = self.panel.numbers.number_1,
    [2] = self.panel.numbers.number_2,
    [3] = self.panel.numbers.number_3,
    [4] = self.panel.numbers.number_4
  }
  for index, value in ipairs(self.numbers_) do
    value:SetVisible(false)
  end
end

function Battle_hitView:OnDeActive()
  self.lastNumberChars_ = nil
  self.lastNumber_ = 0
  for index, value in ipairs(self.numbers_) do
    value.anim:Stop()
    value:SetVisible(false)
  end
end

function Battle_hitView:startAnimatedShow()
  self.panel.anim.anim:PlayOnce("anim_fx_hit_number_enter")
end

function Battle_hitView:startAnimatedHide()
  local asyncCall = Z.CoroUtil.async_to_sync(self.panel.anim.anim.CoroPlayOnce)
  asyncCall(self.panel.anim.anim, "anim_fx_hit_number_end", self.cancelSource:CreateToken())
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
      local anim = self.numbers_[index]
      anim.WhiteBalanceImg:SetImage(hitNumberImgAddr_ .. value.char)
      anim.anim:PlayOnce("anim_fx_hit_number_change")
      anim:SetVisible(true)
    end
  else
    local minIndex = 10
    for index, value in ipairs(numberChars) do
      if value.char ~= self.lastNumberChars_[index].char and index < minIndex then
        minIndex = index
      end
    end
    for i = minIndex, #numberChars do
      local anim = self.numbers_[i]
      anim.WhiteBalanceImg:SetImage(hitNumberImgAddr_ .. numberChars[i].char)
      anim.anim:PlayOnce("anim_fx_hit_number_change")
      anim:SetVisible(true)
    end
  end
  self.lastNumberChars_ = numberChars
end

return Battle_hitView
