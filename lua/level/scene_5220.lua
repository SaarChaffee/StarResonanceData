local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[6] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 6,
    count = -1,
    entity = {actorType = 5, tableUid = 64},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5220004", ""}
      })
    end
  }
  self.EventItems[7] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 7,
    count = -1,
    entity = {actorType = 5, tableUid = 65},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5220005", ""}
      })
    end
  }
  self.EventItems[8] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 8,
    count = -1,
    entity = {actorType = 5, tableUid = 66},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5220005", ""}
      })
    end
  }
  self.EventItems[13] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 13,
    count = -1,
    selectedStr = "on_10020162_flow_end",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5220009", ""}
      })
    end
  }
  self.EventItems[14] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 14,
    count = -1,
    entity = {actorType = 5, tableUid = 84},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5220010", ""}
      })
    end
  }
  self.EventItems[15] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 15,
    count = -1,
    entity = {actorType = 5, tableUid = 85},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5220010", ""}
      })
    end
  }
  self.EventItems[20] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 20,
    count = -1,
    entity = {actorType = 5, tableUid = 98},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5220011", ""}
      })
    end
  }
  self.EventItems[28] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 28,
    count = -1,
    entity = {actorType = 5, tableUid = 132},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5220017", ""}
      })
    end
  }
  self.EventItems[29] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 29,
    count = -1,
    entity = {actorType = 5, tableUid = 154},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5220011", ""}
      })
    end
  }
  self.EventItems[30] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 30,
    count = -1,
    entity = {actorType = 5, tableUid = 155},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5220011", ""}
      })
    end
  }
end

return Scene
