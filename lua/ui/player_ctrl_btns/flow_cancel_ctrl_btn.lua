local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local FlowCancelCtrlBtn = class("FlowCancelCtrlBtn", super)
local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")

function FlowCancelCtrlBtn:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
end

function FlowCancelCtrlBtn:GetUIUnitPath()
  local path = GetLoadAssetPath("BattleBtn_Flow")
  return Z.IsPCUI and path .. Z.ConstValue.PCAssetSuffix or path
end

function FlowCancelCtrlBtn:OnActive()
  self:InitComponent()
  self:initKeyAndEvent()
end

function FlowCancelCtrlBtn:OnDeActive()
  self:UnInitComponent()
  if self.flowCdTimer then
    self.timerMgr:StopTimer(self.flowCdTimer)
    self.flowCdTimer = nil
  end
  Z.EventMgr:Remove("ResonanceSkill1", self.btnCallFunc, self)
  Z.EventMgr:Remove("ResonanceSkill2", self.btnCallFunc, self)
end

function FlowCancelCtrlBtn:InitComponent()
  self.uiBinder.binder_count_down.count_down:Init()
  self:AddAsyncClick(self.uiBinder.btn_item, function()
    self:btnCallFunc(1)
  end)
end

function FlowCancelCtrlBtn:UnInitComponent()
  self.uiBinder.binder_count_down.count_down:UnInit()
  self.uiBinder.btn_item:RemoveAllListeners()
  self.uiBinder.effect_click:SetEffectGoVisible(false)
end

function FlowCancelCtrlBtn:initKeyAndEvent()
  local left = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrResourceLeft")).Value
  local right = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrResourceRight")).Value
  if 50101 == left then
    Z.EventMgr:Add("ResonanceSkill1", self.btnCallFunc, self)
    Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, 9)
    keyIconHelper.InitKeyIcon(self, self.uiBinder.binder_key, 9)
  elseif 50101 == right then
    Z.EventMgr:Add("ResonanceSkill2", self.btnCallFunc, self)
    Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, 10)
    keyIconHelper.InitKeyIcon(self, self.uiBinder.binder_key, 10)
  end
end

function FlowCancelCtrlBtn:btnCallFunc(keyState)
  if keyState == 2 then
    return
  end
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  if stateID == Z.PbEnum("EActorState", "ActorStateFlow") then
    Z.PlayerInputController:Flow(false)
  elseif stateID == Z.PbEnum("EActorState", "ActorStateGlide") then
    Z.PlayerInputController:Glide(false)
  end
end

function FlowCancelCtrlBtn:BindLuaAttrWatchers()
  self.playerFlowWatcher = self:BindEntityLuaAttrWatcher({
    Z.LocalAttr.EAttrState
  }, Z.EntityMgr.PlayerEnt, self.refreshFlowBtns, true)
end

function FlowCancelCtrlBtn:refreshFlowBtns()
  if self.isReset_ then
    return
  end
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  if Z.PbEnum("EActorState", "ActorStateFlow") == stateID then
    self.uiBinder.img_button:SetImage("ui/atlas/mainui/skill/weapon_fz_flow")
  else
    self.uiBinder.img_button:SetImage("ui/atlas/skill/weapon_fz_glide")
  end
end

return FlowCancelCtrlBtn
