local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[1431] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 10104008,
    group = 5,
    eventId = 1431,
    count = -1,
    action = function(localSelf)
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
  self.EventItems[1432] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 17,
    eventId = 1432,
    count = -1,
    entity = {actorType = 5, tableUid = 1035},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 1035}
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
      Z.LevelMgr.timerMgr:StartTimer(function()
        do
          local entityData = {actorType = 2, groupId = 12}
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
      end, 1)
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
      }, true)
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
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1)
    end
  }
  self.EventItems[1430] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1430,
    count = -1,
    entity = {actorType = 5, tableUid = 1031},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 26,
        intParams = {
          2,
          1,
          15,
          16,
          17,
          18,
          19,
          20,
          21,
          22,
          23,
          25,
          30,
          32,
          33,
          35,
          36,
          37,
          43,
          47,
          48,
          49,
          51,
          52,
          53,
          54,
          55,
          56,
          57,
          58,
          59,
          61,
          62,
          67,
          68,
          29,
          138,
          139,
          12,
          152,
          154,
          155,
          156
        },
        floatParams = {
          0.13,
          0.13,
          0.13,
          1.0
        }
      })
    end
  }
  self.EventItems[1438] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 1052,
    group = 2,
    eventId = 1438,
    count = -1,
    action = function(localSelf)
      Z.LevelMgr.timerMgr:StartTimer(function()
        do
          local entityData = {actorType = 2, tableUid = 194}
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
          local entityData = {actorType = 2, tableUid = 195}
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
      end, 1)
    end
  }
  self.EventItems[1439] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 2,
    eventId = 1439,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 2, groupId = 1}
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
  self.EventItems[1441] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 2,
    eventId = 1441,
    count = -1,
    entity = {actorType = 5, tableUid = 1041},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 503}
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
        local entityData = {actorType = 5, tableUid = 504}
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
        local entityData = {actorType = 2, tableUid = 2}
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
        local entityData = {actorType = 2, tableUid = 3}
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
      Z.LevelMgr.timerMgr:StartTimer(function()
        do
          local entityData = {actorType = 2, tableUid = 2}
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
          local entityData = {actorType = 2, tableUid = 3}
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
          local entityData = {actorType = 5, tableUid = 503}
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
          local entityData = {actorType = 5, tableUid = 504}
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
      end, 8)
    end
  }
  self.EventItems[1307] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 8,
    eventId = 1307,
    count = -1,
    entity = {actorType = 5, tableUid = 960},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 451}
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
        local entityData = {actorType = 5, tableUid = 960}
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
  self.EventItems[1308] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 8,
    eventId = 1308,
    count = -1,
    entity = {actorType = 5, tableUid = 481},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 451}
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
        local entityData = {actorType = 5, tableUid = 481}
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
  self.EventItems[1317] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1317,
    count = -1,
    entity = {actorType = 5, tableUid = 536},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiBattleUIIgnoreOneLayer({0}, true)
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
      }, true)
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
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1)
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
  self.EventItems[1320] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 1320,
    count = -1,
    entity = {actorType = 5, tableUid = 966},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        5,
        10,
        17,
        19,
        20,
        26,
        27
      }, false)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiBattleUIIgnoreOneLayer({0}, false)
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
  self.EventItems[1321] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 1321,
    count = -1,
    entity = {actorType = 5, tableUid = 536},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        3,
        4,
        24
      }, false)
      do
        local entityData = {actorType = 5, tableUid = 536}
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
end

return Scene
