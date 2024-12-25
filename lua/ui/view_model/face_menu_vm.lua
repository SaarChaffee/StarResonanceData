local faceData = Z.DataMgr.Get("face_data")
local worldproxy = require("zproxy.world_proxy")
local sortStyleData = function(left, right)
  if left.SortId ~= right.SortId then
    return left.SortId < right.SortId
  end
  return left.Id > right.Id
end
local checkStyleIsAllowUse = function(faceRow, checkUnlock)
  if faceRow.IsHide == 1 then
    return false
  end
  local isInCreate = faceData.FaceState == E.FaceDataState.Create
  if isInCreate and (faceRow.Create ~= 1 or #faceRow.Unlock > 0) then
    return false
  end
  if faceRow.Sex ~= faceData.Gender and faceRow.Sex ~= 0 then
    return false
  end
  if checkUnlock then
    local isUnlocked = faceData:GetFaceStyleItemIsUnlocked(faceRow.Id)
    if isUnlocked == false then
      return false
    end
  end
  if 0 < faceRow.FaceShapeId then
    local faceShapeId = faceData:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "FaceShapeID"))
    if faceShapeId ~= faceRow.FaceShapeId then
      return false
    end
  end
  for _, bodySize in pairs(faceRow.Model) do
    if bodySize == 0 or bodySize == faceData.BodySize then
      return true
    end
  end
  return false
end
local getFaceStyleDataListByAttr = function(attr, attrIndex)
  attrIndex = attrIndex or 1
  local attrData = faceData.FaceDef.ATTR_TABLE[attr]
  local isAllowNull = attrData.IsAllowNull
  local regionList
  if attr == Z.ModelAttr.EModelHeadTexFeature or attr == Z.ModelAttr.EModelHeadTexDecal then
    regionList = {
      Z.PbEnum("EFaceDataType", "FeatureOneID"),
      Z.PbEnum("EFaceDataType", "FeatureTwoID")
    }
  else
    regionList = {
      attrData.OptionList[attrIndex]
    }
  end
  local dataList = {}
  for _, row in pairs(faceData:GetFaceTableData()) do
    if table.zcontains(regionList, row.Type) and checkStyleIsAllowUse(row, true) then
      table.insert(dataList, row)
    end
  end
  table.sort(dataList, sortStyleData)
  if isAllowNull then
    table.insert(dataList, 1, {Id = 0})
  end
  return dataList
end
local getFaceColorDataByOptionEnum = function(optionEnum)
  local data = {
    GroupId = 1,
    HSV = Z.ColorHelper.GetDefaultHSV()
  }
  local row = Z.TableMgr.GetTable("FaceOptionTableMgr").GetRow(optionEnum)
  if row and row.Option == faceData.FaceDef.EOptionValueType.HSV then
    data.GroupId = row.ColorGroup
    local templateVM = Z.VMMgr.GetVM("face_template")
    data.HSV = templateVM.GetFaceOptionInitValueByModelId(faceData.ModelId, optionEnum)
  end
  return data
end
local getUnlockItemDataListByFaceId = function(faceId)
  local ret = {}
  local row = Z.TableMgr.GetTable("FaceTableMgr").GetRow(faceId)
  if row then
    for _, itemArray in ipairs(row.Unlock) do
      if #itemArray == 2 then
        local data = {
          ItemId = itemArray[1],
          UnlockNum = itemArray[2]
        }
        table.insert(ret, data)
      else
        logError("\232\167\163\233\148\129\230\157\161\228\187\182\233\133\141\231\189\174\230\160\188\229\188\143\233\148\153\232\175\175, faceId = {0}", faceId)
      end
    end
  end
  return ret
end
local asyncUnlockFaceStyle = function(faceId, cancelToken)
  local ret = worldproxy.UnLockFaceItem(faceId, cancelToken)
  if ret == 0 then
    Z.TipsVM.ShowTipsLang(120008)
    Z.EventMgr:Dispatch(Z.ConstValue.FaceStyleUnlock, faceId)
  else
    logError("[Face] UnlockStyle Fail, error = {0}", ret)
  end
end
local ret = {
  GetFaceStyleDataListByAttr = getFaceStyleDataListByAttr,
  GetFaceColorDataByOptionEnum = getFaceColorDataByOptionEnum,
  GetUnlockItemDataListByFaceId = getUnlockItemDataListByFaceId,
  CheckStyleIsAllowUse = checkStyleIsAllowUse,
  AsyncUnlockFaceStyle = asyncUnlockFaceStyle
}
return ret
