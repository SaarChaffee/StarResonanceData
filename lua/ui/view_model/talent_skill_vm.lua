local TalentSkillVM = {}
local worldProxy = require("zproxy.world_proxy")
local TalentSkillDefine = require("ui.model.talent_skill_define")

function TalentSkillVM.OpenTalentSkillMainWindow(professionId, skillId)
  if professionId == nil then
    local weaponVm = Z.VMMgr.GetVM("weapon")
    professionId = weaponVm.GetCurWeapon()
  end
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  if funcVm.CheckFuncCanUse(E.FunctionID.Talent) then
    Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Explore_04, "talent_skill_window", function()
      Z.UIMgr:PreloadAsset(TalentSkillDefine.TalentWindowCharacerLeftRimg .. professionId, E.EPreloadTypeEnum.ETexture)
      Z.UIMgr:PreloadAsset(TalentSkillDefine.TalentWindowCharacerRightRimg .. professionId, E.EPreloadTypeEnum.ETexture)
      Z.UIMgr:OpenView("talent_skill_window", {professionId = professionId, skillId = skillId})
    end)
  end
end

function TalentSkillVM.GetCurTalentTagId()
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local professionId = weaponVm.GetCurWeapon()
  local weaponSystemTableBase = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
  if weaponSystemTableBase then
    return weaponSystemTableBase.Talent[1]
  end
  return 0
end

function TalentSkillVM.GetWeaponnTalentTagIcon(professionId)
  if professionId == nil then
    local weaponVm = Z.VMMgr.GetVM("weapon")
    professionId = weaponVm.GetCurWeapon()
  end
  local weaponSystemTableBase = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
  if weaponSystemTableBase then
    local talent = weaponSystemTableBase.Talent
    local talentTagTableRow = Z.TableMgr.GetTable("TalentTagTableMgr").GetRow(talent)
    return talentTagTableRow.TagIconMark
  end
  return nil
end

function TalentSkillVM.GetUnlockTalentBD(professionId)
  local bd = 0
  local talentList = Z.ContainerMgr.CharSerialize.professionList.talentList[professionId]
  if talentList then
    for _, value in ipairs(talentList.talentNodeIds) do
      local talentTreeTableConfig = Z.TableMgr.GetTable("TalentTreeTableMgr").GetRow(value)
      if talentTreeTableConfig.BdType ~= 0 then
        bd = talentTreeTableConfig.BdType
        break
      end
    end
  end
  return bd
end

function TalentSkillVM.CheckTalentIsUnlock(professionId, talentTreeId)
  local talentTreeTableConfig = Z.TableMgr.GetTable("TalentTreeTableMgr").GetRow(talentTreeId)
  if talentTreeTableConfig.PreTalent and #talentTreeTableConfig.PreTalent > 0 then
    for _, treeId in pairs(talentTreeTableConfig.PreTalent) do
      if TalentSkillVM.CheckTalentIsActive(professionId, treeId) then
        return true
      end
    end
  else
    return true
  end
  return false
end

function TalentSkillVM.CheckTalentIsActive(professionId, talentTreeId)
  local talentList = Z.ContainerMgr.CharSerialize.professionList.talentList[professionId]
  if talentList then
    for _, value in ipairs(talentList.talentNodeIds) do
      if talentTreeId == value then
        return true
      end
    end
  end
  return false
end

function TalentSkillVM.GetWeaponActiveTalentTreeNode(professionId)
  return Z.ContainerMgr.CharSerialize.professionList.talentList[professionId]
end

function TalentSkillVM.CheckSkillIsUnLock(professionId, skillId)
  local pos = 1
  local weaponSystemTable = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
  for _, value in ipairs(weaponSystemTable.SkillTalentPosition) do
    if 2 <= #value and value[2] == skillId then
      pos = value[1]
      break
    end
  end
  if pos == 1 then
    return true
  else
    local frontSkill = -1
    for _, value in ipairs(weaponSystemTable.SkillTalentPosition) do
      if 2 <= #value and value[1] == pos - 1 then
        frontSkill = value[2]
        break
      end
    end
    if TalentSkillVM.CheckSkillIsActive(professionId, frontSkill) then
      return true
    else
      return false
    end
  end
