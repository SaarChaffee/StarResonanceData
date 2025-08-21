local deltaTime = 0.1
local UI = Z.UI
local super = require("ui.ui_subview_base")
local Parkour_tplView = class("Parkour_tplView", super)

function Parkour_tplView:ctor()
  self.uiBinder = nil
  super.ctor(self, "parkour_tpl", "parkour/parkour_tpl", UI.ECacheLv.None)
end

function Parkour_tplView:OnActive()
  self.uiBinder.Ref:SetVisible(self.uiBinder.root, not Z.IsPCUI)
  if not Z.IsPCUI then
    self:initData()
    self:BindEvents()
  end
  self:BindLuaAttrWatchers()
end

function Parkour_tplView:OnDeActive()
  self.uiBinder.effect_parent_1:SetEffectGoVisible(false)
  if self.glideWatcher ~= nil then
    self.glideWatcher:Dispose()
    self.glideWatcher = nil
  end
  if self.tunnelFlyWatcher ~= nil then
    self.tunnelFlyWatcher:Dispose()
    self.tunnelFlyWatcher = nil
  end
  if self.stateWatcher ~= nil then
    self.stateWatcher:Dispose()
    self.stateWatcher = nil
  end
end

function Parkour_tplView:BindEvents()
  Z.EventMgr:Add("MaxOriginEnergyChanged", self.refreshMaxEnergy, self)
end

function Parkour_tplView:BindLuaAttrWatchers()
  if Z.EntityMgr.PlayerEnt == nil then
    return
  end
  self.glideWatcher = Z.DIServiceMgr.PlayerAttrComponentWatcherService:OnLocalAttrGlideChanged(function()
    self:onPlayerSpeedChange()
  end)
  self.tunnelFlyWatcher = Z.DIServiceMgr.TunnelFlyComponentWatcherService:OnTunnelSpeedChanged(function()
    self:onPlayerSpeedChange()
  end)
  self.stateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
    self:onPlayerStateChange()
  end)
end

function Parkour_tplView:OnRefresh()
  self:SetUIVisible(self.uiBinder.anim_main, false)
  self:SetUIVisible(self.uiBinder.trans_speed, false)
  self:SetUIVisible(self.uiBinder.img_bar_red, false)
end

function Parkour_tplView:refreshMaxEnergy()
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return
  end
  self.maxValue_ = Z.EntityMgr.PlayerEnt:GetLuaMaxOriEnergy()
  self.uiBinder.img_bg:SetFillAmount(self.curEnergy_ / self.maxValue_)
end

function Parkour_tplView:onPlayerStateChange()
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  local showSpeed = Z.PbEnum("EActorState", "ActorStateGlide") == stateId or Z.PbEnum("EActorState", "ActorStateTunnelFly") == stateId
  self:SetUIVisible(self.uiBinder.trans_speed, showSpeed)
end

function Parkour_tplView:onPlayerSpeedChange()
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  if Z.PbEnum("EActorState", "ActorStateGlide") ~= stateId and Z.PbEnum("EActorState", "ActorStateTunnelFly") ~= stateId then
    self:SetUIVisible(self.uiBinder.trans_speed, false)
    return
  end
  self:SetUIVisible(self.uiBinder.trans_speed, true)
  self:calculationSpeed()
end

function Parkour_tplView:calculationSpeed()
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return
  end
  local realVelocity = 0
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  if Z.PbEnum("EActorState", "ActorStateGlide") == stateId then
    local velocityH = Z.EntityMgr.PlayerEnt:GetLocalAttrGlideVelocityH()
    local velocityV = Z.EntityMgr.PlayerEnt:GetLocalAttrGlideVelocityV()
    local velocity = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrAttachVelocity")).Value
    realVelocity = math.sqrt(velocityH * velocityH + velocityV * velocityV) + velocity
  elseif Z.PbEnum("EActorState", "ActorStateTunnelFly") == stateId then
    realVelocity = Z.EntityMgr.PlayerEnt:GetLocalAttrTunnelFlySpeed()
  end
  self.uiBinder.lab_num.text = string.format(Lang("speed"), string.format("%.2f", realVelocity))
end

