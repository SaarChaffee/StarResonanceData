local super = require("life_profession.life_skill_base")
local LifeCookSkill = class("LifeCookSkill", super)

function LifeCookSkill:ctor()
  super.ctor(self)
end

function LifeCookSkill.GetRewardList()
end

function LifeCookSkill.GetProductInfoList(proID, showConsume)
  local lifeMenufactureData = Z.DataMgr.Get("life_menufacture_data")
  local productionInfoTable = lifeMenufactureData:GetProductionDatas()
  local productionInfoRsltTable = {}
  for k, v in pairs(productionInfoTable) do
    local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(v.productId)
    if not lifeProductionListTableRow.Hide and lifeProductionListTableRow.LifeProId == proID and LifeCookSkill.FitFilterCondition(proID, v) then
      if showConsume == nil then
        table.insert(productionInfoRsltTable, v)
      elseif showConsume == true then
        if LifeCookSkill.IsProductHasCost(v.productId) then
          table.insert(productionInfoRsltTable, v)
        end
      elseif not LifeCookSkill.IsProductHasCost(v.productId) then
        table.insert(productionInfoRsltTable, v)
      end
    end
  end
  LifeCookSkill.SortProductList(productionInfoRsltTable, LifeCookSkill)
  return productionInfoRsltTable
end

function LifeCookSkill.IsProductUnlocked(productID, isConsume)
  local lifeProfessionVm = Z.VMMgr.GetVM("life_profession")
  return lifeProfessionVm.CheckProductionIsUnlock(productID)
end

function LifeCookSkill.GetBuffDatas(productID)
  local cookVm = Z.VMMgr.GetVM("cook")
  local row = Z.TableMgr.GetRow("LifeProductionListTableMgr", productID)
  if row then
    local buffDes = cookVm.GetBuffDesById(row.RelatedItemId)
    if buffDes ~= "" then
      return {buffDes}
    end
  end
end

return LifeCookSkill
