local ItemMaterialVm = {}
local itemClass = require("common.item_binder")
local itemSourceVm = Z.VMMgr.GetVM("item_source")

function ItemMaterialVm.LoadMaterialItem(uiView, parent, materialList, isResident, goToCallFunc, tipsBindPressCheckComp)
  local itemMaterialPath = GetLoadAssetPath("TipsMaterialUnit")
  if itemMaterialPath == "" or itemMaterialPath == nil then
    return
  end
  if Z.IsPCUI then
    itemMaterialPath = string.zconcat(itemMaterialPath, "_pc")
  end
  local itemSquare8Path = GetLoadAssetPath("Com_Item_Square_8")
  if itemSquare8Path == "" or itemSquare8Path == nil then
    return
  end
  if Z.IsPCUI then
    itemSquare8Path = string.zconcat(itemSquare8Path, "_pc")
  end
  local itemClassTab = uiView.ItemClassTab
  for _, value in ipairs(materialList) do
    local functionId = value[1]
    local funcRow = Z.TableMgr.GetRow("FunctionTableMgr", functionId)
    if funcRow then
      do
        local unit = uiView:AsyncLoadUiUnit(itemMaterialPath, "materialFunc" .. functionId, parent.transform, uiView.cancelSource:CreateToken())
        if unit then
          uiView:AddClick(unit.btn, function()
            local data = itemSourceVm.GetSourceByFunctionId(functionId)
            if data then
              local quickJumpType = itemSourceVm.JumpToSource(data)
              if not isResident and quickJumpType ~= E.QuickJumpType.Message then
                Z.TipsVM.CloseAllNoResidentTips()
              end
              if goToCallFunc then
                goToCallFunc()
              end
            end
          end)
          unit.lab_title.text = funcRow.Name
          for index, id in ipairs(value) do
            if 1 < index then
              local name = "materialItem" .. _ .. index
              local item = uiView:AsyncLoadUiUnit(itemSquare8Path, name, unit.layout_item.transform, uiView.cancelSource:CreateToken())
              if item then
                local itemBinder = itemClass.new(uiView)
                itemClassTab[name] = itemBinder
                itemBinder:Init({
                  uiBinder = item,
                  lab = "",
                  configId = id,
                  isHideSource = uiView.viewData.isHideSource,
                  tipsBindPressCheckComp = tipsBindPressCheckComp,
                  goToCallFunc = goToCallFunc
                })
              end
            end
          end
        end
      end
    end
  end
end

function ItemMaterialVm.GetItemMaterialData(materialId)
  local consumableItemRow = Z.TableMgr.GetRow("ConsumableItemTableMgr", materialId, true)
  if consumableItemRow then
    local data = {}
    local dataIndex = 1
    local gender = Z.ContainerMgr.CharSerialize.charBase.gender
    for _, value in ipairs(consumableItemRow.GetItemList) do
      if 1 < #value then
        local itemIdList = {
          value[1]
        }
        local itemIdIndex = 2
        for index, itemId in ipairs(value) do
          if 1 < index then
            local itemRow = Z.TableMgr.GetRow("ItemTableMgr", itemId)
            if itemRow.SexLimit == 0 or gender == itemRow.SexLimit then
              itemIdList[itemIdIndex] = itemId
              itemIdIndex = itemIdIndex + 1
            end
          end
        end
        data[dataIndex] = itemIdList
        dataIndex = dataIndex + 1
      end
    end
    return data
  end
  return nil
end

function ItemMaterialVm.GetItemConsumeList(materialId)
  local consumableItemRow = Z.TableMgr.GetRow("ConsumableItemTableMgr", materialId, true)
  if consumableItemRow then
    return consumableItemRow.ConsumeList
  end
  return nil
end

return ItemMaterialVm
