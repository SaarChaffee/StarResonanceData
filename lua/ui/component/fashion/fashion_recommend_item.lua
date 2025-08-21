local super = require("ui.component.loop_grid_view_item")
local FashionRecommendItem = class("FashionRecommendItem", super)

function FashionRecommendItem:OnInit()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_none, false)
end

function FashionRecommendItem:OnRefresh(data)
  if not data then
    return
  end
  local fashionColorTableRow = Z.TableMgr.GetTable("FashionColorTableMgr").GetRow(data)
  if not fashionColorTableRow then
    return
  end
  local showColor = fashionColorTableRow.Color[1]
  local color = Color.HSVToRGB(showColor[2] / 360, showColor[3] / 100, showColor[4] / 100)
  self.uiBinder.img_color:SetColor(color)
  self.colorInfo_ = fashionColorTableRow.Color
  self.uiBinder.tog_frame.isOn = self.IsSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, fashionColorTableRow.Price == 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, fashionColorTableRow.Price == 2)
end

function FashionRecommendItem:OnSelected(isSelected)
  self.uiBinder.tog_frame.isOn = isSelected
end

function FashionRecommendItem:OnPointerClick(go, eventData)
  self.parent.UIView:SetFashionColor(self.colorInfo_)
end

return FashionRecommendItem
