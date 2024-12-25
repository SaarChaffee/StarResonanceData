local FaceDef = require("ui.model.face_define")
local faceData = Z.DataMgr.Get("face_data")
local FaceCommandData = require("ui.model.face_command_data")
local charactorProxy = require("zproxy.grpc_charactor_proxy")
local cjson = require("cjson")
E.EditorOperation = {
  ChangeModel = 1,
  ChangePicture = 2,
  ChangeColor = 3,
  ChangeOpen = 4,
  ChangeOptionValue = 5,
  ChangeFaceOptionData = 6
}
local openFaceGenderView = function()
  local viewConfigKey = "face_gender_window"
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Creation_01, viewConfigKey, function()
    Z.UnrealSceneMgr:SwitchGroupReflection(true)
    Z.UIMgr:OpenView(viewConfigKey)
  end, Z.ConstValue.UnrealSceneConfigPaths.Role)
end
local closeFaceGenderView = function()
  Z.UIMgr:CloseView("face_gender_window")
end
local openFaceCreateView = function()
  local viewConfigKey = "face_create"
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Creation_01, viewConfigKey, function()
    Z.UnrealSceneMgr:SwitchGroupReflection(true)
    Z.UIMgr:OpenView(viewConfigKey)
  end, Z.ConstValue.UnrealSceneConfigPaths.Role)
end
local closeFaceCreateView = function()
  Z.UIMgr:CloseView("face_create")
end
local openFaceSystemView = function(screenX)
  local viewConfigKey = "face_system"
  local viewData = {screenX = screenX}
  Z.UIMgr:OpenView(viewConfigKey, viewData)
end
local closeFaceSystemView = function()
  Z.UIMgr:CloseView("face_system")
end
local openEditView = function()
  local args = {}
  
  function args.EndCallback()
    local viewConfigKey = "face_edit"
    Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Creation_01, viewConfigKey, function()
      Z.UnrealSceneMgr:SwitchGroupReflection(true)
      Z.UIMgr:OpenView(viewConfigKey)
    end, Z.ConstValue.UnrealSceneConfigPaths.Role)
  end
  
  Z.UIMgr:FadeIn(args)
end
local closeEditView = function()
  Z.UIMgr:CloseView("face_edit")
end
local getDefaultActionData = function()
  local actionIdList = Z.Global.RoleEditorShowAction
  local actionInfo = Z.VMMgr.GetVM("action"):GetActionInfo(actionIdList[1])
  return actionInfo
end
local getFeatureDataByFeatureId = function(featureId)
  local scale = 0
  local x = 0
  local y = 0
  local rotation = 0
  local isFlip = false
  local hsv = Z.ColorHelper.GetDefaultHSV()
  if 0 < featureId then
    local row = Z.TableMgr.GetTable("FaceStickerTableMgr").GetRow(featureId)
    if row then
      scale = (row.DefaultScale.X - row.DefaultScale.Y) / (row.DefaultScale.Z - row.DefaultScale.Y)
      x = (row.DefaultPosition.X + 1) / 2
      y = (row.DefaultPosition.Y + 1) / 2
      rotation = (row.DefaultRotate + 180) / 360
      isFlip = false
      local array = row.DefaultColor
      hsv = {
        h = array[1] / 360,
        s = array[2] * 0.01,
        v = array[3] * 0.01
      }
    end
  end
  local data = {}
  local transData = {}
  transData[FaceDef.EAttrParamFaceHandleData.Scale] = scale
  transData[FaceDef.EAttrParamFaceHandleData.X] = x
  transData[FaceDef.EAttrParamFaceHandleData.Y] = y
  transData[FaceDef.EAttrParamFaceHandleData.Rotation] = rotation
  transData[FaceDef.EAttrParamFaceHandleData.IsFlip] = isFlip
  data.TransData = transData
  data.Color = hsv
  return data
end
local getFaceOptionByAttrType = function(attrType, paramIndex)
  if not attrType then
    return
  end
  paramIndex = paramIndex or 1
  local attrData = faceData.FaceDef.ATTR_TABLE[attrType]
  local optionEnum = attrData.OptionList[paramIndex]
  return faceData:GetFaceOptionValue(optionEnum)
end
local setSingleFaceOptionByAttrType = function(attrType, optionValue, paramIndex, isNotify)
  paramIndex = paramIndex or 1
  local attrData = faceData.FaceDef.ATTR_TABLE[attrType]
  local optionEnum = attrData.OptionList[paramIndex]
  faceData:SetFaceOptionValue(optionEnum, optionValue)
  if isNotify then
    local attrVM = Z.VMMgr.GetVM("face_attr")
    attrVM.UpdateFaceAttr(attrType)
  end
