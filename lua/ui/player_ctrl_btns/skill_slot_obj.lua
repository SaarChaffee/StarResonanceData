local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local skill_slot_obj = class("skill_slot_obj", super)
local inputKeyDescComp = require("input.input_key_desc_comp")

function skill_slot_obj:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
  self.cancelSource = Z.CancelSource.Rent()
  self.cdUnit = nil
  self.effectCdEndTimer_ = nil
  self.effectSkillReplaceTimer_ = nil
  self.effectSkillReplaceEndTimer_ = nil
  self.effectSwitchOnTimer_ = nil
  self.enableTouch_ = true
  self.vm = Z.VMMgr.GetVM("skill_slot")
  self.fighterBtns_vm_ = Z.VMMgr.GetVM("fighterbtns")
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function skill_slot_obj:GetUIUnitPath()
  local keyNum = tonumber(self.key_)
  local path = GetLoadAssetPath(Z.IsPCUI and "BattleBtn_Skill_PC" or "BattleBtn_Skill")
  if Z.IsPCUI and keyNum ~= 6 and keyNum ~= 7 and keyNum ~= 8 then
    path = GetLoadAssetPath("BattleBtn_Skill_Small_PC")
  end
  if keyNum == 10 and Z.IsPCUI then
    path = GetLoadAssetPath("BattleBtn_Skill_Long_PC")
  end
  return path
end

function skill_slot_obj:OnActive()
  self.uiShowSkillId = 0
  self.isFirst = true
  self.platAutoBattleAnim_ = false
  self.env_Vm = Z.VMMgr.GetVM("env")
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self:InitComponent()
  self:Init()
  self:initKeyIcon()
end

function skill_slot_obj:OnDeActive()
  self:UnInitComponent()
  self.uiBinder.steer_item:ClearSteerList()
  self.uiBinder.effect_dynamic:ReleseEffGo()
end

function skill_slot_obj:RegisterEvent()
  Z.EventMgr:Add("UIEffectEventFired", self.UIEffectEventFired, self)
  Z.EventMgr:Add(Z.ConstValue.ShowSkillLableChange, self.onSkillLabelChange, self)
  Z.EventMgr:Add(Z.ConstValue.OnPorfessionChange, self.refreshDynamicEffect, self)
  Z.EventMgr:Add(Z.ConstValue.OnEnvSkillCd, self.refreshEnvCd, self)
  Z.EventMgr:Add(Z.ConstValue.AutoBattleChange, self.refreshAISlot, self)
  Z.EventMgr:Add(Z.ConstValue.AISlotSetMode, self.refreshAISlot, self)
  Z.EventMgr:Add(Z.ConstValue.Vehicle.UpdateRiding, self.onRiding, self)
  Z.EventMgr:Add(Z.ConstValue.OpenSkillRoulette, self.OpenSkillRoulette, self)
  
  function self.onSlotChange(container, dirty)
    if dirty.slots then
      self:refreshDynamicEffect()
    end
  end
  
  Z.ContainerMgr.CharSerialize.slots.Watcher:RegWatcher(self.onSlotChange)
  if tonumber(self.key_) == 101 then
    Z.EventMgr:Add("ResonanceSkill1", self.keyFuncCall, self)
  elseif tonumber(self.key_) == 102 then
    Z.EventMgr:Add("ResonanceSkill2", self.keyFuncCall, self)
  end
end

function skill_slot_obj:UnregisterEvent()
  Z.EventMgr:RemoveObjAll(self)
  Z.ContainerMgr.CharSerialize.slots.Watcher:UnregWatcher(self.onSlotChange)
  self.onSlotChange = nil
end

function skill_slot_obj:InitComponent()
  self.uiBinder.binder_count_down_cd.count_down:Init()
  self.uiBinder.binder_count_down_continue.count_down:Init()
  self.uiBinder.binder_count_down_other.count_down:Init()
  self.uiBinder.skill_slot_data:Init()
end

