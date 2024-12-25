local WeaponSkillVM = {}

function WeaponSkillVM:OpenSkillRemodelPopUp(skillId)
  local viewData = {skillId = skillId}
  Z.UIMgr:OpenView("weapon_skill_remodel_popup", viewData)
end

function WeaponSkillVM:CloseSkillRemodePopUp()
  Z.UIMgr:CloseView("weapon_skill_remodel_popup")
end

function WeaponSkillVM:OpenSkillLevelUpView(viewData)
  Z.UIMgr:OpenView("weapon_skill_upgrades_popup", viewData)
end

function WeaponSkillVM:CloseSkillLevelUpView()
  Z.UIMgr:CloseView("weapon_skill_upgrades_popup")
end

function WeaponSkillVM:OpenSkillUnlockView(viewData)
  Z.UIMgr:OpenView("weapon_skill_unlock_popup", viewData)
end

function WeaponSkillVM:CloseSkillIUnlockView()
  Z.UIMgr:CloseView("weapon_skill_unlock_popup")
end

function WeaponSkillVM:OpenResonanceSkillPreviewView(viewData)
  Z.UIMgr:OpenView("weapon_resonance_preview_popup", viewData)
end

function WeaponSkillVM:OpenResonanceAdvanceSuccessPopup(viewData)
  Z.UIMgr:OpenView("weaponhero_advance_popup", viewData)
end

function WeaponSkillVM:OpenResonanceSkillAdvanceView(viewData)
  local viewConfigKey = "weapon_resonance_advance_window"
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Explore_03, viewConfigKey, function()
    Z.UIMgr:OpenView(viewConfigKey, viewData)
  end)
end

function WeaponSkillVM.OpenWeaponSkillView(skillType, skillId)
  local viewData = {
    skillType = tonumber(skillType),
    skillId = skillId
  }
  Z.UIMgr:OpenView("weapon_skill_main", viewData)
end

function WeaponSkillVM.OpenWeaponSkillViewBySkillId(skillId)
  local skillConfig = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  local slotId = skillConfig.SlotPositionId[1]
  local skillType = WeaponSkillVM:GetSkillTypeBySlotId(slotId)
  WeaponSkillVM.OpenWeaponSkillView(skillType, skillId)
end

function WeaponSkillVM:CloseWeaponSkillView()
  Z.UIMgr:CloseView("weapon_skill_main")
end

function WeaponSkillVM:GetSkillRemodelLevel(skillId)
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local weaponId = weaponVm.GetCurWeapon()
  local weaponInfo = weaponVm.GetWeaponInfo(weaponId)
  skillId = self:GetOriginSkillId(skillId)
  if weaponInfo and weaponInfo.skillInfoMap and weaponInfo.skillInfoMap[skillId] then
    return weaponInfo.skillInfoMap[skillId].remodelLevel
  end
  if Z.ContainerMgr.CharSerialize.professionList.aoyiSkillInfoMap[skillId] then
    return Z.ContainerMgr.CharSerialize.professionList.aoyiSkillInfoMap[skillId].remodelLevel
  end
  return 0
end

function WeaponSkillVM:CheckSkillUnlock(skillId)
  local weaponList = Z.ContainerMgr.CharSerialize.professionList.professionList
  for _, weaponInfo in pairs(weaponList) do
    for __, value in ipairs(weaponInfo.activeSkillIds) do
      if value == skillId then
        return true
      end
    end
  end
  if Z.ContainerMgr.CharSerialize.professionList.aoyiSkillInfoMap[skillId] then
    return true
  end
  return false
end

function WeaponSkillVM:CheckSkillEquip(skillId)
  local slots = Z.ContainerMgr.CharSerialize.slots.slots
  for _, value in pairs(slots) do
    if value.skillId == skillId then
      return true
    end
  end
  return false
end

function WeaponSkillVM:CheckSkillCanEquip(skillId)
  local canEquip = false
  local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  for _, value in pairs(skillRow.SlotPositionId) do
    if value ~= 0 then
      local slotRow = Z.TableMgr.GetTable("SkillSlotPositionTableMgr").GetRow(value)
      if slotRow.IsReplace then
        canEquip = true
        return canEquip
      end
    end
  end
  return canEquip
end

function WeaponSkillVM:ChechSkillRemodelMax(skillId)
  local skillRemodelLevel = self:GetSkillRemodelLevel(skillId)
  local remodelDatas = self:GetSkillRemodelConfig(skillId)
  if remodelDatas == nil then
    return true
  end
  return skillRemodelLevel >= #remodelDatas
end

function WeaponSkillVM:CheckResonanceSkillRemodelMax(skillId)
  local skillRemodelLevel = self:GetSkillRemodelLevel(skillId)
  local remodelLevelList = self:GetResonanceSkillRemodelLevelList(skillId)
  if remodelLevelList == nil then
    return true
  end
  return skillRemodelLevel >= #remodelLevelList
