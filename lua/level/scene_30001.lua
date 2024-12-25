local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[3] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3,
    count = -1,
    entity = {actorType = 5, tableUid = 6},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.EventMgr:Dispatch(Z.ConstValue.EnterHomeLand, 1, true)
    end
  }
  self.EventItems[5] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 5,
    count = -1,
    entity = {actorType = 5, tableUid = 6},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.EventMgr:Dispatch(Z.ConstValue.EnterHomeLand, 1, false)
    end
  }
  self.EventItems[6] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 6,
    count = -1,
    entity = {actorType = 5, tableUid = 7},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.EventMgr:Dispatch(Z.ConstValue.EnterHomeLand, 2, true)
    end
  }
  self.EventItems[7] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 7,
    count = -1,
    entity = {actorType = 5, tableUid = 7},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.EventMgr:Dispatch(Z.ConstValue.EnterHomeLand, 2, false)
    end
  }
  self.EventItems[8] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 8,
    count = -1,
    entity = {actorType = 5, tableUid = 5},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.EventMgr:Dispatch(Z.ConstValue.EnterHomeLand, 3, true)
    end
  }
  self.EventItems[9] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 9,
    count = -1,
    entity = {actorType = 5, tableUid = 5},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.EventMgr:Dispatch(Z.ConstValue.EnterHomeLand, 3, false)
    end
  }
end

return Scene
