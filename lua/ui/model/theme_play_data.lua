local super = require("ui.model.data_base")
local ThemePlayData = class("ThemePlayData", super)

function ThemePlayData:ctor()
end

function ThemePlayData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.signAwardGetDict_ = {}
end

function ThemePlayData:Clear()
  self.signAwardGetDict_ = {}
end

function ThemePlayData:UnInit()
  self.CancelSource:Recycle()
  self.signAwardGetDict_ = nil
end

function ThemePlayData:ResetSignAwardData()
  self.signAwardGetDict_ = {}
end

function ThemePlayData:SetSignAwardData(day, state)
  self.signAwardGetDict_[day] = state
end

function ThemePlayData:GetSignAwardData(day)
  return self.signAwardGetDict_[day]
end

function ThemePlayData:GetSignDataByType(signType)
  if self.signActivityDict_ == nil then
    self.signActivityDict_ = {}
    local configDict = Z.TableMgr.GetTable("ActivitySigninMgr").GetDatas()
    for id, config in pairs(configDict) do
      if self.signActivityDict_[config.Type] == nil then
        self.signActivityDict_[config.Type] = {}
      end
      self.signActivityDict_[config.Type][config.OpenDay] = config
    end
  end
  return self.signActivityDict_[signType] or {}
end

return ThemePlayData
