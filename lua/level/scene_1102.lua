local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[50] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 50,
    count = -1,
    selectedStr = "dinaTalk02",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 15,
        intParams = {110110}
      })
    end
  }
  self.EventItems[54] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 54,
    count = -1,
    selectedStr = "dinaTalk03",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 15,
        intParams = {110111}
      })
    end
  }
  self.EventItems[103] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 103,
    count = -1,
    selectedStr = "jackRealTalk01",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"2000271", ""}
      })
    end
  }
  self.EventItems[114] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 1006,
    group = 0,
    eventId = 114,
    count = -1,
    action = function(localSelf)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1008})
    end
  }
  self.EventItems[1397] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1397,
    count = -1,
    action = function(localSelf)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1050})
    end
  }
  self.EventItems[1407] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 2,
    eventId = 1407,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 3, groupId = 2}
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
  self.EventItems[1402] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1402,
    count = -1,
    entity = {actorType = 5, tableUid = 2356},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1001})
    end
  }
  self.EventItems[1383] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 1383,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2004}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2002}, -1)
    end
  }
  self.EventItems[1403] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1403,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 3, groupId = 97}
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
  self.EventItems[1404] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1404,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 3, groupId = 98}
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
  self.EventItems[1405] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1405,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 3, groupId = 99}
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
  self.EventItems[1406] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1406,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 3, groupId = 100}
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
