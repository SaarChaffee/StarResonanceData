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
    return Lang("PositiveNumber", {val = str})
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
    return Lang("PositivePercent", {val = str})
  end
  return Lang("Percent", {val = str})
end

function ret.UnMarkAndPercentFormat(value)
  if value == nil then
    return nil
  end
  local v = value / 100
  local str = ret.removeTrailingZeros(v)
  if 0 < v then
    return Lang("Percent", {val = str})
  end
  return Lang("Percent", {val = str})
end

function ret.MarkAndSecFormat(value, notApplySymbol)
  if value == nil then
    return nil
  end
  local v = value / 1000
  local str = ret.removeTrailingZeros(v)
  if 0 < v and not notApplySymbol then
    return Lang("PositiveSeconds", {val = str})
  end
  return Lang("Seconds", {val = str})
end

function ret.UnMarkAndSecFormat(value)
  if value == nil then
    return nil
  end
  local v = value / 1000
  local str = ret.removeTrailingZeros(v)
  if 0 < v then
    return Lang("Seconds", {val = str})
  end
  return Lang("Seconds", {val = str})
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
  local isNegative = number < 0
  local absNumber = math.abs(number)
  if absNumber < 1000 then
    return number
  end
  local str = tostring(absNumber):reverse():gsub("(%d%d%d)", "%1,"):reverse()
  local char = string.sub(str, 1, 1)
  if char == "," then
    str = string.sub(str, 2)
  end
  return string.zconcat(isNegative and "-" or "", str)
end

function ret.FormatNumberOverTenMillion(number)
  local isNegative = number < 0
  local absNumber = math.abs(number)
  if absNumber < 10000000 then
    return ret.FormatNumberWithCommas(number)
  end
  local intergerPart = math.floor(absNumber / 1000000)
  local interStr = ret.FormatNumberWithCommas(intergerPart)
  local number2 = math.floor(absNumber % 1000000 / 100000)
  local number3 = math.floor(absNumber % 100000 / 10000)
  if number3 ~= 0 then
    return string.zconcat(isNegative and "-" or "", interStr, ".", number2, number3, "M")
  elseif number2 ~= 0 then
    return string.zconcat(isNegative and "-" or "", interStr, ".", number2, "M")
  else
    return string.zconcat(isNegative and "-" or "", interStr, "M")
  end
end

function ret.FormatNumberOverTenThousand(number)
  if number < 10000 then
    return number
  end
  if 1000000 <= number then
    local intergerPart = math.floor(number / 1000000)
    local number2 = math.floor(number % 1000000 / 100000)
    if number2 ~= 0 then
      return string.zconcat(intergerPart, ".", number2, "M")
    end
    return string.zconcat(intergerPart, "M")
  end
  local thousand = math.floor(number / 1000)
  local number2 = math.floor(number % 1000 / 10)
  if number2 ~= 0 then
    return string.zconcat(thousand, ".", number2, "K")
  end
  return string.zconcat(thousand, "k")
end

function ret.DpsFormatNumberOverTenThousand(number)
  if number < 10000 then
    return number
  end
  if 1000000 <= number then
    local intergerPart = math.floor(number / 1000000)
    local number2 = math.floor(number % 1000000 / 10000)
    if number2 ~= 0 then
      return string.zconcat(intergerPart, ".", number2, "M")
    end
    return string.zconcat(intergerPart, "M")
  end
  local thousand = math.floor(number / 1000)
  local number2 = math.floor(number % 1000 / 10)
  if number2 ~= 0 then
    return string.zconcat(thousand, ".", number2, "K")
  end
  return string.zconcat(thousand, "k")
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
