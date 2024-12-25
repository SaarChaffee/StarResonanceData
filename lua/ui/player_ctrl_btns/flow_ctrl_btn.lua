local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local FlowCtrlBtn = class("FlowCtrlBtn", super)
local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")
local IMG_PATH_GLIDE = "ui/atlas/skill/weapon_fz_glide"
local IMG_PATH_FLOW = "ui/atlas/mainui/skill/weapon_fz_flow"
local IMG_COLOR_DISABLE = Color.New(1, 1, 1, 0.2)
local IMG_COLOR_NORMAL = Color.New(1, 1, 1, 1)

function FlowCtrlBtn:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
end

function FlowCtrlBtn:GetUIUnitPath()
  local path = GetLoadAssetPath("BattleBtn_Flow")
  return Z.IsPCUI and path .. Z.ConstValue.PCAssetSuffix or path
end

function FlowCtrlBtn:OnActive()
  self:InitComponent()
  self.env_Vm = Z.VMMgr.GetVM("env")
  local key
  if self.key_ == E.SlotName.ResonanceSkillSlot_right then
    key = 10
  elseif self.key_ == E.SlotName.ResonanceSkillSlot_left then
    key = 9
  end
  self:refreshEnvCd()
  if key == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.binder_key, false)
    return
  end
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_item, E.DynamicSteerType.KeyBoardId, key)
  keyIconHelper.InitKeyIcon(self, self.uiBinder.binder_key, key)
end

function FlowCtrlBtn:refreshEnvCd(changeResonanceId)
  local resonanceId
  if self.key_ == E.SlotName.ResonanceSkillSlot_right then
    resonanceId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrResourceRight")).Value
  elseif self.key_ == E.SlotName.ResonanceSkillSlot_left then
    resonanceId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrResourceLeft")).Value
  end
  if changeResonanceId and changeResonanceId ~= resonanceId then
    return
  end
  if resonanceId and resonanceId ~= 0 then
    local row = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr").GetRow(resonanceId)
    if row then
      local cdHandler = self.uiBinder.binder_count_down.count_down
      cdHandler.CDLen = row.Time
      cdHandler.Progress = 1 - self.env_Vm.GetResonanceRemainTime(resonanceId) / row.Time
      cdHandler:ChangeCdKey("resonanceDuration_" .. self.key_)
      cdHandler:CreateCD()
    end
  end
end

function FlowCtrlBtn:OnDeActive()
  self:UnInitComponent()
end

function FlowCtrlBtn:InitComponent()
  self.uiBinder.binder_count_down.count_down:Init()
  self:AddAsyncClick(self.uiBinder.btn_item, function()
    self:btnFuncCall(1)
  end)
end

function FlowCtrlBtn:UnInitComponent()
  self.uiBinder.binder_count_down.count_down:UnInit()
  self.uiBinder.btn_item:RemoveAllListeners()
  self.uiBinder.effect_click:SetEffectGoVisible(false)
end

function FlowCtrlBtn:btnFuncCall(keyState)
  if keyState == 2 then
    return
  end
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  if stateID == Z.PbEnum("EActorState", "ActorStateFlow") then
    Z.PlayerInputController:Flow(false)
  elseif stateID == Z.PbEnum("EActorState", "ActorStateGlide") then
    Z.PlayerInputController:Glide(false)
  else
    local tmp = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrCanFlow"))
    if tmp and tmp.Value > 0 then
      if not Z.LuaBridge.CanPlayerEnterState(Z.PbEnum("EActorState", "ActorStateFlow")) then
        Z.TipsVM.ShowTipsLang(130035)
        return
      end
      Z.PlayerInputController:Flow(true)
    else
      tmp = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrCanGlide"))
      if tmp and tmp.Value > 0 then
        if not Z.LuaBridge.CanPlayerEnterState(Z.PbEnum("EActorState", "ActorStateGlide")) then
          Z.TipsVM.ShowTipsLang(130036)
          return
        end
        Z.PlayerInputController:Glide(true)
      end
    end
  end
  self.uiBinder.effect_click:SetEffectGoVisible(false)
  self.uiBinder.effect_click:SetEffectGoVisible(true)
end

function FlowCtrlBtn:RegisterEvent()
  Z.EventMgr:Add(Z.ConstValue.OnEnvSkillCd, self.refreshEnvCd, self)
  if tonumber(self.key_) == 101 then
    Z.EventMgr:Add("ResonanceSkill1", self.btnFuncCall, self)
  elseif tonumber(self.key_) == 102 then
    Z.EventMgr:Add("ResonanceSkill2", self.btnFuncCall, self)
  end
end

function FlowCtrlBtn:BindLuaAttrWatchers()
  self.playerFlowWatcher = self:BindEntityLuaAttrWatcher({
    Z.LocalAttr.EAttrState
  }, Z.EntityMgr.PlayerEnt, self.refreshFlowBtns, true)
end

function FlowCtrlBtn:refreshFlowBtns()
  if self.isReset_ then
    return
  end
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  if stateID == Z.PbEnum("EActorState", "ActorStateSwim") or stateID == Z.PbEnum("EActorState", "ActorStateDead") or stateID == Z.PbEnum("EActorState", "ActorStateResurrection") then
    self.uiBinder.img_button:SetColor(IMG_COLOR_DISABLE)
  else
    self.uiBinder.img_button:SetColor(IMG_COLOR_NORMAL)
  end
  if stateID == Z.PbEnum("EActorState", "ActorStateGlide") then
    self.uiBinder.img_button:SetImage(IMG_PATH_GLIDE)
  else
    self.uiBinder.img_button:SetImage(IMG_PATH_FLOW)
  end
end

function FlowCtrlBtn:UnregisterEvent()
  Z.EventMgr:Remove("ResonanceSkill1", self.btnCallFunc, self)
  Z.EventMgr:Remove("ResonanceSkill2", self.btnCallFunc, self)
  Z.EventMgr:Remove(Z.ConstValue.OnEnvSkillCd, self.refreshEnvCd, self)
end

return FlowCtrlBtn
