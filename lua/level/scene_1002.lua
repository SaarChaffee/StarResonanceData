local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[1369] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 1369,
    count = 1,
    entity = {actorType = 5, tableUid = 1064},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000121", ""}
      })
    end
  }
  self.EventItems[1372] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1372,
    count = 1,
    entity = {actorType = 5, tableUid = 1064},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      do
        local entityData = {actorType = 2, groupId = 85}
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
  self.EventItems[1371] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1371,
    count = 1,
    entity = {actorType = 5, tableUid = 1063},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      do
        local entityData = {actorType = 2, groupId = 85}
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
  self.EventItems[1294] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1294,
    count = 1,
    entity = {actorType = 5, tableUid = 969},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZGame.ZEventParser.PreLoadCutscene(10104012)
      do
        local entityData = {actorType = 3, tableUid = 949}
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
  self.EventItems[1426] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 1103,
    group = 0,
    eventId = 1426,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000145", ""}
      })
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000146", ""}
      })
    end
  }
  self.EventItems[1395] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1395,
    count = 1,
    entity = {actorType = 5, tableUid = 1018},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      do
        local entityData = {actorType = 3, tableUid = 949}
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
  self.EventItems[1309] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1309,
    count = 1,
    entity = {actorType = 5, tableUid = 982},
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
  self.EventItems[1421] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 1037,
    group = 0,
    eventId = 1421,
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
  self.EventItems[1217] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1217,
    count = -1,
    entity = {actorType = 5, tableUid = 536},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
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
      }, 12)
    end
  }
  self.EventItems[1075] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 1075,
    count = -1,
    action = function(localSelf)
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
      }, 12)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2032}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2030}, 0)
    end
  }
  self.EventItems[1271] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 1271,
    count = -1,
    entity = {actorType = 5, tableUid = 536},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
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
      }, 12)
    end
  }
  self.EventItems[1284] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 1027,
    group = 0,
    eventId = 1284,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1018})
    end
  }
  self.EventItems[1427] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1427,
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
  self.EventItems[1428] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1428,
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
  self.EventItems[1429] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1429,
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
  self.EventItems[1388] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1388,
    count = 1,
    entity = {actorType = 5, tableUid = 1073},
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
  self.EventItems[1390] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1390,
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
end

return Scene
