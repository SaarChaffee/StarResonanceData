local actionData = Z.DataMgr.Get("action_data")
local uuidToEntId = function(uuid)
  local entityVm = Z.VMMgr.GetVM("entity")
  return entityVm.UuidToEntId(uuid)
end
local uuidToEntType = function(uuid)
  local entityVm = Z.VMMgr.GetVM("entity")
  return entityVm.UuidToEntType(uuid)
end
local OpenUI = function(uuid, param, token)
  Z.UIMgr:OpenView(param[1])
end
local FunctionEntry = function(uuid, param, token)
  local functionID = tonumber(param[1])
  local goVm = Z.VMMgr.GetVM("gotofunc")
  goVm.GoToFunc(functionID)
end
local NpcTalk = function(uuid, param, token)
  local entity = Z.EntityMgr:GetEntity(uuid)
  if entity == nil then
    return
  end
  local attrId = entity:GetLuaAttr(Z.PbAttrEnum("AttrId")).Value
  local data = {npcId = attrId, uuid = uuid}
  local talkVm = Z.VMMgr.GetVM("talk")
  talkVm.BeginNpcTalkState(data, token)
end
local NpcTalkFlow = function(uuid, param, token)
  local entity = Z.EntityMgr:GetEntity(uuid)
  if entity == nil then
    return
  end
  local attrId = entity:GetLuaAttr(Z.PbAttrEnum("AttrId")).Value
  local data = {npcId = attrId, uuid = uuid}
  local talkVm = Z.VMMgr.GetVM("talk")
  talkVm.BeginNpcTalkFlow(data, token)
end
local NpcTalkFlowAbort = function(uuid, param, token)
  logGreen("NpcTalkFlowAbort,uuid={0}", uuid)
end
local NpcTalkFlowEnd = function(uuid, param, token)
  logGreen("NpcTalkFlowEnd,uuid={0}", uuid)
end
local OptionSelect = function(uuid, param, token)
  local str = param[1]
  local interactionVm = Z.VMMgr.GetVM("interaction")
  interactionVm.AsyncUserOptionSelect(str, token)
end
local ClientSceneEvent = function(uuid, param, token)
  local eventParam
  if not param then
    eventParam = tostring(uuidToEntId(uuid))
  else
    local str = param[1]
    eventParam = str
  end
  Z.LevelMgr:OnLevelEventTrigger(E.LevelEventType.OnOptionSelect, eventParam)
end
local DungeonEntry = function(uuid, param, token)
  local levelId = tonumber(param[1])
  local enterDungeonSceneVm = Z.VMMgr.GetVM("ui_enterdungeonscene")
  enterDungeonSceneVm.OpenEnterDungeonSceneView(levelId)
end
local HeroNormalDungeon = function(uuid, param, token)
  local id = tonumber(param[1])
  local dungeonVm = Z.VMMgr.GetVM("dungeon")
  local dungeonData_ = dungeonVm.GetHerDungeonData(id)
  local functionId_ = Z.PbEnum("EFunctionType", "FunctionTypeHeroDungeonNormal")
  local switchVm = Z.VMMgr.GetVM("switch")
  local functionOpen, reason = switchVm.CheckFuncSwitch(dungeonData_.FunctionID)
  if functionOpen then
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    local heroData = Z.DataMgr.Get("hero_dungeon_main_data")
    heroData:SetScenceId(dungeonData_.Id)
    heroData:SetFunctionId(functionId_)
    gotoFuncVM.GoToFunc(dungeonData_.FunctionID)
  elseif reason and reason[1] then
    Z.TipsVM.OpenViewById(reason[1].error, reason[1].params)
  end
