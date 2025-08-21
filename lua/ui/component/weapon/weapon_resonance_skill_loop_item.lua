local super = require("ui.component.loop_grid_view_item")
local WeaponResonanceSkillLoopItem = class("WeaponResonanceSkillLoopItem", super)
local inputKeyDescComp = require("input.input_key_desc_comp")
local ACTIVE_NAME_PATH = "ui/atlas/weap_skill/weap_char_bg_on"
local NOT_ACTIVE_NAME_PATH = "ui/atlas/weap_skill/weap_char_bg_off"

function WeaponResonanceSkillLoopItem:ctor()
  self.weaponSkillVM_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponVM_ = Z.VMMgr.GetVM("weapon")
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function WeaponResonanceSkillLoopItem:OnInit()
  self.uiBinder.btn:AddListener(function()
    local curData = self:GetCurData()
    if curData == nil then
      return
    end
    if self.parent.UIView then
      self.parent.UIView:OnItemClick(curData.Config.Id, self.uiBinder)
    end
  end)
  self:initDragEvent()
  Z.EventMgr:Add(Z.ConstValue.Weapon.OnSkillEquipRedChange, self.refreshRedDot, self)
end

function WeaponResonanceSkillLoopItem:OnRefresh(data)
  local config = data.Config
  self.skillId_ = config.Id
  local skillTableRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.skillId_)
  local resonanceRow = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetRow(self.skillId_)
  local advanceLevel = self.weaponSkillVM_:GetSkillRemodelLevel(self.skillId_)
  local curSelectSkillId = self.parent.UIView.SelectSkillId
  local isSelected = self.skillId_ == curSelectSkillId
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, not data.IsUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  self.uiBinder.img_icon:SetImage(skillTableRow.Icon)
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.uisteer, E.DynamicSteerType.ResonanceIndex, self.skillId_)
  self.uiBinder.lab_name.text = skillTableRow.Name
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_char_bg, true)
  local charName = Z.RichTextHelper.ApplyStyleTag(resonanceRow.ResonanceObject, data.IsUnlock and E.TextStyleTag.Black or E.TextStyleTag.White)
  self.uiBinder.lab_char.text = charName
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_name, true)
  self.uiBinder.img_char_bg:SetImage(data.IsUnlock and ACTIVE_NAME_PATH or NOT_ACTIVE_NAME_PATH)
  self.uiBinder.lab_advance_level.text = advanceLevel
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_advance_level, 0 < advanceLevel)
  local iconName, keyId = self.weaponSkillVM_:GetKeyCodeNameBySkillId(self.skillId_)
  self.inputKeyDescComp_:Init(keyId, self.uiBinder.com_icon_key)
  if Z.IsPCUI and data.IsEquip then
    self.inputKeyDescComp_:SetVisible(keyId ~= nil)
  else
    self.inputKeyDescComp_:SetVisible(false)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_assemble, not Z.IsPCUI and data.IsEquip)
  self.uiBinder.img_bg:SetImage(Z.ConstValue.Resonance.skill_bg .. resonanceRow.RarityType)
  self.uiBinder.img_advance_level:SetImage(Z.ConstValue.Resonance.skill_lv_bg_ .. resonanceRow.RarityType)
  if isSelected then
    self.parent.UIView:ChangeSelectState(self.skillId_, self.uiBinder, false)
  end
  self:refreshRedDot()
end

function WeaponResonanceSkillLoopItem:refreshRedDot()
  local activeNodeId = self.weaponSkillVM_:GetResonanceActiveRedDotId(self.skillId_)
  local advanceNodeId = self.weaponSkillVM_:GetResonanceAdvanceRedDotId(self.skillId_)
  local equipNodeId = self.weaponSkillVM_:GetSkillEquipRedId(self.skillId_)
  local activeNodeState = Z.RedPointMgr.GetRedState(activeNodeId) and not self.parent.UIView.EquipModel
  local advanceNodeState = Z.RedPointMgr.GetRedState(advanceNodeId) and not self.parent.UIView.EquipModel
  local equipNodeState = Z.RedPointMgr.GetRedState(equipNodeId) and self.parent.UIView.EquipModel
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_red_dot, activeNodeState or advanceNodeState or equipNodeState)
end

function WeaponResonanceSkillLoopItem:OnUnInit()
  self.uiBinder.btn:RemoveAllListeners()
  self:unInitDragEvent()
  Z.EventMgr:Remove(Z.ConstValue.Weapon.OnSkillEquipRedChange, self.refreshRedDot, self)
  self.inputKeyDescComp_:UnInit()
end

function WeaponResonanceSkillLoopItem:initDragEvent()
  self.uiBinder.event_trigger.onBeginDrag:AddListener(function()
    local curData = self:GetCurData()
    if curData == nil then
      return
    end
    if not curData.IsUnlock then
      Z.TipsVM.ShowTips(1045003)
      return
    end
    if not self.weaponSkillVM_:CheckSkillCanEquip(curData.Config.Id) then
      Z.TipsVM.ShowTips(1045002)
      return
    end
    if self.parent.UIView then
      self.parent.UIView:OnItemBeginDrag(curData.Config.Id)
      self.parent.UIView:ChangeSelectState(curData.Config.Id, self.uiBinder, false)
    end
  end)
  self.uiBinder.event_trigger.onDrag:AddListener(function(go, pointerData)
    local curData = self:GetCurData()
    if curData == nil then
      return
    end
    if self.parent.UIView then
      self.parent.UIView:OnItemDrag(curData.Config.Id, pointerData)
    end
  end)
  self.uiBinder.event_trigger.onEndDrag:AddListener(function()
    local curData = self:GetCurData()
    if curData == nil then
      return
    end
    if not curData.IsUnlock then
      return
    end
    if not self.weaponSkillVM_:CheckSkillCanEquip(curData.Config.Id) then
      return
    end
    if self.parent.UIView then
      self.parent.UIView:OnItemEndDrag()
    end
  end)
end

function WeaponResonanceSkillLoopItem:unInitDragEvent()
  self.uiBinder.event_trigger.onBeginDrag:RemoveAllListeners()
  self.uiBinder.event_trigger.onDrag:RemoveAllListeners()
  self.uiBinder.event_trigger.onEndDrag:RemoveAllListeners()
end

return WeaponResonanceSkillLoopItem
