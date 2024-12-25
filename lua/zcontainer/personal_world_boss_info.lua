local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.score
    container.__data__.score = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("score", last)
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
      local v = require("zcontainer.common_award_info").New()
      v:MergeData(buffer, watcherList)
      container.scoreAwardInfo.__data__[dk] = v
      container.Watcher:MarkMapDirty("scoreAwardInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.scoreAwardInfo.__data__[dk]
      container.scoreAwardInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("scoreAwardInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.scoreAwardInfo.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.common_award_info").New()
        container.scoreAwardInfo.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("scoreAwardInfo", dk, {})
    end
  end,
  [3] = function(container, buffer, watcherList)
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
      local v = require("zcontainer.common_award_info").New()
      v:MergeData(buffer, watcherList)
      container.bossAwardInfo.__data__[dk] = v
      container.Watcher:MarkMapDirty("bossAwardInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.bossAwardInfo.__data__[dk]
      container.bossAwardInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("bossAwardInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.bossAwardInfo.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.common_award_info").New()
        container.bossAwardInfo.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("bossAwardInfo", dk, {})
    end
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.uuid
    container.__data__.uuid = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("uuid", last)
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
  if not pbData.score then
    container.__data__.score = 0
  end
  if not pbData.scoreAwardInfo then
    container.__data__.scoreAwardInfo = {}
  end
  if not pbData.bossAwardInfo then
    container.__data__.bossAwardInfo = {}
  end
  if not pbData.uuid then
    container.__data__.uuid = 0
  end
  setForbidenMt(container)
  container.scoreAwardInfo.__data__ = {}
  setForbidenMt(container.scoreAwardInfo)
  for k, v in pairs(pbData.scoreAwardInfo) do
    container.scoreAwardInfo.__data__[k] = require("zcontainer.common_award_info").New()
    container.scoreAwardInfo[k]:ResetData(v)
  end
  container.__data__.scoreAwardInfo = nil
  container.bossAwardInfo.__data__ = {}
  setForbidenMt(container.bossAwardInfo)
  for k, v in pairs(pbData.bossAwardInfo) do
    container.bossAwardInfo.__data__[k] = require("zcontainer.common_award_info").New()
    container.bossAwardInfo[k]:ResetData(v)
  end
  container.__data__.bossAwardInfo = nil
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
  ret.score = {
    fieldId = 1,
    dataType = 0,
    data = container.score
  }
  if container.scoreAwardInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.scoreAwardInfo) do
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
    ret.scoreAwardInfo = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.scoreAwardInfo = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.bossAwardInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.bossAwardInfo) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 3,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 3,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.bossAwardInfo = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.bossAwardInfo = {
      fieldId = 3,
      dataType = 2,
      data = {}
    }
  end
  ret.uuid = {
    fieldId = 4,
    dataType = 0,
    data = container.uuid
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    scoreAwardInfo = {
      __data__ = {}
    },
    bossAwardInfo = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.scoreAwardInfo)
  setForbidenMt(ret.bossAwardInfo)
  return ret
end
return {New = new}
