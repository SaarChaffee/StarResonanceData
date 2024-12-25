local requestSceneLineList = function()
  Z.CoroUtil.create_coro_xpcall(function()
    local sceneLineData_ = Z.DataMgr.Get("sceneline_data")
    sceneLineData_:EnterRequestCD()
    local request = {}
    local worldProxy = require("zproxy.world_proxy")
    local ret = worldProxy.ReqSceneLineInfo(request, sceneLineData_.CancelSource:CreateToken())
    if ret.errCode == 0 then
      sceneLineData_:RefreshSceneLineList(ret.lineInfos)
    else
      Z.TipsVM.ShowTips(ret.errCode)
      sceneLineData_:SortScenelIneList()
    end
  end)()
end
local refreshSceneLineDataList = function()
  local sceneLineData_ = Z.DataMgr.Get("sceneline_data")
  if sceneLineData_:CheckCanRequst() then
    requestSceneLineList()
    Z.TipsVM.ShowTips(1000743)
  else
    Z.TipsVM.ShowTips(1000741, {
      val = sceneLineData_.cdRest
    })
  end
end
local closeSceneLineView = function()
  Z.UIMgr:CloseView("main_line_window")
end
local openSceneLineView = function()
  local sceneLineData_ = Z.DataMgr.Get("sceneline_data")
  if sceneLineData_.playerSceneLine then
    if sceneLineData_:CheckCanRequst() then
      requestSceneLineList()
    end
    Z.UIMgr:OpenView("main_line_window")
  else
    logError("\231\142\169\229\174\182\229\136\134\231\186\191\230\149\176\230\141\174\232\175\183\230\177\130\229\164\177\232\180\165\239\188\140\228\184\141\230\137\147\229\188\128\229\136\134\231\186\191\231\149\140\233\157\162")
  end
end
local enterSceneLine = function(selectLine)
  Z.CoroUtil.create_coro_xpcall(function()
    local sceneLineData_ = Z.DataMgr.Get("sceneline_data")
    local request = {}
    request.lineId = selectLine
    local worldProxy = require("zproxy.world_proxy")
    local ret = worldProxy.ReqSwitchSceneLine(request, sceneLineData_.CancelSource:CreateToken())
    if ret.errCode == 0 then
      closeSceneLineView()
      sceneLineData_:RefreshPlayerSceneLine()
      Z.TipsVM.ShowTips(1000742)
      sceneLineData_:LeaveRequestCD()
      return true
    else
      Z.TipsVM.ShowTips(ret.errCode)
      return false
    end
  end)()
end
local refreshPlayerSceneLine = function()
  local sceneLineData_ = Z.DataMgr.Get("sceneline_data")
  sceneLineData_:RefreshPlayerSceneLine()
end
local ret = {
  RefreshSceneLineDataList = refreshSceneLineDataList,
  CloseSceneLineView = closeSceneLineView,
  OpenSceneLineView = openSceneLineView,
  EnterSceneLine = enterSceneLine,
  RefreshPlayerSceneLine = refreshPlayerSceneLine
}
return ret
