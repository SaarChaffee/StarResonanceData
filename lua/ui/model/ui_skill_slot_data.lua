local super = require("ui.model.data_base")
local SkillSlotData = class("SkillSlotData", super)

function SkillSlotData:ctor()
  super.ctor(self)
  self.SlotList = {}
end

function SkillSlotData:InitSlotList(data)
  for k, v in pairs(data) do
    self.SlotList[k] = v
  end
end

function SkillSlotData:GetSlotData(slotTag)
  return self.SlotList[tostring(slotTag)]
end

return SkillSlotData
