local ret = {}
local skillEffectTableMgr = Z.TableMgr.GetTable("SkillEffectTableMgr")
local skillFightLevelTableMgr = Z.TableMgr.GetTable("SkillFightLevelTableMgr")
local numberTools = require("utility.number_tools")
ret.numberFormFuncDic = {
  mn = numberTools.MakeNormalFormat,
  un = numberTools.DefaultFormat,
  mp = numberTools.MarkAndPercentFormat,
  up = numberTools.UnMarkAndPercentFormat,
  mt = numberTools.MarkAndSecFormat,
  ut = numberTools.UnMarkAndSecFormat
}

function ret.GetSkillDecs(skillFightLevelId, remodelLevel, isResonanceSkill)
  if skillFightLevelId == nil then
    return nil
  end
  local skillFightLevelTableRow = skillFightLevelTableMgr.GetRow(skillFightLevelId)
  if skillFightLevelTableRow == nil then
    return nil
  end
  local skilleffectTableRow = skillEffectTableMgr.GetRow(skillFightLevelTableRow.SkillEffectId)
  if skilleffectTableRow == nil then
    return nil
  end
  local starTableRow
  local weaponSkillVm = Z.VMMgr.GetVM("weapon_skill")
  local skillId = math.floor(skillFightLevelId / 100)
  remodelLevel = remodelLevel or 0
  if 0 < remodelLevel then
    if isResonanceSkill then
      starTableRow = weaponSkillVm:GetResonanceSkillRemodelRow(skillId, remodelLevel)
    else
      starTableRow = weaponSkillVm:GetSkillRemodelRow(skillId, remodelLevel)
    end
  elseif isResonanceSkill then
    starTableRow = Z.TableMgr.GetRow("SkillAoyiTableMgr", skillId)
  end
  local skillParameter = ret.merageFloatParam(skillFightLevelTableRow, starTableRow)
  local param = {
    skillpara = {
      effect = function(floatParamName, formatType)
        if floatParamName == nil then
          return nil
        end
        local numStr = skillParameter[floatParamName]
        if numStr == nil then
          local error = string.zconcat("SkillFightLevelTable \232\161\168FloatParam\230\178\161\230\156\137\230\137\190\229\136\176:", floatParamName, " Id \228\184\186", skillFightLevelId)
          logError(error)
          return nil
        end
        local str = ret.formatFloatParam(numStr, formatType)
        return str
      end,
      damage = function(damageId, tableHeardName, formatType)
        local damageAttrTableMgr = Z.TableMgr.GetTable("DamageAttrTableMgr")
        local damageAttrTableRow = damageAttrTableMgr.GetRow(damageId)
        if damageAttrTableRow == nil then
          return ""
        end
        if tableHeardName == nil or tableHeardName == "" then
          logError("[Skill] Skill.Damage() \231\154\132\232\161\168\229\164\180\228\184\141\230\173\163\231\161\174,damageId :" .. damageId)
          return ""
        end
        local maxLevel = #damageAttrTableRow[tableHeardName]
        local level = skillFightLevelTableRow.Level or 1
        if tableHeardName == "PVEDamageRadio" then
          if remodelLevel <= 0 then
            level = 1
          end
          if starTableRow and starTableRow.TransformationType then
            for _, value in ipairs(starTableRow.TransformationType) do
              if value[1] == E.RemodelInfoType.SkillDamageMultiple then
                level = value[3] + 1
              end
            end
          end
        end
        if maxLevel < level then
          level = maxLevel
        end
        local num = damageAttrTableRow[tableHeardName][level]
        local str = ret.formatFloatParam(num, formatType)
        return str
      end,
      damageMerge = function(damageIdList, multiples, tableHeardName, formatType)
        local num = 0
        for index, damageId in ipairs(damageIdList) do
          local damageAttrTableMgr = Z.TableMgr.GetTable("DamageAttrTableMgr")
          local damageAttrTableRow = damageAttrTableMgr.GetRow(damageId)
          if damageAttrTableRow == nil then
            return ""
          end
          if tableHeardName == nil or tableHeardName == "" then
            logError("[Skill] Skill.Damage() \231\154\132\232\161\168\229\164\180\228\184\141\230\173\163\231\161\174,damageId :" .. damageId)
            return ""
          end
          local maxLevel = #damageAttrTableRow[tableHeardName]
          local level = skillFightLevelTableRow.Level or 1
          if tableHeardName == "PVEDamageRadio" then
            if remodelLevel <= 0 then
              level = 1
            end
            if starTableRow and starTableRow.TransformationType then
              for _, value in ipairs(starTableRow.TransformationType) do
                if value[1] == E.RemodelInfoType.SkillDamageMultiple then
                  level = value[3] + 1
                end
              end
            end
          end
          if maxLevel < level then
            level = maxLevel
          end
          local multiple = multiples[index]
          if multiple == nil then
            logError("[Skill] SkillEffect() \231\154\132\229\144\136\229\185\182\229\143\130\230\149\176\229\128\141\230\149\176\228\184\141\229\140\185\233\133\141")
            return ""
          end
          num = num + damageAttrTableRow[tableHeardName][level] * multiple
        end
        local str = ret.formatFloatParam(num, formatType)
        return str
      end,
      effectcd = function()
        local reduceNumber = 0
        if starTableRow and starTableRow.TransformationType then
          for _, value in ipairs(starTableRow.TransformationType) do
            if value[1] == E.RemodelInfoType.ReduceSkillCD then
              reduceNumber = value[3] / 1000
            end
          end
        end
        local cd = Lang("Seconds", {
          val = tostring(skillFightLevelTableRow.PVECoolTime - reduceNumber):gsub("%.0+$", "")
        })
        return cd
      end,
      chargetime = function()
        local reduceNumber = 0
        if starTableRow and starTableRow.TransformationType then
          for _, value in ipairs(starTableRow.TransformationType) do
            if value[1] == E.RemodelInfoType.ReduceSkillCharge then
              reduceNumber = value[3]
            end
          end
        end
        local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
        if skillRow == nil then
          return ""
        end
        return Lang("Seconds", {
          val = tostring((skillRow.EnergyChargeTime - reduceNumber) / 1000):gsub("%.0+$", "")
        })
      end
    }
  }
  local skillAttrDes = skilleffectTableRow.SkillAttrDes
  if skillAttrDes == nil or skillAttrDes == nil or #skillAttrDes < 1 then
    return nil
  end
  local tab = {}
  for _, attrDes in ipairs(skillAttrDes) do
    if #attrDes ~= 2 then
      logError("SkillEffectTable \232\161\168 SkillAttrDes \233\133\141\231\189\174\233\148\153\232\175\175,ID\228\184\186:" .. skilleffectTableRow.Id)
    end
    local des = {}
    des.Dec = attrDes[1]
    local effect = attrDes[2]
    des.Num = Z.Placeholder.Placeholder(effect, param)
    table.insert(tab, des)
  end
  return tab
