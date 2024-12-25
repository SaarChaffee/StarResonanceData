local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.curHp
    container.__data__.curHp = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("curHp", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.maxHp
    container.__data__.maxHp = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("maxHp", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.originEnergy
    container.__data__.originEnergy = br.ReadSingle(buffer)
    container.Watcher:MarkDirty("originEnergy", last)
  end,
  [4] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.resourceIds
    container.__data__.resourceIds = t
    for i = 1, count do
      local v = br.ReadUInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("resourceIds", last)
    end
  end,
  [5] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.resources
    container.__data__.resources = t
    for i = 1, count do
      local v = br.ReadUInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("resources", last)
    end
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.isDead
    container.__data__.isDead = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("isDead", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.deadTime
    container.__data__.deadTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("deadTime", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.reviveId
    container.__data__.reviveId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("reviveId", last)
  end,
  [9] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.cdInfo
    container.__data__.cdInfo = t
    for i = 1, count do
      local v = require("zcontainer.skill_c_d_info").New()
      v:MergeData(buffer, watcherList)
      t[#t + 1] = v
      container.Watcher:MarkDirty("cdInfo", last)
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
  if not pbData.curHp then
    container.__data__.curHp = 0
  end
  if not pbData.maxHp then
    container.__data__.maxHp = 0
  end
  if not pbData.originEnergy then
    container.__data__.originEnergy = 0
  end
  if not pbData.resourceIds then
    container.__data__.resourceIds = {}
  end
  if not pbData.resources then
    container.__data__.resources = {}
  end
  if not pbData.isDead then
    container.__data__.isDead = 0
  end
  if not pbData.deadTime then
    container.__data__.deadTime = 0
  end
  if not pbData.reviveId then
    container.__data__.reviveId = 0
  end
  if not pbData.cdInfo then
    container.__data__.cdInfo = {}
  end
  setForbidenMt(container)
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
  ret.curHp = {
    fieldId = 1,
    dataType = 0,
    data = container.curHp
  }
  ret.maxHp = {
    fieldId = 2,
    dataType = 0,
    data = container.maxHp
  }
  ret.originEnergy = {
    fieldId = 3,
    dataType = 0,
    data = container.originEnergy
  }
  if container.resourceIds ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.resourceIds) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.resourceIds = {
      fieldId = 4,
      dataType = 3,
      data = data
    }
  else
    ret.resourceIds = {
      fieldId = 4,
      dataType = 3,
      data = {}
    }
  end
  if container.resources ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.resources) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.resources = {
      fieldId = 5,
      dataType = 3,
      data = data
    }
  else
    ret.resources = {
      fieldId = 5,
      dataType = 3,
      data = {}
    }
  end
  ret.isDead = {
    fieldId = 6,
    dataType = 0,
    data = container.isDead
  }
  ret.deadTime = {
    fieldId = 7,
    dataType = 0,
    data = container.deadTime
  }
  ret.reviveId = {
    fieldId = 8,
    dataType = 0,
    data = container.reviveId
  }
  if container.cdInfo ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.cdInfo) do
      if repeatedItem == nil then
        data[index] = {
          fieldId = 9,
          dataType = 1,
          data = nil
        }
      else
        data[index] = {
          fieldId = 9,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.cdInfo = {
      fieldId = 9,
      dataType = 3,
      data = data
    }
  else
    ret.cdInfo = {
      fieldId = 9,
      dataType = 3,
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
    GetContainerElem = getContainerElem
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
