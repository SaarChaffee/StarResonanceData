local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[1] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 1,
    count = -1,
    selectedStr = "PlayEffect-client",
    action = function(localSelf)
      local entityData
      if entityData ~= nil then
        Z.LevelMgr.FireSceneEvent({
          eventType = 27,
          strParams = {
            "effect/character/p_fx_kuining_fensheng_chuxian"
          },
          intParams = {
            1,
            3,
            entityData.actorType,
            entityData.tableUid
          },
          floatParams = {
            0,
            0,
            0,
            0.5,
            0,
            -1
          }
        })
      else
        Z.LevelMgr.FireSceneEvent({
          eventType = 27,
          strParams = {
            "effect/character/p_fx_kuining_fensheng_chuxian"
          },
          intParams = {
            1,
            3,
            0,
            0
          },
          floatParams = {
            0,
            0,
            0,
            0.5,
            0,
            -1
          }
        })
      end
      local entityData = {actorType = 1, tableUid = 4}
      if entityData ~= nil then
        Z.LevelMgr.FireSceneEvent({
          eventType = 27,
          strParams = {
            "effect/character/p_fx_kuining_fensheng_chuxian"
          },
          intParams = {
            2,
            0,
            entityData.actorType,
            entityData.tableUid
          },
          floatParams = {
            0,
            0,
            0,
            0,
            0,
            0
          }
        })
      else
        Z.LevelMgr.FireSceneEvent({
          eventType = 27,
          strParams = {
            "effect/character/p_fx_kuining_fensheng_chuxian"
          },
          intParams = {
            2,
            0,
            0,
            0
          },
          floatParams = {
            0,
            0,
            0,
            0,
            0,
            0
          }
        })
      end
      local entityData
      if entityData ~= nil then
        Z.LevelMgr.FireSceneEvent({
          eventType = 27,
          strParams = {
            "effect/character/p_fx_kuining_fensheng_chuxian"
          },
          intParams = {
            3,
            0,
            entityData.actorType,
            entityData.tableUid
          },
          floatParams = {
            5,
            5,
            5,
            1,
            1,
            1
          }
        })
      else
        Z.LevelMgr.FireSceneEvent({
          eventType = 27,
          strParams = {
            "effect/character/p_fx_kuining_fensheng_chuxian"
          },
          intParams = {
            3,
            0,
            0,
            0
          },
          floatParams = {
            5,
            5,
            5,
            1,
            1,
            1
          }
        })
      end
      local entityData
      if entityData ~= nil then
        Z.LevelMgr.FireSceneEvent({
          eventType = 27,
          strParams = {
            "effect/character/p_fx_kuining_fensheng_chuxian"
          },
          intParams = {
            4,
            0,
            entityData.actorType,
            entityData.tableUid
          },
          floatParams = {
            0,
            0,
            0,
            0,
            0.5,
            0
          }
        })
      else
        Z.LevelMgr.FireSceneEvent({
          eventType = 27,
          strParams = {
            "effect/character/p_fx_kuining_fensheng_chuxian"
          },
          intParams = {
            4,
            0,
            0,
            0
          },
          floatParams = {
            0,
            0,
            0,
            0,
            0.5,
            0
          }
        })
      end
    end
  }
  self.EventItems[68] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 68,
    count = -1,
    selectedStr = "PlayFlowC",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 15,
        intParams = {10030411}
      })
    end
  }
  self.EventItems[69] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 69,
    count = -1,
    selectedStr = "StopFlowC",
    action = function(localSelf)
      Z.LevelMgr.FireSceneEvent({
        eventType = 15,
        intParams = {-10030411}
      })
    end
  }
  self.EventItems[4] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 4,
    count = -1,
    action = function(localSelf)
      logGreen(string.format("\230\137\167\232\161\140\228\186\134\229\137\141\231\171\175\231\169\186\232\138\130\231\130\185\228\186\139\228\187\182 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[10] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 10,
    count = -1,
    action = function(localSelf)
      logGreen(string.format("\229\156\186\230\153\175\229\136\157\229\167\139\229\140\150\229\174\140\230\136\144\228\186\139\228\187\182\239\188\136\229\137\141\231\171\175\239\188\137 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
end

return Scene
