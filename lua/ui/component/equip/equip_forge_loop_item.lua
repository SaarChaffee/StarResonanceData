local super = require("ui.component.loop_list_view_item")
local EquipForgeLoopItem = class("EquipForgeLoopItem", super)
local item = require("common.item_binder")

function EquipForgeLoopItem:ctor()
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.equipSystemVm_ = Z.VMMgr.GetVM("equip_system")
end

function EquipForgeLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
end

function EquipForgeLoopItem:OnRefresh(data)
  self.isMakeState_ = self.uiView_:GetViewState()
  self.data_ = data
  local itemRow
  if self.isMakeState_ then
    itemRow = Z.TableMgr.GetRow("ItemTableMgr", data.Id)
  else
    itemRow = Z.TableMgr.GetRow("ItemTableMgr", data.ConfigId)
  end
  local isUse = false
  if itemRow then
    if not self.isMakeState_ then
      local equipInfo = self.equipSystemVm_.GetSamePartEquipAttr(itemRow.Id)
      isUse = equipInfo and equipInfo.itemUuid == data.Item.uuid
    end
    self.uiBinder.lab_name.text = itemRow.Name
    local itemVm = Z.VMMgr.GetVM("items")
    self.uiBinder.rimg_icon:SetImage(itemVm.GetItemIcon(itemRow.Id))
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_use, isUse)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function EquipForgeLoopItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  if isSelected then
    self.uiView_:OnSelectedCreateItem(self.data_)
  end
end

function EquipForgeLoopItem:OnRecycle()
end

function EquipForgeLoopItem:OnUnInit()
end

return EquipForgeLoopItem
