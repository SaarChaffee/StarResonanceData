local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.uuid
    container.__data__.uuid = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("uuid", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.configId
    container.__data__.configId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("configId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.count
    container.__data__.count = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("count", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.invalid
    container.__data__.invalid = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("invalid", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.bindFlag
    container.__data__.bindFlag = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("bindFlag", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.createTime
    container.__data__.createTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("createTime", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.expireTime
    container.__data__.expireTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("expireTime", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.optSrc
    container.__data__.optSrc = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("optSrc", last)
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.quality
    container.__data__.quality = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("quality", last)
  end,
  [10] = function(container, buffer, watcherList)
    container.equipAttr:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("equipAttr", {})
  end,
  [11] = function(container, buffer, watcherList)
    container.modAttr:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("modAttr", {})
  end,
  [12] = function(container, buffer, watcherList)
    local last = container.__data__.coolDownExpireTime
    container.__data__.coolDownExpireTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("coolDownExpireTime", last)
  end,
  [13] = function(container, buffer, watcherList)
    container.modNewAttr:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("modNewAttr", {})
  end,
  [14] = function(container, buffer, watcherList)
    container.affixData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("affixData", {})
  end,
  [15] = function(container, buffer, watcherList)
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
      local v = require("zcontainer.item_extend_data").New()
      v:MergeData(buffer, watcherList)
      container.extendAttr.__data__[dk] = v
      container.Watcher:MarkMapDirty("extendAttr", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.extendAttr.__data__[dk]
      container.extendAttr.__data__[dk] = nil
      container.Watcher:MarkMapDirty("extendAttr", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.extendAttr.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.item_extend_data").New()
        container.extendAttr.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("extendAttr", dk, {})
    end
  end,
  [16] = function(container, buffer, watcherList)
    local last = container.__data__.rewardId
    container.__data__.rewardId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("rewardId", last)
  end,
  [17] = function(container, buffer, watcherList)
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
      container.geneSequence.__data__[dk] = dv
      container.Watcher:MarkMapDirty("geneSequence", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.geneSequence.__data__[dk]
      container.geneSequence.__data__[dk] = nil
      container.Watcher:MarkMapDirty("geneSequence", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.geneSequence.__data__[dk]
      container.geneSequence.__data__[dk] = dv
      container.Watcher:MarkMapDirty("geneSequence", dk, last)
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
  if not pbData.uuid then
    container.__data__.uuid = 0
  end
  if not pbData.configId then
    container.__data__.configId = 0
  end
  if not pbData.count then
    container.__data__.count = 0
  end
  if not pbData.invalid then
    container.__data__.invalid = 0
  end
  if not pbData.bindFlag then
    container.__data__.bindFlag = 0
  end
  if not pbData.createTime then
    container.__data__.createTime = 0
  end
  if not pbData.expireTime then
    container.__data__.expireTime = 0
  end
  if not pbData.optSrc then
    container.__data__.optSrc = 0
  end
  if not pbData.quality then
    container.__data__.quality = 0
  end
  if not pbData.equipAttr then
    container.__data__.equipAttr = {}
  end
  if not pbData.modAttr then
    container.__data__.modAttr = {}
  end
  if not pbData.coolDownExpireTime then
    container.__data__.coolDownExpireTime = 0
  end
  if not pbData.modNewAttr then
    container.__data__.modNewAttr = {}
  end
  if not pbData.affixData then
    container.__data__.affixData = {}
  end
  if not pbData.extendAttr then
    container.__data__.extendAttr = {}
  end
  if not pbData.rewardId then
    container.__data__.rewardId = 0
  end
  if not pbData.geneSequence then
    container.__data__.geneSequence = {}
  end
  setForbidenMt(container)
  container.equipAttr:ResetData(pbData.equipAttr)
  container.__data__.equipAttr = nil
  container.modAttr:ResetData(pbData.modAttr)
  container.__data__.modAttr = nil
  container.modNewAttr:ResetData(pbData.modNewAttr)
  container.__data__.modNewAttr = nil
  container.affixData:ResetData(pbData.affixData)
  container.__data__.affixData = nil
  container.extendAttr.__data__ = {}
  setForbidenMt(container.extendAttr)
  for k, v in pairs(pbData.extendAttr) do
    container.extendAttr.__data__[k] = require("zcontainer.item_extend_data").New()
    container.extendAttr[k]:ResetData(v)
  end
  container.__data__.extendAttr = nil
  container.geneSequence.__data__ = pbData.geneSequence
  setForbidenMt(container.geneSequence)
  container.__data__.geneSequence = nil
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
  ret.uuid = {
    fieldId = 1,
    dataType = 0,
    data = container.uuid
  }
  ret.configId = {
    fieldId = 2,
    dataType = 0,
    data = container.configId
  }
  ret.count = {
    fieldId = 3,
    dataType = 0,
    data = container.count
  }
  ret.invalid = {
    fieldId = 4,
    dataType = 0,
    data = container.invalid
  }
  ret.bindFlag = {
    fieldId = 5,
    dataType = 0,
    data = container.bindFlag
  }
  ret.createTime = {
    fieldId = 6,
    dataType = 0,
    data = container.createTime
  }
  ret.expireTime = {
    fieldId = 7,
    dataType = 0,
    data = container.expireTime
  }
  ret.optSrc = {
    fieldId = 8,
    dataType = 0,
    data = container.optSrc
  }
  ret.quality = {
    fieldId = 9,
    dataType = 0,
    data = container.quality
  }
  if container.equipAttr == nil then
    ret.equipAttr = {
      fieldId = 10,
      dataType = 1,
      data = nil
    }
  else
    ret.equipAttr = {
      fieldId = 10,
      dataType = 1,
      data = container.equipAttr:GetContainerElem()
    }
  end
  if container.modAttr == nil then
    ret.modAttr = {
      fieldId = 11,
      dataType = 1,
      data = nil
    }
  else
    ret.modAttr = {
      fieldId = 11,
      dataType = 1,
      data = container.modAttr:GetContainerElem()
    }
  end
  ret.coolDownExpireTime = {
    fieldId = 12,
    dataType = 0,
    data = container.coolDownExpireTime
  }
  if container.modNewAttr == nil then
    ret.modNewAttr = {
      fieldId = 13,
      dataType = 1,
      data = nil
    }
  else
    ret.modNewAttr = {
      fieldId = 13,
      dataType = 1,
      data = container.modNewAttr:GetContainerElem()
    }
  end
  if container.affixData == nil then
    ret.affixData = {
      fieldId = 14,
      dataType = 1,
      data = nil
    }
  else
    ret.affixData = {
      fieldId = 14,
      dataType = 1,
      data = container.affixData:GetContainerElem()
    }
  end
  if container.extendAttr ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.extendAttr) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 15,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 15,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.extendAttr = {
      fieldId = 15,
      dataType = 2,
      data = data
    }
  else
    ret.extendAttr = {
      fieldId = 15,
      dataType = 2,
      data = {}
    }
  end
  ret.rewardId = {
    fieldId = 16,
    dataType = 0,
    data = container.rewardId
  }
  if container.geneSequence ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.geneSequence) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.geneSequence = {
      fieldId = 17,
      dataType = 2,
      data = data
    }
  else
    ret.geneSequence = {
      fieldId = 17,
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
    equipAttr = require("zcontainer.equip_attr").New(),
    modAttr = require("zcontainer.mod_attr").New(),
    modNewAttr = require("zcontainer.mod_new_attr").New(),
    affixData = require("zcontainer.affix_data").New(),
    extendAttr = {
      __data__ = {}
    },
    geneSequence = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.extendAttr)
  setForbidenMt(ret.geneSequence)
  return ret
end
return {New = new}
