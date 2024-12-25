local getFuncParam = function(funcSwitchInfo)
  local funcName_
  local param_ = {}
  for index, val in ipairs(funcSwitchInfo.FunctionOrder) do
    if index == 1 then
      funcName_ = val
    else
      table.insert(param_, val)
    end
  end
  return funcName_, param_
end
local func = function(funcName, param)
  if not param then
    return false
  end
  local vmName_ = param[1]
  if not vmName_ then
    return false
  end
  local vm_ = Z.VMMgr.GetVM(vmName_)
  if not vm_ then
    return false
  end
  local vmFunc_ = vm_[funcName]
  if not vmFunc_ then
    return false
  end
  if #param < 2 then
    vmFunc_()
  elseif param[2] == "self" then
    vmFunc_(vm_, table.unpack(param, 3))
  else
    vmFunc_(table.unpack(param, 2))
  end
  return true
end
local openUI = function(funcName, param)
  if not param then
    return false
  end
  if not param[1] then
    return false
  end
  Z.UIMgr:OpenView(param[1])
  return true
end
local funcIsOn = function(id, bIgnoreTip)
  local isOpen, reasons = Z.VMMgr.GetVM("switch").CheckFuncSwitch(id)
  if not isOpen then
    if not bIgnoreTip then
      if reasons and reasons[1] then
        Z.TipsVM.OpenViewById(reasons[1].error, reasons[1].params)
      else
        Z.TipsVM.ShowTipsLang(100102)
      end
    end
    return false
  end
  return true
end
local checkSceneAllowance = function(funcId)
  local mainUiVm = Z.VMMgr.GetVM("mainui")
  local disableFuncs = mainUiVm.GetUnclickableFuncsInScene()
  if disableFuncs[funcId] then
    return false
  end
  return true
end
local checkBuffAllowance = function(funcId)
  local buffVM = Z.VMMgr.GetVM("buff")
  local isBan, buffId = buffVM.IsBanFunc(funcId)
  if isBan then
    return false
  end
  return true
end
local checkFuncCanUse = function(funcId, bIgnoreTip)
  local isOpen = funcIsOn(funcId, bIgnoreTip)
  if not isOpen then
    return false
  end
  local isSceneAllowed = checkSceneAllowance(funcId)
  if not isSceneAllowed then
    if not bIgnoreTip then
      Z.TipsVM.ShowTipsLang(100124)
    end
    return false
  end
  local isBuffAllowed = checkBuffAllowance(funcId)
  if not isBuffAllowed then
    if not bIgnoreTip then
      Z.TipsVM.ShowTipsLang(100123)
    end
    return false
  end
  local deadVM = Z.VMMgr.GetVM("dead")
  if funcId ~= E.FunctionID.MainChat and deadVM.CheckPlayerIsDead() then
    if not bIgnoreTip then
      Z.TipsVM.ShowTipsLang(100126)
    end
    return false
  end
  return true
end
local goToFunc = function(id, ...)
  if not checkFuncCanUse(id, false) then
    return false
  end
  local funcSwitchInfo_ = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(id)
  if funcSwitchInfo_ == nil then
    return false
  end
  local funcName_, param_ = getFuncParam(funcSwitchInfo_)
  for _, v in ipairs({
    ...
  }) do
    table.insert(param_, v)
  end
  if not funcName_ then
    logError("not funcName_")
    return false
  end
  if funcName_ == "OpenUI" then
    return openUI(funcName_, param_)
  else
    return func(funcName_, param_)
  end
  return true
end
local ret = {
  GoToFunc = goToFunc,
  FuncIsOn = funcIsOn,
  CheckFuncCanUse = checkFuncCanUse
}
return ret
