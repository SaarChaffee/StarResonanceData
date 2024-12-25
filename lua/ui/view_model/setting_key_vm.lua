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
    if row.ActionIds == nil or row.ActionIds == nil then
      return nil
    end
    local ret = {}
    for _, actionId in ipairs(row.ActionIds) do
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
    if row.ActionIds ~= nil and row.ActionIds ~= nil then
      for _, id in ipairs(row.ActionIds) do
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
local getKeyCodeListByKeyId = function(keyId)
  local ret = {}
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  if keyTbl == nil then
    return ret
  end
  local row = keyTbl.GetRow(keyId)
  if row == nil or row.ActionIds == nil or row.ActionIds == nil then
    return ret
  end
  for _, inputActionId in ipairs(row.ActionIds) do
    local element = getFirstElementMapWithActionId(inputActionId, row.MapCategoryId)
    if element ~= nil then
      local keyCode = getKeyCodeByElementInfo(element.controllerMap.controllerType, element.keyCode, element.elementIdentifierId)
      if keyCode ~= nil then
        table.insert(ret, keyCode)
      end
    end
  end
  return ret
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
    ret = contrastRow.Keyboard
  end
  return ret
end
local resetKeySetting = function()
  Z.InputMgr:ResetMaps()
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
local handleKeyConflict = function()
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("SettingKeyConfirmConflictSwitch"), function()
    Z.InputMgr:HandelConflict(true)
    Z.DialogViewDataMgr:CloseDialogView()
  end, function()
    Z.InputMgr:HandelConflict(false)
    Z.DialogViewDataMgr:CloseDialogView()
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
local ret = {
  GetShowKeyList = getShowKeyList,
  GetActionsByKeyId = getActionsByKeyId,
  GetFirstElementMapWithActionId = getFirstElementMapWithActionId,
  GetKeyDes = getKeyDes,
  ResetKeySetting = resetKeySetting,
  IsPresetKey = isPresetKey,
  HandleKeyConflict = handleKeyConflict,
  GetKeyIdByActionId = getKeyIdByActionId,
  GetKeyCodeListByKeyId = getKeyCodeListByKeyId,
  ReBindActionByActionId = reBindActionByActionId
}
return ret
