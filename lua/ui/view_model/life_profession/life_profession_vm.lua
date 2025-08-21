local LifeProfessionVM = {}
local LifeSkillTable = {
  [E.ELifeProfession.Collection] = require("life_profession.life_collection_skill").new(),
  [E.ELifeProfession.Chemistry] = require("life_profession.life_chemistry_skill").new(),
  [E.ELifeProfession.Cast] = require("life_profession.life_cast_skill").new(),
  [E.ELifeProfession.Cook] = require("life_profession.life_cook_skill").new()
}
local Type2LifeSkillTable = {
  [E.ELifeProfessionMainType.Collection] = require("life_profession.life_collection_skill").new(),
  [E.ELifeProfessionMainType.Manufacture] = require("life_profession.life_cast_skill").new()
}
local LifeProductionUnlockType = {And = 1, Or = 2}

function LifeProfessionVM.GetAllSortedProfessions()
  local lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  local professions = lifeProfessionData_:GetProfessionDatas()
  local rst = {}
  for k, v in pairs(professions) do
    table.insert(rst, v)
  end
  table.sort(rst, function(a, b)
    local aLevel = LifeProfessionVM.GetLifeProfessionLv(a.ProId)
    local bLevel = LifeProfessionVM.GetLifeProfessionLv(b.ProId)
    if aLevel ~= bLevel then
      return aLevel > bLevel
    end
    local aUnlocked = LifeProfessionVM.IsLifeProfessionUnlocked(a.ProId) and 1 or 0
    local bUnlocked = LifeProfessionVM.IsLifeProfessionUnlocked(b.ProId) and 1 or 0
    if aUnlocked ~= bUnlocked then
      return aUnlocked > bUnlocked
    end
    return a.sort < b.sort
  end)
  return rst
end

function LifeProfessionVM.GetAllProfessions()
  local lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  local professions = lifeProfessionData_:GetProfessionDatas()
  local rst = {}
  for k, v in pairs(professions) do
    table.insert(rst, v)
  end
  table.sort(rst, function(a, b)
    return a.sort < b.sort
  end)
  return rst
end

function LifeProfessionVM.GetLifeProfessionSkill(proID)
  local curSkill = LifeSkillTable[proID]
  if curSkill ~= nil then
    return curSkill
  end
  local lifeProfessionRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(proID)
  if lifeProfessionRow == nil then
    return false
  end
  return Type2LifeSkillTable[lifeProfessionRow.Type]
end

function LifeProfessionVM.GetLifeProfessionProductnfo(proID, showConsume)
  local curSkill = LifeProfessionVM.GetLifeProfessionSkill(proID)
  if curSkill == nil then
    return nil
  end
  return curSkill.GetProductInfoList(proID, showConsume)
end

function LifeProfessionVM.IsProductUnlocked(proID, productID, isConsume)
  if not LifeProfessionVM.IsLifeProfessionUnlocked(proID) then
    return false
  end
  local curSkill = LifeProfessionVM.GetLifeProfessionSkill(proID)
  if curSkill == nil then
    return false
  end
  return curSkill.IsProductUnlocked(productID, isConsume)
end

function LifeProfessionVM.IsProductHasCost(proID, productID)
  local curSkill = LifeProfessionVM.GetLifeProfessionSkill(proID)
  if curSkill == nil then
    return false
  end
  return curSkill.IsProductHasCost(productID)
end

function LifeProfessionVM.CheckProductionIsUnlock(id)
  local lifeMenufactureData = Z.DataMgr.Get("life_menufacture_data")
  local productionDatas = lifeMenufactureData:GetProductionDatas()
  local isSub = true
  for k, v in pairs(productionDatas) do
    if v.productId == id then
      isSub = false
      if #v.subProductList > 0 then
        for _, subProduct in pairs(v.subProductList) do
          local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(subProduct)
          if LifeProfessionVM.CheckConditionUnlock(lifeProductionListTableRow) then
            return true
          end
        end
      else
        local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(v.productId)
        return LifeProfessionVM.CheckConditionUnlock(lifeProductionListTableRow)
      end
    end
  end
  if isSub then
    local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(id)
    return LifeProfessionVM.CheckConditionUnlock(lifeProductionListTableRow)
  end
  return false
