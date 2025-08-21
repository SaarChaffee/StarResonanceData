local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local JumpCtrlBtn = class("JumpCtrlBtn", super)
local inputKeyDescComp = require("input.input_key_desc_comp")

function JumpCtrlBtn:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function JumpCtrlBtn:GetUIUnitPath()
  local path = GetLoadAssetPath("BattleBtn_Jump")
  return Z.IsPCUI and path .. Z.ConstValue.PCAssetSuffix or path
end

function JumpCtrlBtn:OnActive()
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, 7)
  self.inputKeyDescComp_:Init(7, self.uiBinder.binder_key)
  self.uiBinder.event_trigger.onDown:AddListener(function()
    if self.uiBinder == nil then
      return
    end
    self.uiBinder.effect_click:SetEffectGoVisible(true)
    if self.clickEffectTimer then
      self.panel_.timerMgr:StopTimer(self.clickEffectTimer)
      self.clickEffectTimer = nil
    end
    self.clickEffectTimer = self.panel_.timerMgr:StartTimer(function()
      self.uiBinder.effect_click:SetEffectGoVisible(false)
    end, 0.3, 1)
    Z.PlayerInputController:Jump(true)
  end)
  self.uiBinder.event_trigger.onUp:AddListener(function()
    if self.uiBinder == nil then
      return
    end
    Z.PlayerInputController:Jump(false)
  end)
end

function JumpCtrlBtn:OnDeActive()
  self.inputKeyDescComp_:UnInit()
  self.uiBinder.event_trigger.onDown:RemoveAllListeners()
  self.uiBinder.event_trigger.onUp:RemoveAllListeners()
  self.uiBinder.effect_click:SetEffectGoVisible(false)
end

return JumpCtrlBtn
