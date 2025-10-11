local super = require("ui.service.service_base")
local HomeService = class("HomeService", super)

function HomeService:OnInit()
  Z.EventMgr:Add(Z.ConstValue.House.HouseLevelChange, self.OnHouseLevelChange, self)
  Z.EventMgr:Add(Z.ConstValue.EnterHomeLand, self.EnterHomeLand, self)
  self.houseRedClass = require("rednode.house_red")
end

function HomeService:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.EnterHomeLand, self.EnterHomeLand, self)
  Z.EventMgr:Remove(Z.ConstValue.House.HouseLevelChange, self.OnHouseLevelChange, self)
end

function HomeService:OnLogin()
  local houseData = Z.DataMgr.Get("house_data")
  houseData:InitCfgData()
  
  function self.onHomeContainerDataChange(container, dirty)
    if dirty.homelandId then
      local houseVm = Z.VMMgr.GetVM("house")
      houseVm.CloseAllHomeView()
      if container.homelandId ~= 0 then
        Z.RedPointMgr.UpdateNodeCount(E.RedType.HouseInviteRed, 0)
        Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FunctionOpen, "house_check_signature_popup")
        Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FunctionOpen, "house_get_popup")
      end
    end
  end
  
  Z.ContainerMgr.CharSerialize.communityHomeInfo.Watcher:RegWatcher(self.onHomeContainerDataChange)
end

function HomeService:OnLogout()
  Z.ContainerMgr.CharSerialize.communityHomeInfo.Watcher:UnregWatcher(self.onHomeContainerDataChange)
  self.onHomeContainerDataChange = nil
  self.houseRedClass.UnInit()
end

function HomeService:OnSyncAllContainerData()
  self:Init()
end

function HomeService:Init()
  self.houseRedClass.Init()
end

function HomeService:OnEnterScene(sceneId)
  local houseData = Z.DataMgr.Get("house_data")
  houseData.IsEntering = false
  local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  local subType = sceneTable.SceneSubType
  if subType ~= E.SceneSubType.Login and subType ~= E.SceneSubType.Select then
    if subType == E.SceneSubType.Community or subType == E.SceneSubType.Homeland then
      local homeVm = Z.VMMgr.GetVM("home_editor")
      homeVm.LoadHomeData()
      homeVm.SetAllAlignUserData()
      Z.CoroUtil.create_coro_xpcall(function()
        homeVm.AsyncHomelandFurnitureWarehouseData()
      end)()
    end
    local switchVM = Z.VMMgr.GetVM("switch")
    if switchVM.CheckFuncSwitch(E.FunctionID.House) then
      local houseVm = Z.VMMgr.GetVM("house")
      Z.CoroUtil.create_coro_xpcall(function()
        houseVm.AsyncGetHomeLandBaseInfo(houseData.CancelSource:CreateToken())
      end)()
    end
  end
end

function HomeService:OnLeaveScene()
end

function HomeService:EnterHomeLand(homeLandId, isEnter)
  logGreen("EnterHomeLand, homeLandId={0}, isEnter={1}", homeLandId, isEnter)
  if not isEnter then
    homeLandId = -1
  end
  local homeData = Z.DataMgr.Get("home_editor_data")
  homeData:SetHomeLandId(homeLandId)
  local homeVm = Z.VMMgr.GetVM("home_editor")
  homeVm.SetnCommunityInfo()
end

function HomeService:OnHouseLevelChange(newLevel)
  local houseData = Z.DataMgr.Get("house_data")
  if not houseData:IsHomeOwner() then
    return
  end
  local houseVm = Z.VMMgr.GetVM("house")
  houseVm.OpenHouseUpgradeView()
end

return HomeService
