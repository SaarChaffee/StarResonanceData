local UI = Z.UI
local super = require("ui.ui_subview_base")
local WeaponRoleMainWeaponSubView = class("WeaponRoleMainWeaponSubView", super)
local equipPartEffectScale = {
  [E.EquipPart.Weapon] = 1,
  [E.EquipPart.Amulet] = 0.6,
  [E.EquipPart.LeftBracelet] = 0.6,
  [E.EquipPart.RightBracelet] = 0.6
}
local effectType = {Normal = 1, Special = 2}

function WeaponRoleMainWeaponSubView:ctor(parent)
  self.uiBinder = nil
  self.parent_ = parent
  super.ctor(self, "weapon_role_main_weapon_sub", "weapon/weapon_role_main_weapon_sub", UI.ECacheLv.None)
  self.partEquipItems_ = nil
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.professionVm_ = Z.VMMgr.GetVM("profession")
  self.talentSkillVm_ = Z.VMMgr.GetVM("talent_skill")
  self.funcVm_ = Z.VMMgr.GetVM("gotofunc")
end

function WeaponRoleMainWeaponSubView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:onIsPcUI()
  self:AddAsyncClick(self.uiBinder.node_talent.btn, function()
    local talentSkillVM = Z.VMMgr.GetVM("talent_skill")
    talentSkillVM.OpenTalentSkillMainWindow()
  end)
  self:AddClick(self.uiBinder.node_weapon01.btn, function()
    self.professionVm_.OpenProfessionSelectView()
  end)
  self.partEquipItems_ = nil
  self:refershEquipment()
  self:refreshWeapon()
  self:refreshTalent()
  self.uiBinder.node_talent.Ref:SetVisible(self.uiBinder.node_talent.img_red, Z.RedPointMgr.GetRedState(E.RedType.TalentRoleEnter))
end

function WeaponRoleMainWeaponSubView:OnDeActive()
end

function WeaponRoleMainWeaponSubView:onIsPcUI()
  local labSize = Z.IsPCUI and 24 or 32
  local talentText = Lang("TalentProficient")
  local weaponText = Lang("CareerChoice")
  local val_talent = Z.RichTextHelper.ApplySizeTag(talentText, labSize)
  local val_weapon = Z.RichTextHelper.ApplySizeTag(weaponText, labSize)
  self.uiBinder.lab_name_talent.text = val_talent
  self.uiBinder.lab_name_weapon.text = val_weapon
end

function WeaponRoleMainWeaponSubView:initPartEquipItems()
  if not self.partEquipItems_ then
    local parentId = E.RedType.RoleMain
    self.partEquipItems_ = {}
    self.partEquipItems_[E.EquipPart.Weapon] = self.uiBinder.node_left_weapon
    self.partEquipItems_[E.EquipPart.Helmet] = self.uiBinder.node_helmet
    self.partEquipItems_[E.EquipPart.Clothes] = self.uiBinder.node_clothes
    self.partEquipItems_[E.EquipPart.Handguards] = self.uiBinder.node_handguards
    self.partEquipItems_[E.EquipPart.Shoe] = self.uiBinder.node_shoes
    self.partEquipItems_[E.EquipPart.Earring] = self.uiBinder.node_earring
    self.partEquipItems_[E.EquipPart.Necklace] = self.uiBinder.node_necklace
    self.partEquipItems_[E.EquipPart.Ring] = self.uiBinder.node_ring
    self.partEquipItems_[E.EquipPart.Amulet] = self.uiBinder.node_amulet
    self.partEquipItems_[E.EquipPart.LeftBracelet] = self.uiBinder.node_left_bracelet
    self.partEquipItems_[E.EquipPart.RightBracelet] = self.uiBinder.node_right_bracelet
    local refineIsUnlock = self.funcVm_.FuncIsOn(E.EquipFuncId.EquipRefine, true)
    for key, value in pairs(self.partEquipItems_) do
      local nodeId = parentId .. key
      value.Ref:SetVisible(value.img_red, Z.RedPointMgr.GetRedState(nodeId))
      local equipPartRow = Z.TableMgr.GetTable("EquipPartTableMgr").GetRow(key)
      if equipPartRow then
        do
          local isUnlock = Z.ConditionHelper.CheckCondition(equipPartRow.UnlockCondition)
          value.Ref:SetVisible(value.img_lock, not isUnlock)
          local refineLevel = 0
          if Z.ContainerMgr.CharSerialize.equip.equipList[key] then
            refineLevel = Z.ContainerMgr.CharSerialize.equip.equipList[key].equipSlotRefineLevel or 0
          end
          value.lab_refining_level.text = refineLevel
          value.Ref:SetVisible(value.img_refining_level_bg, isUnlock and refineIsUnlock and refineLevel ~= 0)
          for _, condition in ipairs(equipPartRow.UnlockCondition) do
            if condition[1] == E.ConditionType.Level then
              value.lab_lock.text = Lang("Grade", {
                val = condition[2]
              })
            end
          end
          self:AddClick(value.btn, function()
            if Z.ConditionHelper.CheckCondition(equipPartRow.UnlockCondition, true) then
              local viewData = {itemUuid = 0, prtId = key}
              self.equipVm_.OpenChangeEquipView(viewData)
            end
          end)
        end
      end
    end
  end
