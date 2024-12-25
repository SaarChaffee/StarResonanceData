local ModItemTplItem = {}
local MOD_DEFINE = require("ui.model.mod_define")
local item = require("common.item_binder")

function ModItemTplItem.RefreshTpl(uibinder, slotId, itemClass, view)
  local modVM = Z.VMMgr.GetVM("mod")
  local unlock, level = modVM.CheckSlotIsUnlock(slotId)
  if unlock then
    uibinder.Ref:SetVisible(uibinder.img_normal, true)
    uibinder.Ref:SetVisible(uibinder.img_lock, false)
    local slotModInfo = {}
    if Z.ContainerMgr.CharSerialize.mod and Z.ContainerMgr.CharSerialize.mod.modSlots then
      slotModInfo = Z.ContainerMgr.CharSerialize.mod.modSlots
    end
    local modUuid = slotModInfo[slotId]
    local modId
    if modUuid then
      local itemsVM = Z.VMMgr.GetVM("items")
      local itemInfo = itemsVM.GetItemInfo(modUuid, E.BackPackItemPackageType.Mod)
      if itemInfo then
        modId = itemInfo.configId
      end
      uibinder.Ref:SetVisible(uibinder.lab_num, false)
      uibinder.node_item_round.Ref.UIComp:SetVisible(true)
      if itemClass == nil then
        itemClass = item.new(view)
      end
      itemClass:InitCircleItem(uibinder.node_item_round, modId, modUuid, nil, nil, Z.ConstValue.QualityImgRoundBg)
      uibinder.Ref:SetVisible(uibinder.img_num, true)
      return itemClass
    else
      uibinder.Ref:SetVisible(uibinder.lab_num, true)
      uibinder.node_item_round.Ref.UIComp:SetVisible(false)
      uibinder.lab_num.text = slotId
      uibinder.Ref:SetVisible(uibinder.img_num, false)
    end
  else
    uibinder.Ref:SetVisible(uibinder.img_normal, false)
    uibinder.Ref:SetVisible(uibinder.img_lock, true)
    uibinder.Ref:SetVisible(uibinder.img_num, false)
    uibinder.lab_lv.text = Lang("Grade", {val = level})
  end
end

return ModItemTplItem
