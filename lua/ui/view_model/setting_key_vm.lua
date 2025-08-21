local rewiredElementIdentifiers = require("utility/rewired_element_identifiers")
local getShowKeyList = function()
  local rowList = {}
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  if keyTbl == nil then
    return rowList
  end
  for _, row in pairs(keyTbl.GetDatas()) do
    if row.ShowSwitch ~= 2 then
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
local getActionsByKeyId = function(keyId)
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  if keyTbl == nil then
    return nil
  end
  local row = keyTbl.GetRow(keyId)
  if row then
    if row.ActionIds == nil then
      return nil
    end
    local ret = {}
    for i = 1, #row.ActionIds do
      local actionId = row.ActionIds[i][1]
      local inputAction = Z.InputMgr:GetInputActionById(actionId)
      table.insert(ret, inputAction)
    end
    return ret
  end
  return nil
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
local getFirstElementMapWithActionId = function(actionId, mapId)
  local ret = Z.InputMgr:FirstElementMapWithActionId(actionId, mapId)
  return ret
end
local getKeyCodeByElementInfo = function(controllerType, keyCode, elementIdentifierId)
  if controllerType == Rewired.ControllerType.Keyboard then
    return keyCode:ToInt()
  elseif controllerType == Rewired.ControllerType.Mouse then
    return rewiredElementIdentifiers.GetMouseKeyIdByElementId(elementIdentifierId)
  end
  return nil
end
local getModifierKeysDescription = function(actionElementMap)
  local modifierKeys = {
    rewiredElementIdentifiers.GetModifierKeyDes(actionElementMap.modifierKey1),
    rewiredElementIdentifiers.GetModifierKeyDes(actionElementMap.modifierKey2),
    rewiredElementIdentifiers.GetModifierKeyDes(actionElementMap.modifierKey3)
  }
  local description = ""
  for _, modifierKey in ipairs(modifierKeys) do
    if modifierKey ~= "" then
      if description ~= "" then
        description = description .. " + "
      end
      description = description .. modifierKey
    end
  end
  return description
end
local getKeyDes = function(actionElementMap)
  local ret = ""
  if actionElementMap == nil then
    return ret
  end
  local keyCode = getKeyCodeByElementInfo(actionElementMap.controllerMap.controllerType, actionElementMap.keyCode, actionElementMap.elementIdentifierId)
  if keyCode == nil then
    return ret
  end
  local contrastTbl = Z.TableMgr.GetTable("SetKeyboardContrastTableMgr")
  local contrastRow = contrastTbl.GetRow(keyCode)
  if contrastRow ~= nil then
    if contrastRow.ShowType == 1 then
      ret = string.zconcat("<sprite name=\"", contrastRow.Id, "\">")
    else
      ret = contrastRow.Keyboard
    end
  else
    logError("[Setting] contrastRow is nil  controllerType: " .. actionElementMap.controllerMap.controllerType .. "  actionElementMap.keyCode:" .. actionElementMap.keyCode)
  end
  local modifierKeysDescription = getModifierKeysDescription(actionElementMap)
  if modifierKeysDescription ~= "" then
    ret = modifierKeysDescription .. " + " .. ret
  end
  return ret
