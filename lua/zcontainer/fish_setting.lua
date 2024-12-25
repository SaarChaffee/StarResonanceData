local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.baitId
    container.__data__.baitId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("baitId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.experiences
    container.__data__.experiences = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("experiences", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.researchFishId
    container.__data__.researchFishId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("researchFishId", last)
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
      local v = require("zcontainer.fish_record").New()
      v:MergeData(buffer, watcherList)
      container.fishRecords.__data__[dk] = v
      container.Watcher:MarkMapDirty("fishRecords", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.fishRecords.__data__[dk]
      container.fishRecords.__data__[dk] = nil
      container.Watcher:MarkMapDirty("fishRecords", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.fishRecords.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.fish_record").New()
        container.fishRecords.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("fishRecords", dk, {})
    end
  end,
  [6] = function(container, buffer, watcherList)
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
      local dk = br.ReadUInt64(buffer)
      local dv = br.ReadInt32(buffer)
      container.fishRodDurability.__data__[dk] = dv
      container.Watcher:MarkMapDirty("fishRodDurability", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt64(buffer)
      local last = container.fishRodDurability.__data__[dk]
      container.fishRodDurability.__data__[dk] = nil
      container.Watcher:MarkMapDirty("fishRodDurability", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt64(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.fishRodDurability.__data__[dk]
      container.fishRodDurability.__data__[dk] = dv
      container.Watcher:MarkMapDirty("fishRodDurability", dk, last)
    end
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.rodUuid
    container.__data__.rodUuid = br.ReadUInt64(buffer)
    container.Watcher:MarkDirty("rodUuid", last)
  end,
  [8] = function(container, buffer, watcherList)
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
      local dv = br.ReadBoolean(buffer)
      container.levelReward.__data__[dk] = dv
      container.Watcher:MarkMapDirty("levelReward", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.levelReward.__data__[dk]
      container.levelReward.__data__[dk] = nil
      container.Watcher:MarkMapDirty("levelReward", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.levelReward.__data__[dk]
      container.levelReward.__data__[dk] = dv
      container.Watcher:MarkMapDirty("levelReward", dk, last)
    end
  end,
  [9] = function(container, buffer, watcherList)
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
      local dv = br.ReadInt64(buffer)
      container.zeroFishTimes.__data__[dk] = dv
      container.Watcher:MarkMapDirty("zeroFishTimes", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.zeroFishTimes.__data__[dk]
      container.zeroFishTimes.__data__[dk] = nil
      container.Watcher:MarkMapDirty("zeroFishTimes", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt64(buffer)
      local last = container.zeroFishTimes.__data__[dk]
      container.zeroFishTimes.__data__[dk] = dv
      container.Watcher:MarkMapDirty("zeroFishTimes", dk, last)
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
  if not pbData.baitId then
    container.__data__.baitId = 0
  end
  if not pbData.experiences then
    container.__data__.experiences = 0
  end
  if not pbData.researchFishId then
    container.__data__.researchFishId = 0
  end
  if not pbData.fishRecords then
    container.__data__.fishRecords = {}
  end
  if not pbData.fishRodDurability then
    container.__data__.fishRodDurability = {}
  end
  if not pbData.rodUuid then
    container.__data__.rodUuid = 0
  end
  if not pbData.levelReward then
    container.__data__.levelReward = {}
  end
  if not pbData.zeroFishTimes then
    container.__data__.zeroFishTimes = {}
  end
  setForbidenMt(container)
  container.fishRecords.__data__ = {}
  setForbidenMt(container.fishRecords)
  for k, v in pairs(pbData.fishRecords) do
    container.fishRecords.__data__[k] = require("zcontainer.fish_record").New()
    container.fishRecords[k]:ResetData(v)
  end
  container.__data__.fishRecords = nil
  container.fishRodDurability.__data__ = pbData.fishRodDurability
  setForbidenMt(container.fishRodDurability)
  container.__data__.fishRodDurability = nil
  container.levelReward.__data__ = pbData.levelReward
  setForbidenMt(container.levelReward)
  container.__data__.levelReward = nil
  container.zeroFishTimes.__data__ = pbData.zeroFishTimes
  setForbidenMt(container.zeroFishTimes)
  container.__data__.zeroFishTimes = nil
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
  ret.baitId = {
    fieldId = 2,
    dataType = 0,
    data = container.baitId
  }
  ret.experiences = {
    fieldId = 3,
    dataType = 0,
    data = container.experiences
  }
  ret.researchFishId = {
    fieldId = 4,
    dataType = 0,
    data = container.researchFishId
  }
  if container.fishRecords ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.fishRecords) do
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
    ret.fishRecords = {
      fieldId = 5,
      dataType = 2,
      data = data
    }
  else
    ret.fishRecords = {
      fieldId = 5,
      dataType = 2,
      data = {}
    }
  end
  if container.fishRodDurability ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.fishRodDurability) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.fishRodDurability = {
      fieldId = 6,
      dataType = 2,
      data = data
    }
  else
    ret.fishRodDurability = {
      fieldId = 6,
      dataType = 2,
      data = {}
    }
  end
  ret.rodUuid = {
    fieldId = 7,
    dataType = 0,
    data = container.rodUuid
  }
  if container.levelReward ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.levelReward) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.levelReward = {
      fieldId = 8,
      dataType = 2,
      data = data
    }
  else
    ret.levelReward = {
      fieldId = 8,
      dataType = 2,
      data = {}
    }
  end
  if container.zeroFishTimes ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.zeroFishTimes) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.zeroFishTimes = {
      fieldId = 9,
      dataType = 2,
      data = data
    }
  else
    ret.zeroFishTimes = {
      fieldId = 9,
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
    fishRecords = {
      __data__ = {}
    },
    fishRodDurability = {
      __data__ = {}
    },
    levelReward = {
      __data__ = {}
    },
    zeroFishTimes = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.fishRecords)
  setForbidenMt(ret.fishRodDurability)
  setForbidenMt(ret.levelReward)
  setForbidenMt(ret.zeroFishTimes)
  return ret
end
return {New = new}
