local ServiceBase = class("ServiceBase")

function ServiceBase:OnInit()
end

function ServiceBase:OnLateInit()
end

function ServiceBase:OnUnInit()
end

function ServiceBase:OnLogin()
end

function ServiceBase:OnLogout()
end

function ServiceBase:OnNotifyEnterWorld(sceneId)
end

function ServiceBase:OnEnterScene(sceneId)
end

function ServiceBase:OnLeaveScene()
end

function ServiceBase:OnReconnect()
end

function ServiceBase:OnEnterStage(stage, toSceneId, dungeonId)
end

function ServiceBase:OnSyncAllContainerData()
end

function ServiceBase:OnVisualLayerChange()
end

function ServiceBase:OnResurrectionEnd()
end

return ServiceBase