end

function LifeProfessionVM.CheckConditionUnlock(productionRow)
  if productionRow.UnlockType == LifeProductionUnlockType.And then
    return Z.ConditionHelper.CheckCondition(productionRow.UnlockCondition)
  elseif productionRow.UnlockType == LifeProductionUnlockType.Or then
    for index, value in ipairs(productionRow.UnlockCondition) do
      if Z.ConditionHelper.CheckCondition({value}) then
        return true
      end
    end
    return false
  end
  return true
end

function LifeProfessionVM.IsSpecializationUnlocked(proID, specializationID)
  local professionInfo = Z.ContainerMgr.CharSerialize.lifeProfession.professionInfo
  if not professionInfo[proID] then
    return false
  end
  local lifeFormulaTableRow = Z.TableMgr.GetTable("LifeFormulaTableMgr").GetRow(specializationID)
  if not lifeFormulaTableRow then
    return false
  end
  local basicInfo = professionInfo[proID]
  if not basicInfo.specialization[lifeFormulaTableRow.GroupId] then
    return false
  end
  local liftProfessionSpecialization = basicInfo.specialization[lifeFormulaTableRow.GroupId]
  if liftProfessionSpecialization.level >= lifeFormulaTableRow.Level then
    return true
  end
  return false
end

function LifeProfessionVM.GetSpecializationLv(proID, specializationID)
  local professionInfo = Z.ContainerMgr.CharSerialize.lifeProfession.professionInfo
  if not professionInfo[proID] then
    return 0
  end
  local lifeFormulaTableRow = Z.TableMgr.GetTable("LifeFormulaTableMgr").GetRow(specializationID)
  if not lifeFormulaTableRow then
    return 0
  end
  local basicInfo = professionInfo[proID]
  if not basicInfo.specialization[lifeFormulaTableRow.GroupId] then
    return 0
  end
  local liftProfessionSpecialization = basicInfo.specialization[lifeFormulaTableRow.GroupId]
  return liftProfessionSpecialization.level
end

function LifeProfessionVM.GetCurSpecialization(proID, specializationID, groupId)
  local lifeFormulaTableMgr = Z.TableMgr.GetTable("LifeFormulaTableMgr")
  if not LifeProfessionVM.IsSpecializationUnlocked(proID, specializationID) then
    return lifeFormulaTableMgr.GetRow(specializationID)
  end
  local spcLevel = LifeProfessionVM.GetSpecializationLv(proID, specializationID)
  local lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  return lifeProfessionData_:GetSpecializationRow(groupId, spcLevel)
end

function LifeProfessionVM.CheckIsLifeProfessionPointItem(configId)
  return Z.SystemItem.LifeProfessionPointItem == configId
end

function LifeProfessionVM.GetSpcItemIDByProId()
  return Z.SystemItem.LifeProfessionPointItem
end

function LifeProfessionVM.GetSpcItemCnt()
  return Z.ContainerMgr.CharSerialize.lifeProfession.point
end

function LifeProfessionVM.GetSpecCanUnlockCnt(proID)
  if not LifeProfessionVM.IsLifeProfessionFuncUnlocked(proID, true) then
    return 0
  end
  local lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  local specializationGroupTable = lifeProfessionData_:GetSpe2GroupTable(proID)
  local curHavePoint = LifeProfessionVM.GetSpcItemCnt()
  local cnt = 0
  for id, groupId in pairs(specializationGroupTable) do
    local rowData = LifeProfessionVM.GetCurSpecialization(proID, id, groupId)
    if rowData then
      local curCost = rowData.NeedPoint
      local isActive = LifeProfessionVM.IsSpecializationUnlocked(proID, id)
      local meetCondition = Z.ConditionHelper.CheckCondition(rowData.UnlockCondition, false)
      if curHavePoint >= curCost and not isActive and meetCondition then
        cnt = cnt + 1
      end
    end
  end
  return cnt
