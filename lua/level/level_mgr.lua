local Mgr = {}
Mgr.timerMgr = Z.TimerMgr.new()
local LET = E.LevelEventType

function Mgr.FireSceneEvent(p)
  local e = Zproto.EventData.Rent()
  e.eventType = p.eventType
  if p.strParams then
    for _, data in pairs(p.strParams) do
      e.strParams:Add(data or "")
    end
  end
  if p.intParams then
    for _, data in pairs(p.intParams) do
      e.intParams:Add(data)
    end
  end
  if p.floatParams then
    for _, data in pairs(p.floatParams) do
      e.floatParams:Add(data)
    end
  end
  if p.longParams then
    for _, data in pairs(p.longParams) do
      e.longParams:Add(data)
    end
  end
  Z.EventParser.FireSceneEvent(e)
  e:Recycle()
  e = nil
end

function Mgr:OnEnterScene(sceneId)
  self.currentScene = {}
  self.eventMap = {}
  self.onSceneInitEventMap = {}
  Z.EventMgr:Add("level_event", self.OnLevelEventTrigger, self)
  Z.EventMgr:Add(Z.ConstValue.UIOpen, self.OnOpenUI, self)
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.OnCloseUI, self)
  self.currentScene = self:LoadScript(string.format("level.scene_%s", sceneId))
  if Z.GameContext.IsDevelopment == true then
    package.loaded["level.scene_" .. sceneId] = nil
  end
  self.sceneId = sceneId
  if self.currentScene and self.currentScene.Seasons then
    for _, seasonId in pairs(self.currentScene.Seasons) do
      if seasonId == Z.GameContext.SeasonId then
        logGreen("init season scene script" .. tostring(seasonId))
        self:LoadScript(string.format("level.season%s.scene_%s", seasonId, sceneId))
      end
    end
  end
  self:onSceneInit()
end

function Mgr:LoadScript(loadPath)
  local parentScene = require(loadPath)
  if parentScene then
    parentScene:InitEvents()
    for _, eventItem in pairs(parentScene.EventItems) do
      self:RegisterEventItemToMap(eventItem)
    end
  end
  return parentScene
end

function Mgr:OnOpenUI(viewConfigKey)
  self:HandleUIOpenOrCloseEvent(viewConfigKey, LET.OnUIOpen)
end

function Mgr:OnCloseUI(viewConfigKey)
  self:HandleUIOpenOrCloseEvent(viewConfigKey, LET.OnUIClose)
end

function Mgr:HandleUIOpenOrCloseEvent(viewConfigKey, et)
  local ec = self.eventMap[et]
  if ec ~= nil then
    local eventItem = ec[viewConfigKey]
    if eventItem then
      for _, item in pairs(eventItem) do
        item:action()
      end
    end
  end
end

function Mgr:OnLeaveScene()
  if self.eventMap ~= nil and self.eventMap[LET.OnSceneLeave] ~= nil then
    local onSceneLevenEventItems = self.eventMap[LET.OnSceneLeave]
    for _, eventItem in pairs(onSceneLevenEventItems) do
      eventItem:action()
    end
  end
  Z.EventMgr:Remove("level_event", self.OnLevelEventTrigger, self)
  Z.EventMgr:Remove(Z.ConstValue.UIOpen, self.OnOpenUI, self)
  Z.EventMgr:Remove(Z.ConstValue.UIClose, self.OnCloseUI, self)
  self.currentScene = nil
end

function Mgr:onSceneInit()
  if self.onSceneInitEventMap then
    for _, eventItem in pairs(self.onSceneInitEventMap) do
      eventItem:action()
    end
  end
end

