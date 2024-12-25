local ModVM = {}
local worldProxy = require("zproxy.world_proxy")
local MOD_DEFINE = require("ui.model.mod_define")
local ItemsVM = Z.VMMgr.GetVM("items")
local TalentSkillDefine = require("ui.model.talent_skill_define")
local GotoFuncVM = Z.VMMgr.GetVM("gotofunc")

function ModVM.EnterModView(modSlotId, showModEffectId)
  local isModUnlock = GotoFuncVM.CheckFuncCanUse(E.FunctionID.Mod)
  if not isModUnlock then
    return
  end
  if modSlotId == nil then
    modSlotId = 1
  end
  local isUnlock, level = ModVM.CheckSlotIsUnlock(modSlotId)
  if isUnlock then
    Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Module_01, "mod_main", function()
      Z.UIMgr:OpenView("mod_main", {modSlotId = modSlotId, showModEffectId = showModEffectId})
    end)
  else
    Z.TipsVM.ShowTipsLang(1500001, {val = level})
  end
end

function ModVM.EnterModIntensifyView(intensifyType, uuid)
  local isModUnlock = GotoFuncVM.CheckFuncCanUse(E.FunctionID.Mod)
  if not isModUnlock then
    return
  end
  if intensifyType and type(intensifyType) == "string" then
    intensifyType = tonumber(intensifyType)
  end
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Module_01, "mod_intensify_window", function()
    Z.UIMgr:OpenView("mod_intensify_window", {intensifyType = intensifyType, uuid = uuid})
  end)
end

function ModVM.EnterModIntensify()
  ModVM.EnterModIntensifyView(MOD_DEFINE.ModIntensifyType.Intensify)
end

function ModVM.EnterModDecompose()
  ModVM.EnterModIntensifyView(MOD_DEFINE.ModIntensifyType.Decompose)
end

function ModVM.EnterModPreviewView()
  local isModUnlock = GotoFuncVM.CheckFuncCanUse(E.FunctionID.Mod)
  if not isModUnlock then
    return
  end
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Explore_03, "mod_preview_window", function()
    Z.UIMgr:OpenView("mod_preview_window")
  end)
end

function ModVM.GetModPackageCount(modId)
  local itemsVM = Z.VMMgr.GetVM("items")
  return itemsVM.GetItemTotalCount(modId)
end

function ModVM.GetUnEquipSlotId()
  local slot = 1
  local modList = Z.ContainerMgr.CharSerialize.mod
  if modList and modList.modSlots then
    for i = 1, MOD_DEFINE.ModSlotMaxCount do
      if modList.modSlots[i] == nil and ModVM.CheckSlotIsUnlock(i) then
        slot = i
        break
      end
    end
  end
  return slot
end

function ModVM.ParseModEffectDesc(effectId, level)
  local modData = Z.DataMgr.Get("mod_data")
  local config = modData:GetEffectTableConfig(effectId, level)
  local fightAttrParseVm = Z.VMMgr.GetVM("fight_attr_parse")
  local buffAttrParseVM = Z.VMMgr.GetVM("buff_attr_parse")
  local tempAttrParamVM = Z.VMMgr.GetVM("temp_attr_parse")
  local effectList = {}
  local buffIndex = 0
  for _, value in ipairs(config.EffectConfig) do
    local type = value[1]
    if type == TalentSkillDefine.TalentTreeUnitEffectType.Basic then
      local attrDesc = fightAttrParseVm.ParseFightAttrTips(value[2], value[3])
      if attrDesc then
        table.insert(effectList, attrDesc)
      end
    elseif type == TalentSkillDefine.TalentTreeUnitEffectType.Buff then
      buffIndex = buffIndex + 1
      local param = {}
      local paramArray = config.EffectValue[buffIndex]
      if paramArray then
        for paramIndex, paramValue in ipairs(paramArray) do
          param[paramIndex] = {paramValue}
        end
      end
      table.insert(effectList, buffAttrParseVM.ParseBufferTips(value[2], param))
    elseif type == TalentSkillDefine.TalentTreeUnitEffectType.TempBasic then
      local desc = tempAttrParamVM.ParamTempAttr(value[2], value[3])
      table.insert(effectList, desc)
    end
  end
  return table.concat(effectList, "\n")
end

