local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[16] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 16,
    count = -1,
    entity = {actorType = 5, tableUid = 575},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("scene").CheckSceneUnlockByTrigger(72, true)
    end
  }
  self.EventItems[17] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 17,
    count = -1,
    entity = {actorType = 5, tableUid = 575},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("scene").CheckSceneUnlockByTrigger(72, false)
    end
  }
  self.EventItems[14] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 14,
    count = -1,
    action = function(localSelf)
      Panda.LuaAsyncBridge.SetCurWeatherTime(22)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
end

return Scene
