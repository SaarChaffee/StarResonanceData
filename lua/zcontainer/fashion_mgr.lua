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
      local dv = br.ReadInt32(buffer)
      container.wearInfo.__data__[dk] = dv
      container.Watcher:MarkMapDirty("wearInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.wearInfo.__data__[dk]
      container.wearInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("wearInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.wearInfo.__data__[dk]
      container.wearInfo.__data__[dk] = dv
      container.Watcher:MarkMapDirty("wearInfo", dk, last)
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
      local v = require("zcontainer.fashion_color_info").New()
      v:MergeData(buffer, watcherList)
      container.fashionDatas.__data__[dk] = v
      container.Watcher:MarkMapDirty("fashionDatas", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.fashionDatas.__data__[dk]
      container.fashionDatas.__data__[dk] = nil
      container.Watcher:MarkMapDirty("fashionDatas", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.fashionDatas.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.fashion_color_info").New()
        container.fashionDatas.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("fashionDatas", dk, {})
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
      local v = require("zcontainer.unlock_color_info").New()
      v:MergeData(buffer, watcherList)
      container.UnlockColor.__data__[dk] = v
      container.Watcher:MarkMapDirty("UnlockColor", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.UnlockColor.__data__[dk]
      container.UnlockColor.__data__[dk] = nil
      container.Watcher:MarkMapDirty("UnlockColor", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.UnlockColor.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.unlock_color_info").New()
        container.UnlockColor.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("UnlockColor", dk, {})
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
      local dv = br.ReadBoolean(buffer)
      container.fashionReward.__data__[dk] = dv
      container.Watcher:MarkMapDirty("fashionReward", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.fashionReward.__data__[dk]
      container.fashionReward.__data__[dk] = nil
      container.Watcher:MarkMapDirty("fashionReward", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.fashionReward.__data__[dk]
      container.fashionReward.__data__[dk] = dv
      container.Watcher:MarkMapDirty("fashionReward", dk, last)
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
      local dv = br.ReadBoolean(buffer)
      container.allFashion.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allFashion", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.allFashion.__data__[dk]
      container.allFashion.__data__[dk] = nil
      container.Watcher:MarkMapDirty("allFashion", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.allFashion.__data__[dk]
      container.allFashion.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allFashion", dk, last)
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
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      container.allRide.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allRide", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.allRide.__data__[dk]
      container.allRide.__data__[dk] = nil
      container.Watcher:MarkMapDirty("allRide", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.allRide.__data__[dk]
      container.allRide.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allRide", dk, last)
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
      local dv = br.ReadBoolean(buffer)
      container.allWeaponSkin.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allWeaponSkin", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.allWeaponSkin.__data__[dk]
      container.allWeaponSkin.__data__[dk] = nil
      container.Watcher:MarkMapDirty("allWeaponSkin", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.allWeaponSkin.__data__[dk]
      container.allWeaponSkin.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allWeaponSkin", dk, last)
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
      local dk = br.ReadInt32(buffer)
      local v = require("zcontainer.fashion_advance_info").New()
      v:MergeData(buffer, watcherList)
      container.fashionAdvance.__data__[dk] = v
      container.Watcher:MarkMapDirty("fashionAdvance", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.fashionAdvance.__data__[dk]
      container.fashionAdvance.__data__[dk] = nil
      container.Watcher:MarkMapDirty("fashionAdvance", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.fashionAdvance.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.fashion_advance_info").New()
        container.fashionAdvance.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("fashionAdvance", dk, {})
    end
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.fashionCollectPoint
    container.__data__.fashionCollectPoint = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("fashionCollectPoint", last)
  end,
  [10] = function(container, buffer, watcherList)
    local last = container.__data__.rideCollectPoint
    container.__data__.rideCollectPoint = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("rideCollectPoint", last)
  end,
  [11] = function(container, buffer, watcherList)
    local last = container.__data__.weaponSkinCollectPoint
    container.__data__.weaponSkinCollectPoint = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("weaponSkinCollectPoint", last)
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
      container.allFashionNum.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allFashionNum", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.allFashionNum.__data__[dk]
      container.allFashionNum.__data__[dk] = nil
      container.Watcher:MarkMapDirty("allFashionNum", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.allFashionNum.__data__[dk]
      container.allFashionNum.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allFashionNum", dk, last)
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
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      container.allRideNum.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allRideNum", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.allRideNum.__data__[dk]
      container.allRideNum.__data__[dk] = nil
      container.Watcher:MarkMapDirty("allRideNum", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.allRideNum.__data__[dk]
      container.allRideNum.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allRideNum", dk, last)
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
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      container.allWeaponSkinNum.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allWeaponSkinNum", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.allWeaponSkinNum.__data__[dk]
      container.allWeaponSkinNum.__data__[dk] = nil
      container.Watcher:MarkMapDirty("allWeaponSkinNum", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.allWeaponSkinNum.__data__[dk]
      container.allWeaponSkinNum.__data__[dk] = dv
      container.Watcher:MarkMapDirty("allWeaponSkinNum", dk, last)
    end
  end,
  [15] = function(container, buffer, watcherList)
    local last = container.__data__.isFashionInit
    container.__data__.isFashionInit = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isFashionInit", last)
  end,
  [16] = function(container, buffer, watcherList)
    local last = container.__data__.isRideInit
    container.__data__.isRideInit = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isRideInit", last)
  end,
  [17] = function(container, buffer, watcherList)
    local last = container.__data__.isWeaponSkinInit
    container.__data__.isWeaponSkinInit = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isWeaponSkinInit", last)
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
  if not pbData.wearInfo then
    container.__data__.wearInfo = {}
  end
  if not pbData.fashionDatas then
    container.__data__.fashionDatas = {}
  end
  if not pbData.UnlockColor then
    container.__data__.UnlockColor = {}
  end
  if not pbData.fashionReward then
    container.__data__.fashionReward = {}
  end
  if not pbData.allFashion then
    container.__data__.allFashion = {}
  end
  if not pbData.allRide then
    container.__data__.allRide = {}
  end
  if not pbData.allWeaponSkin then
    container.__data__.allWeaponSkin = {}
  end
  if not pbData.fashionAdvance then
    container.__data__.fashionAdvance = {}
  end
  if not pbData.fashionCollectPoint then
    container.__data__.fashionCollectPoint = 0
  end
  if not pbData.rideCollectPoint then
    container.__data__.rideCollectPoint = 0
  end
  if not pbData.weaponSkinCollectPoint then
    container.__data__.weaponSkinCollectPoint = 0
  end
  if not pbData.allFashionNum then
    container.__data__.allFashionNum = {}
  end
  if not pbData.allRideNum then
    container.__data__.allRideNum = {}
  end
  if not pbData.allWeaponSkinNum then
    container.__data__.allWeaponSkinNum = {}
  end
  if not pbData.isFashionInit then
    container.__data__.isFashionInit = false
  end
  if not pbData.isRideInit then
    container.__data__.isRideInit = false
  end
  if not pbData.isWeaponSkinInit then
    container.__data__.isWeaponSkinInit = false
  end
  setForbidenMt(container)
  container.wearInfo.__data__ = pbData.wearInfo
  setForbidenMt(container.wearInfo)
  container.__data__.wearInfo = nil
  container.fashionDatas.__data__ = {}
  setForbidenMt(container.fashionDatas)
  for k, v in pairs(pbData.fashionDatas) do
    container.fashionDatas.__data__[k] = require("zcontainer.fashion_color_info").New()
    container.fashionDatas[k]:ResetData(v)
  end
  container.__data__.fashionDatas = nil
  container.UnlockColor.__data__ = {}
  setForbidenMt(container.UnlockColor)
  for k, v in pairs(pbData.UnlockColor) do
    container.UnlockColor.__data__[k] = require("zcontainer.unlock_color_info").New()
    container.UnlockColor[k]:ResetData(v)
  end
  container.__data__.UnlockColor = nil
  container.fashionReward.__data__ = pbData.fashionReward
  setForbidenMt(container.fashionReward)
  container.__data__.fashionReward = nil
  container.allFashion.__data__ = pbData.allFashion
  setForbidenMt(container.allFashion)
  container.__data__.allFashion = nil
  container.allRide.__data__ = pbData.allRide
  setForbidenMt(container.allRide)
  container.__data__.allRide = nil
  container.allWeaponSkin.__data__ = pbData.allWeaponSkin
  setForbidenMt(container.allWeaponSkin)
  container.__data__.allWeaponSkin = nil
  container.fashionAdvance.__data__ = {}
  setForbidenMt(container.fashionAdvance)
  for k, v in pairs(pbData.fashionAdvance) do
    container.fashionAdvance.__data__[k] = require("zcontainer.fashion_advance_info").New()
    container.fashionAdvance[k]:ResetData(v)
  end
  container.__data__.fashionAdvance = nil
  container.allFashionNum.__data__ = pbData.allFashionNum
  setForbidenMt(container.allFashionNum)
  container.__data__.allFashionNum = nil
  container.allRideNum.__data__ = pbData.allRideNum
  setForbidenMt(container.allRideNum)
  container.__data__.allRideNum = nil
  container.allWeaponSkinNum.__data__ = pbData.allWeaponSkinNum
  setForbidenMt(container.allWeaponSkinNum)
  container.__data__.allWeaponSkinNum = nil
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
  if container.wearInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.wearInfo) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.wearInfo = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.wearInfo = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.fashionDatas ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.fashionDatas) do
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
    ret.fashionDatas = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.fashionDatas = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.UnlockColor ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.UnlockColor) do
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
    ret.UnlockColor = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.UnlockColor = {
      fieldId = 3,
      dataType = 2,
      data = {}
    }
  end
  if container.fashionReward ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.fashionReward) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.fashionReward = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.fashionReward = {
      fieldId = 4,
      dataType = 2,
      data = {}
    }
  end
  if container.allFashion ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.allFashion) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.allFashion = {
      fieldId = 5,
      dataType = 2,
      data = data
    }
  else
    ret.allFashion = {
      fieldId = 5,
      dataType = 2,
      data = {}
    }
  end
  if container.allRide ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.allRide) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.allRide = {
      fieldId = 6,
      dataType = 2,
      data = data
    }
  else
    ret.allRide = {
      fieldId = 6,
      dataType = 2,
      data = {}
    }
  end
  if container.allWeaponSkin ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.allWeaponSkin) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.allWeaponSkin = {
      fieldId = 7,
      dataType = 2,
      data = data
    }
  else
    ret.allWeaponSkin = {
      fieldId = 7,
      dataType = 2,
      data = {}
    }
  end
  if container.fashionAdvance ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.fashionAdvance) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 8,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 8,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.fashionAdvance = {
      fieldId = 8,
      dataType = 2,
      data = data
    }
  else
    ret.fashionAdvance = {
      fieldId = 8,
      dataType = 2,
      data = {}
    }
  end
  ret.fashionCollectPoint = {
    fieldId = 9,
    dataType = 0,
    data = container.fashionCollectPoint
  }
  ret.rideCollectPoint = {
    fieldId = 10,
    dataType = 0,
    data = container.rideCollectPoint
  }
  ret.weaponSkinCollectPoint = {
    fieldId = 11,
    dataType = 0,
    data = container.weaponSkinCollectPoint
  }
  if container.allFashionNum ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.allFashionNum) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.allFashionNum = {
      fieldId = 12,
      dataType = 2,
      data = data
    }
  else
    ret.allFashionNum = {
      fieldId = 12,
      dataType = 2,
      data = {}
    }
  end
  if container.allRideNum ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.allRideNum) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.allRideNum = {
      fieldId = 13,
      dataType = 2,
      data = data
    }
  else
    ret.allRideNum = {
      fieldId = 13,
      dataType = 2,
      data = {}
    }
  end
  if container.allWeaponSkinNum ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.allWeaponSkinNum) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.allWeaponSkinNum = {
      fieldId = 14,
      dataType = 2,
      data = data
    }
  else
    ret.allWeaponSkinNum = {
      fieldId = 14,
      dataType = 2,
      data = {}
    }
  end
  ret.isFashionInit = {
    fieldId = 15,
    dataType = 0,
    data = container.isFashionInit
  }
  ret.isRideInit = {
    fieldId = 16,
    dataType = 0,
    data = container.isRideInit
  }
  ret.isWeaponSkinInit = {
    fieldId = 17,
    dataType = 0,
    data = container.isWeaponSkinInit
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    wearInfo = {
      __data__ = {}
    },
    fashionDatas = {
      __data__ = {}
    },
    UnlockColor = {
      __data__ = {}
    },
    fashionReward = {
      __data__ = {}
    },
    allFashion = {
      __data__ = {}
    },
    allRide = {
      __data__ = {}
    },
    allWeaponSkin = {
      __data__ = {}
    },
    fashionAdvance = {
      __data__ = {}
    },
    allFashionNum = {
      __data__ = {}
    },
    allRideNum = {
      __data__ = {}
    },
    allWeaponSkinNum = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.wearInfo)
  setForbidenMt(ret.fashionDatas)
  setForbidenMt(ret.UnlockColor)
  setForbidenMt(ret.fashionReward)
  setForbidenMt(ret.allFashion)
  setForbidenMt(ret.allRide)
  setForbidenMt(ret.allWeaponSkin)
  setForbidenMt(ret.fashionAdvance)
  setForbidenMt(ret.allFashionNum)
  setForbidenMt(ret.allRideNum)
  setForbidenMt(ret.allWeaponSkinNum)
  return ret
end
return {New = new}
