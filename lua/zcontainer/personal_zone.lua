local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [2] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.onlinePeriods
    container.__data__.onlinePeriods = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("onlinePeriods", last)
    end
  end,
  [3] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.tags
    container.__data__.tags = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("tags", last)
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
      local dv = br.ReadInt32(buffer)
      container.medals.__data__[dk] = dv
      container.Watcher:MarkMapDirty("medals", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.medals.__data__[dk]
      container.medals.__data__[dk] = nil
      container.Watcher:MarkMapDirty("medals", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.medals.__data__[dk]
      container.medals.__data__[dk] = dv
      container.Watcher:MarkMapDirty("medals", dk, last)
    end
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.themeId
    container.__data__.themeId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("themeId", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.businessCardStyleId
    container.__data__.businessCardStyleId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("businessCardStyleId", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.avatarFrameId
    container.__data__.avatarFrameId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("avatarFrameId", last)
  end,
  [9] = function(container, buffer, watcherList)
    container.actionInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("actionInfo", {})
  end,
  [10] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.uiPosition
    container.__data__.uiPosition = t
    for i = 1, count do
      local v = require("zcontainer.editor_u_i_position").New()
      v:MergeData(buffer, watcherList)
      t[#t + 1] = v
      container.Watcher:MarkDirty("uiPosition", last)
    end
  end,
  [11] = function(container, buffer, watcherList)
    local last = container.__data__.titleId
    container.__data__.titleId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("titleId", last)
  end,
  [12] = function(container, buffer, watcherList)
    local last = container.__data__.fashionRefreshFlag
    container.__data__.fashionRefreshFlag = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("fashionRefreshFlag", last)
  end,
  [13] = function(container, buffer, watcherList)
    local last = container.__data__.fashionCollectPoint
    container.__data__.fashionCollectPoint = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("fashionCollectPoint", last)
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
      local v = require("zcontainer.fashion_quality_collect_info").New()
      v:MergeData(buffer, watcherList)
      container.fashionCollectQualityCount.__data__[dk] = v
      container.Watcher:MarkMapDirty("fashionCollectQualityCount", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.fashionCollectQualityCount.__data__[dk]
      container.fashionCollectQualityCount.__data__[dk] = nil
      container.Watcher:MarkMapDirty("fashionCollectQualityCount", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.fashionCollectQualityCount.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.fashion_quality_collect_info").New()
        container.fashionCollectQualityCount.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("fashionCollectQualityCount", dk, {})
    end
  end,
  [15] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.photos
    container.__data__.photos = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("photos", last)
    end
  end,
  [16] = function(container, buffer, watcherList)
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
      container.unlockTargetRecord.__data__[dk] = dv
      container.Watcher:MarkMapDirty("unlockTargetRecord", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockTargetRecord.__data__[dk]
      container.unlockTargetRecord.__data__[dk] = nil
      container.Watcher:MarkMapDirty("unlockTargetRecord", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.unlockTargetRecord.__data__[dk]
      container.unlockTargetRecord.__data__[dk] = dv
      container.Watcher:MarkMapDirty("unlockTargetRecord", dk, last)
    end
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
      local dv = br.ReadBoolean(buffer)
      container.unlockGetRewardRecord.__data__[dk] = dv
      container.Watcher:MarkMapDirty("unlockGetRewardRecord", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockGetRewardRecord.__data__[dk]
      container.unlockGetRewardRecord.__data__[dk] = nil
      container.Watcher:MarkMapDirty("unlockGetRewardRecord", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.unlockGetRewardRecord.__data__[dk]
      container.unlockGetRewardRecord.__data__[dk] = dv
      container.Watcher:MarkMapDirty("unlockGetRewardRecord", dk, last)
    end
  end,
  [18] = function(container, buffer, watcherList)
    local last = container.__data__.rideCollectPoint
    container.__data__.rideCollectPoint = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("rideCollectPoint", last)
  end,
  [19] = function(container, buffer, watcherList)
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
      local v = require("zcontainer.ride_quality_collect_info").New()
      v:MergeData(buffer, watcherList)
      container.rideCollectQualityCount.__data__[dk] = v
      container.Watcher:MarkMapDirty("rideCollectQualityCount", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.rideCollectQualityCount.__data__[dk]
      container.rideCollectQualityCount.__data__[dk] = nil
      container.Watcher:MarkMapDirty("rideCollectQualityCount", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.rideCollectQualityCount.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.ride_quality_collect_info").New()
        container.rideCollectQualityCount.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("rideCollectQualityCount", dk, {})
    end
  end,
  [20] = function(container, buffer, watcherList)
    local last = container.__data__.weaponSkinCollectPoint
    container.__data__.weaponSkinCollectPoint = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("weaponSkinCollectPoint", last)
  end,
  [21] = function(container, buffer, watcherList)
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
      container.photosWall.__data__[dk] = dv
      container.Watcher:MarkMapDirty("photosWall", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.photosWall.__data__[dk]
      container.photosWall.__data__[dk] = nil
      container.Watcher:MarkMapDirty("photosWall", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.photosWall.__data__[dk]
      container.photosWall.__data__[dk] = dv
      container.Watcher:MarkMapDirty("photosWall", dk, last)
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
  if not pbData.onlinePeriods then
    container.__data__.onlinePeriods = {}
  end
  if not pbData.tags then
    container.__data__.tags = {}
  end
  if not pbData.medals then
    container.__data__.medals = {}
  end
  if not pbData.themeId then
    container.__data__.themeId = 0
  end
  if not pbData.businessCardStyleId then
    container.__data__.businessCardStyleId = 0
  end
  if not pbData.avatarFrameId then
    container.__data__.avatarFrameId = 0
  end
  if not pbData.actionInfo then
    container.__data__.actionInfo = {}
  end
  if not pbData.uiPosition then
    container.__data__.uiPosition = {}
  end
  if not pbData.titleId then
    container.__data__.titleId = 0
  end
  if not pbData.fashionRefreshFlag then
    container.__data__.fashionRefreshFlag = false
  end
  if not pbData.fashionCollectPoint then
    container.__data__.fashionCollectPoint = 0
  end
  if not pbData.fashionCollectQualityCount then
    container.__data__.fashionCollectQualityCount = {}
  end
  if not pbData.photos then
    container.__data__.photos = {}
  end
  if not pbData.unlockTargetRecord then
    container.__data__.unlockTargetRecord = {}
  end
  if not pbData.unlockGetRewardRecord then
    container.__data__.unlockGetRewardRecord = {}
  end
  if not pbData.rideCollectPoint then
    container.__data__.rideCollectPoint = 0
  end
  if not pbData.rideCollectQualityCount then
    container.__data__.rideCollectQualityCount = {}
  end
  if not pbData.weaponSkinCollectPoint then
    container.__data__.weaponSkinCollectPoint = 0
  end
  if not pbData.photosWall then
    container.__data__.photosWall = {}
  end
  setForbidenMt(container)
  container.medals.__data__ = pbData.medals
  setForbidenMt(container.medals)
  container.__data__.medals = nil
  container.actionInfo:ResetData(pbData.actionInfo)
  container.__data__.actionInfo = nil
  container.fashionCollectQualityCount.__data__ = {}
  setForbidenMt(container.fashionCollectQualityCount)
  for k, v in pairs(pbData.fashionCollectQualityCount) do
    container.fashionCollectQualityCount.__data__[k] = require("zcontainer.fashion_quality_collect_info").New()
    container.fashionCollectQualityCount[k]:ResetData(v)
  end
  container.__data__.fashionCollectQualityCount = nil
  container.unlockTargetRecord.__data__ = pbData.unlockTargetRecord
  setForbidenMt(container.unlockTargetRecord)
  container.__data__.unlockTargetRecord = nil
  container.unlockGetRewardRecord.__data__ = pbData.unlockGetRewardRecord
  setForbidenMt(container.unlockGetRewardRecord)
  container.__data__.unlockGetRewardRecord = nil
  container.rideCollectQualityCount.__data__ = {}
  setForbidenMt(container.rideCollectQualityCount)
  for k, v in pairs(pbData.rideCollectQualityCount) do
    container.rideCollectQualityCount.__data__[k] = require("zcontainer.ride_quality_collect_info").New()
    container.rideCollectQualityCount[k]:ResetData(v)
  end
  container.__data__.rideCollectQualityCount = nil
  container.photosWall.__data__ = pbData.photosWall
  setForbidenMt(container.photosWall)
  container.__data__.photosWall = nil
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
  if container.onlinePeriods ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.onlinePeriods) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.onlinePeriods = {
      fieldId = 2,
      dataType = 3,
      data = data
    }
  else
    ret.onlinePeriods = {
      fieldId = 2,
      dataType = 3,
      data = {}
    }
  end
  if container.tags ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.tags) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.tags = {
      fieldId = 3,
      dataType = 3,
      data = data
    }
  else
    ret.tags = {
      fieldId = 3,
      dataType = 3,
      data = {}
    }
  end
  if container.medals ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.medals) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.medals = {
      fieldId = 5,
      dataType = 2,
      data = data
    }
  else
    ret.medals = {
      fieldId = 5,
      dataType = 2,
      data = {}
    }
  end
  ret.themeId = {
    fieldId = 6,
    dataType = 0,
    data = container.themeId
  }
  ret.businessCardStyleId = {
    fieldId = 7,
    dataType = 0,
    data = container.businessCardStyleId
  }
  ret.avatarFrameId = {
    fieldId = 8,
    dataType = 0,
    data = container.avatarFrameId
  }
  if container.actionInfo == nil then
    ret.actionInfo = {
      fieldId = 9,
      dataType = 1,
      data = nil
    }
  else
    ret.actionInfo = {
      fieldId = 9,
      dataType = 1,
      data = container.actionInfo:GetContainerElem()
    }
  end
  if container.uiPosition ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.uiPosition) do
      if repeatedItem == nil then
        data[index] = {
          fieldId = 10,
          dataType = 1,
          data = nil
        }
      else
        data[index] = {
          fieldId = 10,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.uiPosition = {
      fieldId = 10,
      dataType = 3,
      data = data
    }
  else
    ret.uiPosition = {
      fieldId = 10,
      dataType = 3,
      data = {}
    }
  end
  ret.titleId = {
    fieldId = 11,
    dataType = 0,
    data = container.titleId
  }
  ret.fashionRefreshFlag = {
    fieldId = 12,
    dataType = 0,
    data = container.fashionRefreshFlag
  }
  ret.fashionCollectPoint = {
    fieldId = 13,
    dataType = 0,
    data = container.fashionCollectPoint
  }
  if container.fashionCollectQualityCount ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.fashionCollectQualityCount) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 14,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 14,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.fashionCollectQualityCount = {
      fieldId = 14,
      dataType = 2,
      data = data
    }
  else
    ret.fashionCollectQualityCount = {
      fieldId = 14,
      dataType = 2,
      data = {}
    }
  end
  if container.photos ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.photos) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.photos = {
      fieldId = 15,
      dataType = 3,
      data = data
    }
  else
    ret.photos = {
      fieldId = 15,
      dataType = 3,
      data = {}
    }
  end
  if container.unlockTargetRecord ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.unlockTargetRecord) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.unlockTargetRecord = {
      fieldId = 16,
      dataType = 2,
      data = data
    }
  else
    ret.unlockTargetRecord = {
      fieldId = 16,
      dataType = 2,
      data = {}
    }
  end
  if container.unlockGetRewardRecord ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.unlockGetRewardRecord) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.unlockGetRewardRecord = {
      fieldId = 17,
      dataType = 2,
      data = data
    }
  else
    ret.unlockGetRewardRecord = {
      fieldId = 17,
      dataType = 2,
      data = {}
    }
  end
  ret.rideCollectPoint = {
    fieldId = 18,
    dataType = 0,
    data = container.rideCollectPoint
  }
  if container.rideCollectQualityCount ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.rideCollectQualityCount) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 19,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 19,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.rideCollectQualityCount = {
      fieldId = 19,
      dataType = 2,
      data = data
    }
  else
    ret.rideCollectQualityCount = {
      fieldId = 19,
      dataType = 2,
      data = {}
    }
  end
  ret.weaponSkinCollectPoint = {
    fieldId = 20,
    dataType = 0,
    data = container.weaponSkinCollectPoint
  }
  if container.photosWall ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.photosWall) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.photosWall = {
      fieldId = 21,
      dataType = 2,
      data = data
    }
  else
    ret.photosWall = {
      fieldId = 21,
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
    medals = {
      __data__ = {}
    },
    actionInfo = require("zcontainer.action_info").New(),
    fashionCollectQualityCount = {
      __data__ = {}
    },
    unlockTargetRecord = {
      __data__ = {}
    },
    unlockGetRewardRecord = {
      __data__ = {}
    },
    rideCollectQualityCount = {
      __data__ = {}
    },
    photosWall = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.medals)
  setForbidenMt(ret.fashionCollectQualityCount)
  setForbidenMt(ret.unlockTargetRecord)
  setForbidenMt(ret.unlockGetRewardRecord)
  setForbidenMt(ret.rideCollectQualityCount)
  setForbidenMt(ret.photosWall)
  return ret
end
return {New = new}
