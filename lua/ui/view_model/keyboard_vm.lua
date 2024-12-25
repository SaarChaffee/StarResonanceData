local addNumber = function(value, addNumber)
  if type(value) == "number" and type(addNumber) == "number" then
    local newValue = value * 10 + addNumber
    return newValue
  end
  return value
end
local delNumber = function(value)
  if type(value) == "number" then
    local newValue = math.floor(value / 10)
    return newValue
  end
  return value
end
local ret = {AddNumber = addNumber, DelNumber = delNumber}
return ret