function ModVM.AsyncEquipMod(uuid, modSlotId, cancelToken)
  local itemData = ItemsVM.GetItemInfo(uuid, E.BackPackItemPackageType.Mod)
  local modId = itemData.configId
  local modTableConfig = Z.TableMgr.GetTable("ModTableMgr").GetRow(modId)
  if modTableConfig == nil then
    return
  end
  if not ModVM.CheckSlotIsUnlock(modSlotId) then
    Z.TipsVM.ShowTipsLang(1042105)
    return
  end
  local isEquip, slot = ModVM.IsModEquip(uuid)
  if isEquip and slot ~= modSlotId then
    local confirmFunc = function()
      Z.DialogViewDataMgr:CloseDialogView()
      ModVM.AsyncInstallMod(uuid, modSlotId, cancelToken)
    end
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("Mod_Replace_Tips"), confirmFunc, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.SameModExchangeSlot)
    return
  end
  local isConflict, slotId = ModVM.CheckModOnly(modId, modSlotId)
  if isConflict then
    Z.TipsVM.ShowTipsLang(1042110)
    return
  end
  local isSameType = false
  local curSlotModUuid
  local modList = Z.ContainerMgr.CharSerialize.mod
  if modList and modList.modSlots then
    curSlotModUuid = modList.modSlots[modSlotId]
  end
  if curSlotModUuid then
    local itemInfo = ItemsVM.GetItemInfo(curSlotModUuid, E.BackPackItemPackageType.Mod)
    local modConfig = Z.TableMgr.GetTable("ModTableMgr").GetRow(itemInfo.configId)
    if modConfig then
      isSameType = modConfig.ModType == modTableConfig.ModType
    end
  end
  local count = ModVM.GetModTypeCount(modTableConfig.ModType)
  local maxCount = ModVM.GetModTypeMaxCount(modTableConfig.ModType)
  if count >= maxCount and not isSameType then
    Z.TipsVM.ShowTipsLang(1042106)
    return
  end
  ModVM.AsyncInstallMod(uuid, modSlotId, cancelToken)
end

function ModVM.GetModTypeMaxCount(modType)
  local limitNum = Z.Global.ModTypeLimitNum
  for _, limit in pairs(limitNum) do
    if limit[1] == modType then
      return limit[2]
    end
  end
  return 0
end

function ModVM.GetModTypeCount(type)
  local count = 0
  local modList = Z.ContainerMgr.CharSerialize.mod
  if modList and modList.modSlots then
    for _, mod in pairs(modList.modSlots) do
      local itemData = ItemsVM.GetItemInfo(mod, E.BackPackItemPackageType.Mod)
      local modId = itemData.configId
      local modTableConfig = Z.TableMgr.GetTable("ModTableMgr").GetRow(modId)
      if modTableConfig.ModType == type then
        count = count + 1
      end
    end
  end
  return count
end

function ModVM.IsModEquip(uuid)
  local modList = Z.ContainerMgr.CharSerialize.mod
  if modList and modList.modSlots then
    for pos, slot in pairs(modList.modSlots) do
      if slot == uuid then
        return true, pos
      end
    end
  end
  return false
end

function ModVM.CheckModOnly(modId, modSlotId)
  local modTableConfig = Z.TableMgr.GetTable("ModTableMgr").GetRow(modId)
  if modTableConfig == nil then
    return false
  end
  if modTableConfig.IsOnly then
    local modList = Z.ContainerMgr.CharSerialize.mod
    if modList and modList.modSlots then
      for i = 1, MOD_DEFINE.ModSlotMaxCount do
        if ModVM.CheckSlotIsUnlock(i) and modList.modSlots[i] ~= nil and i ~= modSlotId then
          local modInfo = ItemsVM.GetItemInfo(modList.modSlots[i], E.BackPackItemPackageType.Mod)
          local equipModConfig = Z.TableMgr.GetTable("ModTableMgr").GetRow(modInfo.configId)
          if equipModConfig.IsOnly and equipModConfig.SimilarId == modTableConfig.SimilarId then
            return true, i
          end
        end
      end
    end
  end
  return false
end

function ModVM.CheckSlotIsUnlock(modSlotId)
  local modHoleTableConfig = Z.TableMgr.GetTable("ModHoleTableMgr").GetRow(modSlotId)
  if modHoleTableConfig then
    local unlockLevel = 0
    if modHoleTableConfig.UnlockLevel then
      unlockLevel = modHoleTableConfig.UnlockLevel
    end
    return unlockLevel <= Z.ContainerMgr.CharSerialize.roleLevel.level, unlockLevel
  end
  return false, 0
