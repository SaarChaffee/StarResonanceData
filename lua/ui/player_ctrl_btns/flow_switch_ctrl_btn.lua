local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local FlowSwitchCtrlBtn = class("FlowSwitchCtrlBtn", super)
local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")
local IMG_PATH_GLIDE = "ui/atlas/skill/weapon_fz_glide"
local IMG_PATH_FLOW = "ui/atlas/mainui/skill/weapon_fz_flow"

function FlowSwitchCtrlBtn:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
end

function FlowSwitchCtrlBtn:GetUIUnitPath()
  local path = GetLoadAssetPath("BattleBtn_Flow")
  return Z.IsPCUI and path .. Z.ConstValue.PCAssetSuffix or path
end

function FlowSwitchCtrlBtn:OnActive()
  self:InitComponent()
end

function FlowSwitchCtrlBtn:OnDeActive()
  self.uiBinder.steer_item:ClearSteerList()
  self:UnInitComponent()
end

function FlowSwitchCtrlBtn:InitComponent()
  self.uiBinder.binder_count_down.count_down:Init()
  self:AddAsyncClick(self.uiBinder.btn_item, function()
    self:btnCallFunc(1)
  end)
end

function FlowSwitchCtrlBtn:UnInitComponent()
  self.uiBinder.binder_count_down.count_down:UnInit()
  self.uiBinder.btn_item:RemoveAllListeners()
  self.uiBinder.effect_click:SetEffectGoVisible(false)
end

function FlowSwitchCtrlBtn:btnCallFunc(keyState)
  if keyState == 2 then
    return
  end
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  if stateID == Z.PbEnum("EActorState", "ActorStateFlow") then
    if not Z.LuaBridge.CanPlayerEnterState(Z.PbEnum("EActorState", "ActorStateGlide")) then
      Z.TipsVM.ShowTipsLang(130035)
      return
    end
    Z.PlayerInputController:Glide(true)
  elseif stateID == Z.PbEnum("EActorState", "ActorStateGlide") then
    if not Z.LuaBridge.CanPlayerEnterState(Z.PbEnum("EActorState", "ActorStateFlow")) then
      Z.TipsVM.ShowTipsLang(130036)
      return
    end
    Z.PlayerInputController:Flow(true)
  end
end

function FlowSwitchCtrlBtn:BindLuaAttrWatchers()
  self.playerFlowWatcher = self:BindEntityLuaAttrWatcher({
    Z.LocalAttr.EAttrState
  }, Z.EntityMgr.PlayerEnt, self.refreshFlowBtns, true)
end

function FlowSwitchCtrlBtn:refreshFlowBtns()
  if self.isReset_ then
    return
  end
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  if Z.PbEnum("EActorState", "ActorStateFlow") == stateID then
    self.uiBinder.img_button:SetImage(IMG_PATH_GLIDE)
  else
    self.uiBinder.img_button:SetImage(IMG_PATH_FLOW)
  end
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, 11)
  keyIconHelper.InitKeyIcon(self, self.uiBinder.binder_key, 11)
end

return FlowSwitchCtrlBtn
