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
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1001})
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
  self.EventItems[1394] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 1394,
    count = -1,
    entity = {actorType = 5, tableUid = 820},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/dng_main_1101_tower_story_freeze")
    end
  }
  self.EventItems[1396] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 1396,
    count = -1,
    entity = {actorType = 5, tableUid = 820},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.Streaming.StreamingManager.Instance:CloseStoryState("scenes/dng_main_1101_tower_story_freeze")
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
end

return Scene
