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
  [E.FashionResType.Tail] = Z.ModelAttr.EModelCMountTailWearData,
  [E.FashionResType.Back] = Z.ModelAttr.EModelCMountBackWearData
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
local getFashionIsUnlock = function(fashionId, ignoreLogin)
  if Z.StageMgr.GetIsInLogin() and not ignoreLogin then
    return
  end
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Fashion]
  for _, item in pairs(package.items) do
    local itemRow = itemTbl.GetRow(item.configId)
    if itemRow then
      local relatedFashion = itemRow.CorrelationId
      if fashionId == relatedFashion then
        return true
      end
    end
  end
  return false
end
local getFashionRegion = function(fashionId)
  local itemRow = itemTbl.GetRow(fashionId)
  if itemRow then
    return itemRow.Type
  else
    return 0
  end
end
local getFashionAdvanced = function(fashionId)
  if fashionId == nil then
    return nil
  end
  local row = Z.TableMgr.GetTable("FashionAdvancedTableMgr").GetRow(fashionId, true)
  return row
end
local getServerUsingFashionId = function(originalFashionId)
  local info = Z.ContainerMgr.CharSerialize.fashion.fashionAdvance[originalFashionId]
  if not info or info.usingAdvanceId == 0 then
    return originalFashionId
  else
    return info.usingAdvanceId
  end
end
local getClientUsingFashionId = function(originalFashionId)
  local fashionId = fashionData:GetAdvanceSelectData(originalFashionId)
  if fashionId then
    return fashionId
  end
end
local createStyleDataList = function(region, fashionIdList)
  local dataList = {}
  local tempDataDict = {}
  local selectFashion = fashionData:GetWear(region)
  for _, fashionId in ipairs(fashionIdList) do
    local wearFashionId = fashionId
    if selectFashion and selectFashion.wearFashionId and selectFashion.fashionId == fashionId then
      wearFashionId = selectFashion.wearFashionId
    else
      local clientUsingFashionId = getClientUsingFashionId(fashionId)
      if clientUsingFashionId then
        wearFashionId = clientUsingFashionId
      else
        wearFashionId = getServerUsingFashionId(fashionId)
      end
    end
    local styleData = {}
    styleData.fashionId = fashionId
    styleData.wearFashionId = wearFashionId
    tempDataDict[fashionId] = styleData
    table.insert(dataList, styleData)
  end
  if not Z.StageMgr.GetIsInLogin() then
    local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Fashion]
    for _, item in pairs(package.items) do
      local itemData = itemTbl.GetRow(item.configId)
      if itemData then
        local relatedFashion = itemData.CorrelationId
        if tempDataDict[relatedFashion] then
          tempDataDict[relatedFashion].isUnlock = true
        end
      end
    end
  end
  return dataList
end
local sortStyleData = function(left, right)
  if not left.isUnlock and right.isUnlock then
    return false
  end
  if left.isUnlock and not right.isUnlock then
    return true
  end
  local leftFashionRow = fashionTbl.GetRow(left.fashionId)
  local rightFashionRow = fashionTbl.GetRow(right.fashionId)
  if leftFashionRow and rightFashionRow and leftFashionRow.SortID ~= rightFashionRow.SortID then
    return leftFashionRow.SortID < rightFashionRow.SortID
  end
  return leftFashionRow.Id > rightFashionRow.Id
end
local checkStyleVisible = function(fashionRow, isShowAllFashion)
  if not isShowAllFashion and fashionRow.IsHide == 1 then
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
local getOriginalFashionId = function(fashionId)
  local row = getFashionAdvanced(fashionId)
  if not row then
    return fashionId
  end
  return row.FashionId
end
local checkNotUnlockShow = function(fashionRow, isShowAllFashion)
  if isShowAllFashion then
    return true
  end
  if not Z.ConditionHelper.CheckCondition(fashionRow.Condition, false) then
    return false
  end
  if fashionRow.NotUnlock <= 0 then
    return true
  end
  if getFashionIsUnlock(fashionRow.Id) then
    return true
  end
  return false
