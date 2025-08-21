local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {2}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[1314] = {
    eventType = E.LevelEventType.OnCutsceneEnd,
    enable = true,
    cutsceneId = 1007,
    group = 0,
    eventId = 1314,
    count = 4,
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnTriggerEvent, {1015})
    end
  }
end

return Scene
