local super = require("ui.component.equip.new_default_equip_loop_list_item")
local EquipQualityvalDecomTips = Z.Global.EquipQualityvalDecomTips or 3
local EquipPerfectvalDecomTips = Z.Global.EquipPerfectvalDecomTips
local EquipDecomposeLoopListItem = class("EquipRepairItemsLoopItem", super)

function EquipDecomposeLoopListItem:ctor()
  self.itemData_ = nil
  super:ctor()
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.equipSystemVm_ = Z.VMMgr.GetVM("equip_system")
end

function EquipDecomposeLoopListItem:Refresh(data)
  self.super.Refresh(self, data)
  self.uiView = self.parent.UIView
  if self.uiView:IsNeedSelected(self.uuid_) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_more_selected, true)
    self.parent:SelectIndex(self.Index - 1)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
end

function EquipDecomposeLoopListItem:OnSelected(isSelected)
  if self.uiView:IsNeedSelected(self.uuid_) and isSelected then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_more_selected, true)
    return
  end
  local func = function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_more_selected, isSelected)
    local uiView = self.parent.UIView
    uiView:ItemSelected(self.uuid_, self.configId, isSelected)
  end
  if isSelected then
    local itemInfo = self.itemsVm_.GetItemInfo(self.uuid_, E.BackPackItemPackageType.Equip)
    if itemInfo then
      local func1 = function()
        local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemInfo.configId)
        if itemConfig and itemConfig.Quality > EquipQualityvalDecomTips then
          local onCanel = function()
            self.parent:UnSelectIndex(self.Index)
          end
          local data = {
            dlgType = E.DlgType.YesNo,
            onConfirm = func,
            labDesc = Lang("EquipDecomposeHighQualityTips"),
            onCancel = onCanel
          }
          Z.DialogViewDataMgr:OpenDialogView(data)
        elseif self.equipSystemVm_.CheckCanRecast(nil, self.configId) and itemInfo.equipAttr.perfectionValue > EquipPerfectvalDecomTips then
          self.equipVm_.OpenDayDialog(func, Lang("EquipEquipPerfectvalDecomposeTips", {val = EquipPerfectvalDecomTips}), E.DlgPreferencesKeyType.EquipEquipDecomposeTips, function()
            self.parent:UnSelectIndex(self.Index)
          end)
        else
          func()
        end
      end
      if self.equipSystemVm_.CheckIsFocusEquip(self.configId) then
        self.equipVm_.OpenDayDialog(func1, Lang("EquipBreakDownRareEquipTips"), E.DlgPreferencesKeyType.EquipBreakDownRareEquipTips, function()
          self.parent:UnSelectIndex(self.Index)
        end)
      else
        func1()
      end
    else
      func()
    end
  else
    func()
  end
end

return EquipDecomposeLoopListItem
