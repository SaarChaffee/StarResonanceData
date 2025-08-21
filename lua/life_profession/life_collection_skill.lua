local super = require("life_profession.life_skill_base")
local LifeCollectionSkill = class("LifeCollectionSkill", super)

function LifeCollectionSkill:ctor()
  super.ctor(self)
end

function LifeCollectionSkill.GetProductInfoList(proID, showConsume)
  local lifeCollectionData = Z.DataMgr.Get("life_collection_data")
  local collectionDatas = lifeCollectionData:GetCollectionDatas()
  local collectInfoTable = {}
  for k, v in pairs(collectionDatas) do
    if not v.Hide and v.LifeProId == proID and LifeCollectionSkill.FitFilterCondition(proID, v, showConsume) then
      if showConsume == nil then
        table.insert(collectInfoTable, v)
      elseif showConsume == true then
        if v.Award > 0 then
          table.insert(collectInfoTable, v)
        end
      elseif 0 < v.FreeAward then
        table.insert(collectInfoTable, v)
      end
    end
  end
  LifeCollectionSkill.SortProductList(collectInfoTable, LifeCollectionSkill, showConsume)
  local productData = {}
  for k, v in pairs(collectInfoTable) do
    local menufactureProductData = {}
    menufactureProductData.lifeType = E.ELifeProfessionMainType.Collection
    menufactureProductData.productId = v.Id
    table.insert(productData, menufactureProductData)
  end
  return productData
end

function LifeCollectionSkill.FitFilterCondition(proID, lifeCollectListTableRow, showConsume)
  local lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  local filterSceneDatas = lifeProfessionData_:GetFilterSceneDatas(proID)
  local filterMinLevel, filterMaxLevel = lifeProfessionData_:GetFilterLevel(proID)
  local sceneFit = LifeCollectionSkill.checkIsFilterScene(lifeCollectListTableRow.Scene, filterSceneDatas)
  local needLevel = showConsume and lifeCollectListTableRow.NeedLevel[1] or lifeCollectListTableRow.NeedLevel[2]
  local levelFit = LifeCollectionSkill.checkIsFilterLevel(needLevel, filterMinLevel, filterMaxLevel)
  local nameFit = false
  local filterName = lifeProfessionData_:GetFilterName(lifeCollectListTableRow.LifeProId)
  if filterName == nil or filterName == "" then
    nameFit = true
  elseif string.match(lifeCollectListTableRow.Name, filterName) then
    nameFit = true
  end
  local consumeFit = false
  local filterConsume, filterNoConsume = lifeProfessionData_:GetFilterConsume(lifeCollectListTableRow.LifeProId)
  if filterConsume and lifeCollectListTableRow.Award > 0 or filterNoConsume and 0 < lifeCollectListTableRow.FreeAward then
    consumeFit = true
  end
  local conditionFit = false
  local levelCondition, speCondition, otherCondition = lifeProfessionData_:GetFilterConditionDatas(lifeCollectListTableRow.LifeProId)
  local unlockConditions = lifeCollectListTableRow.Award > 0 and lifeCollectListTableRow.UnlockCondition or lifeCollectListTableRow.UnlockConditionZeroCost
  if table.zcount(unlockConditions) == 0 then
    conditionFit = otherCondition
  end
  for k, v in pairs(unlockConditions) do
    if v[1] == E.ConditionType.LifeProfessionLevel and levelCondition or v[1] == E.ConditionType.LifeProfessionSpecializationLevel and speCondition then
      conditionFit = true
    elseif otherCondition then
      conditionFit = true
    end
  end
  return nameFit and levelFit and consumeFit and sceneFit and conditionFit
end

function LifeCollectionSkill.SortProductList(productionDatas, lifeSkill, showConsume)
  local unlockDatas = {}
  for k, v in pairs(productionDatas) do
    if lifeSkill.IsProductUnlocked(v.Id, showConsume) then
      unlockDatas[v.Id] = true
    end
  end
  table.sort(productionDatas, function(a, b)
    local aState = unlockDatas[a.Id] and 0 or 1
    local bState = unlockDatas[b.Id] and 0 or 1
    if aState == bState then
      return a.Sort < b.Sort
    else
      return aState < bState
    end
  end)
end

function LifeCollectionSkill.IsProductUnlocked(productID, isConsume)
  local lifeCollectionData = Z.DataMgr.Get("life_collection_data")
  local collectionDatas = lifeCollectionData:GetCollectionDatas()
  for k, v in pairs(collectionDatas) do
    if v.Id == productID and isConsume then
      return Z.ConditionHelper.CheckCondition(v.UnlockCondition)
    end
    if v.Id == productID and not isConsume then
      return Z.ConditionHelper.CheckCondition(v.UnlockConditionZeroCost)
    end
  end
  return false
end

function LifeCollectionSkill.GetAllProductInfoList(proID)
  local lifeCollectionData = Z.DataMgr.Get("life_collection_data")
  local collectionDatas = lifeCollectionData:GetCollectionDatas()
  local collectInfoTable = {}
  for k, v in pairs(collectionDatas) do
    if v.LifeProId == proID then
      table.insert(collectInfoTable, v)
    end
  end
  return collectInfoTable
end

function LifeCollectionSkill.checkIsFilterScene(scene, filterSceneDatas)
  for k, v in pairs(filterSceneDatas) do
    if scene == v.sceneID then
      return v.isOn
    end
  end
  return false
end

function LifeCollectionSkill.checkIsFilterLevel(needLevel, filterMinLevel, filterMaxLevel)
  return filterMinLevel <= needLevel and needLevel <= filterMaxLevel
end

function LifeCollectionSkill.NoticeRecipeUnlock(proID, productID)
  local lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  local collectionRow = Z.TableMgr.GetRow("LifeCollectListTableMgr", productID)
  local viewData = {
    recipeName = collectionRow.Name
  }
  lifeProfessionVM.NoticeRecipeUnlock(viewData)
end

function LifeCollectionSkill.IsProductHasCost(productID)
  local collectionRow = Z.TableMgr.GetRow("LifeCollectListTableMgr", productID)
  return collectionRow.Award > 0
end

return LifeCollectionSkill