end
local getStyleDataListByRegion = function(region)
  local dataList = {}
  local nullData = {}
  nullData.fashionId = 0
  table.insert(dataList, nullData)
  local fashionId
  local wornFashion = fashionData:GetServerFashionWear(region)
  if wornFashion then
    fashionId = getOriginalFashionId(wornFashion)
    local selectFashion = fashionData:GetWear(region)
    if selectFashion and fashionId == selectFashion.fashionId then
      table.insert(dataList, selectFashion)
    else
      local wearFashionId = wornFashion
      local clientUsingFashionId = getClientUsingFashionId(fashionId)
      if clientUsingFashionId then
        wearFashionId = clientUsingFashionId
      end
      local wornData = {}
      wornData.fashionId = fashionId
      wornData.isUnlock = true
      wornData.wearFashionId = wearFashionId
      table.insert(dataList, wornData)
    end
  end
  local fashionIdList = {}
  for fashionId, fashionRow in pairs(fashionTbl.GetDatas()) do
    local row = getFashionAdvanced(fashionId)
    if not row then
      local wornFashionId = getOriginalFashionId(wornFashion)
      if fashionId ~= wornFashion and fashionId ~= wornFashionId then
        local itemRow = itemTbl.GetRow(fashionId, true)
        if itemRow and itemRow.Type == region and checkStyleVisible(fashionRow, fashionData.IsShowAllFashion) and checkNotUnlockShow(fashionRow, fashionData.IsShowAllFashion) then
          table.insert(fashionIdList, fashionId)
        end
      end
    end
  end
  local needSortList = createStyleDataList(region, fashionIdList)
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
    if data.AttachmentColor then
      wearData.AttachmentColor = data.AttachmentColor
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
  local fashionRow = fashionTbl.GetRow(fashionId, true)
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
  for area = 1, fashionData.AreaCount do
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
local getFashionAttachmentColorZList = function(fashionId)
  local colorList = {}
  local hsv = fashionData:GetFashionAreaColor(fashionId, fashionData.SocksAreaIndex)
  hsv = hsv or Z.ColorHelper.GetDefaultHSV()
  local color = {
    h = hsv.h / 360,
    s = hsv.s / 100,
    v = hsv.v / 100
  }
  local zeroColor = {
    h = 0,
    s = 0,
    v = 0
  }
  colorList[#colorList + 1] = color
  for i = 2, fashionData.AreaCount do
    colorList[#colorList + 1] = zeroColor
  end
  local zList = colorListToZList(colorList)
  zList:Insert(0, Vector3.zero)
  return zList
end
local refreshWearAttr = function()
  local dataList = {}
  for _, region in pairs(E.FashionRegion) do
    local styleData = fashionData:GetWear(region)
    if styleData and styleData.wearFashionId and region ~= E.FashionRegion.WeapoonSkin then
      local fashionId = styleData.wearFashionId
      local data = {}
      data.FashionId = fashionId
      data.ColorZList = getFashionColorZList(fashionId)
      data.AttachmentColor = getFashionAttachmentColorZList(fashionId)
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
local clearOptionList = function()
  fashionData:ClearOptionList()
end
local recordFashionChange = function(isSource)
  local cacheData = {
    wearDict = {},
    colorDict = {}
  }
  local wearDict = fashionData:GetWears()
  if wearDict then
    for region, fashionStyleData in pairs(wearDict) do
      cacheData.wearDict[region] = table.zclone(fashionStyleData)
    end
  end
  local colorDict = fashionData:GetColors()
  if colorDict then
    for fashionId, colorData in pairs(colorDict) do
      cacheData.colorDict[fashionId] = {}
      for area, hsv in pairs(colorData) do
        cacheData.colorDict[fashionId][area] = table.zclone(hsv)
      end
    end
  end
  if isSource then
    fashionData:AddOptionData(cacheData)
  else
    fashionData:SetCurOptionTargetData(cacheData)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionOptionStateChange)
end
local setFashionWear = function(region, styleData, ignoreRecord)
  if not ignoreRecord then
    recordFashionChange(true)
  end
  if styleData and styleData.wearFashionId and styleData.wearFashionId > 0 then
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
  if not ignoreRecord then
    recordFashionChange(false)
  end
end
local refreshFashionHideRegion = function()
  fashionData.HideRegionList = {}
  local tableData = Z.TableMgr.GetTable("FashionTableMgr")
  local wearDict = fashionData:GetWears()
  local settingVM = Z.VMMgr.GetVM("fashion_setting")
  local regionDict = settingVM.GetCurFashionSettingRegionDict()
  for _, data in pairs(wearDict) do
    if data.fashionId and data.fashionId > 0 then
      local row = tableData.GetRow(data.fashionId, true)
      if row and 0 < table.zcount(row.HidePart) then
        for i = 1, #row.HidePart do
          local isHide = regionDict[row.Type] == 2
          fashionData.HideRegionList[row.HidePart[i]] = not isHide
        end
      end
    end
  end
end
local revertFashionWearByRegion = function(region)
  local fashionId = fashionData:GetServerFashionWear(region)
  if fashionId then
    local styleData = {}
    styleData.fashionId = getOriginalFashionId(fashionId)
    styleData.isUnlock = true
    styleData.wearFashionId = fashionId
    setFashionWear(region, styleData)
  else
    setFashionWear(region, nil)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionWearChange)
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
local setFashionColor = function(fashionId, area, hsv, ignoreGm, ignoreRecord)
  if not ignoreRecord then
    recordFashionChange(true)
  end
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
        wearData.AttachmentColor = getFashionAttachmentColorZList(fashionId)
        Z.EventMgr:Dispatch(Z.ConstValue.FashionAttrChange, attrType, wearData)
      end
    end
  end
  if not ignoreGm then
    Z.EventMgr:Dispatch(Z.ConstValue.GM.GMFashionView, fashionId)
  end
  if not ignoreRecord then
    recordFashionChange(false)
  end
