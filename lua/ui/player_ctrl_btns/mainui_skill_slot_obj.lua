local mainui_skill_slot_obj = class("mainui_skill_slot_obj")
local inputKeyDescComp = require("input.input_key_desc_comp")
local IMG_PATH_GLIDE = "ui/atlas/skill/weapon_fz_glide"
local IMG_PATH_FLOW = "ui/atlas/mainui/skill/weapon_fz_flow"
local IMG_COLOR_DISABLE = Color.New(1, 1, 1, 0.2)
local IMG_COLOR_NORMAL = Color.New(1, 1, 1, 1)

function mainui_skill_slot_obj:ctor(key, uiBinder, uiBinderRoot, parentView)
  self.key_ = key
  self.isBinded_ = false
  self.uiBinder = uiBinder
  self.uiBinderRoot = uiBinderRoot
  self.parentView_ = parentView
  self:RegisterEvent()
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function mainui_skill_slot_obj:Active()
  self.env_Vm = Z.VMMgr.GetVM("env")
  self:InitComponent()
  self:initKeyIcon()
  self:Init()
end

function mainui_skill_slot_obj:DeActive()
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
  self.inputKeyDescComp_:UnInit()
  self:UnregisterEvent()
  self:UnInitComponent()
end

function mainui_skill_slot_obj:RegisterEvent()
  Z.EventMgr:Add(Z.ConstValue.OnEnvSkillCd, self.refreshEnvCd, self)
  if self.key_ == tonumber(E.SlotName.ResonanceSkillSlot_left) then
    Z.EventMgr:Add("ResonanceSkill1", self.keyFuncCall, self)
  elseif self.key_ == tonumber(E.SlotName.ResonanceSkillSlot_right) then
    Z.EventMgr:Add("ResonanceSkill2", self.keyFuncCall, self)
  end
  self:BindLuaAttrWatchers()
end

function mainui_skill_slot_obj:UnregisterEvent()
  Z.EventMgr:RemoveObjAll(self)
  self.isBinded_ = false
end

function mainui_skill_slot_obj:InitComponent()
  self.uiBinder.binder_count_down_cd.count_down:Init()
  self.uiBinder.binder_count_down_continue.count_down:Init()
  self.uiBinder.binder_count_down_other.count_down:Init()
  self.uiBinder.skill_slot_data:Init()
  self.parentView_:AddAsyncClick(self.uiBinder.btn_item, function()
    self:keyFuncCall(1)
  end)
end

function mainui_skill_slot_obj:UnInitComponent()
  self.uiBinder.binder_count_down_cd.count_down:UnInit()
  self.uiBinder.binder_count_down_continue.count_down:UnInit()
  self.uiBinder.binder_count_down_other.count_down:UnInit()
  self.uiBinder.skill_slot_data:UnInit()
end

function mainui_skill_slot_obj:Init()
  self:refreshResonanceInfo()
end

function mainui_skill_slot_obj:refreshEnvCd(changeResonanceId)
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  if self.resonanceId_ == nil or self.resonanceId_ <= 0 then
    self.uiBinder.skill_slot_data:SetSlotKey(0)
    self.uiBinderRoot.Ref.UIComp:SetVisible(false)
    return
  end
  self.uiBinderRoot.Ref.UIComp:SetVisible(true)
  if changeResonanceId and self.resonanceId_ ~= changeResonanceId then
    return
  end
end

function mainui_skill_slot_obj:keyFuncCall(keyState)
  if self.resonanceId_ == 50101 then
    if Z.EntityMgr.PlayerEnt == nil then
      logError("PlayerEnt is nil")
      return
    end
    if keyState == 2 then
      return
    end
    logGreen("keyFuncCall" .. self.resonanceId_)
    local stateID = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
    if stateID == Z.PbEnum("EActorState", "ActorStateFlow") then
      Z.PlayerInputController:Flow(false)
    elseif stateID == Z.PbEnum("EActorState", "ActorStateGlide") then
      Z.PlayerInputController:Glide(false)
    else
      local tmp = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrCanFlow"))
      if tmp and tmp.Value > 0 then
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
      else
        tmp = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrCanGlide"))
        if tmp and tmp.Value > 0 then
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
        end
      end
    end
  else
    local slotId = tonumber(self.key_) or logError("[mainui_skill_slot_obj:AddListener] tonumber slotId failed! self.key_ {0}", self.key_)
    if keyState == 1 then
      Z.PlayerInputController:Attack(slotId, true)
    elseif keyState == 2 then
      Z.PlayerInputController:Attack(slotId, false)
    end
  end
end

function mainui_skill_slot_obj:initKeyIcon()
  local idx = tonumber(self.key_)
  local slotConfig = Z.TableMgr.GetTable("SkillSlotPositionTableMgr").GetRow(idx)
  if slotConfig and slotConfig.KeyPositionId and slotConfig.KeyPositionId ~= 0 then
    self.inputKeyDescComp_:Init(slotConfig.KeyPositionId, self.uiBinder.com_icon_key)
    self.inputKeyDescComp_:SetVisible(true)
  else
    self.inputKeyDescComp_:UnInit()
    self.uiBinder.com_icon_key.Ref.UIComp:SetVisible(false)
  end
end

function mainui_skill_slot_obj:BindLuaAttrWatchers()
  if self.isBinded_ then
    return
  end
  self.playerStateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
    self:refreshFlowBtns()
  end)
  local resonanceAttrList = {
    Z.PbAttrEnum("AttrResourceLeft"),
    Z.PbAttrEnum("AttrResourceRight")
  }
  self.parentView_:BindEntityLuaAttrWatcher(resonanceAttrList, Z.EntityMgr.PlayerEnt, function()
    self:refreshResonanceInfo()
  end)
  self.isBinded_ = true
end

function mainui_skill_slot_obj:refreshFlowBtns()
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  if self.resonanceId_ ~= 50101 then
    return
  end
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  if stateID == Z.PbEnum("EActorState", "ActorStateGlide") then
    self.uiBinder.img_skill_icon:SetImage(IMG_PATH_GLIDE)
  else
    self.uiBinder.img_skill_icon:SetImage(IMG_PATH_FLOW)
  end
end

function mainui_skill_slot_obj:refreshResonanceInfo()
  if self.key_ == tonumber(E.SlotName.ResonanceSkillSlot_left) then
    self.resonanceId_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrResourceLeft")).Value
  elseif self.key_ == tonumber(E.SlotName.ResonanceSkillSlot_right) then
    self.resonanceId_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrResourceRight")).Value
  end
  if self.resonanceId_ == 50101 then
    self:refreshFlowBtns()
    self.uiBinder.skill_slot_data:SetSlotKey(0)
    self.uiBinder.skill_slot_data:SetCheckFlowCanUseFlag(true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_skill_icon, true)
  else
    self.uiBinder.skill_slot_data:SetSlotKey(self.key_)
    self.uiBinder.skill_slot_data:SetCheckFlowCanUseFlag(false)
  end
  self:refreshEnvCd()
end

return mainui_skill_slot_obj
