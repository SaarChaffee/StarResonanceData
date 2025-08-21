local EquipEnchantVm = {}

function EquipEnchantVm.OpenEnchantPopupView(enchantItemConfigId, equipUuid, selectedTogType)
  Z.UIMgr:OpenView("equip_enchant_popup", {
    enchantItemConfigId = enchantItemConfigId,
    equipUuid = equipUuid,
    selectedTogType = selectedTogType
  })
end

function EquipEnchantVm.CloseEnchantPopupView()
  Z.UIMgr:CloseView("equip_enchant_popup")
end

function EquipEnchantVm.InitConfig()
  local equipConfigData = Z.DataMgr.Get("equip_config_data")
  equipConfigData:InitEquipEnchantCfg()
end

function EquipEnchantVm.GetAttrByEnchantItemRow(equipEnchantRow)
  if not equipEnchantRow then
    return {}
  end
  local fightAttrParseVM = Z.VMMgr.GetVM("fight_attr_parse")
  local tempAttrParseVM = Z.VMMgr.GetVM("temp_attr_parse")
  local buffAttrParseVM = Z.VMMgr.GetVM("buff_attr_parse")
  local tab = {}
  local index = 1
  for k, value in ipairs(equipEnchantRow.EnchantItemEffect) do
    if value[1] == E.RemodelInfoType.Attr then
      local row = fightAttrParseVM.GetFightAttrTableRow(value[2])
      if row then
        tab[index] = {
          attrName = row.OfficialName,
          attrValue = equipEnchantRow.EnchantItemPar[k][1],
          attrId = value[2]
        }
      end
    elseif value[1] == E.RemodelInfoType.Buff then
      local param = {}
      local paramArray = equipEnchantRow.EnchantItemPar[k]
      if paramArray then
        for paramIndex, paramValue in ipairs(paramArray) do
          param[paramIndex] = {paramValue}
        end
      end
      local tb = {
        desc = buffAttrParseVM.ParseBufferTips(value[2], param)
      }
      tab[index] = tb
    elseif value[1] == E.RemodelInfoType.TmpAttr then
      local desc = tempAttrParseVM.ParamTempAttr(value[2], equipEnchantRow.EnchantItemPar[k][1])
      local tb = {desc = desc}
      tab[index] = tb
    end
    index = index + 1
  end
  return tab
end

function EquipEnchantVm.GetEnchantItemByTypeAndLevel(typeId, level)
  local equipConfigData = Z.DataMgr.Get("equip_config_data")
  local equipEnchantItems = equipConfigData.EnchantItemTableData[typeId]
  if equipEnchantItems then
    return equipEnchantItems[level]
  end
end

function EquipEnchantVm.GetEnchantItemByItemIndAndLevel(enchantId, level)
  return EquipEnchantVm.GetEnchantItemByTypeAndLevel(enchantId, level)
end

function EquipEnchantVm.GetSelectedEnchantItems(equipId)
  local tab = {}
  local equipConfigData = Z.DataMgr.Get("equip_config_data")
  local itemsVm = Z.VMMgr.GetVM("items")
  local equipRow = Z.TableMgr.GetRow("EquipTableMgr", equipId)
  if equipRow and equipRow.EnchantId ~= 0 then
    local equipEnchantRows = equipConfigData.EnchantTableData[equipRow.EnchantId]
    if equipEnchantRows and equipEnchantRows[1] then
      for _, typeId in ipairs(equipEnchantRows[1].EnchantItemList) do
        local equipEnchantItems = equipConfigData.EnchantItemTableData[typeId]
        if equipEnchantItems then
          for level, value in pairs(equipEnchantItems) do
            local itemCount = itemsVm.GetItemTotalCount(value.Id)
            if 0 < itemCount then
              tab[#tab + 1] = value
            end
          end
        end
      end
    end
  end
  table.sort(tab, function(left, right)
    local leftRow = Z.TableMgr.GetRow("ItemTableMgr", left.Id)
    local rightRow = Z.TableMgr.GetRow("ItemTableMgr", right.Id)
    if leftRow and rightRow then
      if leftRow.Quality > rightRow.Quality then
        return true
      elseif rightRow.Quality > leftRow.Quality then
        return false
      end
    end
    return leftRow.Id > rightRow.Id
  end)
  return tab
end

function EquipEnchantVm.AsyncEquipEnchant(equipUuid, enchantItemConfigId, enchantType, token)
  local request = {
    equipUuid = equipUuid,
    enchantItemConfigId = enchantItemConfigId,
    enchantType = enchantType
  }
  local world_proxy = require("zproxy.world_proxy")
  local ret = world_proxy.EquipEnchant(request, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  else
    Z.TipsVM.ShowTips(150029)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.EquipEnchantResult, ret == 0)
end

return EquipEnchantVm
