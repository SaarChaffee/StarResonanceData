local worldProxy = require("zproxy.world_proxy")
local setGoalFinish = function(goalType, ...)
  local arg = {
    ...
  }
  Z.CoroUtil.create_coro_xpcall(function()
    logGreen("[goal] SetGoalFinish: " .. goalType)
    worldProxy.SetTargetFinish(goalType, arg)
  end)()
end
local ret = {SetGoalFinish = setGoalFinish}
return ret