end

function ModVM.GetEquipEffectSuccessTimesAndLevelAndNextLevelSuccessTimes(effectId)
  local successTime = 0
  local modList = Z.ContainerMgr.CharSerialize.mod
  if modList and modList.modSlots then
    local itemsVM = Z.VMMgr.GetVM("items")
    for _, uuid in pairs(modList.modSlots) do
      if modList.modInfos and modList.modInfos[uuid] then
        local upgradeRecords = modList.modInfos[uuid].upgradeRecords
        for _, upgradeRecord in ipairs(upgradeRecords) do
          if upgradeRecord.partId == effectId and upgradeRecord.isSuccess then
            successTime = successTime + 1
          end
        end
      end
    end
  end
  local modData = Z.DataMgr.Get("mod_data")
  local effectConfigs = modData:GetEffectTableConfigList(effectId)
  local maxSuccessTimes = 0
  local curConfig
  for _, config in ipairs(effectConfigs) do
    maxSuccessTimes = math.max(maxSuccessTimes, config.EnhancementNum)
    if successTime >= config.EnhancementNum and Z.ContainerMgr.CharSerialize.roleLevel.level >= config.PlayerLevel then
      curConfig = config
    end
  end
  local curLevel = 0
  local nextSuccessTimes = 0
  if curConfig then
    curLevel = curConfig.Level
    nextSuccessTimes = curConfig.EnhancementNum
  end
  if effectConfigs[curLevel + 2] then
    nextSuccessTimes = effectConfigs[curLevel + 2].EnhancementNum
  end
  return successTime, curLevel, nextSuccessTimes
end

function ModVM.GetEffectLevelAndNextLevelSuccessTimes(effectId, successTime)
  local modData = Z.DataMgr.Get("mod_data")
  local effectConfigs = modData:GetEffectTableConfigList(effectId)
  local maxSuccessTimes = 0
  local curConfig
  for _, config in ipairs(effectConfigs) do
    maxSuccessTimes = math.max(maxSuccessTimes, config.EnhancementNum)
    if successTime >= config.EnhancementNum and Z.ContainerMgr.CharSerialize.roleLevel.level >= config.PlayerLevel then
      curConfig = config
    end
  end
  local curLevel = 0
  local nextSuccessTimes = 0
  if curConfig then
    curLevel = curConfig.Level
    nextSuccessTimes = curConfig.EnhancementNum
  end
  if effectConfigs[curLevel + 2] then
    nextSuccessTimes = effectConfigs[curLevel + 2].EnhancementNum
  end
  return curLevel, nextSuccessTimes
end

function ModVM.GetModSuccessTimes(uuid)
  local successTimes = 0
  local modList = Z.ContainerMgr.CharSerialize.mod
  if modList and modList.modInfos then
    local modInfo = modList.modInfos[uuid]
    if modInfo and modInfo.upgradeRecords then
      for _, upgradeRecord in ipairs(modInfo.upgradeRecords) do
        if upgradeRecord.isSuccess then
          successTimes = successTimes + 1
        end
      end
    else
      local itemsVM = Z.VMMgr.GetVM("items")
      local itemInfo = itemsVM.GetItemInfo(uuid, E.BackPackItemPackageType.Mod)
      if itemInfo then
        for _, v in ipairs(itemInfo.modNewAttr.modParts) do
          local temp1, temp2 = ModVM.TempGetModInitSuccessTimes(v)
          successTimes = successTimes + temp1
        end
      end
    end
  end
  return successTimes
end