end

function TalentSkillVM.CheckSkillIsActive(professionId, skillId)
  local weaponInfo = Z.ContainerMgr.CharSerialize.professionList.professionList[professionId]
  if weaponInfo and weaponInfo.activeSkillIds then
    for _, value in ipairs(weaponInfo.activeSkillIds) do
      if value == skillId then
        return true
      end
    end
  end
  return false
end

function TalentSkillVM.CheckCurTalentBDType()
  local professionId = Z.VMMgr.GetVM("profession").GetContainerProfession()
  local talentStageTable = Z.TableMgr.GetTable("TalentStageTableMgr").GetDatas()
  for _, value in pairs(talentStageTable) do
    if value.WeaponType == professionId and value.TalentStage == TalentSkillDefine.TalentTreeMaxStage - 1 and TalentSkillVM.CheckTalentIsActive(professionId, value.RootId) then
      return value.BdType
    end
  end
  return 0
end

function TalentSkillVM.GetCurWeaponUseTalentPoint(professionId)
  if professionId == nil then
    local weaponVm = Z.VMMgr.GetVM("weapon")
    professionId = weaponVm.GetCurWeapon()
  end
  local talentlist = Z.ContainerMgr.CharSerialize.professionList.talentList[professionId]
  if talentlist then
    return talentlist.usedTalentPoints
  end
  return 0
end

function TalentSkillVM.GetTotalTalentResetCount()
  return Z.ContainerMgr.CharSerialize.professionList.totalTalentResetCount
end

function TalentSkillVM.GetSurpluseTalentPointCount(professionId)
  local allPoint = TalentSkillVM.GetAllTalentPointCount()
  local talentList = Z.ContainerMgr.CharSerialize.professionList.talentList[professionId]
  if talentList then
    return allPoint - talentList.usedTalentPoints
  end
  return allPoint
end

function TalentSkillVM.GetAllTalentPointCount()
  return Z.ContainerMgr.CharSerialize.professionList.totalTalentPoints
end

function TalentSkillVM.GetUseTalentPointCount(professionId)
  local talentList = Z.ContainerMgr.CharSerialize.professionList.talentList[professionId]
  if talentList then
    return talentList.usedTalentPoints
  end
  return 0
end

function TalentSkillVM.ParseTalentEffectDesc(id)
  local fightAttrParseVm = Z.VMMgr.GetVM("fight_attr_parse")
  local buffAttrParseVM = Z.VMMgr.GetVM("buff_attr_parse")
  local tempAttrParamVM = Z.VMMgr.GetVM("temp_attr_parse")
  local basicAttrEffectTableMgr = Z.TableMgr.GetTable("BasicAttrEffectTableMgr")
  local talentInfo = Z.TableMgr.GetTable("TalentTableMgr").GetRow(id)
  local effectList = {}
  local buffIndex = 0
  for _, value in ipairs(talentInfo.TalentEffect) do
    local type = value[1]
    if type == TalentSkillDefine.TalentTreeUnitEffectType.Basic then
      local attrDesc = fightAttrParseVm.ParseFightAttrTips(value[2], value[3])
      if attrDesc then
        table.insert(effectList, attrDesc)
      end
    elseif type == TalentSkillDefine.TalentTreeUnitEffectType.Buff then
      buffIndex = buffIndex + 1
      local param = {}
      local paramArray = talentInfo.BuffPar[buffIndex]
      if paramArray then
        for paramIndex, paramValue in ipairs(paramArray) do
          param[paramIndex] = {paramValue}
        end
      end
      table.insert(effectList, buffAttrParseVM.ParseBufferTips(value[2], param))
    elseif type == TalentSkillDefine.TalentTreeUnitEffectType.BasicAttrEffectCoefficient then
      table.insert(effectList, talentInfo.TalentDes)
    elseif type == TalentSkillDefine.TalentTreeUnitEffectType.TempBasic then
      local desc = tempAttrParamVM.ParamTempAttr(value[2], value[3])
      table.insert(effectList, desc)
    elseif type == TalentSkillDefine.TalentTreeUnitEffectType.ReplaceSpecialAttack then
      table.insert(effectList, talentInfo.TalentDes)
    end
  end
  return table.concat(effectList, "\n")
