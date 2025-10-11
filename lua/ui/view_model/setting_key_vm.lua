local rewiredElementIdentifiers = require("utility/rewired_element_identifiers")
local inputKeyboardLayoutIds = require("input.keyboard_layout_ids")
local getKeyboardName = function()
  local keyboardLayoutId = Z.InputMgr.InputDeviceService.KeyboardLayoutId
  return inputKeyboardLayoutIds.GetKeyboardLayoutById(keyboardLayoutId)
end
local getShowKeyList = function()
  local rowList = {}
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  if keyTbl == nil then
    return rowList
  end
  for _, row in pairs(keyTbl.GetDatas()) do
    if row.HideInSettingView == 0 then
      table.insert(rowList, row)
    end
  end
  table.sort(rowList, function(left, right)
    if left.Sort ~= right.Sort then
      return left.Sort < right.Sort
    end
    return left.Id < right.Id
  end)
  return rowList
end
local getDirectionByAxis = function(axisType, direction)
  if axisType == Panda.ZInput.Vector2Axis.YAxis then
    if direction == Panda.ZInput.InputDirection.Positive then
      return E.InputDirectionType.Front
    else
      return E.InputDirectionType.Back
    end
  elseif axisType == Panda.ZInput.Vector2Axis.XAxis then
    if direction == Panda.ZInput.InputDirection.Positive then
      return E.InputDirectionType.Right
    else
      return E.InputDirectionType.Left
    end
  end
  return E.InputDirectionType.None
end
local getShowKeyCtxByKeyRow = function(setKeyboardTableRow)
  local schemeId = setKeyboardTableRow.SchemeId
  local result = {}
  for k, actionId in pairs(setKeyboardTableRow.ActionIds) do
    local inputBindingList = Z.InputMgr:GetInputBindingList(schemeId, actionId[1])
    for i = 0, inputBindingList.Count - 1 do
      local v = inputBindingList[i]
      local inputDirection = getDirectionByAxis(v.AxisType, v.Direction)
      local settingKeyCtx
      for _, ctx in pairs(result) do
        if ctx.inputDirection == inputDirection then
          settingKeyCtx = ctx
        end
      end
      if settingKeyCtx == nil then
        settingKeyCtx = {}
        settingKeyCtx.setKeyboardTableRow = setKeyboardTableRow
        settingKeyCtx.inputDirection = getDirectionByAxis(v.AxisType, v.Direction)
        settingKeyCtx.keyBoardBindings = {}
        settingKeyCtx.gamePadBindings = {}
        table.insert(result, settingKeyCtx)
      end
      for j = 0, v.KeyBoardElements.Count - 1 do
        local element = v.KeyBoardElements[j]
        local elementCtx = {}
        elementCtx.elementId = element.ElementId
        elementCtx.modify = element.Modifier
        elementCtx.deviceType = element.DeviceType
        elementCtx.actionId = actionId[1]
        elementCtx.groupIndex = v.GroupIndex
        elementCtx.bindingIndex = element.BindingIndex
        table.insert(settingKeyCtx.keyBoardBindings, elementCtx)
      end
      for j = 0, v.GamePadElements.Count - 1 do
        local element = v.GamePadElements[j]
        local elementCtx = {}
        elementCtx.elementId = element.ElementId
        elementCtx.modify = element.Modifier
        elementCtx.deviceType = element.DeviceType
        elementCtx.actionId = actionId[1]
        elementCtx.groupIndex = v.GroupIndex
        elementCtx.bindingIndex = element.BindingIndex
        table.insert(settingKeyCtx.gamePadBindings, elementCtx)
      end
    end
  end
  return result
end
local getShowKeyCtxList = function()
  local settingKeyCtxTbl = {}
  local rowList = getShowKeyList()
  for k, v in pairs(rowList) do
    local settingKeyCtxs = getShowKeyCtxByKeyRow(v)
    for _, setting in pairs(settingKeyCtxs) do
      table.insert(settingKeyCtxTbl, setting)
    end
  end
  return settingKeyCtxTbl
end
local getKeyIdByActionId = function(actionId)
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  if keyTbl == nil then
    return nil
  end
  for _, row in pairs(keyTbl.GetDatas()) do
    if row.ActionIds ~= nil then
      for i = 1, #row.ActionIds do
        local id = row.ActionIds[i][1]
        if id == actionId then
          return row.Id
        end
      end
    end
  end
  return nil
end
local getMainKeyDescription = function(settingElementBindingCtx)
  if not settingElementBindingCtx then
    return ""
  end
  local keyboardName = getKeyboardName()
  local rowId = 0
  if settingElementBindingCtx.deviceType == Panda.ZInput.EInputDeviceType.Keyboard then
    rowId = settingElementBindingCtx.elementId
  elseif settingElementBindingCtx.deviceType == Panda.ZInput.EInputDeviceType.Mouse then
    rowId = rewiredElementIdentifiers.GetMouseKeyIdByElementId(settingElementBindingCtx.elementId)
  elseif settingElementBindingCtx.deviceType == Panda.ZInput.EInputDeviceType.Joystick then
    rowId = rewiredElementIdentifiers.GetGamePadKeyIdByElementId(settingElementBindingCtx.elementId, Z.InputMgr.GamepadType)
  else
    return ""
  end
  local contrastRow = Z.TableMgr.GetTable("SetKeyboardContrastTableMgr").GetRow(rowId)
  if contrastRow then
    if contrastRow.ShowType == 1 then
      return string.zconcat("<sprite name=\"", contrastRow[keyboardName], "\">")
    else
      return contrastRow[keyboardName]
    end
  end
