local super = require("ui.component.loop_list_view_item")
local FriendGroupChangeItemPC = class("FriendGroupChangeItemPC", super)

function FriendGroupChangeItemPC:OnRefresh(data)
  self.groupId_ = data.groupId
  if data.groupId == -1 then
    self.uiBinder.lab_group.text = Lang("CreateNewGroup")
  else
    self.uiBinder.lab_group.text = data.groupName
  end
end

function FriendGroupChangeItemPC:OnPointerClick(go, eventData)
  self.parent.UIView:OnSelectGroup(self.groupId_)
end

return FriendGroupChangeItemPC
