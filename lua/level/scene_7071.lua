local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[17] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 17,
    count = -1,
    action = function(localSelf)
      Panda.Streaming.StreamingManager.Instance:OpenStoryStateForLua("scenes/fld001_story_worldevent7071")
      logGreen(string.format("----------\229\138\160\232\189\1897071\229\173\144\229\156\186\230\153\175---------- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[23] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 23,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 8}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 24,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:CreateClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      logGreen(string.format("-----\229\136\155\229\187\18602\231\169\186\230\176\148\229\162\153(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[34] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 34,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("7071_guangqiaofuben_phase2_a", 0, 0, 5, true, 0)
      logGreen(string.format("-----\230\146\173\230\148\19002\230\181\129\229\133\137\231\137\185\230\149\136(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[35] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 35,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("7071_guangqiaofuben_phase3_a", 0, 0, 5, true, 0)
      logGreen(string.format("-----\230\146\173\230\148\19003\230\181\129\229\133\137\231\137\185\230\149\136(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[48] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 48,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("7071_guangqiaofuben_phase3_b", 0, 0, 5, true, 0)
      logGreen(string.format("-----\230\146\173\230\148\19003\230\181\129\229\133\137\231\137\185\230\149\136(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[49] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 49,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("7071_guangqiaofuben_phase3_c", 0, 0, 5, true, 0)
      logGreen(string.format("-----\230\146\173\230\148\19003\230\181\129\229\133\137\231\137\185\230\149\136(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[41] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 41,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 9}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 24,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:CreateClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      logGreen(string.format("-----\229\136\155\229\187\18603\231\169\186\230\176\148\229\162\153(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[54] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 54,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 10}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 24,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:CreateClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      logGreen(string.format("-----\229\136\155\229\187\18603\231\169\186\230\176\148\229\162\153(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[55] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 55,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 11}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 24,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:CreateClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      logGreen(string.format("-----\229\136\155\229\187\18603\231\169\186\230\176\148\229\162\153(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[42] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 42,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("7071_guangqiaofuben_phase4_a1", 0, 0, 5, true, 0)
      logGreen(string.format("-----\230\146\173\230\148\19004\230\181\129\229\133\137\231\137\185\230\149\136(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[50] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 50,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("7071_guangqiaofuben_phase4_b1", 0, 0, 5, true, 0)
      logGreen(string.format("-----\230\146\173\230\148\19004\230\181\129\229\133\137\231\137\185\230\149\136(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[51] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 51,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("7071_guangqiaofuben_phase4_c1", 0, 0, 5, true, 0)
      logGreen(string.format("-----\230\146\173\230\148\19004\230\181\129\229\133\137\231\137\185\230\149\136(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[43] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 43,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 12}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 24,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:CreateClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      logGreen(string.format("-----\229\136\155\229\187\18604\231\169\186\230\176\148\229\162\153(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[56] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 56,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 13}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 24,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:CreateClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      logGreen(string.format("-----\229\136\155\229\187\18604\231\169\186\230\176\148\229\162\153(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[57] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 57,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, groupId = 14}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 24,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:CreateClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      logGreen(string.format("-----\229\136\155\229\187\18604\231\169\186\230\176\148\229\162\153(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[44] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 44,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("7071_guangqiaofuben_phase4_a2", 0, 0, 5, true, 0)
      logGreen(string.format("-----\230\146\173\230\148\19005\230\181\129\229\133\137\231\137\185\230\149\136(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[52] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 52,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("7071_guangqiaofuben_phase4_b2", 0, 0, 5, true, 0)
      logGreen(string.format("-----\230\146\173\230\148\19005\230\181\129\229\133\137\231\137\185\230\149\136(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[53] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 53,
    count = -1,
    action = function(localSelf)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("7071_guangqiaofuben_phase4_c2", 0, 0, 5, true, 0)
      logGreen(string.format("-----\230\146\173\230\148\19005\230\181\129\229\133\137\231\137\185\230\149\136(\231\187\147\230\157\159)----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
end

return Scene
