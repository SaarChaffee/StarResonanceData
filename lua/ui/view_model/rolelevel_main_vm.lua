local WorldProxy = require("zproxy.world_proxy")
local itemShowVm = Z.VMMgr.GetVM("item_show")
local EXPERIENCE_TIPS_COLOR = Color.New(0.9490196078431372, 0.9529411764705882, 0.9098039215686274, 1)
local openRolelevelAwardPanel = function(pageIndex)
  local viewData = {
    pageIndex = tonumber(pageIndex)
  }
  Z.UIMgr:OpenView("rolelevel_mian", viewData)
end
local closeRolelevelAwardPanel = function()
  Z.UIMgr:CloseView("rolelevel_mian")
end
local getAttrInfo = function(level)
  local playerLevelCfg = Z.TableMgr.GetTable("PlayerLevelTableMgr")
  local levelCfg = playerLevelCfg.GetRow(level)
  if not levelCfg then
    return
  end
  local attrTab = {}
  for key, attrArray in pairs(levelCfg.LevelUpAttr) do
    attrTab[attrArray[1]] = attrArray[2]
  end
  return attrTab
end
local getAwardIdByLevel = function(level)
  local playerLevelCfg = Z.TableMgr.GetTable("PlayerLevelTableMgr")
  local levelCfg = playerLevelCfg.GetRow(level)
  if not levelCfg then
    return
  end
  if levelCfg.LevelAwardID == 0 then
    return nil
  end
  return levelCfg.LevelAwardID
end
local getRedCount = function()
  local levelAwardReceived = Z.ContainerMgr.CharSerialize.roleLevel.ReceivedLevelList
  local nowLevel = Z.ContainerMgr.CharSerialize.roleLevel.level
  local redNum = 0
  for levle = 1, nowLevel do
    if getAwardIdByLevel(levle) and not levelAwardReceived[levle] then
      redNum = redNum + 1
    end
  end
  return redNum
end
local refreshServerRed = function()
  local data = Z.DataMgr.Get("role_level_data")
  local nowLevel = Z.ContainerMgr.CharSerialize.roleLevel.level
  Z.RedPointMgr.UpdateNodeCount(E.RedType.RoleLevelMain, getRedCount())
  data:SetRedLevel(nowLevel)
end
local refreshClientRed = function()
  Z.RedPointMgr.UpdateNodeCount(E.RedType.RoleLevelMain, getRedCount(), true)
end
local checkIsHaveNowAward = function()
  local data = Z.DataMgr.Get("role_level_data")
  local lastLevel = data:GetRoleLevel()
  local proficiencyVm = Z.VMMgr.GetVM("proficiency")
  proficiencyVm.SetNewProficiencyType(lastLevel, Z.ContainerMgr.CharSerialize.roleLevel.level)
  local nowLevel = Z.ContainerMgr.CharSerialize.roleLevel.level
  for levle = lastLevel + 1, nowLevel do
    if getAwardIdByLevel(levle) then
      refreshServerRed()
    end
  end
end
local openRoleLevelWindow = function()
  checkIsHaveNowAward()
  local roleLevelData = Z.DataMgr.Get("role_level_data")
  local param = {
    preLevel = roleLevelData:GetRoleLevel(),
    curLevel = Z.ContainerMgr.CharSerialize.roleLevel.level
  }
  roleLevelData:SetRoleLevel(Z.ContainerMgr.CharSerialize.roleLevel.level)
  Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FunctionOpen, "main_upgrade_window", param, 0)
end
local closeRoleLevelWindow = function()
  Z.UIMgr:CloseView("main_upgrade_window")
end
local regWatcher = function(container, dirtys)
  if not dirtys.level then
    return
  end
  openRoleLevelWindow()
  Z.EventMgr:Dispatch(Z.ConstValue.RoleLevelUp, dirtys.level:Get())
end
local addRoleRegWatcher = function()
  local roleLevel = Z.ContainerMgr.CharSerialize.roleLevel
  if roleLevel then
    roleLevel.Watcher:RegWatcher(regWatcher)
  end
  local data = Z.DataMgr.Get("role_level_data")
  local redRefreshLevel = data:GetRedLevel()
  local nowLevel = Z.ContainerMgr.CharSerialize.roleLevel.level
  if redRefreshLevel ~= nowLevel then
    refreshServerRed()
  end
end
local getItems = function(awardId)
  local awardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(awardId)
  if table.zcount(awardList) > 0 then
    local itemTab = {}
    for key, awardData in pairs(awardList) do
      table.insert(itemTab, {
        configId = awardData.awardId,
        count = awardData.awardNum
      })
    end
    return itemTab
  end
  return nil
end
local asyncGetLevelAward = function(level, award, cancelSource)
  local ret = WorldProxy.GetLevelAward(level, award, cancelSource)
  if ret == 0 then
    local materials = getItems(award)
    if materials then
      itemShowVm.OpenItemShowView(materials)
    end
  else
    Z.TipsVM.ShowTips(ret)
  end
  return ret
