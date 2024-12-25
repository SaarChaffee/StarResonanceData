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
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = false,
    group = 0,
    eventId = 1,
    count = -1,
    entity = {actorType = 5, tableUid = 1},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 2}
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
      logGreen(string.format("-----\229\136\155\229\187\186\233\190\153\229\141\183\233\163\142\228\189\156\231\148\168\229\140\186\229\159\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[2] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = false,
    group = 0,
    eventId = 2,
    count = -1,
    entity = {actorType = 5, tableUid = 2},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 2}
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
      logGreen(string.format("-----\229\136\160\233\153\164\233\190\153\229\141\183\233\163\142\228\189\156\231\148\168\229\140\186\229\159\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
end

return Scene
