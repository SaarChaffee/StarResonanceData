local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[67] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 67,
    count = -1,
    entity = {actorType = 5, tableUid = 188},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, 6)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1073})
    end
  }
  self.EventItems[102425] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102425,
    count = -1,
    action = function(localSelf)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1071})
    end
  }
  self.EventItems[102505] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102505,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, 0)
    end
  }
  self.EventItems[53] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 53,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2034}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2030}, -1)
    end
  }
  self.EventItems[102182] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 102182,
    count = -1,
    entity = {actorType = 5, tableUid = 104126},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, 0)
    end
  }
  self.EventItems[102120] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 102120,
    count = -1,
    entity = {actorType = 5, tableUid = 103933},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, 4)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1072})
    end
  }
  self.EventItems[102121] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 102121,
    count = -1,
    entity = {actorType = 5, tableUid = 103934},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, 5)
    end
  }
end

return Scene
