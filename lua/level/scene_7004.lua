local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[20] = {
    eventType = E.LevelEventType.OnSceneInit,
    enable = true,
    group = 0,
    eventId = 20,
    count = -1,
    action = function(localSelf)
    end
  }
  self.EventItems[44] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 44,
    count = -1,
    entity = {actorType = 5, tableUid = 94},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009016) then
        do
          local entityData = {actorType = 5, tableUid = 94}
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
          local entityData = {actorType = 5, tableUid = 30}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 0, 1, 25, false, 1)
      end
    end
  }
  self.EventItems[45] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 45,
    count = -1,
    entity = {actorType = 5, tableUid = 30},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009001) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 30}
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
          local entityData = {actorType = 5, tableUid = 31}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 1, 2, 25, false, 1)
      end
    end
  }
  self.EventItems[46] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 46,
    count = -1,
    entity = {actorType = 5, tableUid = 31},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009002) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 31}
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
          local entityData = {actorType = 5, tableUid = 32}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 2, 4, 25, false, 1)
      end
    end
  }
  self.EventItems[47] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 47,
    count = -1,
    entity = {actorType = 5, tableUid = 32},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009003) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 32}
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
          local entityData = {actorType = 5, tableUid = 33}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 4, 9, 25, false, 1)
      end
    end
  }
  self.EventItems[48] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 48,
    count = -1,
    entity = {actorType = 5, tableUid = 33},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009004) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 33}
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
          local entityData = {actorType = 5, tableUid = 34}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 9, 15, 25, false, 1)
      end
    end
  }
  self.EventItems[49] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 49,
    count = -1,
    entity = {actorType = 5, tableUid = 34},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009005) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 34}
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
          local entityData = {actorType = 5, tableUid = 35}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 15, 19, 25, false, 1)
      end
    end
  }
  self.EventItems[50] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 50,
    count = -1,
    entity = {actorType = 5, tableUid = 35},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009006) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 35}
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
          local entityData = {actorType = 5, tableUid = 36}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 19, 24, 25, false, 1)
      end
    end
  }
  self.EventItems[51] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 51,
    count = -1,
    entity = {actorType = 5, tableUid = 36},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009007) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 36}
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
          local entityData = {actorType = 5, tableUid = 37}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 24, 28, 25, false, 1)
      end
    end
  }
  self.EventItems[52] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 52,
    count = -1,
    entity = {actorType = 5, tableUid = 37},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009008) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 37}
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
          local entityData = {actorType = 5, tableUid = 38}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 28, 30, 25, false, 1)
      end
    end
  }
  self.EventItems[53] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 53,
    count = -1,
    entity = {actorType = 5, tableUid = 38},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009009) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 38}
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
          local entityData = {actorType = 5, tableUid = 39}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 30, 32, 25, false, 1)
      end
    end
  }
  self.EventItems[54] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 54,
    count = -1,
    entity = {actorType = 5, tableUid = 39},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009010) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 39}
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
          local entityData = {actorType = 5, tableUid = 40}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 32, 38, 25, false, 1)
      end
    end
  }
  self.EventItems[55] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 55,
    count = -1,
    entity = {actorType = 5, tableUid = 40},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009011) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 40}
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
          local entityData = {actorType = 5, tableUid = 41}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 38, 53, 25, false, 1)
      end
    end
  }
  self.EventItems[56] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 56,
    count = -1,
    entity = {actorType = 5, tableUid = 41},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009012) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 41}
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
          local entityData = {actorType = 5, tableUid = 42}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 53, 56, 25, false, 1)
      end
    end
  }
  self.EventItems[57] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 57,
    count = -1,
    entity = {actorType = 5, tableUid = 42},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009013) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 42}
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
          local entityData = {actorType = 5, tableUid = 43}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 56, 66, 25, false, 1)
      end
    end
  }
  self.EventItems[58] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 58,
    count = -1,
    entity = {actorType = 5, tableUid = 43},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009014) then
        Panda.ZAudio.ZAudioMgr.Instance:Play("sfx_questtimelimited_target")
        do
          local entityData = {actorType = 5, tableUid = 43}
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
          local entityData = {actorType = 5, tableUid = 44}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
        Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("Multiparkour04_GuideLine", 66, 72, 25, false, 1)
      end
    end
  }
  self.EventItems[59] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 59,
    count = -1,
    entity = {actorType = 5, tableUid = 44},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      if Z.VMMgr.GetVM("level_editor").IsQuestStepGoing(130009, 130009015) then
        do
          local entityData = {actorType = 5, tableUid = 44}
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
          local entityData = {actorType = 3, tableUid = 96}
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
        Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("Multiparkour04_GuideLine")
      end
    end
  }
end

return Scene
