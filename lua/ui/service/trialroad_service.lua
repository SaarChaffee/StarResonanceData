local super = require("ui.service.service_base")
local TrialRoadService = class("TrialRoadService", super)
local trialRoadRed_ = require("rednode.trialroad_red")

function TrialRoadService:OnInit()
end

function TrialRoadService:OnUnInit()
end

function TrialRoadService:OnLogin()
end

function TrialRoadService:OnLogout()
end

function TrialRoadService:OnEnterScene(sceneId)
  local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  local subType = sceneTable.SceneSubType
  if subType ~= E.SceneSubType.Login and subType ~= E.SceneSubType.Select then
    self:InitRed()
  end
end

function TrialRoadService:InitRed()
  trialRoadRed_.InitTrialRoadGradeTargetItemRed()
  trialRoadRed_.InitTrialRoadRoomTargetItemRed()
end

return TrialRoadService