end

local skillRemodelConfig

function WeaponSkillVM:GetSkillRemodelConfig(skillId)
  if skillRemodelConfig == nil then
    skillRemodelConfig = {}
    local weaponStarConfig = Z.TableMgr.GetTable("WeaponStarTableMgr").GetDatas()
    for _, value in ipairs(weaponStarConfig) do
      if skillRemodelConfig[value.SkillId] == nil then
        skillRemodelConfig[value.SkillId] = {}
      end
      table.insert(skillRemodelConfig[value.SkillId], value)
    end
  end
  if skillRemodelConfig[skillId] == nil then
    return {}
  end
  return skillRemodelConfig[skillId]
end

function WeaponSkillVM:GetSkillRemodelRow(skillId, level)
  if skillRemodelConfig == nil then
    skillRemodelConfig = {}
    local weaponStarConfig = Z.TableMgr.GetTable("WeaponStarTableMgr").GetDatas()
    for _, value in ipairs(weaponStarConfig) do
      if skillRemodelConfig[value.SkillId] == nil then
        skillRemodelConfig[value.SkillId] = {}
      end
      table.insert(skillRemodelConfig[value.SkillId], value)
    end
  end
  if skillRemodelConfig[skillId] == nil or skillRemodelConfig[skillId][level] == nil then
    return {}
  end
  return skillRemodelConfig[skillId][level]
end

local resonanceSkillRemodelConfig

function WeaponSkillVM:GetResonanceSkillRemodelLevelList(skillId)
  if resonanceSkillRemodelConfig == nil then
    resonanceSkillRemodelConfig = {}
    local weaponStarConfig = Z.TableMgr.GetTable("SkillAoyiStarTableMgr").GetDatas()
    for _, value in ipairs(weaponStarConfig) do
      if resonanceSkillRemodelConfig[value.SkillId] == nil then
        resonanceSkillRemodelConfig[value.SkillId] = {}
      end
      table.insert(resonanceSkillRemodelConfig[value.SkillId], value)
    end
  end
  if resonanceSkillRemodelConfig[skillId] == nil then
    return {}
  end
  return resonanceSkillRemodelConfig[skillId]
end

function WeaponSkillVM:GetResonanceSkillRemodelRow(skillId, level)
  local remodelLevelList = self:GetResonanceSkillRemodelLevelList(skillId)
  return remodelLevelList[level]
end

local skillLevelConfigs

function WeaponSkillVM:GetLevelUpSkilllList()
  if skillLevelConfigs == nil then
    skillLevelConfigs = {}
  end
  local skillLevelTableDatas = Z.TableMgr.GetTable("SkillUpgradeTableMgr").GetDatas()
  for _, value in pairs(skillLevelTableDatas) do
    if skillLevelConfigs[value.UpgradeId] == nil then
      skillLevelConfigs[value.UpgradeId] = {}
    end
    skillLevelConfigs[value.UpgradeId][value.SkillLevel] = value
  end
end

function WeaponSkillVM:GetLevelUpSkilllRow(upgradeId, level)
  if skillLevelConfigs == nil then
    self:GetLevelUpSkilllList()
  end
  if skillLevelConfigs[upgradeId] == nil then
    return nil
  end
  return skillLevelConfigs[upgradeId][level]
end

function WeaponSkillVM:GetlevelUpDataBySKillUpgradeId(upgradeId)
  if skillLevelConfigs == nil then
    self:GetLevelUpSkilllList()
  end
  return skillLevelConfigs[upgradeId] or {}
end

function WeaponSkillVM:GetSkillFightDataById(skillId)
  local skillVm = Z.VMMgr.GetVM("skill")
  return skillVm.GetSkillFightDataListById(skillId)
end

