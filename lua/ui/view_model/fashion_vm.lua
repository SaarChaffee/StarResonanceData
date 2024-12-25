local fashionTbl = Z.TableMgr.GetTable("FashionTableMgr")
local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")
local fashionData = Z.DataMgr.Get("fashion_data")
local resType2WearDataAttr = {
  [E.FashionResType.Clothes] = Z.ModelAttr.EModelClothesWearData,
  [E.FashionResType.Gloves] = Z.ModelAttr.EModelGlovesWearData,
  [E.FashionResType.Pants] = Z.ModelAttr.EModelPantsWearData,
  [E.FashionResType.Shoes] = Z.ModelAttr.EModelShoesWearData,
  [E.FashionResType.Ring] = Z.ModelAttr.EModelRingWearData,
  [E.FashionResType.Neck] = Z.ModelAttr.EModelNeckWearData,
  [E.FashionResType.Suit] = Z.ModelAttr.EModelSuitWearData,
  [E.FashionResType.HalfSuit] = Z.ModelAttr.EModelHalfSuitWearData,
  [E.FashionResType.HeadWear] = Z.ModelAttr.EModelCMountHeadWearWearData,
  [E.FashionResType.FaceWear] = Z.ModelAttr.EModelHeadFaceWearWearData,
  [E.FashionResType.MouthWear] = Z.ModelAttr.EModelHeadMouthWearWearData,
  [E.FashionResType.Earrings] = Z.ModelAttr.EModelHeadEarsWearData,
  [E.FashionResType.Tail] = Z.ModelAttr.EModelCMountTailWearData
}
local openFashionSystemView = function(fashionData)
  local funcVM = Z.VMMgr.GetVM("gotofunc")
  if not funcVM.CheckFuncCanUse(E.FunctionID.Fashion) then
    return
  end
  local args = {}
  
  function args.EndCallback()
    local viewConfigKey = "fashion_system"
    Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Creation_01, viewConfigKey, function()
      Z.UIMgr:OpenView(viewConfigKey, {gotoData = fashionData})
    end, Z.ConstValue.UnrealSceneConfigPaths.Role)
  end
  
  Z.UIMgr:FadeIn(args)
end
local closeFashionSystemView = function()
  Z.UIMgr:CloseView("fashion_system")
end
local openFashionFaceView = function()
  local viewConfigKey = "fashion_face_window"
  local viewData = {showReturn = true}
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Creation_01, viewConfigKey, function()
    Z.UnrealSceneMgr:SwitchGroupReflection(true)
    Z.UIMgr:OpenView(viewConfigKey, viewData)
  end, Z.ConstValue.UnrealSceneConfigPaths.Role, false, false)
end
local closeFashionFaceView = function()
  Z.UIMgr:CloseView("fashion_face_window")
end
local getFashionUuid = function(fashionId)
  if Z.StageMgr.GetIsInLogin() then
    return
  end
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Fashion]
  for uuid, item in pairs(package.items) do
    local itemRow = itemTbl.GetRow(item.configId)
    if itemRow then
      local relatedFashion = itemRow.CorrelationId
      if fashionId == relatedFashion then
        return uuid
      end
    end
  end
end
local getFashionRegion = function(fashionId)
  local itemRow = itemTbl.GetRow(fashionId)
  if itemRow then
    return itemRow.Type
  else
    return 0
  end
end
local createStyleDataList = function(fashionIdList)
  local dataList = {}
  local tempDataDict = {}
  for _, fashionId in ipairs(fashionIdList) do
    local styleData = {}
    styleData.fashionId = fashionId
    tempDataDict[fashionId] = styleData
    table.insert(dataList, styleData)
  end
  if not Z.StageMgr.GetIsInLogin() then
    local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Fashion]
    for uuid, item in pairs(package.items) do
      local itemData = itemTbl.GetRow(item.configId)
      if itemData then
        local relatedFashion = itemData.CorrelationId
        if tempDataDict[relatedFashion] then
          tempDataDict[relatedFashion].uuid = uuid
        end
      end
    end
  end
  return dataList
