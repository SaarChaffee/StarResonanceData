local qte_weapon_tdl = class("qte_weapon_tdl")
local QteInfo = require("ui.component.qte.qte_info")

function qte_weapon_tdl:ctor(id, fighterview, panel)
  self.timerMgr = Z.TimerMgr.new()
  self.Info_ = QteInfo.new(id)
  if self.Info_ == nil then
    logGreen("self.info is nil")
  end
  self.key_ = "qte_" .. id
  self.uuid_ = 0
  self.view_ = fighterview
  self.panel_ = panel
  self.qteId_ = id
  self.uiObj_ = nil
  self.curTime_ = 0
  self.curIndex = 0
  self.TIME_INTERVEL = 0.05
  self.isVisible_ = false
  self.isFloward_ = true
  self.isTrigger_ = false
  self.animTime_ = 0
  self.factor_ = 1
  self.curPointerSpeed = Vector3.zero
  self:registerEvent()
  self:Load()
end

function qte_weapon_tdl:registerEvent()
  Z.EventMgr:Add("OnQteTrigger", self.OnQteTrigger, self)
end

function qte_weapon_tdl:UnregisterEvent()
  Z.EventMgr:RemoveObjAll(self)
end

function qte_weapon_tdl:Load()
  local uipath = self.Info_.UIPath
  Z.CoroUtil.create_coro_xpcall(function()
    self.cancelSource = Z.CancelSource.Rent()
    local cancelSource = self.cancelSource:CreateToken()
    if not self.uiObj_ then
      self.uiObj_ = self.view_:AsyncLoadUiUnit(uipath, self.key_, self.panel_.tdl_qte_pos.Trans)
      if Z.CancelSource.IsCanceled(cancelSource) or not self.uiObj_ then
        Z.QteMgr.OnQteClosed(self.uuid_)
        return
      end
    end
    if self.uiObj_ ~= nil then
      self:start()
    end
  end)()
end

function qte_weapon_tdl:start()
  self.uiObj_.bg_knife.anim:PlayByTime("Base Layer.anim_qte_weapon_knife_001", self.Info_.maxTime_)
  self.timer = self.timerMgr:StartTimer(function()
    self:onUpdate()
  end, self.TIME_INTERVEL, self.Info_.maxTime_ / self.TIME_INTERVEL)
  self.destoryTimer = self.timerMgr:StartTimer(function()
    self.Info_:SyncRes()
    self:DestroyUI()
  end, self.Info_.maxTime_ + 0.02)
end

function qte_weapon_tdl:OnQteTrigger(qteId)
  if qteId == self.qteId_ or qteId == -1 then
    self.isTrigger_ = true
    self.Info_:OnTrigger(self.curTime_)
    if self.Info_.isStop_ then
      self.Info_:SyncRes()
      self:DestroyUI()
    end
  end
end

function qte_weapon_tdl:onUpdate()
  self.curTime_ = self.curTime_ + self.TIME_INTERVEL
end

function qte_weapon_tdl:PointerSpeed()
  local maxTime = self.Info_.maxTime_ / 2
  logGreen("width .." .. self.uiObj_.bg.Ref:GetSize().x)
  local speed = self.uiObj_.bg.Ref:GetSize().x / maxTime
  if not self.isFloward_ then
    speed = -speed
  end
  return speed
end

function qte_weapon_tdl:DestroyUI()
  if self.timerMgr ~= nil then
    self.timerMgr:Clear()
    self.timerMgr = nil
  end
  self:UnregisterEvent()
  self.view_:RemoveUiUnit(self.key_)
  Z.QteMgr.OnQteClosed(self.uuid_)
end

return qte_weapon_tdl
