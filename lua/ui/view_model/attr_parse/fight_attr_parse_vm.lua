local ret = {}
local numberTool = require("utility.number_tools")
local template = require("zutil.template")
local attrFormatType = {
  Normal = 0,
  Percent = 1,
  Time = 2
}
local numberFormatType = {
  Default = 0,
  MakeNormalFormat = 2,
  MakeNormalAndExpFormat = 3,
  MarkAndPercentFormat = 4,
  MarkAndPercentAndExpFormat = 4
}

function ret.GetFightAttrTableRow(fightAttrId)
  if fightAttrId == nil then
    return nil
  end
  local formatType = fightAttrId % 10
  local configId = fightAttrId - formatType
  local fightTableMgr = Z.TableMgr.GetTable("FightAttrTableMgr")
  local fightattrTableRow = fightTableMgr.GetRow(configId)
  if not fightattrTableRow then
    return nil, nil
  end
  return fightattrTableRow, formatType
end

function ret.GetFormatFunc(attrId)
  if not attrId then
    logError("fightAttrId is nit")
    return numberTool.DefaultFormat
  end
  local fightAttr, formatType = ret.GetFightAttrTableRow(attrId)
  if not fightAttr then
    logError("fightAttrId {0} not find!!!!", attrId)
    return numberTool.DefaultFormat
  end
  local attrNumType = fightAttr.AttrNumType
  local func = numberTool.DefaultFormat
  if attrNumType == attrFormatType.Normal then
    if formatType == numberFormatType.MakeNormalFormat or formatType == numberFormatType.MakeNormalAndExpFormat then
      func = numberTool.MakeNormalFormat
    elseif formatType == numberFormatType.MarkAndPercentFormat or formatType == numberFormatType.MarkAndPercentAndExpFormat then
      func = numberTool.MarkAndPercentFormat
    end
  elseif attrNumType == attrFormatType.Percent then
    func = numberTool.MarkAndPercentFormat
  elseif attrNumType == attrFormatType.Time then
    func = numberTool.MarkAndSecFormat
  end
  return func
end

function ret.ParseFightAttrNumber(attrId, number, notApplySymbol)
  local formatFunc = ret.GetFormatFunc(attrId)
  local str = formatFunc(number, notApplySymbol)
  return str
end

function ret.IsApplyExtraText(attrId)
  local fightattrTableRow, formatType = ret.GetFightAttrTableRow(attrId)
  if not fightattrTableRow then
    return false
  end
  if fightattrTableRow.AttrNumType == 0 and (formatType == 3 or formatType == 5) then
    return true
  end
  return false
end

function ret.ParseFightAttrTips(attrId, value, forceApplySymbol)
  if not attrId then
    logError("fightAttrId is nit")
    return nil
  end
  local fightAttr = ret.GetFightAttrTableRow(attrId)
  if not fightAttr then
    return nil
  end
  local tipTemplate = fightAttr.TipTemplate
  local str = ret.ParseFightAttrNumber(attrId, value)
  if value == 0 and forceApplySymbol then
    str = string.zconcat("+", str)
  end
  if ret.IsApplyExtraText(attrId) then
    str = string.zconcat(Lang("EquipExtraText"), str)
  end
  local view = template.new(tipTemplate)
  view.attr = {value = str}
  return tostring(view)
end

function ret.ParseFightAttrTipsWithValueColor(attrId, value, colorTag)
  if not attrId then
    logError("fightAttrId is nit")
    return nil
  end
  if attrId == 0 then
    logError("fightAttrId is 0")
    return nil
  end
  local str = ret.ParseFightAttrTips(attrId, value)
  return str
end

function ret.ParseFightAttrTipsAndOnlyShowRange(attrId, rangeValuse)
  if not attrId then
    logError("fightAttrId is nit")
    return nil
  end
  local fightAttr = ret.GetFightAttrTableRow(attrId)
  local func = ret.GetFormatFunc(attrId)
  local tipTemplate = fightAttr.TipTemplate
  local minStr = func(rangeValuse[1].minValue, false)
  local maxStr = func(rangeValuse[1].maxValue, false)
  local str
  if minStr == maxStr then
    str = minStr
  else
    str = string.zconcat(minStr, "~", maxStr)
  end
  local view = template.new(tipTemplate)
  view.attr = {value = str}
  return tostring(view)
end

