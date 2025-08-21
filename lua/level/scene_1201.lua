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
  self.EventItems[989] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 989,
    count = 1,
    selectedStr = "on_12010001_flow_end",
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZGame.ZEventParser.PreLoadFlow(12010005)
    end
  }
  self.EventItems[985] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 985,
    count = -1,
    entity = {actorType = 5, tableUid = 2475},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5000018", ""}
      })
      do
        local entityData = {actorType = 5, tableUid = 2475}
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
          do
            local entityData = {actorType = 5, tableUid = 2647}
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
        end, 3)
      end, 3)
    end
  }
  self.EventItems[975] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 975,
    count = 1,
    entity = {actorType = 5, tableUid = 1428},
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
      do
        local entityData = {actorType = 5, tableUid = 1428}
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
  self.EventItems[976] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 976,
    count = 1,
    entity = {actorType = 5, tableUid = 1492},
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
      do
        local entityData = {actorType = 5, tableUid = 1492}
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
  self.EventItems[977] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 977,
    count = -1,
    entity = {actorType = 5, tableUid = 1496},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {1},
        strParams = {
          "option_select",
          "7001=anying"
        }
      })
    end
  }
  self.EventItems[978] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 978,
    count = -1,
    entity = {actorType = 5, tableUid = 1496},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          "7001=anying"
        }
      })
    end
  }
  self.EventItems[979] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 979,
    count = -1,
    selectedStr = "anying",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          "7001=anying"
        }
      })
      do
        local entityData = {actorType = 5, tableUid = 1496}
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
        eventType = 15,
        intParams = {12010010}
      })
      Z.LevelMgr.timerMgr:StartTimer(function()
        do
          local entityData = {actorType = 2, tableUid = 1247}
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
          local entityData = {actorType = 2, tableUid = 2388}
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
  self.EventItems[980] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 980,
    count = -1,
    entity = {actorType = 5, tableUid = 2462},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {0}, true)
    end
  }
  self.EventItems[981] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 981,
    count = -1,
    entity = {actorType = 5, tableUid = 2460},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {120120}, false)
    end
  }
  self.EventItems[982] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 982,
    count = -1,
    entity = {actorType = 5, tableUid = 275},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5000017", ""}
      })
    end
  }
  self.EventItems[983] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 983,
    count = -1,
    entity = {actorType = 5, tableUid = 276},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5000020", ""}
      })
    end
  }
  self.EventItems[984] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 984,
    count = 1,
    entity = {actorType = 5, tableUid = 2537},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5000023", ""}
      })
      do
        local entityData = {actorType = 5, tableUid = 2537}
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
  self.EventItems[964] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 964,
    count = 1,
    entity = {actorType = 5, tableUid = 2365},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      do
        local entityData = {actorType = 3, tableUid = 2503}
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
  self.EventItems[965] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 965,
    count = 1,
    entity = {actorType = 5, tableUid = 2366},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      do
        local entityData = {actorType = 3, tableUid = 2503}
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
  self.EventItems[966] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 966,
    count = 1,
    entity = {actorType = 5, tableUid = 2364},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      do
        local entityData = {actorType = 3, tableUid = 2503}
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
  self.EventItems[990] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 12011002,
    group = 0,
    eventId = 990,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZGame.ZEventParser.PreLoadCutscene(101010408)
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
