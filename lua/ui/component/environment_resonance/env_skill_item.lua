local env_skill_item = class("env_skill_item")
local SkillState = E.EnvResonanceSkillState
local Color_State_Enum = {
  Normal = Color.New(1, 1, 1, 1),
  Disable = Color.New(1, 1, 1, 0.1)
}
local Equip_Image_Enum = {
  Unload = "ui/atlas/environment/env_img_subtract",
  Switch = "ui/atlas/environment/env_frame_change_bg"
}

function env_skill_item:ctor()
  self.envVm_ = Z.VMMgr.GetVM("env")
  self.pivotVm_ = Z.VMMgr.GetVM("pivot")
end

function env_skill_item:InitItem(contItem, configResonance, configSkill, parentView, equipSlot, scenePos)
  Z.EventMgr:Add(Z.ConstValue.OnResonanceSelectFinish, self.RefreshSelectState, self)
  Z.EventMgr:Add(Z.ConstValue.OnResonanceSkill, self.RefreshItem, self)
  self.contItem_ = contItem
  self.configResonance_ = configResonance
  self.configSkill_ = configSkill
  self.parentView_ = parentView
  self.equipSlot_ = equipSlot or 0
  self.scenePos_ = scenePos or 0
  self.changeSlot_ = 0
  self:setImageActivate(false)
  self:setBtnChange(false)
  self:setBtnChangeEff(false)
  self.parentView_:AddAsyncClick(self.contItem_.btn_icon, function()
    self:onClickItem()
  end)
  if contItem.btn_skillno then
    self.parentView_:AddAsyncClick(self.contItem_.btn_skillno, function()
      self:onClickItem()
    end)
  end
  self.parentView_:AddAsyncClick(self.contItem_.cont_add.btn_add, function()
    if self:isEquipSkillItem() then
      if not self.envVm_.CheckAnyResonanceActive() then
        Z.TipsVM.ShowTips(1381007)
      else
        Z.TipsVM.ShowTips(1381008)
      end
    end
  end)
end

function env_skill_item:RefreshItem()
  self:clearTimer()
  if self.configResonance_ and self.configSkill_ then
    local resonanceId = self.configResonance_.Id
    local remainTime = self.envVm_.GetResonanceRemainTime(resonanceId)
    local allTime = self.configResonance_.Time
    local state = self.envVm_.GetSkillState(resonanceId)
    self.contItem_.img_icon:SetImage(self.configSkill_.Icon)
    self.contItem_.Ref:SetVisible(self.contItem_.img_icon, true)
    self.contItem_.Ref:SetVisible(self.contItem_.img_bar_icon, state == SkillState.Active or state == SkillState.Equip)
    self.contItem_.Ref:SetVisible(self.contItem_.img_skillno, false)
    self.contItem_.Ref:SetVisible(self.contItem_.img_expire, state == SkillState.Expired)
    self.contItem_.Ref:SetVisible(self.contItem_.img_icon_light, state == SkillState.Equip)
    self.contItem_.eff_loop:SetEffectGoVisible(state == SkillState.Equip)
    self.contItem_.lab_name.text = self.configSkill_.Name
    if state ~= SkillState.Lock and state ~= SkillState.NotActive then
      self.contItem_.img_bar_icon.fillAmount = 1
      self.contItem_.img_bar_icon.fillAmount = state == SkillState.Expired and 0 or remainTime / allTime
      if state == SkillState.Expired or state == SkillState.NotActive then
        self.contItem_.img_icon:SetColor(Color_State_Enum.Disable)
      else
        self.contItem_.img_icon:SetColor(Color_State_Enum.Normal)
        self:createTimer()
      end
    else
      self.contItem_.img_icon:SetColor(Color_State_Enum.Disable)
    end
    if self.contItem_.img_icon_empty then
      self.contItem_.Ref:SetVisible(self.contItem_.img_icon_empty, state == SkillState.Lock or state == SkillState.NotActive)
    end
  end
  if self:isEquipSkillItem() then
    local resonanceId = self.envVm_.GetEquipResonance(self.equipSlot_)
    self.contItem_.Ref:SetVisible(self.contItem_.btn_bg, 0 < resonanceId)
    self.contItem_.Ref:SetVisible(self.contItem_.cont_add.Ref, resonanceId == 0)
    if self.contItem_.cont_add.cont_reddot then
      local isCanShowRedDot = self.envVm_.IsCanShowRedDot()
      self.contItem_.cont_add.Ref:SetVisible(self.contItem_.cont_add.cont_reddot.Ref, isCanShowRedDot)
    end
  else
    self.contItem_.Ref:SetVisible(self.contItem_.btn_bg, true)
    self.contItem_.Ref:SetVisible(self.contItem_.cont_add.Ref, false)
    self.contItem_.Ref:SetVisible(self.contItem_.btn_change, false)
    self.contItem_.eff_activate_loop_change:SetEffectGoVisible(false)
    self.contItem_.eff_switch:SetEffectGoVisible(false)
  end
  self:RefreshSelectState()
