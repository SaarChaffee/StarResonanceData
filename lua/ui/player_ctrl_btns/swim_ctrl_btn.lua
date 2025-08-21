local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local SwimCtrlBtn = class("SwimCtrlBtn", super)
local inputKeyDescComp = require("input.input_key_desc_comp")

function SwimCtrlBtn:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
  self.uiMaxLayer_ = 0
  self.chargeMax_ = 0
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function SwimCtrlBtn:GetUIUnitPath()
  local path = GetLoadAssetPath("BattleBtn_Swim")
  return Z.IsPCUI and path .. Z.ConstValue.PCAssetSuffix or path
end

function SwimCtrlBtn:OnActive()
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, 8)
  self.inputKeyDescComp_:Init(8, self.uiBinder.binder_key)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  self.uiBinder.event_trigger.onDown:AddListener(function()
    if self.uiBinder == nil then
      return
    end
    self.uiBinder.effect_click:SetEffectGoVisible(false)
    self.uiBinder.effect_click:SetEffectGoVisible(true)
    Z.PlayerInputController:SwimSprint(true)
  end)
  self.uiBinder.event_trigger.onUp:AddListener(function()
    Z.PlayerInputController:SwimSprint(false)
  end)
end

function SwimCtrlBtn:OnDeActive()
  self.uiBinder.event_trigger.onDown:RemoveAllListeners()
  self.uiBinder.event_trigger.onUp:RemoveAllListeners()
  self.uiBinder.effect_click:SetEffectGoVisible(false)
  self.inputKeyDescComp_:UnInit()
end

function SwimCtrlBtn:BindLuaAttrWatchers()
  self:BindEntityLuaAttrWatcher({
    Z.LocalAttr.ESwimStage
  }, Z.EntityMgr.PlayerEnt, self.onSwimStageChanged, true)
end

function SwimCtrlBtn:onSwimStageChanged()
  if self.uiBinder == nil then
    return
  end
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local swimStage = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.ESwimStage).Value
  if swimStage == 4 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  end
end

return SwimCtrlBtn
