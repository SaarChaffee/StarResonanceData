local LifeSkillBase = class("LifeSkillBase")

function LifeSkillBase:ctor()
end

function LifeSkillBase.GetProductInfoList(proID, showConsume)
end

function LifeSkillBase.IsProductUnlocked(productID, isConsume)
end

function LifeSkillBase.IsProductHasCost(productID)
  local lifeMenufactureData = Z.DataMgr.Get("life_menufacture_data")
  local curSelectProduct = lifeMenufactureData:GetCurSelectProductID(productID)
  local productionRow = Z.TableMgr.GetRow("LifeProductionListTableMgr", curSelectProduct)
  return productionRow.Cost[2] ~= nil and productionRow.Cost[2] > 0
end

function LifeSkillBase.GetBuffDatas(productID)
  return nil
end

function LifeSkillBase.SortProductList(productionDatas, lifeSkill)
  local unlockDatas = {}
  for k, v in pairs(productionDatas) do
    if lifeSkill.IsProductUnlocked(v.productId) then
      unlockDatas[v.productId] = true
    end
  end
  table.sort(productionDatas, function(a, b)
    local aState = unlockDatas[a.productId] and 0 or 1
    local bState = unlockDatas[b.productId] and 0 or 1
    local aLifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(a.productId)
    local bLifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(b.productId)
    if aState ~= bState then
      return aState < bState
    end
    if aLifeProductionListTableRow.Type ~= bLifeProductionListTableRow.Type then
      return aLifeProductionListTableRow.Type < bLifeProductionListTableRow.Type
    end
    return aLifeProductionListTableRow.Sort < bLifeProductionListTableRow.Sort
  end)
end

function LifeSkillBase.GetAllProductInfoList(proID)
  local lifeMenufactureData = Z.DataMgr.Get("life_menufacture_data")
  local productionDatas = lifeMenufactureData:GetProductionDatas()
  local productionInfoTable = {}
  for k, v in pairs(productionDatas) do
    if v.LifeProId == proID then
      table.insert(productionInfoTable, v)
    end
  end
  return productionInfoTable
end

function LifeSkillBase.NoticeRecipeUnlock(proID, productID)
  local lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  local productionRow = Z.TableMgr.GetRow("LifeProductionListTableMgr", productID)
  local viewData = {
    recipeName = productionRow.Name
  }
  lifeProfessionVM.NoticeRecipeUnlock(viewData)
end

function LifeSkillBase.FitFilterCondition(proID, menufactureProductData)
  if #menufactureProductData.subProductList > 0 then
    for _, subProduct in pairs(menufactureProductData.subProductList) do
      local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(subProduct)
      if LifeSkillBase.RowDataFitFilter(lifeProductionListTableRow) then
        return true
      end
    end
  else
    local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(menufactureProductData.productId)
    return LifeSkillBase.RowDataFitFilter(lifeProductionListTableRow)
  end
  return false
end

function LifeSkillBase.RowDataFitFilter(lifeProductionListTableRow)
  local lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  local filterMinLevel, filterMaxLevel = lifeProfessionData_:GetFilterLevel(lifeProductionListTableRow.LifeProId)
  local filterName = lifeProfessionData_:GetFilterName(lifeProductionListTableRow.LifeProId)
  local levelFit = false
  if lifeProductionListTableRow.NeedLevel == 0 or filterMinLevel <= lifeProductionListTableRow.NeedLevel and filterMaxLevel >= lifeProductionListTableRow.NeedLevel then
    levelFit = true
  end
  local nameFit = false
  if filterName == nil or filterName == "" then
    nameFit = true
  elseif string.match(lifeProductionListTableRow.Name, filterName) then
    nameFit = true
  end
  local consumeFit = false
  local filterConsume, filterNoConsume = lifeProfessionData_:GetFilterConsume(lifeProductionListTableRow.LifeProId)
  local hasCost = lifeProductionListTableRow.Cost[2] ~= nil and 0 < lifeProductionListTableRow.Cost[2]
  if filterConsume and hasCost or filterNoConsume and not hasCost then
    consumeFit = true
  end
  local typeFit = false
  local filterTypeDatas = lifeProfessionData_:GetFilterTypeDatas(lifeProductionListTableRow.LifeProId)
  if lifeProductionListTableRow.Type == 0 then
    typeFit = true
  end
  for k, v in pairs(filterTypeDatas) do
    if lifeProductionListTableRow.Type == v.type then
      typeFit = v.isOn
    end
  end
  local conditionFit = false
  local levelCondition, speCondition, otherCondition = lifeProfessionData_:GetFilterConditionDatas(lifeProductionListTableRow.LifeProId)
  if table.zcount(lifeProductionListTableRow.UnlockCondition) == 0 then
    conditionFit = otherCondition
  end
  for k, v in pairs(lifeProductionListTableRow.UnlockCondition) do
    if v[1] == E.ConditionType.LifeProfessionLevel and levelCondition or v[1] == E.ConditionType.LifeProfessionSpecializationLevel and speCondition then
      conditionFit = true
    elseif otherCondition then
      conditionFit = true
    end
  end
  return nameFit and levelFit and consumeFit and typeFit and conditionFit
end

return LifeSkillBase
