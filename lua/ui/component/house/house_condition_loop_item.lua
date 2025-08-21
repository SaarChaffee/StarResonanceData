local super = require("ui.component.loop_list_view_item")
local HouseConditionLoopItem = class("HouseConditionLoopItem", super)

function HouseConditionLoopItem:OnInit()
end

function HouseConditionLoopItem:OnRefresh(data)
  local isFinish = data.IsUnlock
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_finished, isFinish)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_unfinished, not isFinish)
  self.uiBinder.lab_conditions.text = data.showPurview or data.Desc
end

function HouseConditionLoopItem:OnUnInit()
end

return HouseConditionLoopItem