end

function LifeProfessionVM.GetRewardCanGainCnt(proID)
  if not LifeProfessionVM.IsLifeProfessionFuncUnlocked(proID, true) then
    return 0
  end
  local lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  local rewardDatas = lifeProfessionData_:GetRewardDatas(proID)
  local cnt = 0
  for k, v in pairs(rewardDatas) do
    local state = LifeProfessionVM.GetAwardState(proID, v.Id)
    if state == E.LifeProfessionRewardState.UnGetReward then
      cnt = cnt + 1
    end
  end
  return cnt
end

function LifeProfessionVM.GetGradeTargetProgress(proID, targetID)
  local lifeAwardTargetTableRow = Z.TableMgr.GetTable("LifeAwardTargetTableMgr").GetRow(targetID)
  if not lifeAwardTargetTableRow then
    return 0, 0
  end
  local lifeTargetInfo = Z.ContainerMgr.CharSerialize.lifeProfession.lifeTargetInfo
  if not lifeTargetInfo[lifeAwardTargetTableRow.TargetGroupId] then
    return 0, lifeAwardTargetTableRow.Num
  end
  local targetInfo = lifeTargetInfo[lifeAwardTargetTableRow.TargetGroupId]
  return targetInfo.value, lifeAwardTargetTableRow.Num
end

function LifeProfessionVM.GetAwardState(proID, targetID)
  local lifeAwardTargetTableRow = Z.TableMgr.GetTable("LifeAwardTargetTableMgr").GetRow(targetID)
  if not lifeAwardTargetTableRow then
    return E.LifeProfessionRewardState.UnFinished
  end
  local lifeTargetInfo = Z.ContainerMgr.CharSerialize.lifeProfession.lifeTargetInfo
  if not lifeTargetInfo[lifeAwardTargetTableRow.TargetGroupId] then
    return E.LifeProfessionRewardState.UnFinished
  end
  local targetInfo = lifeTargetInfo[lifeAwardTargetTableRow.TargetGroupId]
  local states = targetInfo.lifeTargetRewardStates
  for key, value in pairs(states) do
    if key == lifeAwardTargetTableRow.TargetLevl then
      return value
    end
  end
  return E.LifeProfessionRewardState.UnFinished
end

function LifeProfessionVM.IsLifeProfessionUnlocked(proID)
  if not LifeProfessionVM.IsLifeProfessionFuncUnlocked(proID, true) then
    return false
  end
  return LifeProfessionVM.GetLifeProfessionLv(proID) > 0
end

function LifeProfessionVM.IsLifeProfessionFuncUnlocked(proID, ignoreTip)
  local lifeProfessionTableRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(proID)
  local funcVM = Z.VMMgr.GetVM("gotofunc")
  return funcVM.FuncIsOn(lifeProfessionTableRow.FunctionId, ignoreTip)
end

function LifeProfessionVM.GetLifeProfessionLv(proID)
  local professionInfo = Z.ContainerMgr.CharSerialize.lifeProfession.professionInfo
  if not professionInfo[proID] then
    return 0
  end
  local basicInfo = professionInfo[proID]
  return basicInfo.level
end

function LifeProfessionVM.IsLifeProfessionMaxLevel(proID)
  local curLevel = LifeProfessionVM.GetLifeProfessionLv(proID)
  local lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  local maxLevel = lifeProfessionData_:GetProfessionMaxLevel(proID)
  return curLevel == maxLevel
end

