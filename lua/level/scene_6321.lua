local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {1}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[101390] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 8,
    eventId = 101390,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2032}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2030}, -1)
    end
  }
  self.EventItems[101735] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 50610001,
    group = 8,
    eventId = 101735,
    count = -1,
    action = function(localSelf)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1033})
    end
  }
  self.EventItems[101739] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 8,
    eventId = 101739,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1032})
    end
  }
end

return Scene
