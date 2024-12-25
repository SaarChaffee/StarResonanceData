local WorldProxy = require("zproxy.world_proxy")
local COLOR_WHITE = Color.New(1, 1, 1, 1)
local F2F3E8 = Color.New(0.9490196078431372, 0.9529411764705882, 0.9098039215686274, 1)
local FFBEB6 = Color.New(1, 0.7450980392156863, 0.7137254901960784, 1)
local proficiencyData = Z.DataMgr.Get("proficiency_data")
local openProficiencyView = function()
  local level = Z.ContainerMgr.CharSerialize.roleLevel.level
  local functionCfg = Z.TableMgr.GetTable("FunctionTableMgr")
  local potentialCfg = functionCfg.GetRow(200401)
  if level < potentialCfg.Level then
    Z.TipsVM.ShowTipsLang(130032)
  else
    Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Demo_yzh, "proficiency_main", function()
      Z.UIMgr:OpenView("proficiency_main")
    end, Z.ConstValue.UnrealSceneConfigPaths.Role)
  end
end
local closeProficiencyView = function()
  Z.UIMgr:CloseView("proficiency_main")
end
local getProficiencyData = function()
  local data = Z.DataMgr.Get("proficiency_data")
  if table.zcount(data.ShowProficiencyData) > 0 then
    return data.ShowProficiencyData
  end
  local playerLevelSkillCfg = data.PlayerLevelSkillTableDatas
  local tab = {}
  playerLevelSkillCfg = table.zsort(playerLevelSkillCfg, function(a, b)
    if a.ActiveLevel == b.ActiveLevel then
      return a.Style < b.Style
    end
    return a.ActiveLevel < b.ActiveLevel
  end)
  local index = 0
  local nowLevel = -1
  for _, cfgData in pairs(playerLevelSkillCfg) do
    if nowLevel ~= cfgData.value.ActiveLevel then
      index = index + 1
      nowLevel = cfgData.value.ActiveLevel
      tab[index] = {}
    end
    local itemData = {
      BuffId = cfgData.value.BuffId,
      ActiveLevel = cfgData.value.ActiveLevel,
      NextLevel = 0,
      LastLevel = 0,
      Deactive = cfgData.value.Deactive,
      LockItem = {}
    }
    for key, value in pairs(cfgData.value.LockItem) do
      local itemId = value[1]
      local num = value[2]
      if itemId and num then
        local popupItemData = {ConfigId = itemId, Count = num}
        table.insert(itemData.LockItem, popupItemData)
      end
    end
    table.insert(tab[index], itemData)
  end
  for i = 1, #tab do
    for j = 1, #tab[i] do
      local lastValue = tab[i - 1]
      local nextValue = tab[i + 1]
      if lastValue then
        tab[i][j].LastLevel = lastValue[1].ActiveLevel
      end
      if nextValue then
        tab[i][j].NextLevel = nextValue[1].ActiveLevel
      end
    end
  end
  data.ShowProficiencyData = tab
  return data.ShowProficiencyData
end
local asyncSetProficiency = function(LevelProficiency, cancelSource)
  local tab = {}
  tab.usingProficiencyMap = LevelProficiency
  local ret = WorldProxy.SetProficiency(tab, cancelSource)
  if ret == 0 then
  else
    Z.TipsVM.ShowTips(ret)
    logError(table.ztostring(tab))
  end
  proficiencyData:ChangeState(false)
  return ret
end
local getBuffData = function(buffId)
  local buffCfg = Z.TableMgr.GetTable("BuffTableMgr")
  return buffCfg.GetRow(buffId)
end
local getIsLockByLevelAndBuffId = function(lockItem, nowlevel, buffId)
  if lockItem == nil or table.zcount(lockItem) <= 0 then
    return true
  end
  for level, data in pairs(Z.ContainerMgr.CharSerialize.roleLevel.proficiencyInfo.unlockProficiencyMap) do
    if level == nowlevel then
      for _, unLoclBuffId in pairs(data.unlockBufferId) do
        if unLoclBuffId == buffId then
          return true
        end
      end
    end
  end
  return false
end
local getDataIsChange = function()
  local isChange = false
  local usingProficiencyMap = {}
  for key, value in pairs(Z.ContainerMgr.CharSerialize.roleLevel.proficiencyInfo.usingProficiencyMap) do
    usingProficiencyMap[key] = value
  end
  if table.zcount(proficiencyData.ProficiencyActivationTab) == table.zcount(usingProficiencyMap) then
    for key, buffId in pairs(usingProficiencyMap) do
      if proficiencyData.ProficiencyActivationTab[key] ~= buffId then
        isChange = true
        break
      end
    end
  else
    isChange = true
  end
  proficiencyData:ChangeState(isChange)
  Z.EventMgr:Dispatch("RefreshSaveBtn", isChange)
end
local setActiveLevel = function(level, buffId)
  proficiencyData:ActivationLevel(level, buffId)
end
local notActiveLevel = function(level)
  proficiencyData:NotActivationLevel(level)
end
local notActvationAll = function()
  proficiencyData:NotActvationAll()
end
local asyncUnlockProficiency = function(level, buffId, token)
  local ret = WorldProxy.UnlockProficiency(level, buffId, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
  return ret
end
local setNewProficiencyType = function(lastLevel, level)
  local data = Z.DataMgr.Get("proficiency_data")
  local isNewState = false
  for key, playerSkillCfgData in pairs(data.PlayerLevelSkillTableDatas) do
    if playerSkillCfgData.AutoActive ~= 1 then
      if lastLevel == 1 and playerSkillCfgData.ActiveLevel == 1 then
        data.ProficiencyNewItem[playerSkillCfgData.BuffId] = true
        isNewState = true
      end
      if lastLevel < playerSkillCfgData.ActiveLevel and level >= playerSkillCfgData.ActiveLevel then
        data.ProficiencyNewItem[playerSkillCfgData.BuffId] = true
        isNewState = true
      end
    end
  end
  if isNewState then
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.RoleMainRolelevelBtn, table.zcount(data.ProficiencyNewItem))
  end
end
local isActiveByItemData = function(itemData)
  local ProficiencyData = Z.DataMgr.Get("proficiency_data")
  local buffId = ProficiencyData:GetLevelActivationId(itemData.ActiveLevel)
  if not buffId then
    return false
  else
    return buffId == itemData.BuffId
  end
end
local ret = {
  OpenProficiencyView = openProficiencyView,
  CloseProficiencyView = closeProficiencyView,
  GetProficiencyData = getProficiencyData,
  AsyncSetProficiency = asyncSetProficiency,
  GetBuffData = getBuffData,
  GetIsLockByLevelAndBuffId = getIsLockByLevelAndBuffId,
  GetDataIsChange = getDataIsChange,
  SetActiveLevel = setActiveLevel,
  NotActiveLevel = notActiveLevel,
  NotActvationAll = notActvationAll,
  AsyncUnlockProficiency = asyncUnlockProficiency,
  SetNewProficiencyType = setNewProficiencyType,
  IsActiveByItemData = isActiveByItemData
}
return ret
