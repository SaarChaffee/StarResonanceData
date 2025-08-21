local FaceDef = require("ui.model.face_define")
local updateAttrWithOriginValue = function(attrType, valueList)
  local attrValue = valueList[1]
  Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, attrType, attrValue)
  if attrType == Z.ModelAttr.EModelPinchCalfThickness then
    Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, Z.ModelAttr.EModelPinchAnkleThickness, attrValue)
    Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, Z.ModelAttr.EModelPinchFootThickness, attrValue)
  end
end
local updateAttrWithConfigTableRes = function(attrType, valueList)
  local id = valueList[1]
  if 0 < id then
    local row = Z.TableMgr.GetTable("FaceTableMgr").GetRow(id)
    if row then
      if attrType == Z.ModelAttr.EModelHeadTexEye_d then
        Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, Z.ModelAttr.EModelHeadTexEye_d, row.Resource)
        Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, Z.ModelAttr.EModelHeadTexEye_id, row.Resource)
      else
        Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, attrType, row.Resource)
      end
    end
  else
    Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, attrType, "")
  end
end
local updateAttrWithPinchHeadData = function(attrType, valueList)
  local weight = valueList[1]
  local attrValue = Panda.ZGame.PinchHeadData.New("", weight)
  Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, attrType, attrValue)
end
local updateAttrWithPupilVector = function(attrType, valueList)
  local x = valueList[1] + 1
  local y = valueList[2] + 1
  local lastX = x
  local lastY = y * x
  local attrValue = Panda.ZGame.PinchHeadData.New("", Vector2.New(lastY - 1, lastX - 1))
  Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, attrType, attrValue)
end
local updateAttrWithTwoConfigTabRes = function(attrType, valueList)
  local configId1 = valueList[1]
  local config1Row = Z.TableMgr.GetTable("FaceTableMgr").GetRow(configId1)
  if not config1Row then
    return
  end
  local configId2 = valueList[2]
  local config2Row = Z.TableMgr.GetTable("FaceTableMgr").GetRow(configId2, true)
  local resource = 0
  if config2Row then
    resource = config2Row.Resource
  end
  Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, attrType, string.zconcat(config1Row.Resource, "_", string.format("%02d", resource)))
end
local updateAttrWithFaceHandleData = function(attrType, valueList, idOption)
  local faceData = Z.DataMgr.Get("face_data")
  local id = faceData:GetFaceOptionValue(idOption)
  if id <= 0 then
    return
  end
  local row = Z.TableMgr.GetTable("FaceStickerTableMgr").GetRow(id)
  if not row then
    return
  end
  local scale = row.DefaultScale.Y + (row.DefaultScale.Z - row.DefaultScale.Y) * valueList[FaceDef.EAttrParamFaceHandleData.Scale]
  local x = -1 + 2 * valueList[FaceDef.EAttrParamFaceHandleData.X]
  local y = -1 + 2 * valueList[FaceDef.EAttrParamFaceHandleData.Y]
  local rot = -180 + 360 * valueList[FaceDef.EAttrParamFaceHandleData.Rotation]
  local isFlip = valueList[FaceDef.EAttrParamFaceHandleData.IsFlip]
  local attrValue = Panda.ZGame.ModelFaceHandleData.New(isFlip, Vector4.New(scale, x, y, rot))
  Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, attrType, attrValue)
end
local hsvToRGBVector = function(hsv)
  local rgb = Color.HSVToRGB(hsv.h, hsv.s, hsv.v, true)
  return Vector3.New(rgb.r, rgb.g, rgb.b)
end
local updateAttrWithRGBVector = function(attrType, valueList)
  local hsv = valueList[1]
  local attrValue = hsvToRGBVector(hsv)
  Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, attrType, attrValue)
end
local updateAttrWithRGBVectorZList = function(attrType, valueList)
  local zList = ZUtil.Pool.Collections.ZList_UnityEngine_Vector3.Rent()
  for _, hsv in ipairs(valueList) do
    local rgbVector = hsvToRGBVector(hsv)
    zList:Add(rgbVector)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, attrType, zList)
  zList:Recycle()
end
local updateAttrWithHairColorZList = function(attrType, valueList)
  local zList = ZUtil.Pool.Collections.ZList_UnityEngine_Vector3.Rent()
  local faceData = Z.DataMgr.Get("face_data")
  local baseColor = valueList[1]
  zList:Add(hsvToRGBVector(baseColor))
  local highOneLightsColor
  if faceData:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "HairOneIsHighlights")) then
    highOneLightsColor = valueList[2]
  else
    highOneLightsColor = baseColor
  end
  zList:Add(hsvToRGBVector(highOneLightsColor))
  local highTwoLightsColor
  if faceData:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "HairTwoIsHighlights")) then
    highTwoLightsColor = valueList[3]
  else
    highTwoLightsColor = baseColor
  end
  zList:Add(hsvToRGBVector(highTwoLightsColor))
  Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, attrType, zList)
  zList:Recycle()
end
local updateAttrWithHairGradualData = function(attrType, valueList)
  local intOpen = valueList[FaceDef.EAttrParamHairGradient.IsOpen] and 1 or 0
  local rgbVector = hsvToRGBVector(valueList[FaceDef.EAttrParamHairGradient.Color])
  local range = valueList[FaceDef.EAttrParamHairGradient.Range]
  Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, attrType, rgbVector, range, intOpen)
end
local updateFuncDict = {
  [E.FaceAttrUpdateMode.ConfigTableRes] = updateAttrWithConfigTableRes,
  [E.FaceAttrUpdateMode.HairGradualData] = updateAttrWithHairGradualData,
  [E.FaceAttrUpdateMode.HairColorZList] = updateAttrWithHairColorZList,
  [E.FaceAttrUpdateMode.OriginValue] = updateAttrWithOriginValue,
  [E.FaceAttrUpdateMode.PinchHeadData] = updateAttrWithPinchHeadData,
  [E.FaceAttrUpdateMode.FaceHandleData] = updateAttrWithFaceHandleData,
  [E.FaceAttrUpdateMode.RGBVector] = updateAttrWithRGBVector,
  [E.FaceAttrUpdateMode.RGBVectorZList] = updateAttrWithRGBVectorZList,
  [E.FaceAttrUpdateMode.PupilVector] = updateAttrWithPupilVector,
  [E.FaceAttrUpdateMode.TwoConfigTabRes] = updateAttrWithTwoConfigTabRes
}
local updateFaceAttr = function(attrType)
  local faceData = Z.DataMgr.Get("face_data")
  local valueList = {}
  local attrData = FaceDef.ATTR_TABLE[attrType]
  for _, optionEnum in ipairs(attrData.OptionList) do
    local value = faceData:GetFaceOptionValue(optionEnum)
    if value ~= nil then
      table.insert(valueList, value)
    else
      logError("[updateFaceAttr] \230\141\143\232\132\184\233\128\137\233\161\185\229\128\188\228\184\186\231\169\186, optionEnum = {0}", optionEnum)
      return
    end
  end
  local mode = attrData.UpdateParamList[1]
  local updateFunc = updateFuncDict[mode]
  if updateFunc then
    updateFunc(attrType, valueList, table.unpack(attrData.UpdateParamList, 2))
  end
end
local updateAllAttr = function()
  for attrType, _ in pairs(FaceDef.ATTR_TABLE) do
    updateFaceAttr(attrType)
  end
end
local ret = {UpdateFaceAttr = updateFaceAttr, UpdateAllFaceAttr = updateAllAttr}
return ret
