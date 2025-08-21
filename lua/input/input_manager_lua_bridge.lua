local InputManagerLuaBridge = class("InputManagerLuaBridge")

function InputManagerLuaBridge:ctor()
end

function InputManagerLuaBridge:AddInputEventDelegateWithActionId(callback, inputActionEventType, actionId, ...)
  if not callback then
    logError("Callback is nil!")
    return
  end
  if actionId == nil then
    logError("actionId cannot be nil!,Use AddInputEventDelegateWithoutActionId")
    return
  end
  local params = {
    ...
  }
  if #params == 0 then
    Z.InputMgr:AddInputEventDelegate(callback, inputActionEventType, actionId)
  elseif #params == 1 then
    Z.InputMgr:AddInputEventDelegate(callback, inputActionEventType, actionId, params[1])
  elseif #params == 2 then
    Z.InputMgr:AddInputEventDelegate(callback, inputActionEventType, actionId, params[1], params[2])
  else
    logError("Too many parameters!")
  end
end

function InputManagerLuaBridge:AddInputEventDelegateWithoutActionId(callback, inputActionEventType)
  if not callback then
    logError("Callback is nil!")
    return
  end
  Z.InputMgr:AddInputEventDelegate(callback, inputActionEventType)
end

function InputManagerLuaBridge:RemoveInputEventDelegateWithActionId(callback, inputActionEventType, actionId)
  if not callback then
    logError("Callback is nil!")
    return
  end
  if actionId == nil then
    logError("actionId cannot be nil!,Use RemoveInputEventDelegateWithoutActionId")
    return
  end
  Z.InputMgr:RemoveInputEventDelegate(callback, inputActionEventType, actionId)
end

function InputManagerLuaBridge:RemoveInputEventDelegateWithoutActionId(callback, inputActionEventType)
  if not callback then
    logError("Callback is nil!")
    return
  end
  Z.InputMgr:RemoveInputEventDelegate(callback, inputActionEventType)
end

return InputManagerLuaBridge
