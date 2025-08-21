local qte_parkour_shadow_dash = class("qte_parkour_shadow_dash")
local QteInfo = require("ui.component.qte.qte_info")
local QteCreator = require("ui.component.qte.qte_creator")

function qte_parkour_shadow_dash:ctor(id, fighterview, uiBinder)
  self.timerMgr = Z.TimerMgr.new()
  self.Info_ = QteInfo.new(id)
  if self.Info_ == nil then
    logGreen("self.info is nil")
  end
  self.key_ = "qte_" .. id
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
  self.isTrigger_ = false
  self.factor_ = 1
  self.curPointerSpeed = Vector3.zero
  self.fillAmountList_ = {}
  self.isDestroy_ = false
  self.uiLenth = 430
  if Z.IsPCUI then
    self.uiLenth = 336
  end
  self:Load()
end

function qte_parkour_shadow_dash:registerEvent()
  Z.EventMgr:Add("OnQteTrigger", self.OnQteTrigger, self)
end

function qte_parkour_shadow_dash:UnregisterEvent()
  Z.EventMgr:RemoveObjAll(self)
end

function qte_parkour_shadow_dash:Load()
  local uipath = self.Info_.UIPath
  Z.CoroUtil.create_coro_xpcall(function()
    if not self.uiObj_ then
      self.uiObj_ = self.view_:AsyncLoadUiUnit(uipath, self.key_, self.uiBinder_.parkour_qte_pos)
      if not self.uiObj_ then
        QteCreator.OnQteClosed(self.uuid_)
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
        self:OnQteTrigger(self.qteId_)
      end
    end
  end)()
end

function qte_parkour_shadow_dash:start()
  self.uiObj_.progress.Ref:SetPosition(Vector2.New(0, 0))
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
  self:registerEvent()
end

function qte_parkour_shadow_dash:OnQteTrigger(qteId)
  if qteId == self.qteId_ or qteId == -1 then
    self.isTrigger_ = true
    if self.uiObj_ ~= nil then
      self.Info_:OnTrigger(self.curTime_)
      if self.isActive_ and self.Info_.isStop_ then
        self.isActive_ = false
        self.Info_:SyncRes()
        self:OnQteSucess()
        self.timerMgr:Clear()
        self.deathTimer = self.timerMgr:StartTimer(function()
          self:DestroyUI()
        end, 0.7)
      end
    end
  end
end

function qte_parkour_shadow_dash:OnQteSucess()
  if self.Info_.sucessful_ then
    for _, v in ipairs(self.Info_.qteSuccessIdxList_) do
      local eventParam
      if #self.Info_.qteRow.EventParams > 0 then
        eventParam = self.Info_.qteRow.EventParams[v + 1][1]
      end
      Z.EventMgr:Dispatch(Z.ConstValue.Parkour.QteDash, eventParam)
    end
  end
end

function qte_parkour_shadow_dash:onUpdate()
  self.curTime_ = self.curTime_ + self.TIME_INTERVEL
  local dx = self:PointerSpeed()
  local progressPos = self.uiObj_.progress.Ref:GetPosition()
  progressPos.x = progressPos.x + dx
  self.uiObj_.progress.Ref:SetPosition(progressPos)
end

function qte_parkour_shadow_dash:PointerSpeed()
  local maxTime = self.Info_.maxTime_
  local speed = self.uiLenth / maxTime * self.TIME_INTERVEL
  return speed
end

function qte_parkour_shadow_dash:DestroyUI()
  self.isDestroy_ = true
  if self.timerMgr ~= nil then
    self.timerMgr:Clear()
    self.timerMgr = nil
  end
  if self.uiObj_ then
    self.uiObj_.progress.ZEff:ReleseEffGo()
    self.uiObj_.effect_pos.ZEff:ReleseEffGo()
  end
  self:UnregisterEvent()
  self.view_:RemoveUiUnit(self.key_)
  QteCreator.OnQteClosed(self.uuid_)
end

return qte_parkour_shadow_dash