end
local setFeatureAssociatedOption = function(attrType, featureId, isNotify)
  if 0 < featureId then
    local row = Z.TableMgr.GetTable("FaceStickerTableMgr").GetRow(featureId)
    if row then
      local defaultScale = (row.DefaultScale.X - row.DefaultScale.Y) / (row.DefaultScale.Z - row.DefaultScale.Y)
      setSingleFaceOptionByAttrType(attrType, defaultScale, faceData.FaceDef.EAttrParamFaceHandleData.Scale, isNotify)
      setSingleFaceOptionByAttrType(attrType, (row.DefaultPosition.X + 1) / 2, faceData.FaceDef.EAttrParamFaceHandleData.X, isNotify)
      setSingleFaceOptionByAttrType(attrType, (row.DefaultPosition.Y + 1) / 2, faceData.FaceDef.EAttrParamFaceHandleData.Y, isNotify)
      setSingleFaceOptionByAttrType(attrType, (row.DefaultRotate + 180) / 360, faceData.FaceDef.EAttrParamFaceHandleData.Rotation, isNotify)
      setSingleFaceOptionByAttrType(attrType, false, faceData.FaceDef.EAttrParamFaceHandleData.IsFlip, isNotify)
      local array = row.DefaultColor
      local hsv = {
        h = array[1] / 360,
        s = array[2] * 0.01,
        v = array[3] * 0.01
      }
      local colorAttr
      if attrType == Z.ModelAttr.EModelFaceFeatureData then
        colorAttr = Z.ModelAttr.EModelFeatureColor
      else
        colorAttr = Z.ModelAttr.EModelDecalColor
      end
      setSingleFaceOptionByAttrType(colorAttr, hsv, 1, isNotify)
    end
  end
end
local setHairOptionDefaultValueIfEmpty = function(attrType, isNotify)
  local field
  if attrType == Z.ModelAttr.EModelFrontHair then
    field = "Fhair"
  elseif attrType == Z.ModelAttr.EModelBackHair then
    field = "Bhair"
  else
    return
  end
  local optionEnum = faceData.FaceDef.ATTR_TABLE[attrType].OptionList[1]
  if faceData:GetFaceOptionValue(optionEnum) == 0 then
    local modelId = faceData.ModelId
    local row = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(modelId)
    if row then
      local templateVM = Z.VMMgr.GetVM("face_template")
      local value = templateVM.GetModelTblResId(row, field)
      setSingleFaceOptionByAttrType(attrType, value, 1, isNotify)
    end
  end
end
local setSamePupilAreaColor = function(attrType, isNotify)
  local templateVM = Z.VMMgr.GetVM("face_template")
  local baseColor = getFaceOptionByAttrType(attrType, 1)
  local attrData = faceData.FaceDef.ATTR_TABLE[attrType]
  for i = 1, 4 do
    local areaOption = attrData.OptionList[i]
    local initHSV = templateVM.GetFaceOptionInitValueByModelId(faceData.ModelId, areaOption)
    setSingleFaceOptionByAttrType(attrType, {
      h = baseColor.h,
      s = baseColor.s,
      v = initHSV.v
    }, i, isNotify)
  end
end
local refreshBeardByFaceShapeId = function(faceShapeId, isNotify)
  local curBeard = faceData:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "BeardID"))
  if curBeard <= 0 then
    return
  end
  local row = Z.TableMgr.GetTable("FaceTableMgr").GetRow(curBeard)
  if row and 0 < row.FaceShapeId and row.FaceShapeId ~= faceShapeId then
    local bindBeard = faceData:GetBindBeard(faceShapeId, row.Number)
    setSingleFaceOptionByAttrType(Z.ModelAttr.EModelHeadBeard, bindBeard, 1, isNotify)
  end
