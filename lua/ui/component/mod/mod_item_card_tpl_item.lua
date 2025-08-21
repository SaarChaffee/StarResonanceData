local ModItemCardTplItem = {}
local MOD_DEFINE = require("ui.model.mod_define")
local ModData = Z.DataMgr.Get("mod_data")

function ModItemCardTplItem.RefreshTpl(uibinder, modId, isUnLock, slotId, param)
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
  if Z.IsPCUI then
    uibinder.Ref:SetVisible(uibinder.img_num, isUnLock and slotId and modId == nil)
  elseif slotId and isUnLock then
    uibinder.Ref:SetVisible(uibinder.img_num, true)
    local modHoleConfig = Z.TableMgr.GetTable("ModHoleTableMgr").GetRow(slotId)
    if modHoleConfig then
      uibinder.img_num:SetImage(modHoleConfig.HoleIcon)
    end
  else
    uibinder.Ref:SetVisible(uibinder.img_num, false)
  end
  uibinder.Ref:SetVisible(uibinder.lab_level, not isUnLock)
  if not isUnLock then
    if param.condType == E.ConditionType.Level then
      uibinder.lab_level.text = Lang("Grade", {
        val = param.condValue
      })
    elseif param.condType == E.ConditionType.TimeInterval then
      uibinder.lab_level.text = Z.TimeFormatTools.FormatToDHMS(param.progress)
    else
      uibinder.lab_level.text = param.unlockDesc
    end
  end
end

return ModItemCardTplItem
