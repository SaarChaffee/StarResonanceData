local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[1] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 1,
    count = -1,
    action = function(localSelf)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/dng_raid_001_03")
    end
  }
end

return Scene
