local pb = require("pb2")
local GrpcCommunityNtfStubImpl = {}

function GrpcCommunityNtfStubImpl:OnCreateStub()
end

function GrpcCommunityNtfStubImpl:NotifyCommunityApplyUpdate(call, request)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityInfoUpdate(call, request)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityTransferInfoUpdate(call, request)
  local houseData = Z.DataMgr.Get("house_data")
  houseData:SetHomeTransferData(request.transferCommunity)
  Z.EventMgr:Dispatch(Z.ConstValue.Home.CohabitationInfoUpdate)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityNameChange(call, request)
  local houseData = Z.DataMgr.Get("house_data")
  houseData:SetHouseName(request.name)
  Z.EventMgr:Dispatch(Z.ConstValue.Home.BaseInfoUpdate)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityIntroductionChange(call, request)
  local houseData = Z.DataMgr.Get("house_data")
  houseData:SetHouseIntroduc(request.introduction)
  Z.EventMgr:Dispatch(Z.ConstValue.Home.BaseInfoUpdate)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityCheckInChange(call, request)
  local houseData = Z.DataMgr.Get("house_data")
  houseData:SetHouseCheckInContent(request.checkInContent)
  Z.EventMgr:Dispatch(Z.ConstValue.Home.BaseInfoUpdate)
end

function GrpcCommunityNtfStubImpl:NotifyHomelandBuildFurnitureOp(call, request)
  Z.EventMgr:Dispatch(Z.ConstValue.House.RefreshBuildList)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityCohabitantInfo(call, request)
  local houseData = Z.DataMgr.Get("house_data")
  houseData:SetHomeOwnerCharId(request.ownerCharId)
  houseData:UpdateHomeCohabitantInfo(request.cohabitant)
  houseData:RemoveHomeCohabitantInfo(request.removeCharId)
  Z.EventMgr:Dispatch(Z.ConstValue.Home.CohabitationInfoUpdate)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityTransferChange(call, request)
  local houseData = Z.DataMgr.Get("house_data")
  houseData:SetHomeTransferData(request.transferCommunity)
  Z.EventMgr:Dispatch(Z.ConstValue.Home.CohabitationInfoUpdate)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityItemUpdate(call, request)
  local homeData = Z.DataMgr.Get("home_editor_data")
  homeData:RemoveHomelandFurnitureWarehouseGrid(request.removeInstances)
  homeData:AddHomelandFurnitureWarehouseGrid(request.addInstances)
  homeData:UpdateHomelandFurnitureWarehouseGrid(request.updateInstances)
  Z.EventMgr:Dispatch(Z.ConstValue.Home.CommunityItemUpdate)
  Z.DIServiceMgr.HomeService:CommunityItemUpdate()
end

function GrpcCommunityNtfStubImpl:NotifyHomelandWarehouseGridChange(call, request)
  local warehouseVm = Z.VMMgr.GetVM("warehouse")
  for i, itemInfo in ipairs(request.itemInfos) do
    warehouseVm.UpdateWarehouseInfo(itemInfo, E.WarehouseType.House)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Warehouse.OnWarehouseItemChange)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityGlobalAuthorityChange(call, request)
  local houseData = Z.DataMgr.Get("house_data")
  houseData:SetAuthorityInfo(request.authorityInfo)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityLevelUpdate(call, request)
  local houseData = Z.DataMgr.Get("house_data")
  houseData:SetHouseLevel(request.newLevel)
  houseData:SetHouseExp(request.newExp)
  Z.EventMgr:Dispatch(Z.ConstValue.House.HouseExpChange, request.newExp)
  if request.newExp > request.oldExp then
    local itemData = {
      uuid = 0,
      configId = Z.GlobalHome.HomeExpItemId,
      count = request.newExp - request.oldExp
    }
    Z.ItemEventMgr.AddItemGetTipsData(itemData)
  end
end

function GrpcCommunityNtfStubImpl:NotifyCommunityCleanlinessUpdate(call, request)
  local houseData = Z.DataMgr.Get("house_data")
  houseData:SetHouseCleanValue(request.newCleanliness)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityHomeLandClutterInfoAdd(call, request)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityHomeLandClutterInfoRemove(call, request)
end

function GrpcCommunityNtfStubImpl:NotifyHomeLandPlayerTaskInfoUpdate(call, request)
  local houseData = Z.DataMgr.Get("house_data")
  houseData:SetHouseQuestInfo(request.newInfo)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityHomeLandSellShopUpdate(call, request)
  local houseData = Z.DataMgr.Get("house_data")
  houseData:SetHouseSellShopInfo(request.homeLandSellShopInfo)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityHomeLandDecorationInfo(call, request)
  local houseData = Z.DataMgr.Get("house_data")
  houseData:UpdateDecorationInfo(request.decorationInfo, request.isOuter)
  Z.EventMgr:Dispatch(Z.ConstValue.Home.DecorationInfoUpdate)
end

function GrpcCommunityNtfStubImpl:NotifyCommunityFurnitureItemUpdate(call, request)
  for key, value in pairs(request.addItems) do
    local itemData = {
      uuid = 0,
      configId = key,
      count = value
    }
    Z.ItemEventMgr.AddItemGetTipsData(itemData)
  end
end

function GrpcCommunityNtfStubImpl:NotifyCommunityApply(call, request)
  Z.RedPointMgr.UpdateNodeCount(E.RedType.HouseInviteRed, 1)
end

return GrpcCommunityNtfStubImpl
