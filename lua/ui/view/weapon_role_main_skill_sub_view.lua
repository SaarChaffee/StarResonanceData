local UI = Z.UI
local super = require("ui.ui_subview_base")
local Weapon_role_main_skill_subView = class("Weapon_role_main_skill_subView", super)
local inputKeyDescComp = require("input.input_key_desc_comp")

function Weapon_role_main_skill_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "weapon_role_main_skill_sub", "weapon/weapon_role_main_skill_sub", UI.ECacheLv.None, true)
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function Weapon_role_main_skill_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.weaponId_ = self.weaponVm_.GetCurWeapon()
  self.professionVm_ = Z.VMMgr.GetVM("profession")
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.skillInputKeyDescComps_ = {}
  if self.uiBinder.btn_look then
    self:AddAsyncClick(self.uiBinder.btn_look, function()
      self.weaponSkillVm_.OpenWeaponSkillView()
    end)
  end
  self:loadRedDotItem()
  self:refreshSkill()
  self.IsResponseInput = Z.IsPCUI
  if Z.IsPCUI then
    self.inputKeyDescComp_:Init(144, self.uiBinder.com_icon_key, Lang("ViewDetails"))
  end
end

local subFuncIdDict = {
  [E.SkillType.WeaponSkill] = E.FunctionID.WeaponNormalSkill,
  [E.SkillType.MysteriesSkill] = E.FunctionID.WeaponAoyiSkill
}

function Weapon_role_main_skill_subView:refreshSkill()
  local skillNodes = {
    [1] = self.uiBinder.node_skill_1,
    [2] = self.uiBinder.node_skill_2,
    [3] = self.uiBinder.node_skill_3,
    [4] = self.uiBinder.node_skill_4,
    [5] = self.uiBinder.node_skill_5,
    [6] = self.uiBinder.node_skill_6,
    [7] = self.uiBinder.node_skill_7,
    [8] = self.uiBinder.node_skill_8,
    [9] = self.uiBinder.node_skill_9
  }
  if not self.professionVm_:CheckProfessionEquipWeapon() then
    local professionId = self.professionVm_:GetContainerProfession()
    local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
    if professionRow == nil then
      return
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_prompt, true)
    self.uiBinder.lab_prompt.text = string.format(Lang("no_profession_weapon_tips"), professionRow.Name)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_prompt, false)
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for id, root in pairs(skillNodes) do
      local skillId = self.weaponSkillVm_:GetSkillBySlot(id)
      local skillType = self.weaponSkillVm_:GetSkillTypeBySlotId(id)
      local isNormalStyle = true
      local path = self.uiBinder.prefab_cache:GetString("skill_item_large")
      local skillSlotRow = Z.TableMgr.GetTable("SkillSlotPositionTableMgr").GetRow(id)
      if Z.IsPCUI then
        if skillType == E.SkillType.MysteriesSkill then
          isNormalStyle = false
          path = self.uiBinder.prefab_cache:GetString("resonance_skill_pc")
        else
          path = self.uiBinder.prefab_cache:GetString("skill_item_pc")
        end
      elseif skillType == E.SkillType.MysteriesSkill then
        if skillId ~= 0 then
          isNormalStyle = false
          path = self.uiBinder.prefab_cache:GetString("resonance_skill")
        else
          path = self.uiBinder.prefab_cache:GetString("skill_item")
        end
      end
      local unit = self:AsyncLoadUiUnit(path, "skill_item_" .. id, root)
      self:refreshSkillItem(unit, skillId, id, isNormalStyle, skillType)
      self:AddAsyncClick(unit.btn, function()
        if not Z.ConditionHelper.CheckCondition(skillSlotRow.UnlockCondition, true) then
          return
        end
        if self.funcVM_.CheckFuncCanUse(subFuncIdDict[skillType]) then
          self.weaponSkillVm_.OpenWeaponSkillView(skillType, skillId)
        end
      end)
    end
  end)()
end

