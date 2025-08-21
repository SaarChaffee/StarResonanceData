local super = require("ui.model.data_base")
local LifeCookData = class("LifeCookData", super)

function LifeCookData:ctor()
end

function LifeCookData:Init()
  self.LifeCookProduction = {}
  self:InitCfgData()
end

function LifeCookData:InitCfgData()
  local LifeProductionListTableDatas = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetDatas()
  local index = 1
  for _, value in pairs(LifeProductionListTableDatas) do
    if value.LifeProId == E.ELifeProfession.Cook then
      self.LifeCookProduction[index] = value
      index = index + 1
    end
  end
  table.sort(self.LifeCookProduction, function(left, right)
    return left.Sort < right.Sort
  end)
end

function LifeCookData:OnLanguageChange()
  self:InitCfgData()
end

function LifeCookData:Clear()
end

function LifeCookData:UnInit()
end

return LifeCookData
