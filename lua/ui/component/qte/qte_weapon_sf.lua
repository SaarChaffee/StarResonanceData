local qte_weapon_sf = class("qte_weapon_sf")
local QteInfo = require("ui.component.qte.qte_info")

function qte_weapon_sf:ctor(id, fighterview, panel)
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
  self.isTrigger_ = false
  self.curPointerSpeed = Vector3.zero
  self:Load()
  self:registerEvent()
end

function qte_weapon_sf:registerEvent()
  Z.EventMgr:Add(Z.ConstValue.UIHide, self.onUIViewHide, self)
end

function qte_weapon_sf:onUIViewHide(viewConfigKey, visible)
  if viewConfigKey == self.panel_.viewConfigKey then
    self.uiObj_.bg.ZEff:SetEffectGoVisible(visible)
  end
end

function qte_weapon_sf:UnregisterEvent()
  Z.EventMgr:RemoveObjAll(self)
end

function qte_weapon_sf:Load()
  local uipath = self.Info_.UIPath
  Z.CoroUtil.create_coro_xpcall(function()
    self.cancelSource = Z.CancelSource.Rent()
    local cancelSource = self.cancelSource:CreateToken()
    if not self.uiObj_ then
      self.uiObj_ = self.view_:AsyncLoadUiUnit(uipath, self.key_, self.panel_.sf_qte_pos.Trans)
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

function qte_weapon_sf:start()
  self.uiObj_.successEffect.Go:SetActive(false)
  self.uiObj_.touchArea.EventTrigger.onDown:AddListener(function()
    self.Info_:OnTrigger(self.curTime_)
    if self.Info_.isStop_ then
      self.uiObj_.successEffect.Go:SetActive(true)
      self.Info_:SyncRes()
      self:DestroyUI()
    end
  end)
  self.timer = self.timerMgr:StartTimer(function()
    self:onUpdate()
  end, self.TIME_INTERVEL, self.Info_.maxTime_ / self.TIME_INTERVEL)
  self.destoryTimer = self.timerMgr:StartTimer(function()
    self.Info_:SyncRes()
    self:DestroyUI()
  end, self.Info_.maxTime_ + 0.02)
  self.uiObj_.bg.ZEff:CreatEFFGO("ui/uieffect/prefab/ui_sfx_shuangfu_qte_001", Vector3.zero)
end

function qte_weapon_sf:onUpdate()
  local row = Z.TableMgr.GetTable("QteTableMgr").GetRow(self.qteId_)
  if row == nil then
    return
  end
  self.curTime_ = self.curTime_ + self.TIME_INTERVEL
  local idx = self:GetCurStage(row, self.curTime_)
  if idx ~= 0 and self.curIndex ~= idx then
    self.curIndex = idx
    self:RefreshUI(idx)
    self.curPointerSpeed.z = self:PointerSpeed(idx)
  end
  if not self.isVisible_ then
    self.uiObj_.Ref:SetVisible(true)
    self.isVisible_ = true
  end
  self.uiObj_.pointer.Trans:Rotate(self.curPointerSpeed)
end

function qte_weapon_sf:RefreshUI(idx)
  local maxTime = self.Info_.qteAreaList[idx].maxTime
  local startTime = self.Info_.qteAreaList[idx].startTime
  local endTime = self.Info_.qteAreaList[idx].endTime
  local effectiveTime = endTime - startTime
  self.uiObj_.progress.Img.fillAmount = effectiveTime / maxTime
  local rot = -360 * (startTime / maxTime)
  local vec3 = Vector3.zero
  vec3.z = rot
  self.uiObj_.progress.Trans:Rotate(vec3)
end

function qte_weapon_sf:PointerSpeed(idx)
  local maxTime = self.Info_.qteAreaList[idx].maxTime
  local speed = self.TIME_INTERVEL / maxTime * 360
  return speed
end

function qte_weapon_sf:GetCurStage(row, time)
  for k, v in ipairs(row.timeQuantum) do
    local tbegin = v[1]
    local tend = v[2]
    if time <= tend and time > tbegin then
      return k
    end
  end
  return 0
end

function qte_weapon_sf:DestroyUI()
  if self.timerMgr ~= nil then
    self.timerMgr:Clear()
    self.timerMgr = nil
  end
  self.uiObj_.bg.ZEff:ReleseEffGo()
  self.view_:RemoveUiUnit(self.key_)
  self:UnregisterEvent()
  Z.QteMgr.OnQteClosed(self.uuid_)
end

return qte_weapon_sf
