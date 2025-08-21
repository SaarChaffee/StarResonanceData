local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[101069] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 101069,
    count = -1,
    entity = {actorType = 5, tableUid = 101646},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121105)
    end
  }
  self.EventItems[101070] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 101070,
    count = -1,
    entity = {actorType = 5, tableUid = 101648},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121109)
    end
  }
  self.EventItems[101071] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 101071,
    count = -1,
    entity = {actorType = 5, tableUid = 101651},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121115)
    end
  }
  self.EventItems[101082] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 101082,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, tableUid = 101646}
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
      do
        local entityData = {actorType = 5, tableUid = 101660}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 25,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:RemoveClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
    end
  }
end

return Scene