end
local sortStyleData = function(left, right)
  if left.uuid == nil and right.uuid ~= nil then
    return false
  end
  if left.uuid ~= nil and right.uuid == nil then
    return true
  end
  local leftFashionRow = fashionTbl.GetRow(left.fashionId)
  local rightFashionRow = fashionTbl.GetRow(right.fashionId)
  if leftFashionRow and rightFashionRow and leftFashionRow.SortID ~= rightFashionRow.SortID then
    return leftFashionRow.SortID < rightFashionRow.SortID
  end
  return leftFashionRow.Id > rightFashionRow.Id
end
local checkStyleVisible = function(fashionRow)
  if fashionRow.IsHide == 1 then
    return false
  end
  local faceData = Z.DataMgr.Get("face_data")
  local playerGender = faceData:GetPlayerGender()
  local itemRow = itemTbl.GetRow(fashionRow.Id)
  if itemRow and itemRow.SexLimit ~= playerGender and itemRow.SexLimit ~= 0 then
    return false
  end
  return true
end
local getStyleDataListByRegion = function(region)
  local dataList = {}
  local nullData = {}
  nullData.fashionId = 0
  table.insert(dataList, nullData)
  local wornFashion = fashionData:GetServerFashionWear(region)
  if wornFashion then
    local wornData = {}
    wornData.fashionId = wornFashion
    wornData.uuid = getFashionUuid(wornFashion)
    table.insert(dataList, wornData)
  end
  local fashionIdList = {}
  for fashionId, fashionRow in pairs(fashionTbl.GetDatas()) do
    if fashionId ~= wornFashion then
      local itemRow = itemTbl.GetRow(fashionId, true)
      if itemRow and itemRow.Type == region and checkStyleVisible(fashionRow) then
        table.insert(fashionIdList, fashionId)
      end
    end
  end
  local needSortList = createStyleDataList(fashionIdList)
  table.sort(needSortList, sortStyleData)
  for _, data in ipairs(needSortList) do
    table.insert(dataList, data)
  end
  return dataList
end
local wearDataListToZList = function(dataList)
  local zList = ZUtil.Pool.Collections.ZList_Panda_ZGame_SingleWearData.Rent()
  for _, data in ipairs(dataList) do
    local wearData = Panda.ZGame.SingleWearData.Rent()
    wearData.FashionID = data.FashionId
    if data.ColorZList then
      wearData.BaseColor = data.ColorZList
    end
    zList:Add(wearData)
  end
  return zList
end
local hsvToRGBVector = function(hsv)
  local rgb = Color.HSVToRGB(hsv.h, hsv.s, hsv.v, true)
  return Vector3.New(rgb.r, rgb.g, rgb.b)
end
local colorListToZList = function(colorList)
  local zList = ZUtil.Pool.Collections.ZList_UnityEngine_Vector3.Rent()
  for _, hsv in ipairs(colorList) do
    zList:Add(hsvToRGBVector(hsv))
  end
  return zList
end
local getFashionDefaultColorByArea = function(fashionId, targetArea)
  local hsv = Z.ColorHelper.GetDefaultHSV()
  local fashionRow = fashionTbl.GetRow(fashionId)
  if not fashionRow then
    return hsv
  end
  local zList = Z.LuaBridge.GetFashionDefaultHSVListByFashionId(fashionId)
  if targetArea < zList.count then
    local vector = zList[targetArea]
    hsv.h = math.floor(vector.x * 360 + 0.5)
    hsv.s = math.floor(vector.y * 100 + 0.5)
    hsv.v = math.floor(vector.z * 100 + 0.5)
  end
  zList:Recycle()
  return hsv
end
local isDefaultFashionAreaColor = function(fashionId, area, hsv)
  if hsv then
    local defaultColor = getFashionDefaultColorByArea(fashionId, area)
    if hsv.h == defaultColor.h and hsv.s == defaultColor.s and hsv.v == defaultColor.v then
      return true
    end
  end
  return false
end
local getFashionColorZList = function(fashionId)
  local colorList = {}
  local colorDict = fashionData:GetColor(fashionId)
  for area = 1, 4 do
    local hsv = {}
    if not colorDict[area] then
      hsv = getFashionDefaultColorByArea(fashionId, area)
    else
      hsv = colorDict[area]
    end
    table.insert(colorList, {
      h = hsv.h / 360,
      s = hsv.s / 100,
      v = hsv.v / 100
    })
  end
  local zList = colorListToZList(colorList)
  zList:Insert(0, Vector3.zero)
  return zList
