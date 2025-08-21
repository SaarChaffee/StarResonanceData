local cls = {}
local Data = Z.DataMgr.Get("season_cultivate_data")
local TALENT_DEFINE = require("ui.model.talent_define")
local itemVm = Z.VMMgr.GetVM("items")

function cls.OpenEffectPopupView()
  Z.UIMgr:OpenView("season_cultivate_effect_popup")
end

function cls.CloseEffectPopupView()
  Z.UIMgr:CloseView("season_cultivate_effect_popup")
end

function cls.GetAllNormalNodeInfo()
  local out = {}
  local holeInfos = Z.ContainerMgr.CharSerialize.seasonMedalInfo.normalHoleInfos
  for _, hole in pairs(holeInfos) do
    local config = cls.GetHoleConfigByLevel(hole.holeId, hole.holeLevel)
    if config then
      out[hole.holeId] = {}
      out[hole.holeId].holeConfig = config
      out[hole.holeId].attrConfig = cls.GetAttributeConfigByLevel(config.NodeId[1], config.HoleLevel)
      out[hole.holeId].curExp = hole.curExp
      out[hole.holeId].nodeLevel = hole.holeLevel
    end
  end
  return out
end

function cls.GetNormalNodeTotalLevel()
  local infos = cls.GetAllNormalNodeInfo()
  local level = 0
  for _, v in pairs(infos) do
    level = level + v.holeConfig.HoleLevel
  end
  return level
end

function cls.GetCoreNodeSlotInfoBySlotId(slotId)
  local coreAttributes = Z.ContainerMgr.CharSerialize.seasonMedalInfo.coreHoleNodeInfos
  if coreAttributes then
    for index, value in pairs(coreAttributes) do
      if value.choose and value.slot == slotId then
        return value
      end
    end
  end
  return nil
end

function cls.GetCoreNodeInfoByNodeId(nodeId)
  local coreAttributes = Z.ContainerMgr.CharSerialize.seasonMedalInfo.coreHoleNodeInfos
  if nodeId and coreAttributes[nodeId] then
    return coreAttributes[nodeId]
  end
end

function cls.CheckCoreAttrIsChooseByNodeId(nodeId)
  local nodeInfo = cls.GetCoreNodeInfoByNodeId(nodeId)
  if nodeInfo then
    return nodeInfo.choose
  end
  return false
end

function cls.GetCoreNodeInfo(onlyChoose)
  if onlyChoose == nil then
    onlyChoose = false
  end
  local coreInfo = Z.ContainerMgr.CharSerialize.seasonMedalInfo.coreHoleInfo
  if coreInfo.holeLevel <= 0 then
    return {}
  end
  local holeConfig = cls.GetHoleConfigByLevel(999, coreInfo.holeLevel)
  if not holeConfig then
    return {}
  end
  local out = {}
  local coreAttributes = Z.ContainerMgr.CharSerialize.seasonMedalInfo.coreHoleNodeInfos
  for _, attr in pairs(coreAttributes) do
    if not onlyChoose or attr.choose then
      local attrConfig = cls.GetAttributeConfigByLevel(attr.nodeId, attr.nodeLevel)
      if attrConfig then
        out[#out + 1] = {
          holeConfig = holeConfig,
          attrConfig = attrConfig,
          choose = attr.choose,
          slotId = attr.slot,
          nodeLevel = attr.nodeLevel
        }
      end
    end
  end
  return out
end

function cls.GetHoleExpInfo(holeId, addExp)
  local totalCanAddExp = cls.GetHoleExpTotalCanAdd(holeId)
  local totalExp = Mathf.Min(addExp + cls.GetHoleExpTotalCurrent(holeId), totalCanAddExp)
  for level, exp in pairs(Data.seasonHoleExp_[holeId]) do
    if exp > totalExp then
      return level - 1, totalExp, exp
    end
    totalExp = totalExp - exp
  end
  local maxLevel = cls.GetHoleMaxLevel(holeId)
  local maxExp = Data.seasonHoleExp_[holeId][maxLevel]
  return maxLevel, maxExp, maxExp
end

function cls.GetHoleExpTotalCanAdd(holeId)
  if not Data.seasonHoleExp_[holeId] then
    logError("\230\178\161\230\156\137\232\191\153\228\184\170\229\173\148\228\189\141\231\154\132\231\187\143\233\170\140\228\191\161\230\129\175 {0}", holeId)
    return 999
  end
  local canAdd = 0
  for level, exp in pairs(Data.seasonHoleExp_[holeId]) do
    canAdd = canAdd + exp
    if not cls.CheckUpgradeCondition(holeId, level) then
      canAdd = canAdd - 1
      break
    end
  end
  return Mathf.Max(canAdd, 0)
