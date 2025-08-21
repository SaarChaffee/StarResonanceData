local EventDispatcher = class("EventDispatcher")
local invokeEvtFunc = function(func, object, ...)
  if object then
    func(object, ...)
  else
    func(...)
  end
end
local errorHandler = function(err)
  logError("[Event] Error in invokeEvtFunc: " .. tostring(err))
end

function EventDispatcher:ctor(invokeFunc, isCoroutine)
  self.eventTable_ = {}
  if invokeFunc == nil then
    function invokeFunc(func, object, ...)
      local success, result = xpcall(invokeEvtFunc, errorHandler, func, object, ...)
    end
  end
  if isCoroutine then
    invokeFunc = Z.CoroUtil.create_coro_xpcall(invokeFunc)
  end
  self.invokeFunc = invokeFunc
end

function EventDispatcher:Add(evtName, func, object)
  if not evtName then
    logError("[EventDispatcher:Add]evtName is invalid:{0}", evtName)
    return
  end
  object = object or "_EDOBJ"
  if not self.eventTable_[evtName] then
    self.eventTable_[evtName] = {}
  end
  local eventDatas = self.eventTable_[evtName]
  if not eventDatas[object] then
    eventDatas[object] = {}
  end
  eventDatas[object][func] = true
end

function EventDispatcher:Dispatch(evtName, ...)
  if not self:exist(evtName) then
    return
  end
  local eventDatas = self.eventTable_[evtName]
  for object, objectFuncs in pairs(eventDatas) do
    if object == "_EDOBJ" then
      object = nil
    end
    for func, userData in pairs(objectFuncs) do
      self.invokeFunc(func, object, ...)
    end
  end
end

function EventDispatcher:exist(evtName)
  local eventDatas = self.eventTable_[evtName]
  if not eventDatas then
    return false
  end
  local ret = false
  for _, funcs in pairs(eventDatas) do
    if table.zsize(funcs) > 0 then
      ret = true
      break
    end
  end
  return ret
end

function EventDispatcher:Remove(evtName, func, object)
  local eventDatas = self.eventTable_[evtName]
  if not eventDatas then
    return
  end
  object = object or "_EDOBJ"
  if eventDatas[object] and func then
    eventDatas[object][func] = nil
  end
end

function EventDispatcher:RemoveObjAllByEvent(evtName, object)
  local eventDatas = self.eventTable_[evtName]
  if eventDatas and eventDatas[object] then
    eventDatas[object] = nil
  end
end

function EventDispatcher:RemoveObjAll(object)
  for _, v in pairs(self.eventTable_) do
    if v[object] then
      v[object] = nil
    end
  end
end

return EventDispatcher
