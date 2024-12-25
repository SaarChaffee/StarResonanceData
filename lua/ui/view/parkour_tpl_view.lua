local deltaTime = 0.1
local UI = Z.UI
local super = require("ui.ui_subview_base")
local Parkour_tplView = class("Parkour_tplView", super)

function Parkour_tplView:ctor()
  self.panel = nil
  super.ctor(self, "parkour_tpl", "parkour/parkour_tpl", UI.ECacheLv.None)
end

function Parkour_tplView:OnActive()
  self:initData()
  self:BindLuaAttrWatchers()
  self:BindEvents()
end

function Parkour_tplView:OnDeActive()
  self.panel.effectParent1.ZEff:SetEffectGoVisible(false)
  if self.glideWatcher ~= nil then
    self.glideWatcher:Dispose()
    self.glideWatcher = nil
  end
end

function Parkour_tplView:BindEvents()
  Z.EventMgr:Add("OnQteSucess", self.QteRecovery, self)
  Z.EventMgr:Add(Z.ConstValue.Parkour.QteDash, self.QteDash, self)
  Z.EventMgr:Add(Z.ConstValue.Parkour.QteAlert, self.AlertEnergy, self)
end

function Parkour_tplView:BindLuaAttrWatchers()
  if Z.EntityMgr.PlayerEnt ~= nil then
    self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrMaxOriginEnergy")
    }, Z.EntityMgr.PlayerEnt, self.refreshMaxEnergy)
    self.glideWatcher = Z.DIServiceMgr.PlayerAttrComponentWatcherService:OnLocalAttrGlideChanged(function()
      self:onPlayerSpeedChange()
    end)
    self:BindEntityLuaAttrWatcher({
      Z.LocalAttr.ETunnelFlySpeed
    }, Z.EntityMgr.PlayerEnt, self.onPlayerSpeedChange, true)
    self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrState")
    }, Z.EntityMgr.PlayerEnt, self.onPlayerStateChange)
  end
end

function Parkour_tplView:OnRefresh()
  self.panel.anim:SetVisible(false)
  self.panel.followParentSpeed:SetVisible(false)
  self.panel.parkour_bar_red:SetVisible(false)
end

function Parkour_tplView:refreshMaxEnergy()
  self.nowMaxValue_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrMaxOriginEnergy")).Value
  self.panel.parkour_bg.Img:SetFillAmount(self.nowMaxValue_ / self.maxValue_)
end

function Parkour_tplView:onPlayerStateChange()
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  local showSpeed = Z.PbEnum("EActorState", "ActorStateGlide") == stateId or Z.PbEnum("EActorState", "ActorStateTunnelFly") == stateId
  self.panel.followParentSpeed:SetVisible(showSpeed)
end

function Parkour_tplView:onPlayerSpeedChange()
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  if Z.PbEnum("EActorState", "ActorStateGlide") ~= stateId and Z.PbEnum("EActorState", "ActorStateTunnelFly") ~= stateId then
    self.panel.followParentSpeed:SetVisible(false)
    return
  end
  self.panel.followParentSpeed:SetVisible(true)
  self:calculationSpeed()
end

function Parkour_tplView:calculationSpeed()
  local realVelocity = 0
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  if Z.PbEnum("EActorState", "ActorStateGlide") == stateId then
    local velocityH = Z.EntityMgr.PlayerEnt:GetLocalAttrGlideVelocityH()
    local velocityV = Z.EntityMgr.PlayerEnt:GetLocalAttrGlideVelocityV()
    local velocity = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrAttachVelocity")).Value
    realVelocity = math.sqrt(velocityH * velocityH + velocityV * velocityV) + velocity
  elseif Z.PbEnum("EActorState", "ActorStateTunnelFly") == stateId then
    realVelocity = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.ETunnelFlySpeed).Value
  end
  self.panel.lab_num.TMPLab.text = string.format(Lang("speed"), string.format("%.2f", realVelocity))
end

function Parkour_tplView:initData()
  self.playerEntity_ = Z.EntityMgr:GetEntity(tostring(Z.EntityMgr.PlayerUuid))
  self.maxValue_ = Z.GlobalParkour.OriginEnergyValue
  self.cd_ = Z.GlobalParkour.OriginEnergyBarMuteTime
  self.alterPercent_ = Z.GlobalParkour.OriginEnergyAlertPercent
  self.curEnergy_ = self.playerEntity_:GetLuaAttr(Z.LocalAttr.EOriginEnergy).Value
  self.lastEnergy_ = self.curEnergy_
  self.hideCount_ = 0
  self.isAlert_ = false
  self.isQte_ = false
  self.isDash_ = false
  self.isShow_ = false
  self.notEnough_ = false
  self.fullEnergy_ = false
  self.notEnoughEffectCD_ = 0
  self.qteEffectCD_ = 0
  self.qteDashEffectCD_ = 0
  self:refreshMaxEnergy()
  self.timer_ = self.timerMgr:StartTimer(function()
    if self.playerEntity_ == nil then
      return
    end
    self:updateEnergy()
    self:updateEffect()
  end, deltaTime, -1)
end

