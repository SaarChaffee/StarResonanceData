local api = Panda.Module.ZBlobReaderLuaApi
local ri16 = api.ReadInt16
local ru16 = api.ReadUInt16
local ri32 = api.ReadInt32
local ru32 = api.ReadUInt32
local ri64 = api.ReadInt64
local ru64 = api.ReadUInt64
local rbyte = api.ReadByte
local rsbyte = api.ReadSByte
local rf = api.ReadSingle
local rd = api.ReadDouble
local rb = api.ReadBoolean
local rs = api.ReadString
local ReadInt16 = function(buffer)
  local ret, offset = ri16(buffer[1], buffer[2], buffer[3])
  buffer[2] = offset
  return ret
end
local ReadUInt16 = function(buffer)
  local ret, offset = ru16(buffer[1], buffer[2], buffer[3])
  buffer[2] = offset
  return ret
end
local ReadInt32 = function(buffer)
  local ret, offset = ri32(buffer[1], buffer[2], buffer[3])
  buffer[2] = offset
  return ret
end
local ReadUInt32 = function(buffer)
  local ret, offset = ru32(buffer[1], buffer[2], buffer[3])
  buffer[2] = offset
  return ret
end
local ReadInt64 = function(buffer)
  local ret, offset = ri64(buffer[1], buffer[2], buffer[3])
  buffer[2] = offset
  return ret
end
local ReadUInt64 = function(buffer)
  local ret, offset = ru64(buffer[1], buffer[2], buffer[3])
  buffer[2] = offset
  return ret
end
local ReadSByte = function(buffer)
  local ret, offset = rsbyte(buffer[1], buffer[2], buffer[3])
  buffer[2] = offset
  return ret
end
local ReadByte = function(buffer)
  local ret, offset = rbyte(buffer[1], buffer[2], buffer[3])
  buffer[2] = offset
  return ret
end
local ReadBoolean = function(buffer)
  local ret, offset = rb(buffer[1], buffer[2], buffer[3])
  buffer[2] = offset
  return ret
end
local ReadSingle = function(buffer)
  local ret, offset = rf(buffer[1], buffer[2], buffer[3])
  buffer[2] = offset
  return ret
end
local ReadDouble = function(buffer)
  local ret, offset = rd(buffer[1], buffer[2], buffer[3])
  buffer[2] = offset
  return ret
end
local ReadString = function(buffer)
  local ret, offset = rs(buffer[1], buffer[2], buffer[3])
  buffer[2] = offset
  return ret
end
local Count = function(buffer)
  return buffer[3] - buffer[2]
end
local Offset = function(buffer)
  return buffer[2]
end
local SetOffset = function(buffer, offset)
  buffer[2] = offset
end
local BlobReader = {
  ReadInt16 = ReadInt16,
  ReadUInt16 = ReadUInt16,
  ReadInt32 = ReadInt32,
  ReadUInt32 = ReadUInt32,
  ReadInt64 = ReadInt64,
  ReadUInt64 = ReadUInt64,
  ReadByte = ReadByte,
  ReadSByte = ReadSByte,
  ReadSingle = ReadSingle,
  ReadDouble = ReadDouble,
  ReadBoolean = ReadBoolean,
  ReadString = ReadString,
  Count = Count,
  Offset = Offset,
  SetOffset = SetOffset
}
return BlobReader
