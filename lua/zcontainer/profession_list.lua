local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.curProfessionId
    container.__data__.curProfessionId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("curProfessionId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.curAssistProfessions
    container.__data__.curAssistProfessions = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("curAssistProfessions", last)
    end
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
      local v = require("zcontainer.profession_info").New()
      v:MergeData(buffer, watcherList)
      container.professionList.__data__[dk] = v
      container.Watcher:MarkMapDirty("professionList", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.professionList.__data__[dk]
      container.professionList.__data__[dk] = nil
      container.Watcher:MarkMapDirty("professionList", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.professionList.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.profession_info").New()
        container.professionList.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("professionList", dk, {})
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
      local v = require("zcontainer.profession_skill_info").New()
      v:MergeData(buffer, watcherList)
      container.aoyiSkillInfoMap.__data__[dk] = v
      container.Watcher:MarkMapDirty("aoyiSkillInfoMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.aoyiSkillInfoMap.__data__[dk]
      container.aoyiSkillInfoMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("aoyiSkillInfoMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.aoyiSkillInfoMap.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.profession_skill_info").New()
        container.aoyiSkillInfoMap.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("aoyiSkillInfoMap", dk, {})
    end
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.totalTalentPoints
    container.__data__.totalTalentPoints = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("totalTalentPoints", last)
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.totalTalentResetCount
    container.__data__.totalTalentResetCount = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("totalTalentResetCount", last)
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
      local v = require("zcontainer.profession_talent_info").New()
      v:MergeData(buffer, watcherList)
      container.talentList.__data__[dk] = v
      container.Watcher:MarkMapDirty("talentList", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.talentList.__data__[dk]
      container.talentList.__data__[dk] = nil
      container.Watcher:MarkMapDirty("talentList", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.talentList.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.profession_talent_info").New()
        container.talentList.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("talentList", dk, {})
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
  if not pbData.curProfessionId then
    container.__data__.curProfessionId = 0
  end
  if not pbData.curAssistProfessions then
    container.__data__.curAssistProfessions = {}
  end
  if not pbData.professionList then
    container.__data__.professionList = {}
  end
  if not pbData.aoyiSkillInfoMap then
    container.__data__.aoyiSkillInfoMap = {}
  end
  if not pbData.totalTalentPoints then
    container.__data__.totalTalentPoints = 0
  end
  if not pbData.totalTalentResetCount then
    container.__data__.totalTalentResetCount = 0
  end
  if not pbData.talentList then
    container.__data__.talentList = {}
  end
  setForbidenMt(container)
  container.professionList.__data__ = {}
  setForbidenMt(container.professionList)
  for k, v in pairs(pbData.professionList) do
    container.professionList.__data__[k] = require("zcontainer.profession_info").New()
    container.professionList[k]:ResetData(v)
  end
  container.__data__.professionList = nil
  container.aoyiSkillInfoMap.__data__ = {}
  setForbidenMt(container.aoyiSkillInfoMap)
  for k, v in pairs(pbData.aoyiSkillInfoMap) do
    container.aoyiSkillInfoMap.__data__[k] = require("zcontainer.profession_skill_info").New()
    container.aoyiSkillInfoMap[k]:ResetData(v)
  end
  container.__data__.aoyiSkillInfoMap = nil
  container.talentList.__data__ = {}
  setForbidenMt(container.talentList)
  for k, v in pairs(pbData.talentList) do
    container.talentList.__data__[k] = require("zcontainer.profession_talent_info").New()
    container.talentList[k]:ResetData(v)
  end
  container.__data__.talentList = nil
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
  ret.curProfessionId = {
    fieldId = 1,
    dataType = 0,
    data = container.curProfessionId
  }
  if container.curAssistProfessions ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.curAssistProfessions) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.curAssistProfessions = {
      fieldId = 3,
      dataType = 3,
      data = data
    }
  else
    ret.curAssistProfessions = {
      fieldId = 3,
      dataType = 3,
      data = {}
    }
  end
  if container.professionList ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.professionList) do
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
    ret.professionList = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.professionList = {
      fieldId = 4,
      dataType = 2,
      data = {}
    }
  end
  if container.aoyiSkillInfoMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.aoyiSkillInfoMap) do
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
    ret.aoyiSkillInfoMap = {
      fieldId = 7,
      dataType = 2,
      data = data
    }
  else
    ret.aoyiSkillInfoMap = {
      fieldId = 7,
      dataType = 2,
      data = {}
    }
  end
  ret.totalTalentPoints = {
    fieldId = 8,
    dataType = 0,
    data = container.totalTalentPoints
  }
  ret.totalTalentResetCount = {
    fieldId = 9,
    dataType = 0,
    data = container.totalTalentResetCount
  }
  if container.talentList ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.talentList) do
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
    ret.talentList = {
      fieldId = 10,
      dataType = 2,
      data = data
    }
  else
    ret.talentList = {
      fieldId = 10,
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
    professionList = {
      __data__ = {}
    },
    aoyiSkillInfoMap = {
      __data__ = {}
    },
    talentList = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.professionList)
  setForbidenMt(ret.aoyiSkillInfoMap)
  setForbidenMt(ret.talentList)
  return ret
end
return {New = new}