function LifeProfessionVM.GetLifeProfessionExp(proID)
  if not LifeProfessionVM.IsLifeProfessionUnlocked(proID) then
    return 0, 0
  end
  local professionInfo = Z.ContainerMgr.CharSerialize.lifeProfession.professionInfo
  if not professionInfo[proID] then
    return 0, 0
  end
  local basicInfo = professionInfo[proID]
  local lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  local curLevel = LifeProfessionVM.GetLifeProfessionLv(proID)
  return basicInfo.exp, lifeProfessionData_:GetCurLVExp(proID, curLevel)
end

function LifeProfessionVM.AsyncResetSpec(curProID, cancelToken)
  local confirmFunc = function()
    local worldProxy = require("zproxy.world_proxy")
    local ret = worldProxy.ResetSpecialization(curProID, cancelToken)
    if ret ~= 0 then
      Z.TipsVM.ShowTips(ret)
    end
  end
  local itemList = {}
  local lifeProfessionTableRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(curProID)
  local dialogItemData = {}
  dialogItemData.ItemId = lifeProfessionTableRow.FormulaResetCost[1]
  dialogItemData.ItemNum = lifeProfessionTableRow.FormulaResetCost[2]
  dialogItemData.LabType = E.ItemLabType.Expend
  table.insert(itemList, dialogItemData)
  local data = {
    dlgType = E.DlgType.YesNo,
    onConfirm = confirmFunc,
    labDesc = Lang("ConfirmResetProfessionSpec", {
      profession = lifeProfessionTableRow.Name
    }),
    itemList = itemList
  }
  Z.DialogViewDataMgr:OpenDialogView(data)
end

