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
      local v = require("zcontainer.show_piece_id_list").New()
      v:MergeData(buffer, watcherList)
      container.OftenUseTypeList.__data__[dk] = v
      container.Watcher:MarkMapDirty("OftenUseTypeList", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.OftenUseTypeList.__data__[dk]
      container.OftenUseTypeList.__data__[dk] = nil
      container.Watcher:MarkMapDirty("OftenUseTypeList", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.OftenUseTypeList.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.show_piece_id_list").New()
        container.OftenUseTypeList.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("OftenUseTypeList", dk, {})
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
      local v = require("zcontainer.show_piece_id_list").New()
      v:MergeData(buffer, watcherList)
      container.unlockTypeList.__data__[dk] = v
      container.Watcher:MarkMapDirty("unlockTypeList", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockTypeList.__data__[dk]
      container.unlockTypeList.__data__[dk] = nil
      container.Watcher:MarkMapDirty("unlockTypeList", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockTypeList.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.show_piece_id_list").New()
        container.unlockTypeList.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("unlockTypeList", dk, {})
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
      local v = require("zcontainer.show_piece_pair").New()
      v:MergeData(buffer, watcherList)
      container.roulettePosPieceInfo.__data__[dk] = v
      container.Watcher:MarkMapDirty("roulettePosPieceInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.roulettePosPieceInfo.__data__[dk]
      container.roulettePosPieceInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("roulettePosPieceInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.roulettePosPieceInfo.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.show_piece_pair").New()
        container.roulettePosPieceInfo.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("roulettePosPieceInfo", dk, {})
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
  if not pbData.OftenUseTypeList then
    container.__data__.OftenUseTypeList = {}
  end
  if not pbData.unlockTypeList then
    container.__data__.unlockTypeList = {}
  end
  if not pbData.roulettePosPieceInfo then
    container.__data__.roulettePosPieceInfo = {}
  end
  setForbidenMt(container)
  container.OftenUseTypeList.__data__ = {}
  setForbidenMt(container.OftenUseTypeList)
  for k, v in pairs(pbData.OftenUseTypeList) do
    container.OftenUseTypeList.__data__[k] = require("zcontainer.show_piece_id_list").New()
    container.OftenUseTypeList[k]:ResetData(v)
  end
  container.__data__.OftenUseTypeList = nil
  container.unlockTypeList.__data__ = {}
  setForbidenMt(container.unlockTypeList)
  for k, v in pairs(pbData.unlockTypeList) do
    container.unlockTypeList.__data__[k] = require("zcontainer.show_piece_id_list").New()
    container.unlockTypeList[k]:ResetData(v)
  end
  container.__data__.unlockTypeList = nil
  container.roulettePosPieceInfo.__data__ = {}
  setForbidenMt(container.roulettePosPieceInfo)
  for k, v in pairs(pbData.roulettePosPieceInfo) do
    container.roulettePosPieceInfo.__data__[k] = require("zcontainer.show_piece_pair").New()
    container.roulettePosPieceInfo[k]:ResetData(v)
  end
  container.__data__.roulettePosPieceInfo = nil
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
  if container.OftenUseTypeList ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.OftenUseTypeList) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 1,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 1,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.OftenUseTypeList = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.OftenUseTypeList = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.unlockTypeList ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.unlockTypeList) do
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
    ret.unlockTypeList = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.unlockTypeList = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.roulettePosPieceInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.roulettePosPieceInfo) do
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
    ret.roulettePosPieceInfo = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.roulettePosPieceInfo = {
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
    OftenUseTypeList = {
      __data__ = {}
    },
    unlockTypeList = {
      __data__ = {}
    },
    roulettePosPieceInfo = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.OftenUseTypeList)
  setForbidenMt(ret.unlockTypeList)
  setForbidenMt(ret.roulettePosPieceInfo)
  return ret
end
return {New = new}
