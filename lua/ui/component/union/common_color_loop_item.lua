local super = require("ui.component.loopscrollrectitem")
local CommonColorLoopItem = class("CommonColorLoopItem", super)

function CommonColorLoopItem:ctor()
end

function CommonColorLoopItem:OnInit()
end

function CommonColorLoopItem:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  self:setUI()
end

function CommonColorLoopItem:setUI()
  local color = Color.HSVToRGB(self.data_.color[2], self.data_.color[3], self.data_.color[4])
  self.uiBinder.img_color_block:SetColor(color)
end

function CommonColorLoopItem:Selected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  if isSelected and self.data_.selectedFunc then
    self.data_.selectedFunc(self.index_)
  end
end

function CommonColorLoopItem:OnReset()
end

function CommonColorLoopItem:OnUnInit()
end

return CommonColorLoopItem
