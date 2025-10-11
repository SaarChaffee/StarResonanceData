local UI = Z.UI
local super = require("ui.ui_subview_base")
local Weapon_role_main_equip_sub_pcView = class("Weapon_role_main_equip_sub_pcView", super)
local perfectEffAnimName = {
  [E.ItemQuality.Purple] = "anim_item_light_purple_tpl_perfect",
  [E.ItemQuality.Yellow] = "anim_item_light_yellow_tpl_perfect",
  [E.ItemQuality.Red] = "anim_item_light_red_tpl_perfect"
}

function Weapon_role_main_equip_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "weapon_role_main_equip_sub_pc", "weapon/weapon_role_main_equip_sub_pc", UI.ECacheLv.None)
end

function Weapon_role_main_equip_sub_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.partEquipItems_ = nil
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.professionVm_ = Z.VMMgr.GetVM("profession")
  self.weaponSkillSkinVm_ = Z.VMMgr.GetVM("weapon_skill_skin")
  self.talentSkillVm_ = Z.VMMgr.GetVM("talent_skill")
  self.funcVm_ = Z.VMMgr.GetVM("gotofunc")
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.partEquipItems_ = nil
  self:refershEquipment()
end

function Weapon_role_main_equip_sub_pcView:initPartEquipItems()
  if not self.partEquipItems_ then
    local parentId = E.RedType.RoleMain
    self.partEquipItems_ = {}
    self.partEquipItems_[E.EquipPart.Weapon] = self.uiBinder.node_weap
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
          value.Ref:SetVisible(value.node_refining, isUnlock and refineIsUnlock)
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

function Weapon_role_main_equip_sub_pcView:refershEquipment()
  self:initPartEquipItems()
  local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
  Z.CoroUtil.create_coro_xpcall(function()
    for key, value in pairs(self.partEquipItems_) do
      local equipInfo = equipList[key]
      if equipInfo and equipInfo.itemUuid > 0 then
        local itemTabData = self.itemsVm_.GetItemTabDataByUuid(equipInfo.itemUuid)
        if itemTabData then
          value.Ref:SetVisible(value.img_equip_off, false)
          value.Ref:SetVisible(value.rimg_icon, true)
          local path = self.itemsVm_.GetItemIcon(itemTabData.Id)
          if key == E.EquipPart.Weapon then
            local weaponSkinId = self.weaponSkillSkinVm_:GetWeaponSkinId()
            if weaponSkinId == 0 then
              weaponSkinId = itemTabData.Id
            end
            local weaponSkinRow = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetRow(weaponSkinId)
            path = weaponSkinRow.LongIcon
          end
          value.rimg_icon:SetImage(path)
          value.Ref:SetVisible(value.rimg_quality, true)
          if key <= E.EquipPart.Shoe then
            value.rimg_quality:SetImage("ui/textures/weap_pc/weap_equip_0" .. itemTabData.Quality)
          else
            value.rimg_quality:SetImage("ui/atlas/permanent/item_quality_equip_" .. itemTabData.Quality)
          end
          value.Ref:SetVisible(value.img_damage, false)
          value.Ref:SetVisible(value.img_unlocked, false)
          local equipRow = Z.TableMgr.GetTable("EquipTableMgr").GetRow(itemTabData.Id, true)
          local animName = perfectEffAnimName[itemTabData.Quality]
          if animName and equipRow and equipRow.QualitychiIdType ~= 0 then
            value.Ref:SetVisible(value.item_perfect, true)
            value.item_perfect:PlayByTime(animName, -1)
          else
            value.Ref:SetVisible(value.item_perfect, false)
          end
          if equipRow and equipRow.EquipGs then
            value.Ref:SetVisible(value.lab_lv, true)
            value.lab_lv.text = Lang("GSEqual", {
              val = equipRow.EquipGs
            })
          else
            value.Ref:SetVisible(value.lab_lv, false)
          end
        end
      else
        value.Ref:SetVisible(value.item_perfect, false)
        value.Ref:SetVisible(value.img_damage, false)
        value.Ref:SetVisible(value.img_equip_off, true)
        value.Ref:SetVisible(value.rimg_icon, false)
        value.Ref:SetVisible(value.lab_lv, false)
        value.Ref:SetVisible(value.img_unlocked, true)
        if key <= E.EquipPart.Shoe then
          value.rimg_quality:SetImage("ui/textures/weap_pc/weap_equip_00")
        else
          value.rimg_quality:SetImage("ui/atlas/permanent/item_quality_equip_0")
        end
      end
    end
  end)()
end

function Weapon_role_main_equip_sub_pcView:OnDeActive()
end

function Weapon_role_main_equip_sub_pcView:OnRefresh()
end

return Weapon_role_main_equip_sub_pcView
