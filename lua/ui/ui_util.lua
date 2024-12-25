local unityEventAddCoroFunc = function(unityEvent, func, onErr, onCancel)
  unityEvent:AddListener(Z.CoroUtil.create_coro_xpcall(func, function(err)
    if err == Z.CancelException then
      if onCancel then
        onCancel()
      end
      return
    end
    if onErr then
      onErr(err)
    end
  end))
end
return {UnityEventAddCoroFunc = unityEventAddCoroFunc}
