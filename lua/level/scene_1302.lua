local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[102343] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102343,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 100277}
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
  self.EventItems[102344] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102344,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 100277}
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
        local entityData = {actorType = 5, groupId = 100278}
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
  self.EventItems[102224] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 102224,
    count = -1,
    selectedStr = "on_130106_flow_end",
    action = function(localSelf)
      do
        local entityData = {actorType = 2, tableUid = 104140}
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
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"1301200", ""}
      })
    end
  }
  self.EventItems[102289] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102289,
    count = -1,
    action = function(localSelf)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1042})
    end
  }
  self.EventItems[102342] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102342,
    count = -1,
    action = function(localSelf)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1043})
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"1301504", ""}
      })
    end
  }
  self.EventItems[102365] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 102365,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZEventParser.PreLoadCutscene(1301004)
    end
  }
  self.EventItems[262] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 262,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2032}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2030}, 0)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2004}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2002}, 0)
    end
  }
  self.EventItems[290] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 290,
    count = -1,
    entity = {actorType = 5, tableUid = 103929},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZEventParser.PreLoadCutscene(101010508)
      Panda.ZGame.ZEventParser.PreLoadCutscene(101010510)
    end
  }
end

return Scene