end

function cls.GetMaxLevelCanAddTo(holeId)
  if not Data.seasonHoleExp_[holeId] then
    logError("\230\178\161\230\156\137\232\191\153\228\184\170\229\173\148\228\189\141\231\154\132\231\187\143\233\170\140\228\191\161\230\129\175 {0}", holeId)
    return 0
  end
  for level, exp in pairs(Data.seasonHoleExp_[holeId]) do
    if not cls.CheckUpgradeCondition(holeId, level) then
      return level - 1
    end
  end
  return cls.GetHoleMaxLevel(holeId)
end

function cls.GetHoleExpTotalCurrent(holeId)
  local total = 0
  local holeInfo = Z.ContainerMgr.CharSerialize.seasonMedalInfo.normalHoleInfos[holeId]
  if holeInfo then
    for level, exp in pairs(Data.seasonHoleExp_[holeId]) do
      if level <= holeInfo.holeLevel then
        total = total + exp
      elseif level > holeInfo.holeLevel then
        total = total + holeInfo.curExp
        break
      end
    end
  end
  return total
end

function cls.CheckLevelCondition(config, isShowError)
  if not config then
    return true
  end
  for _, v in pairs(config.NodeCondition) do
    local type = v[1]
    local need = v[2]
    local current = 0
    if type == 1 then
      current = cls.GetNormalNodeTotalLevel()
    else
      current = cls.GetCoreNodeLevel()
    end
    if need > current then
      if isShowError then
        Z.TipsVM.ShowTips(124013, {val = need})
      end
      return false
    end
  end
end

function cls.CheckCondition(config, isShowError)
  if not config then
    return true
  end
  return Z.ConditionHelper.CheckCondition(config.Condition, isShowError)
end

function cls.CheckUpgradeCondition(holeId, holeLevel, isShowError)
  local config = cls.GetHoleConfigByLevel(holeId, holeLevel)
  local condition = cls.CheckCondition(config, isShowError)
  if condition == false then
    return false
  end
  local levelCondition = cls.CheckLevelCondition(config, isShowError)
  if levelCondition == false then
    return false
  end
  return true
end

function cls.GetCoreNodeLevel()
  return Z.ContainerMgr.CharSerialize.seasonMedalInfo.coreHoleInfo.holeLevel
end

function cls.TryClick(time)
  if not cls.lastClick_ then
    cls.lastClick_ = 0
  end
  time = time or 500
  local current = Z.ServerTime:GetServerTime()
  if time <= current - cls.lastClick_ then
    cls.lastClick_ = current
    return true
  end
  return false
end

function cls.GetCoreAttrChooseCount()
  local coreLevel = Z.ContainerMgr.CharSerialize.seasonMedalInfo.coreHoleInfo.holeLevel
  if coreLevel <= 0 then
    return 0, 0
  end
  local limit = Z.Global.EffectiveNodeNum
  if limit then
    local coreAttributes = Z.ContainerMgr.CharSerialize.seasonMedalInfo.coreHoleNodeInfos
    local chooseCount = 0
    for _, v in pairs(coreAttributes) do
      if v.choose then
        chooseCount = chooseCount + 1
      end
    end
    return chooseCount, cls.GetCoreAttrCanChooseCount(coreLevel)
  end
  logError("GetCoreAttrChooseCount \229\188\130\229\184\184")
  return 999, 999
end

function cls.GetCoreAttrCanChooseCount(level)
  local limit = Z.Global.EffectiveNodeNum
  if limit then
    for _, v in pairs(limit) do
      if level <= v[1] then
        return v[2]
      end
    end
  end
  return 0
end

function cls.GetCoreEffectiveNodeData()
  local limit = Z.Global.EffectiveNodeNum
  local data = {}
  local maxCount = 0
  if limit then
    for i = #limit, 1, -1 do
      local count = limit[i][2]
      if maxCount < count then
        maxCount = count
      end
      data[i] = limit[i - 1] and limit[i - 1][1] or 0
    end
  end
  return data, maxCount
end

function cls.GetNowCanSelectedCoreCount()
  local limit = Z.Global.EffectiveNodeNum
  local curCoreLevel = cls.GetCoreNodeLevel()
  if curCoreLevel == 0 then
    return 0
  end
  return cls.GetCoreAttrCanChooseCount(curCoreLevel)
