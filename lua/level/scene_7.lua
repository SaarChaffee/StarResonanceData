local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[2569] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 2569,
    count = -1,
    entity = {actorType = 5, tableUid = 12320},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"10010209", ""}
      })
    end
  }
  self.EventItems[3578] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 3578,
    count = -1,
    selectedStr = "on_10010314_flow_end",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission1_2_path3", 0, 0, 25, false, 0)
    end
  }
  self.EventItems[3877] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3877,
    count = -1,
    entity = {actorType = 5, tableUid = 19600},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission1_2_path2", 0, 0, 25, false, 0)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission1_2_path3")
    end
  }
  self.EventItems[3579] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3579,
    count = -1,
    entity = {actorType = 5, tableUid = 18530},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission1_2_path2")
    end
  }
  self.EventItems[3580] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 3580,
    count = -1,
    selectedStr = "on_10010139_flow_end",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission2_1_path1", 0, 0, 10, false, 0)
    end
  }
  self.EventItems[3581] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3581,
    count = -1,
    entity = {actorType = 5, tableUid = 18530},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission2_1_path1")
    end
  }
  self.EventItems[3583] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3583,
    count = -1,
    entity = {actorType = 5, tableUid = 18531},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission1_2_path1", 0, 0, 10, false, 0)
    end
  }
  self.EventItems[3584] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3584,
    count = -1,
    entity = {actorType = 5, tableUid = 18532},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission1_2_path1")
    end
  }
  self.EventItems[3887] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 3887,
    count = -1,
    selectedStr = "on_10010114_flow_end",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission1_1_killsheep", 0, 0, 20, false, 0)
    end
  }
  self.EventItems[4012] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 4012,
    count = -1,
    selectedStr = "on_10010113_flow_end",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission1_1_killsheep")
    end
  }
  self.EventItems[3474] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3474,
    count = -1,
    layerConfigId = 5017,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiBattleUIIgnoreOneLayer({0}, true)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        3,
        4,
        5,
        6,
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
      }, true)
      Panda.ZGame.ZEventParser.PreLoadCutscene(20204202)
    end
  }
  self.EventItems[3475] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3475,
    count = -1,
    layerConfigId = 5017,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1)
    end
  }
  self.EventItems[669] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 669,
    count = -1,
    entity = {actorType = 5, tableUid = 1357},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {1},
        strParams = {
          "option_select",
          "5101=enter_photo_mode_70101"
        }
      })
    end
  }
  self.EventItems[670] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 670,
    count = -1,
    selectedStr = "enter_photo_mode_70101",
    action = function(localSelf)
      Z.VMMgr.GetVM("camerasys").OpenCameraView(70101)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {7002}, false)
    end
  }
  self.EventItems[671] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 671,
    count = -1,
    entity = {actorType = 5, tableUid = 1358},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("camerasys").CloseCameraView()
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, false, {}, false)
    end
  }
  self.EventItems[673] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 673,
    count = -1,
    entity = {actorType = 5, tableUid = 1357},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          ""
        }
      })
    end
  }
  self.EventItems[732] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 732,
    count = -1,
    entity = {actorType = 5, tableUid = 1432},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {1},
        strParams = {
          "option_select",
          "5101=enter_photo_mode_70103"
        }
      })
    end
  }
  self.EventItems[733] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 733,
    count = -1,
    selectedStr = "enter_photo_mode_70103",
    action = function(localSelf)
      Z.VMMgr.GetVM("camerasys").OpenCameraView(70103)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {7001}, false)
    end
  }
  self.EventItems[734] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 734,
    count = -1,
    entity = {actorType = 5, tableUid = 1435},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("camerasys").CloseCameraView()
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, false, {}, false)
    end
  }
  self.EventItems[735] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 735,
    count = -1,
    entity = {actorType = 5, tableUid = 1432},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          ""
        }
      })
    end
  }
  self.EventItems[833] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 833,
    count = -1,
    entity = {actorType = 5, tableUid = 1642},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {1},
        strParams = {
          "option_select",
          "5101=enter_photo_mode_70102"
        }
      })
    end
  }
  self.EventItems[834] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 834,
    count = -1,
    selectedStr = "enter_photo_mode_70102",
    action = function(localSelf)
      Z.VMMgr.GetVM("camerasys").OpenCameraView(70102)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {7003}, false)
    end
  }
  self.EventItems[835] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 835,
    count = -1,
    entity = {actorType = 5, tableUid = 1646},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("camerasys").CloseCameraView()
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, false, {}, false)
    end
  }
  self.EventItems[836] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 836,
    count = -1,
    entity = {actorType = 5, tableUid = 1642},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          ""
        }
      })
    end
  }
  self.EventItems[837] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 837,
    count = -1,
    entity = {actorType = 5, tableUid = 1652},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {1},
        strParams = {
          "option_select",
          "5101=enter_photo_mode_70104"
        }
      })
    end
  }
  self.EventItems[838] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 838,
    count = -1,
    selectedStr = "enter_photo_mode_70104",
    action = function(localSelf)
      Z.VMMgr.GetVM("camerasys").OpenCameraView(70104)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {7004}, false)
    end
  }
  self.EventItems[839] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 839,
    count = -1,
    entity = {actorType = 5, tableUid = 1653},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("camerasys").CloseCameraView()
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, false, {}, false)
    end
  }
  self.EventItems[840] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 840,
    count = -1,
    entity = {actorType = 5, tableUid = 1652},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          ""
        }
      })
    end
  }
  self.EventItems[841] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 841,
    count = -1,
    entity = {actorType = 5, tableUid = 1663},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {1},
        strParams = {
          "option_select",
          "5101=enter_photo_mode_70105"
        }
      })
    end
  }
  self.EventItems[842] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 842,
    count = -1,
    selectedStr = "enter_photo_mode_70105",
    action = function(localSelf)
      Z.VMMgr.GetVM("camerasys").OpenCameraView(70105)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {7005}, false)
    end
  }
  self.EventItems[843] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 843,
    count = -1,
    entity = {actorType = 5, tableUid = 1664},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("camerasys").CloseCameraView()
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, false, {}, false)
    end
  }
  self.EventItems[844] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 844,
    count = -1,
    entity = {actorType = 5, tableUid = 1663},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          ""
        }
      })
    end
  }
  self.EventItems[845] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 845,
    count = -1,
    entity = {actorType = 5, tableUid = 1672},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {1},
        strParams = {
          "option_select",
          "5101=enter_photo_mode_70106"
        }
      })
    end
  }
  self.EventItems[846] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 846,
    count = -1,
    selectedStr = "enter_photo_mode_70106",
    action = function(localSelf)
      Z.VMMgr.GetVM("camerasys").OpenCameraView(70106)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {7006}, false)
    end
  }
  self.EventItems[847] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 847,
    count = -1,
    entity = {actorType = 5, tableUid = 1673},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("camerasys").CloseCameraView()
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, false, {}, false)
    end
  }
  self.EventItems[848] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 848,
    count = -1,
    entity = {actorType = 5, tableUid = 1672},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          ""
        }
      })
    end
  }
  self.EventItems[849] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 849,
    count = -1,
    entity = {actorType = 5, tableUid = 1678},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {1},
        strParams = {
          "option_select",
          "5101=enter_photo_mode_70107"
        }
      })
    end
  }
  self.EventItems[850] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 850,
    count = -1,
    selectedStr = "enter_photo_mode_70107",
    action = function(localSelf)
      Z.VMMgr.GetVM("camerasys").OpenCameraView(70107)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {7007}, false)
    end
  }
  self.EventItems[851] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 851,
    count = -1,
    entity = {actorType = 5, tableUid = 1679},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("camerasys").CloseCameraView()
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, false, {}, false)
    end
  }
  self.EventItems[852] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 852,
    count = -1,
    entity = {actorType = 5, tableUid = 1678},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          ""
        }
      })
    end
  }
  self.EventItems[862] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 862,
    count = -1,
    entity = {actorType = 5, tableUid = 1725},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {1},
        strParams = {
          "option_select",
          "5101=enter_photo_mode_70108"
        }
      })
    end
  }
  self.EventItems[863] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 863,
    count = -1,
    selectedStr = "enter_photo_mode_70108",
    action = function(localSelf)
      Z.VMMgr.GetVM("camerasys").OpenCameraView(70108)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {7008}, false)
    end
  }
  self.EventItems[864] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 864,
    count = -1,
    entity = {actorType = 5, tableUid = 1726},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("camerasys").CloseCameraView()
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, false, {}, false)
    end
  }
  self.EventItems[865] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 865,
    count = -1,
    entity = {actorType = 5, tableUid = 1725},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          ""
        }
      })
    end
  }
  self.EventItems[866] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 866,
    count = -1,
    entity = {actorType = 5, tableUid = 1737},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {1},
        strParams = {
          "option_select",
          "5101=enter_photo_mode_70109"
        }
      })
    end
  }
  self.EventItems[867] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 867,
    count = -1,
    selectedStr = "enter_photo_mode_70109",
    action = function(localSelf)
      Z.VMMgr.GetVM("camerasys").OpenCameraView(70109)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {7009}, false)
    end
  }
  self.EventItems[868] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 868,
    count = -1,
    entity = {actorType = 5, tableUid = 1738},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("camerasys").CloseCameraView()
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, false, {}, false)
    end
  }
  self.EventItems[869] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 869,
    count = -1,
    entity = {actorType = 5, tableUid = 1737},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          ""
        }
      })
    end
  }
  self.EventItems[876] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 876,
    count = -1,
    entity = {actorType = 5, tableUid = 1774},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {1},
        strParams = {
          "option_select",
          "5101=enter_photo_mode_70110"
        }
      })
    end
  }
  self.EventItems[877] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 877,
    count = -1,
    selectedStr = "enter_photo_mode_70110",
    action = function(localSelf)
      Z.VMMgr.GetVM("camerasys").OpenCameraView(70110)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {7010}, false)
    end
  }
  self.EventItems[878] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 878,
    count = -1,
    entity = {actorType = 5, tableUid = 1775},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("camerasys").CloseCameraView()
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, false, {}, false)
    end
  }
  self.EventItems[879] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 879,
    count = -1,
    entity = {actorType = 5, tableUid = 1774},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          ""
        }
      })
    end
  }
  self.EventItems[880] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 880,
    count = -1,
    entity = {actorType = 5, tableUid = 1779},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {1},
        strParams = {
          "option_select",
          "5101=enter_photo_mode_70111"
        }
      })
    end
  }
  self.EventItems[881] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 881,
    count = -1,
    selectedStr = "enter_photo_mode_70111",
    action = function(localSelf)
      Z.VMMgr.GetVM("camerasys").OpenCameraView(70111)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, true, {7011}, false)
    end
  }
  self.EventItems[882] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 882,
    count = -1,
    entity = {actorType = 5, tableUid = 1780},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("camerasys").CloseCameraView()
      Panda.ZGame.CameraManager.Instance:CameraInvoke(3, false, {}, false)
    end
  }
  self.EventItems[883] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 883,
    count = -1,
    entity = {actorType = 5, tableUid = 1779},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          ""
        }
      })
    end
  }
  self.EventItems[3183] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 10203001,
    group = 0,
    eventId = 3183,
    count = -1,
    action = function(localSelf)
      Panda.LuaAsyncBridge.SetCurWeatherTime(16.5)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
  self.EventItems[3247] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3247,
    count = -1,
    selectedStr = "xunzhangsuipian",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission2_1_path1", 0, 0, 20, false, 0)
    end
  }
  self.EventItems[3249] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3249,
    count = -1,
    entity = {actorType = 5, tableUid = 16110},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission2_1_path1")
    end
  }
  self.EventItems[3900] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3900,
    count = -1,
    entity = {actorType = 5, tableUid = 19800},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission2_4_path4", 0, 0, 25, false, 0)
    end
  }
  self.EventItems[3901] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3901,
    count = -1,
    entity = {actorType = 5, tableUid = 18915},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission2_4_path4")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission2_4_path5", 0, 0, 25, false, 0)
    end
  }
  self.EventItems[3902] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3902,
    count = -1,
    entity = {actorType = 5, tableUid = 18916},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission2_4_path5")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission2_4_path6", 0, 0, 25, false, 0)
    end
  }
  self.EventItems[3903] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3903,
    count = -1,
    entity = {actorType = 5, tableUid = 18917},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission2_4_path6")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission2_4_path7", 0, 0, 25, false, 0)
    end
  }
  self.EventItems[3904] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3904,
    count = -1,
    entity = {actorType = 5, tableUid = 19804},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission2_4_path7")
    end
  }
  self.EventItems[2890] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 2890,
    count = -1,
    selectedStr = "ActivateWindTunnel_1009",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("WindTunnel_Floating_1009", 0, 0, 5, false, 0)
      require("zproxy.world_proxy").UserDoAction("WindZone_1009")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[2891] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 2891,
    count = -1,
    entity = {actorType = 5, tableUid = 14508},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1009)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("WindTunnel_Floating_1009")
      require("zproxy.world_proxy").UserDoAction("WindTunnelStart_1009")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[2892] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 2892,
    count = -1,
    entity = {actorType = 5, tableUid = 14509},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindTunnelEnd_1009")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3934] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3934,
    count = -1,
    selectedStr = "ActivateWindTunnel_1001",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindZone_1001")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3935] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3935,
    count = -1,
    entity = {actorType = 5, tableUid = 14551},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1001)
      require("zproxy.world_proxy").UserDoAction("WindTunnelStart_1001")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3936] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 3936,
    count = -1,
    entity = {actorType = 5, tableUid = 14552},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindTunnelEnd_1001")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3940] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3940,
    count = -1,
    selectedStr = "ActivateWindTunnel_1002",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindZone_1002")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3941] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3941,
    count = -1,
    entity = {actorType = 5, tableUid = 14543},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1002)
      require("zproxy.world_proxy").UserDoAction("WindTunnelStart_1002")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3942] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 3942,
    count = -1,
    entity = {actorType = 5, tableUid = 14544},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindTunnelEnd_1002")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3946] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3946,
    count = -1,
    selectedStr = "ActivateWindTunnel_1003",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindZone_1003")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3947] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3947,
    count = -1,
    entity = {actorType = 5, tableUid = 14539},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1003)
      require("zproxy.world_proxy").UserDoAction("WindTunnelStart_1003")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3948] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 3948,
    count = -1,
    entity = {actorType = 5, tableUid = 14540},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindTunnelEnd_1003")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3952] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3952,
    count = -1,
    selectedStr = "ActivateWindTunnel_1004",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("WindTunnel_Floating_1004", 0, 0, 5, false, 0)
      require("zproxy.world_proxy").UserDoAction("WindZone_1004")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3953] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3953,
    count = -1,
    entity = {actorType = 5, tableUid = 14527},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1004)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("WindTunnel_Floating_1004")
      require("zproxy.world_proxy").UserDoAction("WindTunnelStart_1004")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3954] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 3954,
    count = -1,
    entity = {actorType = 5, tableUid = 14528},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindTunnelEnd_1004")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3958] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3958,
    count = -1,
    selectedStr = "ActivateWindTunnel_1005",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindZone_1005")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3959] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3959,
    count = -1,
    entity = {actorType = 5, tableUid = 14531},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1005)
      require("zproxy.world_proxy").UserDoAction("WindTunnelStart_1005")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3960] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 3960,
    count = -1,
    entity = {actorType = 5, tableUid = 14532},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindTunnelEnd_1005")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3964] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3964,
    count = -1,
    selectedStr = "ActivateWindTunnel_1006",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindZone_1006")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3965] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3965,
    count = -1,
    entity = {actorType = 5, tableUid = 14523},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1006)
      require("zproxy.world_proxy").UserDoAction("WindTunnelStart_1006")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3966] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 3966,
    count = -1,
    entity = {actorType = 5, tableUid = 14524},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindTunnelEnd_1006")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3970] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3970,
    count = -1,
    selectedStr = "ActivateWindTunnel_1007",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindZone_1007")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3971] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3971,
    count = -1,
    entity = {actorType = 5, tableUid = 16210},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1007)
      require("zproxy.world_proxy").UserDoAction("WindTunnelStart_1007")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3972] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 3972,
    count = -1,
    entity = {actorType = 5, tableUid = 16211},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindTunnelEnd_1007")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3976] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3976,
    count = -1,
    selectedStr = "ActivateWindTunnel_1008",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindZone_1008")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3977] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3977,
    count = -1,
    entity = {actorType = 5, tableUid = 14515},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1008)
      require("zproxy.world_proxy").UserDoAction("WindTunnelStart_1008")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3978] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 3978,
    count = -1,
    entity = {actorType = 5, tableUid = 14516},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindTunnelEnd_1008")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3982] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3982,
    count = -1,
    selectedStr = "ActivateWindTunnel_1010",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindZone_1010")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3983] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3983,
    count = -1,
    entity = {actorType = 5, tableUid = 10987},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1010)
      require("zproxy.world_proxy").UserDoAction("WindTunnelStart_1010")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3984] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 3984,
    count = -1,
    entity = {actorType = 5, tableUid = 10991},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindTunnelEnd_1010")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3988] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3988,
    count = -1,
    selectedStr = "ActivateWindTunnel_1011",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindZone_1011")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3989] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3989,
    count = -1,
    entity = {actorType = 5, tableUid = 14535},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1011)
      require("zproxy.world_proxy").UserDoAction("WindTunnelStart_1011")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3990] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 3990,
    count = -1,
    entity = {actorType = 5, tableUid = 14536},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindTunnelEnd_1011")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3994] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3994,
    count = -1,
    selectedStr = "ActivateWindTunnel_1012",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("WindTunnel_Floating_1012", 0, 0, 5, false, 0)
      require("zproxy.world_proxy").UserDoAction("WindZone_1012")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3995] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3995,
    count = -1,
    entity = {actorType = 5, tableUid = 14519},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1012)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("WindTunnel_Floating_1012")
      require("zproxy.world_proxy").UserDoAction("WindTunnelStart_1012")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3996] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 3996,
    count = -1,
    entity = {actorType = 5, tableUid = 14520},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      require("zproxy.world_proxy").UserDoAction("WindTunnelEnd_1012")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[4001] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 4001,
    count = -1,
    entity = {actorType = 5, tableUid = 17834},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1013)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[4002] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 4002,
    count = -1,
    entity = {actorType = 5, tableUid = 17835},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[4007] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 4007,
    count = -1,
    entity = {actorType = 5, tableUid = 17845},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1014)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[4008] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 4008,
    count = -1,
    entity = {actorType = 5, tableUid = 17846},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[3922] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3922,
    count = -1,
    layerConfigId = 5207,
    action = function(localSelf, layerConfigId)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {1002}
      })
    end
  }
  self.EventItems[1441] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1441,
    count = -1,
    layerConfigId = 5020,
    action = function(localSelf, layerConfigId)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {10103004}
      })
    end
  }
  self.EventItems[1518] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1518,
    count = -1,
    layerConfigId = 5204,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 1)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_visuallayer5204")
    end
  }
  self.EventItems[1519] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1519,
    count = -1,
    layerConfigId = 5204,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/fld001_story_visuallayer5204")
    end
  }
  self.EventItems[1669] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1669,
    count = -1,
    entity = {actorType = 5, tableUid = 8973},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5017006", ""}
      })
    end
  }
  self.EventItems[1642] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1642,
    count = -1,
    entity = {actorType = 5, tableUid = 9296},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5017032", ""}
      })
    end
  }
  self.EventItems[1643] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1643,
    count = -1,
    entity = {actorType = 5, tableUid = 9297},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5017033", ""}
      })
    end
  }
  self.EventItems[1644] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1644,
    count = -1,
    entity = {actorType = 5, tableUid = 9298},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5017034", ""}
      })
    end
  }
  self.EventItems[1675] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1675,
    count = -1,
    entity = {actorType = 5, tableUid = 8041},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5017009", ""}
      })
    end
  }
  self.EventItems[3882] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 20204101,
    group = 0,
    eventId = 3882,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission2_4_path1", 0, 0, 20, false, 1)
    end
  }
  self.EventItems[3883] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3883,
    count = -1,
    entity = {actorType = 5, tableUid = 8039},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission2_4_path1")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission2_4_path2", 0, 0, 20, false, 1)
    end
  }
  self.EventItems[3884] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3884,
    count = -1,
    entity = {actorType = 5, tableUid = 8040},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission2_4_path2")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("mission2_4_path3", 0, 0, 20, false, 1)
    end
  }
  self.EventItems[3886] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3886,
    count = -1,
    entity = {actorType = 5, tableUid = 9295},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("mission2_4_path3")
    end
  }
  self.EventItems[1602] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 1602,
    count = -1,
    layerConfigId = 5203,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 2)
    end
  }
  self.EventItems[1603] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 1603,
    count = -1,
    layerConfigId = 5203,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[3387] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3387,
    count = -1,
    entity = {actorType = 5, tableUid = 18083},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"5203001", ""}
      })
    end
  }
  self.EventItems[3893] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3893,
    count = -1,
    layerConfigId = 5203,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.PreLoadFlow(10020302)
    end
  }
  self.EventItems[2290] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 2290,
    count = -1,
    layerConfigId = 5212,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 1)
    end
  }
  self.EventItems[2292] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 2292,
    count = -1,
    layerConfigId = 5212,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[3349] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3349,
    count = -1,
    layerConfigId = 5212,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_visuallayer5212")
    end
  }
  self.EventItems[3350] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3350,
    count = -1,
    layerConfigId = 5212,
    action = function(localSelf, layerConfigId)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/fld001_story_visuallayer5212")
    end
  }
  self.EventItems[3833] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 3833,
    count = -1,
    selectedStr = "on_10030401_flow_end",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("main_3rd_starway1", 0, 0, 10, false, 0)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("main_3rd_starway2", 0, 0, 10, false, 0)
    end
  }
  self.EventItems[3834] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 3834,
    count = -1,
    selectedStr = "on_10030412_flow_end",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("main_3rd_starway3", 0, 0, 10, false, 0)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("main_3rd_starway4", 0, 0, 10, false, 0)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("main_3rd_starway5", 0, 0, 10, false, 0)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("main_3rd_starway1")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("main_3rd_starway2")
    end
  }
  self.EventItems[3835] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3835,
    count = -1,
    entity = {actorType = 5, tableUid = 12992},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("main_3rd_starway3")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("main_3rd_starway4")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("main_3rd_starway5")
    end
  }
  self.EventItems[3357] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3357,
    count = -1,
    layerConfigId = 5302,
    action = function(localSelf, layerConfigId)
      do
        local entityData = {actorType = 5, tableUid = 18188}
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
        local entityData = {actorType = 5, tableUid = 18189}
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
        local entityData = {actorType = 5, tableUid = 18190}
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
        local entityData = {actorType = 5, tableUid = 18191}
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
        local entityData = {actorType = 5, tableUid = 18192}
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
        local entityData = {actorType = 5, tableUid = 18193}
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
  self.EventItems[3358] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3358,
    count = -1,
    layerConfigId = 5302,
    action = function(localSelf, layerConfigId)
      do
        local entityData = {actorType = 5, tableUid = 18188}
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
        local entityData = {actorType = 5, tableUid = 18189}
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
        local entityData = {actorType = 5, tableUid = 18190}
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
        local entityData = {actorType = 5, tableUid = 18191}
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
        local entityData = {actorType = 5, tableUid = 18192}
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
        local entityData = {actorType = 5, tableUid = 18193}
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
  self.EventItems[3627] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3627,
    count = -1,
    layerConfigId = 5303,
    action = function(localSelf, layerConfigId)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {1002}
      })
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
      do
        local entityData = {actorType = 2, groupId = 674}
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
  self.EventItems[3628] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3628,
    count = -1,
    layerConfigId = 5303,
    action = function(localSelf, layerConfigId)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {1002}
      })
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[3736] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 3736,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 2, groupId = 674}
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
  self.EventItems[3630] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3630,
    count = -1,
    layerConfigId = 5304,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
    end
  }
  self.EventItems[3631] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3631,
    count = -1,
    layerConfigId = 5304,
    action = function(localSelf, layerConfigId)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {1002}
      })
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[3749] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3749,
    count = -1,
    layerConfigId = 5305,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
    end
  }
  self.EventItems[3750] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3750,
    count = -1,
    layerConfigId = 5305,
    action = function(localSelf, layerConfigId)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {1002}
      })
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[3752] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 3752,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[2727] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 2727,
    count = -1,
    layerConfigId = 5306,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, 1)
    end
  }
  self.EventItems[3556] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3556,
    count = -1,
    layerConfigId = 5306,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[3557] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3557,
    count = -1,
    layerConfigId = 5307,
    action = function(localSelf, layerConfigId)
      do
        local entityData = {actorType = 5, groupId = 641}
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
        local entityData = {actorType = 5, groupId = 642}
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
      Panda.ZGame.ZEventParser.PreLoadCutscene(101010304)
    end
  }
  self.EventItems[3842] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 3842,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 3)
    end
  }
  self.EventItems[3843] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3843,
    count = -1,
    layerConfigId = 5309,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, 0)
    end
  }
  self.EventItems[3873] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3873,
    count = -1,
    layerConfigId = 5309,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.PreLoadCutscene(101010305)
      Panda.ZGame.ZEventParser.PreLoadCutscene(101010306)
    end
  }
  self.EventItems[2672] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 2672,
    count = -1,
    layerConfigId = 5311,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 1)
    end
  }
  self.EventItems[2673] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 2673,
    count = -1,
    layerConfigId = 5311,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[3283] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3283,
    count = -1,
    selectedStr = "shouji",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 15,
        intParams = {10030103}
      })
    end
  }
  self.EventItems[3284] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 3284,
    count = -1,
    selectedStr = "junbeixiang",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 15,
        intParams = {10030104}
      })
    end
  }
  self.EventItems[2796] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 2796,
    count = -1,
    selectedStr = "ramsydairy",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 15,
        intParams = {10030222}
      })
    end
  }
  self.EventItems[2798] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 2798,
    count = -1,
    selectedStr = "key",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 15,
        intParams = {10030223}
      })
    end
  }
  self.EventItems[2655] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 2655,
    count = -1,
    selectedStr = "on_10030222_flow_end",
    action = function(localSelf)
      do
        local entityData = {actorType = 3, tableUid = 14241}
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
  self.EventItems[2656] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 2656,
    count = -1,
    selectedStr = "on_10030223_flow_end",
    action = function(localSelf)
      do
        local entityData = {actorType = 3, tableUid = 14242}
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
  self.EventItems[2703] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 2703,
    count = -1,
    entity = {actorType = 5, tableUid = 13681},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\232\191\155\229\133\165\233\163\142\229\138\155\233\128\154\233\129\147\229\133\165\229\143\163\229\140\186\229\159\159----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1102)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\232\191\155\229\133\165\233\163\142\229\138\155\233\128\154\233\129\147\229\133\165\229\143\163\229\140\186\229\159\159----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[2704] = {
    eventType = E.LevelEventType.OnPlayerStateLeave,
    enable = true,
    group = 0,
    eventId = 2704,
    count = -1,
    state = 30,
    action = function(localSelf, state)
      if Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.ETunnelId).Value == 1024 then
        logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
        do
          local entityData = {actorType = 5, tableUid = 13682}
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
        logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      end
    end
  }
  self.EventItems[2846] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 2846,
    count = -1,
    layerConfigId = 5006,
    action = function(localSelf, layerConfigId)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"10010246", ""}
      })
      Panda.ZGame.ZEventParser.PreLoadCutscene(10101008)
    end
  }
  self.EventItems[3345] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 3345,
    count = -1,
    action = function(localSelf)
      if Z.VMMgr.GetVM("level_editor").IsQuestExist(120001) == true and Z.VMMgr.GetVM("level_editor").IsWorldEventExist(6) == true then
        Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_worldevent7075")
      else
        Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/fld001_story_worldevent7075")
      end
    end
  }
  self.EventItems[3389] = {
    eventType = E.LevelEventType.OnWorldQuestRefresh,
    enable = true,
    group = 0,
    eventId = 3389,
    count = -1,
    action = function(localSelf)
      if Z.VMMgr.GetVM("level_editor").IsQuestExist(120001) == true and Z.VMMgr.GetVM("level_editor").IsWorldEventExist(6) == true then
        Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_worldevent7075")
      else
        Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/fld001_story_worldevent7075")
      end
    end
  }
  self.EventItems[2824] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 2824,
    count = -1,
    layerConfigId = 5007,
    action = function(localSelf, layerConfigId)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"10010214", ""}
      })
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"10010215", ""}
      })
      do
        local entityData = {actorType = 5, tableUid = 14357}
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
  self.EventItems[2826] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 2826,
    count = -1,
    entity = {actorType = 5, tableUid = 14357},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 14357}
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
      local entityData = {actorType = 2, tableUid = 14305}
      Panda.ZGame.ZAIMgr.Instance:SendEvent(entityData.tableUid, entityData.actorType, 500701)
      local entityData = {actorType = 2, tableUid = 14306}
      Panda.ZGame.ZAIMgr.Instance:SendEvent(entityData.tableUid, entityData.actorType, 500701)
      local entityData = {actorType = 2, tableUid = 14307}
      Panda.ZGame.ZAIMgr.Instance:SendEvent(entityData.tableUid, entityData.actorType, 500701)
    end
  }
  self.EventItems[2828] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 2828,
    count = -1,
    selectedStr = "on_10010119_flow_end",
    action = function(localSelf)
      do
        local entityData = {actorType = 2, tableUid = 14297}
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
  self.EventItems[2840] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 2840,
    count = -1,
    selectedStr = "on_21000146_flow_end",
    action = function(localSelf)
      do
        local entityData = {actorType = 2, groupId = 510}
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
        local entityData = {actorType = 2, tableUid = 14371}
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
  self.EventItems[3154] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3154,
    count = -1,
    layerConfigId = 5405,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
    end
  }
  self.EventItems[3155] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3155,
    count = -1,
    layerConfigId = 5405,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[3233] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 3233,
    count = -1,
    action = function(localSelf)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(30114, 30114002) then
        Z.LevelMgr.FireSceneEvent({
          eventType = 1,
          strParams = {"30011402", ""}
        })
      end
    end
  }
  self.EventItems[3250] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 3250,
    count = -1,
    action = function(localSelf)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(30114, 30114002) then
        Z.LevelMgr.FireSceneEvent({
          eventType = 1,
          strParams = {"30011401", ""}
        })
      end
    end
  }
  self.EventItems[3251] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 3251,
    count = -1,
    action = function(localSelf)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(30114, 30114002) then
        Z.LevelMgr.FireSceneEvent({
          eventType = 1,
          strParams = {"30011403", ""}
        })
      end
    end
  }
  self.EventItems[3245] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3245,
    count = -1,
    layerConfigId = 5008,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
      Panda.LuaAsyncBridge.SetCurWeatherTime(-1)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(true)
    end
  }
  self.EventItems[3364] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 3364,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, tableUid = 18208}
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
  self.EventItems[3365] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3365,
    count = 1,
    entity = {actorType = 5, tableUid = 18208},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1002})
    end
  }
  self.EventItems[3512] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3512,
    count = -1,
    entity = {actorType = 5, tableUid = 18343},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 18343}
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
        local entityData = {actorType = 3, tableUid = 18353}
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
        intParams = {30012105}
      })
    end
  }
  self.EventItems[3513] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3513,
    count = -1,
    entity = {actorType = 5, tableUid = 18347},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 18347}
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
        local entityData = {actorType = 3, tableUid = 18354}
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
        intParams = {30012105}
      })
    end
  }
  self.EventItems[3514] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3514,
    count = -1,
    entity = {actorType = 5, tableUid = 18350},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 3, tableUid = 18355}
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
        local entityData = {actorType = 5, tableUid = 18350}
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
        intParams = {30012105}
      })
    end
  }
  self.EventItems[3515] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3515,
    count = -1,
    entity = {actorType = 5, tableUid = 18352},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 18352}
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
        local entityData = {actorType = 3, tableUid = 18356}
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
        intParams = {30012105}
      })
    end
  }
  self.EventItems[3636] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3636,
    count = -1,
    layerConfigId = 5313,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
    end
  }
  self.EventItems[3637] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3637,
    count = -1,
    layerConfigId = 5313,
    action = function(localSelf, layerConfigId)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {1002}
      })
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[3733] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 3733,
    count = -1,
    selectedStr = "on_30012704_flow_end",
    action = function(localSelf)
      do
        local entityData = {actorType = 2, tableUid = 18681}
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
        local entityData = {actorType = 2, tableUid = 18682}
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
        local entityData = {actorType = 2, tableUid = 18683}
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
  self.EventItems[3633] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3633,
    count = -1,
    layerConfigId = 5314,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 0)
    end
  }
  self.EventItems[3634] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3634,
    count = -1,
    layerConfigId = 5314,
    action = function(localSelf, layerConfigId)
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {1002}
      })
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
end

return Scene