end
local setAssociatedFaceOption = function(optionEnum, optionValue, isNotify)
  if optionEnum == Z.PbEnum("EFaceDataType", "PupilLeftColor0") then
    if not faceData:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilIsArea")) then
      for area = 2, 4 do
        setSingleFaceOptionByAttrType(Z.ModelAttr.EModelLEyeArrColor, {
          h = optionValue.h,
          s = optionValue.s
        }, area, isNotify)
      end
    end
    if not faceData:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilIsDiff")) then
      setSingleFaceOptionByAttrType(Z.ModelAttr.EModelREyeArrColor, optionValue, 1, isNotify)
      if not faceData:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilIsArea")) then
        for area = 2, 4 do
          setSingleFaceOptionByAttrType(Z.ModelAttr.EModelREyeArrColor, {
            h = optionValue.h,
            s = optionValue.s
          }, area, isNotify)
        end
      end
    end
  elseif optionEnum == Z.PbEnum("EFaceDataType", "PupilRightColor0") then
    if not faceData:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilIsArea")) then
      for area = 2, 4 do
        setSingleFaceOptionByAttrType(Z.ModelAttr.EModelREyeArrColor, {
          h = optionValue.h,
          s = optionValue.s
        }, area, isNotify)
      end
    end
  elseif optionEnum == Z.PbEnum("EFaceDataType", "PupilLeftColor1") then
    if not faceData:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilIsDiff")) then
      setSingleFaceOptionByAttrType(Z.ModelAttr.EModelREyeArrColor, optionValue, 2, isNotify)
    end
  elseif optionEnum == Z.PbEnum("EFaceDataType", "PupilLeftColor2") then
    if not faceData:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilIsDiff")) then
      setSingleFaceOptionByAttrType(Z.ModelAttr.EModelREyeArrColor, optionValue, 3, isNotify)
    end
  elseif optionEnum == Z.PbEnum("EFaceDataType", "PupilLeftColor3") then
    if not faceData:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilIsDiff")) then
      setSingleFaceOptionByAttrType(Z.ModelAttr.EModelREyeArrColor, optionValue, 4, isNotify)
    end
  elseif optionEnum == Z.PbEnum("EFaceDataType", "PupilIsDiff") then
    if not optionValue then
      for i = 1, 4 do
        local leftAreaColor = getFaceOptionByAttrType(Z.ModelAttr.EModelLEyeArrColor, i)
        setSingleFaceOptionByAttrType(Z.ModelAttr.EModelREyeArrColor, leftAreaColor, i, isNotify)
      end
    end
  elseif optionEnum == Z.PbEnum("EFaceDataType", "PupilIsArea") then
    if not optionValue then
      setSamePupilAreaColor(Z.ModelAttr.EModelLEyeArrColor, isNotify)
      setSamePupilAreaColor(Z.ModelAttr.EModelREyeArrColor, isNotify)
    end
  elseif optionEnum == Z.PbEnum("EFaceDataType", "FeatureOneID") then
    setFeatureAssociatedOption(Z.ModelAttr.EModelFaceFeatureData, optionValue, isNotify)
  elseif optionEnum == Z.PbEnum("EFaceDataType", "FeatureTwoID") then
    setFeatureAssociatedOption(Z.ModelAttr.EModelFaceDecalData, optionValue, isNotify)
  elseif optionEnum == Z.PbEnum("EFaceDataType", "HairID") then
    if 0 < optionValue then
      setSingleFaceOptionByAttrType(Z.ModelAttr.EModelFrontHair, 0, 1, isNotify)
      setSingleFaceOptionByAttrType(Z.ModelAttr.EModelBackHair, 0, 1, isNotify)
      setSingleFaceOptionByAttrType(Z.ModelAttr.EModelDullHair, 0, 1, isNotify)
    end
  elseif optionEnum == Z.PbEnum("EFaceDataType", "FrontHairID") then
    if 0 < optionValue then
      setHairOptionDefaultValueIfEmpty(Z.ModelAttr.EModelBackHair, isNotify)
      setSingleFaceOptionByAttrType(Z.ModelAttr.EModelHairWearId, 0, 1, isNotify)
    end
  elseif optionEnum == Z.PbEnum("EFaceDataType", "BackHairID") then
    if 0 < optionValue then
      setHairOptionDefaultValueIfEmpty(Z.ModelAttr.EModelFrontHair, isNotify)
      setSingleFaceOptionByAttrType(Z.ModelAttr.EModelHairWearId, 0, 1, isNotify)
    end
  elseif optionEnum == Z.PbEnum("EFaceDataType", "DullHairID") then
    if 0 < optionValue then
      setHairOptionDefaultValueIfEmpty(Z.ModelAttr.EModelBackHair, isNotify)
      setHairOptionDefaultValueIfEmpty(Z.ModelAttr.EModelFrontHair, isNotify)
      setSingleFaceOptionByAttrType(Z.ModelAttr.EModelHairWearId, 0, 1, isNotify)
    end
  elseif optionEnum == Z.PbEnum("EFaceDataType", "FaceShapeID") then
    refreshBeardByFaceShapeId(optionValue, isNotify)
  end
end
local setFaceOptionByAttrType = function(attrType, optionValue, paramIndex)
  paramIndex = paramIndex or 1
  local attrData = faceData.FaceDef.ATTR_TABLE[attrType]
  local optionEnum = attrData.OptionList[paramIndex]
  setSingleFaceOptionByAttrType(attrType, optionValue, paramIndex, true)
  setAssociatedFaceOption(optionEnum, optionValue, true)
end
local setPupilOffsetV = function(attrType, offset)
  local templateVM = Z.VMMgr.GetVM("face_template")
  local attrData = faceData.FaceDef.ATTR_TABLE[attrType]
  for i = 1, 4 do
    local areaOption = attrData.OptionList[i]
    local initHSV = templateVM.GetFaceOptionInitValueByModelId(faceData.ModelId, areaOption)
    setSingleFaceOptionByAttrType(attrType, {
      v = initHSV.v + offset
    }, i, true)
  end
end
local resetToServerData = function(attrType, paramIndex)
  paramIndex = paramIndex or 1
  local attrData = faceData.FaceDef.ATTR_TABLE[attrType]
  local optionEnum = attrData.OptionList[paramIndex]
  local option = faceData:GetFaceOptionByEnum(optionEnum)
  local serverValue = faceData:GetFaceOptionValueByEnum(optionEnum)
  if option and not option:IsEqualTo(serverValue) then
    setFaceOptionByAttrType(attrType, serverValue, paramIndex)
  else
    faceData:SetFaceOptionValue(optionEnum, serverValue)
    local attrVM = Z.VMMgr.GetVM("face_attr")
    attrVM.UpdateFaceAttr(attrType)
  end
end
local getDefaultEquipZList = function(gender)
  local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")
  local equipTbl = Z.TableMgr.GetTable("EquipTableMgr")
  local zList = ZUtil.Pool.Collections.ZList_Panda_ZGame_SingleWearData.Rent()
  local initialItemList = Z.Global.FaceEquipment
  for _, itemConfigId in ipairs(initialItemList) do
    local itemRow = itemTbl.GetRow(itemConfigId)
    if itemRow and itemRow.Type >= 200 and itemRow.Type < 300 then
      local equipRow = equipTbl.GetRow(itemConfigId)
      if equipRow then
        local fashionId = gender == Z.PbEnum("EGender", "GenderMale") and equipRow.FashionMId or equipRow.FashionFId
        local wearData = Panda.ZGame.SingleWearData.Rent()
        wearData.FashionID = fashionId
        zList:Add(wearData)
      end
    end
  end
  return zList