end
local HeroChallengeDungeon = function(uuid, param, token)
  local dungeonVm = Z.VMMgr.GetVM("dungeon")
  local groupId = tonumber(param[1])
  local groupDict_ = dungeonVm.GetHeroDungeonGroup(groupId)
  if table.zcount(groupDict_) == 0 then
    return false
  end
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(groupDict_[1].DungeonId)
  local switchVm = Z.VMMgr.GetVM("switch")
  local functionOpen, reason = switchVm.CheckFuncSwitch(dungeonsTable.FunctionID)
  if functionOpen then
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    local heroData = Z.DataMgr.Get("hero_dungeon_main_data")
    heroData:SetChallengeScenceId(groupDict_)
    local functionId = Z.PbEnum("EFunctionType", "FunctionTypeHeroDungeonChallenge")
    heroData:SetFunctionId(functionId)
    gotoFuncVM.GoToFunc(dungeonsTable.FunctionID)
  elseif reason and reason[1] then
    Z.TipsVM.OpenViewById(reason[1].error, reason[1].params)
  end
end
local CookFunc = function(uuid, param, token)
  if tonumber(param[1]) == E.ELifeProfession.Cook then
    local cookVm = Z.VMMgr.GetVM("cook")
    cookVm.OpenCookView(param[2])
  elseif tonumber(param[1]) == E.ELifeProfession.Chemistry then
    local chemistryVm = Z.VMMgr.GetVM("chemistry")
    chemistryVm.OpenChemistryMainView(param[2], tonumber(param[3]) == 1)
  else
    local lifeProfessionVm = Z.VMMgr.GetVM("life_profession")
    lifeProfessionVm.OpenCastMainView(tonumber(param[1]), param[2], tonumber(param[3]) == 1)
  end
end
local VMFuction = function(uuid, param, token)
  local vm = Z.VMMgr.GetVM(param[2])
  if not vm then
    return false
  end
  local vmFunc = vm[param[1]]
  if not vmFunc then
    return false
  end
  vmFunc(uuid, token, param)
end
local Tips = function(uuid, param, token)
  Z.TipsVM.ShowTipsLang(tonumber(param[1]))
end
local WindZone = function(uuid, param)
  local triggerRange = param[1]
  local actionParam = param[2]
  if #actionParam < 1 or #triggerRange < 2 then
    logError("WindZone InterAction Param Invalid")
    return
  end
  local attachSpeed = tonumber(actionParam[1])
  local windZoneHeight = tonumber(triggerRange[2])
  Panda.ZGame.ZMoveDataMgr.WindZoneAttachVelocity(Z.EntityMgr.PlayerUuid, uuid, attachSpeed, windZoneHeight)
end
local WindRing = function(uuid, param)
  local actionParam = param[2]
  if #actionParam < 2 then
    logError("WindRing InterAction Param Invalid")
    return
  end
  local attachSpeed = tonumber(actionParam[1])
  local decelerate = tonumber(actionParam[2])
  Panda.ZGame.ZMoveDataMgr.WindRingAttachVelocity(Z.EntityMgr.PlayerUuid, uuid, attachSpeed, decelerate)
end
local WindTornado = function(uuid, param)
  local actionParam = param[2]
  if #actionParam < 3 then
    logError("WindTornado InterAction Param Invalid")
    return
  end
  local k1 = tonumber(actionParam[1])
  local k2 = tonumber(actionParam[2])
  local k3 = tonumber(actionParam[3])
  Panda.ZGame.ZMoveDataMgr.WindTornadoAttachVelocity(Z.EntityMgr.PlayerUuid, uuid, k1, k2, k3)
end
local DanceTogether = function(uuid, param)
  local actionId = tonumber(param[2][1])
  Z.ZAnimActionPlayMgr:PlayAction(actionId, true, 0, -1, false, 0, true)
end
local WindZoneEnd = function(uuid, param)
  local sourceType = Panda.ZGame.EAttachVelocitySource.WindZone:ToInt()
  Panda.ZGame.ZMoveDataMgr.StopAttachVelocity(Z.EntityMgr.PlayerUuid, sourceType)
end
local WindRingEnd = function(uuid, param)
  local sourceType = Panda.ZGame.EAttachVelocitySource.WindRing:ToInt()
  Panda.ZGame.ZMoveDataMgr.StopAttachVelocity(Z.EntityMgr.PlayerUuid, sourceType)
