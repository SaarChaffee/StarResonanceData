local super = require("ui.component.loop_list_view_item")
local FriendTagItemPC = class("FriendTagItemPC", super)

function FriendTagItemPC:OnInit()
end

function FriendTagItemPC:OnRefresh(data)
  self.uiBinder.img_icon:SetImage(data.ShowTagRoute)
end

return FriendTagItemPC
