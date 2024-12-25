local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.tagId
    container.__data__.tagId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("tagId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.title
    container.__data__.title = br.ReadString(buffer)
    container.Watcher:MarkDirty("title", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.content
    container.__data__.content = br.ReadString(buffer)
    container.Watcher:MarkDirty("content", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.iconId
    container.__data__.iconId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("iconId", last)
  end,
  [5] = function(container, buffer, watcherList)
    container.position:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("position", {})
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
  if not pbData.tagId then
    container.__data__.tagId = 0
  end
  if not pbData.title then
    container.__data__.title = ""
  end
  if not pbData.content then
    container.__data__.content = ""
  end
  if not pbData.iconId then
    container.__data__.iconId = 0
  end
  if not pbData.position then
    container.__data__.position = {}
  end
  setForbidenMt(container)
  container.position:ResetData(pbData.position)
  container.__data__.position = nil
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
  ret.tagId = {
    fieldId = 1,
    dataType = 0,
    data = container.tagId
  }
  ret.title = {
    fieldId = 2,
    dataType = 0,
    data = container.title
  }
  ret.content = {
    fieldId = 3,
    dataType = 0,
    data = container.content
  }
  ret.iconId = {
    fieldId = 4,
    dataType = 0,
    data = container.iconId
  }
  if container.position == nil then
    ret.position = {
      fieldId = 5,
      dataType = 1,
      data = nil
    }
  else
    ret.position = {
      fieldId = 5,
      dataType = 1,
      data = container.position:GetContainerElem()
    }
  end
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    position = require("zcontainer.mark_position").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
