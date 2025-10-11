local UI = Z.UI
local super = require("ui.ui_view_base")
local Battle_auto_battle_setView = class("Battle_auto_battle_setView", super)
local inputKeyDescComp = require("input.input_key_desc_comp")

function Battle_auto_battle_setView:ctor()
  self.uiBinder = nil
  super.ctor(self, "battle_auto_battle_set", "battle/battle_auto_battle_set", UI.ECacheLv.None, true)
  self.enterInputKeyDescComp_ = inputKeyDescComp.new()
  self.escInputKeyDescComp_ = inputKeyDescComp.new()
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function Battle_auto_battle_setView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.fighterBtnsVm_ = Z.VMMgr.GetVM("fighterbtns")
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.fighterBtnsVm_:SwitchAISlotSetMode(true)
  self.enterInputKeyDescComp_:Init(103, self.uiBinder.group_key_enter)
  self.escInputKeyDescComp_:Init(108, self.uiBinder.group_key_esc)
  self:AddClick(self.uiBinder.btn_save, function()
    self:save()
  end)
  self:AddAsyncClick(self.uiBinder.btn_no, function()
    self:cancel()
  end)
  Z.EventMgr:Dispatch(Z.ConstValue.AISlotSetMode, true)
end

function Battle_auto_battle_setView:save()
  Z.CoroUtil.create_coro_xpcall(function()
    self.fighterBtnsVm_:SetAISlotsServer(self.cancelSource:CreateToken())
    self.fighterBtnsVm_:CloseSetAutoBattleSlotView()
  end)()
end

function Battle_auto_battle_setView:cancel()
  self.fighterBtnsVm_:CloseSetAutoBattleSlotView()
end

function Battle_auto_battle_setView:OnDeActive()
  self.fighterBtnsVm_:SwitchAISlotSetMode(false)
  Z.EventMgr:Dispatch(Z.ConstValue.AISlotSetMode, false)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.enterInputKeyDescComp_:UnInit()
  self.escInputKeyDescComp_:UnInit()
  self.inputKeyDescComp_:UnInit()
end

local slotActionIdMap = {
  [Z.InputActionIds.SpecialSkill] = 2,
  [Z.InputActionIds.Skill1] = 3,
  [Z.InputActionIds.Skill2] = 4,
  [Z.InputActionIds.Skill3] = 5,
  [Z.InputActionIds.UltimateSkill] = 6,
  [Z.InputActionIds.SupportSkill1] = 7,
  [Z.InputActionIds.SupportSkill2] = 8,
  [Z.InputActionIds.Skill4] = 9
}

function Battle_auto_battle_setView:OnTriggerInputAction(inputActionEventData)
  if not Z.IsPCUI then
    return
  end
  if inputActionEventData.ActionId == Z.InputActionIds.ExitUI then
    self:cancel()
  end
  if inputActionEventData.ActionId == Z.InputActionIds.OpenChat then
    self:save()
  end
  if slotActionIdMap[inputActionEventData.ActionId] then
    local slotId = slotActionIdMap[inputActionEventData.ActionId]
    self:onSelectSkill(slotId, self.uiBinder[tostring(slotId)])
  end
end

function Battle_auto_battle_setView:OnRefresh()
  if Z.IsPCUI then
    self:refreshPcSkillSlot()
  else
    self:refreshSkillSlot()
  end
end

local resonanceSkillBgPath = "ui/atlas/skill/skill_main/weap_skill_bg_on_"

function Battle_auto_battle_setView:refreshSkillSlot()
  local slotTabelData = Z.TableMgr.GetTable("SkillSlotPositionTableMgr").GetDatas()
  for _, value in pairs(slotTabelData) do
    local unit = self.uiBinder[tostring(value.Id)]
    if value.SlotType == 0 and unit then
      local skillId = self.weaponSkillVm_:GetSkillBySlot(value.Id)
      local skillType = self.weaponSkillVm_:GetSkillTypeBySlotId(value.Id)
      self:AddListener(value.Id, unit)
      local isAISlotLocked = self.fighterBtnsVm_:IsAISlotLocked(value.Id)
      unit.Ref:SetVisible(unit.node_auto_battle, not isAISlotLocked)
      if skillId == 0 then
        unit.Ref:SetVisible(unit.img_skill_icon, false)
        if skillType == E.SkillType.MysteriesSkill then
          unit.Ref:SetVisible(unit.img_skill_bg, false)
        end
      else
        local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
        unit.Ref:SetVisible(unit.img_skill_icon, true)
        unit.img_skill_icon:SetImage(skillRow.Icon)
        if skillType == E.SkillType.MysteriesSkill then
          local skillAoyiRow = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetRow(skillId)
          unit.Ref:SetVisible(unit.img_skill_bg, true)
          unit.img_skill_bg:SetImage(resonanceSkillBgPath .. skillAoyiRow.RarityType)
        end
      end
    end
  end