end
local getEmotionOptions = function()
  local options = {}
  local emotionGroup = string.split(Z.Global.RoleEditorShowFacial, "|")
  for i = 1, #emotionGroup do
    local emotionIdList = string.split(emotionGroup[i], "=")
    options[i] = {
      emotionIdList[2],
      emotionIdList[4],
      emotionIdList[6]
    }
  end
  return options
end
local getFaceSaveCostData = function()
  local dataList = Z.Global.FaceSaveItem
  if #dataList == 2 then
    local data = {
      ItemId = dataList[1],
      Num = dataList[2]
    }
    return data
  else
    logError("Global\232\161\168 FaceSaveItem \233\133\141\231\189\174\233\148\153\232\175\175")
  end
end
local getUsedLockFaceOptionList = function()
  local optionList = {}
  for _, option in pairs(faceData.FaceOptionDict) do
    if option:GetOptionValueType() == faceData.FaceDef.EOptionValueType.Id then
      local faceId = option:GetValue()
      if 0 < faceId and not faceData:GetFaceStyleItemIsUnlocked(faceId) then
        table.insert(optionList, option)
      end
    end
  end
  table.sort(optionList, function(a, b)
    return a:GetValue() < b:GetValue()
  end)
  return optionList
end
local getSendFaceOptionEnumList = function()
  local modelId = faceData.ModelId
  local templateVM = Z.VMMgr.GetVM("face_template")
  local changedEnumSet = {}
  if not Z.StageMgr.GetIsInLogin() then
    local faceServerData = Z.ContainerMgr.CharSerialize.charBase.faceData
    for optionEnum, option in pairs(faceData.FaceOptionDict) do
      if faceServerData.faceInfo[optionEnum] ~= nil then
        if faceServerData.faceInfo[optionEnum] ~= option:GetProtoValue() then
          changedEnumSet[optionEnum] = true
        end
      elseif faceServerData.colorInfo[optionEnum] ~= nil then
        local value = faceServerData.colorInfo[optionEnum]
        local curValue = option:GetProtoValue()
        if curValue.x ~= value.x or curValue.y ~= value.y or curValue.z ~= value.z then
          changedEnumSet[optionEnum] = true
        end
      else
        local initValue = templateVM.GetFaceOptionInitValueByModelId(modelId, optionEnum)
        if not option:IsEqualTo(initValue) then
          changedEnumSet[optionEnum] = true
        end
      end
    end
    local highlightsOneOpenEnum = Z.PbEnum("EFaceDataType", "HairOneIsHighlights")
    if not faceData:GetFaceOptionValue(highlightsOneOpenEnum) and faceServerData.faceInfo[highlightsOneOpenEnum] ~= 1 then
      changedEnumSet[Z.PbEnum("EFaceDataType", "HairOneHighlightsColor")] = nil
    end
    local highlightsTwoOpenEnum = Z.PbEnum("EFaceDataType", "HairTwoIsHighlights")
    if not faceData:GetFaceOptionValue(highlightsTwoOpenEnum) and faceServerData.faceInfo[highlightsTwoOpenEnum] ~= 1 then
      changedEnumSet[Z.PbEnum("EFaceDataType", "HairTwoHighlightsColor")] = nil
    end
  else
    for optionEnum, option in pairs(faceData.FaceOptionDict) do
      local initValue = templateVM.GetFaceOptionInitValueByModelId(modelId, optionEnum)
      if not option:IsEqualTo(initValue) then
        changedEnumSet[optionEnum] = true
      end
    end
  end
  local tempSet = table.zclone(changedEnumSet)
  for _, attrData in pairs(FaceDef.ATTR_TABLE) do
    for _, checkingEnum in ipairs(attrData.OptionList) do
      if changedEnumSet[checkingEnum] then
        for _, optionEnum in ipairs(attrData.OptionList) do
          tempSet[optionEnum] = true
        end
        break
      end
    end
  end
  return table.zkeys(tempSet)
end
local getOptionProtoValue = function(optionEnum)
  local targetEnum = optionEnum
  if optionEnum == Z.PbEnum("EFaceDataType", "HairOneHighlightsColor") and not faceData:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "HairOneIsHighlights")) then
    targetEnum = Z.PbEnum("EFaceDataType", "HairColorBase")
  end
  if optionEnum == Z.PbEnum("EFaceDataType", "HairTwoHighlightsColor") and not faceData:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "HairTwoIsHighlights")) then
    targetEnum = Z.PbEnum("EFaceDataType", "HairColorBase")
  end
  local option = faceData.FaceOptionDict[targetEnum]
  if option then
    return option:GetProtoValue()
  end
end
local convertOptionDictToProtoData = function()
  local ret = {
    faceInfo = {},
    colorInfo = {},
    height = faceData.Height
  }
  local sendList = getSendFaceOptionEnumList()
  for _, optionEnum in ipairs(sendList) do
    local value = getOptionProtoValue(optionEnum)
    if value ~= nil then
      if type(value) == "table" then
        ret.colorInfo[optionEnum] = value
      else
        ret.faceInfo[optionEnum] = value
      end
    end
  end
  return ret
