local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[144] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 144,
    count = -1,
    action = function(localSelf)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld002_sublevel_001")
    end
  }
  self.EventItems[67] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 67,
    count = -1,
    entity = {actorType = 5, tableUid = 696},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("5603/5603_zhuizhu_1", 0, 0, 70, false, 0)
      do
        local entityData = {actorType = 5, tableUid = 696}
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
  self.EventItems[68] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 68,
    count = -1,
    entity = {actorType = 5, tableUid = 697},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("5603/5603_zhuizhu_1")
      do
        local entityData = {actorType = 5, tableUid = 697}
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
  self.EventItems[77] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 77,
    count = -1,
    layerConfigId = 5603,
    action = function(localSelf, layerConfigId)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("5603/5603_zhuizhu_1")
    end
  }
  self.EventItems[127] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 127,
    count = -1,
    layerConfigId = 5604,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/fld002_sublevel_001")
    end
  }
  self.EventItems[128] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 128,
    count = -1,
    layerConfigId = 5604,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld002_sublevel_001")
    end
  }
  self.EventItems[116] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 116,
    count = -1,
    entity = {actorType = 5, tableUid = 800},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"10090103", ""}
      })
    end
  }
  self.EventItems[117] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 117,
    count = -1,
    entity = {actorType = 5, tableUid = 801},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"10090104", ""}
      })
    end
  }
  self.EventItems[118] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 118,
    count = -1,
    entity = {actorType = 5, tableUid = 802},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"10090105", ""}
      })
    end
  }
  self.EventItems[119] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 119,
    count = -1,
    entity = {actorType = 5, tableUid = 803},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"10090106", ""}
      })
    end
  }
end

return Scene
