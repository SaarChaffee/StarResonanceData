local ServiceMgr = {}
local servicesList = {}
local servicesDic = {}
local xpcall = xpcall
local ipairs = ipairs

function ServiceMgr.GetService(serviceName)
  return servicesDic[serviceName]
end

function ServiceMgr.RegisterAll()
  ServiceMgr.Register("friend")
  ServiceMgr.Register("team")
  ServiceMgr.Register("union")
  ServiceMgr.Register("mail")
  ServiceMgr.Register("mod")
  ServiceMgr.Register("gm")
  ServiceMgr.Register("investigate")
  ServiceMgr.Register("chat")
  ServiceMgr.Register("worldquest")
  ServiceMgr.Register("weapon")
  ServiceMgr.Register("insight")
  ServiceMgr.Register("pivot")
  ServiceMgr.Register("dungeon")
  ServiceMgr.Register("tips")
  ServiceMgr.Register("hover")
  ServiceMgr.Register("questionnaire")
  ServiceMgr.Register("env")
  ServiceMgr.Register("season")
  ServiceMgr.Register("item")
  ServiceMgr.Register("face")
  ServiceMgr.Register("home")
  ServiceMgr.Register("setting")
  ServiceMgr.Register("warehouse")
  ServiceMgr.Register("talent_skill")
  ServiceMgr.Register("trialroad")
  ServiceMgr.Register("boss_battle")
  ServiceMgr.Register("equip")
  ServiceMgr.Register("skill")
  ServiceMgr.Register("buff")
  ServiceMgr.Register("personalzone")
  ServiceMgr.Register("explore_monster")
  ServiceMgr.Register("cook")
  ServiceMgr.Register("shop")
  ServiceMgr.Register("quest")
  ServiceMgr.Register("red")
  ServiceMgr.Register("fishing")
  ServiceMgr.Register("world_boss")
  ServiceMgr.Register("timer")
  ServiceMgr.Register("weekly_hunt")
  ServiceMgr.Register("recommendedplay")
  ServiceMgr.Register("sevendaystarget")
end

function ServiceMgr.UnRegisterAll()
  servicesList = {}
  servicesDic = {}
end

function ServiceMgr.Register(serviceName)
  if servicesDic[serviceName] then
    logError("[ServiceMgr] register error, the service name is repeated : " .. serviceName)
    return
  end
  local serviceInfo = {
    name = serviceName,
    class = require(string.zconcat("ui.service.", serviceName, "_service")).new()
  }
  table.insert(servicesList, serviceInfo)
  servicesDic[serviceInfo.name] = serviceInfo.class
end

local errorHandle = function(msg)
  logError("[ServiceMgr] Error : " .. msg)
end

function ServiceMgr.Init()
  ServiceMgr.RegisterAll()
  for _, serviceInfo in ipairs(servicesList) do
    xpcall(serviceInfo.class.OnInit, errorHandle, serviceInfo.class)
  end
end

function ServiceMgr.LateInit()
  for _, serviceInfo in ipairs(servicesList) do
    xpcall(serviceInfo.class.OnLateInit, errorHandle, serviceInfo.class)
  end
end

function ServiceMgr.UnInit()
  for _, serviceInfo in ipairs(servicesList) do
    xpcall(serviceInfo.class.OnUnInit, errorHandle, serviceInfo.class)
  end
  ServiceMgr.UnRegisterAll()
end

function ServiceMgr.OnLogin()
  for _, serviceInfo in ipairs(servicesList) do
    xpcall(serviceInfo.class.OnLogin, errorHandle, serviceInfo.class)
  end
end

function ServiceMgr.OnLogout()
  for _, serviceInfo in ipairs(servicesList) do
    xpcall(serviceInfo.class.OnLogout, errorHandle, serviceInfo.class)
  end
end

function ServiceMgr.OnEnterScene(sceneId)
  for _, serviceInfo in ipairs(servicesList) do
    xpcall(serviceInfo.class.OnEnterScene, errorHandle, serviceInfo.class, sceneId)
  end
end

function ServiceMgr.OnLeaveScene()
  for _, serviceInfo in ipairs(servicesList) do
    xpcall(serviceInfo.class.OnLeaveScene, errorHandle, serviceInfo.class)
  end
end

function ServiceMgr.OnReconnect()
  for _, serviceInfo in ipairs(servicesList) do
    xpcall(serviceInfo.class.OnReconnect, errorHandle, serviceInfo.class)
  end
end

function ServiceMgr.OnEnterStage(stage, toSceneId, dungeonId)
  for _, serviceInfo in ipairs(servicesList) do
    xpcall(serviceInfo.class.OnEnterStage, errorHandle, serviceInfo.class, stage, toSceneId, dungeonId)
  end
end

function ServiceMgr.OnSyncAllContainerData()
  for _, serviceInfo in ipairs(servicesList) do
    xpcall(serviceInfo.class.OnSyncAllContainerData, errorHandle, serviceInfo.class)
  end
end

function ServiceMgr.OnVisualLayerChange()
  for _, serviceInfo in ipairs(servicesList) do
    xpcall(serviceInfo.class.OnVisualLayerChange, errorHandle, serviceInfo.class)
  end
end

return ServiceMgr
