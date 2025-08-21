local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {1, 2}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[548] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 548,
    count = -1,
    entity = {actorType = 5, tableUid = 806},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1017})
    end
  }
  self.EventItems[100827] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 100827,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("HeroDungeon_Tina/Guide_easy", 0, 0, 20, false, 0)
    end
  }
  self.EventItems[101348] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 101348,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2032}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2030}, 0)
    end
  }
  self.EventItems[102440] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102440,
    count = -1,
    action = function(localSelf)
      Panda.Streaming.StreamingManager.Instance:RefreshSceneObjState(1, false)
    end
  }
  self.EventItems[102441] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102441,
    count = -1,
    action = function(localSelf)
      Panda.Streaming.StreamingManager.Instance:RefreshSceneObjState(2, false)
    end
  }
  self.EventItems[102442] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102442,
    count = -1,
    action = function(localSelf)
      Panda.Streaming.StreamingManager.Instance:RefreshSceneObjState(1, true)
      Panda.Streaming.StreamingManager.Instance:RefreshSceneObjState(2, true)
    end
  }
end

return Scene