function LifeProfessionVM.AsyncRequestGetReward(targetID)
  local worldProxy = require("zproxy.world_proxy")
  local lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  local ret = worldProxy.GetUpgradeReward(targetID, lifeProfessionData_.CancelSource:CreateToken())
  if ret.items ~= nil then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(ret.items)
  end
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function LifeProfessionVM.AsyncRequestActivateSpecialization(proID, specID)
  local worldProxy = require("zproxy.world_proxy")
  local lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  local ret = worldProxy.ActivateSpecialization(proID, specID, lifeProfessionData_.CancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  else
    local lifeFormulaTableMgr = Z.TableMgr.GetTable("LifeFormulaTableMgr")
    local speConfig = lifeFormulaTableMgr.GetRow(specID)
    Z.TipsVM.ShowTips(1001908, {
      name = speConfig.Name
    })
    Z.EventMgr:Dispatch(Z.ConstValue.LifeProfession.LifeProfessionSpecLevelUp, specID)
  end
end

function LifeProfessionVM.AsyncRequestLifeProfessionBuild(id, count, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {recipeId = id, count = count}
  local ret = worldProxy.LifeProfessionBuild(request, cancelToken)
  if ret.items ~= nil then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(ret.items)
  end
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function LifeProfessionVM.RequestLifeProfessionCooking(recipeId, count, materials, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {
    recipeId = recipeId,
    count = count,
    materials = materials
  }
  local ret = worldProxy.LifeProfessionCooking(request, cancelToken)
  if ret.items ~= nil then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(ret.items)
  end
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function LifeProfessionVM.RequestLifeProfessionRDCooking(materials, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {materials = materials}
  local reply = worldProxy.LifeProfessionRDCooking(request, cancelToken)
  if reply.errCode ~= 0 then
    Z.TipsVM.ShowTips(reply.errCode)
    return
  end
end

function LifeProfessionVM.AsyncRequestLifeProfessionAlchemy(recipeId, count, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {recipeId = recipeId, count = count}
  local ret = worldProxy.LifeProfessionAlchemy(request, cancelToken)
  if ret.items ~= nil then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(ret.items)
  end
  if ret.errCode == 0 then
    Z.EventMgr:Dispatch(Z.ConstValue.LifeProfession.LifeProfessionBuildRefresh, recipeId)
  else
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function LifeProfessionVM.AsyncRequestLifeProfessionRDAlchemy(materials, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {materials = materials}
  local reply = worldProxy.LifeProfessionRDAlchemy(request, cancelToken)
  if reply.errCode ~= 0 then
    Z.TipsVM.ShowTips(reply.errCode)
    return false
  end
  local chemistryId = 0
  if reply.isUnlockRecipe then
    chemistryId = reply.unlockRecipeId
  end
  Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.ItemShow, "com_rewards_window", {
    itemList = reply.items
  })
  return true
end

function LifeProfessionVM.AsyncRequestUnlockLifeProfession(professionID, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local reply = worldProxy.UnLockLifeProfession(professionID, cancelToken)
  if reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return
  end
end

function LifeProfessionVM.QuickJumpLifeprofession(professionID, productionID, configId)
  local switchVM = Z.VMMgr.GetVM("switch")
  if not switchVM.CheckFuncSwitch(E.FunctionID.LifeProfession) then
    return
  end
  if professionID and type(professionID) == "string" then
    professionID = tonumber(professionID)
  end
  if productionID and type(productionID) == "string" then
    productionID = tonumber(productionID)
  end
  local isProfessionUnlcoked = LifeProfessionVM.IsLifeProfessionUnlocked(professionID)
  if isProfessionUnlcoked then
    local awardprevVm = Z.VMMgr.GetVM("awardpreview")
    local isConsume = true
    local lifeProfessionTableRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(professionID)
    if lifeProfessionTableRow.Type == E.ELifeProfessionMainType.Collection then
      if not productionID then
        isConsume = false
      else
        local lifeCollectListTableRow = Z.TableMgr.GetRow("LifeCollectListTableMgr", productionID)
        if lifeCollectListTableRow.Award == 0 then
          isConsume = false
        elseif lifeCollectListTableRow.FreeAward == 0 then
          isConsume = true
        else
          local awardList = awardprevVm.GetAllAwardPreListByIds(lifeCollectListTableRow.FreeAward)
          for k, v in pairs(awardList) do
            if v.awardId == configId then
              isConsume = false
              break
            end
          end
        end
      end
    elseif not productionID then
      isConsume = false
    else
      local lifeProductionListTableRow = Z.TableMgr.GetRow("LifeProductionListTableMgr", productionID)
      isConsume = lifeProductionListTableRow.Cost[2] and 0 < lifeProductionListTableRow.Cost[2]
    end
    LifeProfessionVM.OpenLifeProfessionInfoView(professionID, productionID, isConsume)
  else
    LifeProfessionVM.OpenLifeProfessionMainView(professionID, true)
  end
end

function LifeProfessionVM.OpenLifeProfessionMainView(professionID, showUnlockPopup)
  local switchVM = Z.VMMgr.GetVM("switch")
  if not switchVM.CheckFuncSwitch(E.FunctionID.LifeProfession) then
    return
  end
  Z.UIMgr:OpenView("life_profession_main", {professionID = professionID, showUnlockPopup = showUnlockPopup})
end

function LifeProfessionVM.OpenLifeProfessionView()
  local switchVM = Z.VMMgr.GetVM("switch")
  if not switchVM.CheckFuncSwitch(E.FunctionID.LifeProfession) then
    return
  end
  local professions = LifeProfessionVM.GetAllSortedProfessions()
  for k, v in pairs(professions) do
    if LifeProfessionVM.IsLifeProfessionUnlocked(v.ProId) then
      LifeProfessionVM.OpenLifeProfessionInfoView(v.ProId)
      return
    end
  end
  Z.UIMgr:OpenView("life_profession_main")
end

function LifeProfessionVM.CloseLifeProfessionMainView()
  Z.UIMgr:CloseView("life_profession_main")
end

function LifeProfessionVM.OpenLifeProfessionInfoView(professionID, productionID, isConsume)
  if professionID and type(professionID) == "string" then
    professionID = tonumber(professionID)
  end
  local config = Z.TableMgr.GetRow("LifeProfessionTableMgr", professionID)
  if config == nil then
    return
  end
  local funcVM = Z.VMMgr.GetVM("gotofunc")
  if not funcVM.FuncIsOn(config.FunctionId, false) then
    return
  end
  Z.UIMgr:OpenView("life_profession_acquisition_main", {
    proID = professionID,
    productionID = productionID,
    isConsume = isConsume
  })
end

function LifeProfessionVM.CloseLifeProfessionInfoView()
  Z.UIMgr:CloseView("life_profession_acquisition_main")
end

function LifeProfessionVM.NoticeRecipeUnlock(viewData)
  local recipeName = Lang("LifeProfessionRecipeUnlock", {
    name = viewData.recipeName
  })
  Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.LifeRecipe, "season_achievement_finish_popup", {name = recipeName, isRecipeUnlock = true})
end

function LifeProfessionVM.OpenSwicthFormulaPopUp(data, trans, showLock)
  if showLock == nil then
    showLock = false
  end
  Z.UIMgr:OpenView("life_profession_formula_tips", {
    data = data,
    trans = trans,
    showLock = showLock
  })
end

function LifeProfessionVM.CloseSwicthFormulaPopUp()
  Z.UIMgr:CloseView("life_profession_formula_tips")
end

function LifeProfessionVM.ShowProLevelUp(proID, level)
  local param = {
    ProfessionUpgrade = true,
    ProfessionId = proID,
    ProfessionLevel = level
  }
  Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FunctionOpen, "main_upgrade_window", param, 0)
end

function LifeProfessionVM.CloseLevelUpView()
  Z.UIMgr:CloseView("life_profession_levelup_window")
end

function LifeProfessionVM.CloseCastMainView()
  Z.UIMgr:CloseView("life_profession_cast_main")
end

function LifeProfessionVM.OpenCastMainView(proID, cameraId, isHouseCast)
  Z.UIMgr:OpenView("life_profession_cast_main", {
    proID = proID,
    camID = tonumber(cameraId),
    slowCam = true,
    isHouseCast = isHouseCast
  })
end

function LifeProfessionVM.OpenUnlockProfessionWindow(professionID)
  Z.UIMgr:OpenView("life_profession_unlock_window", {professionID = professionID})
end

function LifeProfessionVM.CloseUnlockProfessionWindow()
  Z.UIMgr:CloseView("life_profession_unlock_window")
end

function LifeProfessionVM.GetProductionMaterials(data)
  local datas = {}
  if data.NeedMaterialType == 1 then
    if data.Type ~= E.ManufactureProductType.House then
      for k, v in pairs(data.NeedMaterial) do
        if v[1] ~= 0 then
          local itemData = {}
          itemData.itemID = v[1]
          itemData.count = v[2]
          table.insert(datas, itemData)
        end
      end
    else
      local furnitureId = data.FurnitureId
      local housingItemsRow = Z.TableMgr.GetTable("HousingItemsMgr").GetRow(furnitureId)
      for k, v in pairs(housingItemsRow.Consume) do
        if v[1] ~= 0 then
          local itemData = {}
          itemData.itemID = v[1]
          itemData.count = v[2]
          table.insert(datas, itemData)
        end
      end
    end
  elseif data.NeedMaterialType == 2 then
    for k, v in pairs(data.NeedMaterial) do
      if v[1] ~= 0 then
        local itemData = {}
        itemData.itemID = v[1]
        itemData.count = v[2]
        itemData.isItemType = true
        table.insert(datas, itemData)
      end
    end
  end
  return datas
end

function LifeProfessionVM.GetMenufactureBuffDatas(data)
  local curSkill = LifeProfessionVM.GetLifeProfessionSkill(data.LifeProId)
  if curSkill == nil then
    return nil
  end
  local datas = curSkill.GetBuffDatas(data.Id)
  return datas
end

function LifeProfessionVM.GetCastFixedAwards(data)
  local allRewards = {}
  local fixedAwardPackage = data.Award[1]
  table.insert(allRewards, fixedAwardPackage)
  local specialRewardID
  for k, v in pairs(data.SpecialAward) do
    if LifeProfessionVM.IsSpecializationUnlocked(data.LifeProId, v[2]) then
      specialRewardID = v[1]
    end
  end
  if specialRewardID then
    table.insert(allRewards, specialRewardID)
  end
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  return awardPreviewVm.GetAwardProbData(allRewards)
end

function LifeProfessionVM.SwitchEntityShow(show)
  if show then
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_CHARACTER)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_MONSTER)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_BOSS)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_PLAYER)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_NPC)
    Z.LuaBridge.SetHudSwitch(true)
  else
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_CHARACTER)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_MONSTER)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_BOSS)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_PLAYER)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_NPC)
    Z.LuaBridge.SetHudSwitch(false)
  end
