local Scene = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[1080] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 1080,
    count = -1,
    action = function(localSelf)
      logGreen(string.format("\231\142\176\229\156\168\230\152\175\232\181\155\229\173\1632\239\188\140season2 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
end

return Scene