end
local WindTornadoEnd = function(uuid, param)
  local sourceType = Panda.ZGame.EAttachVelocitySource.WindTornado:ToInt()
  Panda.ZGame.ZMoveDataMgr.StopAttachVelocity(Z.EntityMgr.PlayerUuid, sourceType)
end
local UnionHuntEntry = function(uuid, param)
  local unionVM_ = Z.VMMgr.GetVM("union")
  local dungeonId_ = tonumber(param[1])
  unionVM_:OpenHuntEnterView(dungeonId_)
end
local UnionBuild = function(uuid, param)
  local buildId = tonumber(param[1])
  local unionVM = Z.VMMgr.GetVM("union")
  unionVM:OpenUnionBuildViewById(buildId)
end
local StartFlow = function(uuid, param)
  local type = Z.PbEnum("WorldEventType", "PlayFlow")
  Z.LevelMgr.FireSceneEvent({eventType = type, intParams = param})
end
local ShowCutScene = function(uuid, param)
  local type = Z.PbEnum("WorldEventType", "PlayCutScene")
  Z.LevelMgr.FireSceneEvent({eventType = type, intParams = param})
end
local UnionBuildFunc = function(uuid, param)
  local buildId = tonumber(param[1])
  local unionVM = Z.VMMgr.GetVM("union")
  unionVM:OpenUnionBuildFunctionViewById(buildId, uuid, table.unpack(param, 2))
end
local ExploreMonsterDeplete = function(uuid, param)
  local templateId_ = param[1]
  local itemId_ = tonumber(param[2][1])
  local d_ = {
    uuid = uuid,
    templateId = templateId_,
    itemId = itemId_
  }
  local ExploreMonsterVM_ = Z.VMMgr.GetVM("explore_monster")
  ExploreMonsterVM_.OpenExploreMonsterDepleteWindow(d_)
end
local SendAiEvent = function(uuid, param)
  local eventId = tonumber(param[1])
  local entType = 0
  local entId = 0
  if param[2] and param[3] then
    entType = tonumber(param[2])
    entId = tonumber(param[3])
  else
    entType = uuidToEntType(uuid)
    entId = uuidToEntId(uuid)
  end
  Panda.ZGame.ZAIMgr.Instance:SendEvent(entId, entType, eventId)
end
local DoNoThing = function(uuid, param)
end
local UnionWarDance = function(uuid, param, token)
  local unionWarDanceVm = Z.VMMgr.GetVM("union_wardance")
  if unionWarDanceVm:isInWarDanceActivity() or unionWarDanceVm:isinWillOpenWarDanceActivity() then
    unionWarDanceVm:OpenDanceView()
  end
  local unionWarDanceData_ = Z.DataMgr.Get("union_wardance_data")
  unionWarDanceData_:SetIsInDanceArea(true)
end
local UnionWarDanceEnd = function(uuid, param, token)
  local unionWarDanceVm = Z.VMMgr.GetVM("union_wardance")
  unionWarDanceVm:CloseDanceView()
  local unionWarDanceData_ = Z.DataMgr.Get("union_wardance_data")
  unionWarDanceData_:SetIsInDanceArea(false)
end
local HomeFarmEnd = function(uuid, param, token)
  local houseVm = Z.VMMgr.GetVM("house")
  houseVm.CloseHousePlayFarmMainView(uuid, param[2])
  houseVm.CloseHousePlayFarmTipsView(uuid, param[2])
end
local EnterHomeFarm = function(uuid, param, token)
  local houseVm = Z.VMMgr.GetVM("house")
  houseVm.OpenHousePlayFarmMainView(uuid, param[2], param[1])
end
local EnterAutoFlow = function(uuid, param)
  Panda.ZGame.ZMoveDataMgr.StartAutoFlow()
