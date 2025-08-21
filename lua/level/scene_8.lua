local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {1, 2}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[1600] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1600,
    count = -1,
    layerConfigId = 5013,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiBattleUIIgnoreOneLayer({0}, true, localSelf.eventId)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        3,
        4,
        5,
        9,
        10,
        13,
        14,
        17,
        18,
        19,
        20,
        25,
        26,
        27
      }, true, localSelf.eventId)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"50130011", ""}
      })
    end
  }
  self.EventItems[1601] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1601,
    count = -1,
    layerConfigId = 5013,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1, localSelf.eventId)
    end
  }
  self.EventItems[1544] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 501301,
    group = 0,
    eventId = 1544,
    count = -1,
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"50130015", ""}
      })
    end
  }
  self.EventItems[1595] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1595,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({0}, true, localSelf.eventId)
      Z.LevelMgr.timerMgr:StartTimer(function()
        Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({0}, false, localSelf.eventId)
      end, 4)
    end
  }
  self.EventItems[1] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1,
    count = -1,
    entity = {actorType = 5, tableUid = 37},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        strParams = {
          "dungeon_entry",
          "1",
          ""
        },
        intParams = {1, 201}
      })
    end
  }
  self.EventItems[3] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 3,
    count = -1,
    entity = {actorType = 5, tableUid = 37},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        strParams = {
          "dungeon_entry",
          "0",
          ""
        },
        intParams = {0}
      })
    end
  }
  self.EventItems[600] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 600,
    count = -1,
    entity = {actorType = 5, tableUid = 502144},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 502147}
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
        local entityData = {actorType = 5, tableUid = 502148}
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
        local entityData = {actorType = 5, tableUid = 502157}
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
  self.EventItems[463] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 463,
    count = -1,
    entity = {actorType = 5, tableUid = 502149},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"50120001", ""}
      })
    end
  }
  self.EventItems[464] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 464,
    count = -1,
    entity = {actorType = 5, tableUid = 502150},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"50120001", ""}
      })
    end
  }
  self.EventItems[798] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 798,
    count = -1,
    selectedStr = "mixinfomation",
    action = function(localSelf)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1101})
    end
  }
  self.EventItems[1817] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1817,
    count = -1,
    entity = {actorType = 5, tableUid = 503434},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission2_2_path1", 0, 0, 25, false, 0)
    end
  }
  self.EventItems[1818] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1818,
    count = -1,
    entity = {actorType = 5, tableUid = 503436},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission2_2_path1")
    end
  }
  self.EventItems[768] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 768,
    count = -1,
    layerConfigId = 5005,
    action = function(localSelf, layerConfigId)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"50050002", ""}
      })
    end
  }
  self.EventItems[2185] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 2185,
    count = -1,
    selectedStr = "on_10010343_flow_end",
    action = function(localSelf)
      Panda.ZGame.ZEventParser.PreLoadCutscene(10103003)
    end
  }
  self.EventItems[848] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 65,
    eventId = 848,
    count = -1,
    entity = {actorType = 5, tableUid = 1871},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 1871}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("taotuomingzhong_path", 0, 7, 30, false, 0)
    end
  }
  self.EventItems[850] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 65,
    eventId = 850,
    count = -1,
    entity = {actorType = 5, tableUid = 1873},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 1873}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("taotuomingzhong_path")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("taotuomingzhong_path", 7, 19, 30, false, 0)
    end
  }
  self.EventItems[854] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 65,
    eventId = 854,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("taotuomingzhong_path")
    end
  }
  self.EventItems[704] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 704,
    count = -1,
    layerConfigId = 5031,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        0,
        1,
        2,
        3,
        4,
        5,
        10,
        11,
        19,
        20,
        21,
        22,
        23,
        24
      }, true, localSelf.eventId)
      Z.LevelMgr.timerMgr:StartTimer(function()
        Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {503102}, false)
        Z.LevelMgr.timerMgr:StartTimer(function()
          Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {503101}, false)
          Z.LevelMgr.FireSceneEvent({
            eventType = 1,
            strParams = {"50310006", ""}
          })
          Z.LevelMgr.timerMgr:StartTimer(function()
            Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
              0,
              1,
              2,
              3,
              4,
              5,
              10,
              11,
              19,
              20,
              21,
              22,
              23,
              24
            }, false, localSelf.eventId)
          end, 1.6)
        end, 0.8)
      end, 0.3)
    end
  }
  self.EventItems[710] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 710,
    count = -1,
    layerConfigId = 5032,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        0,
        1,
        2,
        3,
        4,
        5,
        10,
        11,
        19,
        20,
        21,
        22,
        23,
        24
      }, true, localSelf.eventId)
      Z.LevelMgr.timerMgr:StartTimer(function()
        Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {503102}, false)
        Z.LevelMgr.timerMgr:StartTimer(function()
          Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {503101}, false)
          Z.LevelMgr.FireSceneEvent({
            eventType = 1,
            strParams = {"50310007", ""}
          })
          Z.LevelMgr.timerMgr:StartTimer(function()
            Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
              0,
              1,
              2,
              3,
              4,
              5,
              10,
              11,
              19,
              20,
              21,
              22,
              23,
              24
            }, false, localSelf.eventId)
          end, 1.6)
        end, 0.8)
      end, 0.3)
    end
  }
  self.EventItems[2175] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 2175,
    count = -1,
    layerConfigId = 6003,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.PreLoadFlow(30010108)
    end
  }
  self.EventItems[1383] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1383,
    count = -1,
    layerConfigId = 6025,
    action = function(localSelf, layerConfigId)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("dng_6026_way01", 0, 0, 20, false, 0)
    end
  }
  self.EventItems[1378] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 1378,
    count = -1,
    selectedStr = "on_30010513_flow_end",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("dng_6026_way02", 0, 0, 20, true, 0)
    end
  }
  self.EventItems[1379] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1379,
    count = -1,
    layerConfigId = 6025,
    action = function(localSelf, layerConfigId)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("dng_6026_way01")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("dng_6026_way02")
    end
  }
  self.EventItems[1211] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 502501,
    group = 0,
    eventId = 1211,
    count = -1,
    action = function(localSelf)
      Z.LevelMgr.timerMgr:StartTimer(function()
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("zhuizongxianyiren_path", 0, 4, 20, false, 0)
        do
          local entityData = {actorType = 5, tableUid = 3664}
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
          local entityData = {actorType = 5, tableUid = 3666}
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
          local entityData = {actorType = 5, tableUid = 3703}
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
      end, 3)
    end
  }
  self.EventItems[1212] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1212,
    count = -1,
    entity = {actorType = 5, tableUid = 3664},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path")
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5025003", ""}
      })
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("zhuizongxianyiren_path", 4, 8, 20, false, 0)
      do
        local entityData = {actorType = 5, tableUid = 3664}
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
  self.EventItems[1809] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1809,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("zhuizongxianyiren_path2", 0, 3, 20, false, 0)
      do
        local entityData = {actorType = 5, tableUid = 503424}
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
  self.EventItems[1227] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1227,
    count = -1,
    layerConfigId = 5025,
    action = function(localSelf, layerConfigId)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path2")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path3")
    end
  }
  self.EventItems[1244] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1244,
    count = -1,
    entity = {actorType = 5, tableUid = 3788},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5025011", ""}
      })
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path3")
      do
        local entityData = {actorType = 5, tableUid = 3788}
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
  self.EventItems[1819] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1819,
    count = -1,
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5025011", ""}
      })
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path3")
      do
        local entityData = {actorType = 5, tableUid = 3788}
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
  self.EventItems[1806] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1806,
    count = -1,
    entity = {actorType = 5, tableUid = 3666},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path")
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5025004", ""}
      })
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("zhuizongxianyiren_path", 7, 10, 20, false, 0)
      do
        local entityData = {actorType = 5, tableUid = 3666}
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
  self.EventItems[1807] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1807,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("zhuizongxianyiren_path", 10, 11, 20, false, 0)
    end
  }
  self.EventItems[1808] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1808,
    count = -1,
    entity = {actorType = 5, tableUid = 3703},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path")
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5025007", ""}
      })
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("zhuizongxianyiren_path", 11, 16, 20, false, 0)
      do
        local entityData = {actorType = 5, tableUid = 3703}
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
  self.EventItems[1810] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1810,
    count = -1,
    entity = {actorType = 5, tableUid = 503424},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path2")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path3")
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5025015", ""}
      })
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("zhuizongxianyiren_path3", 0, 3, 20, false, 0)
      do
        local entityData = {actorType = 5, tableUid = 503424}
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
        local entityData = {actorType = 5, tableUid = 503429}
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
  self.EventItems[1814] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1814,
    count = -1,
    entity = {actorType = 5, tableUid = 503429},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path3")
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5025016", ""}
      })
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("zhuizongxianyiren_path3", 3, 5, 20, false, 0)
      do
        local entityData = {actorType = 5, tableUid = 503429}
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
        local entityData = {actorType = 5, tableUid = 503432}
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
  self.EventItems[1815] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1815,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, tableUid = 503424}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path3")
    end
  }
  self.EventItems[1816] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1816,
    count = -1,
    entity = {actorType = 5, tableUid = 503432},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("zhuizongxianyiren_path3")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("zhuizongxianyiren_path3", 5, 10, 20, false, 0)
      do
        local entityData = {actorType = 5, tableUid = 503432}
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
  self.EventItems[196] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 196,
    count = -1,
    entity = {actorType = 5, tableUid = 153},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 4786}
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
        local entityData = {actorType = 5, tableUid = 394}
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
        local entityData = {actorType = 2, tableUid = 4784}
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
  self.EventItems[197] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 197,
    count = -1,
    entity = {actorType = 5, tableUid = 154},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 392}
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
        local entityData = {actorType = 5, tableUid = 394}
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
        local entityData = {actorType = 2, tableUid = 780}
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
  self.EventItems[198] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 198,
    count = -1,
    entity = {actorType = 5, tableUid = 155},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 393}
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
        local entityData = {actorType = 5, tableUid = 394}
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
        local entityData = {actorType = 2, tableUid = 781}
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
  self.EventItems[199] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 199,
    count = -1,
    entity = {actorType = 5, tableUid = 156},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 4787}
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
        local entityData = {actorType = 5, tableUid = 394}
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
        local entityData = {actorType = 2, tableUid = 4785}
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
  self.EventItems[200] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 200,
    count = -1,
    entity = {actorType = 5, tableUid = 157},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 504759}
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
        local entityData = {actorType = 5, tableUid = 394}
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
        local entityData = {actorType = 3, tableUid = 505186}
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
  self.EventItems[201] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 201,
    count = -1,
    entity = {actorType = 5, tableUid = 152},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 2, tableUid = 504081}
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
        local entityData = {actorType = 5, tableUid = 504080}
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
        local entityData = {actorType = 5, tableUid = 394}
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
  self.EventItems[202] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 202,
    count = -1,
    entity = {actorType = 5, tableUid = 153},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 4786}
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
        local entityData = {actorType = 5, tableUid = 394}
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
        local entityData = {actorType = 2, tableUid = 4784}
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
  self.EventItems[203] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 203,
    count = -1,
    entity = {actorType = 5, tableUid = 154},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 392}
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
        local entityData = {actorType = 5, tableUid = 394}
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
        local entityData = {actorType = 2, tableUid = 780}
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
  self.EventItems[204] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 204,
    count = -1,
    entity = {actorType = 5, tableUid = 155},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 393}
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
        local entityData = {actorType = 5, tableUid = 394}
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
        local entityData = {actorType = 2, tableUid = 781}
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
  self.EventItems[205] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 205,
    count = -1,
    entity = {actorType = 5, tableUid = 156},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 4787}
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
        local entityData = {actorType = 5, tableUid = 394}
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
        local entityData = {actorType = 2, tableUid = 4785}
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
  self.EventItems[206] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 206,
    count = -1,
    entity = {actorType = 5, tableUid = 157},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 3, tableUid = 505186}
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
        local entityData = {actorType = 5, tableUid = 504759}
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
        local entityData = {actorType = 5, tableUid = 394}
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
  self.EventItems[1624] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1624,
    count = -1,
    entity = {actorType = 5, tableUid = 152},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 504080}
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
        local entityData = {actorType = 5, tableUid = 394}
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
        local entityData = {actorType = 2, tableUid = 504081}
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
  self.EventItems[1896] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 1896,
    count = -1,
    selectedStr = "liuguang",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("yiyuanzaiju", 0, 0, 40, false, 0)
    end
  }
  self.EventItems[1898] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 1898,
    count = -1,
    selectedStr = "on_30011606_flow_end",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("yiyuanzaiju")
    end
  }
  self.EventItems[1401] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1401,
    count = -1,
    layerConfigId = 6000,
    action = function(localSelf, layerConfigId)
      Panda.LuaAsyncBridge.SetCurWeatherTime(20)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
  self.EventItems[1402] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1402,
    count = -1,
    layerConfigId = 0,
    action = function(localSelf, layerConfigId)
      Panda.LuaAsyncBridge.SetCurWeatherTime(0)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(true)
    end
  }
  self.EventItems[1631] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1631,
    count = -1,
    layerConfigId = 5011,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
    end
  }
  self.EventItems[1633] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1633,
    count = -1,
    layerConfigId = 5011,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[1711] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1711,
    count = -1,
    layerConfigId = 5510,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_festival_001")
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/cty001_story_warcity")
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
      Panda.LuaAsyncBridge.SetCurWeatherTime(24)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
  self.EventItems[1720] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1720,
    count = -1,
    layerConfigId = 5510,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_story_warcity")
    end
  }
  self.EventItems[1879] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1879,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {1105}, false)
      Z.LevelMgr.timerMgr:StartTimer(function()
        Z.LevelMgr.FireSceneEvent({
          eventType = 1,
          strParams = {"10510303", ""}
        })
      end, 1)
    end
  }
  self.EventItems[1712] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1712,
    count = -1,
    layerConfigId = 5515,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_festival_001")
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/cty001_story_warcity")
      Panda.LuaAsyncBridge.SetCurWeatherTime(24)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
  self.EventItems[1721] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1721,
    count = -1,
    layerConfigId = 5515,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_story_warcity")
    end
  }
  self.EventItems[1713] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1713,
    count = -1,
    layerConfigId = 5516,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_festival_001")
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/cty001_story_warcity")
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
      Panda.LuaAsyncBridge.SetCurWeatherTime(24)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
  self.EventItems[1722] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1722,
    count = -1,
    layerConfigId = 5516,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_story_warcity")
    end
  }
  self.EventItems[1714] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1714,
    count = -1,
    layerConfigId = 5520,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_festival_001")
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/cty001_story_warcity")
      Panda.LuaAsyncBridge.SetCurWeatherTime(24)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
  self.EventItems[1723] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1723,
    count = -1,
    layerConfigId = 5520,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_story_warcity")
    end
  }
  self.EventItems[1715] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1715,
    count = -1,
    layerConfigId = 5525,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_festival_001")
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/cty001_story_warcity")
      Panda.LuaAsyncBridge.SetCurWeatherTime(24)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
  self.EventItems[1719] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1719,
    count = -1,
    layerConfigId = 5525,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_story_warcity")
    end
  }
  self.EventItems[1716] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1716,
    count = -1,
    layerConfigId = 5526,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        4,
        26,
        27
      }, true, localSelf.eventId)
    end
  }
  self.EventItems[1724] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1724,
    count = -1,
    layerConfigId = 5526,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1, localSelf.eventId)
    end
  }
  self.EventItems[1872] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1872,
    count = -1,
    entity = {actorType = 5, tableUid = 503248},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZEventParser.PreLoadCutscene(101010502)
      Panda.ZGame.ZEventParser.PreLoadFlow(10050214)
    end
  }
  self.EventItems[1774] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1774,
    count = -1,
    layerConfigId = 5530,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        4,
        26,
        27
      }, true, localSelf.eventId)
    end
  }
  self.EventItems[1901] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 101010506,
    group = 0,
    eventId = 1901,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[1902] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1902,
    count = -1,
    layerConfigId = 5530,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1, localSelf.eventId)
    end
  }
  self.EventItems[1840] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1840,
    count = -1,
    action = function(localSelf)
      logGreen("--test--d")
      do
        local entityData = {actorType = 5, tableUid = 503560}
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
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[1859] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1859,
    count = -1,
    layerConfigId = 5530,
    action = function(localSelf, layerConfigId)
      do
        local entityData = {actorType = 5, tableUid = 503560}
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
  self.EventItems[1752] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 1752,
    count = -1,
    selectedStr = "on_30021211_flow_end",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("missionside_patanew01", 0, 0, 20, false, 0)
    end
  }
  self.EventItems[1753] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 1753,
    count = -1,
    selectedStr = "on_30021212_flow_end",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("missionside_pata02", 0, 0, 15, false, 0)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("missionside_pata")
    end
  }
  self.EventItems[1754] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 1754,
    count = -1,
    selectedStr = "on_30021213_flow_end",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("missionside_patanew02", 0, 0, 15, false, 0)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("missionside_patanew01")
    end
  }
  self.EventItems[1756] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 1756,
    count = -1,
    selectedStr = "on_30021203_flow_end",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("missionside_patanew02")
    end
  }
  self.EventItems[1975] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1975,
    count = -1,
    action = function(localSelf)
      Panda.LuaAsyncBridge.SetCurWeatherTime(20)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
  self.EventItems[1976] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1976,
    count = -1,
    action = function(localSelf)
      Panda.LuaAsyncBridge.SetCurWeatherTime(-1)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(true)
    end
  }
  self.EventItems[2133] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 2133,
    count = -1,
    entity = {actorType = 2, tableUid = 504430},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 2, tableUid = 504430}
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
  self.EventItems[2134] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 2134,
    count = -1,
    entity = {actorType = 2, tableUid = 504431},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 2, tableUid = 504431}
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
  self.EventItems[1952] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1952,
    count = -1,
    layerConfigId = 5110,
    action = function(localSelf, layerConfigId)
      Panda.LuaAsyncBridge.SetCurWeatherTime(19)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
  self.EventItems[2138] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 2138,
    count = -1,
    selectedStr = "on_10010421_flow_end",
    action = function(localSelf)
      do
        local entityData = {actorType = 5, tableUid = 504683}
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
  self.EventItems[2041] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 2041,
    count = -1,
    layerConfigId = 5110,
    action = function(localSelf, layerConfigId)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("dng_5110_pathway")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("dng_5110_path2")
    end
  }
  self.EventItems[2065] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 2065,
    count = -1,
    selectedStr = "on_10010421_flow_end",
    action = function(localSelf)
      do
        local entityData = {actorType = 2, groupId = 502245}
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
  self.EventItems[2066] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 2066,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 2, groupId = 502245}
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
  self.EventItems[2137] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 2137,
    count = -1,
    entity = {actorType = 5, tableUid = 504683},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.LuaAsyncBridge.SetCurWeatherTime(22)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
      Z.LevelMgr.timerMgr:StartTimer(function()
        do
          local entityData = {actorType = 5, tableUid = 504683}
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
      end, 1)
    end
  }
  self.EventItems[2008] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 2008,
    count = -1,
    layerConfigId = 5019,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
    end
  }
  self.EventItems[2009] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 2009,
    count = -1,
    layerConfigId = 5019,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[2095] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 2095,
    count = -1,
    action = function(localSelf)
      local entityData = {actorType = 2, groupId = 502260}
      if entityData.groupId then
        Panda.ZGame.ZAIMgr.Instance:SendEventToGroup(entityData.groupId, 501901)
      else
        Panda.ZGame.ZAIMgr.Instance:SendEvent(entityData.tableUid, entityData.actorType, 501901)
      end
    end
  }
  self.EventItems[2096] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 2096,
    count = -1,
    action = function(localSelf)
      local entityData = {actorType = 2, groupId = 502261}
      if entityData.groupId then
        Panda.ZGame.ZAIMgr.Instance:SendEventToGroup(entityData.groupId, 501901)
      else
        Panda.ZGame.ZAIMgr.Instance:SendEvent(entityData.tableUid, entityData.actorType, 501901)
      end
    end
  }
  self.EventItems[2097] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 2097,
    count = -1,
    action = function(localSelf)
      local entityData = {actorType = 2, groupId = 502262}
      if entityData.groupId then
        Panda.ZGame.ZAIMgr.Instance:SendEventToGroup(entityData.groupId, 501901)
      else
        Panda.ZGame.ZAIMgr.Instance:SendEvent(entityData.tableUid, entityData.actorType, 501901)
      end
    end
  }
  self.EventItems[2006] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 2006,
    count = -1,
    layerConfigId = 5,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/cty001_story_fireworks")
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/cty001_story_fireworks_festival")
    end
  }
  self.EventItems[2007] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 2007,
    count = -1,
    layerConfigId = 5,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_story_fireworks")
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_story_fireworks_festival")
    end
  }
  self.EventItems[2039] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 2039,
    count = -1,
    layerConfigId = 5040,
    action = function(localSelf, layerConfigId)
      Panda.LuaAsyncBridge.SetCurWeatherTime(22)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
  self.EventItems[2040] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 2040,
    count = -1,
    layerConfigId = 5040,
    action = function(localSelf, layerConfigId)
      Panda.LuaAsyncBridge.SetCurWeatherTime(0)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(true)
    end
  }
  self.EventItems[2088] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 2088,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 2, tableUid = 504422}
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
  self.EventItems[2089] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 2089,
    count = -1,
    entity = {actorType = 5, tableUid = 504420},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 2, tableUid = 504422}
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
  self.EventItems[2119] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 1002,
    group = 0,
    eventId = 2119,
    count = -1,
    action = function(localSelf)
      if Z.VMMgr.GetVM("level_editor").IsQuestExist(185111) then
        Z.LevelMgr.FireSceneEvent({
          eventType = 1,
          strParams = {"10010257", ""}
        })
        Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {210})
        Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {211})
        Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {215})
      end
    end
  }
  self.EventItems[2073] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 2073,
    count = -1,
    layerConfigId = 5041,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/cty001_story_ship")
    end
  }
  self.EventItems[2146] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 2146,
    count = -1,
    entity = {actorType = 5, tableUid = 504704},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {301020109}
      })
    end
  }
  self.EventItems[2147] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 2147,
    count = -1,
    entity = {actorType = 5, tableUid = 504706},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {301020109}
      })
    end
  }
  self.EventItems[2148] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 2148,
    count = -1,
    entity = {actorType = 5, tableUid = 504707},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {301020109}
      })
    end
  }
  self.EventItems[2223] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 2223,
    count = -1,
    entity = {actorType = 5, tableUid = 505214},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {301020109}
      })
    end
  }
  self.EventItems[2172] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 2172,
    count = -1,
    layerConfigId = 5041,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_story_ship")
    end
  }
  self.EventItems[2170] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 2170,
    count = -1,
    layerConfigId = 5042,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/cty001_story_ship")
    end
  }
  self.EventItems[2173] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 2173,
    count = -1,
    layerConfigId = 5042,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/cty001_story_ship")
    end
  }
end

return Scene
