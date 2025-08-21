local super = require("ui.component.loop_list_view_item")
local unionDeviceBattleDungeonMemberRecordItem = class("unionDeviceBattleDungeonMemberRecordItem", super)

function unionDeviceBattleDungeonMemberRecordItem:ctor()
end

function unionDeviceBattleDungeonMemberRecordItem:OnInit()
end

function unionDeviceBattleDungeonMemberRecordItem:OnRefresh(data)
  self.uiBinder.lab_name.text = data.CharName
  self.uiBinder.lab_date.text = Z.TimeFormatTools.TicksFormatTime(data.killTime * 1000, E.TimeFormatType.YMD)
  self.uiBinder.lab_time.text = Z.TimeFormatTools.TicksFormatTime(data.killTime * 1000, E.TimeFormatType.HMS)
end

function unionDeviceBattleDungeonMemberRecordItem:OnUnInit()
end

function unionDeviceBattleDungeonMemberRecordItem:OnSelected(isSelected)
end

function unionDeviceBattleDungeonMemberRecordItem:OnPointerClick()
end

return unionDeviceBattleDungeonMemberRecordItem
