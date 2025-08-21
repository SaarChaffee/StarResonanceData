local FishingMgr = {}

function FishingMgr:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingSuccess, self.fishingSuccess, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingRodBreak, self.fishingRodBreak, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishRunAway, self.fishRunAway, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingStateChange, self.setFishingStage, self)
  self.playerStateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
    local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
    if stateId ~= Z.PbEnum("EActorState", "ActorStateFishing") then
      self:CloseMgr()
      self.fishingVM_.QuitFishingUI()
    end
  end)
  self.cancelResourse = Z.CancelSource.Rent()
end

function FishingMgr:unBindEvent()
  Z.EventMgr:Remove(Z.ConstValue.Fishing.FishingSuccess, self.fishingSuccess, self)
  Z.EventMgr:Remove(Z.ConstValue.Fishing.FishingRodBreak, self.fishingRodBreak, self)
  Z.EventMgr:Remove(Z.ConstValue.Fishing.FishRunAway, self.fishRunAway, self)
  Z.EventMgr:Remove(Z.ConstValue.Fishing.FishingStateChange, self.setFishingStage, self)
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
end

function FishingMgr:CloseMgr()
  if self.isFishing_ then
    self:ClearTimer()
    self:unBindEvent()
    self.isFishing_ = false
    self.cancelResourse:Recycle()
  end
end

function FishingMgr:OpenMgr()
  if not self.isFishing_ then
    self.fishingData_ = Z.DataMgr.Get("fishing_data")
    self.fishingVM_ = Z.VMMgr.GetVM("fishing")
    self:ClearTimer()
    self:bindEvent()
    self.isFishing_ = true
  end
end

function FishingMgr:fishingSuccess()
  self.fishingVM_.FishingSuccess(self.cancelResourse:CreateToken())
  self:ClearTimer()
end

function FishingMgr:fishingRodBreak()
  self.fishingVM_.FishingRodBreak(self.cancelResourse:CreateToken())
  self:ClearTimer()
end

function FishingMgr:fishRunAway()
  self.fishingVM_.FishRunAway(self.cancelResourse:CreateToken())
  self:ClearTimer()
end

function FishingMgr:ClearTimer()
  Z.GlobalTimerMgr:StopTimer("fishingQTE")
  self.updateTimer_ = nil
end

function FishingMgr:setFishingStage()
  if self.fishingData_.FishingStage == E.FishingStage.QTE then
    self.fishingData_:ResetQTEData()
    Z.GlobalTimerMgr:StartTimer("fishingQTE", function()
      self.fishingVM_.FishingProcessUpdate()
    end, self.fishingData_.QTEData.UpdateRate, -1)
  else
    self:ClearTimer()
  end
  if self.fishingData_.FishingStage == E.FishingStage.Settlement then
    Z.UIMgr:OpenView("fishing_obtain_window")
  end
end

return FishingMgr
