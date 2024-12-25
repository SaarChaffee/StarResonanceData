local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[4] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 4,
    count = -1,
    selectedStr = "ActivateWindTunnel_1025",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      do
        local entityData = {actorType = 5, tableUid = 95}
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
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[5] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 5,
    count = -1,
    entity = {actorType = 5, tableUid = 95},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(2025)
      do
        local entityData = {actorType = 5, tableUid = 96}
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
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[6] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 6,
    count = -1,
    entity = {actorType = 5, tableUid = 96},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      do
        local entityData = {actorType = 5, tableUid = 95}
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
        local entityData = {actorType = 5, tableUid = 96}
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
      require("zproxy.world_proxy").UserDoAction("73_WindTunnel_Floating01_1")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[8] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 8,
    count = -1,
    selectedStr = "ActivateWindTunnel_2026",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      do
        local entityData = {actorType = 5, tableUid = 102}
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
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[9] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 9,
    count = -1,
    entity = {actorType = 5, tableUid = 102},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(2026)
      do
        local entityData = {actorType = 5, tableUid = 103}
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
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[10] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 10,
    count = -1,
    entity = {actorType = 5, tableUid = 103},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      do
        local entityData = {actorType = 5, tableUid = 102}
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
        local entityData = {actorType = 5, tableUid = 103}
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
      require("zproxy.world_proxy").UserDoAction("73_WindTunnel_Floating01_2")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[12] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 12,
    count = -1,
    selectedStr = "ActivateWindTunnel_2028",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      do
        local entityData = {actorType = 5, tableUid = 120}
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
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[13] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 13,
    count = -1,
    entity = {actorType = 5, tableUid = 120},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(2028)
      do
        local entityData = {actorType = 5, tableUid = 121}
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
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[14] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 14,
    count = -1,
    entity = {actorType = 5, tableUid = 121},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      do
        local entityData = {actorType = 5, tableUid = 120}
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
        local entityData = {actorType = 5, tableUid = 121}
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
      require("zproxy.world_proxy").UserDoAction("73_WindTunnel_Floating02_2")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[16] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 16,
    count = -1,
    selectedStr = "ActivateWindTunnel_2027",
    action = function(localSelf)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      do
        local entityData = {actorType = 5, tableUid = 127}
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
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\233\128\154\233\129\147\230\191\128\230\180\187\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[17] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 17,
    count = -1,
    entity = {actorType = 5, tableUid = 127},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      Panda.ZGame.ZWindTunnelMgr.Instance:EnterTunnel(2027)
      do
        local entityData = {actorType = 5, tableUid = 128}
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
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\232\191\155\229\133\165\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
  self.EventItems[18] = {
    eventType = E.LevelEventType.OnZoneExitClient,
    enable = true,
    group = 0,
    eventId = 18,
    count = -1,
    entity = {actorType = 5, tableUid = 128},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\229\188\128\229\167\139------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
      do
        local entityData = {actorType = 5, tableUid = 127}
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
        local entityData = {actorType = 5, tableUid = 128}
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
      require("zproxy.world_proxy").UserDoAction("73_WindTunnel_Floating02_1")
      logGreen(string.format("\239\188\136\229\133\179\229\141\161\231\188\150\232\190\145\229\153\168\230\137\147\229\141\176\239\188\137\233\163\142\229\138\155\233\128\154\233\129\147\231\154\132\231\166\187\229\188\128\233\128\187\232\190\145----\231\187\147\230\157\159------ : nil = %s, nil = %s, nil = %s", tostring(nil), tostring(nil), tostring(nil)))
    end
  }
end

return Scene