end

function TalentSkillVM.CheckWeaponRed()
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  if not funcVm.FuncIsOn(E.FunctionID.Talent, true) then
    return false
  end
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  if not funcVm.FuncIsOn(E.FunctionID.ProfessionLv, true) then
    return false
  end
  if not TalentSkillVM.IsCanShowRedDot() then
    return false
  end
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local professionId = weaponVm.GetCurWeapon()
  return weaponVm.CheckWeaponUp(professionId)
end

function TalentSkillVM.CheckTalentTreeRed()
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  if not funcVm.FuncIsOn(E.FunctionID.Talent, true) then
    return false
  end
  local talentSkillData = Z.DataMgr.Get("talent_skill_data")
  talentSkillData:RefreshCurUnActiveUnlockTalentTreeNodes()
  local nodes = talentSkillData:GetCurUnActiveUnlockTalentTreeNodes()
  return 0 < #nodes
end

function TalentSkillVM.CheckRed()
  return TalentSkillVM.CheckWeaponRed()
end

function TalentSkillVM.IsCanShowRedDot()
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local professionId = weaponVm.GetCurWeapon()
  local weaponInfo = weaponVm.GetWeaponInfo(professionId)
  return weaponInfo.level < Z.Global.TalentRedDotLevelLimit
end

function TalentSkillVM.CheckTalentNodeIsSpecialNode(professionId, nodeId)
  local talentTreeConfig = Z.TableMgr.GetTable("TalentTreeTableMgr").GetRow(nodeId)
  local talentSkillData = Z.DataMgr.Get("talent_skill_data")
  local configs = talentSkillData:GetTalentStageConfigs(professionId, talentTreeConfig.TalentStage)
  local count = 0
  local isRoot = false
  for _, v in pairs(configs) do
    count = count + 1
    if v.RootId == nodeId then
      isRoot = true
    end
  end
  return count ~= 1 and isRoot
end

function TalentSkillVM.CheckOtherSchoolIsChoose(professionId, nodeId)
  local talentTreeConfig = Z.TableMgr.GetTable("TalentTreeTableMgr").GetRow(nodeId)
  local talentSkillData = Z.DataMgr.Get("talent_skill_data")
  local configs = talentSkillData:GetTalentStageConfigs(professionId, talentTreeConfig.TalentStage)
  local count = 0
  local isRoot = false
  local otherIsActive = false
  for _, v in pairs(configs) do
    count = count + 1
    if v.RootId == nodeId then
      isRoot = true
    elseif TalentSkillVM.CheckTalentIsActive(professionId, v.RootId) then
      otherIsActive = true
    end
  end
  return 1 < count and isRoot and otherIsActive
end

function TalentSkillVM.GetProfessionTalentStageBdType(professionId, stage, talentTreeId)
  local talentSkillData = Z.DataMgr.Get("talent_skill_data")
  local configs = talentSkillData:GetTalentStageConfigs(professionId, stage)
  local isRoot = false
  for _, v in pairs(configs) do
    if v.RootId == talentTreeId then
      isRoot = true
    end
    if TalentSkillVM.CheckTalentIsActive(professionId, v.RootId) then
      return v.BdType, isRoot
    end
  end
  return -1, isRoot
end

