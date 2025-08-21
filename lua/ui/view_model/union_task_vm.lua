local worldProxy = require("zproxy.world_proxy")
local unionResolveTableMgr_ = Z.TableMgr.GetTable("UnionResolveTableMgr")
local UnionTaskVM = {}
local CheckErrorCode = function(errCode)
  if errCode and errCode ~= 0 then
    Z.TipsVM.ShowTips(errCode)
    return false
  end
  return true
end

function UnionTaskVM:AsyncSubmitItem(itemId, num, cancelToken)
  local parma = {goodsId = itemId, goodsNum = num}
  local ret = worldProxy.SubmitGoods(parma, cancelToken)
  CheckErrorCode(ret)
  return ret
end

function UnionTaskVM:AsyncSendGo(cancelToken)
  local ret = worldProxy.SetOff(cancelToken)
  CheckErrorCode(ret)
  return ret
end

function UnionTaskVM:AsyncGetFreightAward(cancelToken)
  local ret = worldProxy.RewardFreightAward(cancelToken)
  CheckErrorCode(ret)
  return ret
end

function UnionTaskVM:AsyncCheckFreightData(callback, cancelToken)
  local ret = worldProxy.CheckRefreshGoods(cancelToken)
  CheckErrorCode(ret)
  if ret == 0 and callback then
    callback()
  end
  return ret
end

function UnionTaskVM:GetFreightData()
  return Z.ContainerMgr.CharSerialize.freightData
end

function UnionTaskVM:GetFreightNum()
  local d = self:GetFreightData()
  local r_ = 0
  if d and d.goodsValue then
    r_ = d.goodsValue
  end
  return r_
end

function UnionTaskVM:GetHasFreightAward()
  local d = self:GetFreightData()
  local r_ = false
  if d and d.canReceive then
    r_ = d.canReceive
  end
  return r_
end

function UnionTaskVM:GetHasSend()
  local d = self:GetFreightData()
  local r_ = false
  if d and d.setOff then
    r_ = d.setOff
  end
  return r_
end

function UnionTaskVM:GetCanGetRewardTime()
  local d = self:GetFreightData()
  local r_ = 0
  if d and d.canRewardTime then
    r_ = d.canRewardTime
  end
  return r_
end

function UnionTaskVM:CheckCanShowGetBtn()
  local d = self:GetFreightData()
  local r_ = 0
  if d and d.canRewardTime then
    r_ = d.canRewardTime
  else
    return false
  end
  local nowTime = Z.TimeTools.Now() / 1000
  return 0 < r_ and r_ <= nowTime and d.setOff == true or d.canReceive == true
end

function UnionTaskVM:GetResolveData()
  local itemsVm_ = Z.VMMgr.GetVM("items")
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local f = function(resultList, severDataList, type)
    for _, value in pairs(severDataList) do
      local resloveData = unionResolveTableMgr_.GetRow(value)
      if resloveData then
        local itemData = itemTableMgr.GetRow(resloveData.ItemID)
        if itemData then
          local tData = {
            resolveData = resloveData,
            itemTableData = itemData,
            offsetType = type
          }
          local dataList = resultList[type]
          dataList[#dataList + 1] = tData
        end
      end
    end
  end
  local result = {}
  local list = {
    [1] = {},
    [2] = {},
    [3] = {}
  }
  local freightData = self:GetFreightData()
  local freightGoodList = freightData.upGoodsList
  f(list, freightGoodList, 1)
  freightGoodList = freightData.keepGoodsList
  f(list, freightGoodList, 2)
  freightGoodList = freightData.downGoodsList
  f(list, freightGoodList, 3)
  for i = 1, 3 do
    local l = list[i]
    if 0 < #l then
      table.sort(l, function(a, b)
        local numA = itemsVm_.GetItemTotalCount(a.resolveData.ItemID)
        local numB = itemsVm_.GetItemTotalCount(b.resolveData.ItemID)
        if numA == numB then
          return a.resolveData.Id < b.resolveData.Id
        end
        return numA > numB
      end)
      local d = {Type = 1, OffsetType = i}
      result[#result + 1] = d
      local d2 = {
        Type = 2,
        Data = {}
      }
      result[#result + 1] = d2
      for index, value in ipairs(l) do
        if index % 5 == 0 then
          d2 = {
            Type = 2,
            Data = {}
          }
          result[#result + 1] = d2
        end
        d2.Data[#d2.Data + 1] = value
      end
    end
  end
  return result
end

function UnionTaskVM:OpenTaskView()
  Z.UIMgr:OpenView("union_task_main")
end

function UnionTaskVM:CloseTaskView()
  Z.UIMgr:CloseView("union_task_main")
end

function UnionTaskVM:GetResolveAward()
  Z.CoroUtil.create_coro_xpcall(function()
    local unionData = Z.DataMgr.Get("union_task_data")
    self:AsyncGetFreightAward(unionData.CancelSource:CreateToken())
  end)()
end

function UnionTaskVM:OpenResloveMain()
  Z.CoroUtil.create_coro_xpcall(function()
    local unionData = Z.DataMgr.Get("union_task_data")
    self:AsyncCheckFreightData(function()
      self:OpenTaskView()
    end, unionData.CancelSource:CreateToken())
  end)()
end

return UnionTaskVM
