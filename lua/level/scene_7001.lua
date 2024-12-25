local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[461] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 461,
    count = 1,
    entity = {actorType = 5, tableUid = 1275},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      logGreen(string.format("\230\138\181\232\190\190\232\138\130\231\130\18501\239\188\140\229\136\160\233\153\164\232\138\130\231\130\18501\231\154\132\231\137\185\230\149\136(\229\137\141\231\171\175\229\140\186\229\159\159\230\163\128\230\181\139\233\128\187\232\190\145\232\167\166\229\143\145)\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 1275}
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
        local entityData = {actorType = 5, tableUid = 1276}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour01_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour01_GuideLine", 1, 3, 50, false, 0)
    end
  }
  self.EventItems[462] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 462,
    count = 1,
    entity = {actorType = 5, tableUid = 1276},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      logGreen(string.format("\230\138\181\232\190\190\232\138\130\231\130\18502\239\188\140\229\136\160\233\153\164\232\138\130\231\130\18502\231\154\132\231\137\185\230\149\136(\229\137\141\231\171\175\229\140\186\229\159\159\230\163\128\230\181\139\233\128\187\232\190\145\232\167\166\229\143\145)\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 1276}
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
        local entityData = {actorType = 5, tableUid = 1277}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour01_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour01_GuideLine", 2, 4, 50, false, 0)
    end
  }
  self.EventItems[463] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 463,
    count = 1,
    entity = {actorType = 5, tableUid = 1277},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      logGreen(string.format("\230\138\181\232\190\190\232\138\130\231\130\18503\239\188\140\229\136\160\233\153\164\232\138\130\231\130\18503\231\154\132\231\137\185\230\149\136(\229\137\141\231\171\175\229\140\186\229\159\159\230\163\128\230\181\139\233\128\187\232\190\145\232\167\166\229\143\145)\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 1277}
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
        local entityData = {actorType = 5, tableUid = 1278}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour01_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour01_GuideLine", 5, 8, 50, false, 0)
    end
  }
  self.EventItems[464] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 464,
    count = 1,
    entity = {actorType = 5, tableUid = 1278},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      logGreen(string.format("\230\138\181\232\190\190\232\138\130\231\130\18504\239\188\140\229\136\160\233\153\164\232\138\130\231\130\18504\231\154\132\231\137\185\230\149\136(\229\137\141\231\171\175\229\140\186\229\159\159\230\163\128\230\181\139\233\128\187\232\190\145\232\167\166\229\143\145)\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 1278}
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
        local entityData = {actorType = 5, tableUid = 1279}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour01_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour01_GuideLine", 6, 9, 50, false, 0)
    end
  }
  self.EventItems[465] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 465,
    count = 1,
    entity = {actorType = 5, tableUid = 1279},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      logGreen(string.format("\230\138\181\232\190\190\232\138\130\231\130\18505\239\188\140\229\136\160\233\153\164\232\138\130\231\130\18505\231\154\132\231\137\185\230\149\136(\229\137\141\231\171\175\229\140\186\229\159\159\230\163\128\230\181\139\233\128\187\232\190\145\232\167\166\229\143\145)\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 1279}
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
        local entityData = {actorType = 5, tableUid = 1280}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour01_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour01_GuideLine", 8, 10, 50, false, 0)
    end
  }
  self.EventItems[466] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 466,
    count = 1,
    entity = {actorType = 5, tableUid = 1280},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      logGreen(string.format("\230\138\181\232\190\190\232\138\130\231\130\18506\239\188\140\229\136\160\233\153\164\232\138\130\231\130\18506\231\154\132\231\137\185\230\149\136(\229\137\141\231\171\175\229\140\186\229\159\159\230\163\128\230\181\139\233\128\187\232\190\145\232\167\166\229\143\145)\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
      do
        local entityData = {actorType = 5, tableUid = 1280}
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
        local entityData = {actorType = 5, tableUid = 1281}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour01_GuideLine")
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour01_GuideLine", 9, 13, 50, false, 0)
    end
  }
  self.EventItems[467] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 467,
    count = 1,
    entity = {actorType = 5, tableUid = 1281},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      logGreen(string.format("\230\138\181\232\190\190\232\138\130\231\130\18507\239\188\140\229\136\160\233\153\164\232\138\130\231\130\18507\231\154\132\231\137\185\230\149\136(\229\137\141\231\171\175\229\140\186\229\159\159\230\163\128\230\181\139\233\128\187\232\190\145\232\167\166\229\143\145)\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      do
        local entityData = {actorType = 5, tableUid = 1281}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour01_GuideLine")
    end
  }
  self.EventItems[560] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 560,
    count = -1,
    action = function(localSelf)
      do
        local entityData = {actorType = 5, tableUid = 1275}
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
        local entityData = {actorType = 5, tableUid = 1498}
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
  self.EventItems[584] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 584,
    count = 1,
    entity = {actorType = 5, tableUid = 1498},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      logGreen(string.format("\230\138\181\232\190\190\232\181\183\231\130\185(\229\137\141\231\171\175\229\140\186\229\159\159\230\163\128\230\181\139\233\128\187\232\190\145\232\167\166\229\143\145)\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129 : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      do
        local entityData = {actorType = 5, tableUid = 1498}
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
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour01_GuideLine", 0, 2, 50, false, 0)
    end
  }
end

return Scene