end
local EnterBubble = function(uuid, param, token)
  local bubbleData = Z.DataMgr.Get("bubble_data")
  local bubbleId = tonumber(param[1])
  local actTableRow = Z.TableMgr.GetTable("BubbleActTableMgr").GetRow(bubbleId, true)
  if not actTableRow then
    return
  end
  if not Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(actTableRow.FunctionId, true) then
    return
  end
  bubbleData:SetCurBubbleId(bubbleId)
  Z.EventMgr:Dispatch(Z.ConstValue.Bubble.CurrentIdChanged)
end
local BubbleEnd = function(uuid, param, token)
  local bubbleId = tonumber(param[1])
  local bubbleData = Z.DataMgr.Get("bubble_data")
  bubbleData:SetCurBubbleId(0)
  bubbleData:SetDisplayedBubbleView(false)
  local worldProxy = require("zproxy.world_proxy")
  Z.CoroUtil.create_coro_xpcall(function()
    local request = {bubbleActId = bubbleId}
    local cancelSource = Z.CancelSource.Rent()
    worldProxy.EndBubbleAct(request, cancelSource:CreateToken())
    cancelSource:Recycle()
  end)()
  Z.EventMgr:Dispatch(Z.ConstValue.Bubble.CurrentIdChanged)
end
local InteractionActionDic = {
  [Z.PbEnum("EInteractionAction", "EInteractionActionNpcTalk")] = NpcTalk,
  [Z.PbEnum("EInteractionAction", "EInteractionActionNpcTalkFlow")] = NpcTalkFlow,
  [Z.PbEnum("EInteractionAction", "EInteractionActionDungeonEntry")] = DungeonEntry,
  [Z.PbEnum("EInteractionAction", "EInteractionActionFunctionEntry")] = FunctionEntry,
  [Z.PbEnum("EInteractionAction", "EInteractionActionClientSceneEvent")] = ClientSceneEvent,
  [Z.PbEnum("EInteractionAction", "EInteractionActionOptionSelect")] = OptionSelect,
  [Z.PbEnum("EInteractionAction", "EInteractionActionHeroNormalDungeon")] = HeroNormalDungeon,
  [Z.PbEnum("EInteractionAction", "EInteractionActionHeroChallengeDungeon")] = HeroChallengeDungeon,
  [Z.PbEnum("EInteractionAction", "EInteractionActionVMFuction")] = VMFuction,
  [Z.PbEnum("EInteractionAction", "EInteractionActionTips")] = Tips,
  [Z.PbEnum("EInteractionAction", "EInteractionActionOpenUI")] = OpenUI,
  [Z.PbEnum("EInteractionAction", "EInteractionActionWindZone")] = WindZone,
  [Z.PbEnum("EInteractionAction", "EInteractionActionWindRing")] = WindRing,
  [Z.PbEnum("EInteractionAction", "EInteractionActionWindTornado")] = WindTornado,
  [Z.PbEnum("EInteractionAction", "EInteractionActionDanceTogether")] = DanceTogether,
  [Z.PbEnum("EInteractionAction", "EInteractionActionStartFlow")] = StartFlow,
  [Z.PbEnum("EInteractionAction", "EInteractionActionShowCutScene")] = ShowCutScene,
  [Z.PbEnum("EInteractionAction", "EInteractionActionUnionHuntEntry")] = UnionHuntEntry,
  [Z.PbEnum("EInteractionAction", "EInteractionActionUnionBuild")] = UnionBuild,
  [Z.PbEnum("EInteractionAction", "EInteractionActionUnionBuildFunc")] = UnionBuildFunc,
  [Z.PbEnum("EInteractionAction", "EInteractionActionExploreMonsterDeplete")] = ExploreMonsterDeplete,
  [Z.PbEnum("EInteractionAction", "EInteractionActionSendClientAiEvent")] = SendAiEvent,
  [Z.PbEnum("EInteractionAction", "EInteractionActionDoNoThing")] = DoNoThing,
  [Z.PbEnum("EInteractionAction", "EInteractionActionCookFunc")] = CookFunc,
  [Z.PbEnum("EInteractionAction", "EInteractionActionUnionWarDance")] = UnionWarDance,
  [Z.PbEnum("EInteractionAction", "EInteractionActionEnterAutoFlow")] = EnterAutoFlow,
  [Z.PbEnum("EInteractionAction", "EInteractionActionHomeFarm")] = EnterHomeFarm,
  [Z.PbEnum("EInteractionAction", "EInteractionActionBubbleActStart")] = EnterBubble,
  [Z.PbEnum("EInteractionAction", "EInteractionActionBubbleActEnd")] = BubbleEnd
}
local InteractionEndTriggerActionDic = {
  [Z.PbEnum("EInteractionAction", "EInteractionActionWindZone")] = WindZoneEnd,
  [Z.PbEnum("EInteractionAction", "EInteractionActionWindRing")] = WindRingEnd,
  [Z.PbEnum("EInteractionAction", "EInteractionActionWindTornado")] = WindTornadoEnd,
  [Z.PbEnum("EInteractionAction", "EInteractionActionUnionWarDance")] = UnionWarDanceEnd,
  [Z.PbEnum("EInteractionAction", "EInteractionActionHomeFarm")] = HomeFarmEnd,
  [Z.PbEnum("EInteractionAction", "EInteractionActionBubbleActStart")] = BubbleEnd
}
local InteractionAborActionDic = {
  [Z.PbEnum("EInteractionAction", "EInteractionActionNpcTalkFlow")] = NpcTalkFlowAbort
}
local InteractionEndActionDic = {
  [Z.PbEnum("EInteractionAction", "EInteractionActionNpcTalkFlow")] = NpcTalkFlowEnd
}
local InteractionActionBackDic = {}
local parseParam = function(interactionCfgId, templateId, actionType, actionParam, interConfig)
  local param
  if actionType == Z.PbEnum("EInteractionAction", "EInteractionActionClientSceneEvent") then
    param = actionParam
  elseif actionType == Z.PbEnum("EInteractionAction", "EInteractionActionWindZone") or actionType == Z.PbEnum("EInteractionAction", "EInteractionActionWindRing") or actionType == Z.PbEnum("EInteractionAction", "EInteractionActionWindTornado") then
    param = {
      interConfig.TriggerRange,
      actionParam
    }
  elseif actionType == Z.PbEnum("EInteractionAction", "EInteractionActionDanceTogether") or actionType == Z.PbEnum("EInteractionAction", "EInteractionActionExploreMonsterDeplete") then
    param = {
      templateId,
      actionParam,
      interactionCfgId
    }
  elseif actionType == Z.PbEnum("EInteractionAction", "EInteractionActionHomeFarm") or actionType == Z.PbEnum("EInteractionAction", "EInteractionActionHomeFarm") then
    param = {actionParam, interactionCfgId}
  else
    param = actionParam
  end
  return param
