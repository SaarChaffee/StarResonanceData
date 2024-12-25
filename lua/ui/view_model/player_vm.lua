local worldProxy = require("zproxy.world_proxy")
local PlayerVM = {}

function PlayerVM:AsyncSetCharName(name, cancelToken)
  worldProxy.ChangeName(name, cancelToken)
end

function PlayerVM:IsNamed()
  local mask = 1 << Z.PbEnum("EUserState", "ENameState")
  local isNamed = Z.ContainerMgr.CharSerialize.charBase.CharState & mask > 0
  return isNamed
end

function PlayerVM:OpenNameWindow()
  local isNamed = self:IsNamed()
  if not isNamed then
    Z.UIMgr:OpenView("name_window")
  else
    Z.EPFlowBridge.OnLuaFunctionCallback("OPEN_NAME_WINDOW")
  end
end

function PlayerVM:CloseNameWindow()
  Z.UIMgr:CloseView("name_window")
end

function PlayerVM:OpenUnstuckTip()
  if not self:CheckUnstuckCD() then
    Z.TipsVM.ShowTipsLang(100006)
    return
  end
  local configCD = Z.Global.UnstuckCD
  local param = {
    val = math.ceil(configCD / 60)
  }
  local labDesc
  if Z.StageMgr.IsInNewbieScene() then
    labDesc = Lang("UnstuckTipSpecial", param)
  else
    labDesc = Lang("UnstuckTipNormal", param)
  end
  Z.DialogViewDataMgr:OpenNormalDialog(labDesc, function(cancelToken)
    self:AsyncSendUnstuck(cancelToken)
    Z.DialogViewDataMgr:CloseDialogView()
    local settingVM = Z.VMMgr.GetVM("setting")
    settingVM.CloseSettingView()
    local mainUIFuncsListVM = Z.VMMgr.GetVM("mainui_funcs_list")
    mainUIFuncsListVM.CloseView()
  end)
end

function PlayerVM:AsyncSendUnstuck(cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.UnStuck(cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  else
    local playerData = Z.DataMgr.Get("player_data")
    playerData.LastUnstuckTime = Z.ServerTime:GetServerTime()
  end
end

function PlayerVM:CheckUnstuckCD()
  local configCD = Z.Global.UnstuckCD * 1000
  local playerData = Z.DataMgr.Get("player_data")
  local lastSendTime = playerData.LastUnstuckTime
  if lastSendTime and configCD > Z.ServerTime:GetServerTime() - lastSendTime then
    return false
  else
    return true
  end
end

function PlayerVM:OpenRenameWindow()
  Z.UIMgr:OpenView("rename_window")
end

function PlayerVM:CloseRenameWindow()
  Z.UIMgr:CloseView("rename_window")
end

function PlayerVM:AsyncChangeShowId(showId)
  worldProxy.ChangeShowId(showId)
end

return PlayerVM
