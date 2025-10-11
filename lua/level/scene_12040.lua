local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[19] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 19,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/union_activity_sublevel_001")
      Panda.LuaAsyncBridge.SetCurWeatherTime(8)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
end

return Scene