function Parkour_tplView:updateEnergy()
  self.curEnergy_ = self.playerEntity_:GetLuaAttr(Z.LocalAttr.EOriginEnergy).Value
  local fillAmount = self.curEnergy_ / self.maxValue_
  self.panel.parkour_bar.Img:SetFillAmount(fillAmount)
  self.panel.parkour_bar_blue.Img:SetFillAmount(fillAmount)
  self.panel.parkour_bar_red.Img:SetFillAmount(fillAmount)
  self:checkCd()
  self:checkAlert()
  self:checkFullEnergy()
end

function Parkour_tplView:updateEffect()
  if self.isQte_ then
    self.qteEffectCD_ = self.qteEffectCD_ + deltaTime
    if self.qteEffectCD_ >= 2 then
      self.qteEffectCD_ = 0
      self.isQte_ = false
    end
  end
  if self.isDash_ then
    self.qteDashEffectCD_ = self.qteDashEffectCD_ + deltaTime
    if self.qteDashEffectCD_ >= 4 then
      self.qteDashEffectCD_ = 0
      self.isDash_ = false
    end
  end
  if self.notEnough_ then
    self.notEnoughEffectCD_ = self.notEnoughEffectCD_ + deltaTime
    if 2 <= self.notEnoughEffectCD_ then
      self.notEnoughEffectCD_ = 0
      self.notEnough_ = false
    end
  end
end

function Parkour_tplView:checkCd()
  if self.curEnergy_ and self.lastEnergy_ then
    if self.curEnergy_ == self.lastEnergy_ then
      self.hideCount_ = self.hideCount_ + deltaTime
      if self.hideCount_ >= self.cd_ then
        self.hideCount_ = 0
        if self.isShowEnergy_ then
          Z.CoroUtil.create_coro_xpcall(function()
            self.panel.anim.anim:Stop()
            self.panel.followParent.anim:Stop()
            self.isAlert_ = false
            local asyncCall = Z.CoroUtil.async_to_sync(self.panel.anim.anim.CoroPlayOnce)
            asyncCall(self.panel.anim.anim, "anim_parkour_tpl_close", self.cancelSource:CreateToken())
            self.panel.anim:SetVisible(false)
            self.isShowEnergy_ = false
          end, function()
            self.panel.anim:SetVisible(false)
            self.isShowEnergy_ = false
          end)()
        end
      end
    else
      self.hideCount_ = 0
      if not self.isShowEnergy_ then
        self.panel.effectParent1:SetVisible(false)
        Z.CoroUtil.create_coro_xpcall(function()
          if self.curEnergy_ and self.curEnergy_ > self.alterPercent_ then
            self.isAlert_ = true
          end
          local asyncCall = Z.CoroUtil.async_to_sync(self.panel.anim.anim.CoroPlayOnce)
          asyncCall(self.panel.anim.anim, "anim_parkour_tpl_open", self.cancelSource:CreateToken())
          self.panel.anim:SetVisible(true)
          self.isShowEnergy_ = true
        end, function()
          self.panel.anim:SetVisible(true)
          self.isShowEnergy_ = true
        end)()
      end
    end
  end
  self.lastEnergy_ = self.curEnergy_
end

function Parkour_tplView:checkFullEnergy()
  if self.curEnergy_ >= self.nowMaxValue_ then
    if not self.fullEnergy_ then
      self.fullEnergy_ = true
      self.panel.followParent.anim:PlayOnce("anim_parkour_tpl_blue")
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
  if self.panel then
    if self.isAlert_ then
      self.panel.parkour_bar.Img:SetImage(GetLoadAssetPath(Z.ConstValue.Parkour.BarRed))
      self.panel.effectParent1:SetVisible(true)
      self.panel.followParent.anim:PlayLoop("anim_parkour_tpl_red")
    else
      self.panel.parkour_bar.Img:SetImage(GetLoadAssetPath(Z.ConstValue.Parkour.BarBlue))
      self.panel.followParent.anim:Stop()
      self.panel.effectParent1:SetVisible(false)
    end
  end
end

function Parkour_tplView:AlertEnergy()
  if not self.notEnough_ then
    self.notEnough_ = not self.notEnough_
    self.notEnoughEffectCD_ = 0
  end
end

function Parkour_tplView:QteRecovery(qteId, parkourSytleId)
  if qteId ~= 4 and qteId ~= 5 and qteId ~= 6 and qteId ~= 7 then
    return
  end
  self.isQte_ = true
  self.qteEffectCD_ = 0
  if parkourSytleId then
    local n1, n2 = math.modf(parkourSytleId)
    local config = Z.TableMgr.GetTable("ParkourStyleActionTableMgr").GetRow(n1)
    if config and config.EnergyValue == 0 then
      return
    end
  end
end

function Parkour_tplView:QteDash(parkourSytleId)
  self.isDash_ = true
  self.qteDashEffectCD_ = 0
  if parkourSytleId then
    local n1, n2 = math.modf(parkourSytleId)
    local config = Z.TableMgr.GetTable("ParkourStyleActionTableMgr").GetRow(n1)
    if config and config.EnergyValue == 0 then
      return
    end
  end
end

return Parkour_tplView