function ModVM.GetModEffectIdAndSuccessTimesDetail(uuid, itemInfo)
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemInfo == nil then
    itemInfo = itemsVM.GetItemInfo(uuid, E.BackPackItemPackageType.Mod)
  end
  local tempRes = {}
  local tempDetails = {}
  if itemInfo then
    for _, v in ipairs(itemInfo.modNewAttr.modParts) do
      tempRes[v], tempDetails[v] = ModVM.TempGetModInitSuccessTimes(v)
    end
  end
  if Z.ContainerMgr.CharSerialize.mod and Z.ContainerMgr.CharSerialize.mod.modInfos then
    local modInfo = Z.ContainerMgr.CharSerialize.mod.modInfos[uuid]
    if modInfo then
      if modInfo.partIds then
        for _, v in ipairs(modInfo.partIds) do
          tempRes[v] = 0
          tempDetails[v] = {}
        end
      end
      if modInfo.upgradeRecords then
        for _, upgraderecord in ipairs(modInfo.upgradeRecords) do
          if upgraderecord.isSuccess and tempRes[upgraderecord.partId] then
            tempRes[upgraderecord.partId] = tempRes[upgraderecord.partId] + 1
          end
          if tempDetails[upgraderecord.partId] then
            table.insert(tempDetails[upgraderecord.partId], upgraderecord.isSuccess)
          end
        end
      end
    end
  end
  local res = {}
  if itemInfo then
    for key, v in ipairs(itemInfo.modNewAttr.modParts) do
      res[key] = {
        id = v,
        level = tempRes[v],
        logs = tempDetails[v]
      }
    end
  end
  return res
end

function ModVM.GetModEffectIdAndSuccessTimes(uuid)
  local itemsVM = Z.VMMgr.GetVM("items")
  local itemInfo = itemsVM.GetItemInfo(uuid, E.BackPackItemPackageType.Mod)
  local tempRes = {}
  if itemInfo then
    for _, v in ipairs(itemInfo.modNewAttr.modParts) do
      tempRes[v] = ModVM.TempGetModInitSuccessTimes(v)
    end
  end
  if Z.ContainerMgr.CharSerialize.mod and Z.ContainerMgr.CharSerialize.mod.modInfos then
    local modInfo = Z.ContainerMgr.CharSerialize.mod.modInfos[uuid]
    if modInfo then
      if modInfo.partIds then
        for _, v in ipairs(modInfo.partIds) do
          tempRes[v] = 0
        end
      end
      if modInfo.upgradeRecords then
        for _, upgraderecord in ipairs(modInfo.upgradeRecords) do
          if upgraderecord.isSuccess and tempRes[upgraderecord.partId] then
            tempRes[upgraderecord.partId] = tempRes[upgraderecord.partId] + 1
          end
        end
      end
    end
  end
  local res = {}
  local index = 0
  for key, value in pairs(tempRes) do
    index = index + 1
    res[index] = {id = key, successTimes = value}
  end
  return res
end

function ModVM.GetModDecompose(modList)
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local awardIds = {}
  local index = 0
  for _, modUuid in ipairs(modList) do
    local awardId = ModVM.GetModDecomposeAwardByUuidAndSuccessTimes(modUuid)
    if awardId then
      index = index + 1
      awardIds[index] = awardId
    end
  end
  local awardInfo = awardPreviewVm.GetAllAwardPreListByIds(awardIds)
  return awardInfo
end

function ModVM.GetModDecomposeAwardByUuidAndSuccessTimes(modInfo)
  local successTimes = ModVM.GetModSuccessTimes(modInfo.uuid)
  local config = Z.TableMgr.GetTable("ModTableMgr").GetRow(modInfo.configId)
  if config then
    for _, decomposeAward in ipairs(config.DecomposeAwardPackID) do
      if successTimes >= decomposeAward[1] and successTimes <= decomposeAward[2] then
        return decomposeAward[3]
      end
    end
  end
  return nil
end

function ModVM.CalculateCurModSuccessRate(uuid)
  local itemsVM = Z.VMMgr.GetVM("items")
  local itemInfo = itemsVM.GetItemInfo(uuid, E.BackPackItemPackageType.Mod)
  local modData = Z.DataMgr.Get("mod_data")
  local successRate = modData:GetSuccessRate(itemInfo.quality)
  local curRate = successRate[2]
  local modList = Z.ContainerMgr.CharSerialize.mod
  if modList and modList.modInfos then
    local modInfo = modList.modInfos[uuid]
    if modInfo and modInfo.successRate then
      curRate = modInfo.successRate
    end
  end
  return curRate / 100
end

