local manager = Panda.ZGame.DI.DIScopeManager.Instance
local injectTag = {}
local Inject = function(services)
  for k, v in pairs(services) do
    if v == injectTag then
      services[k] = manager.LuaBridgeService[k]
      logGreen("inject " .. k)
      logGreen(services[k])
    end
  end
  return services
end
local Resolve = function(key)
  return manager.LuaBridgeService[key]
end
return {Inject = Inject, InjectTag = injectTag}
