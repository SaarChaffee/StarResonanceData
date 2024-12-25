local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
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
      local dv = br.ReadInt32(buffer)
      container.wearInfo.__data__[dk] = dv
      container.Watcher:MarkMapDirty("wearInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.wearInfo.__data__[dk]
      container.wearInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("wearInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.wearInfo.__data__[dk]
      container.wearInfo.__data__[dk] = dv
      container.Watcher:MarkMapDirty("wearInfo", dk, last)
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
      local v = require("zcontainer.fashion_color_info").New()
      v:MergeData(buffer, watcherList)
      container.fashionDatas.__data__[dk] = v
      container.Watcher:MarkMapDirty("fashionDatas", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.fashionDatas.__data__[dk]
      container.fashionDatas.__data__[dk] = nil
      container.Watcher:MarkMapDirty("fashionDatas", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.fashionDatas.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.fashion_color_info").New()
        container.fashionDatas.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("fashionDatas", dk, {})
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
      local v = require("zcontainer.unlock_color_info").New()
      v:MergeData(buffer, watcherList)
      container.UnlockColor.__data__[dk] = v
      container.Watcher:MarkMapDirty("UnlockColor", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.UnlockColor.__data__[dk]
      container.UnlockColor.__data__[dk] = nil
      container.Watcher:MarkMapDirty("UnlockColor", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.UnlockColor.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.unlock_color_info").New()
        container.UnlockColor.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("UnlockColor", dk, {})
    end
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
  if not pbData.wearInfo then
    container.__data__.wearInfo = {}
  end
  if not pbData.fashionDatas then
    container.__data__.fashionDatas = {}
  end
  if not pbData.UnlockColor then
    container.__data__.UnlockColor = {}
  end
  setForbidenMt(container)
  container.wearInfo.__data__ = pbData.wearInfo
  setForbidenMt(container.wearInfo)
  container.__data__.wearInfo = nil
  container.fashionDatas.__data__ = {}
  setForbidenMt(container.fashionDatas)
  for k, v in pairs(pbData.fashionDatas) do
    container.fashionDatas.__data__[k] = require("zcontainer.fashion_color_info").New()
    container.fashionDatas[k]:ResetData(v)
  end
  container.__data__.fashionDatas = nil
  container.UnlockColor.__data__ = {}
  setForbidenMt(container.UnlockColor)
  for k, v in pairs(pbData.UnlockColor) do
    container.UnlockColor.__data__[k] = require("zcontainer.unlock_color_info").New()
    container.UnlockColor[k]:ResetData(v)
  end
  container.__data__.UnlockColor = nil
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
  if container.wearInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.wearInfo) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.wearInfo = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.wearInfo = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.fashionDatas ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.fashionDatas) do
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
    ret.fashionDatas = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.fashionDatas = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.UnlockColor ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.UnlockColor) do
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
    ret.UnlockColor = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.UnlockColor = {
      fieldId = 3,
      dataType = 2,
      data = {}
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
    wearInfo = {
      __data__ = {}
    },
    fashionDatas = {
      __data__ = {}
    },
    UnlockColor = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.wearInfo)
  setForbidenMt(ret.fashionDatas)
  setForbidenMt(ret.UnlockColor)
  return ret
end
return {New = new}
