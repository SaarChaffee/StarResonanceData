local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.curPoint
    container.__data__.curPoint = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("curPoint", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.maxPoint
    container.__data__.maxPoint = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("maxPoint", last)
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
  if not pbData.seasonData then
    container.__data__.seasonData = {}
  end
  if not pbData.lastSeasonId then
    container.__data__.lastSeasonId = 0
  end
  if not pbData.curPoint then
    container.__data__.curPoint = 0
  end
  if not pbData.maxPoint then
    container.__data__.maxPoint = 0
  end
  if not pbData.lastWeek then
    container.__data__.lastWeek = {}
  end
  setForbidenMt(container)
  container.seasonData.__data__ = {}
  setForbidenMt(container.seasonData)
  for k, v in pairs(pbData.seasonData) do
    container.seasonData.__data__[k] = require("zcontainer.compensation_season_statistics").New()
    container.seasonData[k]:ResetData(v)
  end
  container.__data__.seasonData = nil
  container.lastWeek.__data__ = pbData.lastWeek
  setForbidenMt(container.lastWeek)
  container.__data__.lastWeek = nil
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
  if container.seasonData ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.seasonData) do
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
    ret.seasonData = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.seasonData = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  ret.lastSeasonId = {
    fieldId = 2,
    dataType = 0,
    data = container.lastSeasonId
  }
  ret.curPoint = {
    fieldId = 3,
    dataType = 0,
    data = container.curPoint
  }
  ret.maxPoint = {
    fieldId = 4,
    dataType = 0,
    data = container.maxPoint
  }
  if container.lastWeek ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.lastWeek) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.lastWeek = {
      fieldId = 5,
      dataType = 2,
      data = data
    }
  else
    ret.lastWeek = {
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
    seasonData = {
      __data__ = {}
    },
    lastWeek = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.seasonData)
  setForbidenMt(ret.lastWeek)
  return ret
end
return {New = new}
