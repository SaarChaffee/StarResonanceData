local super = require("ui.component.loopscrollrectitem")
local FriendSelectItem = class("FriendSelectItem", super)

function FriendSelectItem:ctor()
end

function FriendSelectItem:OnInit()
end

function FriendSelectItem:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  self.uiBinder.lab_group_name.text = self.data_.GroupName
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_check, false)
end

function FriendSelectItem:Selected(isSelected)
  if true == isSelected then
    self.parent.uiView:ChangeGroup(self.data_.GroupId)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_check, isSelected)
end

function FriendSelectItem:OnUnInit()
end

function FriendSelectItem:OnReset()
end

return FriendSelectItem
