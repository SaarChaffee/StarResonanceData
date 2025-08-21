local super = require("ui.component.loop_list_view_item")
local ShopTog3LoopItem = class("ShopTog3LoopItem", super)

function ShopTog3LoopItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  local showDefault = true
  if data.shopItem then
    local row = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(data.shopItem.itemId)
    if row then
      local itemsVm = Z.VMMgr.GetVM("items")
      self.uiBinder.img_icon:SetImage(itemsVm.GetItemIcon(row.ItemId))
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_default, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, true)
      showDefault = false
    end
  end
  if showDefault then
    self.uiBinder.img_default:SetImage(data.mallPagetabTableRow.PagetabIcon)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_default, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, false)
  end
end

function ShopTog3LoopItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  if isSelected then
    self.parent.UIView:Tog3Click(self.data_, self.Index, isClick)
  end
end

return ShopTog3LoopItem