end
local doInteractionAction = function(uuid, interactionCfgId, templateId, data, cancelSource)
  local interConfig = Z.TableMgr.GetTable("InteractiveTableMgr").GetRow(templateId)
  if interConfig == nil then
    logError("doInteractionAction Error templateId = " .. templateId)
    return
  end
  local token = ZUtil.ZCancelSource.NeverCancelToken
  if cancelSource ~= nil then
    token = cancelSource:CreateToken()
  end
  local param = parseParam(interactionCfgId, templateId, data.Action, data.Param, interConfig)
  local doFunc = InteractionActionDic[data.Action]
  if doFunc then
    logGreen("Do Interaction Action: uuid={0}, interactionCfgId={1},templateId={2}, actiontype={3}, scene={4}, entType={5}, entId={6}, param={7}", uuid, interactionCfgId, templateId, data.Action, Z.StageMgr.GetCurrentSceneId(), uuidToEntType(uuid), uuidToEntId(uuid), table.ztostring(param))
    Z.CoroUtil.create_coro_xpcall(function()
      doFunc(uuid, param, token)
    end)()
  else
    logError("interaction action not found: uuid={0}, interactionCfgId={1},templateId={2}, actiontype={3}, scene={4}, entType={5}, entId={6}", uuid, interactionCfgId, templateId, data.Action, Z.StageMgr.GetCurrentSceneId(), uuidToEntType(uuid), uuidToEntId(uuid))
  end
