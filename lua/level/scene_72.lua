local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[140] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 140,
    count = -1,
    entity = {actorType = 5, tableUid = 572},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("scene").CheckSceneUnlockByTrigger(71, true)
    end
  }
  self.EventItems[141] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 141,
    count = -1,
    entity = {actorType = 5, tableUid = 572},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("scene").CheckSceneUnlockByTrigger(71, false)
    end
  }
  self.EventItems[138] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 138,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
    end
  }
end

return Scene