function Mgr:OnLevelEventTrigger(...)
  local params = {
    ...
  }
  if not params or #params <= 0 then
    return
  end
  if not self.eventMap then
    return
  end
  local et = params[1]
  if et == LET.TriggerEvent then
    local eventId = tonumber(params[2]) or 0
    local levelUuid = tonumber(params[3]) or 0
    if eventId == 0 then
      logError("[level_mgr]\232\167\166\229\143\145\232\135\170\229\174\154\228\185\137\228\186\139\228\187\182\233\148\153\232\175\175\239\188\140\228\186\139\228\187\182Id\228\184\1860")
      return
    end
    local eventItem = self.currentScene.EventItems[eventId]
    if eventItem == nil then
      logError("[level_mgr]\232\167\166\229\143\145\232\135\170\229\174\154\228\185\137\228\186\139\228\187\182\229\164\177\232\180\165\239\188\140\228\184\141\229\173\152\229\156\168\232\175\165\228\186\139\228\187\182\239\188\140Id={0}", eventId)
      return
    end
    if eventItem.eventType ~= et then
      logError("[level_mgr]\232\167\166\229\143\145\232\135\170\229\174\154\228\185\137\228\186\139\228\187\182\229\164\177\232\180\165\239\188\140\228\184\141\230\152\175TriggerEvent\231\177\187\229\158\139\231\154\132\228\186\139\228\187\182\239\188\140Id={0}\239\188\140eventType={1}", eventId, eventItem.eventType)
      return
    end
    local curLevelUuid = Z.ContainerMgr.CharSerialize.sceneData.levelUuid
    if levelUuid ~= 0 and levelUuid ~= curLevelUuid then
      logError("[level_mgr]\232\167\166\229\143\145\232\135\170\229\174\154\228\185\137\228\186\139\228\187\182\229\164\177\232\180\165, levelUuid\228\184\141\229\140\185\233\133\141, curLevelUuid={0}, eventLevelUuid={0}", curLevelUuid, levelUuid)
      return
    end
    eventItem:action()
    return
  end
  local eventContainer = self.eventMap[et]
  if not eventContainer then
    return
  end
  if et >= LET.OnFlowPlayEnd and et <= LET.CustomEventEndFlag then
    local eventKeyParam = params[2]
    local eventList = eventContainer[eventKeyParam]
    if eventList then
      for _, eventItem in pairs(eventList) do
        eventItem:action()
      end
    end
  elseif et == LET.OnZoneEnterClient or et == LET.OnZoneExitClient then
    local ztp = params[2]
    local entKeyTbl = {actorType = 5}
    if ztp.IsGroup then
      entKeyTbl.groupId = ztp.GroupId
    else
      entKeyTbl.tableUid = ztp.ZoneEntId
    end
    local funKey = Mgr.KeyGen.EntityKey(entKeyTbl)
    local eventList = eventContainer[funKey]
    if eventList then
      for _, eventItem in pairs(eventList) do
        eventItem:action(ztp.IsGroup, ztp.ZoneEntId, ztp.GroupId, ztp.EventEntityParams)
      end
    end
  elseif et == LET.OnVisualLayerEnter or et == LET.OnVisualLayerLeave then
    local layerConfigId = params[2]
    local eventList = eventContainer[layerConfigId]
    if eventList then
      for _, eventItem in pairs(eventList) do
        eventItem:action(layerConfigId)
      end
    end
  elseif et == LET.OnPlayerStateEnter or et == LET.OnPlayerStateLeave then
    local state = tonumber(params[2])
    local eventList = eventContainer[state]
    if eventList then
      for _, eventItem in pairs(eventList) do
        eventItem:action(state)
      end
    end
  elseif et == LET.OnWorldQuestRefresh then
    for _, eventItem in pairs(eventContainer) do
      eventItem:action()
    end
  end
end

function Mgr:RegisterEventItemToMap(eventItem)
  local et = eventItem.eventType
  local tbl = self.eventMap
  if not tbl[et] then
    tbl[et] = {}
  end
  local eventContainer = tbl[et]
  if et == LET.OnZoneEnterClient or et == LET.OnZoneExitClient then
    local funKey = Mgr.KeyGen.EntityKey(eventItem.entity, eventItem.eventId)
    if not eventContainer[funKey] then
      eventContainer[funKey] = {}
    end
    table.insert(eventContainer[funKey], eventItem)
  elseif et == LET.OnCutsceneEnd then
    local tblCutsceneEndSingle = eventContainer[eventItem.cutsceneId]
    if not tblCutsceneEndSingle then
      eventContainer[eventItem.cutsceneId] = {}
      tblCutsceneEndSingle = eventContainer[eventItem.cutsceneId]
    end
    table.insert(tblCutsceneEndSingle, eventItem)
  elseif et == LET.OnSceneInit then
    table.insert(self.onSceneInitEventMap, eventItem)
  elseif et == LET.OnOptionSelect then
    local funKey = eventItem.selectedStr
    if not eventContainer[funKey] then
      eventContainer[funKey] = {}
    end
    table.insert(eventContainer[funKey], eventItem)
  elseif et == LET.OnFlowPlayEnd or et == LET.OnCutsceneEnd then
    local funKey = eventItem.selectedStr
    if not eventContainer[funKey] then
      eventContainer[funKey] = {}
    end
    table.insert(eventContainer[funKey], eventItem)
  elseif et == LET.OnSceneLeave then
    table.insert(eventContainer, eventItem)
  elseif et == LET.OnVisualLayerEnter or et == LET.OnVisualLayerLeave then
    local funKey = eventItem.layerConfigId
    if not eventContainer[funKey] then
      eventContainer[funKey] = {}
    end
    table.insert(eventContainer[funKey], eventItem)
  elseif et == LET.OnUIOpen or et == LET.OnUIClose then
    local funKey = eventItem.viewConfigKey
    if not eventContainer[funKey] then
      eventContainer[funKey] = {}
    end
    table.insert(eventContainer[funKey], eventItem)
  elseif et == LET.OnPlayerStateEnter or et == LET.OnPlayerStateLeave then
    local state = eventItem.state
    if not eventContainer[state] then
      eventContainer[state] = {}
    end
    table.insert(eventContainer[state], eventItem)
  elseif et == LET.OnWorldQuestRefresh then
    table.insert(eventContainer, eventItem)
  end
end

Mgr.KeyGen = {
  EntityKey = function(data, tips)
    if data.actorType == nil then
      logError("current level data error, event id:" .. tostring(tips))
      return tostring(data)
    end
    if data.groupId then
      return data.actorType .. data.groupId .. "_"
    else
      return data.actorType .. data.tableUid
    end
  end
}
return Mgr