end
local showFashionColor = function(fashionId)
  local fashionRow = fashionTbl.GetRow(fashionId)
  if not fashionRow then
    return
  end
  local attrType = resType2WearDataAttr[fashionRow.FashionType]
  if not attrType then
    return
  end
  local wearData = Panda.ZGame.SingleWearData.Rent()
  wearData.FashionID = fashionId
  wearData.BaseColor = getFashionColorZList(fashionId)
  wearData.AttachmentColor = getFashionAttachmentColorZList(fashionId)
  Z.EventMgr:Dispatch(Z.ConstValue.FashionAttrChange, attrType, wearData)
end
local setFashionWearByFashionId = function(wearFashionId, orginalFashionId)
  local fashionRow = Z.TableMgr.GetRow("FashionTableMgr", wearFashionId, true)
  if not fashionRow then
    return
  end
  local fashionId = wearFashionId
  if orginalFashionId then
    fashionId = orginalFashionId
  end
  local styleData = {fashionId = fashionId, wearFashionId = wearFashionId}
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
    if styleData then
      table.insert(wear, styleData.wearFashionId)
      table.insert(fashionIds, styleData.wearFashionId)
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
    Z.TipsVM.ShowTipsLang(ret)
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
    }, true
  end
  local hIndex = 0
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(fashionId)
  if fashionRow then
    local colorRow = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(fashionRow.ColorGroupId)
    if colorRow then
      if colorRow.Type == E.EHueModifiedMode.Board then
        hIndex = hsv.h
        local minS = colorRow.Saturation[1][2]
        local maxS = colorRow.Saturation[1][3]
        hsv.s = Mathf.Clamp(hsv.s, minS, maxS)
        local minV = colorRow.Value[1][2]
        local maxV = colorRow.Value[1][3]
        hsv.v = Mathf.Clamp(hsv.v, minV, maxV)
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
  local socksColorValue, socksColorReset = convertHSVToProtoVector(fashionId, fashionData.SocksAreaIndex)
  local attachmentColor = {
    [1] = socksColorValue
  }
  local attachmentReset = {
    [1] = socksColorReset
  }
  local protoColorDict = {}
  local resetDictData = {}
  for area = 1, fashionData.AreaCount do
    local colorValue, colorReset = convertHSVToProtoVector(fashionId, area)
    protoColorDict[area] = colorValue
    resetDictData[area] = colorReset
  end
  local worldproxy = require("zproxy.world_proxy")
  local ret = worldproxy.FashionSetColor(fashionId, {
    colorDict = protoColorDict,
    resetDict = resetDictData,
    attachmentColor = attachmentColor,
    attachmentReset = attachmentReset
  }, cancelToken)
  if ret == 0 then
    Z.TipsVM.ShowTipsLang(120002)
    Z.EventMgr:Dispatch(Z.ConstValue.FashionColorSave, fashionId)
  else
    Z.TipsVM.ShowTipsLang(ret)
  end
