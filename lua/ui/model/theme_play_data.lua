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

function ThemePlayData:SetSignAwardData(signType, day, state)
  if self.signAwardGetDict_[signType] == nil then
    self.signAwardGetDict_[signType] = {}
  end
  self.signAwardGetDict_[signType][day] = state
end

function ThemePlayData:GetSignAwardData(signType, day)
  if self.signAwardGetDict_[signType] == nil then
    return E.DrawState.NoDraw
  end
  return self.signAwardGetDict_[signType][day]
end

function ThemePlayData:GetSignDataDict()
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
  return self.signActivityDict_
end

function ThemePlayData:GetSignDataByType(signType)
  local signDataDict = self:GetSignDataDict()
  return signDataDict[signType] or {}
end

function ThemePlayData:GetAllSignFuncId()
  local signDataDict = self:GetSignDataDict()
  local funcIdDict = {}
  for type, signDayMap in pairs(signDataDict) do
    for day, signData in pairs(signDayMap) do
      if signData.FuncId ~= 0 then
        funcIdDict[type] = signData.FuncId
        break
      end
    end
  end
  return funcIdDict
end

return ThemePlayData
