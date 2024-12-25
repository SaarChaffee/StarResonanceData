local ret = {
  buffer = nil,
  offset = 0,
  length = 0
}

function ret:ReadInt16()
  local v = string.unpack("i2", self.buffer, self.offset)
  self.offset = self.offset + 2
  return v
end

function ret:ReadInt32()
  local v = string.unpack("i4", self.buffer, self.offset)
  self.offset = self.offset + 4
  return v
end

function ret:ReadInt64()
  local v = string.unpack(">i8", self.buffer, self.offset)
  self.offset = self.offset + 8
  return v
end

function ret:ReadSingle()
  local v = string.unpack("f", self.buffer, self.offset)
  self.offset = self.offset + 4
  return v
end

function ret:MergeMap(dict)
  local add = self:ReadInt32()
  local remove = self:ReadInt32()
  local update = self:ReadInt32()
  for i = 1, add do
    local key = self:ReadInt32()
    local value = self:ReadInt32()
    dict[key] = value
  end
end

return ret