end
local clampValue = function(value, min, max)
  value = math.max(value, min)
  value = math.min(value, max)
  return value
end
local checkUseDefaultValue = function(optionEnum, modeTableRow, faceOptionTableData, faceTableData, colorGroupTableData, faceMenuVM, templateVM, sourceValue, checkUnlock)
  local useValue = sourceValue
  local useDefault = false
  local optionRow = faceOptionTableData.GetRow(optionEnum, true)
  if not optionRow then
    return useValue, useDefault
  end
  if optionRow.Option == faceData.FaceDef.EOptionValueType.Id then
    if 0 < sourceValue then
      local tableRow = faceTableData.GetRow(sourceValue, true)
      if not tableRow or not faceMenuVM.CheckStyleIsAllowUse(tableRow, checkUnlock) then
        local field
        if optionEnum == Z.PbEnum("EFaceDataType", "FrontHairID") then
          field = "Fhair"
        elseif optionEnum == Z.PbEnum("EFaceDataType", "BackHairID") then
          field = "Bhair"
        end
        if field then
          useValue = templateVM.GetModelTblResId(modeTableRow, field)
        else
          useValue = templateVM.GetFaceOptionInitValue(modeTableRow, optionEnum)
        end
        useDefault = true
      end
    end
  elseif optionRow.Option == faceData.FaceDef.EOptionValueType.Float then
  elseif optionRow.Option == faceData.FaceDef.EOptionValueType.HSV and (0 < useValue.h or 0 < useValue.s or 0 < useValue.v) then
    local colorRow = colorGroupTableData.GetRow(optionRow.ColorGroup, true)
    if colorRow then
      if colorRow.Type == 1 then
        local configIndex = 0
        for i, hData in ipairs(colorRow.Hue) do
          local h = hData[2] / 360
          if math.abs(h - useValue.h) < 1.0E-4 then
            configIndex = i
          end
        end
        if 0 < configIndex then
          local minS = colorRow.Saturation[configIndex][3] * 0.01
          local maxS = colorRow.Saturation[configIndex][4] * 0.01
          useValue.s = clampValue(useValue.s, minS, maxS)
          local minV = colorRow.Value[configIndex][3] * 0.01
          local maxV = colorRow.Value[configIndex][4] * 0.01
          useValue.v = clampValue(useValue.v, minV, maxV)
        end
      else
        local minS = colorRow.Saturation[1][2] * 0.01
        local maxS = colorRow.Saturation[1][3] * 0.01
        useValue.s = clampValue(useValue.s, minS, maxS)
        local minV = colorRow.Value[1][2] * 0.01
        local maxV = colorRow.Value[1][3] * 0.01
        useValue.v = clampValue(useValue.v, minV, maxV)
      end
    end
  end
  return useValue, useDefault
end
local useFashionLuaDataWithDefaultValue = function(faceLuaData, ignoreTips, checkUnlock)
  local modeTableRow = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(faceData.ModelId)
  local faceOptionTableData = Z.TableMgr.GetTable("FaceOptionTableMgr")
  local faceTableData = Z.TableMgr.GetTable("FaceTableMgr")
  local colorGroupTableData = Z.TableMgr.GetTable("ColorGroupTableMgr")
  local faceMenuVM = Z.VMMgr.GetVM("face_menu")
  local templateVM = Z.VMMgr.GetVM("face_template")
  local useDefault = false
  for optionEnum, value in pairs(faceLuaData) do
    optionEnum = tonumber(optionEnum)
    local useValue, default = checkUseDefaultValue(optionEnum, modeTableRow, faceOptionTableData, faceTableData, colorGroupTableData, faceMenuVM, templateVM, value, checkUnlock)
    useDefault = useDefault or default
    faceData:SetFaceOptionValue(optionEnum, useValue)
  end
  if useDefault and not ignoreTips then
    Z.TipsVM.ShowTips(120018)
  end
end
local updateFaceDataByContainerData = function()
  faceData.Gender = Z.ContainerMgr.CharSerialize.charBase.gender
  faceData.BodySize = Z.ContainerMgr.CharSerialize.charBase.bodySize
  faceData.ModelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
  faceData.FaceState = E.FaceDataState.Edit
  local faceContainer = Z.ContainerMgr.CharSerialize.charBase.faceData
  local modeTableRow = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(faceData.ModelId)
  local faceOptionTableData = Z.TableMgr.GetTable("FaceOptionTableMgr")
  local faceTableData = Z.TableMgr.GetTable("FaceTableMgr")
  local colorGroupTableData = Z.TableMgr.GetTable("ColorGroupTableMgr")
  local faceMenuVM = Z.VMMgr.GetVM("face_menu")
  local templateVM = Z.VMMgr.GetVM("face_template")
  templateVM.UpdateOptionDictByModelId(faceData.ModelId, false)
  for optionEnum, value in pairs(faceContainer.faceInfo) do
    local option = faceData.FaceOptionDict[optionEnum]
    if option then
      local curValue = option:GetLocalValue(value)
      local useValue = checkUseDefaultValue(optionEnum, modeTableRow, faceOptionTableData, faceTableData, colorGroupTableData, faceMenuVM, templateVM, curValue, true)
      faceData:SetFaceOptionValueWithoutLimit(optionEnum, useValue)
    end
  end
  for optionEnum, value in pairs(faceContainer.colorInfo) do
    local option = faceData.FaceOptionDict[optionEnum]
    if option then
      local curValue = option:GetLocalValue(value)
      local useValue = checkUseDefaultValue(optionEnum, modeTableRow, faceOptionTableData, faceTableData, colorGroupTableData, faceMenuVM, templateVM, curValue, true)
      faceData:SetFaceOptionValueWithoutLimit(optionEnum, useValue)
    end
  end