function TalentSkillVM.GetCurProfessionTalentStageName()
  local talentId = TalentSkillVM.GetCurProfessionTalentStage()
  local talenStageRow = Z.TableMgr.GetTable("TalentStageTableMgr").GetRow(talentId)
  if talenStageRow then
    if #talenStageRow.Name > 1 then
      return talenStageRow.Name[2]
    else
      return talenStageRow.Name[1]
    end
  end
  return ""
end

function TalentSkillVM.GetCurProfessionTalentStage()
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local professionId = weaponVm.GetCurWeapon()
  return TalentSkillVM.GetProfressionTalentStage(professionId)
end

function TalentSkillVM.GetProfressionTalentStage(professionId)
  local talentList = Z.ContainerMgr.CharSerialize.professionList.talentList[professionId]
  if talentList and talentList.talentStageCfgId and talentList.talentStageCfgId ~= 0 then
    return talentList.talentStageCfgId
  else
    local talentSkillData = Z.DataMgr.Get("talent_skill_data")
    local configs = talentSkillData:GetTalentStageConfigs(professionId, 0)
    if configs and configs[0] then
      return configs[0].Id
    end
    return 0
  end
end

local function recursionFindRoute(talentNodeId, talentTreeTableMgr, routes, activeTalentTreeNodes, routesIndex)
  if activeTalentTreeNodes[talentNodeId] ~= nil then
    return
  end
  table.insert(routes[routesIndex], talentNodeId)
  local talentTreeConfig = talentTreeTableMgr.GetRow(talentNodeId)
  if talentTreeConfig then
    local copyRoute = table.zclone(routes[routesIndex])
    local lockNodes = {}
    for _, preTalentNode in ipairs(talentTreeConfig.PreTalent) do
      if activeTalentTreeNodes[preTalentNode] == nil then
        table.insert(lockNodes, preTalentNode)
      end
    end
    local lockNodesCount = #lockNodes
    if lockNodesCount == 0 then
      return
    else
      if lockNodesCount ~= #talentTreeConfig.PreTalent then
        local route = table.zclone(copyRoute)
        table.insert(routes, route)
      end
      for index, nodeId in ipairs(lockNodes) do
        if index == 1 then
          recursionFindRoute(nodeId, talentTreeTableMgr, routes, activeTalentTreeNodes, routesIndex)
        else
          local route = table.zclone(copyRoute)
          table.insert(routes, route)
          recursionFindRoute(nodeId, talentTreeTableMgr, routes, activeTalentTreeNodes, #routes)
        end
      end
    end
  end
end

function TalentSkillVM.GetMinUnlockRoute(talentNodeId, showTips)
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local professionId = weaponVm.GetCurWeapon()
  local activeTalentTreeNodes = TalentSkillVM.GetWeaponActiveTalentTreeNode(professionId)
  local tempActiveTalentTreeNodes = {}
  if activeTalentTreeNodes and activeTalentTreeNodes.talentNodeIds then
    for _, nodes in ipairs(activeTalentTreeNodes.talentNodeIds) do
      tempActiveTalentTreeNodes[nodes] = nodes
    end
  end
  local talentTreeTableMgr = Z.TableMgr.GetTable("TalentTreeTableMgr")
  local routes = {
    [1] = {}
  }
  recursionFindRoute(talentNodeId, talentTreeTableMgr, routes, tempActiveTalentTreeNodes, 1)
  local minLength, minRouteIndex
  table.sort(routes, function(a, b)
    return #a < #b
  end)
  for index, route in ipairs(routes) do
    local routeLength = #route
    if minLength == nil then
      minLength = routeLength
      minRouteIndex = index
    elseif minLength == routeLength then
      if showTips then
        Z.TipsVM.ShowTipsLang(1042032)
      end
      return
    elseif routeLength < minLength then
      minLength = routeLength
      minRouteIndex = index
    end
  end
  local res = {}
  local isUseRecommendTalent = false
  if minRouteIndex ~= nil then
    local talentTableMgr = Z.TableMgr.GetTable("TalentTableMgr")
    local itemsVM = Z.VMMgr.GetVM("items")
    local useTalentPoint = TalentSkillVM.GetUseTalentPointCount(professionId)
    local allTalentPoint = TalentSkillVM.GetAllTalentPointCount()
    local tempUseItem = {}
    local tempUseTalentPoints = 0
    local minRoute = {}
    local quickUnlockTalentTreeConfig = talentTreeTableMgr.GetRow(talentNodeId)
    local talentSkillData = Z.DataMgr.Get("talent_skill_data")
    local talentStageConfig = talentSkillData:GetTalentStageConfigByTalentTreeConfig(quickUnlockTalentTreeConfig)
    if talentStageConfig == nil then
      return
    end
    if tempActiveTalentTreeNodes[talentStageConfig.RootId] == nil then
      for i = 0, talentStageConfig.TalentStage - 1 do
        local tempTalentStageConfig = talentSkillData:GetTalentStageConfigs(quickUnlockTalentTreeConfig.WeaponType, i)
        if tempTalentStageConfig and tempTalentStageConfig[0] then
          for _, id in ipairs(tempTalentStageConfig[0].RecommendTalent) do
            if tempActiveTalentTreeNodes[id] == nil then
              table.insert(minRoute, id)
            end
          end
          isUseRecommendTalent = true
        end
      end
    end
    for i = #routes[minRouteIndex], 1, -1 do
      table.insert(minRoute, routes[minRouteIndex][i])
    end
    for i = 1, #minRoute do
      local talentTreeConfig = talentTreeTableMgr.GetRow(minRoute[i])
      if talentTreeConfig then
        local isCanUnlock = true
        for _, nodeCondition in ipairs(talentTreeConfig.Unlock) do
          if nodeCondition[1] == E.ConditionType.UseTalentPoints then
            if useTalentPoint + tempUseTalentPoints < nodeCondition[2] then
              isCanUnlock = false
              break
            end
          else
            local params = {}
            if nodeCondition[2] then
              table.insert(params, nodeCondition[2])
            end
            if nodeCondition[3] then
              table.insert(params, nodeCondition[3])
            end
            if not Z.ConditionHelper.CheckSingleCondition(nodeCondition[1], true, table.unpack(params)) then
              isCanUnlock = false
              break
            end
          end
        end
        if isCanUnlock then
          local talentConfig = talentTableMgr.GetRow(talentTreeConfig.TalentId)
          if talentConfig then
            for _, consume in ipairs(talentConfig.UnlockConsume) do
              if tempUseItem[consume[1]] == nil then
                tempUseItem[consume[1]] = consume[2]
              else
                tempUseItem[consume[1]] = tempUseItem[consume[1]] + consume[2]
              end
            end
            tempUseTalentPoints = tempUseTalentPoints + talentConfig.TalentPointsConsume
            for itemId, needCount in pairs(tempUseItem) do
              if needCount > itemsVM.GetItemTotalCount(itemId) then
                local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId)
                if showTips and itemConfig then
                  Z.TipsVM.ShowTipsLang(1042034, {
                    val = itemConfig.Name
                  })
                end
                return nil, nil, nil, nil, itemId
              end
            end
            if allTalentPoint < useTalentPoint + tempUseTalentPoints then
              local talentPointConfigId = Z.DataMgr.Get("talent_skill_data"):GetTalentPointConfigId()
              local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(talentPointConfigId)
              if showTips and itemConfig then
                Z.TipsVM.ShowTipsLang(1042034, {
                  val = itemConfig.Name
                })
              end
              return nil, nil, nil, nil, talentPointConfigId
            end
            table.insert(res, minRoute[i])
          end
        else
          local talentConfig = talentTableMgr.GetRow(talentTreeConfig.TalentId)
          if showTips and talentConfig then
            Z.TipsVM.ShowTipsLang(1042033, {
              val = talentConfig.TalentName
            })
          end
          return
        end
      end
    end
    return res, tempUseTalentPoints, tempUseItem, isUseRecommendTalent
  else
    return
  end
