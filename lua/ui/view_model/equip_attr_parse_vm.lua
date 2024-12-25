local getAttrTipsColorTag = function(value, minVal, maxVal)
  local p = (value - minVal) / (maxVal - minVal)
  local colorArea = Z.Global.EquipStyleEffectColor
  local level1 = colorArea[2][1] / 10000
  local level2 = colorArea[2][2] / 10000
  if p < level1 then
    return E.TextStyleTag.TipsTitleMain, E.AttrTipsColorTag.AttrGray
  elseif p < level2 then
    return E.TextStyleTag.TipsViolet, E.AttrTipsColorTag.Purple
  else
    return E.TextStyleTag.TipsYellow, E.AttrTipsColorTag.Orange
  end
end
local getAttrEquipLibType = function(type)
  local types = Z.Global.EquipLibType
  if types[type] then
    return Lang(types[type])
  end
  return nil
end
local getEquipAttrTipsAndFormValues = function(attrId, curValue, nextValue)
  local fightAttrParseVm = Z.VMMgr.GetVM("fight_attr_parse")
  local tip = fightAttrParseVm.ParseFightAttrTips(attrId, curValue)
  local v1 = curValue
  local v2 = curValue
  tip = string.zreplace(tip, v1, "")
  return tip, v1, v2
end
local getEquipBaseAttrTips = function(equipAttr, forceApplySymbol)
  if not equipAttr or not equipAttr.basicAttr then
    return nil
  end
  local fightAttrParseVm = Z.VMMgr.GetVM("fight_attr_parse")
  local equipAttrParseVm = Z.VMMgr.GetVM("equip_attr_parse")
  local tips = {}
  for key, value in pairs(equipAttr.basicAttr) do
    local attrDatas = equipAttrParseVm.GetEquipAttrEffectById(key, value)
    for k, attrData in pairs(attrDatas) do
      local v = attrData.attrValue
      local tip = fightAttrParseVm.ParseFightAttrTips(attrData.attrId, v, forceApplySymbol)
      if v == 0 then
        tip = Z.RichTextHelper.ApplyStyleTag(tip, "ashe3")
      end
      table.insert(tips, {
        attrId = attrData.attrId,
        tip = tip
      })
    end
  end
  table.sort(tips, function(a, b)
    return a.attrId < b.attrId
  end)
  local ret = {}
  for index, value in ipairs(tips) do
    table.insert(ret, value.tip)
  end
  return ret
end
local getEquipExternAttrTips = function(externAttrs, showLimit, hideLibType)
  if not externAttrs then
    return nil
  end
  local fightAttrParseVm = Z.VMMgr.GetVM("fight_attr_parse")
  local buffAttrParseVM = Z.VMMgr.GetVM("buff_attr_parse")
  local ret = {}
  local tips = {}
  local colorTag, colorType
  for key, value in pairs(externAttrs) do
    local str, func
    if value.type == E.AttrInfoType.Buff then
      local values = {}
      for index1, data in pairs(value.attrData) do
        local val = data.attrVal
        values[index1] = {
          val,
          data.attrMin,
          data.attrMax
        }
        colorTag, colorType = getAttrTipsColorTag(val, data.attrMin, data.attrMax)
      end
      if showLimit == nil then
        showLimit = true
      end
      str = buffAttrParseVM.ParseBufferTips(value.attrId, values, showLimit)
    elseif value.type == E.AttrInfoType.Attr then
      for index2, data in pairs(value.attrData) do
        local val = data.attrVal
        if durability == 0 then
          val = 0
        end
        str = fightAttrParseVm.ParseFightAttrTips(value.attrId, val)
        func = fightAttrParseVm.GetFormatFunc(value.attrId)
        if data.attrMin == data.attrMax then
          showLimit = false
        end
        if showLimit then
          local min = data.attrMin
          local max = data.attrMax
          if func then
            min = func(data.attrMin, true)
            max = func(data.attrMax, true)
          end
          if min == max then
            str = string.zconcat(str, "(", min, "", "", ")")
          else
            str = string.zconcat(str, "(", min, "~", max, ")")
          end
        end
        colorTag, colorType = getAttrTipsColorTag(val, data.attrMin, data.attrMax)
      end
    end
    local libType = getAttrEquipLibType(value.libType)
    if libType and hideLibType ~= E.AttrInfoType.All and value.type ~= hideLibType then
      str = string.zconcat("\227\128\144", libType, "\227\128\145", str)
    end
    str = Z.RichTextHelper.ApplyStyleTag(str, colorTag)
    str = Z.TableMgr.DecodeLineBreak(str)
    table.insert(tips, {
      attrType = value.type,
      attrId = value.attrId,
      tip = str,
      colorType = colorType
    })
  end
  table.sort(tips, function(a, b)
    if a.attrType == 1 and a.attrType == 2 then
      return true
    elseif a.attrType == 2 and a.attrType == 1 then
      return false
    end
    return a.attrId < b.attrId
  end)
  for index, value in ipairs(tips) do
    local tempTb = {}
    tempTb.tip = value.tip
    tempTb.colorType = value.colorType
    table.insert(ret, tempTb)
  end
  return ret
