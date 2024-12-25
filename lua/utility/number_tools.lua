local ret = {}

function ret.DefaultFormat(value)
  if value ~= nil then
    return ret.removeTrailingZeros(value)
  end
  return nil
end

function ret.MakeNormalFormat(value, notApplySymbol)
  if value == nil then
    return nil
  end
  local str = ret.removeTrailingZeros(value)
  if 0 < value and not notApplySymbol then
    return string.zconcat("+", str)
  end
  return str
end

function ret.MarkAndPercentFormat(value, notApplySymbol)
  if value == nil then
    return nil
  end
  local v = value / 100
  local str
  str = ret.removeTrailingZeros(v)
  if 0 < v and not notApplySymbol then
    return string.zconcat("+", str, "%")
  end
  return string.zconcat(str, "%")
end

function ret.UnMarkAndPercentFormat(value)
  if value == nil then
    return nil
  end
  local v = value / 100
  local str = ret.removeTrailingZeros(v)
  if 0 < v then
    return string.zconcat(str, "%")
  end
  return string.zconcat(str, "%")
end

function ret.MarkAndSecFormat(value, notApplySymbol)
  if value == nil then
    return nil
  end
  local v = value / 1000
  local str = ret.removeTrailingZeros(v)
  if 0 < v and not notApplySymbol then
    return string.zconcat("+", str, Lang("EquipSecondsText"))
  end
  return string.zconcat(str, Lang("EquipSecondsText"))
end

function ret.UnMarkAndSecFormat(value)
  if value == nil then
    return nil
  end
  local v = value / 1000
  local str = ret.removeTrailingZeros(v)
  if 0 < v then
    return string.zconcat(str, Lang("EquipSecondsText"))
  end
  return string.zconcat(str, Lang("EquipSecondsText"))
end

function ret.removeTrailingZeros(num)
  local str = tostring(num)
  local trimmed = str:gsub("%.0+$", "")
  return trimmed
end

function ret.GetPreciseDecimal(nNum, n)
  if type(nNum) ~= "number" then
    return nNum
  end
  n = n or 0
  n = math.floor(n)
  if n < 0 then
    n = 0
  end
  local nDecimal = 10 ^ n
  local nTemp = math.floor(nNum * nDecimal)
  local nRet = nTemp / nDecimal
  return nRet
end

function ret.FormatNumberWithCommas(number)
  if number < 1000 then
    return number
  end
  local str = tostring(number):reverse():gsub("(%d%d%d)", "%1,"):reverse()
  local char = string.sub(str, 1, 1)
  if char == "," then
    return string.sub(str, 2)
  end
  return str
end

function ret.NumberToK(num)
  local num = tonumber(num)
  if num == nil then
    return num
  end
  if num < 10000 then
    return num
  end
  if 999000 < num then
    return "999k+"
  else
    local number1 = math.floor(num / 1000)
    local number2 = math.floor((num - number1 * 1000) / 100)
    local number3 = math.floor((num - number1 * 1000 - number2 * 100) / 10)
    if 99 < number1 or number2 == 0 and number3 == 0 then
      return number1 .. "k"
    end
    if number1 < 10 then
      return string.zconcat(number1, ".", number2, number3, "k")
    elseif 10 <= number1 and number2 == 0 then
      return string.zconcat(number1, "k")
    end
    return string.zconcat(number1, ".", number2, "k")
  end
end

function ret.Distance(startPos, endPos)
  local dx = endPos.x - startPos.x
  local dy = endPos.y - startPos.y
  local dz = endPos.z - startPos.z
  local distanceStr = math.sqrt(dx * dx + dy * dy + dz * dz)
  return distanceStr
end

return ret
