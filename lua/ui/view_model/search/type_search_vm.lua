local cls = {}

function cls.GetObtainWayByType(types)
  local itemTypeSearchTableMgr = Z.TableMgr.GetTable("ItemTypeSearchTableMgr")
  local itemSourceVm = Z.VMMgr.GetVM("item_source")
  local datas = {}
  local ways = {}
  for _, v in pairs(types) do
    local itemTypeSearchTable = itemTypeSearchTableMgr.GetRow(v, true)
    if itemTypeSearchTable then
      table.insert(ways, itemTypeSearchTable.FunctionId)
    end
  end
  local temp = {}
  for _, way in pairs(ways) do
    local data = itemSourceVm.GetItemSourceByWayDatas(way)
    for _, value in ipairs(data) do
      if not temp[value.functionId] then
        temp[value.functionId] = {}
      end
      local funcTab = temp[value.functionId]
      funcTab[#funcTab + 1] = value
    end
  end
  for _, value in pairs(temp) do
    local funcDatas = value
    if 1 <= #funcDatas then
      datas[#datas + 1] = funcDatas[1]
    end
  end
  table.sort(datas, function(a, b)
    return a.sortId < b.sortId
  end)
  return datas
end

return cls
