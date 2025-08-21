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
    entity = {actorType = 5, tableUid = 511},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008001) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 511}
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
          local entityData = {actorType = 5, tableUid = 512}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 3, 11, 25, false, 1)
      end
    end
  }
  self.EventItems[42] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 42,
    count = -1,
    entity = {actorType = 5, tableUid = 512},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008002) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 512}
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
          local entityData = {actorType = 5, tableUid = 513}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 11, 14, 25, false, 1)
      end
    end
  }
  self.EventItems[43] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 43,
    count = -1,
    entity = {actorType = 5, tableUid = 513},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008003) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 513}
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
          local entityData = {actorType = 5, tableUid = 514}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 14, 20, 25, false, 1)
      end
    end
  }
  self.EventItems[44] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 44,
    count = -1,
    entity = {actorType = 5, tableUid = 515},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008005) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 515}
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
          local entityData = {actorType = 5, tableUid = 516}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 24, 29, 25, false, 1)
      end
    end
  }
  self.EventItems[45] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 45,
    count = -1,
    entity = {actorType = 5, tableUid = 516},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008006) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 516}
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
          local entityData = {actorType = 5, tableUid = 511}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 29, 33, 25, false, 1)
      end
    end
  }
  self.EventItems[46] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 46,
    count = -1,
    entity = {actorType = 5, tableUid = 517},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008009) then
        do
          local entityData = {actorType = 5, tableUid = 517}
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
    end
  }
  self.EventItems[53] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 53,
    count = -1,
    action = function(localSelf)
    end
  }
  self.EventItems[57] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 57,
    count = -1,
    entity = {actorType = 5, tableUid = 510},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008010) then
        logGreen(string.format("-----\232\167\166\229\143\145\229\137\141\231\171\175\228\186\139\228\187\182----- : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
        do
          local entityData = {actorType = 5, tableUid = 511}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 0, 3, 25, false, 1)
      end
    end
  }
  self.EventItems[61] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 61,
    count = -1,
    entity = {actorType = 5, tableUid = 514},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008004) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 514}
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
          local entityData = {actorType = 5, tableUid = 515}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 20, 24, 25, false, 1)
      end
    end
  }
  self.EventItems[65] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 65,
    count = -1,
    entity = {actorType = 5, tableUid = 511},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008023) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 511}
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
          local entityData = {actorType = 5, tableUid = 512}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 3, 11, 25, false, 1)
      end
    end
  }
  self.EventItems[66] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 66,
    count = -1,
    entity = {actorType = 5, tableUid = 512},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008024) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 512}
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
          local entityData = {actorType = 5, tableUid = 513}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 11, 14, 25, false, 1)
      end
    end
  }
  self.EventItems[67] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 67,
    count = -1,
    entity = {actorType = 5, tableUid = 513},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008025) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 513}
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
          local entityData = {actorType = 5, tableUid = 514}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 14, 20, 25, false, 1)
      end
    end
  }
  self.EventItems[68] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 68,
    count = -1,
    entity = {actorType = 5, tableUid = 514},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008026) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 514}
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
          local entityData = {actorType = 5, tableUid = 515}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 20, 24, 25, false, 1)
      end
    end
  }
  self.EventItems[69] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 69,
    count = -1,
    entity = {actorType = 5, tableUid = 515},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008027) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 515}
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
          local entityData = {actorType = 5, tableUid = 516}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 24, 29, 25, false, 1)
      end
    end
  }
  self.EventItems[70] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 70,
    count = -1,
    entity = {actorType = 5, tableUid = 516},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008028) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 516}
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
          local entityData = {actorType = 5, tableUid = 511}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 29, 33, 25, false, 1)
      end
    end
  }
  self.EventItems[71] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 71,
    count = -1,
    entity = {actorType = 5, tableUid = 511},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008029) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 511}
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
          local entityData = {actorType = 5, tableUid = 512}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 3, 11, 25, false, 1)
      end
    end
  }
  self.EventItems[72] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 72,
    count = -1,
    entity = {actorType = 5, tableUid = 512},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008030) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 512}
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
          local entityData = {actorType = 5, tableUid = 513}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 11, 14, 25, false, 1)
      end
    end
  }
  self.EventItems[73] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 73,
    count = -1,
    entity = {actorType = 5, tableUid = 513},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008031) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 513}
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
          local entityData = {actorType = 5, tableUid = 514}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 14, 20, 25, false, 1)
      end
    end
  }
  self.EventItems[74] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 74,
    count = -1,
    entity = {actorType = 5, tableUid = 514},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008032) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 514}
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
          local entityData = {actorType = 5, tableUid = 515}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 20, 24, 25, false, 1)
      end
    end
  }
  self.EventItems[75] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 75,
    count = -1,
    entity = {actorType = 5, tableUid = 515},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008033) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 515}
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
          local entityData = {actorType = 5, tableUid = 516}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 24, 29, 25, false, 1)
      end
    end
  }
  self.EventItems[76] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 76,
    count = -1,
    entity = {actorType = 5, tableUid = 516},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130008, 130008034) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 516}
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
          local entityData = {actorType = 5, tableUid = 517}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour03_GuideLine", 34, 37, 25, false, 1)
      end
    end
  }
end

return Scene