end
local doInteractionEndTriggerAction = function(uuid, interactionCfgId, templateId, data, cancelSource)
  local interConfig = Z.TableMgr.GetTable("InteractiveTableMgr").GetRow(templateId)
  if interConfig == nil then
    logError("doInteractionAction Error templateId = " .. templateId)
    return
  end
  local token = ZUtil.ZCancelSource.NeverCancelToken
  if cancelSource ~= nil then
    token = cancelSource:CreateToken()
  end
  local param = parseParam(interactionCfgId, templateId, data.Action, data.Param, interConfig)
  local doFunc = InteractionEndTriggerActionDic[data.Action]
  if doFunc then
    logGreen("Do Interaction Action End Trigger: uuid={0}, interactionCfgId={1},templateId={2}, actiontype={3}, scene={4}, entType={5}, entId={6}, param={7}", uuid, interactionCfgId, templateId, data.Action, Z.StageMgr.GetCurrentSceneId(), uuidToEntType(uuid), uuidToEntId(uuid), table.ztostring(param))
    doFunc(uuid, param, token)
  end
end
local doInteractionActionAbort = function(uuid, interactionCfgId, templateId, data, cancelSource)
  local interConfig = Z.TableMgr.GetTable("InteractiveTableMgr").GetRow(templateId)
  local token = ZUtil.ZCancelSource.NeverCancelToken
  if cancelSource ~= nil then
    token = cancelSource:CreateToken()
  end
  local param = parseParam(interactionCfgId, templateId, data.Action, data.Param, interConfig)
  local doFunc = InteractionAborActionDic[data.Action]
  if doFunc then
    logGreen("Do Interaction Action abort: uuid={0}, interactionCfgId={1},templateId={2}, actiontype={3}, scene={4}, entType={5}, entId={6}, param={7}", uuid, interactionCfgId, templateId, data.Action, Z.StageMgr.GetCurrentSceneId(), uuidToEntType(uuid), uuidToEntId(uuid), table.ztostring(param))
    doFunc(uuid, param, token)
  end
end
local doInteractionActionEnd = function(uuid, interactionCfgId, templateId, data, cancelSource)
  local interConfig = Z.TableMgr.GetTable("InteractiveTableMgr").GetRow(templateId)
  local token = ZUtil.ZCancelSource.NeverCancelToken
  if cancelSource ~= nil then
    token = cancelSource:CreateToken()
  end
  local param = parseParam(interactionCfgId, templateId, data.Action, data.Param, interConfig)
  local doFunc = InteractionEndActionDic[data.Action]
  if doFunc then
    logGreen("Do Interaction Action End: uuid={0}, interactionCfgId={1},templateId={2}, actiontype={3}, scene={4}, entType={5}, entId={6}, param={7}", uuid, interactionCfgId, templateId, data.Action, Z.StageMgr.GetCurrentSceneId(), uuidToEntType(uuid), uuidToEntId(uuid), table.ztostring(param))
    doFunc(uuid, param, token)
  end
end
local doInteractionActionBack = function(isSuccess, uuid, templateId, interactionCfgId, actionType)
  local interConfig = Z.TableMgr.GetTable("InteractiveTableMgr").GetRow(templateId)
  if interConfig == nil then
    logError("doInteractionActionBack Error templateId = " .. templateId)
    return
  end
  local doFunc = InteractionActionBackDic[actionType]
  if doFunc then
    doFunc(isSuccess, uuid, templateId, interactionCfgId)
  end
end
local ret = {
  DoInteractionAction = doInteractionAction,
  DoInteractionEndTriggerAction = doInteractionEndTriggerAction,
  DoInteractionActionBack = doInteractionActionBack,
  DoInteractionActionAbort = doInteractionActionAbort,
  DoInteractionActionEnd = doInteractionActionEnd
}
return ret
