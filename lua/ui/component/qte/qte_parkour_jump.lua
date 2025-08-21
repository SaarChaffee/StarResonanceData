local qte_parkour_jump = class("qte_parkour_jump")
local QteInfo = require("ui.component.qte.qte_info")

function qte_parkour_jump:ctor(id, fighterview, uiBinder)
  self.timerMgr = Z.TimerMgr.new()
  self.Info_ = QteInfo.new(id)
  if self.Info_ == nil then
    logGreen("self.info is nil")
  end
  math.randomseed(os.time() + id)
  self.key_ = "qte_" .. math.random()
  self.uuid_ = 0
  self.view_ = fighterview
  self.uiBinder_ = uiBinder
  self.qteId_ = id
  self.uiObj_ = nil
  self.isActive_ = true
  self.totalHeight = 0
  self.curIndex = 0
  self.TIME_INTERVEL = 0.04
  self.isVisible_ = false
  self.isFloward_ = true
  self.curTime_ = 0
  self.animTime_ = 0
  self.factor_ = 1
  self.curPointerSpeed = Vector3.zero
  self.fillAmountList_ = {}
  self.isTrigger_ = false
  self.isDestroy_ = false
  self.uiLenth = 430
  if Z.IsPCUI then
    self.uiLenth = 336
  end
  self.curDotCount = 0
  self:Load()
  self:registerEvent()
end

function qte_parkour_jump:registerEvent()
  Z.EventMgr:Add("OnQteTrigger", self.OnQteTrigger, self)
end

function qte_parkour_jump:UnregisterEvent()
  Z.EventMgr:RemoveObjAll(self)
end

function qte_parkour_jump:Load()
  local uipath = self.Info_.UIPath
  Z.CoroUtil.create_coro_xpcall(function()
    if not self.uiObj_ then
      self.uiObj_ = self.view_:AsyncLoadUiUnit(uipath, self.key_, self.uiBinder_.parkour_qte_pos)
      if not self.uiObj_ then
        Z.QteMgr.OnQteClosed(self.uuid_)
        return
      end
    end
    if self.isDestroy_ and self.uiObj_ then
      self:DestroyUI()
      return
    end
    if self.uiObj_ ~= nil then
      self:start()
      if self.isTrigger_ then
        self:OnQteTriggerShow()
      end
    end
  end)()
end

function qte_parkour_jump:start()
  self.uiObj_.progress.Ref:SetPosition(Vector2.New(0, 0))
  for i = 1, self.Info_.maxDotCount do
    self.uiObj_.img_on[i]:SetVisible(false)
    self.uiObj_.effect_start[i].ZEff:SetEffectGoVisible(false)
    self.uiObj_.effect_loop[i].ZEff:SetEffectGoVisible(false)
    self.uiObj_.effect_on[i].ZEff:SetEffectGoVisible(false)
  end
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  self.curDotCount = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EParkourQTEEnergyBean).Value
  self:OpenEnergyBean()
  for i = 1, 3 do
    local areaInfo = self.Info_:GetAreaInfo(i)
    local prec = (areaInfo.endTime - areaInfo.startTime) / self.Info_.maxTime_
    local posprec = areaInfo.startTime / self.Info_.maxTime_
    local width = self.uiLenth * prec
    local pos = Vector2.New(self.uiLenth * posprec, self.uiObj_.progress.Ref:GetPosition().y)
    self.uiObj_["node_" .. i].Ref:SetWidth(width)
    self.uiObj_["node_" .. i].Ref:SetPosition(pos)
  end
  self.timer = self.timerMgr:StartTimer(function()
    self:onUpdate()
  end, self.TIME_INTERVEL, math.floor(self.Info_.maxTime_ / self.TIME_INTERVEL))
  self.destoryTimer = self.timerMgr:StartTimer(function()
    self.Info_:SyncRes()
    self:DestroyUI()
  end, self.Info_.maxTime_ + 0.1)
end

function qte_parkour_jump:OnQteTrigger(qteId)
  if qteId == self.qteId_ or qteId == -1 then
    self.isTrigger_ = true
    self.Info_:OnTrigger(self.curTime_)
    if self.isActive_ and self.Info_.isStop_ then
      self.isActive_ = false
      self.Info_:SyncRes()
      self:OnQteTriggerShow()
    end
  end
  self.Info_:CheckDot()
end

function qte_parkour_jump:OnQteTriggerShow()
  if self.uiObj_ ~= nil then
    self:OpenEnergyBean()
    self.timerMgr:Clear()
    self.deathTimer = self.timerMgr:StartTimer(function()
      self:DestroyUI()
    end, 0.7)
  end
end

function qte_parkour_jump:OpenEnergyBean()
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local enegryDotCount = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EParkourQTEEnergyBean).Value
  for i = 1, enegryDotCount do
    self.uiObj_.img_on[i]:SetVisible(true)
    if i > self.curDotCount then
      self.uiObj_.effect_start[i].ZEff:SetEffectGoVisible(true)
    end
    self.uiObj_.effect_loop[i].ZEff:SetEffectGoVisible(true)
  end
  self.lastDotCount = self.curDotCount
end

function qte_parkour_jump:onUpdate()
  self.curTime_ = self.curTime_ + self.TIME_INTERVEL
  local dx = self:PointerSpeed()
  local progressPos = self.uiObj_.progress.Ref:GetPosition()
  progressPos.x = progressPos.x + dx
  self.uiObj_.progress.Ref:SetPosition(progressPos)
end

function qte_parkour_jump:PointerSpeed()
  local maxTime = self.Info_.maxTime_
  local speed = self.uiLenth / maxTime * self.TIME_INTERVEL
  return speed
end

function qte_parkour_jump:DestroyUI()
  self.isDestroy_ = true
  if self.timerMgr ~= nil then
    self.timerMgr:Clear()
    self.timerMgr = nil
  end
  if self.uiObj_ then
    self.uiObj_.progress.ZEff:ReleseEffGo()
    self.uiObj_.effect_pos.ZEff:ReleseEffGo()
    for i = 1, self.Info_.maxDotCount do
      self.uiObj_.img_on[i]:SetVisible(false)
      self.uiObj_.effect_start[i].ZEff:SetEffectGoVisible(false)
      self.uiObj_.effect_loop[i].ZEff:SetEffectGoVisible(false)
      self.uiObj_.effect_on[i].ZEff:SetEffectGoVisible(false)
    end
  end
  self:UnregisterEvent()
  self.view_:RemoveUiUnit(self.key_)
  Z.QteMgr.OnQteClosed(self.uuid_)
end

return qte_parkour_jump
