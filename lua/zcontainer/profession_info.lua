local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.professionId
    container.__data__.professionId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("professionId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.level
    container.__data__.level = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("level", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.experience
    container.__data__.experience = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("experience", last)
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
      local v = require("zcontainer.profession_skill_info").New()
      v:MergeData(buffer, watcherList)
      container.skillInfoMap.__data__[dk] = v
      container.Watcher:MarkMapDirty("skillInfoMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.skillInfoMap.__data__[dk]
      container.skillInfoMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("skillInfoMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.skillInfoMap.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.profession_skill_info").New()
        container.skillInfoMap.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("skillInfoMap", dk, {})
    end
  end,
  [6] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.activeSkillIds
    container.__data__.activeSkillIds = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("activeSkillIds", last)
    end
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
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      container.slotSkillInfoMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("slotSkillInfoMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.slotSkillInfoMap.__data__[dk]
      container.slotSkillInfoMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("slotSkillInfoMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.slotSkillInfoMap.__data__[dk]
      container.slotSkillInfoMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("slotSkillInfoMap", dk, last)
    end
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.UseSkinId
    container.__data__.UseSkinId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("UseSkinId", last)
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
  if not pbData.professionId then
    container.__data__.professionId = 0
  end
  if not pbData.level then
    container.__data__.level = 0
  end
  if not pbData.experience then
    container.__data__.experience = 0
  end
  if not pbData.skillInfoMap then
    container.__data__.skillInfoMap = {}
  end
  if not pbData.activeSkillIds then
    container.__data__.activeSkillIds = {}
  end
  if not pbData.slotSkillInfoMap then
    container.__data__.slotSkillInfoMap = {}
  end
  if not pbData.UseSkinId then
    container.__data__.UseSkinId = 0
  end
  setForbidenMt(container)
  container.skillInfoMap.__data__ = {}
  setForbidenMt(container.skillInfoMap)
  for k, v in pairs(pbData.skillInfoMap) do
    container.skillInfoMap.__data__[k] = require("zcontainer.profession_skill_info").New()
    container.skillInfoMap[k]:ResetData(v)
  end
  container.__data__.skillInfoMap = nil
  container.slotSkillInfoMap.__data__ = pbData.slotSkillInfoMap
  setForbidenMt(container.slotSkillInfoMap)
  container.__data__.slotSkillInfoMap = nil
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
  ret.professionId = {
    fieldId = 1,
    dataType = 0,
    data = container.professionId
  }
  ret.level = {
    fieldId = 2,
    dataType = 0,
    data = container.level
  }
  ret.experience = {
    fieldId = 3,
    dataType = 0,
    data = container.experience
  }
  if container.skillInfoMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.skillInfoMap) do
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
    ret.skillInfoMap = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.skillInfoMap = {
      fieldId = 4,
      dataType = 2,
      data = {}
    }
  end
  if container.activeSkillIds ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.activeSkillIds) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.activeSkillIds = {
      fieldId = 6,
      dataType = 3,
      data = data
    }
  else
    ret.activeSkillIds = {
      fieldId = 6,
      dataType = 3,
      data = {}
    }
  end
  if container.slotSkillInfoMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.slotSkillInfoMap) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.slotSkillInfoMap = {
      fieldId = 7,
      dataType = 2,
      data = data
    }
  else
    ret.slotSkillInfoMap = {
      fieldId = 7,
      dataType = 2,
      data = {}
    }
  end
  ret.UseSkinId = {
    fieldId = 8,
    dataType = 0,
    data = container.UseSkinId
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    skillInfoMap = {
      __data__ = {}
    },
    slotSkillInfoMap = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.skillInfoMap)
  setForbidenMt(ret.slotSkillInfoMap)
  return ret
end
return {New = new}
