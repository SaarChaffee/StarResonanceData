local super = require("ui.component.loop_list_view_item")
local FriendSelectItem = class("FriendSelectItem", super)

function FriendSelectItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_group_name.text = self.data_.GroupName
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_check, self.IsSelected)
end

function FriendSelectItem:OnSelected(isSelected, isClick)
  if true == isSelected then
    self.parent.UIView:ChangeGroup(self.data_.GroupId)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_check, isSelected)
end

return FriendSelectItem
