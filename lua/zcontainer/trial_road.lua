local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.passRoom
    container.__data__.passRoom = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("passRoom", last)
    end
  end,
  [2] = function(container, buffer, watcherList)
    local add = br.ReadInt32(buffer)
    local remove = 0
    local update = 0
    if add == -4 then
      return
    end
    if add == -1 then
      add = br.ReadInt32(buffer)
    else
      remove = br.ReadInt32(buffer)
      update = br.ReadInt32(buffer)
    end
    for i = 1, add do
      local dk = br.ReadInt32(buffer)
      local v = require("zcontainer.trial_road_room_target_award").New()
      v:MergeData(buffer, watcherList)
      container.roomTargetAward.__data__[dk] = v
      container.Watcher:MarkMapDirty("roomTargetAward", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.roomTargetAward.__data__[dk]
      container.roomTargetAward.__data__[dk] = nil
      container.Watcher:MarkMapDirty("roomTargetAward", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.roomTargetAward.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.trial_road_room_target_award").New()
        container.roomTargetAward.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("roomTargetAward", dk, {})
    end
  end,
  [3] = function(container, buffer, watcherList)
    container.targetAward:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("targetAward", {})
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
  if not pbData.passRoom then
    container.__data__.passRoom = {}
  end
  if not pbData.roomTargetAward then
    container.__data__.roomTargetAward = {}
  end
  if not pbData.targetAward then
    container.__data__.targetAward = {}
  end
  setForbidenMt(container)
  container.roomTargetAward.__data__ = {}
  setForbidenMt(container.roomTargetAward)
  for k, v in pairs(pbData.roomTargetAward) do
    container.roomTargetAward.__data__[k] = require("zcontainer.trial_road_room_target_award").New()
    container.roomTargetAward[k]:ResetData(v)
  end
  container.__data__.roomTargetAward = nil
  container.targetAward:ResetData(pbData.targetAward)
  container.__data__.targetAward = nil
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
  if container.passRoom ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.passRoom) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.passRoom = {
      fieldId = 1,
      dataType = 3,
      data = data
    }
  else
    ret.passRoom = {
      fieldId = 1,
      dataType = 3,
      data = {}
    }
  end
  if container.roomTargetAward ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.roomTargetAward) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 2,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 2,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.roomTargetAward = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.roomTargetAward = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.targetAward == nil then
    ret.targetAward = {
      fieldId = 3,
      dataType = 1,
      data = nil
    }
  else
    ret.targetAward = {
      fieldId = 3,
      dataType = 1,
      data = container.targetAward:GetContainerElem()
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
    roomTargetAward = {
      __data__ = {}
    },
    targetAward = require("zcontainer.trial_road_target_award").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.roomTargetAward)
  return ret
end
return {New = new}
