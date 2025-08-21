local super = require("ui.component.loop_list_view_item")
local CollectionMembershipItem = class("CollectionMembershipItem", super)

function CollectionMembershipItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_weapon_icon_off:SetImage(data.row.Icon)
  self.uiBinder.img_weapon_icon_on:SetImage(data.row.Icon)
  self.uiBinder.lab_vocational_name.text = data.row.Name
  self:refreshItemSize()
  self:refreshSelectState()
end

function CollectionMembershipItem:OnSelected(isSelected, isClick)
  self:refreshItemSize()
  self:refreshSelectState()
  if isSelected and isClick then
    self.parent.UIView:onStartAnimSelected()
    self.parent.UIView:OnSelectItem(self.data_)
  end
end

function CollectionMembershipItem:refreshItemSize()
  if self.IsSelected then
    self.uiBinder.Trans:SetWidth(300)
  else
    self.uiBinder.Trans:SetWidth(196)
  end
  self.loopListView:OnItemSizeChanged(self.Index)
end

function CollectionMembershipItem:refreshSelectState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not self.IsSelected)
end

return CollectionMembershipItem
