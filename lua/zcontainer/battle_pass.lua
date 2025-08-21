local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.id
    container.__data__.id = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("id", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.level
    container.__data__.level = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("level", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.curexp
    container.__data__.curexp = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("curexp", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.weekExp
    container.__data__.weekExp = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("weekExp", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.expLastTime
    container.__data__.expLastTime = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("expLastTime", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.isUnlock
    container.__data__.isUnlock = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isUnlock", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.buyNormalPas
    container.__data__.buyNormalPas = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("buyNormalPas", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.buyPrimePass
    container.__data__.buyPrimePass = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("buyPrimePass", last)
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
      local v = require("zcontainer.battle_pass_award_info").New()
      v:MergeData(buffer, watcherList)
      container.award.__data__[dk] = v
      container.Watcher:MarkMapDirty("award", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.award.__data__[dk]
      container.award.__data__[dk] = nil
      container.Watcher:MarkMapDirty("award", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.award.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.battle_pass_award_info").New()
        container.award.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("award", dk, {})
    end
  end,
  [10] = function(container, buffer, watcherList)
    local last = container.__data__.isValid
    container.__data__.isValid = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isValid", last)
  end,
  [11] = function(container, buffer, watcherList)
    local last = container.__data__.isSendedMail
    container.__data__.isSendedMail = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isSendedMail", last)
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
  if not pbData.id then
    container.__data__.id = 0
  end
  if not pbData.level then
    container.__data__.level = 0
  end
  if not pbData.curexp then
    container.__data__.curexp = 0
  end
  if not pbData.weekExp then
    container.__data__.weekExp = 0
  end
  if not pbData.expLastTime then
    container.__data__.expLastTime = 0
  end
  if not pbData.isUnlock then
    container.__data__.isUnlock = false
  end
  if not pbData.buyNormalPas then
    container.__data__.buyNormalPas = false
  end
  if not pbData.buyPrimePass then
    container.__data__.buyPrimePass = false
  end
  if not pbData.award then
    container.__data__.award = {}
  end
  if not pbData.isValid then
    container.__data__.isValid = false
  end
  if not pbData.isSendedMail then
    container.__data__.isSendedMail = false
  end
  setForbidenMt(container)
  container.award.__data__ = {}
  setForbidenMt(container.award)
  for k, v in pairs(pbData.award) do
    container.award.__data__[k] = require("zcontainer.battle_pass_award_info").New()
    container.award[k]:ResetData(v)
  end
  container.__data__.award = nil
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
  ret.id = {
    fieldId = 1,
    dataType = 0,
    data = container.id
  }
  ret.level = {
    fieldId = 2,
    dataType = 0,
    data = container.level
  }
  ret.curexp = {
    fieldId = 3,
    dataType = 0,
    data = container.curexp
  }
  ret.weekExp = {
    fieldId = 4,
    dataType = 0,
    data = container.weekExp
  }
  ret.expLastTime = {
    fieldId = 5,
    dataType = 0,
    data = container.expLastTime
  }
  ret.isUnlock = {
    fieldId = 6,
    dataType = 0,
    data = container.isUnlock
  }
  ret.buyNormalPas = {
    fieldId = 7,
    dataType = 0,
    data = container.buyNormalPas
  }
  ret.buyPrimePass = {
    fieldId = 8,
    dataType = 0,
    data = container.buyPrimePass
  }
  if container.award ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.award) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 9,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 9,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.award = {
      fieldId = 9,
      dataType = 2,
      data = data
    }
  else
    ret.award = {
      fieldId = 9,
      dataType = 2,
      data = {}
    }
  end
  ret.isValid = {
    fieldId = 10,
    dataType = 0,
    data = container.isValid
  }
  ret.isSendedMail = {
    fieldId = 11,
    dataType = 0,
    data = container.isSendedMail
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    award = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.award)
  return ret
end
return {New = new}
