local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[4] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 4,
    count = -1,
    action = function(localSelf)
      Panda.LuaAsyncBridge.SetCurWeatherTime(7)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
end

return Scene
