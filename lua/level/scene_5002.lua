local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[21] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 21,
    count = 1,
    entity = {actorType = 5, tableUid = 13},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {102})
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("dng_5002/5002_GuideLine_01")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("dng_5002/5002_GuideLine_01", 1, 2, 20, false, 2)
    end
  }
  self.EventItems[35] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 101010103,
    group = 0,
    eventId = 35,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("dng_5002/5002_GuideLine_01", 0, 1, 10, false, 2)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {101})
    end
  }
  self.EventItems[70] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 101010101,
    group = 0,
    eventId = 70,
    count = -1,
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {101010102}
      })
    end
  }
  self.EventItems[71] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 101010102,
    group = 0,
    eventId = 71,
    count = -1,
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {101010103}
      })
    end
  }
  self.EventItems[39] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 39,
    count = 1,
    entity = {actorType = 5, tableUid = 48},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("dng_5002/5002_GuideLine_01")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("dng_5002/5002_GuideLine_01", 1, 4, 20, false, 2)
    end
  }
  self.EventItems[55] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 101010104,
    group = 0,
    eventId = 55,
    count = -1,
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {101010105}
      })
    end
  }
  self.EventItems[82] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 82,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1)
    end
  }
  self.EventItems[83] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 83,
    count = -1,
    layerConfigId = 5003,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1)
    end
  }
  self.EventItems[59] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 59,
    count = -1,
    layerConfigId = 5003,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiBattleUIIgnoreOneLayer({0}, true)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        5,
        9,
        10,
        11,
        12,
        17,
        18,
        19,
        20
      }, true)
      require("zproxy.world_proxy").UserDoAction("cutsceneReplay")
      Z.LevelMgr.timerMgr:StartTimer(function()
        Panda.ZGame.ZEventParser.PreLoadCutscene(101010102)
      end, 3)
    end
  }
  self.EventItems[77] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 77,
    count = -1,
    entity = {actorType = 5, tableUid = 85},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("dng_5002/5002_GuideLine_01", 1, 4, 20, false, 2)
    end
  }
  self.EventItems[64] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 64,
    count = 1,
    entity = {actorType = 5, tableUid = 74},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"3000024", ""}
      })
    end
  }
  self.EventItems[65] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = false,
    group = 0,
    eventId = 65,
    count = 1,
    entity = {actorType = 5, tableUid = 76},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"3000025", ""}
      })
    end
  }
  self.EventItems[92] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 101010101,
    group = 0,
    eventId = 92,
    count = -1,
    action = function(localSelf)
      require("zproxy.world_proxy").UserDoAction("changeBuff")
      Z.LevelMgr.timerMgr:StartTimer(function()
        Panda.ZGame.ZEventParser.PreLoadCutscene(101010103)
      end, 1)
    end
  }
  self.EventItems[93] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 101010102,
    group = 0,
    eventId = 93,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZEventParser.PreLoadCutscene(101010104)
    end
  }
  self.EventItems[94] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 101010103,
    group = 0,
    eventId = 94,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZEventParser.PreLoadCutscene(101010105)
    end
  }
  self.EventItems[95] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 101010104,
    group = 0,
    eventId = 95,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZEventParser.PreLoadCutscene(101010106)
    end
  }
  self.EventItems[68] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 68,
    count = -1,
    entity = {actorType = 5, tableUid = 78},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.timerMgr:StartTimer(function()
        Panda.ZGame.ZIgnoreMgr.Instance:ModMultiBattleUIIgnoreOneLayer({0}, false)
        Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
          5,
          9,
          10,
          11,
          12,
          17,
          18,
          19,
          20
        }, false)
      end, 1)
    end
  }
  self.EventItems[69] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 101010105,
    group = 0,
    eventId = 69,
    count = -1,
    action = function(localSelf)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {210, 215})
      do
        local entityData = {actorType = 5, tableUid = 110}
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
  self.EventItems[108] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 108,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, tableUid = 110}
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
  self.EventItems[121] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 121,
    count = -1,
    entity = {actorType = 5, tableUid = 78},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiBattleUIIgnoreOneLayer({0}, true)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        5,
        9,
        10,
        11,
        12,
        17,
        18,
        19,
        20
      }, true)
    end
  }
end

return Scene
