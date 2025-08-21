local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {2}

function Scene:InitEvents()
  self.EventItems = {}
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
  self.EventItems[102436] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102436,
    count = -1,
    action = function(localSelf)
      Panda.Streaming.StreamingManager.Instance:RefreshSceneObjState(1, false)
    end
  }
  self.EventItems[102437] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102437,
    count = -1,
    action = function(localSelf)
      Panda.Streaming.StreamingManager.Instance:RefreshSceneObjState(2, false)
    end
  }
  self.EventItems[102438] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102438,
    count = -1,
    action = function(localSelf)
      Panda.Streaming.StreamingManager.Instance:RefreshSceneObjState(1, true)
      Panda.Streaming.StreamingManager.Instance:RefreshSceneObjState(2, true)
    end
  }
end

return Scene