end

function LifeProfessionVM.SetAllLockedRecipe()
  local lifeMenufactureData = Z.DataMgr.Get("life_menufacture_data")
  local lifeProfessionData = Z.DataMgr.Get("life_profession_data")
  lifeProfessionData:Clear()
  local dataList = LifeProfessionVM.GetAllProfessions()
  for k, v in pairs(dataList) do
    local skill = LifeProfessionVM.GetLifeProfessionSkill(v.ProId)
    local productionList = lifeMenufactureData:GetALLProductionDatas()
    for k, production in pairs(productionList) do
      if not skill.IsProductUnlocked(production.Id) and production.LifeProId == v.ProId then
        lifeProfessionData:SetRecipeLockedData(v.ProId, production.Id)
      end
    end
  end
end

function LifeProfessionVM.CheckHasNewRecipe(conditionType)
  local lifeProfessionData = Z.DataMgr.Get("life_profession_data")
  local lockedRecipeTable = lifeProfessionData:GetRecipeLockedData()
  for proID, lockedRecipeList in pairs(lockedRecipeTable) do
    local lifeSkill = LifeProfessionVM.GetLifeProfessionSkill(proID)
    for k, v in pairs(lockedRecipeList) do
      if v and LifeProfessionVM.IsProductUnlocked(proID, k) then
        lifeSkill.NoticeRecipeUnlock(proID, k)
        lifeProfessionData:SetRecipeUnLockedData(proID, k)
      end
    end
  end