function skill_slot_obj:UnInitComponent()
  self.uiBinder.binder_count_down_cd.count_down:UnInit()
  self.uiBinder.binder_count_down_continue.count_down:UnInit()
  self.uiBinder.binder_count_down_other.count_down:UnInit()
  self.uiBinder.skill_slot_data:UnInit()
  self.uiBinder.event_trigger.onDown:RemoveAllListeners()
  self.uiBinder.event_trigger.onUp:RemoveAllListeners()
  self.uiBinder.event_trigger.onExit:RemoveAllListeners()
  self.inputKeyDescComp_:UnInit()
  self:cancelLongPressAttack()
end

function skill_slot_obj:Init()
  local keyNum = tonumber(self.key_)
  self.uiBinder.skill_slot_data:SetSlotKey(keyNum)
  self.uiBinder.skill_slot_data:RefreshSkillLabel(Z.VMMgr.GetVM("setting").Get(E.SettingID.ShowSkillTag))
  local skillId = Z.SkillDataMgr:TryGetSkillIdBySlotId(keyNum)
  local effectInfoList = self.vm:GetSlotEffects(skillId, keyNum)
  if effectInfoList ~= nil then
    for _, effectName in pairs(effectInfoList) do
      self.uiBinder.effect_dynamic:CreatEFFGO(effectName, Vector3.zero, self.panel_.IsVisible)
    end
  end
  self.enableTouch_ = true
  self:AddListener()
  self:refreshEnvCd()
  self:refreshAISlot()
end

function skill_slot_obj:refreshAISlot()
  local slotId = tonumber(self.key_)
  local slotConfig = Z.TableMgr.GetTable("SkillSlotPositionTableMgr").GetRow(slotId)
  if slotConfig == nil then
    self.uiBinder.skill_slot_data:SetAutoBattleHide(false)
    return
  end
  if slotConfig.SlotType ~= 0 then
    self.uiBinder.skill_slot_data:SetAutoBattleHide(false)
    return
  end
  local autoBattleOpen = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAutoBattleSwitch).Value
  local setAIMode = self.fighterBtns_vm_:CheckAISlotSetMode()
  if not autoBattleOpen and not setAIMode then
    self.uiBinder.skill_slot_data:SetAutoBattleHide(false)
    return
  end
  if not Z.IsPCUI and self.fighterBtns_vm_:GetPlayerCtrlTmpType() == E.PlayerCtrlBtnTmpType.Vehicles then
    self.uiBinder.skill_slot_data:SetAutoBattleHide(false)
    return
  end
  self.uiBinder.skill_slot_data:ResetAutoBattlestatus()
end

function skill_slot_obj:refreshEnvCd(changeResonanceId)
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local resonanceId
  if self.key_ == E.SlotName.ResonanceSkillSlot_left then
    resonanceId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrResourceLeft")).Value
  elseif self.key_ == E.SlotName.ResonanceSkillSlot_right then
    resonanceId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrResourceRight")).Value
  end
  if resonanceId == nil or resonanceId <= 0 then
    if self.key_ == E.SlotName.ResonanceSkillSlot_left or self.key_ == E.SlotName.ResonanceSkillSlot_right then
      self.uiBinder.skill_slot_data:SetSlotKey(0)
      self.enableTouch_ = false
    end
    return
  end
  if changeResonanceId and resonanceId ~= changeResonanceId then
    return
  end
  local row = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr").GetRow(resonanceId)
  if row then
    local cdHandler = self.uiBinder.binder_count_down_other.count_down
    local resonanceRemainTime = self.env_Vm.GetResonanceRemainTime(resonanceId)
    cdHandler.CDLen = row.Time
    cdHandler.Progress = resonanceRemainTime == -1 and 1 or 1 - resonanceRemainTime / row.Time
    cdHandler:ChangeCdKey("resonanceDuration_" .. self.key_)
    cdHandler:CreateCD()
  end
end

