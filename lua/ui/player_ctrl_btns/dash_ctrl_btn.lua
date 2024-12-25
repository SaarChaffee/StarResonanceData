local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local DashCtrlBtn = class("DashCtrlBtn", super)
local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")
local DotShowData = {
  [3] = {
    progressFactor = {
      0,
      0.24,
      0.486,
      1
    },
    progress = "ui/atlas/skill/skill_bar_top_big_3",
    bg = "ui/atlas/skill/skill_bar_bg_big_3"
  },
  [4] = {
    progressFactor = {
      0,
      0.129,
      0.321,
      0.56,
      1
    },
    progress = "ui/atlas/skill/skill_bar_top_big_4",
    bg = "ui/atlas/skill/skill_bar_bg_big_4"
  },
  [5] = {
    progressFactor = {
      0,
      0.107,
      0.241,
      0.417,
      0.608,
      1
    },
    progress = "ui/atlas/skill/skill_bar_top_big_5",
    bg = "ui/atlas/skill/skill_bar_bg_big_5"
  }
}
local RUSH_IMG_PATH_1 = "ui/atlas/proficiency/proficiency_skill_03"
local RUSH_IMG_PATH_2 = "ui/atlas/mainui/skill/sprint"
local RUSH_IMG_COLOR_1 = Color.New(1, 1, 1, 0.2)
local RUSH_IMG_COLOR_2 = Color.New(1, 1, 1, 1)

function DashCtrlBtn:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
  self.isDisable_ = false
  self.curChargeCount_ = 0
  self.currentCDKey_ = ""
  self.uiMaxLayer_ = 0
  self.chargeMax_ = 0
end

function DashCtrlBtn:GetUIUnitPath()
  local path = GetLoadAssetPath("BattleBtn_Dash")
  return Z.IsPCUI and path .. Z.ConstValue.PCAssetSuffix or path
end

function DashCtrlBtn:OnActive()
  self:InitComponent()
  self:refreshRushMaxCharge()
end

function DashCtrlBtn:OnDeActive()
  self:UnInitComponent()
end

function DashCtrlBtn:InitComponent()
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer_icon, E.DynamicSteerType.KeyBoardId, 8)
  keyIconHelper.InitKeyIcon(self, self.uiBinder.binder_key, 8)
  self.uiBinder.binder_count_down.count_down:Init()
  self.uiBinder.event_trigger.onDown:AddListener(function()
    if self.uiBinder == nil or self.isDisable_ then
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
    Z.PlayerInputController:Rush(true)
  end)
  self.uiBinder.event_trigger.onUp:AddListener(function()
    if self.uiBinder == nil or self.isDisable_ then
      return
    end
    Z.PlayerInputController:Rush(false)
  end)
end

function DashCtrlBtn:UnInitComponent()
  self.uiBinder.binder_count_down.count_down:UnInit()
  self.uiBinder.event_trigger.onDown:RemoveAllListeners()
  self.uiBinder.event_trigger.onUp:RemoveAllListeners()
  self.uiBinder.effect_click:SetEffectGoVisible(false)
end

function DashCtrlBtn:RegisterEvent()
  Z.EventMgr:Add("OnCDLayerChanged", self.OnCDLayerChanged, self)
end

function DashCtrlBtn:UnregisterEvent()
  Z.EventMgr:RemoveObjAll(self)
end

function DashCtrlBtn:OnCDLayerChanged(key)
  if self.uiBinder == nil then
    return
  end
  local cdHandler = self.uiBinder.binder_count_down.count_down
  if key == self.currentCDKey_ then
    if cdHandler:CurrentKeyIsInCD() then
      self.curChargeCount_ = cdHandler:GetChargeLayer()
    else
      self.curChargeCount_ = self.chargeMax_
    end
    self:RefreshChargeCount()
  end
end

