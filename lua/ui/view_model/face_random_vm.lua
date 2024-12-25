E.FaceRandomType = {AllRandom = 1, LibraryRadom = 2}
local FaceDef = require("ui.model.face_define")
local randomBool = function(trueProb)
  trueProb = trueProb or 0.5
  return trueProb > math.random()
end
local randomValueInRange = function(min, max)
  local ratio = math.random()
  return min + (max - min) * ratio
end
local randomFaceTableIdByRegion = function(region)
  local faceMenuVM = Z.VMMgr.GetVM("face_menu")
  local faceData = Z.DataMgr.Get("face_data")
  local idList = {}
  local totalWeight = 0
  for id, row in pairs(faceData:GetFaceTableData()) do
    if row.Type == region and 0 < row.Weight and faceMenuVM.CheckStyleIsAllowUse(row, true) and faceData:GetFaceStyleItemIsUnlocked(id) then
      totalWeight = totalWeight + row.Weight
      table.insert(idList, {
        faceId = id,
        weight = row.Weight
      })
    end
  end
  if totalWeight <= 0 then
    return 0
  end
  local randomWeight = math.random(totalWeight)
  local curWeight = 0
  for i = 1, #idList do
    curWeight = curWeight + idList[i].weight
    if randomWeight <= curWeight then
      return idList[i].faceId
    end
  end
  return 0
