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
      local v = require("zcontainer.hand_book_struct").New()
      v:MergeData(buffer, watcherList)
      container.unlockNoteImportantRoleMap.__data__[dk] = v
      container.Watcher:MarkMapDirty("unlockNoteImportantRoleMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockNoteImportantRoleMap.__data__[dk]
      container.unlockNoteImportantRoleMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("unlockNoteImportantRoleMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockNoteImportantRoleMap.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.hand_book_struct").New()
        container.unlockNoteImportantRoleMap.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("unlockNoteImportantRoleMap", dk, {})
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
      local v = require("zcontainer.hand_book_struct").New()
      v:MergeData(buffer, watcherList)
      container.unlockNoteReadingBookMap.__data__[dk] = v
      container.Watcher:MarkMapDirty("unlockNoteReadingBookMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockNoteReadingBookMap.__data__[dk]
      container.unlockNoteReadingBookMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("unlockNoteReadingBookMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockNoteReadingBookMap.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.hand_book_struct").New()
        container.unlockNoteReadingBookMap.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("unlockNoteReadingBookMap", dk, {})
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
      local v = require("zcontainer.hand_book_struct").New()
      v:MergeData(buffer, watcherList)
      container.unlockNoteDictionaryMap.__data__[dk] = v
      container.Watcher:MarkMapDirty("unlockNoteDictionaryMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockNoteDictionaryMap.__data__[dk]
      container.unlockNoteDictionaryMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("unlockNoteDictionaryMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockNoteDictionaryMap.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.hand_book_struct").New()
        container.unlockNoteDictionaryMap.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("unlockNoteDictionaryMap", dk, {})
    end
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
      local v = require("zcontainer.hand_book_struct").New()
      v:MergeData(buffer, watcherList)
      container.unlockNotePostCardMap.__data__[dk] = v
      container.Watcher:MarkMapDirty("unlockNotePostCardMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockNotePostCardMap.__data__[dk]
      container.unlockNotePostCardMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("unlockNotePostCardMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockNotePostCardMap.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.hand_book_struct").New()
        container.unlockNotePostCardMap.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("unlockNotePostCardMap", dk, {})
    end
  end,
  [5] = function(container, buffer, watcherList)
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
      local v = require("zcontainer.hand_book_struct").New()
      v:MergeData(buffer, watcherList)
      container.unlockNoteMonthCardMap.__data__[dk] = v
      container.Watcher:MarkMapDirty("unlockNoteMonthCardMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockNoteMonthCardMap.__data__[dk]
      container.unlockNoteMonthCardMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("unlockNoteMonthCardMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockNoteMonthCardMap.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.hand_book_struct").New()
        container.unlockNoteMonthCardMap.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("unlockNoteMonthCardMap", dk, {})
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
  if not pbData.unlockNoteImportantRoleMap then
    container.__data__.unlockNoteImportantRoleMap = {}
  end
  if not pbData.unlockNoteReadingBookMap then
    container.__data__.unlockNoteReadingBookMap = {}
  end
  if not pbData.unlockNoteDictionaryMap then
    container.__data__.unlockNoteDictionaryMap = {}
  end
  if not pbData.unlockNotePostCardMap then
    container.__data__.unlockNotePostCardMap = {}
  end
  if not pbData.unlockNoteMonthCardMap then
    container.__data__.unlockNoteMonthCardMap = {}
  end
  setForbidenMt(container)
  container.unlockNoteImportantRoleMap.__data__ = {}
  setForbidenMt(container.unlockNoteImportantRoleMap)
  for k, v in pairs(pbData.unlockNoteImportantRoleMap) do
    container.unlockNoteImportantRoleMap.__data__[k] = require("zcontainer.hand_book_struct").New()
    container.unlockNoteImportantRoleMap[k]:ResetData(v)
  end
  container.__data__.unlockNoteImportantRoleMap = nil
  container.unlockNoteReadingBookMap.__data__ = {}
  setForbidenMt(container.unlockNoteReadingBookMap)
  for k, v in pairs(pbData.unlockNoteReadingBookMap) do
    container.unlockNoteReadingBookMap.__data__[k] = require("zcontainer.hand_book_struct").New()
    container.unlockNoteReadingBookMap[k]:ResetData(v)
  end
  container.__data__.unlockNoteReadingBookMap = nil
  container.unlockNoteDictionaryMap.__data__ = {}
  setForbidenMt(container.unlockNoteDictionaryMap)
  for k, v in pairs(pbData.unlockNoteDictionaryMap) do
    container.unlockNoteDictionaryMap.__data__[k] = require("zcontainer.hand_book_struct").New()
    container.unlockNoteDictionaryMap[k]:ResetData(v)
  end
  container.__data__.unlockNoteDictionaryMap = nil
  container.unlockNotePostCardMap.__data__ = {}
  setForbidenMt(container.unlockNotePostCardMap)
  for k, v in pairs(pbData.unlockNotePostCardMap) do
    container.unlockNotePostCardMap.__data__[k] = require("zcontainer.hand_book_struct").New()
    container.unlockNotePostCardMap[k]:ResetData(v)
  end
  container.__data__.unlockNotePostCardMap = nil
  container.unlockNoteMonthCardMap.__data__ = {}
  setForbidenMt(container.unlockNoteMonthCardMap)
  for k, v in pairs(pbData.unlockNoteMonthCardMap) do
    container.unlockNoteMonthCardMap.__data__[k] = require("zcontainer.hand_book_struct").New()
    container.unlockNoteMonthCardMap[k]:ResetData(v)
  end
  container.__data__.unlockNoteMonthCardMap = nil
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
  if container.unlockNoteImportantRoleMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.unlockNoteImportantRoleMap) do
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
    ret.unlockNoteImportantRoleMap = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.unlockNoteImportantRoleMap = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.unlockNoteReadingBookMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.unlockNoteReadingBookMap) do
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
    ret.unlockNoteReadingBookMap = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.unlockNoteReadingBookMap = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.unlockNoteDictionaryMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.unlockNoteDictionaryMap) do
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
    ret.unlockNoteDictionaryMap = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.unlockNoteDictionaryMap = {
      fieldId = 3,
      dataType = 2,
      data = {}
    }
  end
  if container.unlockNotePostCardMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.unlockNotePostCardMap) do
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
    ret.unlockNotePostCardMap = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.unlockNotePostCardMap = {
      fieldId = 4,
      dataType = 2,
      data = {}
    }
  end
  if container.unlockNoteMonthCardMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.unlockNoteMonthCardMap) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 5,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 5,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.unlockNoteMonthCardMap = {
      fieldId = 5,
      dataType = 2,
      data = data
    }
  else
    ret.unlockNoteMonthCardMap = {
      fieldId = 5,
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
    unlockNoteImportantRoleMap = {
      __data__ = {}
    },
    unlockNoteReadingBookMap = {
      __data__ = {}
    },
    unlockNoteDictionaryMap = {
      __data__ = {}
    },
    unlockNotePostCardMap = {
      __data__ = {}
    },
    unlockNoteMonthCardMap = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.unlockNoteImportantRoleMap)
  setForbidenMt(ret.unlockNoteReadingBookMap)
  setForbidenMt(ret.unlockNoteDictionaryMap)
  setForbidenMt(ret.unlockNotePostCardMap)
  setForbidenMt(ret.unlockNoteMonthCardMap)
  return ret
end
return {New = new}
