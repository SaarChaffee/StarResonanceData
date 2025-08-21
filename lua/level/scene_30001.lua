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
    entity = {actorType = 5, tableUid = 114},
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
    entity = {actorType = 5, tableUid = 114},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.EventMgr:Dispatch(Z.ConstValue.EnterHomeLand, 1, false)
    end
  }
end

return Scene
