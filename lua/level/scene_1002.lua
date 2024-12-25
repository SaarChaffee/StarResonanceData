local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[1280] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 1280,
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
  self.EventItems[1281] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 10104011,
    group = 0,
    eventId = 1281,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1)
    end
  }
  self.EventItems[1294] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1294,
    count = -1,
    entity = {actorType = 5, tableUid = 969},
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
  self.EventItems[1217] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1217,
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
  self.EventItems[1075] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 1075,
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
  self.EventItems[1271] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 1271,
    count = -1,
    entity = {actorType = 5, tableUid = 536},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiBattleUIIgnoreOneLayer({0}, false)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({
        3,
        4,
        5,
        10,
        17,
        19,
        20,
        24
      }, false)
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
  self.EventItems[1284] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 1027,
    group = 0,
    eventId = 1284,
    count = 1,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1018})
    end
  }
end

return Scene
