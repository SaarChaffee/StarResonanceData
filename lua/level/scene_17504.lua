local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[70] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 70,
    count = -1,
    entity = {actorType = 5, groupId = 9},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
    end
  }
  self.EventItems[71] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 71,
    count = -1,
    entity = {actorType = 5, groupId = 9},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
    end
  }
end

return Scene