function skill_slot_obj:onRiding()
  local keyNum = tonumber(self.key_)
  self.uiBinder.skill_slot_data:SetSlotKey(keyNum)
  if not Z.IsPCUI and self.fighterBtns_vm_:GetPlayerCtrlTmpType() == E.PlayerCtrlBtnTmpType.Vehicles then
    self.uiBinder.skill_slot_data:SetAutoBattleHide(false)
    return
  end
end

function skill_slot_obj:keyFuncCall(keyState)
  local slotId = tonumber(self.key_) or logError("[skill_slot_obj:AddListener] tonumber slotId failed! self.key_ {0}", self.key_)
  if keyState == 1 then
    if self.uiBinder == nil or not self.enableTouch_ then
      return
    end
    self.uiBinder.skill_slot_data:ShowClickEffect()
    Z.PlayerInputController:Attack(slotId, true)
  elseif keyState == 2 then
    if self.uiBinder == nil or not self.enableTouch_ then
      return
    end
    Z.PlayerInputController:Attack(slotId, false)
  end
end

function skill_slot_obj:AddListener()
  local slotId = tonumber(self.key_) or logError("[skill_slot_obj:AddListener] tonumber slotId failed! self.key_ {0}", self.key_)
  self.uiBinder.event_trigger.onDown:AddListener(function()
    if self.uiBinder == nil or not self.enableTouch_ then
      return
    end
    if self:tryChangSkillPanel() then
      Z.PlayerInputController:Attack(slotId, true)
    end
    self:longPressAttack()
  end)
  self.uiBinder.event_trigger.onUp:AddListener(function()
    if self.uiBinder == nil or not self.enableTouch_ then
      return
    end
    Z.PlayerInputController:Attack(slotId, false)
    self:cancelLongPressAttack()
  end)
  self.uiBinder.event_trigger.onExit:AddListener(function()
    if self.uiBinder == nil or not self.enableTouch_ then
      return
    end
    Z.PlayerInputController:Attack(slotId, false)
    self:cancelLongPressAttack()
  end)
  if Z.IsPCUI then
    return
  end
  self.uiBinder.joystick:SetSlotId(slotId)
  self.uiBinder.joystick:SetCancelRect(self.panel_.uiBinder.node_skill_cancel)
  self.uiBinder.joystick.onDown:AddListener(function()
    if self.uiBinder == nil or not self.enableTouch_ then
      return
    end
    if self:tryChangSkillPanel() then
      Z.PlayerInputController:Attack(slotId, true)
    end
    self:longPressAttack()
  end)
  self.uiBinder.joystick.onUp:AddListener(function()
    if self.uiBinder == nil or not self.enableTouch_ then
      return
    end
    Z.PlayerInputController:Attack(slotId, false)
    self:cancelLongPressAttack()
  end)
end

function skill_slot_obj:longPressAttack()
  self:cancelLongPressAttack()
  local slotId = tonumber(self.key_)
  local pressTime = 0
  local _ = 0
  local isLongPress, pressTime = Panda.ZGame.ZBattleUtils.CheckSkillCanLongPressAttack(slotId, _)
  if not isLongPress then
    return
  end
  self.attackTimer_ = self.timerMgr:StartTimer(function()
    if self.uiBinder == nil or not self.enableTouch_ then
      return
    end
    Z.PlayerInputController:Attack(slotId, true)
  end, pressTime, -1)
end

function skill_slot_obj:cancelLongPressAttack()
  if self.attackTimer_ then
    self.timerMgr:StopTimer(self.attackTimer_)
    self.attackTimer_ = nil
  end
end

function skill_slot_obj:OpenSkillRoulette(slotId, open)
  if Z.IsPCUI then
    return
  end
  if tonumber(self.key_) ~= slotId then
    self.enableTouch_ = not open
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.joystick_bg, open)
end