function ModVM.IsHaveRedDot(modSlotId)
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  if not funcVm.CheckFuncCanUse(E.FunctionID.Mod, true) then
    return false
  end
  if modSlotId and not ModVM.CheckSlotIsUnlock(modSlotId) then
    return false
  end
  local emptySlot = -1
  local equipModUuid = {}
  local allSlotIsEquip = true
  local tempModType = {}
  local limitNum = Z.Global.ModTypeLimitNum
  for _, limit in pairs(limitNum) do
    tempModType[limit[1]] = limit[2]
  end
  local modHoleTableConfigs = Z.TableMgr.GetTable("ModHoleTableMgr").GetDatas()
  local modList = Z.ContainerMgr.CharSerialize.mod
  for _, config in pairs(modHoleTableConfigs) do
    if ModVM.CheckSlotIsUnlock(config.Id) then
      if modList and modList.modSlots and modList.modSlots[config.Id] then
        local modUuid = modList.modSlots[config.Id]
        local itemData = ItemsVM.GetItemInfo(modUuid, E.BackPackItemPackageType.Mod)
        local modId = itemData.configId
        local modTableConfig = Z.TableMgr.GetTable("ModTableMgr").GetRow(modId)
        tempModType[modTableConfig.ModType] = tempModType[modTableConfig.ModType] - 1
        equipModUuid[modUuid] = true
        if modSlotId == config.Id then
          return false
        end
      else
        allSlotIsEquip = false
        emptySlot = config.Id
      end
    end
  end
  if allSlotIsEquip then
    return false
  end
  if modSlotId then
    emptySlot = modSlotId
  end
  local redMod = {}
  local redModCount = 0
  local itemsVM = Z.VMMgr.GetVM("items")
  local madlistItems = itemsVM.GetItemIds(E.BackPackItemPackageType.Mod, nil, nil, false)
  if 0 < #madlistItems then
    for _, item in ipairs(madlistItems) do
      if equipModUuid[item.itemUuid] then
      else
        local itemData = ItemsVM.GetItemInfo(item.itemUuid, E.BackPackItemPackageType.Mod)
        local modId = itemData.configId
        local modTableConfig = Z.TableMgr.GetTable("ModTableMgr").GetRow(modId)
        local isConflict, slotId = ModVM.CheckModOnly(modId, emptySlot)
        if not isConflict and tempModType[modTableConfig.ModType] > 0 then
          redModCount = redModCount + 1
          redMod[item.itemUuid] = item.itemUuid
        end
      end
    end
  end
  return 0 < redModCount, redMod
end

function ModVM.GetAllEquipSuccessTimes()
  local successTimes = 0
  local modList = Z.ContainerMgr.CharSerialize.mod
  if modList and modList.modSlots then
    for _, uuid in pairs(modList.modSlots) do
      successTimes = ModVM.GetModSuccessTimes(uuid) + successTimes
    end
  end
  return successTimes
end

function ModVM.GetPreviewEquipSuccessTimes(slotId, uuid)
  local successTimes = ModVM.GetModSuccessTimes(uuid)
  local modList = Z.ContainerMgr.CharSerialize.mod
  if modList and modList.modSlots then
    for slot, uuid in pairs(modList.modSlots) do
      if slot ~= slotId then
        successTimes = ModVM.GetModSuccessTimes(uuid) + successTimes
      end
    end
  end
  return successTimes
end

function ModVM.GetSlotEquipModUuid(slotId)
  local modList = Z.ContainerMgr.CharSerialize.mod
  if modList and modList.modSlots then
    return modList.modSlots[slotId]
  end
  return nil
end

function ModVM.GetEquipModEffectAndLevel(uuids)
  local tempEffects = {}
  for _, uuid in pairs(uuids) do
    local effects = ModVM.GetModEffectIdAndSuccessTimes(uuid)
    for _, effect in ipairs(effects) do
      if tempEffects[effect.id] then
        tempEffects[effect.id] = tempEffects[effect.id] + effect.successTimes
      else
        tempEffects[effect.id] = effect.successTimes
      end
    end
  end
  local res = {}
  local index = 0
  for key, value in pairs(tempEffects) do
    index = index + 1
    res[index] = {id = key, successTimes = value}
  end
  return res
end

function ModVM.MergeEquipModEffectAndLevel(effect, mergeEffect)
  local tempEffects = {}
  for _, effect in ipairs(effect) do
    tempEffects[effect.id] = {
      curValue = effect.successTimes,
      nextValue = 0
    }
  end
  for _, effect in ipairs(mergeEffect) do
    if tempEffects[effect.id] then
      tempEffects[effect.id].nextValue = effect.successTimes
    else
      tempEffects[effect.id] = {
        curValue = 0,
        nextValue = effect.successTimes
      }
    end
  end
  local res = {}
  local index = 0
  for key, value in pairs(tempEffects) do
    index = index + 1
    res[index] = {
      id = key,
      curValue = value.curValue,
      nextValue = value.nextValue
    }
  end
  return res
