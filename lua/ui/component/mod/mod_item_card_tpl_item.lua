local ModItemCardTplItem = {}
local MOD_DEFINE = require("ui.model.mod_define")
local ModData = Z.DataMgr.Get("mod_data")

function ModItemCardTplItem.RefreshTpl(uibinder, modId, isUnLock, slotId, level)
  if modId ~= nil then
    uibinder.Ref:SetVisible(uibinder.group_device, true)
    local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(modId)
    if itemConfig then
      local itemsVm = Z.VMMgr.GetVM("items")
      uibinder.rimg_icon:SetImage(itemsVm.GetItemIcon(modId))
    end
  else
    uibinder.Ref:SetVisible(uibinder.group_device, false)
  end
  uibinder.Ref:SetVisible(uibinder.img_lock, not isUnLock)
  if slotId and isUnLock then
    uibinder.Ref:SetVisible(uibinder.img_num, true)
    local modHoleConfig = Z.TableMgr.GetTable("ModHoleTableMgr").GetRow(slotId)
    if modHoleConfig then
      uibinder.img_num:SetImage(modHoleConfig.HoleIcon)
    end
  else
    uibinder.Ref:SetVisible(uibinder.img_num, false)
  end
  uibinder.Ref:SetVisible(uibinder.lab_level, not isUnLock)
  uibinder.lab_level.text = Lang("LevelReminderTips", {val = level})
end

return ModItemCardTplItem
