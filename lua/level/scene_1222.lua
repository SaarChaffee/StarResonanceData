local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {1}

function Scene:InitEvents()
  self.EventItems = {}
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
  self.EventItems[101202] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 101202,
    count = -1,
    selectedStr = "feixing2",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(121114)
    end
  }
  self.EventItems[101407] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 101407,
    count = -1,
    entity = {actorType = 5, tableUid = 102527},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("1211_WindTunnel_13_show", 0, 0, 20, false, 0)
    end
  }
  self.EventItems[101410] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 101410,
    count = -1,
    entity = {actorType = 5, tableUid = 102552},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("1211_WindTunnel_14", 0, 0, 20, false, 0)
    end
  }
end

return Scene