end
local getFashionDefaultColorZList = function(fashionId)
  local colorList = {}
  for area = 1, 4 do
    local hsv = getFashionDefaultColorByArea(fashionId, area)
    table.insert(colorList, {
      h = hsv.h / 360,
      s = hsv.s / 100,
      v = hsv.v / 100
    })
  end
  local zList = colorListToZList(colorList)
  zList:Insert(0, Vector3.zero)
  return zList
end
local refreshWearAttr = function()
  local dataList = {}
  for _, region in pairs(E.FashionRegion) do
    local styleData = fashionData:GetWear(region)
    if styleData then
      local fashionId = styleData.fashionId
      local data = {}
      data.FashionId = fashionId
      data.ColorZList = getFashionColorZList(fashionId)
      table.insert(dataList, data)
    end
  end
  local zList = wearDataListToZList(dataList)
  Z.EventMgr:Dispatch(Z.ConstValue.FashionAttrChange, Z.LocalAttr.EWearFashion, zList)
  zList:Recycle()
end
local nowSelectPartIsHide = function(region)
  local tab = Z.VMMgr.GetVM("fashion_setting").GetCurFashionSettingRegionDict()
  if tab[region] == 2 then
    Z.TipsVM.ShowTipsLang(120003)
  end
end
local setFashionWear = function(region, styleData)
  if styleData and styleData.fashionId > 0 then
    fashionData:SetWear(region, styleData)
    if region == E.FashionRegion.Suit then
      fashionData:SetWear(E.FashionRegion.UpperClothes, nil)
      fashionData:SetWear(E.FashionRegion.Pants, nil)
    elseif region == E.FashionRegion.UpperClothes or region == E.FashionRegion.Pants then
      fashionData:SetWear(E.FashionRegion.Suit, nil)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.GM.GMItemView, styleData.fashionId)
  else
    fashionData:SetWear(region, nil)
  end
  nowSelectPartIsHide(region)
  refreshWearAttr()
end
local revertFashionWearByRegion = function(region)
  local fashionId = fashionData:GetServerFashionWear(region)
  if fashionId then
    local styleData = {}
    styleData.fashionId = fashionId
    styleData.uuid = getFashionUuid(fashionId)
    setFashionWear(region, styleData)
  else
    setFashionWear(region, nil)
  end
end
local revertFashionColorByFashionIdAndArea = function(fashionId, area)
  local hsv = fashionData:GetServerFashionColor(fashionId, area)
  fashionData:SetColor(fashionId, area, hsv)
  refreshWearAttr()
end
local revertAllFashionWear = function()
  fashionData:ClearWearDict()
  fashionData:InitFashionData()
  refreshWearAttr()
  Z.EventMgr:Dispatch(Z.ConstValue.FashionWearRevert)
end
local setFashionColor = function(fashionId, area, hsv, ignoreGm)
  fashionData:SetColor(fashionId, area, hsv)
  local fashionRow = fashionTbl.GetRow(fashionId)
  if fashionRow then
    local resType = fashionRow.FashionType
    local attrType = resType2WearDataAttr[resType]
    if not attrType then
      return
    end
    local itemRow = itemTbl.GetRow(fashionId)
    if itemRow then
      local settingVM = Z.VMMgr.GetVM("fashion_setting")
      local isHide = settingVM.GetFashionRegionIsHide(itemRow.Type)
      if not isHide then
        local wearData = Panda.ZGame.SingleWearData.Rent()
        wearData.FashionID = fashionId
        wearData.BaseColor = getFashionColorZList(fashionId)
        Z.EventMgr:Dispatch(Z.ConstValue.FashionAttrChange, attrType, wearData)
      end
    end
  end
  if not ignoreGm then
    Z.EventMgr:Dispatch(Z.ConstValue.GM.GMFashionView, fashionId)
  end
end
local setFashionWearByFashionId = function(fashionId)
  local fashionRow = Z.TableMgr.GetRow("FashionTableMgr", fashionId)
  if not fashionRow then
    return
  end
  local styleData = {fashionId = fashionId}
  local region = fashionRow.Type
  if styleData and styleData.fashionId > 0 then
    fashionData:SetWear(region, styleData)
    if region == E.FashionRegion.Suit then
      fashionData:SetWear(E.FashionRegion.UpperClothes, nil)
      fashionData:SetWear(E.FashionRegion.Pants, nil)
    elseif region == E.FashionRegion.UpperClothes or region == E.FashionRegion.Pants then
      fashionData:SetWear(E.FashionRegion.Suit, nil)
    end
  else
    fashionData:SetWear(region, nil)
  end
  refreshWearAttr()
