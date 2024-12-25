local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[26] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 26,
    count = -1,
    action = function(localSelf)
      logGreen(string.format("----------\230\146\173\230\148\190\232\183\175\229\190\132\230\181\129\229\133\137\231\137\185\230\149\136(\229\137\141\231\171\175)---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("7065_banyunhuowu", 0, 0, 30, false, 0)
    end
  }
  self.EventItems[27] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 27,
    count = -1,
    action = function(localSelf)
      logGreen(string.format("----------\229\129\156\230\173\162\230\146\173\230\148\190\232\183\175\229\190\132\230\181\129\229\133\137\231\137\185\230\149\136(\229\137\141\231\171\175)---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("7065_banyunhuowu")
    end
  }
  self.EventItems[38] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 38,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({3}, true)
      logGreen(string.format("----------\231\166\129\230\173\162\232\183\179\232\183\131(\229\137\141\231\171\175)---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[39] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 39,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({4}, true)
      logGreen(string.format("----------\231\166\129\230\173\162\229\134\178\229\136\186(\229\137\141\231\171\175)---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[40] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 40,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({10}, true)
      logGreen(string.format("----------\231\166\129\230\173\162\230\138\128\232\131\189(\229\137\141\231\171\175)---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[42] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 42,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1)
      logGreen(string.format("----------\230\184\133\233\153\164\230\137\128\230\156\137\229\177\143\232\148\189(\229\137\141\231\171\175)---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[44] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 44,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1)
      logGreen(string.format("----------\230\184\133\233\153\164\230\137\128\230\156\137\229\177\143\232\148\189(\229\137\141\231\171\175)---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
end

return Scene
