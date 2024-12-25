local UI = Z.UI
local super = require("ui.ui_subview_base")
local Weapon_role_main_skill_subView = class("Weapon_role_main_skill_subView", super)

function Weapon_role_main_skill_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "weapon_role_main_skill_sub", "weapon/weapon_role_main_skill_sub", UI.ECacheLv.None)
end

function Weapon_role_main_skill_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.weaponId_ = self.weaponVm_.GetCurWeapon()
  self.professionVm_ = Z.VMMgr.GetVM("profession")
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self:AddAsyncClick(self.uiBinder.btn_look, function()
    self.weaponSkillVm_.OpenWeaponSkillView()
  end)
  self:loadRedDotItem()
  self:refreshSkill()
end

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
  local subFuncIdDict = {
    [E.SkillType.WeaponSkill] = E.FunctionID.WeaponNormalSkill,
    [E.SkillType.MysteriesSkill] = E.FunctionID.WeaponAoyiSkill
  }
  Z.CoroUtil.create_coro_xpcall(function()
    for id, root in pairs(skillNodes) do
      local skillId = self.weaponSkillVm_:GetSkillBySlot(id)
      local skillType = self.weaponSkillVm_:GetSkillTypeBySlotId(id)
      local isNormalStyle = true
      local path = self.uiBinder.prefab_cache:GetString("skill_item_large")
      local skillSlotRow = Z.TableMgr.GetTable("SkillSlotPositionTableMgr").GetRow(id)
      if skillType == E.SkillType.MysteriesSkill then
        if skillId ~= 0 then
          isNormalStyle = false
          path = self.uiBinder.prefab_cache:GetString("resonance_skill")
        else
          path = self.uiBinder.prefab_cache:GetString("skill_item")
        end
      end
      local unit = self:AsyncLoadUiUnit(path, "skill_item_" .. id, root)
      if unit.node_eff_loop then
        unit.node_eff_loop:SetEffectGoVisible(false)
      end
      unit.Trans:SetAnchorPosition(0, 0)
      unit.Ref:SetVisible(unit.root, true)
      unit.Ref:SetVisible(unit.img_assemble, false)
      unit.Ref:SetVisible(unit.img_on, false)
      unit.Ref:SetVisible(unit.img_lock, false)
      unit.Ref:SetVisible(unit.lab_lock, false)
      if Z.IsPCUI and skillId ~= 0 then
        unit.Ref:SetVisible(unit.img_pc, true)
        local iconName, path = self.weaponSkillVm_:GetKeyCodeNameBySkillId(self.weaponSkillVm_:GetOriginSkillId(skillId))
        if path then
          unit.Ref:SetVisible(unit.img_pc_icon, true)
          unit.img_pc_icon:SetImage(path)
        else
          unit.Ref:SetVisible(unit.img_pc_icon, false)
        end
        unit.lab_figure.text = iconName
      else
        unit.Ref:SetVisible(unit.img_pc, false)
      end
      if isNormalStyle then
        unit.Ref:SetVisible(unit.node_lab, false)
        unit.Ref:SetVisible(unit.img_light, false)
        unit.Ref:SetVisible(unit.img_mark, false)
        if skillId ~= 0 then
          local oriSkillId = self.weaponSkillVm_:GetOriginSkillId(skillId)
          local remouldNodeId = self.weaponSkillVm_:GetSkillRemouldRedId(oriSkillId)
          local upNodeId = self.weaponSkillVm_:GetSkillUpRedId(oriSkillId)
          Z.RedPointMgr.LoadRedDotItem(remouldNodeId, self, unit.Trans)
          Z.RedPointMgr.LoadRedDotItem(upNodeId, self, unit.Trans)
        end
      else
        unit.Ref:SetVisible(unit.lab_name, false)
        local skillAoyiRow = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetRow(skillId)
        if skillAoyiRow then
          local bgImgPath = Z.ConstValue.Resonance_skill_bg .. skillAoyiRow.RarityType
          unit.img_bg:SetImage(bgImgPath)
          local advanceNodeId = self.weaponSkillVm_:GetResonanceAdvanceRedDotId(skillId)
          local advanceNodeState = Z.RedPointMgr.GetRedState(advanceNodeId)
          unit.Ref:SetVisible(unit.node_red_dot, advanceNodeState)
          local advanceLevel = self.weaponSkillVm_:GetSkillRemodelLevel(skillId)
          unit.lab_advance_level.text = advanceLevel
          unit.Ref:SetVisible(unit.img_advance_level, 0 < advanceLevel)
          if Z.IsPCUI then
            unit.lab_key.text = self.weaponSkillVm_:GetKeyCodeNameBySkillId(self.weaponSkillVm_:GetOriginSkillId(skillId))
          end
          unit.Ref:SetVisible(unit.img_key, Z.IsPCUI)
          unit.Ref:SetVisible(unit.img_assemble, not Z.IsPCUI)
          unit.Ref:SetVisible(unit.img_frame, false)
        end
      end
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
      if skillId == 0 then
        unit.Ref:SetVisible(unit.img_icon, false)
      else
        unit.Ref:SetVisible(unit.img_icon, true)
        local skillConfig = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
        unit.img_icon:SetImage(skillConfig.Icon)
      end
      local slotNodeId = self.weaponSkillVm_:GetSlotEquipRedId(id)
      Z.RedPointMgr.LoadRedDotItem(slotNodeId, self, unit.btn.transform)
      self:AddAsyncClick(unit.btn, function()
        if not Z.ConditionHelper.CheckCondition(skillSlotRow.UnlockCondition, true) then
          return
        end
        if self.funcVM_.CheckFuncCanUse(subFuncId) then
          self.weaponSkillVm_.OpenWeaponSkillView(skillType, skillId)
        end
      end)
    end
  end)()
  if not self.professionVm_:CheckProfessionEquipWeapon() then
    local professionId = self.professionVm_:GetCurProfession()
    local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
    if professionRow == nil then
      return
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_prompt, true)
    self.uiBinder.lab_prompt.text = string.format(Lang("no_profession_weapon_tips"), professionRow.Name)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_prompt, false)
  end
end

function Weapon_role_main_skill_subView:OnDeActive()
  self:unLoadRedDotItem()
end

function Weapon_role_main_skill_subView:OnRefresh()
end

function Weapon_role_main_skill_subView:loadRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.WeaponSkillDetail, self, self.uiBinder.btn_look.transform)
end

function Weapon_role_main_skill_subView:unLoadRedDotItem()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.WeaponSkillDetail, self)
end

return Weapon_role_main_skill_subView
