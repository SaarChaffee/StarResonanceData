local template = require("zutil.template")
local ret = {}
local marknormalHandFuncs = {
  valueHandFunc = Z.NumTools.MakeNormalFormat,
  minValHandFunc = Z.NumTools.MakeNormalFormat,
  maxValHandFunc = Z.NumTools.MakeNormalFormat
}
local unmarknormalHandFuncs = {
  valueHandFunc = Z.NumTools.DefaultFormat,
  minValHandFunc = Z.NumTools.DefaultFormat,
  maxValHandFunc = Z.NumTools.DefaultFormat
}
local markpercentHandFuncs = {
  valueHandFunc = Z.NumTools.MarkAndPercentFormat,
  minValHandFunc = Z.NumTools.MarkAndPercentFormat,
  maxValHandFunc = Z.NumTools.MarkAndPercentFormat
}
local unmarkpercentHandFuncs = {
  valueHandFunc = Z.NumTools.UnMarkAndPercentFormat,
  minValHandFunc = Z.NumTools.UnMarkAndPercentFormat,
  maxValHandFunc = Z.NumTools.UnMarkAndPercentFormat
}
local marktimeHandFuncs = {
  valueHandFunc = Z.NumTools.MarkAndSecFormat,
  minValHandFunc = Z.NumTools.UnMarkAndSecFormat,
  maxValHandFunc = Z.NumTools.UnMarkAndSecFormat
}
local unmarktimeHandFuncs = {
  valueHandFunc = Z.NumTools.UnMarkAndSecFormat,
  minValHandFunc = Z.NumTools.UnMarkAndSecFormat,
  maxValHandFunc = Z.NumTools.UnMarkAndSecFormat
}

function ret.attrHandFunc(index, handFuncs, valueArr, showValueLimit, colorTag, onlyShowRange, args)
  local minVal, maxVal, val, ret
  if onlyShowRange then
    if handFuncs ~= nil and handFuncs.valueHandFunc ~= nil then
      minVal = handFuncs.valueHandFunc(valueArr[index].minValue)
      maxVal = handFuncs.valueHandFunc(valueArr[index].maxValue)
    else
      minVal = valueArr[index].minValue
      maxVal = valueArr[index].maxValue
    end
    if minVal == maxVal then
      return maxVal
    end
    return string.zconcat(minVal, "~", maxVal)
  end
  if handFuncs ~= nil and handFuncs.valueHandFunc ~= nil then
    val = handFuncs.valueHandFunc(valueArr[index][1])
  else
    val = valueArr[index][1]
  end
  if showValueLimit then
    if handFuncs ~= nil and handFuncs.minValHandFunc ~= nil then
      minVal = handFuncs.minValHandFunc(valueArr[index][2])
    else
      minVal = valueArr[index][2]
    end
    if handFuncs ~= nil and handFuncs.maxValHandFunc ~= nil then
      maxVal = handFuncs.maxValHandFunc(valueArr[index][3])
    else
      maxVal = valueArr[index][3]
    end
    if type(args) == "string" and args == "NoAddSymbol" then
      minVal = valueArr[index][2]
      maxVal = valueArr[index][3]
    end
    ret = string.zconcat(val, "(", minVal, "~", maxVal, ")")
  else
    ret = val
  end
  return ret
end

function ret.ParseBufferTips(buffId, valueArr, showValueLimit, colorTag, onlyShowRange)
  if buffId == 0 then
    logError("buff Id is 0")
    return nil
  end
  local buffTableMgr = Z.TableMgr.GetTable("BuffTableMgr")
  local buffTableRow = buffTableMgr.GetRow(buffId, false)
  if not buffTableRow then
    return
  end
  local tableMgr = Z.TableMgr.GetTable("AttrDescriptionMgr")
  local attrDescription = tableMgr.GetRow(buffTableRow.TipsDescription, false)
  if not attrDescription then
    logError("not fing AttrDescriptionTable id is" .. buffTableRow.TipsDescription)
    return nil
  end
  if next(valueArr) == nil then
    return attrDescription.Description
  end
  local view = template.new(attrDescription.Description)
  local decision = {
    marknormal = function(index)
      return ret.attrHandFunc(index, marknormalHandFuncs, valueArr, showValueLimit, colorTag, onlyShowRange, "NoAddSymbol")
    end,
    unmarknormal = function(index)
      return ret.attrHandFunc(index, unmarknormalHandFuncs, valueArr, showValueLimit, colorTag, onlyShowRange)
    end,
    markpercent = function(index)
      return ret.attrHandFunc(index, markpercentHandFuncs, valueArr, showValueLimit, colorTag, onlyShowRange)
    end,
    unmarkpercent = function(index)
      return ret.attrHandFunc(index, unmarkpercentHandFuncs, valueArr, showValueLimit, colorTag, onlyShowRange)
    end,
    marktime = function(index)
      return ret.attrHandFunc(index, marktimeHandFuncs, valueArr, showValueLimit, colorTag, onlyShowRange)
    end,
    unmarktime = function(index)
      return ret.attrHandFunc(index, unmarktimeHandFuncs, valueArr, showValueLimit, colorTag, onlyShowRange)
    end
  }
  view.Decision = decision
  return tostring(view)
end

function ret.ParseBufferTipsWithValueColor(buffId, valueArr, colorTag)
  return ret.ParseBufferTips(buffId, valueArr, false, colorTag)
end

function ret.ParseBufferTipsAndOnlyShowRange(buffId, rangeValueArr)
  return ret.ParseBufferTips(buffId, rangeValueArr, false, nil, true)
end

return ret
