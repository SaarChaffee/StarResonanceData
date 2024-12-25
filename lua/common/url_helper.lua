local UrlHelper = {}

function UrlHelper.Encode(urlPath)
  if urlPath == nil then
    return ""
  end
  urlPath = string.gsub(urlPath, "([^%w%.%- ])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
  return string.gsub(urlPath, " ", "+")
end

function UrlHelper.Decode(urlPath)
  if urlPath == nil then
    return ""
  end
  urlPath = string.gsub(urlPath, "%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end)
  return urlPath
end

return UrlHelper