end

function ret.merageFloatParam(skillFightLevelTableRow, weaponStarTableRow)
  local fightParamter = {}
  if skillFightLevelTableRow ~= nil and skillFightLevelTableRow.FloatParameter ~= nil then
    fightParamter = ret.getFloatParma(skillFightLevelTableRow.FloatParameter)
  end
  local weaponParamter
  if weaponStarTableRow ~= nil and weaponStarTableRow.FloatParameter ~= nil then
    weaponParamter = ret.getFloatParma(weaponStarTableRow.FloatParameter)
  end
  if weaponParamter == nil or next(weaponParamter) == nil then
    return fightParamter
  end
  for key, value in pairs(weaponParamter) do
    local fightParamterValue = fightParamter[key]
    if fightParamterValue ~= nil then
      fightParamter[key] = fightParamterValue + value
    else
      fightParamter[key] = value
    end
  end
  return fightParamter
end

function ret.getFloatParma(floatParams)
  local parameter = {}
  if floatParams == nil then
    return parameter
  end
  for _, value in ipairs(floatParams) do
    if value ~= nil and value ~= nil and #value == 2 then
      local arr = value
      parameter[arr[1]] = arr[2]
    end
  end
  return parameter
end

function ret.formatFloatParam(paramNum, formatType)
  if paramNum == nil then
    return nil
  end
  if formatType == nil then
    formatType = "un"
  end
  local fun = ret.numberFormFuncDic[formatType]
  if fun == nil then
    fun = ret.numberFormFuncDic.un
  end
  if paramNum == nil then
    return nil
  end
  local num
  if type(paramNum) == "string" then
    num = tonumber(paramNum)
  else
    num = paramNum
  end
  return fun(num)
end

function ret.GetEffectDescNotParse(skillFightLevelId)
  if skillFightLevelId == nil then
    return ""
  end
  local skillFightLevelTableRow = skillFightLevelTableMgr.GetRow(skillFightLevelId)
  if skillFightLevelTableRow == nil then
    return ""
  end
  local skilleffectTableRow = skillEffectTableMgr.GetRow(skillFightLevelTableRow.SkillEffectId)
  if skilleffectTableRow == nil then
    return ""
  end
  local skillAttrDes = skilleffectTableRow.SkillAttrDes
  if skillAttrDes == nil or skillAttrDes == nil then
    return ""
  end
  local descArray = skillAttrDes[1]
  if descArray == nil or descArray == nil then
    return ""
  end
  return descArray[1]
end

local skillFightLevelDic = {}

