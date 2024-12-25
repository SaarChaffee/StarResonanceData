local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[41] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 41,
    count = -1,
    entity = {actorType = 5, tableUid = 63},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 63}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 25,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:RemoveClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      do
        local entityData = {actorType = 5, tableUid = 64}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour03_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 3, 18, 25, false, 1)
    end
  }
  self.EventItems[42] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 42,
    count = -1,
    entity = {actorType = 5, tableUid = 64},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 64}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 25,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:RemoveClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      do
        local entityData = {actorType = 5, tableUid = 65}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour03_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 11, 22, 25, false, 1)
    end
  }
  self.EventItems[43] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 43,
    count = -1,
    entity = {actorType = 5, tableUid = 65},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 65}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 25,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:RemoveClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      do
        local entityData = {actorType = 5, tableUid = 353}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour03_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 18, 28, 25, false, 1)
    end
  }
  self.EventItems[44] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 44,
    count = -1,
    entity = {actorType = 5, tableUid = 66},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 66}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 25,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:RemoveClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      do
        local entityData = {actorType = 5, tableUid = 69}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour03_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 22, 34, 25, false, 1)
    end
  }
  self.EventItems[45] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 45,
    count = -1,
    entity = {actorType = 5, tableUid = 69},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 69}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 25,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:RemoveClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      do
        local entityData = {actorType = 5, tableUid = 92}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour03_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 28, 34, 25, false, 1)
    end
  }
  self.EventItems[46] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 46,
    count = -1,
    entity = {actorType = 5, tableUid = 92},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 92}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 25,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:RemoveClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour03_GuideLine")
    end
  }
  self.EventItems[53] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 53,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, tableUid = 258}
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
      do
        local entityData = {actorType = 5, tableUid = 63}
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
    end
  }
  self.EventItems[57] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 57,
    count = -1,
    entity = {actorType = 5, tableUid = 258},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\230\138\181\232\190\190\232\181\183\231\130\185(\229\137\141\231\171\175\229\140\186\229\159\159\230\163\128\230\181\139\233\128\187\232\190\145\232\167\166\229\143\145)\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      do
        local entityData = {actorType = 5, tableUid = 258}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 25,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:RemoveClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      do
        local entityData = {actorType = 5, tableUid = 63}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 0, 11, 25, false, 1)
    end
  }
  self.EventItems[61] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 61,
    count = -1,
    entity = {actorType = 5, tableUid = 353},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 353}
        if entityData.groupId then
          Z.LevelMgr.FireSceneEvent({
            eventType = 25,
            intParams = {
              entityData.groupId
            }
          })
        else
          Panda.ZGame.ZClientEntityMgr.Instance:RemoveClientEntityLua(entityData.tableUid, entityData.actorType)
        end
      end
      do
        local entityData = {actorType = 5, tableUid = 66}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour03_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 22, 34, 25, false, 1)
    end
  }
end

return Scene
