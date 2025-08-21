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
end

return Scene