end
local setEquipExternAttrTipsImgColor = function(unit, mode)
end
local getEquipEffectDetiles = function(equipConfigId, effectDetileId)
  local equipTableRow = Z.TableMgr.GetTable("EquipTableMgr").GetRow(equipConfigId)
  if not equipTableRow then
    return
  end
  local fightAttrParseVm = Z.VMMgr.GetVM("fight_attr_parse")
  local buffAttrParseVM = Z.VMMgr.GetVM("buff_attr_parse")
  local equipEffectDetileTableMgr = Z.TableMgr.GetTable("EquipEffectDetileTableMgr")
  local ret = {}
  local datas = equipEffectDetileTableMgr.GetDatas()
  for key, equipEffectDetileTable in pairs(datas) do
    if equipEffectDetileTable.EffectLibID == effectDetileId then
      for key, value in ipairs(equipEffectDetileTable.EquipPart) do
        if value == equipTableRow.EquipPart then
          local func
          if equipEffectDetileTable.EffectType == 1 then
            func = buffAttrParseVM.ParseBufferTipsAndOnlyShowRange
          else
            func = fightAttrParseVm.ParseFightAttrTipsAndOnlyShowRange
          end
          local rangeValuse = {}
          for _, range in pairs(equipEffectDetileTable.ValueRange) do
            table.insert(rangeValuse, {
              minValue = range[1],
              maxValue = range[2]
            })
          end
          local tip = func(equipEffectDetileTable.EffectConfig, rangeValuse)
          table.insert(ret, tip)
        end
      end
    end
  end
  return ret
end
local getEquipBasgeAttrPreviewTips = function(configId, dungeonId)
  local equipCfgData = Z.TableMgr.GetTable("EquipTableMgr").GetRow(configId)
  local itemTableCfgData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(equipCfgData.Id)
  if equipCfgData == nil or itemTableCfgData == nil then
    return 0
  end
  local basicAttrCfgData = Z.TableMgr.GetTable("BasicAttrTableMgr").GetRow(1)
  local baseCount = 0
  if basicAttrCfgData then
    local basics = basicAttrCfgData["Basic" .. itemTableCfgData.Quality]
    if basics then
      baseCount = basics * 6
    end
  end
  local range = 0
  if dungeonId then
    local dungeonCfgDatas = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
    if dungeonCfgDatas then
      range = (dungeonCfgDatas.DungeonsAttrGrowRange or 0) + range
      if dungeonCfgDatas.AttrGrowRangeBuff then
        local planetData = Z.DataMgr.Get("planetmemory_data")
        local seasonId = planetData:GetNowSeasonId()
        local day = planetData:GetSeasonDay()
        local seasonCfgDatas = Z.TableMgr.GetTable("SeasonDailyTableMgr").GetDatas()
        for id, seasonCfgData in pairs(seasonCfgDatas) do
          if seasonCfgData.Season == seasonId and seasonCfgData.Day == day then
            range = range + (seasonCfgData.GrowRangeAdd or 0)
            break
          end
        end
      end
    end
  end
  local basicAttrGrowCfgData = Z.TableMgr.GetTable("BasicAttrGrowTableMgr").GetRow(range)
  local min = 0
  local max = 0
  if basicAttrGrowCfgData and basicAttrGrowCfgData.AttrGrowRange[1] then
    min = basicAttrGrowCfgData.AttrGrowRange[1][1]
    max = min
    for index, value in ipairs(basicAttrGrowCfgData.AttrGrowRange) do
      if min > value[1] then
        min = value[1]
      end
      if max < value[1] then
        max = value[1]
      end
    end
  end
  local growCount = 0
  if basicAttrCfgData then
    local GrowTimes = basicAttrCfgData["GrowTimes" .. itemTableCfgData.Quality]
    if GrowTimes[1] then
      growCount = growCount + GrowTimes[1] + GrowTimes[2]
    end
  end
  if growCount == 0 then
    growCount = 1
  end
  return string.format(Lang("EquipAttr"), baseCount + min * growCount .. "~" .. baseCount + max * growCount)