end

function cls.GetHoleConfigByLevel(holeId, level)
  if Data.seasonHoles_[holeId] and Data.seasonHoles_[holeId][level] then
    return Data.seasonHoles_[holeId][level]
  end
  logError("\230\156\137\232\191\153\228\184\170\229\173\148\228\189\141\229\144\151\228\189\160\229\176\177\229\156\168\232\191\153\232\142\183\229\143\150\239\188\159{0} Lv.{1}", holeId, level)
  return nil
end

function cls.GetAttributeConfigByLevel(nodeId, level)
  if Data.seasonAttributes_[nodeId] and Data.seasonAttributes_[nodeId][level] then
    return Data.seasonAttributes_[nodeId][level]
  end
  logError("\230\156\137\232\191\153\228\184\170\229\177\158\230\128\167\229\144\151\228\189\160\229\176\177\229\156\168\232\191\153\232\142\183\229\143\150\239\188\159{0} Lv.{1}", nodeId, level)
  return nil
end

function cls.GetHoleMaxLevel(holeId)
  if Data.seasonHoleMaxLevel_[holeId] then
    return Data.seasonHoleMaxLevel_[holeId]
  end
  logError("\230\156\137\232\191\153\228\184\170\229\173\148\228\189\141\229\144\151\228\189\160\229\176\177\229\156\168\232\191\153\232\142\183\229\143\150\239\188\159{0}", holeId)
  return 0
end

function cls.GetAttributeDes(attrId)
  local config = Z.TableMgr.GetTable("SeasonNodeDataTableMgr").GetRow(attrId)
  if config then
    local fightAttrParseVm = Z.VMMgr.GetVM("fight_attr_parse")
    local skillVm = Z.VMMgr.GetVM("skill")
    local buffAttrParseVM = Z.VMMgr.GetVM("buff_attr_parse")
    local basicAttrEffectTableMgr = Z.TableMgr.GetTable("BasicAttrEffectTableMgr")
    local value = config.NodeEffect[1]
    local type = value[1]
    if type == TALENT_DEFINE.TalentEffectType.Property then
      return fightAttrParseVm.ParseFightAttrTips(value[2], value[3])
    elseif type == TALENT_DEFINE.TalentEffectType.Skill then
      local weaponSkillVm = Z.VMMgr.GetVM("weapon_skill")
      local skillFightData = weaponSkillVm:GetSkillFightDataById(value[2])
      local skillFightLvTblData = skillFightData[value[3]]
      local remodelLevel = weaponSkillVm:GetSkillRemodelLevel(value[2])
      local skillDescList = skillVm.GetSkillDecs(skillFightLvTblData.Id, remodelLevel)
      if skillDescList then
        local lstResult = {}
        for index, descInfo in ipairs(skillDescList) do
          lstResult[index] = descInfo.Dec .. descInfo.Num
        end
        return table.concat(lstResult, "\n")
      end
    elseif type == TALENT_DEFINE.TalentEffectType.Buff then
      local param = {}
      for paramIndex, paramValue in ipairs(config.BuffPar[1]) do
        param[paramIndex] = {paramValue}
      end
      return buffAttrParseVM.ParseBufferTips(value[2], param)
    elseif type == TALENT_DEFINE.TalentEffectType.BasicAttrEffectCoefficient then
      return fightAttrParseVm.ParseTalentBasicAttrEffectTips(value[2], basicAttrEffectTableMgr)
    end
  end
  logError("GetAttributeDes \229\188\130\229\184\184")
  return ""
end

