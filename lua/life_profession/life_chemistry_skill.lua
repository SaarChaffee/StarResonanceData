local super = require("life_profession.life_skill_base")
local LifeChemistrySkill = class("LifeChemistrySkill", super)

function LifeChemistrySkill:ctor()
  super.ctor(self)
end

function LifeChemistrySkill.GetProductInfoList(proID, showConsume)
  local lifeMenufactureData = Z.DataMgr.Get("life_menufacture_data")
  local productionDatas = lifeMenufactureData:GetProductionDatas()
  local productionInfoTable = {}
  local productionInfoTableIndex = 0
  for k, v in pairs(productionDatas) do
    local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(v.productId)
    if not lifeProductionListTableRow.Hide and lifeProductionListTableRow.LifeProId == proID and LifeChemistrySkill.FitFilterCondition(proID, v) then
      if showConsume == nil then
        productionInfoTableIndex = productionInfoTableIndex + 1
        productionInfoTable[productionInfoTableIndex] = v
      elseif showConsume == true then
        if LifeChemistrySkill.IsProductHasCost(v.productId) then
          productionInfoTableIndex = productionInfoTableIndex + 1
          productionInfoTable[productionInfoTableIndex] = v
        end
      elseif not LifeChemistrySkill.IsProductHasCost(v.productId) then
        productionInfoTableIndex = productionInfoTableIndex + 1
        productionInfoTable[productionInfoTableIndex] = v
      end
    end
  end
  LifeChemistrySkill.SortProductList(productionInfoTable, LifeChemistrySkill)
  return productionInfoTable
end

function LifeChemistrySkill.IsProductUnlocked(productID, isConsume)
  local lifeProfessionVm = Z.VMMgr.GetVM("life_profession")
  return lifeProfessionVm.CheckProductionIsUnlock(productID)
end

return LifeChemistrySkill