end

function LifeProfessionVM.GetNextGainVitalityConsume()
  local spareEnergy = Z.ContainerMgr.CharSerialize.lifeProfession.spareEnergy
  local craftEnergyTableRow = Z.TableMgr.GetRow("CraftEnergyTableMgr", Z.SystemItem.VigourItemId)
  local total = 0
  local cnt = 0
  for k, v in pairs(craftEnergyTableRow.CostAward) do
    if v[2] == Z.SystemItem.LifeProfessionPointItem then
      total = v[1]
      cnt = v[3]
    end
  end
  if not spareEnergy[Z.SystemItem.LifeProfessionPointItem] then
    return total, cnt
  end
  return total - spareEnergy[Z.SystemItem.LifeProfessionPointItem], cnt
end

function LifeProfessionVM.GetLifeManufactureCost(lifeProfessionId)
  if Z.EntityMgr.PlayerEnt == nil then
    return Z.Global.CastingConfirmTime
  end
  local costRate = Z.EntityMgr.PlayerEnt:GetTempAttrByType(E.TempAttrEffectType.TempAttrInteractionTimeRate, E.ETempAttrType.TempAttrLifeProfession, lifeProfessionId)
  local cost = Z.EntityMgr.PlayerEnt:GetTempAttrByType(E.TempAttrEffectType.TempAttrInteractionTime, E.ETempAttrType.TempAttrLifeProfession, lifeProfessionId)
  local time = Z.Global.CastingConfirmTime * (1 - costRate / 10000) - cost / 1000
  return Mathf.Max(time, 0)
end

return LifeProfessionVM