function WeaponSkillVM:ParseRemodelDesc(skillId, advanceLevel, isResonanceSkill, hideEffectMul)
  local remodelRow
  if isResonanceSkill then
    remodelRow = self:GetResonanceSkillRemodelRow(skillId, advanceLevel)
  else
    remodelRow = self:GetSkillRemodelRow(skillId, advanceLevel)
  end
  if remodelRow == nil then
    return "", {}
  end
  local fightAttrParseVM = Z.VMMgr.GetVM("fight_attr_parse")
  local buffAttrParseVM = Z.VMMgr.GetVM("buff_attr_parse")
  local tempAttrParseVM = Z.VMMgr.GetVM("temp_attr_parse")
  local skillVM = Z.VMMgr.GetVM("skill")
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local descList = {}
  if #remodelRow.TransformationType == 0 then
    table.insert(descList, remodelRow.Des)
  else
    local buffIndex = 0
    for index, value in ipairs(remodelRow.TransformationType) do
      if index ~= 1 then
        table.insert(descList, "\n")
      end
      if value[1] == E.RemodelInfoType.Attr then
        local desc = fightAttrParseVM.ParseFightAttrTips(value[2], value[3])
        table.insert(descList, desc)
      elseif value[1] == E.RemodelInfoType.Buff then
        buffIndex = buffIndex + 1
        local param = {}
        local paramArray = remodelRow.BuffPar[buffIndex]
        if paramArray then
          for paramIndex, paramValue in ipairs(paramArray) do
            param[paramIndex] = {paramValue}
          end
        end
        local desc = buffAttrParseVM.ParseBufferTips(value[2], param)
        table.insert(descList, desc)
      elseif value[1] == E.RemodelInfoType.TmpAttr then
        local desc = tempAttrParseVM.ParamTempAttr(value[2], value[3])
        if desc ~= "" then
          table.insert(descList, desc)
        end
      elseif value[1] == E.RemodelInfoType.SkillDamageMultiple and not hideEffectMul then
        local level = weaponVm.GetShowSkillLevel(nil, skillId)
        local skillFightData = self:GetSkillFightDataById(skillId)
        local descEffectList = skillVM.GetSkillDecs(skillFightData[level].Id, advanceLevel, isResonanceSkill) or {}
        local preDescEffectList = skillVM.GetSkillDecs(skillFightData[level].Id, advanceLevel - 1, isResonanceSkill) or {}
        preDescEffectList = skillVM.GetSkillDecsWithColor(preDescEffectList)
        descEffectList = skillVM.ContrastSkillDecs(preDescEffectList, descEffectList)
        for index, value in ipairs(descEffectList) do
          local desc = ""
          desc = value.Dec .. Lang(":") .. value.Num
          if index < #descEffectList then
            desc = desc .. "\n"
          end
          table.insert(descList, desc)
        end
      elseif value[1] == E.RemodelInfoType.ReduceSkillCD then
        local skip = false
        for _, type in ipairs(remodelRow.TransformationType) do
          if type[1] == E.RemodelInfoType.SkillDamageMultiple then
            skip = true
            break
          end
        end
        if skip then
          break
        end
        local stringKey = "reduce_skill_cd"
        if 0 > value[3] then
          stringKey = "add_skill_cd"
        end
        local desc = Lang(stringKey, {
          val = value[3] / 1000
        })
        table.insert(descList, desc)
      elseif value[1] == E.RemodelInfoType.ReduceSkillCharge then
        local skip = false
        for _, type in ipairs(remodelRow.TransformationType) do
          if type[1] == E.RemodelInfoType.SkillDamageMultiple then
            skip = true
            break
          end
        end
        if skip then
          break
        end
        local stringKey = "reduce_skill_charge_time"
        if 0 > value[3] then
          stringKey = "add_skill_charge_time"
        end
        local desc = Lang(stringKey, {
          val = value[3] / 1000
        })
        table.insert(descList, desc)
      end
    end
  end
  return table.concat(descList), descList
end

function WeaponSkillVM:MergeMultiRemodelEffect(remodelDatas, skillId, advanceLevel, isShowSkillMultiple)
  local resultEffectList = {}
  local resultEffectDict = {}
  local buffParList = {}
  if remodelDatas and next(remodelDatas) ~= nil then
    local remodelLevel = advanceLevel or self:GetSkillRemodelLevel(skillId)
    for _, row in pairs(remodelDatas) do
      if remodelLevel >= row.Level then
        local buffIndex = 0
        for _, info in ipairs(row.TransformationType) do
          local type = info[1]
          if type == E.RemodelInfoType.Attr or type == E.RemodelInfoType.TmpAttr then
            if resultEffectDict[type] == nil then
              resultEffectDict[type] = {}
            end
            local id = info[2]
            local value = info[3]
            if resultEffectDict[type][id] == nil or value > resultEffectDict[type][id].checkValue then
              resultEffectDict[type][id] = {checkValue = value, info = info}
            end
          elseif type == E.RemodelInfoType.Buff then
            if resultEffectDict[type] == nil then
              resultEffectDict[type] = {}
            end
            buffIndex = buffIndex + 1
            local id = info[2]
            local buffPar = row.BuffPar[buffIndex]
            resultEffectDict[type][id] = {info = info, buffPar = buffPar}
          elseif type == E.RemodelInfoType.SkillDamageMultiple and isShowSkillMultiple then
            if resultEffectDict[type] == nil then
              resultEffectDict[type] = {}
            end
            local id = info[2]
            local value = row.Level
            if resultEffectDict[type][id] == nil or value > resultEffectDict[type][id].checkValue then
              resultEffectDict[type][id] = {checkValue = value, info = info}
            end
          end
        end
      end
    end
  end
  for type, effectList in pairs(resultEffectDict) do
    for id, effectInfo in pairs(effectList) do
      table.insert(resultEffectList, effectInfo.info)
      if type == E.RemodelInfoType.Buff then
        table.insert(buffParList, effectInfo.buffPar)
      end
    end
  end
  return resultEffectList, buffParList
