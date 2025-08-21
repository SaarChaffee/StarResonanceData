local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local FlowSwitchCtrlBtn = class("FlowSwitchCtrlBtn", super)
local inputKeyDescComp = require("input.input_key_desc_comp")
local IMG_PATH_GLIDE = "ui/atlas/skill/weapon_fz_glide"
local IMG_PATH_FLOW = "ui/atlas/mainui/skill/weapon_fz_flow"

function FlowSwitchCtrlBtn:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function FlowSwitchCtrlBtn:GetUIUnitPath()
  local path = GetLoadAssetPath("BattleBtn_Flow")
  return Z.IsPCUI and path .. Z.ConstValue.PCAssetSuffix or path
end

function FlowSwitchCtrlBtn:OnActive()
  self:InitComponent()
end

function FlowSwitchCtrlBtn:OnDeActive()
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
  self.uiBinder.steer_item:ClearSteerList()
  self:UnInitComponent()
end

function FlowSwitchCtrlBtn:InitComponent()
  self.uiBinder.binder_count_down.count_down:Init()
  self:AddAsyncClick(self.uiBinder.btn_item, function()
    self:btnCallFunc(1)
  end)
  self:refreshFlowBtns()
  self.inputKeyDescComp_:Init(11, self.uiBinder.binder_key)
end

function FlowSwitchCtrlBtn:UnInitComponent()
  self.inputKeyDescComp_:UnInit()
  self.uiBinder.binder_count_down.count_down:UnInit()
  self.uiBinder.btn_item:RemoveAllListeners()
  self.uiBinder.effect_click:SetEffectGoVisible(false)
end

function FlowSwitchCtrlBtn:btnCallFunc(keyState)
  if keyState == 2 then
    return
  end
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  if stateID == Z.PbEnum("EActorState", "ActorStateFlow") then
    local result = Z.LuaBridge.CanPlayerEnterState(Z.PbEnum("EActorState", "ActorStateGlide"))
    if result == Z.ECheckEnterResult.ESuccess then
      Z.PlayerInputController:Glide(true)
    elseif result == Z.ECheckEnterResult.ENotHighEnough then
      Z.TipsVM.ShowTipsLang(130036)
    elseif result == Z.ECheckEnterResult.EEnergyNotEnough then
      Z.TipsVM.ShowTipsLang(130042)
    else
      Z.TipsVM.ShowTipsLang(3203)
    end
  elseif stateID == Z.PbEnum("EActorState", "ActorStateGlide") then
    local result = Z.LuaBridge.CanPlayerEnterState(Z.PbEnum("EActorState", "ActorStateFlow"))
    if result == Z.ECheckEnterResult.ESuccess then
      Z.PlayerInputController:Flow(true)
    elseif result == Z.ECheckEnterResult.ENotHighEnough then
      Z.TipsVM.ShowTipsLang(130035)
    elseif result == Z.ECheckEnterResult.EEnergyNotEnough then
      Z.TipsVM.ShowTipsLang(130042)
    else
      Z.TipsVM.ShowTipsLang(3203)
    end
  end
end

function FlowSwitchCtrlBtn:BindLuaAttrWatchers()
  self.playerStateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
    self:refreshFlowBtns()
  end)
end

function FlowSwitchCtrlBtn:refreshFlowBtns()
  if self.isReset_ then
    return
  end
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  if Z.PbEnum("EActorState", "ActorStateFlow") == stateID then
    self.uiBinder.img_button:SetImage(IMG_PATH_GLIDE)
  else
    self.uiBinder.img_button:SetImage(IMG_PATH_FLOW)
  end
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, 11)
end

return FlowSwitchCtrlBtn
