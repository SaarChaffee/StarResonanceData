local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {2}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[886] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 886,
    count = -1,
    entity = {actorType = 5, tableUid = 991},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
    end
  }
  self.EventItems[887] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 887,
    count = -1,
    entity = {actorType = 5, tableUid = 991},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
    end
  }
  self.EventItems[100472] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 100472,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2032}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2030}, -1)
    end
  }
  self.EventItems[101355] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 101355,
    count = 1,
    entity = {actorType = 5, tableUid = 102280},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1025})
    end
  }
end

return Scene
