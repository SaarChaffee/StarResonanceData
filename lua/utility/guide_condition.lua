local GuideCondition = {}
local fashionData = Z.DataMgr.Get("fashion_data")

function GuideCondition.GuideCondition1(parm)
  for index, fashionid in ipairs(parm.parms) do
    local tab = Z.TableMgr.GetTable("ItemTableMgr").GetRow(tonumber(fashionid))
    if tab then
      local styleData = fashionData:GetWear(tab.Type)
      if styleData and tonumber(fashionid) == styleData.fashionId then
        return true
      end
    end
  end
  return false
end

function GuideCondition.GuideCondition2(parm)
  for index, viewConfigKey in ipairs(parm.parms) do
    local focusViewConfigKey = Z.UIMgr:GetFocusViewConfigKey()
    focusViewConfigKey = focusViewConfigKey or Z.ConstValue.MainViewName
    if focusViewConfigKey == viewConfigKey then
      return true
    end
  end
  return false
end

function GuideCondition.GuideCondition524(configId)
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", configId)
  if itemRow == nil then
    return
  end
  local itemTypeRow = Z.TableMgr.GetRow("ItemTypeTableMgr", itemRow.Type)
  if itemTypeRow == nil then
    return
  end
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[itemTypeRow.Package]
  for index, value in pairs(package.items) do
    if value.configId == configId then
      return true
    end
  end
  return false
end

function GuideCondition.GuideCondition525(configId)
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip]
  for _, equipInfo in pairs(Z.ContainerMgr.CharSerialize.equip.equipList) do
    if package.items[equipInfo.itemUuid] and configId == package.items[equipInfo.itemUuid].configId then
      return true
    end
  end
  return false
end

return GuideCondition
