local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {1, 2}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[1314] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 1007,
    group = 0,
    eventId = 1314,
    count = 4,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1015})
    end
  }
  self.EventItems[100829] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 100829,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("HeroDungeon_Tower/Guide_easy", 0, 0, 20, false, 0)
    end
  }
  self.EventItems[102165] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 102165,
    count = -1,
    entity = {actorType = 5, tableUid = 104105},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.timerMgr:StartTimer(function()
        Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {4004})
        do
          local entityData = {actorType = 5, tableUid = 104105}
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
      end, 0.5)
    end
  }
end

return Scene
