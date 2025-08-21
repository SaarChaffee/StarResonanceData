local super = require("ui.service.service_base")
local TeamService = class("TeamService", super)

function TeamService:OnInit()
end

function TeamService:OnUnInit()
end

function TeamService:switchFunctionState(functionId, isOpen)
  if functionId == E.FunctionID.TeamVoice then
    local teamVM = Z.VMMgr.GetVM("team")
    if teamVM.CheckIsInTeam() and not isOpen then
      teamVM.CloseTeamVoice()
    end
  elseif functionId == E.FunctionID.TeamVoiceMic then
    local teamVM = Z.VMMgr.GetVM("team")
    if teamVM.CheckIsInTeam() then
      local funcVm = Z.VMMgr.GetVM("gotofunc")
      if not funcVm.CheckFuncCanUse(E.FunctionID.TeamVoice, true) then
        teamVM.CloseTeamVoice()
      else
        teamVM.OpenTeamSpeaker()
      end
    end
  end
end

function TeamService:OnLogin()
  Z.EventMgr:Add(Z.ConstValue.RefreshFunctionIcon, self.switchFunctionState, self)
end

function TeamService:OnLeaveScene()
  local teamTipsVm = Z.VMMgr.GetVM("team_tips")
  teamTipsVm.CloseTeamTipsView()
end

function TeamService:OnLogout()
  local teamVM = Z.VMMgr.GetVM("team")
  teamVM.QuiteTeamVoice()
  Z.EventMgr:Remove(Z.ConstValue.RefreshFunctionIcon, self.switchFunctionState, self)
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
