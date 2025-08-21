local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {1}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[549] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 549,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2032}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2030}, -1)
    end
  }
  self.EventItems[100937] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 50610001,
    group = 0,
    eventId = 100937,
    count = -1,
    action = function(localSelf)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1027})
    end
  }
  self.EventItems[100832] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 100832,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("HeroDungeon_Goblin/Guide_hard", 0, 0, 20, false, 0)
    end
  }
end

return Scene
