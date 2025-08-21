local super = require("ui.component.loop_list_view_item")
local FriendGroupNameItemPC = class("FriendGroupNameItemPC", super)

function FriendGroupNameItemPC:OnInit()
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
end

function FriendGroupNameItemPC:OnRefresh(data)
  if data.IsDefault then
    self.uiBinder.lab_group.text = Lang("FriendGroupDefaultName")
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, false)
    self.uiBinder.Trans:SetHeight(32)
  else
    self.uiBinder.lab_group.text = Lang("FriendGroupClassName")
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, true)
    self.uiBinder.Trans:SetHeight(40)
  end
end

return FriendGroupNameItemPC