end
local getLevelAwards = function()
  local awards = {}
  local rolelevelData = Z.DataMgr.Get("role_level_data")
  for key, levelData in pairs(rolelevelData.PlayerLevelTableDatas) do
    if #levelData.LevelUpAttr ~= 0 or levelData.LevelAwardID ~= 0 or levelData.ExplainText ~= "" or levelData.TalentAward ~= 0 then
      table.insert(awards, {
        Level = levelData.Level,
        Exp = levelData.Exp,
        LevelUpAttr = levelData.LevelUpAttr,
        LevelAwardID = levelData.LevelAwardID,
        Icon = levelData.Icon,
        ExplainText = levelData.ExplainText,
        TalentPoint = levelData.TalentAward
      })
      awards[#awards].LevelExp = levelData.Exp
    elseif awards[#awards] then
      awards[#awards].LevelExp = awards[#awards].LevelExp + levelData.Exp
    end
  end
  return awards
end
local getAllItemCanReceiveAndMerge = function()
  local received = Z.ContainerMgr.CharSerialize.roleLevel.ReceivedLevelList
  local level = Z.ContainerMgr.CharSerialize.roleLevel.level
  local allLevelAwards = getLevelAwards()
  local allRewards
  for _, levelAward in pairs(allLevelAwards) do
    if not received[levelAward.Level] and level >= levelAward.Level and levelAward.LevelAwardID ~= 0 then
      allRewards = allRewards or {}
      local rewards = getItems(levelAward.LevelAwardID)
      if rewards then
        for _, reward in pairs(rewards) do
          if allRewards[reward.configId] then
            allRewards[reward.configId].count = allRewards[reward.configId].count + reward.count
          else
            allRewards[reward.configId] = reward
          end
        end
      end
    end
  end
  if allRewards then
    local list = {}
    for _, v in pairs(allRewards) do
      table.insert(list, v)
    end
    return list
  end
  return nil
end
local asyncGetAllRewards = function(cancelSource)
  local items = getAllItemCanReceiveAndMerge()
  if not items or #items <= 0 then
    return
  end
  local ret = WorldProxy.GetAllLevelAward(cancelSource)
  if ret == 0 then
    itemShowVm.OpenItemShowView(items)
  else
    Z.TipsVM.ShowTips(ret)
  end
  return ret
end
local insightBtnCall = function()
  local switchVm = Z.VMMgr.GetVM("switch")
  local isOpen = switchVm.CheckFuncSwitch(E.FunctionID.Insight)
  if isOpen then
    Z.CoroUtil.create_coro_xpcall(function()
      local cancelSource = Z.CancelSource.Rent()
      Z.VMMgr.GetVM("role_info_main").CloseView()
      if not Z.EntityMgr.PlayerEnt then
        logError("PlayerEnt is nil")
        return
      end
      local curInsightState = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrInsightFlag")).Value
      local insightVm = Z.VMMgr.GetVM("insight")
      if curInsightState == 1 then
        insightVm.CloseInsight(cancelSource:CreateToken())
      end
      insightVm.OpenInsight(cancelSource:CreateToken())
    end)()
  end
end
local openRoleLevelItemTips = function(posTrans, levelData)
  local viewData = {rect = posTrans}
  if levelData.LevelAwardID ~= 0 then
    local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
    local awardDataList = awardPreviewVm.GetAllAwardPreListByIds(levelData.LevelAwardID)
    if awardDataList then
      viewData.award = {
        title = Lang("ItemReward"),
        awards = awardDataList
      }
    end
  end
  if 0 < #levelData.LevelUpAttr then
    local attrParseVm = Z.VMMgr.GetVM("fight_attr_parse")
    local lstContent = {}
    for _, v in ipairs(levelData.LevelUpAttr[1]) do
      lstContent[#lstContent + 1] = attrParseVm.ParseFightAttrTips(v[1], v[2])
    end
    viewData.attr = {
      title = Lang("PropertyReward"),
      info = table.concat(lstContent, "\n")
    }
  end
  if levelData.ExplainText ~= "" then
    viewData.unlock = {
      title = Lang("FuncUnlock"),
      info = levelData.ExplainText
    }
  end
  Z.UIMgr:OpenView("tips_rolelevelitems", viewData)
end
local closeRoleLevelItems = function()
  Z.UIMgr:CloseView("tips_rolelevelitems")
end
local initRoleData = function()
  local data = Z.DataMgr.Get("role_level_data")
  data:Init()
end
local openRoleLevelWayWindow = function()
  local level_ = Z.ContainerMgr.CharSerialize.roleLevel.level
  local playerLevelCfg = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetRow(level_)
  if playerLevelCfg and next(playerLevelCfg.ExpAccess) then
    local viewData = {}
    viewData.nextLvCfg = playerLevelCfg
    Z.UIMgr:OpenView("rolelevel_way_window", viewData)
  end
end
local getRecommendFightValue = function()
  local value = 0
  local level = Z.ContainerMgr.CharSerialize.roleLevel.level
  local data = Z.DataMgr.Get("role_level_data")
  for _, v in pairs(data.PlayerLevelTableDatas) do
    if level >= v.Level then
      value = value + v.FightValue
    end
  end
  return value
end
local isBlessExpFuncOn = function()
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  return funcVm.CheckFuncCanUse(E.FunctionID.BlessExp, true)
end
local ret = {
  OpenRolelevelAwardPanel = openRolelevelAwardPanel,
  CloseRolelevelAwardPanel = closeRolelevelAwardPanel,
  AsyncGetLevelAward = asyncGetLevelAward,
  GetAttrInfo = getAttrInfo,
  GetLevelAwards = getLevelAwards,
  AsyncGetAllRewards = asyncGetAllRewards,
  AddRoleRegWatcher = addRoleRegWatcher,
  CloseRoleLevelWindow = closeRoleLevelWindow,
  OpenRoleLevelItemTips = openRoleLevelItemTips,
  CloseRoleLevelItems = closeRoleLevelItems,
  InsightBtnCall = insightBtnCall,
  GetAwardIdByLevel = getAwardIdByLevel,
  RefreshServerRed = refreshServerRed,
  RefreshClientRed = refreshClientRed,
  InitRoleData = initRoleData,
  OpenRoleLevelWindow = openRoleLevelWindow,
  OpenRoleLevelWayWindow = openRoleLevelWayWindow,
  GetRecommendFightValue = getRecommendFightValue,
  IsBlessExpFuncOn = isBlessExpFuncOn
}
return ret