end
local checkIsFitProfessionAttrByAttrId = function(attrId)
  local curProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  if curProfessionId == 0 or not curProfessionId then
    return false
  end
  local fightAttrParseVm = Z.VMMgr.GetVM("fight_attr_parse")
  local fightAttrData = fightAttrParseVm.GetFightAttrTableRow(attrId)
  if fightAttrData then
    for index, value in ipairs(fightAttrData.RecomProfessionId) do
      if value == curProfessionId then
        return true
      end
    end
  end
  return false
end
local getEquipAttrEffectById = function(equipAttrLibId, randomValue)
  if randomValue < 0 then
    randomValue = 0
  end
  local tab = {}
  local equipAttrLibTableRow = Z.TableMgr.GetTable("EquipAttrLibTableMgr").GetRow(equipAttrLibId)
  if equipAttrLibTableRow then
    for index, value in ipairs(equipAttrLibTableRow.AttrEffect) do
      local minValue = equipAttrLibTableRow.AttrEffectConfig[index][1] or 0
      local maxValue = equipAttrLibTableRow.AttrEffectConfig[index][2] or 0
      local attrValue = math.floor(randomValue * (maxValue - minValue) / 100 + minValue)
      tab[#tab + 1] = {
        attrType = value[1],
        attrId = value[2],
        attrValue = attrValue,
        IsFitProfessionAttr = checkIsFitProfessionAttrByAttrId(value[2])
      }
    end
    return tab
  end
  return tab
end
local getEquipAttrEffectByAttrDic = function(attrDic)
  local data = {}
  if not attrDic then
    return data
  end
  for k, v in pairs(attrDic) do
    table.zmerge(data, getEquipAttrEffectById(k, v))
  end
  return data
end
local getEquipBasicAttrData = function(configId)
  local tab = {}
  local equipCfgRow = Z.TableMgr.GetTable("EquipTableMgr").GetRow(configId)
  if equipCfgRow then
    local basicAttrId = equipCfgRow.BasicAttrLibId[1]
    if basicAttrId then
      for key, equipAttrLibTableRow in pairs(Z.TableMgr.GetTable("EquipAttrLibTableMgr").GetDatas()) do
        if equipAttrLibTableRow.AttrLibId == basicAttrId then
          for key, value in ipairs(equipAttrLibTableRow.AttrEffect) do
            tab[#tab + 1] = {
              attrType = value[1],
              attrId = value[2],
              attrValue = 0
            }
          end
          return tab
        end
      end
    end
  end
  return tab
end
local checkAttrEffectDataDiff = function(attrid, attrValue, attrEffectDatas)
  for key, attrEffectData in ipairs(attrEffectDatas) do
    if attrEffectData.attrId == attrid then
      if attrEffectData.attrValue == attrValue then
        return 0
      elseif attrValue < attrEffectData.attrValue then
        return 1
      elseif attrValue > attrEffectData.attrValue then
        return -1
      end
    end
  end
  return -1
end
local getEquipExternAttrData = function(configId)
  local tab = {}
  local equipCfgRow = Z.TableMgr.GetTable("EquipTableMgr").GetRow(configId)
  if equipCfgRow then
    return equipCfgRow.AdvancedAttrLibId
  end
  return tab
end
local ret = {
  GetEquipAttrTipsAndFormValues = getEquipAttrTipsAndFormValues,
  GetEquipBaseAttrTips = getEquipBaseAttrTips,
  GetEquipExternAttrTips = getEquipExternAttrTips,
  GetEquipEffectDetileIds = getEquipEffectDetiles,
  SetEquipExternAttrTipsImgColor = setEquipExternAttrTipsImgColor,
  GetEquipBaseAttrPreviewTips = getEquipBasgeAttrPreviewTips,
  GetEquipBasicAttrData = getEquipBasicAttrData,
  GetEquipExternAttrData = getEquipExternAttrData,
  GetEquipAttrEffectById = getEquipAttrEffectById,
  GetEquipAttrEffectByAttrDic = getEquipAttrEffectByAttrDic,
  CheckAttrEffectDataDiff = checkAttrEffectDataDiff
}
return ret