end
local checkLocalFaceData = function()
  local modeTableRow = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(faceData.ModelId)
  local faceOptionTableData = Z.TableMgr.GetTable("FaceOptionTableMgr")
  local faceTableData = Z.TableMgr.GetTable("FaceTableMgr")
  local colorGroupTableData = Z.TableMgr.GetTable("ColorGroupTableMgr")
  local faceMenuVM = Z.VMMgr.GetVM("face_menu")
  local templateVM = Z.VMMgr.GetVM("face_template")
  for optionEnum, option in pairs(faceData.FaceOptionDict) do
    local value = option:GetValue()
    if value ~= nil then
      value = checkUseDefaultValue(optionEnum, modeTableRow, faceOptionTableData, faceTableData, colorGroupTableData, faceMenuVM, templateVM, value)
      option:SetValue(value)
    end
  end
end
local asyncSetSeverFaceData = function(cancelToken)
  local worldproxy = require("zproxy.world_proxy")
  checkLocalFaceData()
  local data = convertOptionDictToProtoData()
  local ret = worldproxy.SetFaceData(data, cancelToken)
  if ret == 0 then
    Z.TipsVM.ShowTipsLang(120007)
  else
    logError("[Face] SetFaceData Fail, error = {0}", ret)
  end
end
local saveFaceDataToFile = function()
  local modeTableRow = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(faceData.ModelId)
  local faceOptionTableData = Z.TableMgr.GetTable("FaceOptionTableMgr")
  local faceTableData = Z.TableMgr.GetTable("FaceTableMgr")
  local colorGroupTableData = Z.TableMgr.GetTable("ColorGroupTableMgr")
  local faceMenuVM = Z.VMMgr.GetVM("face_menu")
  local templateVM = Z.VMMgr.GetVM("face_template")
  local data = {}
  for optionEnum, option in pairs(faceData.FaceOptionDict) do
    local value = option:GetValue()
    if value ~= nil then
      value = checkUseDefaultValue(optionEnum, modeTableRow, faceOptionTableData, faceTableData, colorGroupTableData, faceMenuVM, templateVM, value)
      data[optionEnum] = value
    end
  end
  local path = Panda.Utility.PathEx.GetPathWithSaveFilePanel("save", "C:\\", "PandaFaceData", "txt")
  Panda.Utility.FileEx.SaveText(cjson.encode(data), path)
end
local loadFaceDataFromFile = function(path)
  path = path or Panda.Utility.PathEx.GetPathWithOpenFilePanel("open", "C:\\", "txt", "PandaFaceData")
  local content = Panda.Utility.FileEx.ReadText(path)
  local data = cjson.decode(content)
  faceData:ResetFaceOption()
  useFashionLuaDataWithDefaultValue(data)
  Z.EventMgr:Dispatch(Z.ConstValue.FaceOptionAllChange)
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshMenuView)
end
local saveFaceDataToLuaFile = function(path)
  local luaFileName = faceData:GetPlayerGender() .. faceData:GetPlayerBodySize() .. Z.ServerTime:GetServerTime()
  local path = path or Panda.Utility.PathEx.GetPathWithSaveFilePanel("save", "C:\\", luaFileName, "lua")
  local modeTableRow = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(faceData.ModelId)
  local faceOptionTableData = Z.TableMgr.GetTable("FaceOptionTableMgr")
  local faceTableData = Z.TableMgr.GetTable("FaceTableMgr")
  local colorGroupTableData = Z.TableMgr.GetTable("ColorGroupTableMgr")
  local faceMenuVM = Z.VMMgr.GetVM("face_menu")
  local templateVM = Z.VMMgr.GetVM("face_template")
  local data = {}
  for optionEnum, option in pairs(faceData.FaceOptionDict) do
    local value = option:GetValue()
    if value ~= nil then
      value = checkUseDefaultValue(optionEnum, modeTableRow, faceOptionTableData, faceTableData, colorGroupTableData, faceMenuVM, templateVM, value)
      data[optionEnum] = value
    end
  end
  local file = io.open(path, "w")
  local stringData = table.ztostring(data)
  if not file then
    return
  end
  file:write("local FaceRandomData = ", stringData, [[

return FaceRandomData
]])
  Z.CoroUtil.create_coro_xpcall(function()
    io.close(file)
  end)()
end
local stringToTable = function(faceDataStr)
  local faceData = {}
  for enum, value in string.gmatch(faceDataStr, [[
%[([0-9]*)] = ([^,
]+),]]) do
    local enumKey = tonumber(enum)
    if value == "true" then
      faceData[enumKey] = true
    elseif value == "false" then
      faceData[enumKey] = false
    else
      faceData[enumKey] = tonumber(value)
    end
  end
  for enum, value in string.gmatch(faceDataStr, "%[([0-9]*)] = {([^{]+)},") do
    local enumKey = tonumber(enum)
    faceData[enumKey] = {}
    for k, v in string.gmatch(value, [[
%["([h,s,v])"] = ([^,
]+),]]) do
      faceData[enumKey][k] = tonumber(v)
    end
  end
  return faceData
