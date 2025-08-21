local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {1}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[8] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 8,
    count = -1,
    entity = {actorType = 5, tableUid = 8},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {4009})
      do
        local entityData = {actorType = 5, tableUid = 8}
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
  self.EventItems[361] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 361,
    count = -1,
    entity = {actorType = 5, tableUid = 778},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121101)
    end
  }
  self.EventItems[100527] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 100527,
    count = -1,
    entity = {actorType = 5, tableUid = 100348},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121102)
    end
  }
  self.EventItems[100528] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 100528,
    count = -1,
    entity = {actorType = 5, tableUid = 100349},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121106)
    end
  }
  self.EventItems[100529] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 100529,
    count = -1,
    entity = {actorType = 5, tableUid = 100350},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121107)
    end
  }
  self.EventItems[776] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 776,
    count = -1,
    entity = {actorType = 5, tableUid = 1364},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 778}
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
  self.EventItems[777] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 777,
    count = -1,
    entity = {actorType = 5, tableUid = 1364},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 778}
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
  self.EventItems[100520] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 100520,
    count = -1,
    entity = {actorType = 5, tableUid = 100319},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121111)
    end
  }
  self.EventItems[100521] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 100521,
    count = -1,
    entity = {actorType = 5, tableUid = 100320},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121112)
    end
  }
  self.EventItems[870] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 870,
    count = -1,
    selectedStr = "feixing1",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121113)
    end
  }
  self.EventItems[100523] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 100523,
    count = -1,
    entity = {actorType = 5, tableUid = 100322},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121114)
    end
  }
  self.EventItems[919] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 919,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, tableUid = 438}
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
  self.EventItems[920] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 920,
    count = -1,
    entity = {actorType = 5, tableUid = 2210},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 438}
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
  self.EventItems[925] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 925,
    count = -1,
    entity = {actorType = 5, tableUid = 2226},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121117)
    end
  }
  self.EventItems[100524] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 100524,
    count = -1,
    entity = {actorType = 5, tableUid = 100323},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121118)
    end
  }
  self.EventItems[101046] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 101046,
    count = -1,
    entity = {actorType = 5, tableUid = 101583},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121103)
    end
  }
  self.EventItems[101079] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 101079,
    count = -1,
    entity = {actorType = 5, tableUid = 101660},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121104)
    end
  }
  self.EventItems[101311] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 101311,
    count = -1,
    selectedStr = "feixing2",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121114)
    end
  }
  self.EventItems[101406] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 101406,
    count = -1,
    entity = {actorType = 5, tableUid = 102525},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("1211_WindTunnel_13_show", 0, 0, 20, false, 0)
    end
  }
  self.EventItems[101411] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 101411,
    count = -1,
    entity = {actorType = 5, tableUid = 102561},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("1211_WindTunnel_14", 0, 0, 20, false, 0)
    end
  }
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
  self.EventItems[886] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 886,
    count = -1,
    entity = {actorType = 5, tableUid = 991},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
    end
  }
  self.EventItems[887] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 887,
    count = -1,
    entity = {actorType = 5, tableUid = 991},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
    end
  }
  self.EventItems[100472] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 100472,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2032}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2030}, -1)
    end
  }
  self.EventItems[101355] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 101355,
    count = 1,
    entity = {actorType = 5, tableUid = 102280},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1025})
    end
  }
end

return Scene