end
local randomHSVByColorGroupId = function(id)
  local row = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(id)
  if not row then
    return Z.ColorHelper.GetDefaultHSV()
  end
  local h, s, v
  if row.Type == 1 then
    local randomIndex = math.random(#row.Hue)
    h = row.Hue[randomIndex][2] / 360
    s = row.Saturation[randomIndex][2] / 100
    v = row.Value[randomIndex][2] / 100
  else
    h = math.random()
    s = randomValueInRange(row.Saturation[1][2], row.Saturation[1][3]) / 100
    v = randomValueInRange(row.Value[1][2], row.Value[1][3]) / 100
  end
  return {
    h = h,
    s = s,
    v = v
  }
end
local clampValue = function(value, min, max)
  value = math.max(value, min)
  value = math.min(value, max)
  return value
end
local getLimitedHSVByColorGroupId = function(id, hsv)
  local row = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(id)
  if not row then
    return hsv
  end
  if row.Type == 1 then
    local configIndex = 0
    for i, hData in ipairs(row.Hue) do
      local h = hData[2] / 360
      if math.abs(h - hsv.h) < 1.0E-4 then
        configIndex = i
      end
    end
    if 0 < configIndex then
      local minS = row.Saturation[configIndex][3] / 100
      local maxS = row.Saturation[configIndex][4] / 100
      hsv.s = clampValue(hsv.s, minS, maxS)
      local minV = row.Value[configIndex][3] / 100
      local maxV = row.Value[configIndex][4] / 100
      hsv.v = clampValue(hsv.v, minV, maxV)
    end
  else
    local minS = row.Saturation[1][2] / 100
    local maxS = row.Saturation[1][3] / 100
    hsv.s = clampValue(hsv.s, minS, maxS)
    local minV = row.Value[1][2] / 100
    local maxV = row.Value[1][3] / 100
    hsv.v = clampValue(hsv.v, minV, maxV)
  end
  return hsv
end
local randomHSVWithSpecialS = function(colorGroupId, maxDiff)
  local row = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(colorGroupId)
  if not row then
    return Z.ColorHelper.GetDefaultHSV()
  end
  local hsv
  if row.Type == 1 then
    hsv = randomHSVByColorGroupId(colorGroupId)
  else
    local h = math.random()
    local randomV = randomValueInRange(row.Value[1][2], row.Value[1][3])
    local s = randomValueInRange(0, randomV + maxDiff) / 100
    local v = randomV / 100
    hsv = getLimitedHSVByColorGroupId(colorGroupId, {
      h = h,
      s = s,
      v = v
    })
  end
  return hsv
end
local ECheckRule = {CheckOpen = 10, CheckClose = 11}
local ruleToFunc = {
  [1] = function(optionRow)
    return randomFaceTableIdByRegion(optionRow.Id)
  end,
  [2] = function(optionRow, min, max)
    return randomValueInRange(min / 10, max / 10)
  end,
  [3] = function(optionRow)
    return randomHSVByColorGroupId(optionRow.ColorGroup)
  end,
  [4] = function()
    return true
  end,
  [5] = function()
    return false
  end,
  [101] = function(optionRow, v)
    local hsv = randomHSVByColorGroupId(optionRow.ColorGroup)
    hsv.v = v / 100
    return getLimitedHSVByColorGroupId(optionRow.ColorGroup, hsv)
  end,
  [103] = function(optionRow, optionEnum, vRatio)
    local faceData = Z.DataMgr.Get("face_data")
    local hsv = faceData:GetFaceOptionValue(optionEnum)
    if hsv then
      hsv.v = hsv.v * vRatio / 100
    else
      hsv = Z.ColorHelper.GetDefaultHSV()
    end
    return getLimitedHSVByColorGroupId(optionRow.ColorGroup, hsv)
  end,
  [104] = function(optionRow, maxDiff)
    return randomHSVWithSpecialS(optionRow.ColorGroup, maxDiff)
  end
}
local getValueByRuleArray = function(row, ruleArray)
  local rule = ruleArray[1]
  local randomFunc = ruleToFunc[rule]
  if randomFunc then
    return randomFunc(row, table.unpack(ruleArray, 2))
  else
    logError("[FaceRandom] \230\156\170\230\148\175\230\140\129\231\154\132\233\154\143\230\156\186\232\167\132\229\136\153, rule = {0}", rule)
  end
end
local getOptionEnumListForRandom = function()
  local faceData = Z.DataMgr.Get("face_data")
  local optionTbl = Z.TableMgr.GetTable("FaceOptionTableMgr")
  local priorityDict = {}
  for optionEnum, _ in pairs(faceData.FaceOptionDict) do
    priorityDict[optionEnum] = 1
  end
  for optionEnum, _ in pairs(faceData.FaceOptionDict) do
    local row = optionTbl.GetRow(optionEnum)
    if row then
      local ruleNum = #row.RandomType
      for i = 1, ruleNum - 1 do
        local ruleArray = row.RandomType[i]
        if #ruleArray == 2 then
          local preOption = ruleArray[2]
          priorityDict[preOption] = math.max(priorityDict[optionEnum] + 1, priorityDict[preOption])
        else
          logError("[FaceRandom] \230\156\170\230\148\175\230\140\129\231\154\132\229\137\141\231\189\174\230\157\161\228\187\182\230\160\188\229\188\143, id = {0}", optionEnum)
        end
      end
    end
  end
  local optionEnumList = table.zkeys(faceData.FaceOptionDict)
  table.sort(optionEnumList, function(a, b)
    return priorityDict[a] > priorityDict[b]
  end)
  return optionEnumList
end
local isMeetCheckRule = function(row, openRandomDict)
  local ruleNum = #row.RandomType
  local isAllow = true
  for i = 1, ruleNum - 1 do
    local ruleArray = row.RandomType[i]
    if #ruleArray == 2 then
      local checkRule = ruleArray[1]
      local checkOption = ruleArray[2]
      if checkRule == ECheckRule.CheckOpen then
        if not openRandomDict[checkOption] then
          isAllow = false
          break
        end
      elseif checkRule == ECheckRule.CheckClose then
        if openRandomDict[checkOption] then
          isAllow = false
          break
        end
      else
        logError("[FaceRandom] \230\156\170\230\148\175\230\140\129\231\154\132\229\137\141\231\189\174\230\157\161\228\187\182, rule = {0}", checkRule)
      end
    end
  end
  return isAllow
end
local randomAll = function()
  math.randomseed(os.time())
  local faceData = Z.DataMgr.Get("face_data")
  local templateVM = Z.VMMgr.GetVM("face_template")
  templateVM.UpdateOptionDictByModelId(faceData.ModelId, false)
  local optionTbl = Z.TableMgr.GetTable("FaceOptionTableMgr")
  local openRandomDict = {}
  for optionEnum, _ in pairs(faceData.FaceOptionDict) do
    local row = optionTbl.GetRow(optionEnum)
    if row then
      openRandomDict[optionEnum] = randomBool(row.Random / 100)
    end
  end
  local optionEnumList = getOptionEnumListForRandom()
  local faceVM = Z.VMMgr.GetVM("face")
  for _, optionEnum in ipairs(optionEnumList) do
    local row = optionTbl.GetRow(optionEnum)
    if row and openRandomDict[optionEnum] then
      local isAllow = isMeetCheckRule(row, openRandomDict)
      local value
      if isAllow then
        local ruleNum = #row.RandomType
        value = getValueByRuleArray(row, row.RandomType[ruleNum])
      else
        value = templateVM.GetFaceOptionInitValueByModelId(faceData.ModelId, optionEnum)
      end
      if value ~= nil then
        faceData:SetFaceOptionValue(optionEnum, value)
        faceVM.SetAssociatedFaceOption(optionEnum, value, false)
      end
    end
  end
  for _, optionEnum in ipairs(optionEnumList) do
    local row = optionTbl.GetRow(optionEnum)
    if row and not openRandomDict[optionEnum] and row.Option == faceData.FaceDef.EOptionValueType.Bool then
      faceData:SetFaceOptionValue(optionEnum, false)
      faceVM.SetAssociatedFaceOption(optionEnum, false, false)
    end
  end
  local initHSV = templateVM.GetFaceOptionInitValueByModelId(faceData.ModelId, Z.PbEnum("EFaceDataType", "PupilLeftColor0"))
  faceData:SetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilLeftColor0"), {
    v = initHSV.v
  })
  faceData:SetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilRightColor0"), {
    v = initHSV.v
  })
  Z.EventMgr:Dispatch(Z.ConstValue.FaceOptionAllChange)
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshMenuView)
end
local getRandDataFileName = function(gender, size)
  local faceRandomConfig = require("random.face_random_config")
  if not faceRandomConfig then
    return
  end
  if faceRandomConfig[gender] == nil or faceRandomConfig[gender][size] == nil then
    return
  end
  local index = math.random(1, table.zcount(faceRandomConfig[gender][size]))
  local fileName = faceRandomConfig[gender][size][index]
  return fileName
