local super = require("ui.model.data_base")
local SeasonData = class("SeasonData", super)

function SeasonData:ctor()
  super.ctor(self)
end

function SeasonData:Init()
  self:Clear()
  self.CancelSource = Z.CancelSource.Rent()
  self.seasonSubPageId_ = 1
  self.SeasonActFuncId = 0
  local SeasonCenterTableMgr = Z.TableMgr.GetTable("SeasonCenterTableMgr")
  local seasonCenterDatas = SeasonCenterTableMgr.GetDatas()
  self.pageIndexAndFuncIdMap_ = {}
  for id, value in pairs(seasonCenterDatas) do
    self.pageIndexAndFuncIdMap_[value.Sort] = id
  end
  self:InitCfgData()
end

function SeasonData:InitCfgData()
  self.SeasonGlobalTableDatas = Z.TableMgr.GetTable("SeasonGlobalTableMgr").GetDatas()
  self.SeasonDailyTableDatas = Z.TableMgr.GetTable("SeasonDailyTableMgr").GetDatas()
  self.SeasonActTableDatas = Z.TableMgr.GetTable("SeasonActTableMgr").GetDatas()
end

function SeasonData:OnLanguageChange()
  self:InitCfgData()
end

function SeasonData:Clear()
  self.CurSeasonId = 0
  self.MaxEquipLevel = 0
end

function SeasonData:UnInit()
  self.CancelSource:Recycle()
end

function SeasonData:SetSubPageId(id)
  self.seasonSubPageId_ = id
end

function SeasonData:GetSubPageId()
  return self.seasonSubPageId_ or 1
end

function SeasonData:SetSeasonActFuncId(id)
  self.SeasonActFuncId = id
end

function SeasonData:GetSeasonActFuncId()
  return self.SeasonActFuncId or 0
end

function SeasonData:SetCurShowPage(id)
  self.curShowPageId = id
end

function SeasonData:GetCurShowPage()
  return self.curShowPageId or 1
end

function SeasonData:GetAllPages()
  return self.pageIndexAndFuncIdMap_
end

function SeasonData:GetPageByIndex(index)
  local funcId = self.pageIndexAndFuncIdMap_[index]
  local seasonCenterTableMgr = Z.TableMgr.GetTable("SeasonCenterTableMgr")
  local cfg = seasonCenterTableMgr.GetRow(funcId)
  return cfg
end

function SeasonData:GetPageCodeByFunctionId(id)
  local seasonCenterTableMgr = Z.TableMgr.GetTable("SeasonCenterTableMgr")
  local cfg = seasonCenterTableMgr.GetRow(id)
  if cfg then
    return cfg.ViewPath
  end
end

function SeasonData:GetPageSortByFuncId(funcId)
  if funcId == nil then
    return 1
  end
  local seasonCenterTableMgr = Z.TableMgr.GetTable("SeasonCenterTableMgr")
  local cfg = seasonCenterTableMgr.GetRow(funcId)
  if cfg == nil then
    return 1
  end
  return cfg.Sort
end

return SeasonData