function Parkour_tplView:initData()
  self.playerEntity_ = Z.EntityMgr:GetEntity(tostring(Z.EntityMgr.PlayerUuid))
  if self.playerEntity_ == nil then
    logError("PlayerEnt is nil")
    return
  end
  self.maxValue_ = Z.GlobalParkour.OriginEnergyValue
  self.cd_ = Z.GlobalParkour.OriginEnergyBarMuteTime
  self.alterPercent_ = Z.GlobalParkour.OriginEnergyAlertPercent
  self.curEnergy_ = self.playerEntity_:GetLuaOriginEnergy()
  self.lastEnergy_ = self.curEnergy_
  self.hideCount_ = 0
  self.isAlert_ = false
  self.fullEnergy_ = false
  self:refreshMaxEnergy()
  self.timer_ = self.timerMgr:StartTimer(function()
    if self.playerEntity_ == nil then
      return
    end
    self:updateEnergy()
  end, deltaTime, -1)
end

function Parkour_tplView:updateEnergy()
  self.curEnergy_ = self.playerEntity_:GetLuaOriginEnergy()
  local fillAmount = self.curEnergy_ / self.maxValue_
  self.uiBinder.img_bar:SetFillAmount(fillAmount)
  self.uiBinder.img_bar_blue:SetFillAmount(fillAmount)
  self.uiBinder.img_bar_red:SetFillAmount(fillAmount)
  self:checkCd()
  self:checkAlert()
  self:checkFullEnergy()
end

function Parkour_tplView:checkCd()
  if self.curEnergy_ and self.lastEnergy_ then
    if self.curEnergy_ == self.lastEnergy_ then
      self.hideCount_ = self.hideCount_ + deltaTime
      if self.hideCount_ >= self.cd_ then
        self.hideCount_ = 0
        if self.isShowEnergy_ then
          Z.CoroUtil.create_coro_xpcall(function()
            self.uiBinder.anim_main:Stop()
            self.uiBinder.anim_follow:Stop()
            self.isAlert_ = false
            local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.anim_main.CoroPlayOnce)
            asyncCall(self.uiBinder.anim_main, "anim_parkour_tpl_close", self.cancelSource:CreateToken())
            self:SetUIVisible(self.uiBinder.anim_main, false)
            self.isShowEnergy_ = false
          end, function()
            self:SetUIVisible(self.uiBinder.anim_main, false)
            self.isShowEnergy_ = false
          end)()
        end
      end
    else
      self.hideCount_ = 0
      if not self.isShowEnergy_ then
        self:SetUIVisible(self.uiBinder.effect_parent_1, false)
        Z.CoroUtil.create_coro_xpcall(function()
          if self.curEnergy_ and self.curEnergy_ > self.alterPercent_ then
            self.isAlert_ = true
          end
          local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.anim_main.CoroPlayOnce)
          asyncCall(self.uiBinder.anim_main, "anim_parkour_tpl_open", self.cancelSource:CreateToken())
          self:SetUIVisible(self.uiBinder.anim_main, true)
          self.isShowEnergy_ = true
        end, function()
          self:SetUIVisible(self.uiBinder.anim_main, true)
          self.isShowEnergy_ = true
        end)()
      end
    end
  end
  self.lastEnergy_ = self.curEnergy_
end

function Parkour_tplView:checkFullEnergy()
  if self.curEnergy_ >= self.maxValue_ then
    if not self.fullEnergy_ then
      self.fullEnergy_ = true
      self.uiBinder.anim_follow:PlayOnce("anim_parkour_tpl_blue")
    end
  elseif self.fullEnergy_ then
    self.fullEnergy_ = false
  end
end

function Parkour_tplView:checkAlert()
  if not self.isShowEnergy_ then
    return
  end
  if self.curEnergy_ then
    if self.curEnergy_ <= self.alterPercent_ then
      if not self.isAlert_ then
        self.isAlert_ = true
        self:changeParkOurImg()
      end
    elseif self.isAlert_ then
      self.isAlert_ = false
      self:changeParkOurImg()
    end
  end
end

function Parkour_tplView:changeParkOurImg()
  if self.uiBinder then
    if self.isAlert_ then
      self.uiBinder.img_bar:SetImage(GetLoadAssetPath(Z.ConstValue.Parkour.BarRed))
      self:SetUIVisible(self.uiBinder.effect_parent_1, true)
      self.uiBinder.anim_follow:PlayLoop("anim_parkour_tpl_red")
    else
      self.uiBinder.img_bar:SetImage(GetLoadAssetPath(Z.ConstValue.Parkour.BarBlue))
      self.uiBinder.anim_follow:Stop()
      self:SetUIVisible(self.uiBinder.effect_parent_1, false)
    end
  end
end

return Parkour_tplView
