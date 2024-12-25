local unpack = unpack or table.unpack
local main_coro, _ = coroutine.running()
local default_err_handler = function(err)
  if err == ZUtil.ZCancelSource.CancelException then
    return
  end
  logError(err)
end
local async_to_sync = function(async_func, param_cnt)
  return function(...)
    local l_co, _ = coroutine.running()
    if l_co == main_coro then
      error("this function must be run in coroutine")
    end
    local l_rets, l_err
    local l_waiting = false
    local cb_func = function(...)
      if l_waiting then
        coroutine.resume(l_co, ...)
      else
        l_rets = {
          ...
        }
      end
    end
    local err_func = function(err)
      l_err = err
      if l_waiting then
        coroutine.resume(l_co)
      end
    end
    local params = {
      ...
    }
    local param_cnt = param_cnt or #params
    table.insert(params, param_cnt + 1, cb_func)
    table.insert(params, param_cnt + 2, err_func)
    async_func(unpack(params))
    if l_rets == nil and l_err == nil then
      l_waiting = true
      l_rets = {
        coroutine.yield()
      }
    end
    if l_err then
      error(l_err)
    end
    return unpack(l_rets)
  end
end
local create_coro_call = function(func)
  return function(...)
    local co = coroutine.create(func)
    assert(coroutine.resume(co, ...))
  end
end
local create_coro_xpcall = function(func, errFunc)
  if errFunc == nil then
    errFunc = default_err_handler
  end
  return function(...)
    local pf = function(...)
      xpcall(func, errFunc, ...)
    end
    local co = coroutine.create(pf)
    assert(coroutine.resume(co, ...))
  end
end
local coro_call = function(func, ...)
  local cur_co, _ = coroutine.running()
  if cur_co ~= main_coro then
    error("cannot create create coroutine in main coroutine")
  end
  create_coro_call(func)(...)
end
local coro_xpcall = function(func, errHandler, ...)
  local cur_co, _ = coroutine.running()
  if cur_co ~= main_coro then
    error("cannot create create coroutine in main coroutine")
  end
  create_coro_xpcall(func, errHandler)(...)
end
return {
  async_to_sync = async_to_sync,
  create_coro_call = create_coro_call,
  create_coro_xpcall = create_coro_xpcall,
  coro_call = coro_call,
  coro_xpcall = coro_xpcall
}
