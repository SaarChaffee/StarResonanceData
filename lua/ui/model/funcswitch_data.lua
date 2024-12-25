local super = require("ui.model.data_base")
local FuncSwitchData = class("FuncSwitchData", super)

function FuncSwitchData:ctor()
  super.ctor(self)
  self.FuncSwitchData = {}
  self.SwitchTypeCache = {}
end

function FuncSwitchData:CacheAdd(type, funcId)
  if self.SwitchTypeCache[type] == nil then
    self.SwitchTypeCache[type] = {}
  end
  self.SwitchTypeCache[type][funcId] = true
end

function FuncSwitchData:Clear()
  self.FuncSwitchData = {}
  self.SwitchTypeCache = {}
end

return FuncSwitchData
