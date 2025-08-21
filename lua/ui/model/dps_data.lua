local super = require("ui.model.data_base")
local DpsData = class("DpsData", super)

function DpsData:ctor()
  super.ctor(self)
  self:Clear()
end

function DpsData:Init()
  self.RecountTableMap = {}
end

function DpsData:InitCfgData()
  local table = Z.TableMgr.GetTable("RecountTableMgr").GetDatas()
  for key, value in pairs(table) do
    for index, dmgId in ipairs(value.DamageId) do
      self.RecountTableMap[dmgId] = value.Id
    end
  end
end

function DpsData:OnLanguageChange()
end

function DpsData:Clear()
end

return DpsData