end

function WeaponSkillVM:ParseResonanceSkillBaseDesc(skillId)
  local skillVM = Z.VMMgr.GetVM("skill")
  local content = ""
  local skillLv = 1
  local skillFightData = self:GetSkillFightDataById(skillId)
  local nowSkillFightLvTblData = skillFightData[skillLv]
  local advanceLevel = self:GetSkillRemodelLevel(skillId)
  local nowSkillDecsList = skillVM.GetSkillDecs(nowSkillFightLvTblData.Id, advanceLevel, true) or {}
  nowSkillDecsList = skillVM.GetSkillDecsWithColor(nowSkillDecsList)
  local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  if skillRow == nil then
    return content
  end
  content = Z.TableMgr.DecodeLineBreak(skillRow.Desc)
  if nowSkillDecsList then
    for index, value in ipairs(nowSkillDecsList) do
      if index == 1 then
        content = string.zconcat(content, [[


]], value.Dec, Lang(":"), value.Num)
      else
        content = string.zconcat(content, "\n", value.Dec, Lang(":"), value.Num)
      end
    end
  end
  return content
end

function WeaponSkillVM:ParseResonanceSkillDesc(skillId, advanceLevel, isTotal, isShowSkillMultiple)
  local outList = {
    attrList = {},
    buffList = {}
  }
  if advanceLevel == 0 then
    local resonanceRow = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetRow(skillId)
    if resonanceRow then
      local effectInfo = {
        transformationTypeField = resonanceRow.TransformationType,
        buffParam = resonanceRow.BuffPar
      }
      self:ParseResonanceTransformation(skillId, advanceLevel, effectInfo, outList, isShowSkillMultiple)
    end
  else
    local remodelRow = self:GetResonanceSkillRemodelRow(skillId, advanceLevel)
    if remodelRow then
      local transformationType = remodelRow.TransformationType
      local buffPar = remodelRow.BuffPar
      if isTotal then
        local remodelDatas = self:GetResonanceSkillRemodelLevelList(skillId)
        transformationType, buffPar = self:MergeMultiRemodelEffect(remodelDatas, skillId, advanceLevel, isShowSkillMultiple)
      end
      local effectInfo = {transformationTypeField = transformationType, buffParam = buffPar}
      self:ParseResonanceTransformation(skillId, advanceLevel, effectInfo, outList, isShowSkillMultiple)
    end
  end
  return outList.attrList, outList.buffList
end

function WeaponSkillVM:ParseResonanceTransformation(skillId, advanceLevel, effectInfo, outList, isShowSkillMultiple)
  local skillVM = Z.VMMgr.GetVM("skill")
  local fightAttrParseVM = Z.VMMgr.GetVM("fight_attr_parse")
  local buffAttrParseVM = Z.VMMgr.GetVM("buff_attr_parse")
  local tempAttrParseVM = Z.VMMgr.GetVM("temp_attr_parse")
  local buffTableMgr = Z.TableMgr.GetTable("BuffTableMgr")
  if #effectInfo.transformationTypeField > 0 then
    local buffIndex = 0
    for index, value in ipairs(effectInfo.transformationTypeField) do
      local type = value[1]
      if type == E.RemodelInfoType.Attr then
        local attrId = value[2]
        local attrValue = value[3]
        local desc = fightAttrParseVM.ParseFightAttrTips(attrId, attrValue)
        table.insert(outList.attrList, {
          title = "",
          desc = desc,
          type = type,
          id = attrId,
          value = attrValue
        })
      elseif type == E.RemodelInfoType.Buff then
        buffIndex = buffIndex + 1
        local param = {}
        local paramArray = effectInfo.buffParam[buffIndex]
        if paramArray then
          for paramIndex, paramValue in ipairs(paramArray) do
            param[paramIndex] = {paramValue}
          end
        end
        local buffId = value[2]
        local buffRow = buffTableMgr.GetRow(buffId)
        local desc = buffAttrParseVM.ParseBufferTips(buffId, param)
        table.insert(outList.buffList, {
          title = buffRow.Name,
          desc = desc
        })
      elseif type == E.RemodelInfoType.TmpAttr then
        local attrId = value[2]
        local attrValue = value[3]
        local desc = tempAttrParseVM.ParamTempAttr(attrId, attrValue)
        if desc ~= "" then
          table.insert(outList.attrList, {
            title = "",
            desc = desc,
            type = type,
            id = attrId,
            value = attrValue
          })
        end
      elseif value[1] == E.RemodelInfoType.SkillDamageMultiple and isShowSkillMultiple then
        local skillFightData = self:GetSkillFightDataById(skillId)
        local descEffectList = skillVM.GetSkillDecs(skillFightData[1].Id, advanceLevel, true) or {}
        descEffectList = skillVM.GetSkillDecsWithColor(descEffectList)
        local desc = ""
        for _, effect in pairs(descEffectList) do
          desc = string.zconcat(desc, effect.Dec, Lang(":"), effect.Num, "\n")
        end
        table.insert(outList.attrList, {
          title = "",
          desc = desc,
          type = type,
          id = 0,
          value = 0
        })
      end
    end
  end
