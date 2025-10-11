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

function HouseRed.CheckInviteRed()
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  if not funcVm.CheckFuncCanUse(E.FunctionID.House, true) then
    return
  end
  local houseData = Z.DataMgr.Get("house_data")
  local houseVM = Z.VMMgr.GetVM("house")
  Z.CoroUtil.create_coro_xpcall(function()
    local redNum = 0
    local ret = houseVM.AsyncGetPersonData(houseData.CancelSource:CreateToken())
    if ret then
      redNum = #ret.items
    end
    Z.RedPointMgr.UpdateNodeCount(E.RedType.HouseInviteRed, redNum)
  end)()
end

function HouseRed.Init()
  HouseRed.CheckLevelUpRed()
  HouseRed.CheckInviteRed()
  Z.EventMgr:Add(Z.ConstValue.House.HouseLevelChange, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Add(Z.ConstValue.House.HouseCleaninessChange, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Add(Z.ConstValue.House.HouseExpChange, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Add(Z.ConstValue.Home.BaseInfoUpdate, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Add(Z.ConstValue.Home.CohabitationInfoUpdate, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Add(Z.ConstValue.House.RefreshApplyList, HouseRed.CheckInviteRed)
end

function HouseRed.UnInit()
  Z.EventMgr:Remove(Z.ConstValue.House.HouseLevelChange, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Remove(Z.ConstValue.House.HouseCleaninessChange, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Remove(Z.ConstValue.House.HouseExpChange, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Remove(Z.ConstValue.Home.BaseInfoUpdate, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Remove(Z.ConstValue.Home.CohabitationInfoUpdate, HouseRed.CheckLevelUpRed)
  Z.EventMgr:Remove(Z.ConstValue.House.RefreshApplyList, HouseRed.CheckInviteRed)
end

return HouseRed
