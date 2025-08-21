local br = require("sync.blob_reader")
local mergeDataFuncs = {}
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
  if not pbData.payOrderList then
    container.__data__.payOrderList = {}
  end
  if not pbData.payRefundList then
    container.__data__.payRefundList = {}
  end
  if not pbData.firstPay then
    container.__data__.firstPay = {}
  end
  if not pbData.orderList then
    container.__data__.orderList = {}
  end
  if not pbData.orderIndexList then
    container.__data__.orderIndexList = {}
  end
  setForbidenMt(container)
  container.firstPay:ResetData(pbData.firstPay)
  container.__data__.firstPay = nil
  container.orderList.__data__ = pbData.orderList
  setForbidenMt(container.orderList)
  container.__data__.orderList = nil
  container.orderIndexList.__data__ = pbData.orderIndexList
  setForbidenMt(container.orderIndexList)
  container.__data__.orderIndexList = nil
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
  if container.payOrderList ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.payOrderList) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.payOrderList = {
      fieldId = 1,
      dataType = 3,
      data = data
    }
  else
    ret.payOrderList = {
      fieldId = 1,
      dataType = 3,
      data = {}
    }
  end
  if container.payRefundList ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.payRefundList) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.payRefundList = {
      fieldId = 2,
      dataType = 3,
      data = data
    }
  else
    ret.payRefundList = {
      fieldId = 2,
      dataType = 3,
      data = {}
    }
  end
  if container.firstPay == nil then
    ret.firstPay = {
      fieldId = 3,
      dataType = 1,
      data = nil
    }
  else
    ret.firstPay = {
      fieldId = 3,
      dataType = 1,
      data = container.firstPay:GetContainerElem()
    }
  end
  if container.orderList ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.orderList) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.orderList = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.orderList = {
      fieldId = 4,
      dataType = 2,
      data = {}
    }
  end
  if container.orderIndexList ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.orderIndexList) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.orderIndexList = {
      fieldId = 5,
      dataType = 2,
      data = data
    }
  else
    ret.orderIndexList = {
      fieldId = 5,
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
    firstPay = require("zcontainer.pay_data").New(),
    orderList = {
      __data__ = {}
    },
    orderIndexList = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.orderList)
  setForbidenMt(ret.orderIndexList)
  return ret
end
return {New = new}
