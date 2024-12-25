local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[33] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 33,
    count = -1,
    entity = {actorType = 5, tableUid = 196},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 196}
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
        local entityData = {actorType = 5, tableUid = 197}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour02_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour02_GuideLine", 1, 12, 50, false, 0)
    end
  }
  self.EventItems[34] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 34,
    count = -1,
    entity = {actorType = 5, tableUid = 197},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 197}
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
        local entityData = {actorType = 5, tableUid = 198}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour02_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour02_GuideLine", 6, 18, 50, false, 0)
    end
  }
  self.EventItems[35] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 35,
    count = -1,
    entity = {actorType = 5, tableUid = 198},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 198}
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
        local entityData = {actorType = 5, tableUid = 199}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour02_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour02_GuideLine", 12, 18, 50, false, 0)
    end
  }
  self.EventItems[36] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 36,
    count = -1,
    entity = {actorType = 5, tableUid = 199},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 199}
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
        local entityData = {actorType = 5, tableUid = 200}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour02_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour02_GuideLine", 18, 30, 50, false, 0)
    end
  }
  self.EventItems[37] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 37,
    count = -1,
    entity = {actorType = 5, tableUid = 199},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 200}
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
        local entityData = {actorType = 5, tableUid = 201}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour02_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour02_GuideLine", 18, 38, 50, false, 0)
    end
  }
  self.EventItems[38] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 38,
    count = -1,
    entity = {actorType = 5, tableUid = 201},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 201}
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
        local entityData = {actorType = 5, tableUid = 202}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour02_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour02_GuideLine", 18, 38, 50, false, 0)
    end
  }
  self.EventItems[39] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 39,
    count = -1,
    entity = {actorType = 5, tableUid = 202},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      do
        local entityData = {actorType = 5, tableUid = 202}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour02_GuideLine")
    end
  }
  self.EventItems[59] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 59,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, tableUid = 196}
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
        local entityData = {actorType = 5, tableUid = 361}
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
  self.EventItems[71] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 71,
    count = 1,
    entity = {actorType = 5, tableUid = 361},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      logGreen(string.format("\230\138\181\232\190\190\232\181\183\231\130\185(\229\137\141\231\171\175\229\140\186\229\159\159\230\163\128\230\181\139\233\128\187\232\190\145\232\167\166\229\143\145)\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      do
        local entityData = {actorType = 5, tableUid = 361}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour02_GuideLine", 0, 3, 50, false, 0)
    end
  }
end

return Scene
