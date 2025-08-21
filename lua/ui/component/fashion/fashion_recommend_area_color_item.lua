local super = require("ui.component.loop_grid_view_item")
local FashionRecommendAreaColorItem = class("FashionRecommendAreaColorItem", super)

function FashionRecommendAreaColorItem:OnInit()
end

function FashionRecommendAreaColorItem:OnRefresh(data)
  self.data_ = data
  if table.zcount(data) == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_none, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_color, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_none, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_color, true)
    local color = Color.HSVToRGB(data[1] / 360, data[2] * 0.01, data[3] * 0.01)
    self.uiBinder.img_color:SetColor(color)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, true)
  end
  self.uiBinder.tog_frame.isOn = self.IsSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, false)
end

function FashionRecommendAreaColorItem:OnSelected(isSelected, isClick)
  self.uiBinder.tog_frame.isOn = self.IsSelected
  if isSelected and isClick then
    self.parent.UIView:OnSelectAreaColor(self.data_)
  end
end

return FashionRecommendAreaColorItem
