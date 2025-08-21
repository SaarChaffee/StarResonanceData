local br = require("sync.blob_reader")
local mergeDataFuncs = {
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
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      container.baseAttrs.__data__[dk] = dv
      container.Watcher:MarkMapDirty("baseAttrs", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.baseAttrs.__data__[dk]
      container.baseAttrs.__data__[dk] = nil
      container.Watcher:MarkMapDirty("baseAttrs", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      local last = container.baseAttrs.__data__[dk]
      container.baseAttrs.__data__[dk] = dv
      container.Watcher:MarkMapDirty("baseAttrs", dk, last)
    end
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.perfectionValue
    container.__data__.perfectionValue = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("perfectionValue", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.recastCount
    container.__data__.recastCount = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("recastCount", last)
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.totalRecastCount
    container.__data__.totalRecastCount = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("totalRecastCount", last)
  end,
  [10] = function(container, buffer, watcherList)
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
      container.basicAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("basicAttr", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.basicAttr.__data__[dk]
      container.basicAttr.__data__[dk] = nil
      container.Watcher:MarkMapDirty("basicAttr", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.basicAttr.__data__[dk]
      container.basicAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("basicAttr", dk, last)
    end
  end,
  [11] = function(container, buffer, watcherList)
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
      container.advanceAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("advanceAttr", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.advanceAttr.__data__[dk]
      container.advanceAttr.__data__[dk] = nil
      container.Watcher:MarkMapDirty("advanceAttr", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.advanceAttr.__data__[dk]
      container.advanceAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("advanceAttr", dk, last)
    end
  end,
  [12] = function(container, buffer, watcherList)
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
      container.recastAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("recastAttr", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.recastAttr.__data__[dk]
      container.recastAttr.__data__[dk] = nil
      container.Watcher:MarkMapDirty("recastAttr", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.recastAttr.__data__[dk]
      container.recastAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("recastAttr", dk, last)
    end
  end,
  [13] = function(container, buffer, watcherList)
    local last = container.__data__.perfectionLevel
    container.__data__.perfectionLevel = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("perfectionLevel", last)
  end,
  [14] = function(container, buffer, watcherList)
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
      container.rareQualityAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("rareQualityAttr", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.rareQualityAttr.__data__[dk]
      container.rareQualityAttr.__data__[dk] = nil
      container.Watcher:MarkMapDirty("rareQualityAttr", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.rareQualityAttr.__data__[dk]
      container.rareQualityAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("rareQualityAttr", dk, last)
    end
  end,
  [15] = function(container, buffer, watcherList)
    local last = container.__data__.maxPerfectionValue
    container.__data__.maxPerfectionValue = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("maxPerfectionValue", last)
  end,
  [17] = function(container, buffer, watcherList)
    container.equipAttrSet:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("equipAttrSet", {})
  end,
  [18] = function(container, buffer, watcherList)
    local last = container.__data__.breakThroughTime
    container.__data__.breakThroughTime = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("breakThroughTime", last)
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
  if not pbData.baseAttrs then
    container.__data__.baseAttrs = {}
  end
  if not pbData.perfectionValue then
    container.__data__.perfectionValue = 0
  end
  if not pbData.recastCount then
    container.__data__.recastCount = 0
  end
  if not pbData.totalRecastCount then
    container.__data__.totalRecastCount = 0
  end
  if not pbData.basicAttr then
    container.__data__.basicAttr = {}
  end
  if not pbData.advanceAttr then
    container.__data__.advanceAttr = {}
  end
  if not pbData.recastAttr then
    container.__data__.recastAttr = {}
  end
  if not pbData.perfectionLevel then
    container.__data__.perfectionLevel = 0
  end
  if not pbData.rareQualityAttr then
    container.__data__.rareQualityAttr = {}
  end
  if not pbData.maxPerfectionValue then
    container.__data__.maxPerfectionValue = 0
  end
  if not pbData.equipAttrSet then
    container.__data__.equipAttrSet = {}
  end
  if not pbData.breakThroughTime then
    container.__data__.breakThroughTime = 0
  end
  setForbidenMt(container)
  container.baseAttrs.__data__ = pbData.baseAttrs
  setForbidenMt(container.baseAttrs)
  container.__data__.baseAttrs = nil
  container.basicAttr.__data__ = pbData.basicAttr
  setForbidenMt(container.basicAttr)
  container.__data__.basicAttr = nil
  container.advanceAttr.__data__ = pbData.advanceAttr
  setForbidenMt(container.advanceAttr)
  container.__data__.advanceAttr = nil
  container.recastAttr.__data__ = pbData.recastAttr
  setForbidenMt(container.recastAttr)
  container.__data__.recastAttr = nil
  container.rareQualityAttr.__data__ = pbData.rareQualityAttr
  setForbidenMt(container.rareQualityAttr)
  container.__data__.rareQualityAttr = nil
  container.equipAttrSet:ResetData(pbData.equipAttrSet)
  container.__data__.equipAttrSet = nil
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
  if container.baseAttrs ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.baseAttrs) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.baseAttrs = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.baseAttrs = {
      fieldId = 4,
      dataType = 2,
      data = {}
    }
  end
  ret.perfectionValue = {
    fieldId = 7,
    dataType = 0,
    data = container.perfectionValue
  }
  ret.recastCount = {
    fieldId = 8,
    dataType = 0,
    data = container.recastCount
  }
  ret.totalRecastCount = {
    fieldId = 9,
    dataType = 0,
    data = container.totalRecastCount
  }
  if container.basicAttr ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.basicAttr) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.basicAttr = {
      fieldId = 10,
      dataType = 2,
      data = data
    }
  else
    ret.basicAttr = {
      fieldId = 10,
      dataType = 2,
      data = {}
    }
  end
  if container.advanceAttr ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.advanceAttr) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.advanceAttr = {
      fieldId = 11,
      dataType = 2,
      data = data
    }
  else
    ret.advanceAttr = {
      fieldId = 11,
      dataType = 2,
      data = {}
    }
  end
  if container.recastAttr ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.recastAttr) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.recastAttr = {
      fieldId = 12,
      dataType = 2,
      data = data
    }
  else
    ret.recastAttr = {
      fieldId = 12,
      dataType = 2,
      data = {}
    }
  end
  ret.perfectionLevel = {
    fieldId = 13,
    dataType = 0,
    data = container.perfectionLevel
  }
  if container.rareQualityAttr ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.rareQualityAttr) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.rareQualityAttr = {
      fieldId = 14,
      dataType = 2,
      data = data
    }
  else
    ret.rareQualityAttr = {
      fieldId = 14,
      dataType = 2,
      data = {}
    }
  end
  ret.maxPerfectionValue = {
    fieldId = 15,
    dataType = 0,
    data = container.maxPerfectionValue
  }
  if container.equipAttrSet == nil then
    ret.equipAttrSet = {
      fieldId = 17,
      dataType = 1,
      data = nil
    }
  else
    ret.equipAttrSet = {
      fieldId = 17,
      dataType = 1,
      data = container.equipAttrSet:GetContainerElem()
    }
  end
  ret.breakThroughTime = {
    fieldId = 18,
    dataType = 0,
    data = container.breakThroughTime
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    baseAttrs = {
      __data__ = {}
    },
    basicAttr = {
      __data__ = {}
    },
    advanceAttr = {
      __data__ = {}
    },
    recastAttr = {
      __data__ = {}
    },
    rareQualityAttr = {
      __data__ = {}
    },
    equipAttrSet = require("zcontainer.equip_attr_set").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.baseAttrs)
  setForbidenMt(ret.basicAttr)
  setForbidenMt(ret.advanceAttr)
  setForbidenMt(ret.recastAttr)
  setForbidenMt(ret.rareQualityAttr)
  return ret
end
return {New = new}
