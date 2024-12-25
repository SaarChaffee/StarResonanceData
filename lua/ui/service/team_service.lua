local super = require("ui.service.service_base")
local TeamService = class("TeamService", super)

function TeamService:OnInit()
end

function TeamService:OnUnInit()
end

function TeamService:OnLogin()
end

function TeamService:OnLeaveScene()
  local teamTipsVm = Z.VMMgr.GetVM("team_tips")
  teamTipsVm.CloseTeamTipsView()
end

function TeamService:OnLogout()
  local teamVM = Z.VMMgr.GetVM("team")
  teamVM.QuiteTeamVoice()
end

function TeamService:OnEnterScene(sceneId)
  local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  local subType = sceneTable.SceneSubType
  if subType ~= E.SceneSubType.Login and subType ~= E.SceneSubType.Select then
    Z.CoroUtil.create_coro_xpcall(function()
      local teamVM = Z.VMMgr.GetVM("team")
      local teamData = Z.DataMgr.Get("team_data")
      teamVM.AsyncGetTeamInfo(teamData.CancelSource:CreateToken())
    end)()
  end
end

return TeamService
