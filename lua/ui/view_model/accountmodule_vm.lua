local logout = function()
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("DescLogOut"), function()
    local loginVM = Z.VMMgr.GetVM("login")
    Z.CoroUtil.create_coro_xpcall(function()
      Z.UIMgr:CloseView("mark_main")
      Z.VMMgr.GetVM("setting").CloseSettingView()
      loginVM:AsyncExitGame()
    end)()
    Z.CoroUtil.create_coro_xpcall(function()
      Z.Delay(0.1, ZUtil.ZCancelSource.NeverCancelToken)
      Z.DialogViewDataMgr:CloseDialogView()
      loginVM:Logout()
    end)()
  end)
end
local ret = {Logout = logout}
return ret
