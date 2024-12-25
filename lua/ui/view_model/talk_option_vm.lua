local talkData = Z.DataMgr.Get("talk_data")
local openOptionView = function(optionDataList, type)
  local viewData = {}
  viewData.Type = type or E.TalkOptionsType.Normal
  viewData.optionData = optionDataList
  if viewData.Type == E.TalkOptionsType.Confrontation then
    Z.UIMgr:OpenView("pub_talk_option_window", viewData)
  elseif 0 < #optionDataList then
    Z.UIMgr:OpenView("talk_option_window", viewData)
  end
end
local closeOptionView = function()
  Z.UIMgr:CloseView("talk_option_window")
end
local closePubOptionView = function()
  Z.UIMgr:CloseView("pub_talk_option_window")
end
local createTalkOptionData = function(content, func, iconPath, iconStyle)
  local option = {}
  option.Content = content
  option.Func = func
  option.iconPath = iconPath
  option.iconStyle = iconStyle
  option.Id = 0
  return option
end
local createCFTTalkOptionData = function(cftData, index, func)
  local option = {}
  option.Id = cftData.Id
  option.Index = index
  option.Content = cftData.Content
  option.Func = func
  option.TrustValue = cftData.TrustChange
  option.TimeValue = cftData.TimeChange
  option.Type = Z.EPFlowConfrontationType.IntToEnum(cftData.Type)
  option.FailNodeName = cftData.FailNodeName
  return option
end
local startFailFlow = function(type, failName)
  local talkData = Z.DataMgr.Get("talk_data")
  local allPlayFlows = talkData:GetAllPlayFlow()
  if allPlayFlows == nil or table.zcount(allPlayFlows) < 1 then
    return
  end
  local _, flowInfo = next(allPlayFlows)
  if flowInfo == nil then
    return
  end
  local flowId = flowInfo.flowId
  Z.EPFlowBridge.StartFailFlow(flowId, type, failName)
  if type == Z.EPFlowEventType.Confrontation then
    closePubOptionView()
  else
    closeOptionView()
  end
end
local createOptionsByFlow = function(options)
  local ret = {}
  for i, content in ipairs(options) do
    local optionFunc = function()
      Z.EPFlowBridge.OnOptionSelected(i - 1)
      closeOptionView()
    end
    local option = createTalkOptionData(content, optionFunc)
    table.insert(ret, option)
  end
  return ret
end
local createInterrogateOptionsByFlow = function(options)
  local talkData = Z.DataMgr.Get("talk_data")
  local ret = {}
  for index, value in ipairs(options) do
    function value.Func()
      Z.EPFlowBridge.OnOptionSelected(index - 1)
      
      talkData:SetSelectInterrogateDict(value.Id)
      closeOptionView()
    end
    
    if talkData:GetSelectInterrogateIsShow(value.Id) then
      table.insert(ret, value)
    end
  end
  return ret
end
local creatConfrontationByFlow = function(options)
  local ret = {}
  for i, cftData in ipairs(options.Confrontation) do
    local optionFunc = function()
      Z.EPFlowBridge.OnConfrontationSelected(i - 1)
      if Z.EPFlowConfrontationType.Neutral == cftData.Type then
      else
        closePubOptionView()
      end
    end
    local option = createCFTTalkOptionData(cftData, i, optionFunc)
    table.insert(ret, option)
  end
  return ret
end
local createNpcFunctionOptions = function(npcId)
  local ret = {}
  local npcRow = Z.TableMgr.GetTable("NpcTableMgr").GetRow(npcId)
  if not npcRow then
    return ret
  end
  for _, v in ipairs(npcRow.NpcFunctionID) do
    local configData = v
    if configData and #configData == 2 then
      local functionId = tonumber(configData[2])
      if functionId then
        do
          local optionFunc = function()
            talkData.IsDelayQuit = false
            local curFlow = talkData:GetTalkCurFlow()
            Z.EPFlowBridge.StopFlow(curFlow)
            closeOptionView()
            local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
            if gotoFuncVM.CheckFuncCanUse(functionId) then
              gotoFuncVM.GoToFunc(functionId, npcId)
            end
          end
          local funcConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(functionId)
          local iconPath
          if funcConfig and funcConfig.DialogIcon and funcConfig.DialogIcon ~= "" then
            iconPath = funcConfig.DialogIcon
          end
          local option = createTalkOptionData(configData[1], optionFunc, iconPath, E.TextStyleTag.Talk_option_yellow)
          table.insert(ret, option)
        end
      end
    end
  end
  return ret
