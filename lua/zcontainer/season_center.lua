local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.seasonId
    container.__data__.seasonId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("seasonId", last)
  end,
  [2] = function(container, buffer, watcherList)
    container.battlePass:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("battlePass", {})
  end,
  [3] = function(container, buffer, watcherList)
    container.bpQuestList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("bpQuestList", {})
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
  if not pbData.seasonId then
    container.__data__.seasonId = 0
  end
  if not pbData.battlePass then
    container.__data__.battlePass = {}
  end
  if not pbData.bpQuestList then
    container.__data__.bpQuestList = {}
  end
  if not pbData.seasonHistory then
    container.__data__.seasonHistory = {}
  end
  setForbidenMt(container)
  container.battlePass:ResetData(pbData.battlePass)
  container.__data__.battlePass = nil
  container.bpQuestList:ResetData(pbData.bpQuestList)
  container.__data__.bpQuestList = nil
  container.seasonHistory.__data__ = {}
  setForbidenMt(container.seasonHistory)
  for k, v in pairs(pbData.seasonHistory) do
    container.seasonHistory.__data__[k] = require("zcontainer.season_center_history").New()
    container.seasonHistory[k]:ResetData(v)
  end
  container.__data__.seasonHistory = nil
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
  ret.seasonId = {
    fieldId = 1,
    dataType = 0,
    data = container.seasonId
  }
  if container.battlePass == nil then
    ret.battlePass = {
      fieldId = 2,
      dataType = 1,
      data = nil
    }
  else
    ret.battlePass = {
      fieldId = 2,
      dataType = 1,
      data = container.battlePass:GetContainerElem()
    }
  end
  if container.bpQuestList == nil then
    ret.bpQuestList = {
      fieldId = 3,
      dataType = 1,
      data = nil
    }
  else
    ret.bpQuestList = {
      fieldId = 3,
      dataType = 1,
      data = container.bpQuestList:GetContainerElem()
    }
  end
  if container.seasonHistory ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.seasonHistory) do
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
    ret.seasonHistory = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.seasonHistory = {
      fieldId = 4,
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
    battlePass = require("zcontainer.battle_pass").New(),
    bpQuestList = require("zcontainer.season_bp_quest_list").New(),
    seasonHistory = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.seasonHistory)
  return ret
end
return {New = new}
