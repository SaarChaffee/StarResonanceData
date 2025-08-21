local super = require("ui.model.data_base")
local RecommendFightValueData = class("RecommendFightValueData", super)

function RecommendFightValueData:ctor()
  super.ctor(self)
  self.FunctionIdToServerFightPointType = {
    [E.RecommendFightValueType.Level] = E.FightPointFunctionType.FightPointFunctionType_RoleBasic,
    [E.RecommendFightValueType.Season] = E.FightPointFunctionType.FightPointFunctionType_Medal,
    [E.RecommendFightValueType.Equip] = E.FightPointFunctionType.FightPointFunctionType_Equip,
    [E.RecommendFightValueType.Mod] = E.FightPointFunctionType.FightPointFunctionType_Mod,
    [E.RecommendFightValueType.Talent] = E.FightPointFunctionType.FightPointFunctionType_Talent,
    [E.RecommendFightValueType.Skill] = E.FightPointFunctionType.FightPointFunctionType_Skill
  }
  self.Type2JumpId = {
    [E.RecommendFightValueType.Level] = E.RecommendFightValueType.Level,
    [E.RecommendFightValueType.Season] = E.RecommendFightValueType.Season,
    [E.RecommendFightValueType.Equip] = E.EquipFuncId.Equip,
    [E.RecommendFightValueType.Mod] = E.RecommendFightValueType.Mod,
    [E.RecommendFightValueType.Talent] = E.RecommendFightValueType.Talent,
    [E.RecommendFightValueType.Skill] = E.RecommendFightValueType.Skill
  }
end

function RecommendFightValueData:Init()
  self.assessModuleRows_ = nil
end

function RecommendFightValueData:UnInit()
  self.assessModuleRows_ = nil
end

function RecommendFightValueData:Clear()
end

function RecommendFightValueData:SetRFByType(type, value)
end

function RecommendFightValueData:GetAssessModuleRows()
  if not self.assessModuleRows_ then
    local datas = Z.TableMgr.GetTable("AssessModuleTableMgr").GetDatas()
    self.assessModuleRows_ = {}
    for _, v in pairs(datas) do
      table.insert(self.assessModuleRows_, v)
    end
    table.sort(self.assessModuleRows_, function(cfg1, cfg2)
      return cfg1.SortId < cfg2.SortId
    end)
  end
  return self.assessModuleRows_
end

function RecommendFightValueData:GetJumpIdByType(type)
  return self.Type2JumpId[type]
end

function RecommendFightValueData:OnLanguageChange()
  self.assessModuleRows_ = nil
end

return RecommendFightValueData