function cls.AsyncChooseCoreSeasonHoleNode(chosenNodeIds, cancelToken)
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.ChooseCoreSeasonHoleNode(chosenNodeIds, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  return true
end

function cls.AsyncResetNormalSeasonHoles(holeId, cancelToken)
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.ResetNormalSeasonHoles(holeId, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  return true
end

function cls.AsyncUpgradeSeasonCoreMedalHole(cancelToken)
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.UpgradeSeasonCoreMedalHole(999, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  return true
end

function cls.AsyncUpgradeSeasonNormalHole(holeId, itemNum, cancelToken)
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.UpgradeSeasonNormalHole(holeId, itemNum, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  return true
end

function cls.GetNodeEffectDes(config)
  if config == nil then
    return nil
  end
  local effectType = config.NodeEffect[1][1]
  local effectId = config.NodeEffect[1][2]
  local effectValue = config.NodeEffect[1][3]
  if effectType == TALENT_DEFINE.TalentEffectType.Property then
    local fightAttrParseVm = Z.VMMgr.GetVM("fight_attr_parse")
    local fightAttr = fightAttrParseVm.GetFightAttrTableRow(effectId)
    return effectType, fightAttr.OfficialName, fightAttrParseVm.ParseFightAttrNumber(effectId, effectValue)
  else
    return effectType, cls.GetAttributeDes(config.Id)
  end
end

function cls.GetNodeLevel(holeId)
  local holeInfo = Z.ContainerMgr.CharSerialize.seasonMedalInfo.normalHoleInfos[holeId]
  if holeInfo then
    return holeInfo.holeLevel
  end
  return 0
end

function cls.CheckCoreNodeCondition(condition)
  for i, v in pairs(condition) do
    local type = v[1]
    local need = v[2]
    local current = 0
    if type == 1 then
      current = cls.GetNormalNodeTotalLevel()
    else
      current = cls.GetCoreNodeLevel()
    end
    if need > current then
      return false
    end
  end
  return true
end

function cls.CheckCoreCondition(condition)
  local results = Z.ConditionHelper.GetConditionDescList(condition)
  for i, result in pairs(results) do
    if result.IsUnlock == false then
      return false
    end
  end
  return true
end

function cls.CheckCoreMoneyCoudition()
  local max = cls.GetHoleMaxLevel(E.SeasonCultivateHole.Core)
  local current = cls.GetCoreNodeLevel() + 1
  local hasNext = max > current
  if not hasNext then
    return false
  end
  local tempHole = cls.GetHoleConfigByLevel(E.SeasonCultivateHole.Core, current + 1)
  local moneyId = tempHole.NumberConsume[1][1]
  local needMoney = tempHole.NumberConsume[1][2]
  local hasMoney = itemVm.GetItemTotalCount(moneyId)
  if needMoney > hasMoney then
    return false
  end
end

function cls.CheckCoreItemCoudition()
  local current = cls.GetCoreNodeLevel() + 1
  local tempHole = cls.GetHoleConfigByLevel(E.SeasonCultivateHole.Core, current + 1)
  for i, v in pairs(tempHole.NumberConsume) do
    if i ~= 1 then
      local itemId = v[1]
      local needCount = v[2]
      local count = itemVm.GetItemTotalCount(itemId)
      if needCount > count then
        return false
      end
    end
  end
end

function cls.GetConditionDesc(condition)
  local results = Z.ConditionHelper.GetConditionDescList(condition)
  for i, result in pairs(results) do
    if result.tipsId == 124011 then
      result.Desc = Lang("SeasonNodeConditionRank", result.tipsParam)
    elseif result.tipsId == 124012 then
      result.Desc = Lang("SeasonNodeConditionOutside", result.tipsParam)
    elseif result.tipsId == 124013 then
      result.Desc = Lang("SeasonNodeConditionCore", result.tipsParam)
    elseif result.tipsId == 1004101 then
      result.Progress = ""
    elseif result.tipsId == 1500013 then
      result.Progress = ""
    end
  end
  return results
end

function cls.GetOutNodeRecommendFightValue()
  local point = 0
  local holeInfos = Z.ContainerMgr.CharSerialize.seasonMedalInfo.normalHoleInfos
  for _, hole in pairs(holeInfos) do
    local config = cls.GetHoleConfigByLevel(hole.holeId, hole.holeLevel)
    if config then
      local attrConfig = cls.GetAttributeConfigByLevel(config.NodeId[1], hole.holeLevel)
      if attrConfig then
        point = point + attrConfig.FightValue
      end
    end
  end
  return point
end

function cls.GetCoreNodeRecommendFightValue()
  local point = 0
  local _, maxSlotCount_ = cls.GetCoreEffectiveNodeData()
  for slotId = 1, maxSlotCount_ do
    local data = cls.GetCoreNodeSlotInfoBySlotId(slotId)
    if data then
      local cfgData = cls.GetAttributeConfigByLevel(data.nodeId, data.nodeLevel)
      if cfgData then
        point = point + cfgData.FightValue
      end
    end
  end
  return point
end

function cls.GetRecommendFightValue()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.SeasonCultivate, true)
  if not isOn then
    return 0
  end
  local pointOut = cls.GetOutNodeRecommendFightValue()
  local pointCore = cls.GetCoreNodeRecommendFightValue()
  return pointCore + pointOut
end

return cls
