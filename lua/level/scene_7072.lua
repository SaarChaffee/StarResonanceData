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
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_worldevent7072")
      logGreen(string.format("----------\229\138\160\232\189\1897072\229\173\144\229\156\186\230\153\175---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[37] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 37,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      do
        local entityData = {actorType = 5, groupId = 14}
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
    end
  }
  self.EventItems[38] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 38,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      do
        local entityData = {actorType = 5, groupId = 15}
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
    end
  }
end

return Scene