end

function TalentSkillVM.GetRecommendFightValue()
  local fightValue = 0
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local professionId = weaponVm.GetCurWeapon()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.Talent, true)
  if isOn then
    local talentList = Z.ContainerMgr.CharSerialize.professionList.talentList[professionId]
    if talentList then
      local talentTreeMgr = Z.TableMgr.GetTable("TalentTreeTableMgr")
      local talentMgr = Z.TableMgr.GetTable("TalentTableMgr")
      for _, value in ipairs(talentList.talentNodeIds) do
        local talentTreeConfig = talentTreeMgr.GetRow(value)
        if talentTreeConfig then
          local talentId = talentTreeConfig.TalentId
          local talentConfig = talentMgr.GetRow(talentId)
          if talentConfig then
            fightValue = fightValue + talentConfig.FightValue
          end
        end
      end
    end
  end
  isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.ProfessionLv, true)
  if isOn then
    local weaponInfo = weaponVm.GetWeaponInfo(professionId)
    if weaponInfo then
      local weaponData = Z.DataMgr.Get("weapon_data")
      local TableRow = weaponData:GetWeaponAttrTableRow(professionId, weaponInfo.level)
      if TableRow then
        fightValue = fightValue + TableRow.FightValue
      end
    end
  end
  return fightValue