end
local asyncSendFashionWear = function(cancelToken)
  local wear = {}
  local unwear = {}
  local fashionIds = {}
  for _, region in pairs(E.FashionRegion) do
    local styleData = fashionData:GetWear(region)
    if styleData and styleData.uuid then
      table.insert(wear, styleData.uuid)
      table.insert(fashionIds, styleData.fashionId)
    else
      table.insert(unwear, region)
    end
  end
  local worldproxy = require("zproxy.world_proxy")
  local ret = worldproxy.FashionWear(wear, unwear, cancelToken)
  if ret == 0 then
    Z.TipsVM.ShowTipsLang(120001)
    for index, fashionId in ipairs(fashionIds) do
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnFashionWearChange, fashionId)
    end
  else
    logError("[Fashion] FashionWear Fail, error = {0}", ret)
  end
end
local convertHSVToProtoVector = function(fashionId, area)
  local colorDict = fashionData:GetColor(fashionId)
  local hsv = colorDict[area]
  if not hsv then
    return {
      x = -1,
      y = -1,
      z = -1
    }
  end
  if isDefaultFashionAreaColor(fashionId, area, hsv) then
    return {
      x = -1,
      y = -1,
      z = -1
    }
  end
  local hIndex = 0
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(fashionId)
  if fashionRow then
    local colorRow = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(fashionRow.ColorGroupId)
    if colorRow then
      if colorRow.Type == E.EHueModifiedMode.Board then
        hIndex = hsv.h
      else
        for _, hueArray in ipairs(colorRow.Hue) do
          local intH = hsv.h
          if intH == hueArray[2] then
            hIndex = hueArray[1] or 0
            break
          end
        end
      end
    end
  end
  return {
    x = hIndex,
    y = hsv.s,
    z = hsv.v
  }
end
local asyncSendFashionColor = function(fashionId, cancelToken)
  local protoColorDict = {}
  for area = 1, 4 do
    protoColorDict[area] = convertHSVToProtoVector(fashionId, area)
  end
  local worldproxy = require("zproxy.world_proxy")
  local ret = worldproxy.FashionSetColor(fashionId, {colorDict = protoColorDict}, cancelToken)
  if ret == 0 then
    Z.TipsVM.ShowTipsLang(120002)
    Z.EventMgr:Dispatch(Z.ConstValue.FashionColorSave, fashionId)
  else
    logError("[Fashion] FashionSetColor Fail, error = {0}", ret)
  end
end
local asyncUnlockFashionColor = function(fashionId, colorIndex, cancelToken)
  local worldproxy = require("zproxy.world_proxy")
  local ret = worldproxy.UnlockColor(fashionId, colorIndex, cancelToken)
  if ret == 0 then
    Z.TipsVM.ShowTipsLang(120010)
    Z.EventMgr:Dispatch(Z.ConstValue.FashionColorUnlock, fashionId, colorIndex)
  else
    logError("[Fashion] UnlockColor Fail, error = {0}, fashionId = {1}", ret, fashionId)
  end
end
local asyncSaveAllFashion = function(cancelSource)
  asyncSendFashionWear(cancelSource:CreateToken())
  local saveVM = Z.VMMgr.GetVM("fashion_save_tips")
  local wears = fashionData:GetWears()
  for _, styleData in pairs(wears) do
    local fashionId = styleData.fashionId
    local areaColorDict = fashionData:GetColor(fashionId)
    for area, hsv in pairs(areaColorDict) do
      if not saveVM.GetFashionAreaColorIsSaved(fashionId, area, hsv) then
        asyncSendFashionColor(fashionId, cancelSource:CreateToken())
        break
      end
    end
  end
end
local getRegionName = function(region)
  local row = Z.TableMgr.GetTable("ItemTypeTableMgr").GetRow(region)
  if row then
    return row.Name
  else
    return ""
  end
end
local checkIsFashion = function(itemid)
  local fashionTableRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(itemid, true)
  if not fashionTableRow then
    return false
  end
  return checkStyleVisible(fashionTableRow)
