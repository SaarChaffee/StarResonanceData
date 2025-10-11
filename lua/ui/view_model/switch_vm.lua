local switchData_ = Z.DataMgr.Get("switch_data")
local checkLevel = function(config)
  local level = config and config.RoleLevel or 0
  local flag, _, _, _ = Z.ConditionHelper.checkConditionType_1(level)
  local ret = {}
  ret.str = config.Name
  ret.val = level
  return flag, 124002, ret
end
local checkFunctionIsClose = function(config)
  local flag = true
  local isClose = switchData_.ServerCloseFunctionIdDic[config.Id]
  if isClose then
    flag = false
  else
    local isClose = switchData_.UserCloseFunctionIdDic[config.Id]
    if isClose then
      flag = false
    end
  end
  return flag, {
    {error = 2021}
  }
end
local checkTime = function(config)
  if not config or config.TimerId == 0 then
    return true, 0, nil
  end
  local tipsId = 0
  local tipsParam
  local startTime, endTime, duration = Z.TimeTools.GetWholeStartEndTimeByTimerId(config.TimerId)
  if startTime then
    local serverTime = Z.ServerTime:GetServerTime() / 1000
    if startTime > serverTime then
      local date = {
        longstring = Z.TimeFormatTools.TicksFormatTime(startTime * 1000, E.TimeFormatType.YMD, false, true)
      }
      tipsId = 124001
      tipsParam = {
        date = date,
        str = config.Name
      }
    end
  end
  return tipsId == 0, tipsId, tipsParam
end
local checkQuest = function(config)
  if not config then
    return true, 0, nil
  end
  local getParam = function(id)
    local questTable = Z.TableMgr.GetTable("QuestTableMgr").GetRow(id)
    if questTable then
      local questTypeTable = Z.TableMgr.GetTable("QuestTypeTableMgr").GetRow(questTable.QuestType)
      if questTypeTable then
        local questTypeGroupTable = Z.TableMgr.GetTable("QuestTypeGroupTableMgr").GetRow(questTypeTable.QuestTypeGroupID)
        local questVm = Z.VMMgr.GetVM("quest")
        if questTypeGroupTable then
          local param = {}
          param.str = {}
          param.str[1] = config.Name
          param.str[2] = questTypeGroupTable.GroupName
          param.quest = {}
          param.quest.name = questVm.GetQuestName(questTable.QuestId)
          return param
        end
      end
    end
    return nil
  end
  if 0 < config.QuestId then
    local param = getParam(config.QuestId)
    if param then
      local flag, _, _, _ = Z.ConditionHelper.checkConditionType_2(config.QuestId)
      return flag, 124003, param
    end
  elseif next(config.QuestStepId) then
    local quest = config.QuestStepId[1]
    local step = config.QuestStepId[2]
    local param = getParam(quest)
    if param then
      local flag, tipsId, _, _ = Z.ConditionHelper.checkConditionType_28(quest, step)
      return flag, tipsId, param
    end
  end
  return true, 0, nil
end
local getLockedReason = function(config, needFunctionName)
  local reason = {}
  local pass, error, params = checkTime(config, needFunctionName)
  if not pass then
    table.insert(reason, {error = error, params = params})
  end
  pass, error, params = checkLevel(config, needFunctionName)
  if not pass then
    table.insert(reason, {error = error, params = params})
  end
  pass, error, params = checkQuest(config, needFunctionName)
  if not pass then
    table.insert(reason, {error = error, params = params})
  end
  return reason
end
local check = function(config)
  if config.RoleLevel == 0 and config.QuestId == 0 and #config.QuestStepId == 0 and config.TimerId == 0 then
    return true
  end
  local isOpen = Z.ContainerMgr.CharSerialize.FunctionData.unlockedMap[config.Id]
  if isOpen then
    return true, nil
  end
  local reason = getLockedReason(config)
  if reason == nil then
    local str = "\229\138\159\232\131\189\229\188\128\229\133\179\229\174\185\229\153\168\230\149\176\230\141\174\228\184\186\230\156\170\229\188\128\229\144\175\239\188\140\228\189\134\230\152\175\230\178\161\230\156\137\229\142\159\229\155\160,\229\138\159\232\131\189ID\228\184\186 " .. config.Id .. " ,\232\175\183\230\163\128\230\159\165!!!!!"
    logError(str)
  end
  return false, reason
end

