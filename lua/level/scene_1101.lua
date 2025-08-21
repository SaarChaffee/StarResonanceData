local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[1027] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 1027,
    count = -1,
    selectedStr = "useA1imagine",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000014", ""}
      })
    end
  }
  self.EventItems[1317] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1317,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZEventParser.PreLoadFlow(110109)
    end
  }
  self.EventItems[1028] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 1028,
    count = -1,
    selectedStr = "CwatchL1",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000108", ""}
      })
    end
  }
  self.EventItems[1031] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 1031,
    count = -1,
    selectedStr = "CwatchL2",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000109", ""}
      })
    end
  }
  self.EventItems[1032] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 1032,
    count = -1,
    selectedStr = "CwatchR1",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000110", ""}
      })
    end
  }
  self.EventItems[1033] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 1033,
    count = -1,
    selectedStr = "CwatchR2",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000111", ""}
      })
    end
  }
  self.EventItems[1034] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 1034,
    count = -1,
    selectedStr = "CwatchM1",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000112", ""}
      })
    end
  }
  self.EventItems[1035] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 1035,
    count = -1,
    selectedStr = "CwatchM2",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000113", ""}
      })
    end
  }
  self.EventItems[1318] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1318,
    count = -1,
    entity = {actorType = 5, tableUid = 979},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("changeVar01")
    end
  }
  self.EventItems[1319] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1319,
    count = -1,
    entity = {actorType = 5, tableUid = 980},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("changeVar01")
    end
  }
  self.EventItems[1322] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 1322,
    count = -1,
    entity = {actorType = 5, tableUid = 979},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("changeVar02")
    end
  }
  self.EventItems[1323] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 1323,
    count = -1,
    entity = {actorType = 5, tableUid = 980},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("changeVar02")
    end
  }
  self.EventItems[1326] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1326,
    count = -1,
    entity = {actorType = 5, tableUid = 857},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("F2toC")
    end
  }
  self.EventItems[1327] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1327,
    count = -1,
    entity = {actorType = 5, tableUid = 858},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("F2toC")
    end
  }
  self.EventItems[1329] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1329,
    count = -1,
    entity = {actorType = 5, tableUid = 945},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("DtoC")
    end
  }
  self.EventItems[1328] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1328,
    count = -1,
    entity = {actorType = 5, tableUid = 946},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("DtoC")
    end
  }
  self.EventItems[1331] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1331,
    count = -1,
    entity = {actorType = 5, tableUid = 948},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("BtoC")
    end
  }
  self.EventItems[1330] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1330,
    count = -1,
    entity = {actorType = 5, tableUid = 949},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("BtoC")
    end
  }
  self.EventItems[1335] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1335,
    count = -1,
    entity = {actorType = 5, tableUid = 941},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("CtoF2")
    end
  }
  self.EventItems[1336] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1336,
    count = -1,
    entity = {actorType = 5, tableUid = 942},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("CtoF2")
    end
  }
  self.EventItems[1337] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1337,
    count = -1,
    entity = {actorType = 5, tableUid = 744},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("CtoD")
    end
  }
  self.EventItems[1338] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1338,
    count = -1,
    entity = {actorType = 5, tableUid = 944},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("CtoD")
    end
  }
  self.EventItems[1339] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1339,
    count = -1,
    entity = {actorType = 5, tableUid = 951},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("CtoB")
    end
  }
  self.EventItems[1340] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1340,
    count = -1,
    entity = {actorType = 5, tableUid = 952},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      require("zproxy.world_proxy").UserDoAction("CtoB")
    end
  }
  self.EventItems[1288] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 1288,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2004}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2002}, -1)
    end
  }
  self.EventItems[983] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 983,
    count = -1,
    selectedStr = "dinaTalk02",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 15,
        intParams = {110110}
      })
    end
  }
  self.EventItems[985] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 985,
    count = -1,
    selectedStr = "dinaTalk03",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 15,
        intParams = {110111}
      })
    end
  }
  self.EventItems[1036] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 1036,
    count = -1,
    selectedStr = "jackRealTalk01",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000271", ""}
      })
    end
  }
  self.EventItems[959] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 1006,
    group = 0,
    eventId = 959,
    count = -1,
    action = function(localSelf)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1001})
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1008})
      do
        local entityData = {actorType = 3, groupId = 55}
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
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000022", ""}
      })
    end
  }
  self.EventItems[1364] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1364,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 3, groupId = 55}
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
