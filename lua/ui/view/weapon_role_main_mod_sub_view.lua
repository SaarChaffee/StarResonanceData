local UI = Z.UI
local super = require("ui.ui_subview_base")
local Weapon_role_main_mod_subView = class("Weapon_role_main_mod_subView", super)
local MOD_DEFINE = require("ui.model.mod_define")
local ModItemCardTplItem = require("ui.component.mod.mod_item_card_tpl_item")

function Weapon_role_main_mod_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "weapon_role_main_mod_sub", "weapon/weapon_role_main_mod_sub", UI.ECacheLv.None)
  self.modVM_ = Z.VMMgr.GetVM("mod")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function Weapon_role_main_mod_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  local slotModInfo = {}
  if Z.ContainerMgr.CharSerialize.mod and Z.ContainerMgr.CharSerialize.mod.modSlots then
    slotModInfo = Z.ContainerMgr.CharSerialize.mod.modSlots
  end
  for i = 1, MOD_DEFINE.ModSlotMaxCount do
    local unitUIBinder = self.uiBinder["node_mod_item_card_tpl" .. i]
    local modUuid = slotModInfo[i]
    local modId
    if modUuid then
      local itemInfo = self.itemsVM_.GetItemInfo(modUuid, E.BackPackItemPackageType.Mod)
      if itemInfo then
        modId = itemInfo.configId
      end
    end
    local isUnLock, level = self.modVM_.CheckSlotIsUnlock(i)
    ModItemCardTplItem.RefreshTpl(unitUIBinder, modId, isUnLock, i, level)
    self:AddAsyncClick(unitUIBinder.img_bg, function()
      self.modVM_.EnterModView(i)
    end)
    local isRed = self.modVM_.IsHaveRedDot(i)
    unitUIBinder.Ref:SetVisible(unitUIBinder.node_reddot, isRed)
  end
  self:AddAsyncClick(self.uiBinder.btn_view_details, function()
    self.modVM_.EnterModView()
  end)
end

function Weapon_role_main_mod_subView:OnDeActive()
end

function Weapon_role_main_mod_subView:OnRefresh()
end

return Weapon_role_main_mod_subView
