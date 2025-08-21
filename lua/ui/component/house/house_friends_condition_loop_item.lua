local super = require("ui.component.loop_list_view_item")
local HouseFriendsLoopItem = class("HouseFriendsLoopItem", super)

function HouseFriendsLoopItem:OnInit()
end

function HouseFriendsLoopItem:OnRefresh(data)
  if data.isSatisfy then
    self.uiBinder.lab_title.text = Lang("ConditionSatisfy")
  else
    self.uiBinder.lab_title.text = Lang("ConditionDissatisfy")
  end
end

function HouseFriendsLoopItem:OnUnInit()
end

return HouseFriendsLoopItem