end
local asyncUnlockFashionColor = function(fashionId, colorIndex, cancelToken)
  local worldproxy = require("zproxy.world_proxy")
  local ret = worldproxy.UnlockColor(fashionId, colorIndex, cancelToken)
  if ret == 0 then
    Z.TipsVM.ShowTipsLang(120010)
    Z.EventMgr:Dispatch(Z.ConstValue.FashionColorUnlock, fashionId, colorIndex)
  else
    Z.TipsVM.ShowTipsLang(ret)
  end
end
local asyncSaveAllFashion = function(cancelSource)
  asyncSendFashionWear(cancelSource:CreateToken())
  local saveVM = Z.VMMgr.GetVM("fashion_save_tips")
  local wears = fashionData:GetWears()
  for _, styleData in pairs(wears) do
    local row = getFashionAdvanced(styleData.wearFashionId)
    if not row then
      local fashionId = styleData.wearFashionId
      local areaColorDict = fashionData:GetColor(fashionId)
      for area, hsv in pairs(areaColorDict) do
        if not saveVM.GetFashionAreaColorIsSaved(fashionId, area, hsv) then
          asyncSendFashionColor(fashionId, cancelSource:CreateToken())
          break
        end
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
local checkIsFashionPreview = function(itemid)
  local fashionTableRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(itemid, true)
  if not fashionTableRow then
    return false
  end
  if fashionTableRow.NotUnlock > 0 then
    return false
  end
  if not Z.ConditionHelper.CheckCondition(fashionTableRow.Condition, false) then
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
  data.FashionIdList = fashionIdList
  data.Reason = E.FashionTipsReason.UnlockedWear
  openFashionSystemView(data)
end
local saveFashionDataToFile = function()
  local data = {
    Wear = {},
    Color = {}
  }
  for region, styleData in pairs(fashionData:GetWears()) do
    data.Wear[tostring(region)] = styleData.wearFashionId
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
      fashionData:SetWear(region, {fashionId = fashionId, wearFashionId = fashionId})
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
local applyFashionOptionData = function(cacheData)
  if not cacheData then
    return
  end
  fashionData:SetAllWear({})
  if cacheData.wearDict then
    for region, fashionStyleData in pairs(cacheData.wearDict) do
      setFashionWear(region, fashionStyleData, true)
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionWearChange)
  fashionData:SetAllColor({})
  if cacheData.colorDict then
    for fashionId, colorData in pairs(cacheData.colorDict) do
      for area, hsv in pairs(colorData) do
        setFashionColor(fashionId, area, hsv, false, true)
      end
    end
  end
  refreshWearAttr()
end
local moveEditorOperation = function()
  local list = fashionData:GetOptionList()
  if fashionData.OptionIndex >= #list then
    return
  end
  local optionData = fashionData:GetOptionData(fashionData.OptionIndex + 1)
  if not optionData then
    return
  end
  applyFashionOptionData(optionData.targetData)
  fashionData.OptionIndex = fashionData.OptionIndex + 1
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionOptionStateChange)
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionViewRefresh)
end
local returnEditorOperation = function()
  if fashionData.OptionIndex <= 0 then
    return
  end
  local optionData = fashionData:GetOptionData(fashionData.OptionIndex)
  applyFashionOptionData(optionData.sourceData)
  fashionData.OptionIndex = fashionData.OptionIndex - 1
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionOptionStateChange)
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionViewRefresh)
end
local unlockAdvanceFashion = function(fashionId, cancelToken)
  local worldproxy = require("zproxy.world_proxy")
  local ret = worldproxy.UnlockAdvanceFashion(fashionId, cancelToken)
  if ret == 0 then
    Z.TipsVM.ShowTips(120024)
    return true
  else
    Z.TipsVM.ShowTips(ret)
    return false
  end