function skill_slot_obj:tryChangSkillPanel()
  if Z.IsPCUI then
    return true
  end
  if self.key_ == E.SlotName.ResonanceSkillSlot_left or self.key_ == E.SlotName.ResonanceSkillSlot_right then
    return true
  end
  self.fighterBtns_vm_:SetSkillPanelLocked(false)
  if not Z.LuaBridge.IsCanHoldWeapon() then
    return true
  end
  local usingToy = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrToy")).Value
  if usingToy == 1 then
    return true
  end
  if tonumber(self.key_) ~= 1 then
    return true
  end
  if not self.fighterBtns_vm_:GetSkillPanelShow() then
    local moveType = Z.EntityMgr.PlayerEnt:GetLuaAttrVirtualMoveType()
    local dontShowBattleList = {
      Z.PbEnum("EMoveType", "MoveDash")
    }
    if not Z.EntityMgr.PlayerEnt:GetLuaLocalAttrInBattleShow() and not table.zcontains(dontShowBattleList, moveType) then
      Z.EntityMgr.PlayerEnt:SetLuaLocalAttrHoldWeapon(true)
      Z.EntityMgr.PlayerEnt:SetLuaLocalAttrInBattleShow(true)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.PlayerSkillPanelChange, true)
    return false
  else
    Z.EventMgr:Dispatch(Z.ConstValue.CancelSwitchNormalSkillPanel)
  end
  return true
end

function skill_slot_obj:UIEffectEventFired(skillId, slotId, effectName, isRun)
  local slotKey = tonumber(self.key_)
  if Z.SkillDataMgr:TryGetSkillIdBySlotId(slotKey) == 0 and skillId == 0 then
    self.uiBinder.effect_dynamic:ReleseEffGo()
    return
  end
  if Z.SkillDataMgr:TryGetSkillIdBySlotId(slotKey) ~= skillId and slotKey ~= slotId then
    return
  end
  self:refreshDynamicEffect()
end

function skill_slot_obj:refreshDynamicEffect()
  local skillId = Z.SkillDataMgr:TryGetSkillIdBySlotId(tonumber(self.key_))
  local effectInfoList = self.vm:GetSlotEffects(skillId, tonumber(self.key_))
  local showDynamicEffect = false
  if effectInfoList ~= nil then
    for _, effectName in pairs(effectInfoList) do
      showDynamicEffect = true
      self.uiBinder.effect_dynamic:CreatEFFGO(effectName, Vector3.zero)
      break
    end
  end
  if not showDynamicEffect then
    self.uiBinder.effect_dynamic:ReleseEffGo()
  end
end

function skill_slot_obj:stopEffect(effect)
  if not effect or not effect.ZEff then
    return -1
  end
  effect.ZEff:SetEffectGoVisible(false)
end

function skill_slot_obj:playEffect(timerKey, effect, time)
  if not effect or not effect.ZEff then
    return
  end
  if timerKey ~= nil then
    effect.ZEff:SetEffectGoVisible(false)
    self.timerMgr:StopTimer(timerKey)
  end
  effect.ZEff:SetEffectGoVisible(true)
  if time == -1 then
    return
  else
    local newTimerKey = self.timerMgr:StartTimer(function()
      effect.ZEff:SetEffectGoVisible(false)
    end, time)
    return newTimerKey
  end
end

function skill_slot_obj:initKeyIcon()
  local keyId
  local idx = tonumber(self.key_)
  local slotConfig = Z.TableMgr.GetTable("SkillSlotPositionTableMgr").GetRow(idx)
  if slotConfig then
    keyId = slotConfig.KeyPositionId
  end
  if keyId and keyId ~= 0 then
    Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, keyId)
    self.inputKeyDescComp_:Init(keyId, self.uiBinder.binder_key)
  else
    self.inputKeyDescComp_:UnInit()
    self.uiBinder.Ref:SetVisible(self.uiBinder.binder_key, false)
  end
end

function skill_slot_obj:onSkillLabelChange(show)
  if self.uiBinder == nil then
    return
  end
  self.uiBinder.skill_slot_data:RefreshSkillLabel(show)
end

function skill_slot_obj:BindLuaAttrWatchers()
  self:BindEntityLuaAttrWatcher({
    Z.LocalAttr.EAutoBattleSwitch
  }, Z.EntityMgr.PlayerEnt, self.refreshAISlot, true)
end

return skill_slot_obj