end
local createNpcQuestOptionsForFlow = function(npcId)
  local ret = {}
  local talkData = Z.DataMgr.Get("talk_data")
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local questTalkIdDict = talkData:GetQuestTalkFlowDictByNpcAndScene(npcId, curSceneId)
  local curFlow = talkData:GetTalkCurFlow()
  local tempData = {}
  for talkId, questId in pairs(questTalkIdDict) do
    if talkId ~= curFlow then
      tempData[#tempData + 1] = {talkId = talkId, questId = questId}
    end
  end
  table.sort(tempData, function(a, b)
    local configA = Z.TableMgr.GetTable("QuestTableMgr").GetRow(a.questId)
    local configB = Z.TableMgr.GetTable("QuestTableMgr").GetRow(b.questId)
    return configA.QuestType < configB.QuestType
  end)
  local questDetailVM = Z.VMMgr.GetVM("questdetail")
  for _, data in pairs(tempData) do
    local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(data.questId)
    if questRow then
      local param = {
        quest = {
          name = questRow.QuestName
        }
      }
      local content = Lang("QuestAbout", param)
      local optionFunc = function()
        closeOptionView()
        local curFlow = talkData:GetTalkCurFlow()
        talkData:SetPlayFlowIdData(data.talkId, E.FlowPlayStateEnum.Loading, E.FlowPlaySourceEnum.OptionPlayFlow, curFlow)
        Z.EPFlowBridge.StopFlow(curFlow)
        Z.EPFlowBridge.StartFlow(data.talkId)
      end
      local icon = questDetailVM.GetStateIconByQuestId(data.questId)
      if not icon or icon == "" then
        icon = GetLoadAssetPath(Z.ConstValue.NpcTalk.ChatQuestIconPath)
      end
      local option = createTalkOptionData(content, optionFunc, icon, E.TextStyleTag.Talk_option_yellow)
      table.insert(ret, option)
    end
  end
  return ret
end
local openConfrontationTalkOptionView = function(optiosns)
  local dataList = creatConfrontationByFlow(optiosns)
  openOptionView(dataList, E.TalkOptionsType.Confrontation)
end
local createLeaveOption = function()
  local optionFunc = function()
    local curFlow = talkData:GetTalkCurFlow()
    Z.EPFlowBridge.StopFlow(curFlow)
    closeOptionView()
  end
  local option = createTalkOptionData(Lang("Leave"), optionFunc)
  return option
end
local openFlowTalkOptionView = function(options, isAddExtraOption)
  local dataList = {}
  local npcId = talkData:GetTalkingNpcId()
  if 0 < npcId and isAddExtraOption then
    table.zmerge(dataList, createNpcFunctionOptions(npcId))
    table.zmerge(dataList, createNpcQuestOptionsForFlow(npcId))
  end
  table.zmerge(dataList, createOptionsByFlow(options))
  openOptionView(dataList)
end
local openFlowInterrogateOptionView = function(options, isAddExtraOption)
  local dataList = {}
  if isAddExtraOption then
    local npcId = talkData:GetTalkingNpcId()
    if 0 < npcId then
      table.zmerge(dataList, createNpcFunctionOptions(npcId))
      table.zmerge(dataList, createNpcQuestOptionsForFlow(npcId))
    end
  end
  table.zmerge(dataList, createInterrogateOptionsByFlow(options))
  openOptionView(dataList)
end
local ret = {
  CreateNpcQuestOptionsForFlow = createNpcQuestOptionsForFlow,
  OpenOptionView = openOptionView,
  OpenFlowTalkOptionView = openFlowTalkOptionView,
  OpenFlowInterrogateOptionView = openFlowInterrogateOptionView,
  OpenConfrontationTalkOptionView = openConfrontationTalkOptionView,
  CloseOptionView = closeOptionView,
  StartFailFlow = startFailFlow,
  CreateLeaveOption = createLeaveOption
}
return ret
