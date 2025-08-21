local worldProxy = require("zproxy.world_proxy")
local asyncReqSceneLineInfo = function()
  local sceneLineData = Z.DataMgr.Get("sceneline_data")
  sceneLineData.LastRequestTime = os.time()
  local request = {}
  local ret = worldProxy.ReqSceneLineInfo(request, sceneLineData.CancelSource:CreateToken())
  if ret.errCode == 0 then
    sceneLineData:SetLineDataList(ret.lineInfos)
  else
    Z.TipsVM.ShowTips(ret.errCode)
  end
  local teamData = Z.DataMgr.Get("team_data")
  if teamData.TeamInfo then
    local sceneId = Z.StageMgr.GetCurrentSceneId()
    local dict = {}
    for _, value in pairs(teamData.TeamInfo.members) do
      if value.socialData.basicData.charID ~= Z.ContainerMgr.CharSerialize.charBase.charId and value.socialData.basicData.sceneId == sceneId then
        if dict[value.socialData.basicData.sceneGuid] == nil then
          dict[value.socialData.basicData.sceneGuid] = {}
        end
        table.insert(dict[value.socialData.basicData.sceneGuid], value.socialData)
      end
    end
    sceneLineData.SocialDataBySceneGuidDict = dict
  end
  Z.EventMgr:Dispatch(Z.ConstValue.SceneLine.RequestSceneLineInfoBack)
end
local closeSceneLineView = function()
  Z.UIMgr:CloseView("main_line_window")
end
local openSceneLineView = function()
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  if sceneRow == nil then
    return
  end
  local isSceneLineFuncOpen = Z.VMMgr.GetVM("switch").CheckFuncSwitch(E.FunctionID.SceneLine)
  local sceneSupportLine = Z.VMMgr.GetVM("scene").IsStaticScene(sceneId)
  if isSceneLineFuncOpen and sceneSupportLine then
    Z.UIMgr:OpenView("main_line_window")
  end
end
local asyncReqSwitchSceneLineByLineId = function(lineId)
  local sceneLineData = Z.DataMgr.Get("sceneline_data")
  local request = {}
  request.lineId = lineId
  local errCode = worldProxy.ReqSwitchSceneLine(request, sceneLineData.CancelSource:CreateToken())
  if errCode == 0 then
    closeSceneLineView()
    Z.TipsVM.ShowTips(1000742)
    return true
  else
    Z.TipsVM.ShowTips(errCode)
    return false
  end
end
local asyncReqSwitchSceneLineByCharId = function(charId)
  local sceneLineData = Z.DataMgr.Get("sceneline_data")
  local request = {}
  request.targetCharId = charId
  local errCode = worldProxy.ReqSwitchSceneLine(request, sceneLineData.CancelSource:CreateToken())
  if errCode == 0 then
    closeSceneLineView()
    Z.TipsVM.ShowTips(1000742)
    return true
  else
    Z.TipsVM.ShowTips(errCode)
    return false
  end
end
local ret = {
  AsyncReqSceneLineInfo = asyncReqSceneLineInfo,
  CloseSceneLineView = closeSceneLineView,
  OpenSceneLineView = openSceneLineView,
  AsyncReqSwitchSceneLineByLineId = asyncReqSwitchSceneLineByLineId,
  AsyncReqSwitchSceneLineByCharId = asyncReqSwitchSceneLineByCharId
}
return ret
