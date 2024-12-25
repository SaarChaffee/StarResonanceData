local Scene = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[679] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 679,
    count = -1,
    action = function(localSelf)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/cty001_festival_001")
    end
  }
  self.EventItems[1078] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 1078,
    count = -1,
    action = function(localSelf)
      logGreen(string.format("\231\142\176\229\156\168\230\152\175\232\181\155\229\173\1631\239\188\140season1 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
end

return Scene