end

local repalceTalentTree, replaceTalent

function WeaponSkillVM:GetAllReplaceConfig()
  replaceTalent = {}
  repalceTalentTree = {}
  local talentData = Z.TableMgr.GetTable("TalentTableMgr").GetDatas()
  for _, value in pairs(talentData) do
    for __, effect in pairs(value.TalentEffect) do
      if effect[1] == E.RemodelInfoType.SkillReplace then
        replaceTalent[value.Id] = {}
        replaceTalent[value.Id].skillId = effect[2]
        replaceTalent[value.Id].repalceSkillId = effect[3]
      end
    end
  end
  local talentTreeData = Z.TableMgr.GetTable("TalentTreeTableMgr").GetDatas()
  for _, value in pairs(talentTreeData) do
    local replaceTalentData = replaceTalent[value.TalentId]
    if replaceTalentData then
      table.insert(repalceTalentTree, value)
    end
  end
end

local skillReplaceDict = {}

function WeaponSkillVM:RefreshReplaceSkill()
  if replaceTalent == nil or repalceTalentTree == nil then
    self:GetAllReplaceConfig()
  end
  skillReplaceDict = {}
  local talentSkillVm = Z.VMMgr.GetVM("talent_skill")
  local professionId = Z.VMMgr.GetVM("profession").GetCurProfession()
  for _, value in pairs(repalceTalentTree) do
    if talentSkillVm.CheckTalentIsActive(professionId, value.Id) then
      local replaceTalentData = replaceTalent[value.TalentId]
      skillReplaceDict[replaceTalentData.skillId] = replaceTalentData.repalceSkillId
    end
  end
end

function WeaponSkillVM:GetSkillBySlot(slotId)
  local slots = Z.ContainerMgr.CharSerialize.slots.slots
  local tmpSkillId = 0
  if slots[slotId] then
    tmpSkillId = slots[slotId].skillId
  end
  if skillReplaceDict[tmpSkillId] then
    tmpSkillId = skillReplaceDict[tmpSkillId]
  end
  return tmpSkillId
end

function WeaponSkillVM:GetReplaceSkillId(skillId)
  if skillReplaceDict[skillId] and skillReplaceDict[skillId] ~= 0 then
    return skillReplaceDict[skillId]
  end
  return skillId
end

function WeaponSkillVM:GetOriginSkillId(skillId)
  for oriSkillId, repalceSkillId in pairs(skillReplaceDict) do
    if repalceSkillId == skillId then
      return oriSkillId
    end
  end
  return skillId
end

function WeaponSkillVM:GetSlotIdBySkillId(skillId)
  local slots = Z.ContainerMgr.CharSerialize.slots.slots
  for slotId, value in pairs(slots) do
    if value.skillId == skillId then
      return slotId
    end
  end
  return 0
end

local skillTypeInSlot = {
  [E.SkillType.WeaponSkill] = {
    1,
    3,
    4,
    5,
    9
  },
  [E.SkillType.MysteriesSkill] = {7, 8}
}

function WeaponSkillVM:GetSkillTypeBySlotId(slotId)
  for skillType, value in pairs(skillTypeInSlot) do
    for _, slotid in pairs(value) do
      if slotId == slotid then
        return skillType
      end
    end
  end
  return E.SkillType.WeaponSkill
end

function WeaponSkillVM:GetMysteriesSkillList(filterData)
  local resultList = {}
  local skillConfigs = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetDatas()
  for k, value in pairs(skillConfigs) do
    local isCanInsert = true
    if filterData then
      local filterRarity = filterData[E.ItemFilterType.ResonanceSkillRarity]
      if filterRarity and next(filterRarity) and not filterRarity[value.RarityType] then
        isCanInsert = false
      end
      local filterType = filterData[E.ItemFilterType.ResonanceSkillType]
      if filterType and next(filterType) and not filterType[value.ShowSkillType] then
        isCanInsert = false
      end
    end
    if isCanInsert then
      table.insert(resultList, {
        Config = value,
        IsEquip = self:CheckSkillEquip(value.Id),
        IsUnlock = self:CheckSkillUnlock(value.Id),
        IsCanUnlock = self:CheckResonanceSkillCanUnlock(value.Id)
      })
    end
  end
  table.sort(resultList, function(a, b)
    local a_equipState = a.IsEquip and 1 or 0
    local b_equipState = b.IsEquip and 1 or 0
    local a_unlockState = a.IsUnlock and 1 or 0
    local b_unlockState = b.IsUnlock and 1 or 0
    local a_canUnlockState = a.IsCanUnlock and 1 or 0
    local b_canUnlockState = b.IsCanUnlock and 1 or 0
    if a_equipState == b_equipState then
      if a_unlockState == b_unlockState then
        if a_canUnlockState == b_canUnlockState then
          if a.Config.RarityType == b.Config.RarityType then
            return a.Config.Index < b.Config.Index
          else
            return a.Config.RarityType > b.Config.RarityType
          end
        else
          return a_canUnlockState > b_canUnlockState
        end
      else
        return a_unlockState > b_unlockState
      end
    else
      return a_equipState > b_equipState
    end
  end)
  return resultList