function Weapon_role_main_skill_subView:refreshSkillItem(unit, skillId, id, isNormalStyle, skillType)
  if unit.node_eff_loop then
    unit.node_eff_loop:SetEffectGoVisible(false)
  end
  unit.Trans:SetAnchorPosition(0, 0)
  if not Z.IsPCUI then
    unit.Ref:SetVisible(unit.root, true)
    unit.Ref:SetVisible(unit.img_assemble, false)
  end
  unit.Ref:SetVisible(unit.img_on, false)
  unit.Ref:SetVisible(unit.img_lock, false)
  unit.Ref:SetVisible(unit.lab_lock, false)
  local iconName, keyId = self.weaponSkillVm_:GetKeyCodeNameBySkillId(self.weaponSkillVm_:GetOriginSkillId(skillId))
  if self.skillInputKeyDescComps_[skillId] == nil then
    self.skillInputKeyDescComps_[skillId] = inputKeyDescComp.new()
  end
  self.skillInputKeyDescComps_[skillId]:Init(keyId, unit.com_icon_key)
  if Z.IsPCUI then
    self.skillInputKeyDescComps_[skillId]:SetVisible(keyId ~= nil)
  else
    self.skillInputKeyDescComps_[skillId]:SetVisible(false)
  end
  if isNormalStyle then
    if Z.IsPCUI then
      if id == 6 then
        local bgImgPath = string.format(Z.ConstValue.Skill_bg, "3")
        unit.img_bg:SetImage(bgImgPath)
      end
    else
      unit.Ref:SetVisible(unit.node_lab, false)
      unit.Ref:SetVisible(unit.img_light, false)
      unit.Ref:SetVisible(unit.img_mark, false)
    end
  elseif Z.IsPCUI then
  elseif skillId ~= 0 then
    local skillAoyiRow = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetRow(skillId)
    unit.Ref:SetVisible(unit.lab_name, false)
    local bgImgPath = Z.ConstValue.Resonance.skill_bg .. skillAoyiRow.RarityType
    unit.img_bg:SetImage(bgImgPath)
    local advanceLevel = self.weaponSkillVm_:GetSkillRemodelLevel(skillId)
    unit.lab_advance_level.text = advanceLevel
    unit.Ref:SetVisible(unit.img_advance_level, 0 < advanceLevel)
    if unit.img_char_bg then
      unit.Ref:SetVisible(unit.img_char_bg, false)
    end
    unit.Trans:SetAnchorPosition(0, -38)
  end
  self:refershUnlock(id, unit, skillType)
  if skillId == 0 then
    unit.Ref:SetVisible(unit.img_icon, false)
    self.skillInputKeyDescComps_[skillId]:SetVisible(false)
  else
    local skillConfig = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
    unit.Ref:SetVisible(unit.img_icon, true)
    unit.img_icon:SetImage(skillConfig.Icon)
  end
  if isNormalStyle then
    self:refershReddot(skillId, id, unit)
  else
    self:refreshResonceRedDot(skillId, unit)
  end
end

function Weapon_role_main_skill_subView:refershReddot(skillId, id, unit)
  if skillId ~= 0 then
    local oriSkillId = self.weaponSkillVm_:GetOriginSkillId(skillId)
    local remouldNodeId = self.weaponSkillVm_:GetSkillRemouldRedId(oriSkillId)
    local upNodeId = self.weaponSkillVm_:GetSkillUpRedId(oriSkillId)
    Z.RedPointMgr.LoadRedDotItem(remouldNodeId, self, unit.reddot_root)
    Z.RedPointMgr.LoadRedDotItem(upNodeId, self, unit.reddot_root)
    local slotNodeId = self.weaponSkillVm_:GetSlotEquipRedId(id)
    Z.RedPointMgr.LoadRedDotItem(slotNodeId, self, unit.reddot_root)
  end
end

function Weapon_role_main_skill_subView:refreshResonceRedDot(skillId, unit)
  if skillId ~= 0 then
    local advanceNodeId = self.weaponSkillVm_:GetResonanceAdvanceRedDotId(skillId)
    Z.RedPointMgr.LoadRedDotItem(advanceNodeId, self, unit.reddot_root)
  end
end

function Weapon_role_main_skill_subView:refershUnlock(id, unit, skillType)
  local subFuncId = subFuncIdDict[skillType]
  local isFuncOpen = true
  if subFuncId then
    local isFuncOpen = self.funcVM_.CheckFuncCanUse(subFuncId, true)
    unit.Ref:SetVisible(unit.img_lock, not isFuncOpen)
  end
  local slotConfig = Z.TableMgr.GetRow("SkillSlotPositionTableMgr", id)
  local slotUnlock = true
  if slotConfig and slotConfig.UnlockCondition then
    slotUnlock = Z.ConditionHelper.CheckCondition(slotConfig.UnlockCondition)
    if not slotUnlock then
      for _, condition in ipairs(slotConfig.UnlockCondition) do
        if condition[1] == E.ConditionType.Level then
          unit.Ref:SetVisible(unit.lab_lock, true)
          unit.lab_lock.text = Lang("Grade", {
            val = condition[2]
          })
        end
      end
    end
  end
  unit.Ref:SetVisible(unit.img_lock, not slotUnlock or not isFuncOpen)
end

function Weapon_role_main_skill_subView:OnDeActive()
  self:unLoadRedDotItem()
  if Z.IsPCUI then
    self.inputKeyDescComp_:UnInit()
    for _, value in pairs(self.skillInputKeyDescComps_) do
      value:UnInit()
    end
  end
end

function Weapon_role_main_skill_subView:OnRefresh()
end

function Weapon_role_main_skill_subView:loadRedDotItem()
  if Z.IsPCUI then
    Z.RedPointMgr.LoadRedDotItem(E.RedType.WeaponSkillDetail, self, self.uiBinder.reddot_root)
  else
    Z.RedPointMgr.LoadRedDotItem(E.RedType.WeaponSkillDetail, self, self.uiBinder.btn_look.transform)
  end
end

function Weapon_role_main_skill_subView:unLoadRedDotItem()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.WeaponSkillDetail, self)
end

function Weapon_role_main_skill_subView:OnTriggerInputAction(inputActionEventData)
  if inputActionEventData.ActionId == Z.InputActionIds.RoleViewDetail then
    self.weaponSkillVm_.OpenWeaponSkillView()
  end
end

return Weapon_role_main_skill_subView
