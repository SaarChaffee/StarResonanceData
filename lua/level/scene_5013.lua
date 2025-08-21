local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[95] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 95,
    count = -1,
    action = function(localSelf)
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
    end
  }
  self.EventItems[1314] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 1314,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ClearAllIgnoreByScene(-1, localSelf.eventId)
    end
  }
  self.EventItems[82] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 501301,
    group = 0,
    eventId = 82,
    count = -1,
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 1,
        strParams = {"50130015", ""}
      })
    end
  }
  self.EventItems[1444] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 1444,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({0}, true, localSelf.eventId)
      Z.LevelMgr.timerMgr:StartTimer(function()
        Panda.ZGame.ZIgnoreMgr.Instance:ModMultiInputIgnoreOneLayer({0}, false, localSelf.eventId)
      end, 4)
    end
  }
end

return Scene