end

function ModVM.OpenModSearchTips(transform)
  local searchVm = Z.VMMgr.GetVM("type_search")
  local functions = searchVm.GetObtainWayByType({
    511,
    512,
    513
  })
  if table.zcount(functions) == 0 then
    return
  end
  local viewData = {
    rect = transform,
    approachDatas = functions,
    isRightFirst = false
  }
  Z.UIMgr:OpenView("tips_approach", viewData)
end

function ModVM.TempGetModInitSuccessTimes(effectId)
  local modData = Z.DataMgr.Get("mod_data")
  local config = modData:GetEffectTableConfig(effectId, 0)
  if config and not config.IsNegative then
    return 1, {
      [1] = true
    }
  end
  return 0, {}
end

function ModVM.GetRecommendFightValue()
  local fightValue = 0
  local modData = Z.DataMgr.Get("mod_data")
  local successTimes = ModVM.GetAllEquipSuccessTimes()
  local modLinkEffectConfig = modData:GetModLinkEffectConfig(successTimes)
  if modLinkEffectConfig then
    fightValue = fightValue + modLinkEffectConfig.FightValue
  end
  local modList = Z.ContainerMgr.CharSerialize.mod
  if modList and modList.modSlots then
    local equipDetails = ModVM.GetEquipModEffectAndLevel(modList.modSlots)
    for _, value in pairs(equipDetails) do
      local level, _ = ModVM.GetEffectLevelAndNextLevelSuccessTimes(value.id, value.successTimes)
      local modEffectConfig = modData:GetEffectTableConfig(value.id, level)
      if modEffectConfig then
        fightValue = fightValue + modEffectConfig.FightValue
      end
    end
  end
  return fightValue
end

function ModVM.CheckReply(reply)
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  else
    return true
  end
end

function ModVM.AsyncInstallMod(uuid, slot, cancelToken)
  local request = {slotId = slot, modUuid = uuid}
  local reply = worldProxy.InstallMod(request, cancelToken)
  if ModVM.CheckReply(reply) then
    Z.EventMgr:Dispatch(Z.ConstValue.Mod.OnModInstall, uuid, slot)
    return true
  else
    return false
  end
end

function ModVM.AsyncUninstallMod(slot, cancelToken)
  local request = {slotId = slot}
  local reply = worldProxy.UninstallMod(request, cancelToken)
  if ModVM.CheckReply(reply) then
    Z.EventMgr:Dispatch(Z.ConstValue.Mod.OnModUnInstall, slot)
    return true
  else
    return false
  end
end

function ModVM.AsyncIntensify(uuid, effectId, cancelToken)
  local request = {modUuid = uuid, partEffectConfigId = effectId}
  local reply = worldProxy.UpgradeMod(request, cancelToken)
  if ModVM.CheckReply(reply) then
    local modinfo = Z.ContainerMgr.CharSerialize.mod.modInfos[uuid]
    if modinfo.upgradeRecords[#modinfo.upgradeRecords].isSuccess then
      local modData = Z.DataMgr.Get("mod_data")
      local successTime, curLv, nextSuccessTimes = ModVM.GetEquipEffectSuccessTimesAndLevelAndNextLevelSuccessTimes(effectId)
      local config = modData:GetEffectTableConfig(effectId, curLv)
      if config and config.EnhancementNum == successTime and ModVM.IsModEquip(uuid) then
        Z.UIMgr:OpenView("mod_intensify_popup", {effectId = effectId, lv = curLv})
      else
        Z.AudioMgr:Play("UI_Event_Magic_C")
        Z.TipsVM.ShowTips(1042111)
      end
    else
      Z.AudioMgr:Play("sys_general_cancel")
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Mod.OnModIntensify, effectId)
    return true
  else
    return false
  end
end

function ModVM.AsyncDecomposeMods(uuids, cancelToken)
  local request = {modUuids = uuids}
  local reply = worldProxy.DecomposeMod(request, cancelToken)
  if ModVM.CheckReply(reply) then
    Z.EventMgr:Dispatch(Z.ConstValue.Mod.OnModDecompose)
  end
  return false
end

return ModVM
