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
      local dk = br.ReadUInt32(buffer)
      local v = require("zcontainer.quest_data").New()
      v:MergeData(buffer, watcherList)
      container.questMap.__data__[dk] = v
      container.Watcher:MarkMapDirty("questMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.questMap.__data__[dk]
      container.questMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("questMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local last = container.questMap.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.quest_data").New()
        container.questMap.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("questMap", dk, {})
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
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      container.finishQuest.__data__[dk] = dv
      container.Watcher:MarkMapDirty("finishQuest", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.finishQuest.__data__[dk]
      container.finishQuest.__data__[dk] = nil
      container.Watcher:MarkMapDirty("finishQuest", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.finishQuest.__data__[dk]
      container.finishQuest.__data__[dk] = dv
      container.Watcher:MarkMapDirty("finishQuest", dk, last)
    end
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.trackingId
    container.__data__.trackingId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("trackingId", last)
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
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      container.finishResetQuest.__data__[dk] = dv
      container.Watcher:MarkMapDirty("finishResetQuest", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.finishResetQuest.__data__[dk]
      container.finishResetQuest.__data__[dk] = nil
      container.Watcher:MarkMapDirty("finishResetQuest", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      local last = container.finishResetQuest.__data__[dk]
      container.finishResetQuest.__data__[dk] = dv
      container.Watcher:MarkMapDirty("finishResetQuest", dk, last)
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
      local dk = br.ReadUInt32(buffer)
      local v = require("zcontainer.quest_history").New()
      v:MergeData(buffer, watcherList)
      container.historyMap.__data__[dk] = v
      container.Watcher:MarkMapDirty("historyMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.historyMap.__data__[dk]
      container.historyMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("historyMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local last = container.historyMap.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.quest_history").New()
        container.historyMap.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("historyMap", dk, {})
    end
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.worldQuestTimeStamp
    container.__data__.worldQuestTimeStamp = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("worldQuestTimeStamp", last)
  end,
  [7] = function(container, buffer, watcherList)
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
      local v = require("zcontainer.world_quest_info").New()
      v:MergeData(buffer, watcherList)
      container.worldQuestInfo.__data__[dk] = v
      container.Watcher:MarkMapDirty("worldQuestInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.worldQuestInfo.__data__[dk]
      container.worldQuestInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("worldQuestInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local last = container.worldQuestInfo.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.world_quest_info").New()
        container.worldQuestInfo.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("worldQuestInfo", dk, {})
    end
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
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      container.allWorldQuestList.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allWorldQuestList", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.allWorldQuestList.__data__[dk]
      container.allWorldQuestList.__data__[dk] = nil
      container.Watcher:MarkMapDirty("allWorldQuestList", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      local last = container.allWorldQuestList.__data__[dk]
      container.allWorldQuestList.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allWorldQuestList", dk, last)
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
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      container.blueWorldQuestMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("blueWorldQuestMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.blueWorldQuestMap.__data__[dk]
      container.blueWorldQuestMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("blueWorldQuestMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      local last = container.blueWorldQuestMap.__data__[dk]
      container.blueWorldQuestMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("blueWorldQuestMap", dk, last)
    end
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
      local v = require("zcontainer.world_quest_list").New()
      v:MergeData(buffer, watcherList)
      container.filterEventId.__data__[dk] = v
      container.Watcher:MarkMapDirty("filterEventId", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.filterEventId.__data__[dk]
      container.filterEventId.__data__[dk] = nil
      container.Watcher:MarkMapDirty("filterEventId", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.filterEventId.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.world_quest_list").New()
        container.filterEventId.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("filterEventId", dk, {})
    end
  end,
  [11] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.acceptQuestList
    container.__data__.acceptQuestList = t
    for i = 1, count do
      local v = br.ReadUInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("acceptQuestList", last)
    end
  end,
  [12] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.followWorldQuestList
    container.__data__.followWorldQuestList = t
    for i = 1, count do
      local v = br.ReadUInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("followWorldQuestList", last)
    end
  end,
  [13] = function(container, buffer, watcherList)
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
      container.trackOptionalQuest.__data__[dk] = dv
      container.Watcher:MarkMapDirty("trackOptionalQuest", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.trackOptionalQuest.__data__[dk]
      container.trackOptionalQuest.__data__[dk] = nil
      container.Watcher:MarkMapDirty("trackOptionalQuest", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      local last = container.trackOptionalQuest.__data__[dk]
      container.trackOptionalQuest.__data__[dk] = dv
      container.Watcher:MarkMapDirty("trackOptionalQuest", dk, last)
    end
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
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      container.finishResetQuestCount.__data__[dk] = dv
      container.Watcher:MarkMapDirty("finishResetQuestCount", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.finishResetQuestCount.__data__[dk]
      container.finishResetQuestCount.__data__[dk] = nil
      container.Watcher:MarkMapDirty("finishResetQuestCount", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      local last = container.finishResetQuestCount.__data__[dk]
      container.finishResetQuestCount.__data__[dk] = dv
      container.Watcher:MarkMapDirty("finishResetQuestCount", dk, last)
    end
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
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      container.acceptQuestMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("acceptQuestMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.acceptQuestMap.__data__[dk]
      container.acceptQuestMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("acceptQuestMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.acceptQuestMap.__data__[dk]
      container.acceptQuestMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("acceptQuestMap", dk, last)
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
  if not pbData.questMap then
    container.__data__.questMap = {}
  end
  if not pbData.finishQuest then
    container.__data__.finishQuest = {}
  end
  if not pbData.trackingId then
    container.__data__.trackingId = 0
  end
  if not pbData.finishResetQuest then
    container.__data__.finishResetQuest = {}
  end
  if not pbData.historyMap then
    container.__data__.historyMap = {}
  end
  if not pbData.worldQuestTimeStamp then
    container.__data__.worldQuestTimeStamp = 0
  end
  if not pbData.worldQuestInfo then
    container.__data__.worldQuestInfo = {}
  end
  if not pbData.allWorldQuestList then
    container.__data__.allWorldQuestList = {}
  end
  if not pbData.blueWorldQuestMap then
    container.__data__.blueWorldQuestMap = {}
  end
  if not pbData.filterEventId then
    container.__data__.filterEventId = {}
  end
  if not pbData.acceptQuestList then
    container.__data__.acceptQuestList = {}
  end
  if not pbData.followWorldQuestList then
    container.__data__.followWorldQuestList = {}
  end
  if not pbData.trackOptionalQuest then
    container.__data__.trackOptionalQuest = {}
  end
  if not pbData.finishResetQuestCount then
    container.__data__.finishResetQuestCount = {}
  end
  if not pbData.acceptQuestMap then
    container.__data__.acceptQuestMap = {}
  end
  if not pbData.version then
    container.__data__.version = 0
  end
  setForbidenMt(container)
  container.questMap.__data__ = {}
  setForbidenMt(container.questMap)
  for k, v in pairs(pbData.questMap) do
    container.questMap.__data__[k] = require("zcontainer.quest_data").New()
    container.questMap[k]:ResetData(v)
  end
  container.__data__.questMap = nil
  container.finishQuest.__data__ = pbData.finishQuest
  setForbidenMt(container.finishQuest)
  container.__data__.finishQuest = nil
  container.finishResetQuest.__data__ = pbData.finishResetQuest
  setForbidenMt(container.finishResetQuest)
  container.__data__.finishResetQuest = nil
  container.historyMap.__data__ = {}
  setForbidenMt(container.historyMap)
  for k, v in pairs(pbData.historyMap) do
    container.historyMap.__data__[k] = require("zcontainer.quest_history").New()
    container.historyMap[k]:ResetData(v)
  end
  container.__data__.historyMap = nil
  container.worldQuestInfo.__data__ = {}
  setForbidenMt(container.worldQuestInfo)
  for k, v in pairs(pbData.worldQuestInfo) do
    container.worldQuestInfo.__data__[k] = require("zcontainer.world_quest_info").New()
    container.worldQuestInfo[k]:ResetData(v)
  end
  container.__data__.worldQuestInfo = nil
  container.allWorldQuestList.__data__ = pbData.allWorldQuestList
  setForbidenMt(container.allWorldQuestList)
  container.__data__.allWorldQuestList = nil
  container.blueWorldQuestMap.__data__ = pbData.blueWorldQuestMap
  setForbidenMt(container.blueWorldQuestMap)
  container.__data__.blueWorldQuestMap = nil
  container.filterEventId.__data__ = {}
  setForbidenMt(container.filterEventId)
  for k, v in pairs(pbData.filterEventId) do
    container.filterEventId.__data__[k] = require("zcontainer.world_quest_list").New()
    container.filterEventId[k]:ResetData(v)
  end
  container.__data__.filterEventId = nil
  container.trackOptionalQuest.__data__ = pbData.trackOptionalQuest
  setForbidenMt(container.trackOptionalQuest)
  container.__data__.trackOptionalQuest = nil
  container.finishResetQuestCount.__data__ = pbData.finishResetQuestCount
  setForbidenMt(container.finishResetQuestCount)
  container.__data__.finishResetQuestCount = nil
  container.acceptQuestMap.__data__ = pbData.acceptQuestMap
  setForbidenMt(container.acceptQuestMap)
  container.__data__.acceptQuestMap = nil
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
  if container.questMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.questMap) do
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
    ret.questMap = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.questMap = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.finishQuest ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.finishQuest) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.finishQuest = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.finishQuest = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  ret.trackingId = {
    fieldId = 3,
    dataType = 0,
    data = container.trackingId
  }
  if container.finishResetQuest ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.finishResetQuest) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.finishResetQuest = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.finishResetQuest = {
      fieldId = 4,
      dataType = 2,
      data = {}
    }
  end
  if container.historyMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.historyMap) do
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
    ret.historyMap = {
      fieldId = 5,
      dataType = 2,
      data = data
    }
  else
    ret.historyMap = {
      fieldId = 5,
      dataType = 2,
      data = {}
    }
  end
  ret.worldQuestTimeStamp = {
    fieldId = 6,
    dataType = 0,
    data = container.worldQuestTimeStamp
  }
  if container.worldQuestInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.worldQuestInfo) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 7,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 7,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.worldQuestInfo = {
      fieldId = 7,
      dataType = 2,
      data = data
    }
  else
    ret.worldQuestInfo = {
      fieldId = 7,
      dataType = 2,
      data = {}
    }
  end
  if container.allWorldQuestList ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.allWorldQuestList) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.allWorldQuestList = {
      fieldId = 8,
      dataType = 2,
      data = data
    }
  else
    ret.allWorldQuestList = {
      fieldId = 8,
      dataType = 2,
      data = {}
    }
  end
  if container.blueWorldQuestMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.blueWorldQuestMap) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.blueWorldQuestMap = {
      fieldId = 9,
      dataType = 2,
      data = data
    }
  else
    ret.blueWorldQuestMap = {
      fieldId = 9,
      dataType = 2,
      data = {}
    }
  end
  if container.filterEventId ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.filterEventId) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 10,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 10,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.filterEventId = {
      fieldId = 10,
      dataType = 2,
      data = data
    }
  else
    ret.filterEventId = {
      fieldId = 10,
      dataType = 2,
      data = {}
    }
  end
  if container.acceptQuestList ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.acceptQuestList) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.acceptQuestList = {
      fieldId = 11,
      dataType = 3,
      data = data
    }
  else
    ret.acceptQuestList = {
      fieldId = 11,
      dataType = 3,
      data = {}
    }
  end
  if container.followWorldQuestList ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.followWorldQuestList) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.followWorldQuestList = {
      fieldId = 12,
      dataType = 3,
      data = data
    }
  else
    ret.followWorldQuestList = {
      fieldId = 12,
      dataType = 3,
      data = {}
    }
  end
  if container.trackOptionalQuest ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.trackOptionalQuest) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.trackOptionalQuest = {
      fieldId = 13,
      dataType = 2,
      data = data
    }
  else
    ret.trackOptionalQuest = {
      fieldId = 13,
      dataType = 2,
      data = {}
    }
  end
  if container.finishResetQuestCount ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.finishResetQuestCount) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.finishResetQuestCount = {
      fieldId = 14,
      dataType = 2,
      data = data
    }
  else
    ret.finishResetQuestCount = {
      fieldId = 14,
      dataType = 2,
      data = {}
    }
  end
  if container.acceptQuestMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.acceptQuestMap) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.acceptQuestMap = {
      fieldId = 15,
      dataType = 2,
      data = data
    }
  else
    ret.acceptQuestMap = {
      fieldId = 15,
      dataType = 2,
      data = {}
    }
  end
  ret.version = {
    fieldId = 16,
    dataType = 0,
    data = container.version
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    questMap = {
      __data__ = {}
    },
    finishQuest = {
      __data__ = {}
    },
    finishResetQuest = {
      __data__ = {}
    },
    historyMap = {
      __data__ = {}
    },
    worldQuestInfo = {
      __data__ = {}
    },
    allWorldQuestList = {
      __data__ = {}
    },
    blueWorldQuestMap = {
      __data__ = {}
    },
    filterEventId = {
      __data__ = {}
    },
    trackOptionalQuest = {
      __data__ = {}
    },
    finishResetQuestCount = {
      __data__ = {}
    },
    acceptQuestMap = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.questMap)
  setForbidenMt(ret.finishQuest)
  setForbidenMt(ret.finishResetQuest)
  setForbidenMt(ret.historyMap)
  setForbidenMt(ret.worldQuestInfo)
  setForbidenMt(ret.allWorldQuestList)
  setForbidenMt(ret.blueWorldQuestMap)
  setForbidenMt(ret.filterEventId)
  setForbidenMt(ret.trackOptionalQuest)
  setForbidenMt(ret.finishResetQuestCount)
  setForbidenMt(ret.acceptQuestMap)
  return ret
end
return {New = new}