function ret.ParseTalentBasicAttrEffectTips(basicAttrEffectId, basicAttrEffectTableMgr)
  local effectList = {}
  if basicAttrEffectTableMgr == nil then
    basicAttrEffectTableMgr = Z.TableMgr.GetTable("BasicAttrEffectTableMgr")
  end
  local basicAttrEffectTableRow = basicAttrEffectTableMgr.GetRow(basicAttrEffectId)
  if basicAttrEffectTableRow ~= nil then
    local limitStr = ""
    if #basicAttrEffectTableRow.AttrStrengthTable > 0 then
      local str = ret.ParseTalentBasicAttrEffectDes(basicAttrEffectTableRow.AttrStrengthTable)
      if basicAttrEffectTableRow.AttrStrengthMax and 0 < basicAttrEffectTableRow.AttrStrengthMax then
        limitStr = string.format(Lang("EffectUpperLimit"), basicAttrEffectTableRow.AttrStrengthMax)
      end
      table.insert(effectList, string.format(Lang("BasicAttrEffect_1"), str, limitStr))
    end
    if 0 < #basicAttrEffectTableRow.AttrVitalityTable then
      local str = ret.ParseTalentBasicAttrEffectDes(basicAttrEffectTableRow.AttrVitalityTable)
      if basicAttrEffectTableRow.AttrVitalityMax and 0 < basicAttrEffectTableRow.AttrVitalityMax then
        limitStr = string.format(Lang("EffectUpperLimit"), basicAttrEffectTableRow.AttrVitalityMax)
      end
      table.insert(effectList, string.format(Lang("BasicAttrEffect_2"), str, limitStr))
    end
    if 0 < #basicAttrEffectTableRow.AttrDexterityTable then
      local str = ret.ParseTalentBasicAttrEffectDes(basicAttrEffectTableRow.AttrDexterityTable)
      if basicAttrEffectTableRow.AttrDexterityMax and 0 < basicAttrEffectTableRow.AttrDexterityMax then
        limitStr = string.format(Lang("EffectUpperLimit"), basicAttrEffectTableRow.AttrDexterityMax)
      end
      table.insert(effectList, string.format(Lang("BasicAttrEffect_3"), str, limitStr))
    end
    if 0 < #basicAttrEffectTableRow.AttrIntelligenceTable then
      local str = ret.ParseTalentBasicAttrEffectDes(basicAttrEffectTableRow.AttrIntelligenceTable)
      if basicAttrEffectTableRow.AttrIntelligenceMax and 0 < basicAttrEffectTableRow.AttrIntelligenceMax then
        limitStr = string.format(Lang("EffectUpperLimit"), basicAttrEffectTableRow.AttrIntelligenceMax)
      end
      table.insert(effectList, string.format(Lang("BasicAttrEffect_4"), str, limitStr))
    end
    if 0 < #basicAttrEffectTableRow.AttrMindTable then
      local str = ret.ParseTalentBasicAttrEffectDes(basicAttrEffectTableRow.AttrMindTable)
      if basicAttrEffectTableRow.AttrMindMax and 0 < basicAttrEffectTableRow.AttrMindMax then
        limitStr = string.format(Lang("EffectUpperLimit"), basicAttrEffectTableRow.AttrMindMax)
      end
      table.insert(effectList, string.format(Lang("BasicAttrEffect_5"), str, limitStr))
    end
    if 0 < #basicAttrEffectTableRow.AttrObserveTable then
      local str = ret.ParseTalentBasicAttrEffectDes(basicAttrEffectTableRow.AttrObserveTable)
      if basicAttrEffectTableRow.AttrObserveMax and 0 < basicAttrEffectTableRow.AttrObserveMax then
        limitStr = string.format(Lang("EffectUpperLimit"), basicAttrEffectTableRow.AttrObserveMax)
      end
      table.insert(effectList, string.format(Lang("BasicAttrEffect_6"), str, limitStr))
    end
  end
  return table.concat(effectList, "\n")
end

function ret.ParseTalentBasicAttrEffectDes(basicAttrEffectList)
  local str = ""
  for i, fightAttrValue in ipairs(basicAttrEffectList) do
    local fightAttrData = ret.GetFightAttrTableRow(fightAttrValue[1])
    if fightAttrData ~= nil then
      local func = ret.GetFormatFunc(fightAttrValue[1])
      local fightAttrPrecise = numberTool.GetPreciseDecimal(fightAttrValue[2], 2)
      local valueStr = func(fightAttrPrecise, true)
      local tempStr = string.format(" %s %s", Z.RichTextHelper.ApplyStyleTag(valueStr, E.TextStyleTag.TipsGreen), fightAttrData.OfficialName)
      if i ~= 1 then
        str = string.zconcat(str, ",", tempStr)
      else
        str = tempStr
      end
    end
  end
  return str
end

return ret