end

function TalentSkillVM.CheckReply(reply)
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  else
    return true
  end
end

function TalentSkillVM.UnlockWeaponSkill(professionId, skillId, cancelToken)
  local request = {}
  request.professionId = professionId
  request.skillId = skillId
  local reply = worldProxy.ProfessionSkillActive(request, cancelToken)
  return TalentSkillVM.CheckReply(reply)
end

function TalentSkillVM.UnlockTalentTreeNode(professionId, treeNodeIds, cancelToken, isRecommend)
  local request = {}
  request.professionId = professionId
  request.talentNodeIds = treeNodeIds
  local reply = worldProxy.ActiveProfessionTalent(request, cancelToken)
  if TalentSkillVM.CheckReply(reply) then
    if isRecommend then
      Z.TipsVM.ShowTipsLang(1042018)
    else
    end
    if 1 < #treeNodeIds then
    else
      local talentTreeConfig = Z.TableMgr.GetTable("TalentTreeTableMgr").GetRow(treeNodeIds[1])
      if talentTreeConfig then
        local talentConfig = Z.TableMgr.GetTable("TalentTableMgr").GetRow(talentTreeConfig.TalentId)
        if talentConfig and talentConfig.TalentType == TalentSkillDefine.TalentTreeUnitType.Special then
          local talentSkillData = Z.DataMgr.Get("talent_skill_data")
          local allStageConfigs = talentSkillData:GetTalentTreeByWeapon(professionId)
          if allStageConfigs == nil then
            return false
          end
          local stageConfig = allStageConfigs[talentTreeConfig.TalentStage][talentTreeConfig.BdType]
          local name = stageConfig.Name[1]
          if stageConfig.Name[2] then
            name = stageConfig.Name[2]
          end
          Z.TipsVM.ShowTipsLang(1042017, {val = name})
        end
      end
    end
    Z.EventMgr:Dispatch(Z.ConstValue.TalentSkill.UnLockTalent, treeNodeIds)
    return true
  end
  return false
end

function TalentSkillVM.ResetTalentTree(professionId, cancelToken)
  local request = {professionId = professionId}
  local reply = worldProxy.ResetProfessionTalent(request, cancelToken)
  return TalentSkillVM.CheckReply(reply)
end

function TalentSkillVM.ResetTalentNode(professionId, nodeId, cancelToken)
  local request = {professionId = professionId, talentNodeId = nodeId}
  local reply = worldProxy.ResetProfessionTalentBySingleNode(request, cancelToken)
  Z.EventMgr:Dispatch(Z.ConstValue.TalentSkill.UnLockTalent)
  return TalentSkillVM.CheckReply(reply)
end

return TalentSkillVM
