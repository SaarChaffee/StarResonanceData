local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.communityId
    container.__data__.communityId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("communityId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.homelandId
    container.__data__.homelandId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("homelandId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.buyCount
    container.__data__.buyCount = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("buyCount", last)
  end,
  [4] = function(container, buffer, watcherList)
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
      local v = require("zcontainer.community_homeland_recipe").New()
      v:MergeData(buffer, watcherList)
      container.unlockedRecipes.__data__[dk] = v
      container.Watcher:MarkMapDirty("unlockedRecipes", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockedRecipes.__data__[dk]
      container.unlockedRecipes.__data__[dk] = nil
      container.Watcher:MarkMapDirty("unlockedRecipes", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockedRecipes.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.community_homeland_recipe").New()
        container.unlockedRecipes.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("unlockedRecipes", dk, {})
    end
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.level
    container.__data__.level = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("level", last)
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
  if not pbData.communityId then
    container.__data__.communityId = 0
  end
  if not pbData.homelandId then
    container.__data__.homelandId = 0
  end
  if not pbData.buyCount then
    container.__data__.buyCount = 0
  end
  if not pbData.unlockedRecipes then
    container.__data__.unlockedRecipes = {}
  end
  if not pbData.level then
    container.__data__.level = 0
  end
  setForbidenMt(container)
  container.unlockedRecipes.__data__ = {}
  setForbidenMt(container.unlockedRecipes)
  for k, v in pairs(pbData.unlockedRecipes) do
    container.unlockedRecipes.__data__[k] = require("zcontainer.community_homeland_recipe").New()
    container.unlockedRecipes[k]:ResetData(v)
  end
  container.__data__.unlockedRecipes = nil
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
  ret.communityId = {
    fieldId = 1,
    dataType = 0,
    data = container.communityId
  }
  ret.homelandId = {
    fieldId = 2,
    dataType = 0,
    data = container.homelandId
  }
  ret.buyCount = {
    fieldId = 3,
    dataType = 0,
    data = container.buyCount
  }
  if container.unlockedRecipes ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.unlockedRecipes) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 4,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 4,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.unlockedRecipes = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.unlockedRecipes = {
      fieldId = 4,
      dataType = 2,
      data = {}
    }
  end
  ret.level = {
    fieldId = 5,
    dataType = 0,
    data = container.level
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    unlockedRecipes = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.unlockedRecipes)
  return ret
end
return {New = new}
