local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[548] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 548,
    count = 1,
    entity = {actorType = 5, tableUid = 806},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
    end
  }
  self.EventItems[100826] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 100826,
    count = -1,
    action = function(localSelf)
      logGreen("\232\167\166\229\143\145\229\137\141\231\171\175\229\188\149\229\175\188\231\186\191")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("HeroDungeon_Tina/Guide_easy", 0, 0, 20, false, 0)
    end
  }
  self.EventItems[100828] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 100828,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("HeroDungeon_Tina/Guide_hard", 0, 0, 20, false, 0)
    end
  }
end

return Scene
