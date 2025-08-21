local super = require("life_profession.life_skill_base")
local LifeCastSkill = class("LifeCollectionSkill", super)

function LifeCastSkill:ctor()
  super.ctor(self)
end

function LifeCastSkill.GetProductInfoList(proID, showConsume)
  local lifeMenufactureData = Z.DataMgr.Get("life_menufacture_data")
  local productionDatas = lifeMenufactureData:GetProductionDatas()
  local productionInfoTable = {}
  for k, v in pairs(productionDatas) do
    local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(v.productId)
    if not lifeProductionListTableRow.Hide and lifeProductionListTableRow.LifeProId == proID and LifeCastSkill.FitFilterCondition(proID, v) then
      if showConsume == nil then
        table.insert(productionInfoTable, v)
      elseif showConsume == true then
        if LifeCastSkill.IsProductHasCost(v.productId) then
          table.insert(productionInfoTable, v)
        end
      elseif not LifeCastSkill.IsProductHasCost(v.productId) then
        table.insert(productionInfoTable, v)
      end
    end
  end
  LifeCastSkill.SortProductList(productionInfoTable, LifeCastSkill)
  return productionInfoTable
end

function LifeCastSkill.IsProductUnlocked(productID, isConsume)
  local lifeProfessionVm = Z.VMMgr.GetVM("life_profession")
  return lifeProfessionVm.CheckProductionIsUnlock(productID)
end

return LifeCastSkill
