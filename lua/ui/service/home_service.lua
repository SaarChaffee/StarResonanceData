local super = require("ui.service.service_base")
local HomeService = class("HomeService", super)

function HomeService:OnInit()
  Z.EventMgr:Add(Z.ConstValue.EnterHomeLand, self.EnterHomeLand, self)
end

function HomeService:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.EnterHomeLand, self.EnterHomeLand, self)
end

function HomeService:OnLogin()
end

function HomeService:OnLeaveScene()
end

function HomeService:OnLogout()
end

function HomeService:OnEnterScene(sceneId)
  local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  local subType = sceneTable.SceneSubType
  if subType ~= E.SceneSubType.Login and subType ~= E.SceneSubType.Select then
    local homeVm = Z.VMMgr.GetVM("home")
    homeVm.LoadHomeData()
    homeVm.SetAllAlignUserData()
  end
end

function HomeService:EnterHomeLand(homeLandId, isEnter)
  if not isEnter then
    homeLandId = -1
  end
  local homeData = Z.DataMgr.Get("home_data")
  homeData:SetHomeLoadId(homeLandId)
  local homeVm = Z.VMMgr.GetVM("home")
  homeVm.SetnCommunityInfo()
end

return HomeService
