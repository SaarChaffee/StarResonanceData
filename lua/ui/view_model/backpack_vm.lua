local itemsTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
local itemTypeTableMgr_ = Z.TableMgr.GetTable("ItemTypeTableMgr")
local openBagView = function()
  Z.UIMgr:OpenView("backpack_main")
end
local closeBagView = function()
  Z.UIMgr:CloseView("backpack_main")
end
local asycSortPackage = function(packageType, cancelToken)
  local backPackData = Z.DataMgr.Get("backpack_data")
  if backPackData.SortState then
    return
  end
  if backPackData.LastSortTime then
    local time = backPackData.LastSortTime - Time.time
    if 0 < time then
      local param = {
        time = {
          cd = math.ceil(time)
        }
      }
      Z.TipsVM.ShowTipsLang(100105, param)
      return
    end
  end
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[packageType]
  local sortItemParamTab = {}
  local dstItemUuids = {}
  local itemCountDic = {}
  for index, item in pairs(package.items) do
    local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(item.configId)
    if itemTableRow and itemTableRow.Overlap ~= 1 then
      local overlap = itemTableRow.Overlap
      local itemKey = item.configId * 1000 .. item.bindFlag
      if itemCountDic[itemKey] == nil then
        itemCountDic[itemKey] = item.count
        dstItemUuids[itemKey] = item.uuid
      else
        local serverTime = Z.ServerTime:GetServerTime() / 1000
        if serverTime > item.coolDownExpireTime then
          if overlap == -1 then
            local param = {}
            param.srcItemUuid = item.uuid
            param.dstItemUuid = dstItemUuids[itemKey]
            table.insert(sortItemParamTab, param)
          elseif overlap > itemCountDic[itemKey] then
            itemCountDic[itemKey] = itemCountDic[itemKey] + item.count
            local param = {}
            param.srcItemUuid = item.uuid
            param.dstItemUuid = dstItemUuids[itemKey]
            table.insert(sortItemParamTab, param)
            if overlap <= itemCountDic[itemKey] then
              itemCountDic[itemKey] = itemCountDic[itemKey] - overlap
              dstItemUuids[itemKey] = item.uuid
            end
          else
            itemCountDic[itemKey] = item.count
            dstItemUuids[itemKey] = item.uuid
          end
        end
      end
    end
  end
  if table.zcount(sortItemParamTab) == 0 then
    return
  end
  backPackData.LastSortTime = Time.time + 5
  backPackData.SortState = true
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.SortPackage({packageType = packageType, itemParams = sortItemParamTab}, cancelToken)
  backPackData.SortState = false
  Z.EventMgr:Dispatch(Z.ConstValue.Backpack.SortOver)
end
local asycAddPackageCapacity = function()
  Z.TipsVM.ShowTipsLang(100102)
end
local getFirstClassSortIdList = function()
  local ret = {}
  local idShowIndexDic = {}
  local showIndexs = {}
  local itemPackageTableMgr = Z.TableMgr.GetTable("ItemPackageTableMgr")
  for _, value in pairs(itemPackageTableMgr.GetDatas()) do
    if value.Show and value.Show > 0 then
      if idShowIndexDic[value.Show] then
        logError("Please check ItemPackageTable, Show" .. value.Show .. " has  already exist !!!!!")
        table.insert(idShowIndexDic[value.Show], value.Id)
      else
        idShowIndexDic[value.Show] = {
          value.Id
        }
        table.insert(showIndexs, value.Show)
      end
    end
  end
  table.sort(showIndexs)
  local backPackData = Z.DataMgr.Get("backpack_data")
  local switchVm = Z.VMMgr.GetVM("switch")
  for _, value in pairs(showIndexs) do
    for _, id in ipairs(idShowIndexDic[value]) do
      local funcId = backPackData.ItemBackIdxToFuncId[id]
      if switchVm.CheckFuncSwitch(funcId) then
        table.insert(ret, id)
      end
    end
  end
  return ret
end
local getSecondClassSortData = function(packageId)
  local itemPackageTableMgr = Z.TableMgr.GetTable("ItemPackageTableMgr")
  local itempackageDatas = itemPackageTableMgr.GetRow(packageId)
  local ret = {}
  if itempackageDatas then
    for _, value in ipairs(itempackageDatas.Classify) do
      table.insert(ret, value)
    end
    table.sort(ret, function(left, right)
      if tonumber(left[1]) < tonumber(right[1]) then
        return true
      end
      return false
    end)
    table.insert(ret, 1, {})
  end
  return ret
end
local ret = {
  OpenBagView = openBagView,
  CloseBagView = closeBagView,
  AsycSortPackage = asycSortPackage,
  AsycAddPackageCapacity = asycAddPackageCapacity,
  GetFirstClassSortIdList = getFirstClassSortIdList,
  GetSecondClassSortData = getSecondClassSortData
}
return ret
