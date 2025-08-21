local HouseRed = {}

function HouseRed.CheckLevelUpRed()
  local houseVM = Z.VMMgr.GetVM("house")
  local houseData = Z.DataMgr.Get("house_data")
  if houseVM.CheckHouseCanUpGrade() and houseData:IsHomeOwner() then
    Z.RedPointMgr.UpdateNodeCount(E.RedType.HouseLevelRed, 1)
  else
    Z.RedPointMgr.UpdateNodeCount(E.RedType.HouseLevelRed, 0)
  end
end

function HouseRed.Init()
  HouseRed.CheckLevelUpRed()
  Z.EventMgr:Add(Z.ConstValue.House.HouseLevelChange, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Add(Z.ConstValue.House.HouseCleaninessChange, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Add(Z.ConstValue.House.HouseExpChange, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Add(Z.ConstValue.Home.BaseInfoUpdate, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Add(Z.ConstValue.Home.CohabitationInfoUpdate, HouseRed.CheckLevelUpRed)
end

function HouseRed.UnInit()
  Z.EventMgr:Remove(Z.ConstValue.House.HouseLevelChange, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Remove(Z.ConstValue.House.HouseCleaninessChange, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Remove(Z.ConstValue.House.HouseExpChange, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Remove(Z.ConstValue.Home.BaseInfoUpdate, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Remove(Z.ConstValue.Home.CohabitationInfoUpdate, HouseRed.CheckLevelUpRed)
end

return HouseRed