end

local skillBgColor = {
  [1] = "#c04823",
  [2] = "#4f5759",
  [3] = "#2371c0",
  [4] = "#c09923",
  [5] = "#69c023"
}

function Battle_auto_battle_setView:refreshPcSkillSlot()
  local slotTabelData = Z.TableMgr.GetTable("SkillSlotPositionTableMgr").GetDatas()
  for _, value in pairs(slotTabelData) do
    local unit = self.uiBinder[tostring(value.Id)]
    if value.SlotType == 0 and unit then
      local skillId = self.weaponSkillVm_:GetSkillBySlot(value.Id)
      self:initKeyIcon(value.Id, unit)
      self:AddListener(value.Id, unit)
      local isAISlotLocked = self.fighterBtnsVm_:IsAISlotLocked(value.Id)
      unit.Ref:SetVisible(unit.node_auto_battle, not isAISlotLocked)
      if skillId == 0 then
        unit.Ref:SetVisible(unit.img_skill_icon, false)
        unit.Ref:SetVisible(unit.img_skill_bg_color, false)
      else
        local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
        unit.Ref:SetVisible(unit.img_skill_icon, true)
        unit.img_skill_icon:SetImage(skillRow.Icon)
        if skillRow.PCBgColour > #skillBgColor or skillRow.PCBgColour < 1 then
          unit.Ref:SetVisible(unit.img_skill_bg_color, false)
        else
          unit.Ref:SetVisible(unit.img_skill_bg_color, true)
          unit.img_skill_bg_color:SetColorByHex(skillBgColor[skillRow.PCBgColour])
        end
      end
    end
  end
end

function Battle_auto_battle_setView:initKeyIcon(slotId, uiBinder)
  local keyId
  local slotConfig = Z.TableMgr.GetTable("SkillSlotPositionTableMgr").GetRow(slotId)
  if slotConfig then
    keyId = slotConfig.KeyPositionId
  end
  if keyId and keyId ~= 0 then
    Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, keyId)
    self.inputKeyDescComp_:Init(keyId, uiBinder.node_icon_key)
  else
    self.inputKeyDescComp_:UnInit()
    self.uiBinder.Ref:SetVisible(uiBinder.node_icon_key, false)
  end
end

function Battle_auto_battle_setView:AddListener(slotId, uiBinder)
  uiBinder.rayimg_touch_area.onDown:AddListener(function()
    self:onSelectSkill(slotId, uiBinder)
  end)
end

function Battle_auto_battle_setView:onSelectSkill(slotId, uiBinder)
  if self.fighterBtnsVm_:IsAISlotLocked(slotId) then
    if self.fighterBtnsVm_:CheckInAISlotCache(slotId) then
      uiBinder.Ref:SetVisible(uiBinder.node_auto_battle, false)
      self.fighterBtnsVm_:RemoveAISlots(slotId)
    else
      uiBinder.Ref:SetVisible(uiBinder.node_auto_battle, true)
      self.fighterBtnsVm_:CacheAISlots(slotId)
    end
  elseif self.fighterBtnsVm_:CheckInAISlotCache(slotId) then
    uiBinder.Ref:SetVisible(uiBinder.node_auto_battle, true)
    self.fighterBtnsVm_:RemoveAISlots(slotId)
  else
    uiBinder.Ref:SetVisible(uiBinder.node_auto_battle, false)
    self.fighterBtnsVm_:CacheAISlots(slotId)
  end
end

return Battle_auto_battle_setView
