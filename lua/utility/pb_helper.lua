local pb = require("pb2")
pb.option("enum_as_value")
pb.option("use_default_values")
local closeNewIndexMetaTable = {
  __newindex = function()
    error("you can't use newindex method in protobuf data")
  end,
  __index = function(self, filedName)
    local ret = rawget(self, filedName)
    if not rawget(self, filedName) then
      error("attempt is visit a not exit field:" .. tostring(filedName))
    end
    return ret
  end
}
local ParseProtoBufToTable = function(msgName, datas)
  local pbTb = pb.decode("bokura." .. msgName, datas)
  setmetatable(pbTb, closeNewIndexMetaTable)
  return pbTb
end
return {ParseProtoBufToTable = ParseProtoBufToTable}