local function checkFuncSwitch(id)
  local tableMgr = Z.TableMgr.GetTable("FunctionTableMgr")
  local config = tableMgr.GetRow(id)
  if config == nil then
    return true
  end
  if config.OnOff == 1 then
    return false
  end
  local isNotClose, reason = checkFunctionIsClose(config)
  if not isNotClose then
    return false, reason
  end
  local isUnlock, reason = check(config)
  if isUnlock and config.ParentId ~= 0 then
    return checkFuncSwitch(config.ParentId)
  end
  return isUnlock, reason
end

local onSwitchChange = function(container, dirtyKeys)
  if dirtyKeys.unlockedMap then
    local tabs = {}
    for funcId, open in pairs(dirtyKeys.unlockedMap) do
      open = open.Get()
      tabs[funcId] = open
      switchData_.SwitchFunctionIdDic[funcId] = open
      if open then
        local functionTable = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(funcId)
        local previewData = Z.DataMgr.Get("function_preview_data")
        local isPreview = previewData:CheckNeedPreview(funcId)
        if functionTable and isPreview then
          if functionTable.OpenTips > 0 then
            local previewCfg = Z.TableMgr.GetTable("FunctionPreviewTableMgr").GetRow(funcId)
            if previewCfg then
              Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FunctionOpen, "tips_unlock_condition", {functionId = funcId}, previewCfg.Preview)
            end
          end
          Z.EventMgr:Dispatch(Z.ConstValue.RefreshFunctionIcon, funcId, open)
        end
        Z.EventMgr:Dispatch(Z.ConstValue.RefreshFunctionBtnState, funcId, open)
        local chatMainData = Z.DataMgr.Get("chat_main_data")
        chatMainData:CheckChannelList(funcId, open)
        Z.RedPointMgr.RefreshRedNodeState(funcId)
      end
    end
    Z.EventMgr:Dispatch(Z.ConstValue.SwitchFunctionChange, tabs)
  end
end
local getLockedFeature = function(onlyNeedPreview)
  return switchData_:GetLockedFeature(onlyNeedPreview)
end
local getAllFeature = function(onlyNeedPreview)
  return switchData_:GetAllFeature(onlyNeedPreview)
end
local isMainFunction = function(id)
  return switchData_:IsMainFunction(id)
end
local watcherSwitchChange = function()
  local funcData = Z.ContainerMgr.CharSerialize.FunctionData
  if funcData then
    funcData.Watcher:RegWatcher(onSwitchChange)
  end
  for functionId, isUnlock in pairs(funcData.unlockedMap) do
    switchData_.SwitchFunctionIdDic[functionId] = isUnlock
  end
  Z.EventMgr:Dispatch(Z.ConstValue.SwitchFunctionChange, funcData.unlockedMap)
end
local checkIsClose = function(closeTab, param)
  for id, value in pairs(closeTab) do
    local isClose = false
    for index, value in ipairs(param.closeFunction) do
      if id == value then
        isClose = true
        break
      end
    end
    if not isClose then
      closeTab[id] = false
      Z.EventMgr:Dispatch(Z.ConstValue.RefreshFunctionIcon, id, true)
    end
  end
end
local userCloseFunction = function(param)
  if not param or not param.closeFunction then
    return
  end
  checkIsClose(switchData_.UserCloseFunctionIdDic, param)
  switchData_.UserCloseFunctionIdDic = {}
  for index, functionId in ipairs(param.closeFunction) do
    switchData_.UserCloseFunctionIdDic[functionId] = true
    Z.EventMgr:Dispatch(Z.ConstValue.RefreshFunctionIcon, functionId, false)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.UserCloseFunction, param.closeFunction)
end
local serverCloseFunction = function(param)
  if not param or not param.closeFunction then
    return
  end
  checkIsClose(switchData_.ServerCloseFunctionIdDic, param)
  switchData_.ServerCloseFunctionIdDic = {}
  for index, functionId in ipairs(param.closeFunction) do
    switchData_.ServerCloseFunctionIdDic[functionId] = true
    Z.EventMgr:Dispatch(Z.ConstValue.RefreshFunctionIcon, functionId, false)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.ServerCloseFunction, param.closeFunction)
end
local ret = {
  CheckFuncSwitch = checkFuncSwitch,
  WatcherSwitchChange = watcherSwitchChange,
  GetLockedFeature = getLockedFeature,
  GetLockedReason = getLockedReason,
  CheckTime = checkTime,
  CheckLevel = checkLevel,
  CheckQuest = checkQuest,
  IsMainFunction = isMainFunction,
  GetAllFeature = getAllFeature,
  UserCloseFunction = userCloseFunction,
  ServerCloseFunction = serverCloseFunction
}
return ret