end
local loadFashionLuaData = function()
  local path = Panda.Utility.PathEx.GetPathWithOpenFilePanel("open", "C:\\", "lua", "PandaFaceData")
  local content = Panda.Utility.FileEx.ReadText(path)
  if not content then
    return
  end
  local faceDataFile = stringToTable(content)
  faceData:ResetFaceOption()
  useFashionLuaDataWithDefaultValue(faceDataFile)
  Z.EventMgr:Dispatch(Z.ConstValue.FaceOptionAllChange)
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshMenuView)
end
local loadFashionLuaDataWithPath = function(filePath)
  local gender = 0
  local size = 0
  for fileName in string.gmatch(filePath, "\\([^\\]+).lua") do
    gender = tonumber(string.sub(fileName, 1, 1))
    size = tonumber(string.sub(fileName, 2, 2))
  end
  if faceData:GetPlayerGender() ~= gender or faceData:GetPlayerBodySize() ~= size then
    logError("[Face] loadFaceDataFromFile gender, size different. gender:" .. gender .. " size:" .. size)
    return
  end
  local content = Panda.Utility.FileEx.ReadText(filePath)
  local faceRandomData = stringToTable(content)
  if not faceRandomData then
    return
  end
  faceData:ResetFaceOption()
  useFashionLuaDataWithDefaultValue(faceRandomData)
  Z.EventMgr:Dispatch(Z.ConstValue.FaceOptionAllChange)
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshMenuView)
end
local getLookAtOffsetScale = function(scaleType)
  if scaleType == E.ELookAtScaleType.BodyHeight then
    return 200, 0
  elseif scaleType == E.ELookAtScaleType.ShoeHeight then
    return 0.05, 0
  elseif scaleType == E.ELookAtScaleType.ShoeHeightFace then
    return 0.1, 1
  end
end
local recordFaceEditorListCommand = function(modelAttrList, hotId)
  local command = faceData:GetCurCommand()
  if command and not command:IsAttrChange() then
    command:SetModelAttr(modelAttrList)
  else
    local faceCommandData = FaceCommandData.new(modelAttrList, hotId)
    faceData:RecordFaceEditorCommand(faceCommandData)
  end
end
local recordFaceEditorCommand = function(modelAttr, hotId)
  local modelList
  if modelAttr then
    modelList = {
      [1] = modelAttr
    }
  end
  recordFaceEditorListCommand(modelList, hotId)
end
local moveEditorOperation = function()
  faceData:MoveEditorOperation()
end
local returnEditorOperation = function()
  faceData:ReturnEditorOperation()
end
local loadFashionLuaDataWithFilePath = function(filePathName)
  local data = string.split(filePathName, "/")
  local filePath = data[1]
  local fileName = data[2]
  local gender = tonumber(string.sub(fileName, 1, 1))
  local size = tonumber(string.sub(fileName, 2, 2))
  if faceData:GetPlayerGender() ~= gender or faceData:GetPlayerBodySize() ~= size then
    logError("[Face] loadFaceDataFromFile gender, size different. gender:" .. gender .. " size:" .. size)
    return
  end
  local faceRandomData = require(filePath .. "." .. fileName)
  if not faceRandomData then
    return
  end
  useFashionLuaDataWithDefaultValue(faceRandomData)
  Z.EventMgr:Dispatch(Z.ConstValue.FaceOptionAllChange)
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshMenuView)
end
local isAttrChange = function()
  for optionEnum, option in pairs(faceData.FaceOptionDict) do
    local serverValue = faceData:GetFaceOptionValueByEnum(optionEnum)
    if not option:IsEqualTo(serverValue) then
      return true
    end
  end
  return false
end
local uploadFaceData = function()
  local request = {fileSuffix = ".json"}
  charactorProxy.GetFaceUpToken(request)
end
local upLoadResultFunc = function(url)
  Z.CoroUtil.create_coro_xpcall(function()
    local request = {faceCosUrl = url}
    local ret = charactorProxy.UploadFaceSuccess(request, faceData.CancelSource:CreateToken())
    if ret.errCode == 0 then
      Z.TipsVM.ShowTips(120020)
    else
      Z.TipsVM.ShowTips(ret.errCode)
    end
  end)()
end
local onUploadFaceDataGetTmpToken = function(tmpToken, shortGuid)
  local cosXml = Z.CosXmlRequest.Rent()
  cosXml:InitCosXml(tmpToken.tmpSecretId, tmpToken.tmpSecretKey, tmpToken.region, tmpToken.tmpToken, tmpToken.expiredTime, function(isSuccess)
    if isSuccess then
      upLoadResultFunc(tmpToken.objectKey)
      if faceData.UploadFaceDataSuccess then
        faceData.UploadFaceDataSuccess(shortGuid)
        faceData.UploadFaceDataSuccess = nil
      end
    else
      Z.TipsVM.ShowTips(120021)
    end
    cosXml:Recycle()
  end)
  cosXml.Bucket = tmpToken.bucket
  cosXml.SaveKey = tmpToken.objectKey
  local faceOptionData = {}
  for optionEnum, option in pairs(faceData.FaceOptionDict) do
    local value = option:GetValue()
    if value ~= nil then
      faceOptionData[optionEnum] = value
    end
  end
  local data = {
    faceOptionData = faceOptionData,
    gender = faceData:GetPlayerGender(),
    size = faceData:GetPlayerBodySize()
  }
  local content = cjson.encode(data)
  Z.CosMgr.Instance:TransferUpLoadByte(cosXml, content)