end

function WeaponSkillVM:GetResonanceActiveRedDotId(skillId)
  return "weapon_resonance_active_item_" .. skillId
end

function WeaponSkillVM:GetResonanceAdvanceRedDotId(skillId, advanceLv)
  if advanceLv == nil then
    advanceLv = self:GetSkillRemodelLevel(skillId) + 1
  end
  return string.zconcat("weapon_resonance_advance_item_", skillId, "_", advanceLv)
end

function WeaponSkillVM:CheckResonanceSkillCanUnlock(skillId)
  local resonanceRow = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetRow(skillId)
  if resonanceRow == nil then
    return false
  end
  local isCanUnlock = true
  local itemsVM = Z.VMMgr.GetVM("items")
  for i, v in ipairs(resonanceRow.SkillAdvancedItem) do
    local itemId = v[1]
    local num = v[2]
    local haveNum = itemsVM.GetItemTotalCount(itemId)
    if num > haveNum then
      isCanUnlock = false
      break
    end
  end
  return isCanUnlock
end

function WeaponSkillVM:AsyncProfessionSkillRemodel(skillNodeId, skillId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.ProfessionSkillRemodel(skillNodeId, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Weapon.OnWeaponSkillRemodelSuccess, skillId)
  return true
end

function WeaponSkillVM:AsyncAoYiSkillRemodel(advanceId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local vRequest = {aoyiStarId = advanceId}
  local ret = worldProxy.AoYiSkillRemodel(vRequest, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  else
    local advanceRow = Z.TableMgr.GetTable("SkillAoyiStarTableMgr").GetRow(advanceId)
    if advanceRow then
      self:OpenResonanceAdvanceSuccessPopup({
        skillId = advanceRow.SkillId,
        advanceLv = advanceRow.Level
      })
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Weapon.OnResonanceSkillAdvanceSuccess)
  return true
end

function WeaponSkillVM:AsyncProfessionSkillLevelUp(professionId, skillId, targetLevel, skillType, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  if skillType == E.SkillType.WeaponSkill or skillType == E.SkillType.SupportSkill then
    local weaponSkillUpgradeRequest = {
      professionId = professionId,
      skillId = skillId,
      targetLevel = targetLevel
    }
    local ret = worldProxy.ProfessionSkillUpgrade(weaponSkillUpgradeRequest, cancelToken)
    if ret and ret ~= 0 then
      Z.TipsVM.ShowTips(ret)
      return false
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Weapon.OnWeaponSkillLevelUpSuccess, skillId)
    return true
  elseif skillType == E.SkillType.MysteriesSkill then
    local aoyiSkillUpgradeRequest = {skillId = skillId, targetLevel = targetLevel}
    local ret = worldProxy.AoYiSkillUpgrade(aoyiSkillUpgradeRequest, cancelToken)
    if ret and ret ~= 0 then
      Z.TipsVM.ShowTips(ret)
      return false
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Weapon.OnWeaponSkillLevelUpSuccess, skillId)
    return true
  end
end

function WeaponSkillVM:AsyncProfessionSkillUnlock(skillId, skillType, professionId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  if skillType == E.SkillType.WeaponSkill or skillType == E.SkillType.SupportSkill then
    local weaponSkillActiveRequest = {professionId = professionId, skillId = skillId}
    local ret = worldProxy.ProfessionSkillActive(weaponSkillActiveRequest, cancelToken)
    if ret and ret ~= 0 then
      Z.TipsVM.ShowTips(ret)
      return false
    end
    return true
  elseif skillType == E.SkillType.MysteriesSkill then
    local aoyiSkillActiveRequest = {skillId = skillId}
    local ret = worldProxy.AoYiSkillActive(aoyiSkillActiveRequest, cancelToken)
    if ret and ret ~= 0 then
      Z.TipsVM.ShowTips(ret)
      return false
    else
      self:OpenResonanceAdvanceSuccessPopup({skillId = skillId, advanceLv = 0})
      Z.EventMgr:Dispatch(Z.ConstValue.Hero.ResonacneSkillUnlock)
    end
    return true
  end
end

function WeaponSkillVM:AsyncSkillInstall(slotId, skillId, cancelToken)
  local unlock = self:CheckSkillUnlock(skillId)
  if skillId ~= 0 and not unlock then
    return
  end
  local worldProxy = require("zproxy.world_proxy")
  local nowSkillId = self:GetSkillBySlot(slotId)
  if skillId ~= 0 and skillId == nowSkillId then
    return
  end
  local ret = worldProxy.InstallSkill(slotId, skillId, cancelToken)
  Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnGuideEvnet, string.zconcat(E.SteerGuideEventType.AssemblySkillSlot, "=", slotId))
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  if skillId ~= 0 then
    local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
    Z.TipsVM.ShowTips(1045001, {
      val = skillRow.Name
    })
  end
  Z.AudioMgr:Play("UI_Click_QTE")
  Z.EventMgr:Dispatch(Z.ConstValue.Hero.InstallSkill, skillId)
  Z.EventMgr:Dispatch(Z.ConstValue.Hero.OldInstallSkillId, nowSkillId)
  if slotId == tonumber(E.SlotName.SkillSlot_7) or slotId == tonumber(E.SlotName.SkillSlot_8) then
    Z.EventMgr:Dispatch(Z.ConstValue.SkillSlotInstall, slotId)
  end
  return true
end

function WeaponSkillVM:GetSkillUpCost(UpgradeId, nowSkillLevel, nextLevel)
  local skillConfig = Z.TableMgr.GetTable("SkillUpgradeTableMgr").GetDatas()
  local cost = {}
  for _, skillConfig in ipairs(skillConfig) do
    if skillConfig.UpgradeId == UpgradeId and nowSkillLevel < skillConfig.SkillLevel and nextLevel >= skillConfig.SkillLevel then
      for _, value in ipairs(skillConfig.Cost) do
        local itemId = value[1]
        if cost[itemId] == nil then
          cost[itemId] = value[2]
        else
          cost[itemId] = cost[itemId] + value[2]
        end
      end
    end
  end
  return cost
end

function WeaponSkillVM:GetSkillUpRedId(skillId)
  return "WeaponSkillUpRed" .. skillId
end

function WeaponSkillVM:GetSkillRemouldRedId(skillId)
  return "WeaponSkillRemould" .. skillId
end

function WeaponSkillVM:GetSkillUnlockRedId(skillId)
  return "WeaponSkillUnlock" .. skillId
end

function WeaponSkillVM:GetSlotEquipRedId(slotId)
  return "WeaponSlotEquip" .. slotId
end

function WeaponSkillVM:GetSkillEquipRedId(skillId)
  return "WeaponSkillEquip" .. skillId
end

function WeaponSkillVM:CheckSkillCanUnlock(skillId)
  local itemVm = Z.VMMgr.GetVM("items")
  local canUnlock = false
  if not self:CheckSkillUnlock(skillId) then
    local upgradeId = self:GetSkillUpgradeId(skillId)
    local skillLevelConfig = self:GetLevelUpSkilllRow(upgradeId, 1)
    if skillLevelConfig then
      local itemEnough = true
      for _, cost in ipairs(skillLevelConfig.Cost) do
        if itemVm.GetItemTotalCount(cost[1]) < cost[2] then
          itemEnough = false
        end
      end
      local condition = Z.ConditionHelper.CheckCondition(skillLevelConfig.UnlockConditions, false)
      if itemEnough and condition then
        canUnlock = true
      end
    end
  end
  return canUnlock
end

function WeaponSkillVM:GetSkillCanLevelMax(skillId, curSkillLevel, ingoreTips)
  local itemVm = Z.VMMgr.GetVM("items")
  local ret = curSkillLevel
  local costItem = {}
  local upgradeId = self:GetSkillUpgradeId(skillId)
  local skillLevelData = self:GetlevelUpDataBySKillUpgradeId(upgradeId)
  for i = curSkillLevel + 1, table.zcount(skillLevelData) do
    for _, value in ipairs(skillLevelData[i].Cost) do
      local itemId = value[1]
      if costItem[itemId] == nil then
        costItem[itemId] = 0
      end
      costItem[itemId] = costItem[itemId] + value[2]
      if itemVm.GetItemTotalCount(itemId) < costItem[itemId] then
        ret = i - 1
        return ret, 100002
      end
    end
    if not Z.ConditionHelper.CheckCondition(skillLevelData[i].UnlockConditions, not ingoreTips) then
      ret = i - 1
      return ret
    end
    ret = i
  end
  return ret
end

function WeaponSkillVM:CheckIsSkillMaxLevel(skillId, curSkillLevel, ingoreTips)
  if curSkillLevel == nil then
    if not ingoreTips then
      Z.TipsVM.ShowTipsLang(130033)
    end
    return true
  end
  local skillConfig = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  if skillConfig == nil then
    if not ingoreTips then
      Z.TipsVM.ShowTipsLang(130033)
    end
    return true
  end
  local maxLevel, tipsId = self:GetSkillCanLevelMax(skillId, curSkillLevel, ingoreTips)
  if curSkillLevel >= maxLevel then
    if not ingoreTips and tipsId then
      Z.TipsVM.ShowTipsLang(tipsId)
    end
    return true
  end
  return false
end

function WeaponSkillVM:CheckIsAchievementSkillConditions(skillId, curSkillLevel, showTips)
  local upgradeId = self:GetSkillUpgradeId(skillId)
  local skillLevelData = self:GetLevelUpSkilllRow(upgradeId, curSkillLevel)
  if skillLevelData == nil then
    return true
  end
  for _, value in ipairs(skillLevelData.UnlockConditions) do
    if not Z.ConditionHelper.CheckSingleCondition(value[1], showTips, value[2]) then
      return false, value
    end
  end
  return true
end

function WeaponSkillVM:GetSkillMaxlevel(skillId)
  local skillLevelRow = self:GetSkillFightDataById(skillId)
  return #skillLevelRow
end

function WeaponSkillVM:GetKeyCodeNameBySkillId(skillId)
  local slotId = self:GetSlotIdBySkillId(skillId)
  if 0 < slotId then
    local slotConfig = Z.TableMgr.GetRow("SkillSlotPositionTableMgr", slotId)
    if slotConfig then
      local keyId = slotConfig.KeyPositionId
      local keyVM = Z.VMMgr.GetVM("setting_key")
      local keyCode = keyVM.GetKeyCodeListByKeyId(keyId)[1]
      if keyCode then
        local contrastRow = Z.TableMgr.GetRow("SetKeyboardContrastTableMgr", keyCode)
        if contrastRow then
          if contrastRow.ShowType == 0 then
            return contrastRow.Keyboard, nil
          else
            return "", contrastRow.ImageWay
          end
        end
      end
    end
  end
  return "", nil
end

function WeaponSkillVM:GetSkillUpgradeId(skillId)
  local skillSystemRow = Z.TableMgr.GetTable("SkillSystemTableMgr").GetRow(skillId)
  if skillSystemRow then
    return skillSystemRow.UpgradeId
  end
end

function WeaponSkillVM:GetParentTag(tagID)
  local tagTab = Z.TableMgr.GetTable("BdTagTableMgr").GetRow(tagID)
  local l_ret = {}
  if tagTab then
    if tagTab.ParentTag == nil or tagTab.ParentTag == 0 then
      return l_ret
    end
    table.insert(l_ret, tagTab.ParentTag)
    local l_parentTbl_ = self:GetParentTag(tagTab.ParentTag)
    for _, value in ipairs(l_parentTbl_) do
      table.insert(l_ret, value)
    end
  end
  return l_ret
end

function WeaponSkillVM:GetSkillAllTag(skillID)
  local skillFightData = self:GetSkillFightDataById(skillID)
  local l_ret = {}
  for _, skillFightData in ipairs(skillFightData) do
    local skillEffectTbl = Z.TableMgr.GetTable("SkillEffectTableMgr").GetRow(skillFightData.SkillEffectId)
    if skillEffectTbl ~= nil then
      for __, tag in ipairs(skillEffectTbl.Tags) do
        table.insert(l_ret, tag)
      end
    end
  end
  return table.zunique(l_ret)
end

function WeaponSkillVM:GetParentTagTable(tagID)
  local tagTab = Z.TableMgr.GetTable("BdTagTableMgr").GetRow(tagID)
  local ret = {}
  if tagTab then
    table.insert(ret, tagTab)
    if tagTab.ParentTag == nil or tagTab.ParentTag == 0 then
      return ret
    end
    local l_parentTbl_ = self:GetParentTag(tagTab.ParentTag)
    for _, value in ipairs(l_parentTbl_) do
      table.insert(ret, value)
    end
  end
  return ret
end

function WeaponSkillVM:GetSkillAllTagTableList(skillID)
  local skillFightData = self:GetSkillFightDataById(skillID)
  local ret = {}
  local index = 1
  local tagsList = {}
  for _, skillFightData in ipairs(skillFightData) do
    local skillEffectTbl = Z.TableMgr.GetTable("SkillEffectTableMgr").GetRow(skillFightData.SkillEffectId)
    if skillEffectTbl ~= nil then
      for _, tag in ipairs(skillEffectTbl.Tags) do
        if not table.zcontains(tagsList, tag) then
          local tagList = {}
          local tagTab = Z.TableMgr.GetTable("BdTagTableMgr").GetRow(tag)
          if tagTab ~= nil then
            table.insert(tagList, tagTab)
            if tagTab.ParentTag ~= nil and tagTab.ParentTag ~= 0 then
              local tmpTab = self:GetParentTagTable(tagTab.ParentTag)
              for ___, value in ipairs(tmpTab) do
                table.insert(tagList, value)
              end
            end
          end
          ret[index] = tagList
          table.insert(tagsList, tag)
          index = index + 1
        end
      end
    end
  end
  return ret
end

return WeaponSkillVM
