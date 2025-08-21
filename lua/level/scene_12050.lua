local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[18] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 18,
    count = -1,
    selectedStr = "enterWindRight",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1205001)
    end
  }
  self.EventItems[21] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 21,
    count = -1,
    selectedStr = "enterWindHead",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1205003)
    end
  }
  self.EventItems[22] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 22,
    count = -1,
    selectedStr = "enterWindLeg",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1205004)
    end
  }
  self.EventItems[35] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 35,
    count = -1,
    selectedStr = "enterWindRightToLeg",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1205005)
    end
  }
  self.EventItems[36] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 36,
    count = -1,
    selectedStr = "enterWindLegToHead",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1205006)
    end
  }
  self.EventItems[97] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 97,
    count = -1,
    selectedStr = "enterWindRightToHead",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1205007)
    end
  }
  self.EventItems[98] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 98,
    count = -1,
    selectedStr = "enterWindHeadToRight",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1205009)
    end
  }
  self.EventItems[99] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 99,
    count = -1,
    selectedStr = "enterWindHeadToLeg",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1205010)
    end
  }
  self.EventItems[100] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 100,
    count = -1,
    selectedStr = "enterWindLegToRight",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1205008)
    end
  }
  self.EventItems[116] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 116,
    count = -1,
    selectedStr = "enterWindRoad",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1205011)
    end
  }
  self.EventItems[118] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 118,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 38}
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
  self.EventItems[119] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 119,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 39}
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
  self.EventItems[120] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 120,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 40}
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
  self.EventItems[165] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 165,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 66}
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
  self.EventItems[166] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 166,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 68}
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
  self.EventItems[167] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 167,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 71}
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
  self.EventItems[182] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 182,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2032}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2025}, -1)
    end
  }
  self.EventItems[187] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 187,
    count = 1,
    entity = {actorType = 5, tableUid = 557},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({1}, {2025}, -1)
      Z.LevelMgr.timerMgr:StartTimer(function()
        Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2031}, false)
        Z.LevelMgr.FireSceneEvent({
          eventType = 1,
          strParams = {"1004071", ""}
        })
        Z.LevelMgr.FireSceneEvent({
          eventType = 1,
          strParams = {"1004072", ""}
        })
      end, 0.2)
    end
  }
end

return Scene
