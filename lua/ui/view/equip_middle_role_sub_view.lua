local UI = Z.UI
local super = require("ui.ui_subview_base")
local Equip_middle_role_subView = class("Equip_middle_role_subView", super)
local unitEffPathPrefix = "ui/uieffect/prefab/ui_sfx_equip/ui_sfx_quality_group_00"

function Equip_middle_role_subView:ctor(parent)
  self.panel = nil
  super.ctor(self, "equip_middle_role_sub", "equip/equip_middle_role_sub", UI.ECacheLv.None)
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function Equip_middle_role_subView:OnActive()
  self.panel.Ref:SetPosition(-57, 56)
  self:ShowEquipPartsView()
end

function Equip_middle_role_subView:ShowEquipPartsView()
  self.selectedPartId_ = nil
  self:refreshPartEquipItems()
end

function Equip_middle_role_subView:OnDeActive()
  self.partEquipItems = nil
end

function Equip_middle_role_subView:ShowReplaceEquipView(itemUuid)
  self.equipVm_.OpenChangeEquipView({
    itemUuid = itemUuid,
    prtId = self.selectedPartId_
  })
end

function Equip_middle_role_subView:initPartEquipItems()
  if not self.partEquipItems then
    self.partEquipItems = {}
    self.partEquipItems[E.EquipPart.Helmet] = self.panel.cont_helmet_part_item
    self.partEquipItems[E.EquipPart.Clothes] = self.panel.cont_clothes_part_item
    self.partEquipItems[E.EquipPart.Handguards] = self.panel.cont_handguards_part_item
    self.partEquipItems[E.EquipPart.Shoe] = self.panel.cont_shoe_part_item
    self.partEquipItems[E.EquipPart.Earring] = self.panel.cont_earring_part_item
    self.partEquipItems[E.EquipPart.Necklace] = self.panel.cont_necklace_part_item
    self.partEquipItems[E.EquipPart.Ring] = self.panel.cont_ring_part_item
    for key, value in pairs(self.partEquipItems) do
      local part = key
      self:AddClick(value.btn_equip.Btn, function()
        self:onPartEquipItemSelected(part)
      end)
    end
  end
end

function Equip_middle_role_subView:refreshPartEquipItems()
  local animName = "anim_helmet_part_item_loop_00"
  self:initPartEquipItems()
  local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
  for key, value in pairs(self.partEquipItems) do
    value:SetVisible(true)
    local equipInfo = equipList[key]
    local needHide = true
    if equipInfo then
      local itemTabData = self.itemsVm_.GetItemTabDataByUuid(equipInfo.itemUuid)
      local itemData = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip].items[equipInfo.itemUuid]
      local randomNum = math.random(1, 4)
      if itemTabData then
        value.img_icon.Img:SetImage(self.itemsVm_.GetItemIcon(itemTabData.Id))
        value.img_icon:SetVisible(true)
        value.img_defaulticon:SetVisible(false)
        value.img_bg.Img:SetImage("ui/atlas/item/prop/common_cimg_quality_" .. itemData.quality)
        value.img_damaged:SetVisible(false)
        value.group.anim:PlayByTime(string.zconcat(animName, randomNum), -1)
        value.eff_root.ZEff:CreatEFFGO(unitEffPathPrefix .. itemData.quality, Vector3.zero, true)
        needHide = false
      end
    end
    if needHide then
      value.img_icon:SetVisible(false)
      value.img_defaulticon:SetVisible(true)
    end
  end
end

function Equip_middle_role_subView:onPartEquipItemSelected(partId)
  self.selectedPartId_ = partId
  self:ShowReplaceEquipView()
end

function Equip_middle_role_subView:OnRefresh()
end

return Equip_middle_role_subView