end
local getGamepadDesc = function(row, gamepadType)
  local ret = ""
  local keyBoardIds
  if gamepadType == Panda.ZInput.EGamepadType.PS5 then
    keyBoardIds = row.PS5
  elseif gamepadType == Panda.ZInput.EGamepadType.XBOX then
    keyBoardIds = row.XBOX
  end
  if keyBoardIds == nil or #keyBoardIds == 0 then
    return ""
  end
  local keyDes = {}
  local contrastTbl = Z.TableMgr.GetTable("SetKeyboardContrastTableMgr")
  for _, keyBoardId in ipairs(keyBoardIds) do
    if contrastTbl then
      local contrastRow = contrastTbl.GetRow(keyBoardId)
      if contrastRow then
        if contrastRow.ShowType == 1 then
          keyDes[#keyDes + 1] = string.zconcat("<sprite name=\"", contrastRow.Id, "\">")
        else
          keyDes[#keyDes + 1] = string.zconcat("[", contrastRow.Keyboard, "]")
        end
      end
    end
  end
  ret = table.concat(keyDes, " + ")
  return ret
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
  if Z.InputMgr.InputDeviceType == Panda.ZInput.EInputDeviceType.Joystick then
    ret[1] = getGamepadDesc(row, Z.InputMgr.GamepadType)
    return ret
  end
  if row == nil or row.ActionIds == nil then
    return ret
  end
  for i = 1, #row.ActionIds do
    local inputActionId = row.ActionIds[i][1]
    local element = getFirstElementMapWithActionId(inputActionId, row.MapCategoryId)
    if element ~= nil then
      local desc = getKeyDes(element, keyId)
      table.insert(ret, desc)
    end
  end
  return ret
end
local resetKeySetting = function()
  Z.InputMgr:ResetMapsAndSave()
end
local isPresetKey = function(data)
  local contrastTbl = Z.TableMgr.GetTable("SetKeyboardContrastTableMgr")
  local keyCodeId = getKeyCodeByElementInfo(data.controllerType, data.keyboardKey, data.elementIdentifierId)
  local row = contrastTbl.GetRow(keyCodeId)
  if row then
    return true
  end
  Z.TipsVM.ShowTipsLang(1000202)
  return false
end
local handleKeyConflict = function(conflictActionIds)
  if not conflictActionIds or conflictActionIds.Count == 0 then
    return
  end
  local excludedActionIds = {}
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  local conflictCount = conflictActionIds.Count
  for i = 0, conflictCount - 1 do
    local actionId = conflictActionIds[i]
    local keyId = getKeyIdByActionId(actionId)
    if not keyTbl or not keyId then
      logGreen(string.format("[Setting] Missing mapping in SetKeyboard table for actionId: %d", actionId))
      table.insert(excludedActionIds, actionId)
    else
      local row = keyTbl.GetRow(keyId)
      if not row or row.ShowSwitch ~= 0 then
        table.insert(excludedActionIds, actionId)
        logGreen(string.format("[Setting] keyId: %d is not allowed to switch. ShowSwitch: %d", keyId, row and row.ShowSwitch or -1))
      end
    end
  end
  if #excludedActionIds == conflictCount then
    Z.TipsVM.ShowTips(1000204)
    Z.InputMgr:HandelConflict(false)
    return
  end
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("SettingKeyConfirmConflictSwitch"), function()
    Z.InputMgr:HandelConflict(true, excludedActionIds)
  end, function()
    Z.InputMgr:HandelConflict(false)
  end)
end
local reBindActionByActionId = function(actionId)
  local keyId = getKeyIdByActionId(actionId)
  if keyId == nil then
    return
  end
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  if keyTbl == nil then
    return
  end
  local row = keyTbl.GetRow(keyId)
  if row == nil then
    return
  end
  local element = getFirstElementMapWithActionId(actionId, row.MapCategoryId)
  if element == nil then
    return
  end
  Z.InputMgr:ReBindActionByActionElementMap(element)
end
local getDisplayGamepadActionKeyIds = function()
  local settingData = Z.DataMgr.Get("setting_data")
  settingData.displayGamepadActionCache_ = {}
  local keyIds = settingData:GetDisplayGamepadActionKeyIds()
  if keyIds ~= nil and next(keyIds) then
    return keyIds
  end
  local SetKeyboardTableMgr = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  if SetKeyboardTableMgr == nil then
    return {}
  end
  local rowList = SetKeyboardTableMgr.GetDatas()
  local ret = {}
  for _, row in pairs(rowList) do
    if row.ShowList == 1 then
      settingData:AddDisplayActionKeyId(row.Id)
      table.insert(ret, row.Id)
    end
  end
  return ret
end
local checkCanShowKeyDesc = function(keyId)
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  if keyTbl == nil then
    return false
  end
  local row = keyTbl.GetRow(keyId)
  if row == nil then
    return false
  end
  local deviceType = Z.InputMgr.InputDeviceType
  if deviceType == Panda.ZInput.EInputDeviceType.Joystick then
    if row.XBOX ~= nil and #row.XBOX > 0 then
      return true
    else
      return false
    end
  end
  return true
end
local ret = {
  GetShowKeyList = getShowKeyList,
  GetActionsByKeyId = getActionsByKeyId,
  GetFirstElementMapWithActionId = getFirstElementMapWithActionId,
  GetKeyDes = getKeyDes,
  ResetKeySetting = resetKeySetting,
  IsPresetKey = isPresetKey,
  HandleKeyConflict = handleKeyConflict,
  GetKeyIdByActionId = getKeyIdByActionId,
  GetGamepadDesc = getGamepadDesc,
  GetKeyCodeDescListByKeyId = getKeyCodeDescListByKeyId,
  ReBindActionByActionId = reBindActionByActionId,
  GetDisplayGamepadActionKeyIds = getDisplayGamepadActionKeyIds,
  CheckCanShowKeyDesc = checkCanShowKeyDesc
}
return ret
