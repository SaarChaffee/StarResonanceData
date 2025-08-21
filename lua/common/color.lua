local hex2Rgba = function(hexStr)
  local len_ = hexStr and string.len(hexStr) or 0
  local pams_ = {}
  for i = 1, len_, 2 do
    table.insert(pams_, string.sub(hexStr, i, i + 1))
  end
  local colorRgb = {}
  colorRgb.r = tonumber(pams_[1] or "0", 16) or "0"
  colorRgb.g = tonumber(pams_[2] or "0", 16) or "0"
  colorRgb.b = tonumber(pams_[3] or "0", 16) or "0"
  colorRgb.a = tonumber(pams_[4] or "FF", 16) or "0"
  return colorRgb
end
local getDefaultHSV = function()
  return {
    h = 0,
    s = 0,
    v = 0
  }
end
local ret = {GetDefaultHSV = getDefaultHSV, Hex2Rgba = hex2Rgba}
return ret