end
local getFashionAdvancedIsUnlock = function(originalFashionId, advancedFashionId)
  local info = Z.ContainerMgr.CharSerialize.fashion.fashionAdvance[originalFashionId]
  if info and info.advanceIds then
    for _, id in pairs(info.advanceIds) do
      if advancedFashionId == id then
        return true
      end
    end
  end
  return false
end
local isFashionAdvancedCanUnlock = function(row)
  local itemsVM = Z.VMMgr.GetVM("items")
  for i = 1, #row.Consume do
    local count = itemsVM.GetItemTotalCount(row.Consume[i][1])
    if not count or count < row.Consume[i][2] then
      return false
    end
  end
  return true
end
local setModelAutoLookatCamera = function(model)
  Z.ModelHelper.SetLookAtTransform(model, Z.CameraMgr.MainCamTrans, true)
  model:SetLuaAttrLookAtIgnoreOverLimitPoint(true)
  model:SetLuaAttrLookAtWeightSpeed(0.15)
  model:SetLuaAttrLookAtPosSpeed(0.15)
  model:SetLuaAttrLookAtPosSpeedEnd(0.025)
  model:SetLuaAttrLookAtWeightSpeedEnd(0.015)
  model:SetLuaAttrLookAtEyeOpen(true)
  model:SetLuaAttrLookAtGlobalMode(true)
  model:SetLuaAttrLookAtGlobalModeHeadRate(0.5)
end
local asyncSaveFashionTryOn = function(fashionId, advanceFashionId, token)
  local worldproxy = require("zproxy.world_proxy")
  local ret = worldproxy.SaveFashionTryOn(fashionId, advanceFashionId, token)
  return ret
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
  GetFashionIsUnlock = getFashionIsUnlock,
  GetFashionRegion = getFashionRegion,
  GetStyleDataListByRegion = getStyleDataListByRegion,
  GetRegionName = getRegionName,
  SetFashionColor = setFashionColor,
  ShowFashionColor = showFashionColor,
  SetFashionWear = setFashionWear,
  GetOriginalFashionId = getOriginalFashionId,
  GetFashionAdvanced = getFashionAdvanced,
  WearDataListToZList = wearDataListToZList,
  RefreshFashionHideRegion = refreshFashionHideRegion,
  RevertFashionWearByRegion = revertFashionWearByRegion,
  RevertFashionColorByFashionIdAndArea = revertFashionColorByFashionIdAndArea,
  RevertAllFashionWear = revertAllFashionWear,
  SaveFashionDataToFile = saveFashionDataToFile,
  LoadFashionDataFromFile = loadFashionDataFromFile,
  RefreshWearAttr = refreshWearAttr,
  CheckIsFashion = checkIsFashion,
  CheckIsFashionPreview = checkIsFashionPreview,
  GotoFashionView = gotoFashionView,
  GotoFashionListView = gotoFashionListView,
  CheckStyleVisible = checkStyleVisible,
  AsyncRefreshPersonalZoneFashionScore = asyncRefreshPersonalZoneFashionScore,
  SetFashionWearByFashionId = setFashionWearByFashionId,
  GetFashionAdvancedIsUnlock = getFashionAdvancedIsUnlock,
  IsFashionAdvancedCanUnlock = isFashionAdvancedCanUnlock,
  ClearOptionList = clearOptionList,
  RecordFashionChange = recordFashionChange,
  MoveEditorOperation = moveEditorOperation,
  ReturnEditorOperation = returnEditorOperation,
  UnlockAdvanceFashion = unlockAdvanceFashion,
  SetModelAutoLookatCamera = setModelAutoLookatCamera,
  GetServerUsingFashionId = getServerUsingFashionId,
  AsyncSaveFashionTryOn = asyncSaveFashionTryOn
}
return ret