end

function WeaponRoleMainWeaponSubView:refershEquipment()
  self:initPartEquipItems()
  local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
  Z.CoroUtil.create_coro_xpcall(function()
    for key, value in pairs(self.partEquipItems_) do
      local equipInfo = equipList[key]
      if equipInfo and equipInfo.itemUuid > 0 then
        local itemTabData = self.itemsVm_.GetItemTabDataByUuid(equipInfo.itemUuid)
        local itemData = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip].items[equipInfo.itemUuid]
        if itemTabData then
          value.Ref:SetVisible(value.img_equip_off, false)
          value.Ref:SetVisible(value.rimg_equip_on, true)
          value.rimg_equip_on:SetImage(self.itemsVm_.GetItemIcon(itemTabData.Id))
          value.Ref:SetVisible(value.img_frame, true)
          value.img_frame:SetImage("ui/atlas/weap/weap_equip_btn_on" .. itemTabData.Quality)
          value.Ref:SetVisible(value.img_damage, false)
          local effectPath = Z.ConstValue.EquipEffect[itemTabData.Quality]
          if effectPath and self.equipVm_.CheckCanRecast(itemData.uuid, itemData.configId) then
            local scale = equipPartEffectScale[key] or 0.8
            if itemData.equipAttr.perfectionValue >= Z.Global.GoodEquipPerfectVal then
              local unit = self:AsyncLoadUiUnit(effectPath .. effectType.Special, "node_effect" .. key, value.node_effect.transform)
              if unit then
                unit.Trans:SetRot(0, 0, 180)
                value.node_effect:SetScale(scale, scale)
                value.Ref:SetVisible(value.node_effect, true)
              end
            end
          else
            value.Ref:SetVisible(value.node_effect, false)
          end
        end
      else
        value.Ref:SetVisible(value.node_effect, false)
        value.Ref:SetVisible(value.img_damage, false)
        value.Ref:SetVisible(value.img_equip_off, true)
        value.Ref:SetVisible(value.rimg_equip_on, false)
        value.Ref:SetVisible(value.img_frame, false)
      end
    end
  end)()
end

function WeaponRoleMainWeaponSubView:refreshWeapon()
  local weaponId = self.weaponVm_.GetCurWeapon()
  if weaponId then
    local ProfessionSystemRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(weaponId)
    if ProfessionSystemRow then
      self.uiBinder.node_weapon01.Ref:SetVisible(self.uiBinder.node_weapon01.img_talent_icon, true)
      self.uiBinder.node_weapon01.img_talent_icon:SetImage(ProfessionSystemRow.Icon)
    end
  else
    self.uiBinder.node_weapon01.Ref:SetVisible(self.uiBinder.node_weapon01.img_talent_icon, false)
  end
  self:AddClick(self.uiBinder.node_weapon01.btn, function()
    self.professionVm_.OpenProfessionSelectView()
  end)
end

function WeaponRoleMainWeaponSubView:refreshTalent()
  local vm = Z.VMMgr.GetVM("switch")
  local isUnlock = vm.CheckFuncSwitch(E.FunctionID.Talent)
  if isUnlock then
    self.uiBinder.node_talent.Ref:SetVisible(self.uiBinder.node_talent.img_talent_lock, false)
    self.uiBinder.node_talent.Ref:SetVisible(self.uiBinder.node_talent.img_talent_icon, true)
  else
    self.uiBinder.node_talent.Ref:SetVisible(self.uiBinder.node_talent.img_talent_lock, true)
    self.uiBinder.node_talent.Ref:SetVisible(self.uiBinder.node_talent.img_talent_icon, false)
  end
  local tagIcon = self.talentSkillVm_.GetWeaponnTalentTagIcon()
  if tagIcon then
    self.uiBinder.node_talent.img_talent_icon:SetImage(tagIcon)
  end
end

return WeaponRoleMainWeaponSubView
