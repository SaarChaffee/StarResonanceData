local super = require("ui.model.data_base")
local UseItemPopupData = class("UseItemPopupData", super)

function UseItemPopupData:ctor()
  super.ctor(self)
end

function UseItemPopupData:Init()
  self.MaxUseCount = 0
  self.UsrCount = 0
end

function UseItemPopupData:AddUseCount(count)
  self.UsrCount = self.UsrCount + count
  self:restrictUseCount()
end

function UseItemPopupData:GetUseCount()
  return self.UsrCount
end

function UseItemPopupData:GetMaxUseCount(count)
  return self.MaxUseCount
end

function UseItemPopupData:SetUseCount(count)
  self.UsrCount = count
  self:restrictUseCount()
end

function UseItemPopupData:SetMaxUseCount(count)
  self.MaxUseCount = count
  self.UsrCount = 0
end

function UseItemPopupData:restrictUseCount()
  if self.UsrCount > self.MaxUseCount then
    self.UsrCount = self.MaxUseCount
  end
  if self.UsrCount < 1 then
    self.UsrCount = 1
  end
end

function UseItemPopupData:UnInit()
end

return UseItemPopupData
