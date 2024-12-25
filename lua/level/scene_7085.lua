local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[18] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 18,
    count = -1,
    action = function(localSelf)
      logGreen(string.format("----------\229\138\160\232\189\189\229\173\144\229\156\186\230\153\175----------(\229\188\128\229\167\139) : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_worldevent7085")
      logGreen(string.format("----------\229\138\160\232\189\189\229\173\144\229\156\186\230\153\175----------(\231\187\147\230\157\159) : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
end

return Scene
