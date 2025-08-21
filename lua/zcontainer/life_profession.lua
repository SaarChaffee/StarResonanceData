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
      local dk = br.ReadInt32(buffer)
      local v = require("zcontainer.life_profession_basic").New()
      v:MergeData(buffer, watcherList)
      container.professionInfo.__data__[dk] = v
      container.Watcher:MarkMapDirty("professionInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.professionInfo.__data__[dk]
      container.professionInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("professionInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.professionInfo.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.life_profession_basic").New()
        container.professionInfo.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("professionInfo", dk, {})
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
      local dk = br.ReadInt32(buffer)
      local v = require("zcontainer.life_profession_target_info").New()
      v:MergeData(buffer, watcherList)
      container.lifeTargetInfo.__data__[dk] = v
      container.Watcher:MarkMapDirty("lifeTargetInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.lifeTargetInfo.__data__[dk]
      container.lifeTargetInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("lifeTargetInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.lifeTargetInfo.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.life_profession_target_info").New()
        container.lifeTargetInfo.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("lifeTargetInfo", dk, {})
    end
  end,
  [3] = function(container, buffer, watcherList)
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
      local v = require("zcontainer.life_profession_recipe").New()
      v:MergeData(buffer, watcherList)
      container.lifeProfessionRecipe.__data__[dk] = v
      container.Watcher:MarkMapDirty("lifeProfessionRecipe", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.lifeProfessionRecipe.__data__[dk]
      container.lifeProfessionRecipe.__data__[dk] = nil
      container.Watcher:MarkMapDirty("lifeProfessionRecipe", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.lifeProfessionRecipe.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.life_profession_recipe").New()
        container.lifeProfessionRecipe.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("lifeProfessionRecipe", dk, {})
    end
  end,
  [4] = function(container, buffer, watcherList)
    container.lifeProfessionAlchemyInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("lifeProfessionAlchemyInfo", {})
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
      container.spareEnergy.__data__[dk] = dv
      container.Watcher:MarkMapDirty("spareEnergy", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.spareEnergy.__data__[dk]
      container.spareEnergy.__data__[dk] = nil
      container.Watcher:MarkMapDirty("spareEnergy", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.spareEnergy.__data__[dk]
      container.spareEnergy.__data__[dk] = dv
      container.Watcher:MarkMapDirty("spareEnergy", dk, last)
    end
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.point
    container.__data__.point = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("point", last)
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
  if not pbData.professionInfo then
    container.__data__.professionInfo = {}
  end
  if not pbData.lifeTargetInfo then
    container.__data__.lifeTargetInfo = {}
  end
  if not pbData.lifeProfessionRecipe then
    container.__data__.lifeProfessionRecipe = {}
  end
  if not pbData.lifeProfessionAlchemyInfo then
    container.__data__.lifeProfessionAlchemyInfo = {}
  end
  if not pbData.spareEnergy then
    container.__data__.spareEnergy = {}
  end
  if not pbData.point then
    container.__data__.point = 0
  end
  setForbidenMt(container)
  container.professionInfo.__data__ = {}
  setForbidenMt(container.professionInfo)
  for k, v in pairs(pbData.professionInfo) do
    container.professionInfo.__data__[k] = require("zcontainer.life_profession_basic").New()
    container.professionInfo[k]:ResetData(v)
  end
  container.__data__.professionInfo = nil
  container.lifeTargetInfo.__data__ = {}
  setForbidenMt(container.lifeTargetInfo)
  for k, v in pairs(pbData.lifeTargetInfo) do
    container.lifeTargetInfo.__data__[k] = require("zcontainer.life_profession_target_info").New()
    container.lifeTargetInfo[k]:ResetData(v)
  end
  container.__data__.lifeTargetInfo = nil
  container.lifeProfessionRecipe.__data__ = {}
  setForbidenMt(container.lifeProfessionRecipe)
  for k, v in pairs(pbData.lifeProfessionRecipe) do
    container.lifeProfessionRecipe.__data__[k] = require("zcontainer.life_profession_recipe").New()
    container.lifeProfessionRecipe[k]:ResetData(v)
  end
  container.__data__.lifeProfessionRecipe = nil
  container.lifeProfessionAlchemyInfo:ResetData(pbData.lifeProfessionAlchemyInfo)
  container.__data__.lifeProfessionAlchemyInfo = nil
  container.spareEnergy.__data__ = pbData.spareEnergy
  setForbidenMt(container.spareEnergy)
  container.__data__.spareEnergy = nil
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
  if container.professionInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.professionInfo) do
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
    ret.professionInfo = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.professionInfo = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.lifeTargetInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.lifeTargetInfo) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 2,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 2,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.lifeTargetInfo = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.lifeTargetInfo = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.lifeProfessionRecipe ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.lifeProfessionRecipe) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 3,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 3,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.lifeProfessionRecipe = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.lifeProfessionRecipe = {
      fieldId = 3,
      dataType = 2,
      data = {}
    }
  end
  if container.lifeProfessionAlchemyInfo == nil then
    ret.lifeProfessionAlchemyInfo = {
      fieldId = 4,
      dataType = 1,
      data = nil
    }
  else
    ret.lifeProfessionAlchemyInfo = {
      fieldId = 4,
      dataType = 1,
      data = container.lifeProfessionAlchemyInfo:GetContainerElem()
    }
  end
  if container.spareEnergy ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.spareEnergy) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.spareEnergy = {
      fieldId = 5,
      dataType = 2,
      data = data
    }
  else
    ret.spareEnergy = {
      fieldId = 5,
      dataType = 2,
      data = {}
    }
  end
  ret.point = {
    fieldId = 6,
    dataType = 0,
    data = container.point
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    professionInfo = {
      __data__ = {}
    },
    lifeTargetInfo = {
      __data__ = {}
    },
    lifeProfessionRecipe = {
      __data__ = {}
    },
    lifeProfessionAlchemyInfo = require("zcontainer.life_profession_alchemy_info").New(),
    spareEnergy = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.professionInfo)
  setForbidenMt(ret.lifeTargetInfo)
  setForbidenMt(ret.lifeProfessionRecipe)
  setForbidenMt(ret.spareEnergy)
  return ret
end
return {New = new}
