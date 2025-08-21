local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[102099] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 102099,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2032}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2030}, 0)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2004}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2002}, 0)
      Panda.LuaAsyncBridge.PlayerRemoveClientBuffLua(881649)
    end
  }
  self.EventItems[102119] = {
    eventType = E.LevelEventType.OnZoneEnterClient,
    enable = true,
    group = 0,
    eventId = 102119,
    count = -1,
    entity = {actorType = 5, tableUid = 103929},
    action = function(localSelf, isGroup, groupId, zoneEntId, entity)
      Panda.ZGame.ZEventParser.PreLoadCutscene(101010508)
      Panda.ZGame.ZEventParser.PreLoadCutscene(101010511)
    end
  }
  self.EventItems[102509] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102509,
    count = -1,
    action = function(localSelf)
      logGreen("\232\167\166\229\143\145\229\156\186\230\153\175\231\178\146\229\173\144")
      Panda.LuaAsyncBridge.PlayerAddClientBuffLua(881649)
    end
  }
  self.EventItems[102510] = {
    eventType = E.LevelEventType.TriggerEvent,
    enable = true,
    group = 0,
    eventId = 102510,
    count = -1,
    action = function(localSelf)
      Panda.LuaAsyncBridge.PlayerRemoveClientBuffLua(881649)
    end
  }
end

return Scene
