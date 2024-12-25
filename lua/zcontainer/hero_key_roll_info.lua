local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.type
    container.__data__.type = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("type", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.charId
    container.__data__.charId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("charId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.name
    container.__data__.name = br.ReadString(buffer)
    container.Watcher:MarkDirty("name", last)
  end,
  [4] = function(container, buffer, watcherList)
    container.avatar:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("avatar", {})
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.rollValue
    container.__data__.rollValue = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("rollValue", last)
  end
}
local setForbidenMt = function(t)
  local mt = {
    __index = t.__data__,
    __newindex = function(_, _, _)
      error("__newindex is forbidden for container")
    end,
    __pairs = function(tbl)
      local stateless_iter = function(tbl, k)
        local v
        k, v = next(t.__data__, k)
        if nil ~= v or "__data__" ~= k then
          return k, v
        end
      end
      return stateless_iter, tbl, nil
    end
  }
  setmetatable(t, mt)
end
local resetData = function(container, pbData)
  if not container or not container.__data__ then
    error("container is nil or not container")
  end
  if not pbData then
    return
  end
  container.__data__ = pbData
  if not pbData.type then
    container.__data__.type = 0
  end
  if not pbData.charId then
    container.__data__.charId = 0
  end
  if not pbData.name then
    container.__data__.name = ""
  end
  if not pbData.avatar then
    container.__data__.avatar = {}
  end
  if not pbData.rollValue then
    container.__data__.rollValue = 0
  end
  setForbidenMt(container)
  container.avatar:ResetData(pbData.avatar)
  container.__data__.avatar = nil
end
local mergeData = function(container, buffer, watcherList)
  if not container or not container.__data__ then
    error("container is nil or not container")
  end
  local tag = br.ReadInt32(buffer)
  if tag ~= -2 then
    error("Invalid begin tag:" .. tag)
    return
  end
  local size = br.ReadInt32(buffer)
  if size == -3 then
    return
  end
  local offset = br.Offset(buffer)
  local index = br.ReadInt32(buffer)
  while 0 < index do
    local func = mergeDataFuncs[index]
    if func ~= nil then
      func(container, buffer, watcherList)
    else
      logWarning("Unknown field: " .. index)
      br.SetOffset(buffer, offset + size)
    end
    index = br.ReadInt32(buffer)
  end
  if index ~= -3 then
    error("Invalid end tag:" .. index)
  end
  if watcherList and container.Watcher.isDirty then
    watcherList[#watcherList + 1] = container.Watcher
  end
end
local getContainerElem = function(container)
  if container == nil then
    return nil
  end
  local ret = {}
  ret.type = {
    fieldId = 1,
    dataType = 0,
    data = container.type
  }
  ret.charId = {
    fieldId = 2,
    dataType = 0,
    data = container.charId
  }
  ret.name = {
    fieldId = 3,
    dataType = 0,
    data = container.name
  }
  if container.avatar == nil then
    ret.avatar = {
      fieldId = 4,
      dataType = 1,
      data = nil
    }
  else
    ret.avatar = {
      fieldId = 4,
      dataType = 1,
      data = container.avatar:GetContainerElem()
    }
  end
  ret.rollValue = {
    fieldId = 5,
    dataType = 0,
    data = container.rollValue
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    avatar = require("zcontainer.avatar_info").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
