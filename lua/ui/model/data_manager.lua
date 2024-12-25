local cached_data = {}
local getData = function(name)
  if cached_data[name] == nil then
    local data = require("ui.model." .. name)
    cached_data[name] = data.new()
    cached_data[name]:Init()
  end
  return cached_data[name]
end
local onReconnect = function()
  for key, value in pairs(cached_data) do
    value:OnReconnect()
  end
end
local clear = function()
  for key, value in pairs(cached_data) do
    value:Clear()
  end
end
local unInit = function()
  for key, value in pairs(cached_data) do
    value:UnInit()
  end
  cached_data = {}
end
local onLanguageChange = function()
  for key, value in pairs(cached_data) do
    value:OnLanguageChange()
  end
end
return {
  Get = getData,
  OnReconnect = onReconnect,
  Clear = clear,
  UnInit = unInit,
  OnLanguageChange = onLanguageChange
}
