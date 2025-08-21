local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[31] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 31,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({13, 14}, false, localSelf.eventId)
    end
  }
  self.EventItems[32] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 32,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1, localSelf.eventId)
    end
  }
  self.EventItems[50] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 50,
    count = -1,
    action = function(localSelf)
      logGreen(string.format("----------\230\146\173\230\148\190\232\183\175\229\190\132\230\181\129\229\133\137\231\137\185\230\149\136(\229\137\141\231\171\175)---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("dng_7061/8001_m60120_L", 0, 0, 30, false, 0)
    end
  }
  self.EventItems[51] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 51,
    count = -1,
    action = function(localSelf)
      logGreen(string.format("----------\229\129\156\230\173\162\230\146\173\230\148\190\232\183\175\229\190\132\230\181\129\229\133\137\231\137\185\230\149\136(\229\137\141\231\171\175)---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("dng_7061/8001_m60120_L")
    end
  }
  self.EventItems[52] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 52,
    count = -1,
    action = function(localSelf)
      logGreen(string.format("----------\230\146\173\230\148\190\232\183\175\229\190\132\230\181\129\229\133\137\231\137\185\230\149\136(\229\137\141\231\171\175)---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("dng_7061/8001_m60120_R", 0, 0, 30, false, 0)
    end
  }
  self.EventItems[53] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 53,
    count = -1,
    action = function(localSelf)
      logGreen(string.format("----------\229\129\156\230\173\162\230\146\173\230\148\190\232\183\175\229\190\132\230\181\129\229\133\137\231\137\185\230\149\136(\229\137\141\231\171\175)---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("dng_7061/8001_m60120_R")
    end
  }
end

return Scene
