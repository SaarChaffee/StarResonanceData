local super = require("ui.component.loop_list_view_item")
local HouseLevelDescLoopItem = class("HouseLevelDescLoopItem", super)

function HouseLevelDescLoopItem:OnInit()
end

function HouseLevelDescLoopItem:OnRefresh(data)
  self.data = data
  self.uiBinder.lab_info.text = data.desc
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_finished, data.isUnlocked)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lcok, not data.isUnlocked)
end

function HouseLevelDescLoopItem:OnUnInit()
end

return HouseLevelDescLoopItem
