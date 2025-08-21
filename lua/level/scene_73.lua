local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[82] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 82,
    count = -1,
    selectedStr = "EnterWindTunnel_7301",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(7301)
    end
  }
  self.EventItems[88] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 88,
    count = -1,
    selectedStr = "EnterWindTunnel_7302",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(7302)
    end
  }
  self.EventItems[94] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 94,
    count = -1,
    selectedStr = "EnterWindTunnel_7303",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(7303)
    end
  }
  self.EventItems[100] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 100,
    count = -1,
    selectedStr = "EnterWindTunnel_7304",
    action = function(localSelf)
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(7304)
    end
  }
  self.EventItems[106] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 106,
    count = -1,
    entity = {actorType = 5, tableUid = 789},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("danganguanliyuan_1", 0, 0, 50, false, 0)
    end
  }
  self.EventItems[107] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 107,
    count = -1,
    entity = {actorType = 5, tableUid = 444},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("danganguanliyuan_1")
    end
  }
end

return Scene