end
local getModifierKeyDescription = function(settingElementBindingCtx)
  if not settingElementBindingCtx then
    return nil
  end
  local keyboardName = getKeyboardName()
  local keyId = 0
  if settingElementBindingCtx.deviceType == Panda.ZInput.EInputDeviceType.Keyboard or settingElementBindingCtx.deviceType == Panda.ZInput.EInputDeviceType.Mouse then
    keyId = rewiredElementIdentifiers.GetMouseModifierKeyId(settingElementBindingCtx.modify)
  elseif settingElementBindingCtx.deviceType == Panda.ZInput.EInputDeviceType.Joystick then
    local modifierId = rewiredElementIdentifiers.GetGamePadModifierKeyId(settingElementBindingCtx.modify)
    keyId = rewiredElementIdentifiers.GetGamePadKeyIdByElementId(modifierId, Z.InputMgr.GamepadType)
  else
    return nil
  end
  if keyId == nil or keyId == 0 then
    return nil
  end
  local contrastRow = Z.TableMgr.GetTable("SetKeyboardContrastTableMgr").GetRow(keyId)
  if contrastRow then
    if contrastRow.ShowType == 1 then
      return string.zconcat("<sprite name=\"", contrastRow[keyboardName], "\">")
    else
      return contrastRow[keyboardName]
    end
  end
  return nil
end
local getKeyDes = function(settingElementBindingCtx)
  local ret = ""
  if settingElementBindingCtx == nil then
    return ret
  end
  local mainDesc = getMainKeyDescription(settingElementBindingCtx)
  local modifierDesc = getModifierKeyDescription(settingElementBindingCtx)
  if modifierDesc == nil then
    return mainDesc
  else
    return Lang("KeyElementDesc", {modifier = modifierDesc, mainDesc = mainDesc})
  end
end
local getKeyCodeDescListByKeyId = function(keyId)
  local ret = {}
  if keyId == nil then
    return ret
  end
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  if keyTbl == nil then
    return ret
  end
  local row = keyTbl.GetRow(keyId)
  if row == nil or row.ActionIds == nil then
    return ret
  end
  local curDeviceType = Z.InputMgr.InputDeviceType
  local settingKeyCtxs = getShowKeyCtxByKeyRow(row)
  for _, setting in pairs(settingKeyCtxs) do
    local bindings = curDeviceType == Panda.ZInput.EInputDeviceType.Joystick and setting.gamePadBindings or setting.keyBoardBindings
    for _, element in pairs(bindings) do
      local desc = getKeyDes(element)
      table.insert(ret, desc)
    end
  end
  return ret
end
local resetKeySetting = function()
  Z.InputMgr:ResetMapsAndSave()
end
local handleKeyConflict = function(conflictInfo)
  if not conflictInfo or conflictInfo.ConflictingInfos.Count == 0 then
    return
  end
  local excludedActionIds = {}
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  local conflictCount = conflictInfo.ConflictingInfos.Count
  for i = 0, conflictCount - 1 do
    local actionId = conflictInfo.ConflictingInfos[i].ActionId
    local keyId = getKeyIdByActionId(actionId)
    if not keyTbl or not keyId then
      logGreen(string.format("[Setting] Missing mapping in SetKeyboard table for actionId: %d", actionId))
      table.insert(excludedActionIds, actionId)
    else
      local row = keyTbl.GetRow(keyId)
      if not row then
        table.insert(excludedActionIds, actionId)
      end
      local isKeyboardAllowChange = row.CanChange[1] == nil or row.CanChange[1] == 1
      local isPadAllowChange = row.CanChange[2] == nil or row.CanChange[2] == 1
      local canChange
      if conflictInfo.DeviceType == Panda.ZInput.EInputDeviceType.Joystick then
        canChange = isPadAllowChange
      else
        canChange = isKeyboardAllowChange
      end
      if not canChange then
        table.insert(excludedActionIds, actionId)
      end
    end
  end
  if #excludedActionIds == conflictCount then
    Z.TipsVM.ShowTips(1000204)
    Z.InputMgr:HandelConflict(conflictInfo, false)
    return
  end
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("SettingKeyConfirmConflictSwitch"), function(CancelToken)
    Z.InputMgr:HandelConflict(conflictInfo, true)
  end, function(CancelToken)
    Z.InputMgr:HandelConflict(conflictInfo, false)
  end)
end
local isPresetKey = function(data)
  return false
end
local ret = {
  GetShowKeyList = getShowKeyList,
  GetShowKeyCtxList = getShowKeyCtxList,
  GetKeyDes = getKeyDes,
  ResetKeySetting = resetKeySetting,
  HandleKeyConflict = handleKeyConflict,
  GetKeyIdByActionId = getKeyIdByActionId,
  GetKeyCodeDescListByKeyId = getKeyCodeDescListByKeyId,
  IsPresetKey = isPresetKey
}
return ret
