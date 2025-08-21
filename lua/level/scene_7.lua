local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[4399] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 4399,
    count = -1,
    entity = {actorType = 5, tableUid = 15094},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("scene").CheckSceneUnlockByTrigger(71, true)
    end
  }
  self.EventItems[4400] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 4400,
    count = -1,
    entity = {actorType = 5, tableUid = 15094},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("scene").CheckSceneUnlockByTrigger(71, false)
    end
  }
  self.EventItems[4401] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 4401,
    count = -1,
    entity = {actorType = 5, tableUid = 21123},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("scene").CheckSceneUnlockByTrigger(75, true)
    end
  }
  self.EventItems[4402] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 4402,
    count = -1,
    entity = {actorType = 5, tableUid = 21123},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.VMMgr.GetVM("scene").CheckSceneUnlockByTrigger(75, false)
    end
  }
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
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiBattleUIIgnoreOneLayer({0}, true, localSelf.eventId)
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
      }, true, localSelf.eventId)
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
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1, localSelf.eventId)
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
  self.EventItems[4150] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4150,
    count = -1,
    selectedStr = "EnterWindTunnel_1009",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1009)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("WindTunnel_Floating_1009")
    end
  }
  self.EventItems[4134] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4134,
    count = -1,
    selectedStr = "EnterWindTunnel_1001",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1001)
    end
  }
  self.EventItems[4136] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4136,
    count = -1,
    selectedStr = "EnterWindTunnel_1002",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1002)
    end
  }
  self.EventItems[4138] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4138,
    count = -1,
    selectedStr = "EnterWindTunnel_1003",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1003)
    end
  }
  self.EventItems[4140] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4140,
    count = -1,
    selectedStr = "EnterWindTunnel_1004",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1004)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("WindTunnel_Floating_1004")
    end
  }
  self.EventItems[4142] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4142,
    count = -1,
    selectedStr = "EnterWindTunnel_1005",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1005)
    end
  }
  self.EventItems[4144] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4144,
    count = -1,
    selectedStr = "EnterWindTunnel_1006",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1006)
    end
  }
  self.EventItems[4146] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4146,
    count = -1,
    selectedStr = "EnterWindTunnel_1007",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1007)
    end
  }
  self.EventItems[4148] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4148,
    count = -1,
    selectedStr = "EnterWindTunnel_1008",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1008)
    end
  }
  self.EventItems[4152] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4152,
    count = -1,
    selectedStr = "EnterWindTunnel_1010",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1010)
    end
  }
  self.EventItems[4154] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4154,
    count = -1,
    selectedStr = "EnterWindTunnel_1011",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1011)
    end
  }
  self.EventItems[4156] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4156,
    count = -1,
    selectedStr = "EnterWindTunnel_1012",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1012)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("WindTunnel_Floating_1012")
    end
  }
  self.EventItems[4158] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4158,
    count = -1,
    selectedStr = "EnterWindTunnel_1013",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1013)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[4159] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4159,
    count = -1,
    selectedStr = "ExitWindTunnel_1013",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[4160] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4160,
    count = -1,
    selectedStr = "EnterWindTunnel_1014",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1014)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[4161] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4161,
    count = -1,
    selectedStr = "ExitWindTunnel_1014",
    action = function(localSelf)
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
  self.EventItems[2290] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 2290,
    count = -1,
    layerConfigId = 5212,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 1)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_visuallayer5212")
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"10010265", ""}
      })
    end
  }
  self.EventItems[4335] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 4335,
    count = -1,
    layerConfigId = 5212,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
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
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("main_3rd_starway5", 0, 0, 10, false, 0)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("main_3rd_starway1")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("main_3rd_starway2")
    end
  }
  self.EventItems[4427] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 4427,
    count = -1,
    layerConfigId = 5310,
    action = function(localSelf, layerConfigId)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("main_3rd_starway3")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("main_3rd_starway5")
    end
  }
  self.EventItems[4429] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 4429,
    count = -1,
    selectedStr = "on_10030403_flow_end",
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("main_3rd_starway3")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("main_3rd_starway5")
    end
  }
  self.EventItems[4454] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 4454,
    count = -1,
    selectedStr = "on_10302008_flow_end",
    action = function(localSelf)
      Panda.ZGame.ZEventParser.PreLoadCutscene(201010308)
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
  self.EventItems[4533] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 4533,
    count = -1,
    layerConfigId = 5304,
    action = function(localSelf, layerConfigId)
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
  self.EventItems[4132] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4132,
    count = -1,
    selectedStr = "EnterWindTunnel_Story_02",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\232\191\155\229\133\165\233\163\142\229\138\155\233\128\154\233\129\147\229\133\165\229\143\163\229\140\186\229\159\159----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(1102)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\232\191\155\229\133\165\233\163\142\229\138\155\233\128\154\233\129\147\229\133\165\229\143\163\229\140\186\229\159\159----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[4133] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4133,
    count = -1,
    selectedStr = "ExitWindTunnel_Story_02",
    action = function(localSelf)
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
        eventType = 4,
        intParams = {10101008}
      })
    end
  }
  self.EventItems[4409] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 4409,
    count = -1,
    layerConfigId = 5402,
    action = function(localSelf, layerConfigId)
      Panda.LuaAsyncBridge.SetCurWeatherTime(5)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
      Z.LevelMgr.timerMgr:StartTimer(function()
        Z.LevelMgr.FireSceneEvent({
          eventType = 1,
          strParams = {"10410101", ""}
        })
        Z.LevelMgr.FireSceneEvent({
          eventType = 1,
          strParams = {"10410102", ""}
        })
      end, 4)
    end
  }
  self.EventItems[4410] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 4410,
    count = -1,
    layerConfigId = 5402,
    action = function(localSelf, layerConfigId)
      Panda.LuaAsyncBridge.SetCurWeatherTime(0)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(true)
    end
  }
  self.EventItems[3345] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 3345,
    count = -1,
    action = function(localSelf)
      if Z.VMMgr.GetVM("level_editor").IsQuestExist(120001) == true and Z.VMMgr.GetVM("level_editor").IsWorldEventExist(7075) == true then
        Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_worldevent7075")
      elseif Z.VMMgr.GetVM("level_editor").IsQuestExist(120001) == true and Z.VMMgr.GetVM("level_editor").IsWorldEventExist(7076) == true then
        Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_worldevent7075")
      elseif Z.VMMgr.GetVM("level_editor").IsQuestExist(120001) == true and Z.VMMgr.GetVM("level_editor").IsWorldEventExist(7077) == true then
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
      if Z.VMMgr.GetVM("level_editor").IsQuestExist(120001) == true and Z.VMMgr.GetVM("level_editor").IsWorldEventExist(7075) == true then
        Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_worldevent7075")
      elseif Z.VMMgr.GetVM("level_editor").IsQuestExist(120001) == true and Z.VMMgr.GetVM("level_editor").IsWorldEventExist(7076) == true then
        Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_worldevent7075")
      elseif Z.VMMgr.GetVM("level_editor").IsQuestExist(120001) == true and Z.VMMgr.GetVM("level_editor").IsWorldEventExist(7077) == true then
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
      do
        local entityData = {actorType = 2, groupId = 769}
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
      do
        local entityData = {actorType = 2, tableUid = 14254}
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
      if entityData.groupId then
        Panda.ZGame.ZAIMgr.Instance:SendEventToGroup(entityData.groupId, 500701)
      else
        Panda.ZGame.ZAIMgr.Instance:SendEvent(entityData.tableUid, entityData.actorType, 500701)
      end
      local entityData = {actorType = 2, tableUid = 14306}
      if entityData.groupId then
        Panda.ZGame.ZAIMgr.Instance:SendEventToGroup(entityData.groupId, 500701)
      else
        Panda.ZGame.ZAIMgr.Instance:SendEvent(entityData.tableUid, entityData.actorType, 500701)
      end
      local entityData = {actorType = 2, tableUid = 14307}
      if entityData.groupId then
        Panda.ZGame.ZAIMgr.Instance:SendEventToGroup(entityData.groupId, 500701)
      else
        Panda.ZGame.ZAIMgr.Instance:SendEvent(entityData.tableUid, entityData.actorType, 500701)
      end
      Z.LevelMgr.timerMgr:StartTimer(function()
        do
          local entityData = {actorType = 2, groupId = 769}
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
      end, 20)
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
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1002})
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
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 4)
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
  self.EventItems[4073] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 4073,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("dng_5406_path02", 0, 0, 15, false, 0)
    end
  }
  self.EventItems[4075] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 4075,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("dng_5406_path02")
    end
  }
  self.EventItems[4423] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 4423,
    count = -1,
    layerConfigId = 5406,
    action = function(localSelf, layerConfigId)
      Panda.LuaAsyncBridge.SetCurWeatherTime(5)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(false)
    end
  }
  self.EventItems[4424] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 4424,
    count = -1,
    layerConfigId = 5406,
    action = function(localSelf, layerConfigId)
      Panda.LuaAsyncBridge.SetCurWeatherTime(0)
      Panda.LuaAsyncBridge.SetWeatherIsUpdateFromServer(true)
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
      Z.LevelMgr.FireSceneEvent({
        eventType = 4,
        intParams = {1002}
      })
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
  self.EventItems[4213] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 4213,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[3878] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3878,
    count = -1,
    layerConfigId = 5409,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        3,
        4,
        5,
        6,
        10,
        13,
        14,
        24,
        26,
        27
      }, true, localSelf.eventId)
    end
  }
  self.EventItems[3879] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3879,
    count = -1,
    entity = {actorType = 5, tableUid = 12809},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1, localSelf.eventId)
    end
  }
  self.EventItems[3880] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3880,
    count = -1,
    layerConfigId = 5409,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1, localSelf.eventId)
    end
  }
  self.EventItems[3889] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3889,
    count = -1,
    entity = {actorType = 5, tableUid = 19652},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      local entityData = {actorType = 2, groupId = 698}
      if entityData.groupId then
        Panda.ZGame.ZAIMgr.Instance:SendEventToGroup(entityData.groupId, 3889)
      else
        Panda.ZGame.ZAIMgr.Instance:SendEvent(entityData.tableUid, entityData.actorType, 3889)
      end
    end
  }
  self.EventItems[3890] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3890,
    count = -1,
    entity = {actorType = 5, tableUid = 19653},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      local entityData = {actorType = 2, groupId = 705}
      if entityData.groupId then
        Panda.ZGame.ZAIMgr.Instance:SendEventToGroup(entityData.groupId, 3889)
      else
        Panda.ZGame.ZAIMgr.Instance:SendEvent(entityData.tableUid, entityData.actorType, 3889)
      end
    end
  }
  self.EventItems[3891] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 3891,
    count = -1,
    entity = {actorType = 5, tableUid = 19654},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      local entityData = {actorType = 2, groupId = 706}
      if entityData.groupId then
        Panda.ZGame.ZAIMgr.Instance:SendEventToGroup(entityData.groupId, 3889)
      else
        Panda.ZGame.ZAIMgr.Instance:SendEvent(entityData.tableUid, entityData.actorType, 3889)
      end
    end
  }
  self.EventItems[3906] = {
    eventType = E.LevelEventType.OnVisualLayerEnter,
    enable = true,
    group = 0,
    eventId = 3906,
    count = -1,
    layerConfigId = 5505,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 1)
    end
  }
  self.EventItems[3907] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 3907,
    count = -1,
    layerConfigId = 5505,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[4275] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 4275,
    count = -1,
    entity = {actorType = 5, tableUid = 21076},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(true, 4)
    end
  }
  self.EventItems[4541] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 4541,
    count = -1,
    layerConfigId = 5535,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[4543] = {
    eventType = E.LevelEventType.OnVisualLayerLeave,
    enable = true,
    group = 0,
    eventId = 4543,
    count = -1,
    layerConfigId = 5535,
    action = function(localSelf, layerConfigId)
      Panda.ZGame.ZEventParser.WeatherCtrlClient(false, -1)
    end
  }
  self.EventItems[4177] = {
    eventType = E.LevelEventType.OnFlowPlayEnd,
    enable = true,
    group = 0,
    eventId = 4177,
    count = -1,
    selectedStr = "on_10050428_flow_end",
    action = function(localSelf)
      Panda.ZGame.ZEventParser.PreLoadFlow(10050411)
    end
  }
  self.EventItems[4545] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4545,
    count = -1,
    selectedStr = "ShowPatrolRoute_204",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"16010002", ""}
      })
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("bubble_route_204")
      Z.LevelMgr.timerMgr:StartTimer(function()
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("bubble_route_204", 0, 0, 7.5, true, 0)
      end, 0.3)
    end
  }
  self.EventItems[4546] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4546,
    count = -1,
    selectedStr = "ShowPatrolRoute_205",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"16010002", ""}
      })
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("bubble_route_205")
      Z.LevelMgr.timerMgr:StartTimer(function()
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("bubble_route_205", 0, 0, 7.5, true, 0)
      end, 0.3)
    end
  }
  self.EventItems[4547] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4547,
    count = -1,
    selectedStr = "ShowPatrolRoute_206",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"16010002", ""}
      })
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("bubble_route_206")
      Z.LevelMgr.timerMgr:StartTimer(function()
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("bubble_route_206", 0, 0, 7.5, true, 0)
      end, 0.3)
    end
  }
  self.EventItems[4539] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 4539,
    count = -1,
    entity = {actorType = 5, tableUid = 22101},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen("\229\138\160\232\189\189\229\137\141")
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(50004, 50004001) then
        logGreen("\229\138\160\232\189\189\229\173\144\229\133\179")
        Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_raidentrance")
      end
    end
  }
end

return Scene