function ret.CacheSKillFightLevelTable()
  local skillFightLevelTable = Z.TableMgr.GetTable("SkillFightLevelTableMgr").GetDatas()
  for _, skillData in pairs(skillFightLevelTable) do
    if skillFightLevelDic[skillData.SkillId] == nil then
      skillFightLevelDic[skillData.SkillId] = {}
    end
    skillFightLevelDic[skillData.SkillId][skillData.Level] = skillData
  end
end

function ret.GetSkillFightDataListById(skillId)
  return skillFightLevelDic[skillId] or {}
end

function ret.CheckSkillMaxByFightId(skillFightLevelId)
  local skillData = skillFightLevelTableMgr.GetRow(skillFightLevelId)
  if skillData == nil then
    return true
  end
  local lstLevel = ret.GetSkillFightDataListById(skillData.SkillId)
  if next(lstLevel) ~= nil then
    local maxSkillData = lstLevel[#lstLevel]
    return maxSkillData.Id == skillFightLevelId
  else
    return true
  end
end

function ret.GetSkillFightData(skillFightLevelId)
  local skillData = skillFightLevelTableMgr.GetRow(skillFightLevelId)
  return skillData
end

function ret.GetNextSkillFightData(skillFightLevelId)
  local lstLevel = ret.GetSkillFightDataListById(skillFightLevelId)
  local skillData = skillFightLevelTableMgr.GetRow(skillFightLevelId)
  local nextSkillLevel = skillData.Level + 1
  return lstLevel[nextSkillLevel]
end

function ret.GetPlayerCommonSkillInfo()
  local skillInfo = {}
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return skillInfo
  end
  local skillList = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrCommonSkillList"))
  if skillList then
    local count = skillList.Value.count
    for i = 0, count - 1 do
      local skillFightLevelId = skillList.Value[i]
      local skillId = math.floor(skillFightLevelId / 100)
      local skillLv = skillFightLevelId - skillId * 100
      skillInfo[skillId] = {skillFightLevelId = skillFightLevelId, skillLv = skillLv}
    end
  end
  return skillInfo
end

function ret.GetSkillIdbySlotId(slotId)
  local slots = Z.ContainerMgr.slots.slots
  if slots == nil then
    return 0
  end
  if slots[slotId] == nil then
    return 0
  end
  return slots[slotId].skillId
end

function ret.ContrastSkillDecs(preSkillDes, nowSkillDes)
  if preSkillDes == nil or nowSkillDes == nil then
    return nowSkillDes
  end
  local preSkillDict_ = {}
  for _, value in ipairs(preSkillDes) do
    preSkillDict_[value.Dec] = value.Num
  end
  for _, value in ipairs(nowSkillDes) do
    if preSkillDict_[value.Dec] then
      local preNums = {}
      for number in string.gmatch(preSkillDict_[value.Dec], "%d+%.?%d*%%?") do
        table.insert(preNums, number)
      end
      local nowNums = {}
      for number in string.gmatch(value.Num, "%d+%.?%d*%%?") do
        table.insert(nowNums, number)
      end
      for _, number in ipairs(nowNums) do
        local str = string.gsub(number, "%%", "%%%%")
        value.Num = value.Num:gsub(str, "?rep ", 1, true)
      end
      for index, number in ipairs(nowNums) do
        local num1 = number:gsub("%%", "")
        local num2 = preNums[index]:gsub("%%", "")
        if tonumber(num1) ~= tonumber(num2) then
          value.Num = string.gsub(value.Num, "?rep ", Z.RichTextHelper.ApplyStyleTag(number, E.TextStyleTag.SkillNumChange):gsub("%%", "%%%%"), 1)
        else
          value.Num = string.gsub(value.Num, "?rep ", Z.RichTextHelper.ApplyStyleTag(number, E.TextStyleTag.SkillNum):gsub("%%", "%%%%"), 1)
        end
      end
    else
      value.Num = Z.RichTextHelper.ApplyStyleTag(value.Num, E.TextStyleTag.SkillNum)
    end
  end
  return nowSkillDes
end

function ret.GetSkillDecsWithColor(skillDes)
  if skillDes == nil then
    return skillDes
  end
  for _, value in ipairs(skillDes) do
    local preNums = {}
    for number in string.gmatch(value.Num, "%d+%.?%d*%%?") do
      table.insert(preNums, number)
    end
    for _, number in ipairs(preNums) do
      local str = string.gsub(number, "%%", "%%%%")
      value.Num = value.Num:gsub(str, "?rep ", 1, true)
    end
    for _, number in ipairs(preNums) do
      local replace = string.gsub(Z.RichTextHelper.ApplyStyleTag(number, E.TextStyleTag.SkillNum), "%%", "%%%%")
      value.Num = string.gsub(value.Num, "?rep ", replace, 1)
    end
  end
  return skillDes
end

return ret
