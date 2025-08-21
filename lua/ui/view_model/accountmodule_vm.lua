local logout = function()
  Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameImportant, E.ESysDialogGameImportantOrder.Important, nil, Lang("DescLogOut"), function()
    local loginVM = Z.VMMgr.GetVM("login")
    Z.UIMgr:CloseView("mark_main")
    Z.VMMgr.GetVM("setting").CloseSettingView()
    Z.CoroUtil.create_coro_xpcall(function()
      loginVM:AsyncExitGame()
    end)()
    Z.Delay(0.1, ZUtil.ZCancelSource.NeverCancelToken)
    loginVM:Logout()
  end, nil, true)
end
local ret = {Logout = logout}
return ret
