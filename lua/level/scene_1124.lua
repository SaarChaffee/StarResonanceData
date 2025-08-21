local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {1}

function Scene:InitEvents()
  self.EventItems = {}
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
  self.EventItems[100830] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 100830,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("HeroDungeon_Tower/Guide_easy", 0, 0, 20, false, 0)
    end
  }
  self.EventItems[100831] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 100831,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("HeroDungeon_Tower/Guide_hard", 0, 0, 20, false, 0)
    end
  }
end

return Scene
