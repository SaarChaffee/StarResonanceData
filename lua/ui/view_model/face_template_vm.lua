local FaceDef = require("ui.model.face_define")
local isValidColorVector = function(vector)
  if not vector then
    return false
  end
  local isZero = vector.X < 0.01 and 0.01 > vector.Y and 0.01 > vector.Z
  return not isZero
end
local colorVectorToHSV = function(vector)
  if not isValidColorVector(vector) then
    return Z.ColorHelper.GetDefaultHSV()
  end
  return {
    h = vector.X / 360,
    s = vector.Y / 100,
    v = vector.Z / 100
  }
end
local getResId = function(row, field)
  local value = 0
  if 1 < #row[field] then
    value = tonumber(row[field][1])
  end
  return value
end
local getFieldValue = function(row, field, index)
  local value
  if not index then
    value = row[field]
  else
    value = row[field][index]
  end
  return value
end
local getHSV = function(row, field, index)
  local vector = getFieldValue(row, field, index)
  if not isValidColorVector(vector) then
    local baseModelId = Z.ModelManager:GetModelIdByGenderAndSize(row.Sex, row.Model)
    local baseRow = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(baseModelId)
    if baseRow then
      vector = getFieldValue(baseRow, field, index)
    end
  end
  return colorVectorToHSV(vector)
end
local getIsOpen = function(row, field, index)
  local value = getFieldValue(row, field, index)
  return not (value < 0.01)
end
local getBodyParam = function(row, field, index)
  local value = getFieldValue(row, field, index)
  return value / 10
end
local getPupilAreaColor = function(row, area, isLeft)
  local baseModelId = Z.ModelManager:GetModelIdByGenderAndSize(row.Sex, row.Model)
  local baseRow = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(baseModelId)
  if baseRow then
    local baseVector = baseRow.LEyeColorArr[area]
    if baseVector then
      local field
      if not isLeft and row.EyeColorDiff == 1 then
        field = "REyeColorArr"
      else
        field = "LEyeColorArr"
      end
      if row.ColorZone == 1 then
        local areaVector = row[field][area]
        if isValidColorVector(areaVector) then
          return colorVectorToHSV(areaVector)
        else
          return colorVectorToHSV(baseVector)
        end
      else
        local areaVector = row[field][1]
        local hsv = colorVectorToHSV(areaVector)
        hsv.v = baseVector.Z / 100
        return hsv
      end
    end
  end
  return Z.ColorHelper.GetDefaultHSV()
end
local getFeatureTransData = function(row, idField, paramIndex)
  local faceVM = Z.VMMgr.GetVM("face")
  local id = getResId(row, idField)
  local transData = faceVM.GetFeatureDataByFeatureId(id).TransData
  return transData[paramIndex]
end
local getFeatureColor = function(row, idField, colorField)
  local vector = row[colorField]
  if not isValidColorVector(vector) then
    local faceVM = Z.VMMgr.GetVM("face")
    local id = getResId(row, idField)
    local hsv = faceVM.GetFeatureDataByFeatureId(id).Color
    return hsv
  else
    return colorVectorToHSV(vector)
  end