end
local asyncGetFaceUploadData = function(token)
  local ret = charactorProxy.GetFaceUploadData({}, token)
  return ret
end
local getFaceDataUrlReply = function(shareCode, token)
  local request = {
    faceData = {shortGuid = shareCode, fileSuffix = ".json"}
  }
  local ret = charactorProxy.GetFaceDataUrl(request, token)
  return ret
end
local downloadFaceData = function(shareCode, cancelSource, func)
  local ret = getFaceDataUrlReply(shareCode, cancelSource:CreateToken())
  if ret.errCode == 0 then
    if ret.faceDataUrl and ret.faceDataUrl ~= "" then
      local request = Z.HttpRequest.Rent()
      request.Url = ret.faceDataUrl
      Z.HttpMgr:Get(request, cancelSource:CreateToken(), function(response)
        if func then
          func()
        end
        if response == nil or response.HasError or response.Value == "" then
          if response ~= nil then
            response:Recycle()
          end
          request:Recycle()
          Z.TipsVM.ShowTips(120019)
          return
        end
        request:Recycle()
        local data = cjson.decode(response.Value)
        response:Recycle()
        local gender = data.gender
        local size = data.size
        if gender ~= faceData:GetPlayerGender() or size ~= faceData:GetPlayerBodySize() then
          Z.TipsVM.ShowTips(120017)
          return
        end
        recordFaceEditorCommand()
        useFashionLuaDataWithDefaultValue(data.faceOptionData, false, true)
        Z.EventMgr:Dispatch(Z.ConstValue.FaceOptionAllChange)
        Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshMenuView)
      end, function(exception)
        Z.TipsVM.ShowTips(120019)
        if func then
          func()
        end
      end)
    else
      Z.TipsVM.ShowTips(120019)
    end
  else
    Z.TipsVM.ShowTips(120019)
  end
end
local openFaceShareView = function(type)
  Z.UIMgr:OpenView("face_share_popup", type)
end
local ret = {
  OpenFaceGenderView = openFaceGenderView,
  CloseFaceGenderView = closeFaceGenderView,
  OpenFaceCreateView = openFaceCreateView,
  CloseFaceCreateView = closeFaceCreateView,
  OpenFaceSystemView = openFaceSystemView,
  CloseFaceSystemView = closeFaceSystemView,
  OpenEditView = openEditView,
  CloseEditView = closeEditView,
  ConvertOptionDictToProtoData = convertOptionDictToProtoData,
  UpdateFaceDataByContainerData = updateFaceDataByContainerData,
  GetSendFaceOptionEnumList = getSendFaceOptionEnumList,
  AsyncSetSeverFaceData = asyncSetSeverFaceData,
  GetDefaultActionData = getDefaultActionData,
  GetDefaultEquipZList = getDefaultEquipZList,
  GetEmotionOptions = getEmotionOptions,
  GetFaceSaveCostData = getFaceSaveCostData,
  GetUsedLockFaceOptionList = getUsedLockFaceOptionList,
  SetFaceOptionByAttrType = setFaceOptionByAttrType,
  SetAssociatedFaceOption = setAssociatedFaceOption,
  GetFaceOptionByAttrType = getFaceOptionByAttrType,
  SetPupilOffsetV = setPupilOffsetV,
  ResetToServerData = resetToServerData,
  GetFeatureDataByFeatureId = getFeatureDataByFeatureId,
  SaveFaceDataToFile = saveFaceDataToFile,
  LoadFaceDataFromFile = loadFaceDataFromFile,
  GetLookAtOffsetScale = getLookAtOffsetScale,
  SaveFaceDataToLuaFile = saveFaceDataToLuaFile,
  LoadFashionLuaData = loadFashionLuaData,
  LoadFashionLuaDataWithPath = loadFashionLuaDataWithPath,
  LoadFashionLuaDataWithFilePath = loadFashionLuaDataWithFilePath,
  OpenFaceShareView = openFaceShareView,
  OnUploadFaceDataGetTmpToken = onUploadFaceDataGetTmpToken,
  UploadFaceData = uploadFaceData,
  DownloadFaceData = downloadFaceData,
  AsyncGetFaceUploadData = asyncGetFaceUploadData,
  GetFaceDataUrlReply = getFaceDataUrlReply,
  UseFashionLuaDataWithDefaultValue = useFashionLuaDataWithDefaultValue,
  RecordFaceEditorCommand = recordFaceEditorCommand,
  RecordFaceEditorListCommand = recordFaceEditorListCommand,
  MoveEditorOperation = moveEditorOperation,
  ReturnEditorOperation = returnEditorOperation,
  IsAttrChange = isAttrChange
}
return ret
