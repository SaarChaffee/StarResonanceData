local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local skill_slot_obj = class("skill_slot_obj", super)
local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")

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
end

function skill_slot_obj:GetUIUnitPath()
  local path = GetLoadAssetPath(Z.IsPCUI and "BattleBtn_Skill_PC" or "BattleBtn_Skill")
  if tonumber(self.key_) == 10 and Z.IsPCUI then
    path = path .. "_long"
  end
  return path
end

function skill_slot_obj:OnActive()
  self.uiShowSkillId = 0
  self.isFirst = true
  self.platAutoBattleAnim_ = false
  self.env_Vm = Z.VMMgr.GetVM("env")
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
  Z.EventMgr:Add(Z.ConstValue.UIHide, self.onUIViewHide, self)
  Z.EventMgr:Add(Z.ConstValue.ShowSkillLableChange, self.onSkillLabelChange, self)
  Z.EventMgr:Add(Z.ConstValue.AutoBattleChange, self.refreshAutoBattleSwitch, self)
  Z.EventMgr:Add(Z.ConstValue.OnAutoBattleBannedBySkillBanned, self.refreshAutoBattleSwitch, self)
  Z.EventMgr:Add(Z.ConstValue.OnPorfessionChange, self.refreshDynamicEffect, self)
  Z.EventMgr:Add(Z.ConstValue.OnEnvSkillCd, self.refreshEnvCd, self)
  if tonumber(self.key_) == 101 then
    Z.EventMgr:Add("ResonanceSkill1", self.keyFuncCall, self)
  elseif tonumber(self.key_) == 102 then
    Z.EventMgr:Add("ResonanceSkill2", self.keyFuncCall, self)
  end
end

function skill_slot_obj:UnregisterEvent()
  Z.EventMgr:RemoveObjAll(self)
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
end

function skill_slot_obj:onUIViewHide(viewConfigKey, visible)
  if self.uiBinder == nil then
    return
  end
  if viewConfigKey == self.panel_.viewConfigKey then
    self.uiBinder.Ref:SetVisible(self.uiBinder.trans_effect_group, visible)
  end
end

function skill_slot_obj:Init()
  local keyNum = tonumber(self.key_)
  self.uiBinder.skill_slot_data:SetSlotKey(keyNum)
  self.uiBinder.skill_slot_data:RefreshSkillLabel(Z.VMMgr.GetVM("setting").Get(E.SettingID.ShowSkillTag))
  self:refreshAutoBattleSwitch()
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
end

function skill_slot_obj:refreshEnvCd(changeResonanceId)
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
    cdHandler.CDLen = row.Time
    cdHandler.Progress = 1 - self.env_Vm.GetResonanceRemainTime(resonanceId) / row.Time
    cdHandler:ChangeCdKey("resonanceDuration_" .. self.key_)
    cdHandler:CreateCD()
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
    self.uiBinder.skill_slot_data:ShowClickEffect()
    Z.PlayerInputController:Attack(slotId, true)
  end)
  self.uiBinder.event_trigger.onUp:AddListener(function()
    if self.uiBinder == nil or not self.enableTouch_ then
      return
    end
    Z.PlayerInputController:Attack(slotId, false)
  end)
  self.uiBinder.event_trigger.onExit:AddListener(function()
    if self.uiBinder == nil or not self.enableTouch_ then
      return
    end
    Z.PlayerInputController:Attack(slotId, false)
  end)
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
  if isRun then
    self.uiBinder.effect_dynamic:CreatEFFGO(effectName, Vector3.zero, self.panel_.IsVisible)
  else
    self.uiBinder.effect_dynamic:ReleseEffGo()
  end
end

function skill_slot_obj:refreshDynamicEffect()
  local skillId = Z.SkillDataMgr:TryGetSkillIdBySlotId(tonumber(self.key_))
  local effectInfoList = self.vm:GetSlotEffects(skillId, tonumber(self.key_))
  local showDynamicEffect = false
  if effectInfoList ~= nil then
    for _, effectName in pairs(effectInfoList) do
      showDynamicEffect = true
      self.uiBinder.effect_dynamic:CreatEFFGO(effectName, Vector3.zero, self.panel_.IsVisible)
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
    keyIconHelper.InitKeyIcon(self, self.uiBinder.binder_key, keyId)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.binder_key, false)
  end
end

function skill_slot_obj:onSkillLabelChange(show)
  if self.uiBinder == nil then
    return
  end
  self.uiBinder.skill_slot_data:RefreshSkillLabel(show)
end

function skill_slot_obj:refreshAutoBattleSwitch(forceHide)
  if self.uiBinder == nil or tonumber(self.key_) ~= E.SkillSlotType.NormalAttack then
    self.uiBinder.skill_slot_data:RefreshSkillAutoTips(false)
    return
  end
  local settingVm = Z.VMMgr.GetVM("setting")
  local autoBattleOpen = settingVm.Get(E.SettingID.AutoBattle)
  local switchOpen = Z.LocalUserDataMgr.GetBool("auto_battle_switch", false)
  local fightrtVm = Z.VMMgr.GetVM("fighterbtns")
  local autoBattleFlag = fightrtVm:GetAutoBattleFlag()
  self.uiBinder.skill_slot_data:RefreshSkillAutoTips(autoBattleOpen and switchOpen and autoBattleFlag)
end

function skill_slot_obj:BindLuaAttrWatchers()
  self:BindEntityLuaAttrWatcher({
    Z.LocalAttr.EAutoBattleAnim
  }, Z.EntityMgr.PlayerEnt, self.switchAutoBattleAnim, true)
end

function skill_slot_obj:switchAutoBattleAnim()
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Skill) or self.uiBinder == nil or tonumber(self.key_) ~= E.SkillSlotType.NormalAttack then
    return
  end
  local play = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAutoBattleAnim).Value
  if play then
    if not self.platAutoBattleAnim_ then
      Z.TipsVM.ShowTips(100133)
      self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
    end
    self.uiBinder.img_icon_1:SetColorByHex(E.ColorHexValues.Yellow)
    self.uiBinder.img_icon_2:SetColorByHex(E.ColorHexValues.Yellow)
    self.platAutoBattleAnim_ = true
  else
    self.uiBinder.anim:Pause()
    self.uiBinder.img_icon_1:SetColorByHex(E.ColorHexValues.White)
    self.uiBinder.img_icon_2:SetColorByHex(E.ColorHexValues.White)
    if self.platAutoBattleAnim_ then
      Z.TipsVM.ShowTips(100134)
    end
    self.platAutoBattleAnim_ = false
  end
end

return skill_slot_obj