end
local initTypeToFunc = {
  [FaceDef.EOptionInitType.FaceId] = getResId,
  [FaceDef.EOptionInitType.OriginValue] = getFieldValue,
  [FaceDef.EOptionInitType.BodyParam] = getBodyParam,
  [FaceDef.EOptionInitType.HSVVector] = getHSV,
  [FaceDef.EOptionInitType.Switch] = getIsOpen,
  [FaceDef.EOptionInitType.HairHighlightsColor] = function(row, index)
    local isOpen = getIsOpen(row, "HairHighlight")
    if isOpen then
      local vector = row.HairColor[index] or row.HairColor[1]
      return colorVectorToHSV(vector)
    else
      return colorVectorToHSV(row.HairColor[1])
    end
  end,
  [FaceDef.EOptionInitType.HairGradualColor] = function(row)
    local isOpen = getIsOpen(row, "HairGradient", 1)
    if isOpen then
      local array = row.HairGradient
      return {
        h = array[3] / 360,
        s = array[4] / 100,
        v = array[5] / 100
      }
    else
      return colorVectorToHSV(row.HairColor[1])
    end
  end,
  [FaceDef.EOptionInitType.PupilAreaColor] = getPupilAreaColor,
  [FaceDef.EOptionInitType.PartHair] = function(row, field)
    return getResId(row, "Hair") > 0 and 0 or getResId(row, field)
  end,
  [FaceDef.EOptionInitType.FeatureData] = function(row, featureIndex, paramIndex)
    local idField = featureIndex == 1 and "Feature" or "DecalTex"
    return getFeatureTransData(row, idField, paramIndex)
  end,
  [FaceDef.EOptionInitType.FeatureColor] = function(row, featureIndex, colorField)
    local idField = featureIndex == 1 and "Feature" or "DecalTex"
    return getFeatureColor(row, idField, colorField)
  end
}
local getFaceOptionInitValue = function(row, optionEnum)
  local optionInfo = FaceDef.OPTION_TABLE[optionEnum]
  if optionInfo then
    local initType = optionInfo.InitParamList[1]
    local initFunc = initTypeToFunc[initType]
    if initFunc then
      local value = initFunc(row, table.unpack(optionInfo.InitParamList, 2))
      return value
    else
      logError("[getFaceOptionInitValue] initType = {0}\230\156\170\230\148\175\230\140\129", initType)
    end
  else
    logError("[getFaceOptionInitValue] optionEnum = {0}\230\156\170\230\148\175\230\140\129", optionEnum)
  end
end
local getFaceOptionInitValueByModelId = function(modelId, optionEnum)
  local row = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(modelId)
  if row then
    return getFaceOptionInitValue(row, optionEnum)
  end
end
local updateOptionDictByModelId = function(modelId, isNotify, useCacheFaceData)
  local faceData = Z.DataMgr.Get("face_data")
  if not useCacheFaceData then
    local row = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(modelId)
    if not row then
      return
    end
    for optionEnum, _ in pairs(FaceDef.OPTION_TABLE) do
      local value = getFaceOptionInitValue(row, optionEnum)
      faceData:SetFaceOptionValueWithoutLimit(optionEnum, value)
    end
  end
  if isNotify ~= false then
    Z.EventMgr:Dispatch(Z.ConstValue.FaceOptionAllChange)
    Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshMenuView)
  end
end
local updateFaceInitOptionDictByModelId = function()
  local faceData = Z.DataMgr.Get("face_data")
  local row = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(faceData:GetPlayerModelId())
  if not row then
    return
  end
  for optionEnum, _ in pairs(FaceDef.OPTION_TABLE) do
    if not faceData:GetFaceOptionByEnum(optionEnum) then
      local value = getFaceOptionInitValue(row, optionEnum)
      faceData:AddFaceOptionInitValue(optionEnum, value)
    end
  end
end
local updateFashionByModelId = function(modelId)
  local row = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(modelId)
  if not row then
    return
  end
  local fashionZList = ZUtil.Pool.Collections.ZList_Panda_ZGame_SingleWearData.Rent()
  local equipZList = ZUtil.Pool.Collections.ZList_Panda_ZGame_SingleWearData.Rent()
  local fieldList = {
    "Suit",
    "Clothes",
    "Pants",
    "Gloves",
    "Shoes",
    "Headwear",
    "Tail",
    "Mask",
    "MouthMask",
    "Earrings",
    "Necklace",
    "Ring"
  }
  for _, field in ipairs(fieldList) do
    local id = getResId(row, field)
    if 0 < id then
      local wearData = Panda.ZGame.SingleWearData.Rent()
      wearData.FashionID = id
      fashionZList:Add(wearData)
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, Z.LocalAttr.EWearFashion, fashionZList)
  Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, Z.LocalAttr.EWearEquip, equipZList)
  fashionZList:Recycle()
  equipZList:Recycle()
end
local ret = {
  UpdateOptionDictByModelId = updateOptionDictByModelId,
  UpdateFashionByModelId = updateFashionByModelId,
  GetFaceOptionInitValue = getFaceOptionInitValue,
  GetFaceOptionInitValueByModelId = getFaceOptionInitValueByModelId,
  GetModelTblResId = getResId,
  UpdateFaceInitOptionDictByModelId = updateFaceInitOptionDictByModelId
}
return ret
