local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {}

function Scene:InitEvents()
  self.EventItems = {}
  self.EventItems[542] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 542,
    count = 1,
    selectedStr = "xmll",
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("6001_xingmailuanliu1", 0, 0, 5, false, 0)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("6001_xingmailuanliu2", 0, 0, 5, false, 0)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("6001_xingmailuanliu3", 0, 0, 5, false, 0)
      Panda.ZEffect.ZPathEffectMgr.Instance:PlayEffect("6001_xingmailuanliu4", 0, 0, 5, false, 0)
      do
        local entityData = {actorType = 5, tableUid = 1258}
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
    end
  }
  self.EventItems[544] = {
    eventType = E.LevelEventType.OnOptionSelect,
    enable = true,
    group = 0,
    eventId = 544,
    count = 1,
    selectedStr = "calm",
    action = function(localSelf)
      if localSelf.count == 0 then
        return
      else
        localSelf.count = localSelf.count - 1
      end
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("6001_xingmailuanliu1")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("6001_xingmailuanliu2")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("6001_xingmailuanliu3")
      Panda.ZEffect.ZPathEffectMgr.Instance:StopEffect("6001_xingmailuanliu4")
    end
  }
  self.EventItems[549] = {
    eventType = E.LevelEventType.OnSceneLeave,
    enable = true,
    group = 0,
    eventId = 549,
    count = -1,
    action = function(localSelf)
      Panda.ZGame.CameraManager.Instance:CameraInvoke(0, true, {2032}, false)
      Panda.ZGame.CameraManager.Instance:SwitchCameraTemplate({0}, {2030}, -1)
    end
  }
end

return Scene
