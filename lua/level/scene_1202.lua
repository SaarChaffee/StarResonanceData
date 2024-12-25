local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[25] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 25,
    count = 1,
    entity = {actorType = 5, tableUid = 107},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZGame.ZEventParser.PreLoadFlow(12010005)
      do
        local entityData = {actorType = 16, tableUid = 506}
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
  self.EventItems[82] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 82,
    count = 1,
    entity = {actorType = 5, tableUid = 205},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5000113", ""}
      })
    end
  }
  self.EventItems[83] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 83,
    count = 1,
    entity = {actorType = 5, tableUid = 206},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5000114", ""}
      })
    end
  }
  self.EventItems[84] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 84,
    count = 1,
    entity = {actorType = 5, tableUid = 209},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5000021", ""}
      })
    end
  }
  self.EventItems[77] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 77,
    count = -1,
    entity = {actorType = 5, tableUid = 190},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5000017", ""}
      })
    end
  }
  self.EventItems[78] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 78,
    count = -1,
    entity = {actorType = 5, tableUid = 191},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5000020", ""}
      })
    end
  }
  self.EventItems[86] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 86,
    count = -1,
    entity = {actorType = 5, tableUid = 255},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(120203)
    end
  }
  self.EventItems[87] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 87,
    count = -1,
    entity = {actorType = 5, tableUid = 257},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(120204)
    end
  }
  self.EventItems[102] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 102,
    count = -1,
    entity = {actorType = 5, tableUid = 293},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"1201901", ""}
      })
    end
  }
  self.EventItems[181] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 181,
    count = -1,
    entity = {actorType = 5, tableUid = 561},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(120202)
    end
  }
  self.EventItems[120] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 120,
    count = 1,
    entity = {actorType = 5, tableUid = 328},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5000035", ""}
      })
      do
        local entityData = {actorType = 3, tableUid = 330}
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
  self.EventItems[121] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 121,
    count = 1,
    entity = {actorType = 5, tableUid = 329},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5000036", ""}
      })
    end
  }
  self.EventItems[122] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 122,
    count = 1,
    entity = {actorType = 5, tableUid = 327},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5000037", ""}
      })
    end
  }
  self.EventItems[128] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 128,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2032}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2030}, -1)
    end
  }
  self.EventItems[172] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 172,
    count = -1,
    entity = {actorType = 5, tableUid = 472},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(120201)
    end
  }
end

return Scene
