local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[937] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 937,
    count = 1,
    entity = {actorType = 5, tableUid = 2642},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZGame.ZEventParser.PreLoadFlow(12010001)
    end
  }
  self.EventItems[938] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 938,
    count = 1,
    entity = {actorType = 5, tableUid = 2644},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZGame.ZEventParser.PreLoadFlow(12010005)
    end
  }
  self.EventItems[817] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 817,
    count = -1,
    entity = {actorType = 5, tableUid = 2331},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121110)
      Z.LevelMgr.timerMgr:StartTimer(function()
        Z.LevelMgr.FireSceneEvent({
          eventType = 1,
          strParams = {"5000015", ""}
        })
      end, 2)
    end
  }
  self.EventItems[845] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 845,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, tableUid = 2331}
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
  self.EventItems[939] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 939,
    count = 1,
    entity = {actorType = 5, tableUid = 2647},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZGame.ZEventParser.PreLoadFlow(12010009)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5000010", ""}
      })
      Z.LevelMgr.timerMgr:StartTimer(function()
        Z.LevelMgr.FireSceneEvent({
          eventType = 1,
          strParams = {"5000011", ""}
        })
        Z.LevelMgr.timerMgr:StartTimer(function()
          Z.LevelMgr.FireSceneEvent({
            eventType = 1,
            strParams = {"5000012", ""}
          })
        end, 3)
      end, 3)
    end
  }
  self.EventItems[775] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 775,
    count = -1,
    entity = {actorType = 5, tableUid = 1524},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(120101)
    end
  }
  self.EventItems[834] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 834,
    count = 1,
    entity = {actorType = 5, tableUid = 2369},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("WindTunnel_Dungeon_Island_1201", 0, 1, 240, false, 0)
    end
  }
  self.EventItems[179] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 179,
    count = -1,
    entity = {actorType = 5, tableUid = 991},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
    end
  }
  self.EventItems[181] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 181,
    count = -1,
    entity = {actorType = 5, tableUid = 991},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
    end
  }
  self.EventItems[923] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 923,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2032}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2030}, -1)
    end
  }
end

return Scene