function DashCtrlBtn:BindLuaAttrWatchers()
  self:BindEntityLuaAttrWatcher({
    Z.PbAttrEnum("AttrProfessionId")
  }, Z.EntityMgr.PlayerEnt, self.refreshRushMaxCharge)
  self:BindEntityLuaAttrWatcher({
    Z.LocalAttr.EParkourRunning
  }, Z.EntityMgr.PlayerEnt, self.refreshRushIcon, true)
  self:BindEntityLuaAttrWatcher({
    Z.PbAttrEnum("AttrBattleRushChargeBegin")
  }, Z.EntityMgr.PlayerEnt, self.CreateRushCD)
  self:BindEntityLuaAttrWatcher({
    Z.LocalAttr.EAttrState
  }, Z.EntityMgr.PlayerEnt, self.refreshEnable, true)
end

function DashCtrlBtn:CreateRushCD()
  local weaponId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrProfessionId")).Value
  if weaponId == 0 then
    return
  end
  local weaponRow = Z.TableMgr.GetTable("ProfessionTableMgr").GetRow(weaponId)
  if weaponRow == nil then
    return
  end
  local chargeBegin = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrBattleRushChargeBegin")).Value
  if chargeBegin < 1 then
    return
  end
  local chargeTime = weaponRow.BattleRushChargeTime
  local cdHandler = self.uiBinder.binder_count_down.count_down
  local vaildTime = 0 < Z.ServerTime:GetServerTime() - chargeBegin and (Z.ServerTime:GetServerTime() - chargeBegin) / 1000 or 0
  if vaildTime > chargeTime * self.chargeMax_ then
    return
  end
  cdHandler.CDLen = tonumber(chargeTime)
  cdHandler.MaxLayer = self.chargeMax_
  cdHandler.Progress = vaildTime / chargeTime / self.chargeMax_
  cdHandler:CreateCD()
end

function DashCtrlBtn:refreshRushMaxCharge()
  if self.uiBinder == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_rush_group, false)
  local weaponId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrProfessionId")).Value
  if weaponId == 0 then
    return
  end
  local weaponRow = Z.TableMgr.GetTable("ProfessionTableMgr").GetRow(weaponId)
  if weaponRow == nil then
    return
  end
  local cdHandler = self.uiBinder.binder_count_down.count_down
  self.currentCDKey_ = cdHandler:GetCurrentKey()
  self.chargeMax_ = weaponRow.BattleRushMaxChargeCount
  if cdHandler:CurrentKeyIsInCD() then
    self.curChargeCount_ = cdHandler:GetChargeLayer()
  else
    self.curChargeCount_ = self.chargeMax_
  end
  self:RefreshChargeCount()
end

function DashCtrlBtn:refreshRushIcon()
  local running = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EParkourRunning)
  if running.Value then
    self.uiBinder.img_icon_normal:SetImage(RUSH_IMG_PATH_1)
  else
    self.uiBinder.img_icon_normal:SetImage(RUSH_IMG_PATH_2)
  end
end

function DashCtrlBtn:refreshEnable()
  local state = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  if state == Z.PbEnum("EActorState", "ActorStatePedalWall") then
    self.uiBinder.img_icon_normal:SetColor(RUSH_IMG_COLOR_1)
  else
    self.uiBinder.img_icon_normal:SetColor(RUSH_IMG_COLOR_2)
  end
end

function DashCtrlBtn:RefreshChargeCount()
  if self.uiMaxLayer_ > 5 then
    self.uiMaxLayer_ = 5
  end
  if self.uiMaxLayer_ < 3 then
    self.uiMaxLayer_ = 3
  end
  local curShData = DotShowData[self.uiMaxLayer_]
  local fillAmountIdx = self.curChargeCount_ > self.uiMaxLayer_ and self.uiMaxLayer_ or self.curChargeCount_
  local fillAmount = curShData.progressFactor[fillAmountIdx + 1]
  if fillAmount == nil then
    return
  end
  self.uiBinder.img_count_progress.fillAmount = fillAmount
  self.uiBinder.img_count_progress:SetImage(curShData.progress)
  self.uiBinder.img_dot_group:SetImage(curShData.bg)
end

return DashCtrlBtn