end

function env_skill_item:RefreshEquipItem()
  self.configResonance_ = nil
  self.configSkill_ = nil
  local resonanceId = self.envVm_.GetEquipResonance(self.equipSlot_)
  if 0 < resonanceId then
    self.configResonance_ = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr").GetRow(resonanceId)
    local skillId = self.envVm_.GetSkillIdByResonance(resonanceId)
    if 0 < skillId then
      self.configSkill_ = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
    end
  end
  if 0 < self.changeSlot_ then
    self.contItem_.eff_switch:SetEffectGoVisible(true)
    self.changeSlot_ = 0
  end
  self:RefreshItem()
end

function env_skill_item:RefreshSelectState()
  local selectResonanceId = self.parentView_.SelectResonanceId_
  local isSelected = self.parentView_.IsEquipSkillItem_ == self:isEquipSkillItem() and self.configResonance_ and self.configResonance_.Id == selectResonanceId
  if self.contItem_ and self.contItem_.img_on then
    self.contItem_.Ref:SetVisible(self.contItem_.img_on, isSelected)
  end
  if self:isEquipSkillItem() then
    local resonanceId = self.envVm_.GetEquipResonance(self.equipSlot_)
    local isCanAdd = 0 < selectResonanceId and self.envVm_.CheckResonanceActive(selectResonanceId)
    self.contItem_.cont_add.Ref:SetVisible(self.contItem_.cont_add.btn_add, resonanceId == 0 or isCanAdd)
  end
end

function env_skill_item:DestroyItem()
  Z.EventMgr:Remove(Z.ConstValue.OnResonanceSelectFinish, self.RefreshSelectState, self)
  Z.EventMgr:Remove(Z.ConstValue.OnResonanceSkill, self.RefreshItem, self)
  self.contItem_ = nil
  self.configResonance_ = nil
  self.configSkill_ = nil
  self.parentView_ = nil
  self:clearTimer()
end

function env_skill_item:createTimer()
  local remainTime = self.envVm_.GetResonanceRemainTime(self.configResonance_.Id)
  if remainTime <= 0 then
    return
  end
  local allTime = self.configResonance_.Time
  self.timer_ = self.parentView_.timerMgr:StartTimer(function()
    remainTime = remainTime - 1
    self.contItem_.img_bar_icon.fillAmount = remainTime / allTime
    if remainTime <= 0 then
      if self.parentView_ then
        self.parentView_:refreshAllItem()
      end
      self:clearTimer()
    end
  end, 1, remainTime)
end

function env_skill_item:clearTimer()
  if self.timer_ then
    self.timer_:Stop()
    self.timer_ = nil
  end
end

function env_skill_item:isEquipSkillItem()
  return self.equipSlot_ > 0
end

function env_skill_item:onClickItem()
  self.parentView_:RefreshSelectSkill(self.configResonance_.Id, self:isEquipSkillItem())
end

function env_skill_item:AsyncChangeResonanceSkill()
  local selectResonanceId = self.parentView_.SelectResonanceId_
  local equipResonanceId = self.envVm_.GetEquipResonance(self.equipSlot_)
  if selectResonanceId == 0 then
    if equipResonanceId == 0 then
      Z.TipsVM.ShowTipsLang(1381001)
    end
    self.parentView_:RefreshSelectEquipSkill(self.equipSlot_)
  elseif equipResonanceId == 0 or equipResonanceId ~= selectResonanceId then
    if not self.envVm_.CheckResonanceActive(selectResonanceId) then
      Z.TipsVM.ShowTipsLang(1381002)
      return
    end
    if 0 >= self.envVm_.GetResonanceRemainTime(selectResonanceId) then
      Z.TipsVM.ShowTipsLang(1381003)
      return
    end
    self.changeSlot_ = self.equipSlot_
    Z.AudioMgr:Play("UI_Click_QTE")
    self.envVm_.AsyncChangeResonanceSkill(self.equipSlot_, selectResonanceId, self.parentView_.cancelSource:CreateToken())
  end
end

function env_skill_item:setImageActivate(active)
  if self:isEquipSkillItem() and self.contItem_.img_activate then
    self.contItem_.Ref:SetVisible(self.contItem_.img_activate, active)
    self.contItem_.eff_activate_loop:SetEffectGoVisible(active)
  end
end

function env_skill_item:setBtnChange(active)
  if self:isEquipSkillItem() and self.contItem_.btn_change then
    self.contItem_.Ref:SetVisible(self.contItem_.btn_change, active)
    if self.contItem_.eff_activate_loop_change then
      self.contItem_.eff_activate_loop_change:SetEffectGoVisible(active)
    end
  end
end

function env_skill_item:setBtnChangeEff(active)
  if self:isEquipSkillItem() and self.contItem_.eff_switch then
    self.contItem_.eff_switch:SetEffectGoVisible(active)
  end
end

return env_skill_item