end
local gotoFashionView = function(fashionId, viewKey)
  if viewKey then
    Z.UIMgr:CloseView(viewKey)
  end
  fashionData:SetWear(getFashionRegion(fashionId), {fashionId = fashionId})
  local data = {}
  data.FashionId = fashionId
  data.Reason = E.FashionTipsReason.UnlockedWear
  openFashionSystemView(data)
end
local gotoFashionListView = function(fashionIdList, viewKey)
  if viewKey then
    Z.UIMgr:CloseView(viewKey)
  end
  for i = 1, #fashionIdList do
    fashionData:SetWear(getFashionRegion(fashionIdList[i]), {
      fashionId = fashionIdList[i]
    })
  end
  local data = {}
  data.FashionId = fashionIdList[1]
  data.Reason = E.FashionTipsReason.UnlockedWear
  openFashionSystemView(data)
end
local saveFashionDataToFile = function()
  local data = {
    Wear = {},
    Color = {}
  }
  for region, styleData in pairs(fashionData:GetWears()) do
    data.Wear[tostring(region)] = styleData.fashionId
  end
  for fashionId, areaColorDict in pairs(fashionData:GetColors()) do
    local temp = {}
    for area, hsv in pairs(areaColorDict) do
      temp[tostring(area)] = hsv
    end
    data.Color[tostring(fashionId)] = temp
  end
  local cjson = require("cjson")
  local path = Panda.Utility.PathEx.GetPathWithSaveFilePanel("save", "C:\\", "PandaFashionData", "txt")
  Panda.Utility.FileEx.SaveText(cjson.encode(data), path)
end
local loadFashionDataFromFile = function(path)
  path = path or Panda.Utility.PathEx.GetPathWithOpenFilePanel("open", "C:\\", "txt")
  local cjson = require("cjson")
  local content = Panda.Utility.FileEx.ReadText(path)
  local data = cjson.decode(content)
  fashionData:Clear()
  for k, v in pairs(data.Wear) do
    local region = tonumber(k)
    local fashionId = math.floor(v + 0.5)
    if 0 < fashionId then
      fashionData:SetWear(region, {fashionId = fashionId})
    end
  end
  for k1, areaColorDict in pairs(data.Color) do
    local fashionId = tonumber(k1)
    for k2, hsv in pairs(areaColorDict) do
      local area = tonumber(k2)
      fashionData:SetColor(fashionId, area, hsv)
    end
  end
  refreshWearAttr()
end
local asyncRefreshPersonalZoneFashionScore = function()
  local worldProxy = require("zproxy.world_proxy")
  worldProxy.RefreshPersonalZoneFashionScore()
end
local ret = {
  OpenFashionSystemView = openFashionSystemView,
  CloseFashionSystemView = closeFashionSystemView,
  OpenFashionFaceView = openFashionFaceView,
  CloseFashionFaceView = closeFashionFaceView,
  AsyncSendFashionColor = asyncSendFashionColor,
  AsyncSendFashionWear = asyncSendFashionWear,
  AsyncSaveAllFashion = asyncSaveAllFashion,
  AsyncUnlockFashionColor = asyncUnlockFashionColor,
  GetFashionDefaultColorByArea = getFashionDefaultColorByArea,
  IsDefaultFashionAreaColor = isDefaultFashionAreaColor,
  GetFashionUuid = getFashionUuid,
  GetFashionRegion = getFashionRegion,
  GetStyleDataListByRegion = getStyleDataListByRegion,
  GetRegionName = getRegionName,
  SetFashionColor = setFashionColor,
  SetFashionWear = setFashionWear,
  WearDataListToZList = wearDataListToZList,
  RevertFashionWearByRegion = revertFashionWearByRegion,
  RevertFashionColorByFashionIdAndArea = revertFashionColorByFashionIdAndArea,
  RevertAllFashionWear = revertAllFashionWear,
  SaveFashionDataToFile = saveFashionDataToFile,
  LoadFashionDataFromFile = loadFashionDataFromFile,
  RefreshWearAttr = refreshWearAttr,
  CheckIsFashion = checkIsFashion,
  GotoFashionView = gotoFashionView,
  GotoFashionListView = gotoFashionListView,
  CheckStyleVisible = checkStyleVisible,
  AsyncRefreshPersonalZoneFashionScore = asyncRefreshPersonalZoneFashionScore,
  SetFashionWearByFashionId = setFashionWearByFashionId
}
return ret
