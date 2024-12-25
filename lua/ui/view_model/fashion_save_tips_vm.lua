local fashionData = Z.DataMgr.Get("fashion_data")
local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")
local openSaveTipsView = function()
  Z.UIMgr:OpenView("fashion_save_confirm_popup")
end
local closeSaveTipsView = function()
  Z.UIMgr:CloseView("fashion_save_confirm_popup")
end
local getFashionAreaColorIsSaved = function(fashionId, area, hsv)
  local areaColor = fashionData:GetServerFashionColor(fashionId, area)
  if areaColor and hsv.h == areaColor.h and hsv.s == areaColor.s and hsv.v == areaColor.v then
    return true
  end
  return false
end
local getFashionWearIsSaved = function(fashionId)
  local wears = Z.ContainerMgr.CharSerialize.fashion.wearInfo
  for key, value in pairs(wears) do
    if fashionId == value then
      return true
    end
  end
  return false
end
local isExistUnsavedFashion = function()
  local wears = fashionData:GetWears()
  for _, styleData in pairs(wears) do
    if not getFashionWearIsSaved(styleData.fashionId) then
      return true
    end
  end
  local colors = fashionData:GetColors()
  for fashionId, areaColorDict in pairs(colors) do
    for area, hsv in pairs(areaColorDict) do
      if not getFashionAreaColorIsSaved(fashionId, area, hsv) then
        return true
      end
    end
  end
  return false
end
local getFashionWearIsUnlocked = function(fashionId)
  local items = Z.ContainerMgr.CharSerialize.itemPackage.packages[7].items
  for uuid, item in pairs(items) do
    local itemData = itemTbl.GetRow(item.configId)
    if itemData then
      local relatedFashion = itemData.CorrelationId
      if fashionId == relatedFashion then
        return true
      end
    end
  end
  return false
end
local getFashionColorIsUnlocked = function(fashionId, area)
  local areaColorDict = fashionData:GetColor(fashionId)
  local hsv = areaColorDict[area]
  if not hsv then
    return true
  end
  local fashionVM = Z.VMMgr.GetVM("fashion")
  if fashionVM.IsDefaultFashionAreaColor(fashionId, area, hsv) then
    return true
  end
  local curIntH = math.floor(hsv.h * 360 + 0.5)
  local curColorIndex = 0
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(fashionId)
  if fashionRow then
    local colorRow = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(fashionRow.ColorGroupId)
    if colorRow then
      if colorRow.Type == E.EHueModifiedMode.Board then
        return true
      end
      for _, hueArray in ipairs(colorRow.Hue) do
        if curIntH == hueArray[2] then
          curColorIndex = hueArray[1]
          break
        end
      end
    end
  end
  return fashionData:GetColorIsUnlocked(fashionId, curColorIndex)
end
local isColorChange = function(hsv, fashionId, area)
  if hsv then
    local serverColor = fashionData:GetServerFashionColor(fashionId, area)
    if serverColor then
      return hsv.h ~= serverColor.h or hsv.s ~= serverColor.s or hsv.v ~= serverColor.v
    else
      local fashionVM = Z.VMMgr.GetVM("fashion")
      local defaultColor = fashionVM.GetFashionDefaultColorByArea(fashionId, area)
      if hsv.h ~= defaultColor.h or hsv.s ~= defaultColor.s or hsv.v ~= defaultColor.v then
        return true
      end
      return false
    end
  end
  return false
end
local getFashionConfirmDataList = function()
  local ret = {}
  local tempFashionSet = {}
  local wears = fashionData:GetWears()
  for _, styleData in pairs(wears) do
    local fashionId = styleData.fashionId
    if not getFashionWearIsUnlocked(fashionId) then
      local confirmData = {
        FashionId = fashionId,
        Reason = E.FashionTipsReason.UnlockedWear
      }
      table.insert(ret, confirmData)
      tempFashionSet[fashionId] = true
    end
  end
  for _, styleData in pairs(wears) do
    local fashionId = styleData.fashionId
    if not tempFashionSet[fashionId] then
      local confirmData
      local areaColorDict = fashionData:GetColor(fashionId)
      for area, hsv in pairs(areaColorDict) do
        local reason
        if isColorChange(hsv, fashionId, area) then
          reason = E.FashionTipsReason.UnlockedColor
        elseif not getFashionColorIsUnlocked(fashionId, area) then
          reason = E.FashionTipsReason.UnlockedColor
        end
        if reason then
          if not confirmData then
            confirmData = {
              FashionId = fashionId,
              Reason = reason,
              AreaList = {}
            }
            table.insert(ret, confirmData)
          end
          table.insert(confirmData.AreaList, area)
        end
      end
      if confirmData then
        table.sort(confirmData.AreaList)
      end
    end
  end
  return ret
end
local convertRealAreaToShowArea = function(fashionId, realArea)
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(fashionId)
  if fashionRow then
    for i, area in ipairs(fashionRow.ColorPart) do
      if realArea == area then
        return i
      end
    end
  end
end
local getFashionColorAreaStr = function(fashionId, areaList)
  local areaStr = ""
  local count = #areaList
  for i, area in ipairs(areaList) do
    local showArea = convertRealAreaToShowArea(fashionId, area)
    if showArea then
      areaStr = areaStr .. Lang("RomanNumeral" .. showArea)
    end
    if i ~= count then
      areaStr = areaStr .. "\227\128\129"
    end
  end
  return areaStr
end
local isFashionWearChange = function()
  local wears = fashionData:GetWears()
  for region, styleData in pairs(wears) do
    local wornFashion = fashionData:GetServerFashionWear(region)
    if wornFashion ~= styleData.fashionId then
      return true
    end
  end
  return false
end
local ret = {
  OpenSaveTipsView = openSaveTipsView,
  CloseSaveTipsView = closeSaveTipsView,
  GetFashionColorAreaStr = getFashionColorAreaStr,
  GetFashionColorIsUnlocked = getFashionColorIsUnlocked,
  GetFashionConfirmDataList = getFashionConfirmDataList,
  GetFashionAreaColorIsSaved = getFashionAreaColorIsSaved,
  IsExistUnsavedFashion = isExistUnsavedFashion,
  IsFashionWearChange = isFashionWearChange
}
return ret