end
local checkOptionEnumValue = function(faceData, faceOption, faceTable, isCreate, optionEnum, value)
  local optionTable = faceOption.GetRow(optionEnum)
  if not optionTable then
    return false
  end
  if optionTable.Option ~= faceData.FaceDef.EOptionValueType.Id then
    return true
  end
  local faceTable = faceTable.GetRow(value, true)
  if not faceTable then
    return false
  end
  if faceTable.IsHide == 1 then
    return false
  end
  if isCreate and (faceTable.Create == 0 or 0 < #faceTable.Unlock) then
    return false
  end
  return true
end
local applyRandomFaceFile = function(filePathName)
  local faceRandomData = require(filePathName)
  local faceData = Z.DataMgr.Get("face_data")
  local row = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(faceData:GetPlayerModelId())
  if not row then
    return
  end
  local templateVM = Z.VMMgr.GetVM("face_template")
  local faceVm = Z.VMMgr.GetVM("face")
  for optionEnum, _ in pairs(faceData.FaceOptionDict) do
    local value = templateVM.GetFaceOptionInitValue(row, optionEnum)
    faceData:SetFaceOptionValue(optionEnum, value)
    faceVm.SetAssociatedFaceOption(optionEnum, value, false)
  end
  local faceVM = Z.VMMgr.GetVM("face")
  faceVM.UseFashionLuaDataWithDefaultValue(faceRandomData, true, true)
  Z.EventMgr:Dispatch(Z.ConstValue.FaceOptionAllChange)
end
local randomFromLibrary = function()
  local faceData = Z.DataMgr.Get("face_data")
  local templateVM = Z.VMMgr.GetVM("face_template")
  templateVM.UpdateOptionDictByModelId(faceData.ModelId, false)
  local fileName = getRandDataFileName(faceData:GetPlayerGender(), faceData:GetPlayerBodySize())
  if not fileName then
    if Z.GameContext.IsEditor then
      logError("face_random_vm randomFromLibrary randomFileName is nil")
    end
    randomAll()
    return
  end
  applyRandomFaceFile(string.zconcat("random.", fileName))
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceRefreshMenuView)
  if Z.GameContext.IsEditor then
    logGreen("[face] face_random_vm use library fileName" .. fileName)
  end
end
local getFaceRandomType = function()
  math.randomseed(os.time())
  local libraryValue = Z.Global.FaceRandomPR
  local randomValue = math.random(1, 100)
  if libraryValue >= randomValue then
    return E.FaceRandomType.LibraryRadom
  else
    return E.FaceRandomType.AllRandom
  end
end
local randomFace = function()
  local randomType = getFaceRandomType()
  if randomType == E.FaceRandomType.AllRandom then
    randomAll()
  else
    randomFromLibrary()
  end
end
local ret = {RandomFace = randomFace, ApplyRandomFaceFile = applyRandomFaceFile}
return ret
