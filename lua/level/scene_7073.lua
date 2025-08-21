local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[28] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 28,
    count = -1,
    action = function(localSelf)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_worldevent7073")
      logGreen(string.format("----------\229\138\160\232\189\1897073\229\173\144\229\156\186\230\153\175---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[60] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 60,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 3, groupId = 15}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 24,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:CreateClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      logGreen(string.format("-----\229\136\155\229\187\18604\231\169\186\230\176\148\229\162\153(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
end

return Scene
