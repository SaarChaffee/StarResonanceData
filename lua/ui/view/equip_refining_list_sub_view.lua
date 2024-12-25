local UI = Z.UI
local super = require("ui.ui_subview_base")
local Equip_refining_list_subView = class("Equip_refining_list_subView", super)

function Equip_refining_list_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "equip_refining_list_sub", "equip/equip_refining_list_sub", UI.ECacheLv.None)
  self.refineVm_ = Z.VMMgr.GetVM("equip_refine")
end

function Equip_refining_list_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.curPartId_ = nil
  self:initEquipPartTabUi()
  Z.EventMgr:Add(Z.ConstValue.Equip.IsHideLeftView, self.isHideLeftView, self)
  Z.EventMgr:Add(Z.ConstValue.Equip.RefinePartSuccess, self.refreshPartRefineLevel, self)
end

function Equip_refining_list_subView:initEquipPartTabUi()
  self.equipPartTabs_ = {}
  self.equipPartTabs_[E.EquipPart.Weapon] = self.uiBinder.binder_tab_item_weapon
  self.equipPartTabs_[E.EquipPart.Helmet] = self.uiBinder.binder_tab_item_helmet
  self.equipPartTabs_[E.EquipPart.Clothes] = self.uiBinder.binder_tab_item_clothes
  self.equipPartTabs_[E.EquipPart.Handguards] = self.uiBinder.binder_tab_item_handguards
  self.equipPartTabs_[E.EquipPart.Shoe] = self.uiBinder.binder_tab_item_shoes
  self.equipPartTabs_[E.EquipPart.Necklace] = self.uiBinder.binder_tab_item_necklace
  self.equipPartTabs_[E.EquipPart.Earring] = self.uiBinder.binder_tab_item_earring
  self.equipPartTabs_[E.EquipPart.Ring] = self.uiBinder.binder_tab_item_ring
  self.equipPartTabs_[E.EquipPart.LeftBracelet] = self.uiBinder.binder_tab_item_left_bracelet
  self.equipPartTabs_[E.EquipPart.RightBracelet] = self.uiBinder.binder_tab_item_right_bracelet
  self.equipPartTabs_[E.EquipPart.Amulet] = self.uiBinder.binder_tab_item_amulet
  for k, v in pairs(self.equipPartTabs_) do
    Z.RedPointMgr.LoadRedDotItem(self.refineVm_.GetRefinePartRedName(k), self, v.tog_item.transform)
    local partId = k
    v.tog_item.group = self.uiBinder.toggroup
    local equipPartRow = Z.TableMgr.GetTable("EquipPartTableMgr").GetRow(partId)
    if equipPartRow then
      do
        local isUnlock = Z.ConditionHelper.CheckCondition(equipPartRow.UnlockCondition)
        v.Ref:SetVisible(v.node_unlock, isUnlock)
        v.Ref:SetVisible(v.img_lock, not isUnlock)
        local colorA = isUnlock and 255 or 128
        v.img_icon_off:SetColor(Color.New(0.5686274509803921, 0.5686274509803921, 0.5607843137254902, colorA / 255))
        local refineLevel = 0
        if Z.ContainerMgr.CharSerialize.equip.equipList[k] then
          refineLevel = Z.ContainerMgr.CharSerialize.equip.equipList[k].equipSlotRefineLevel or 0
        end
        local str = Lang("EquipRefineLevle", {
          val = Z.RichTextHelper.ApplySizeTag(refineLevel, 30)
        })
        v.lab_refining_level_off.text = str
        v.lab_refining_level_on.text = str
        v.tog_item:AddListener(function(isOn)
          if isOn then
            if Z.ConditionHelper.CheckCondition(equipPartRow.UnlockCondition, true) then
              self:refreshEquipListByPartId(partId)
            else
              self.equipPartTabs_[self.curPartId_].tog_item.isOn = true
            end
          end
        end, nil)
      end
    end
  end
  local part = self.viewData.part or E.EquipPart.Weapon
  self.equipPartTabs_[part].tog_item.isOn = true
  self:refreshEquipListByPartId(part)
  local nowHeight = (self.uiBinder.binder_tab_item_weapon.Ref.transform.rect.height + 17) * (self.curPartId_ - E.EquipPart.Weapon + 1)
  local rectHeight = self.uiBinder.scrollview_item.transform.rect.height
  local diff = nowHeight - rectHeight
  if 0 < diff then
    self.uiBinder.scrollview_item.content:SetAnchorPosition(0, diff)
  else
    self.uiBinder.scrollview_item.content:SetAnchorPosition(0, 0)
  end
end

function Equip_refining_list_subView:refreshPartRefineLevel()
  local refineLevel = 0
  if Z.ContainerMgr.CharSerialize.equip.equipList[self.curPartId_] then
    refineLevel = Z.ContainerMgr.CharSerialize.equip.equipList[self.curPartId_].equipSlotRefineLevel or 0
  end
  local str = Lang("EquipRefineLevle", {val = refineLevel})
  self.equipPartTabs_[self.curPartId_].lab_refining_level_off.text = str
  self.equipPartTabs_[self.curPartId_].lab_refining_level_on.text = str
end

function Equip_refining_list_subView:refreshEquipListByPartId(partId)
  if partId == self.curPartId_ then
    return
  end
  if self.viewData and self.viewData.itemSelectedFunc then
    self.viewData.itemSelectedFunc(partId)
  end
  self.curPartId_ = partId
end

function Equip_refining_list_subView:isHideLeftView(isHide)
  self.uiBinder.Ref.UIComp:SetVisible(not isHide)
end

function Equip_refining_list_subView:OnDeActive()
end

function Equip_refining_list_subView:OnRefresh()
end

return Equip_refining_list_subView
