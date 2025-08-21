local PathFindingVM = {}

function PathFindingVM:StartPathFinding()
  local goalGuideData = Z.DataMgr.Get("goal_guide_data")
  local goalPosInfo = goalGuideData:GetLastGuideData()
  if goalPosInfo then
    if goalPosInfo.Source == E.GoalGuideSource.CustomMapFlag then
      Z.TipsVM.ShowTips(102901)
    else
      self:StartPathFindingByGoalPosInfo(goalPosInfo)
    end
  else
    local questGoalGuideVM = Z.VMMgr.GetVM("quest_goal_guide")
    if not questGoalGuideVM.CheckCantPathFindingQuest() then
      Z.TipsVM.ShowTips(102902)
    end
  end
end

function PathFindingVM:StartPathFindingByFlagData(sceneId, flagData)
  if not self:CheckCanPathFinding() then
    return
  end
  local mapVM = Z.VMMgr.GetVM("map")
  local pos = flagData.Pos or Vector3.New(0, 0, 0)
  local posType = mapVM.GetPosTypeByFlagData(flagData)
  local uid = posType == Z.GoalPosType.Collection and flagData.Id or flagData.Uid
  Z.ZPathFindingMgr:SetPathFindingTarget(posType, sceneId, uid, pos)
  if Z.EntityMgr.PlayerEnt and not Z.EntityMgr.PlayerEnt.IsRiding then
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.VehicleRide)
  else
    Z.ZPathFindingMgr:StartPathFinding()
  end
end

function PathFindingVM:StartPathFindingByGoalPosInfo(goalPosInfo)
  if not self:CheckCanPathFinding() then
    return
  end
  local uid = goalPosInfo.PosType == Z.GoalPosType.Collection and goalPosInfo.ExtraUuid or goalPosInfo.Uid
  Z.ZPathFindingMgr:SetPathFindingTarget(goalPosInfo.PosType, goalPosInfo.SceneId, uid, goalPosInfo.Pos)
  if Z.EntityMgr.PlayerEnt and not Z.EntityMgr.PlayerEnt.IsRiding then
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.VehicleRide)
  else
    Z.ZPathFindingMgr:StartPathFinding()
  end
end

function PathFindingVM:CheckState()
  return Z.ZPathFindingMgr:LuaCheckEnable() == 0
end

function PathFindingVM:CheckCanPathFinding()
  if self:CheckState() then
    return true
  end
  local visualLayerId = 0
  if Z.EntityMgr.PlayerEnt then
    visualLayerId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
  end
  if 0 < visualLayerId then
    Z.TipsVM.ShowTips(102918)
    return false
  end
  if Z.EntityMgr.PlayerEnt and Z.EntityMgr.PlayerEnt.IsRiding and not Z.EntityMgr.PlayerEnt.IsPlayerControlVehicle then
    Z.TipsVM.ShowTips(102919)
    return false
  end
  local vehicleVM = Z.VMMgr.GetVM("vehicle")
  local vehicleDefine = require("ui.model.vehicle_define")
  local curId = vehicleVM.IsTypeEquip(vehicleDefine.VehicleUseType.land)
  if 0 < curId then
    local config = Z.TableMgr.GetRow("VehicleBaseTableMgr", curId)
    if config == nil then
      return false
    end
    if config.IsPathfinding then
      return true
    else
      self:ShowPathFindingVehiclePopup()
      return false
    end
  else
    self:ShowPathFindingVehiclePopup()
    return false
  end
end

function PathFindingVM:ShowPathFindingVehiclePopup()
  local content = Lang("CantPathFindingByVehicleDesc")
  local confirmLabel = Lang("Goto")
  local dialogViewData = {
    dlgType = E.DlgType.YesNo,
    labDesc = content,
    onConfirm = function()
      local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
      gotoFuncVM.GoToFunc(E.FunctionID.Vehicle)
    end,
    labYes = confirmLabel
  }
  Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
end

return PathFindingVM
