local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[11] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 11,
    count = -1,
    entity = {actorType = 5, tableUid = 1},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {1},
        strParams = {
          "option_select",
          "2001=SMonAc",
          "2002=SMonPa",
          "2003=LMonAc",
          "2004=LMonPa"
        }
      })
    end
  }
  self.EventItems[12] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 12,
    count = -1,
    entity = {actorType = 5, tableUid = 1},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Z.LevelMgr.FireSceneEvent({
        eventType = 10,
        intParams = {0},
        strParams = {
          "option_select",
          "2001=SMonAc",
          "2002=SMonPa",
          "2003=LMonAc",
          "2004=LMonPa"
        }
      })
    end
  }
end

return Scene
