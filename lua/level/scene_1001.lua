local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[1460] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1460,
    count = 1,
    entity = {actorType = 5, tableUid = 480},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000193", ""}
      })
    end
  }
  self.EventItems[1461] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1461,
    count = 1,
    entity = {actorType = 5, tableUid = 533},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000202", ""}
      })
    end
  }
  self.EventItems[1542] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1542,
    count = 1,
    entity = {actorType = 5, tableUid = 1155},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      do
        local entityData = {actorType = 2, groupId = 10}
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
  self.EventItems[1325] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 1325,
    count = -1,
    selectedStr = "sitdown",
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        0,
        3,
        4,
        5,
        10
      }, true, localSelf.eventId)
    end
  }
  self.EventItems[1327] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 10104011,
    group = 0,
    eventId = 1327,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1, localSelf.eventId)
    end
  }
  self.EventItems[1481] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1481,
    count = 1,
    entity = {actorType = 5, tableUid = 1075},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000166", ""}
      })
      Panda.ZGame.ZEventParser.PreLoadCutscene(10104011)
      Panda.ZGame.ZEventParser.PreLoadCutscene(10104012)
    end
  }
  self.EventItems[1446] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1446,
    count = 1,
    entity = {actorType = 5, tableUid = 1139},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {1037}
      })
    end
  }
  self.EventItems[1568] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 1037,
    group = 0,
    eventId = 1568,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000149", ""}
      })
    end
  }
  self.EventItems[1317] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1317,
    count = 1,
    entity = {actorType = 5, tableUid = 1087},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiBattleUIIgnoreOneLayer({0}, true, localSelf.eventId)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        3,
        4,
        5,
        10,
        17,
        19,
        20,
        24,
        26,
        27
      }, true, localSelf.eventId)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(12, true, {5003}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({
        1,
        1,
        1,
        1,
        1
      }, {
        5000,
        5001,
        5002,
        5004,
        5005
      }, -1)
    end
  }
  self.EventItems[1318] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 1318,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1, localSelf.eventId)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(12, false, {0}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({
        0,
        0,
        0,
        0,
        0
      }, {
        5000,
        5001,
        5002,
        5004,
        5005
      }, -1)
    end
  }
  self.EventItems[1513] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 1513,
    count = 1,
    entity = {actorType = 5, tableUid = 1087},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiBattleUIIgnoreOneLayer({0}, false, localSelf.eventId)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        3,
        4,
        5,
        10,
        17,
        19,
        20,
        24,
        26,
        27
      }, false, localSelf.eventId)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(12, false, {0}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({
        0,
        0,
        0,
        0,
        0
      }, {
        5000,
        5001,
        5002,
        5004,
        5005
      }, -1)
    end
  }
  self.EventItems[1499] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1499,
    count = 1,
    entity = {actorType = 5, tableUid = 15},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      do
        local entityData = {actorType = 3, tableUid = 522}
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
      do
        local entityData = {actorType = 3, tableUid = 520}
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
  self.EventItems[1554] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1554,
    count = 1,
    entity = {actorType = 5, tableUid = 1163},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        5,
        10,
        18
      }, true, localSelf.eventId)
    end
  }
  self.EventItems[1555] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1555,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        5,
        10,
        18
      }, false, localSelf.eventId)
    end
  }
  self.EventItems[1575] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1575,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.Streaming.StreamingManager.Instance:RefreshSceneObjState(1, false)
    end
  }
  self.EventItems[1576] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1576,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.Streaming.StreamingManager.Instance:RefreshSceneObjState(2, false)
    end
  }
  self.EventItems[1577] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1577,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.Streaming.StreamingManager.Instance:RefreshSceneObjState(1, true)
      Panda.Streaming.StreamingManager.Instance:RefreshSceneObjState(2, true)
    end
  }
end

return Scene
