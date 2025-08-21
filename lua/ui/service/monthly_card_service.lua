local super = require("ui.service.service_base")
local MonthlyCardService = class("MonthlyCardService", super)

function MonthlyCardService:OnInit()
end

function MonthlyCardService:OnUnInit()
end

function MonthlyCardService:OnLogin()
  self:bindWatcher()
  
  function self.monthlyGuideTimer_(state, offsetIndex)
    self:monthlyGuideTimer()
  end
  
  if self.timerRegistered == nil or self.timerRegistered == false then
    local timerId = self:getTimerId()
    if timerId == nil then
      return
    end
    Z.DIServiceMgr.ZCfgTimerService:RegisterTimerAction(timerId, self.monthlyGuideTimer_)
    self.timerRegistered = true
  end
  self:refreshRedPoint()
end

function MonthlyCardService:bindWatcher()
  local monthlyRewardCardData = Z.DataMgr.Get("monthly_reward_card_data")
  
  function self.monthlyCardDataUpdate_(container, dirtys)
    self:showPrivilegesTips(dirtys)
    if dirtys and dirtys.tipsClicked then
      monthlyRewardCardData.IsOpenedTipsCardView = false
    end
  end
  
  function self.counterListChange_(container, dirtys)
    self:onCounterListChange(dirtys)
  end
  
  Z.ContainerMgr.CharSerialize.monthlyCard.Watcher:RegWatcher(self.monthlyCardDataUpdate_)
  Z.ContainerMgr.CharSerialize.counterList.Watcher:RegWatcher(self.counterListChange_)
end

function MonthlyCardService:unbindWatcher()
  Z.ContainerMgr.CharSerialize.monthlyCard.Watcher:UnregWatcher(self.monthlyCardDataUpdate_)
  Z.ContainerMgr.CharSerialize.counterList.Watcher:UnregWatcher(self.counterListChange_)
  self.monthlyCardDataUpdate_ = nil
  self.counterListChange_ = nil
end

function MonthlyCardService:showPrivilegesTips(dirtys)
  if not dirtys then
    return
  end
  if dirtys and dirtys.monthlyCardInfo then
    local monthlyCardVM = Z.VMMgr.GetVM("monthly_reward_card")
    local curKey = monthlyCardVM:GetActiveMonthlyCardKey()
    for k, v in pairs(dirtys.monthlyCardInfo) do
      if v:IsNew() and k >= curKey then
        Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.Activities, "monthly_reward_card_privilege_window")
        break
      end
    end
  end
end

function MonthlyCardService:onCounterListChange(dirtys)
  if not dirtys then
    return
  end
  self:refreshRedPoint()
end

function MonthlyCardService:getTimerId()
  local counterTableMgr = Z.TableMgr.GetTable("CounterTableMgr")
  local counterId = Z.Global.MonthCardAwardCount
  local counterCfgData = counterTableMgr.GetRow(counterId)
  if counterCfgData then
    return counterCfgData.TimeTableId
  end
  return
end

function MonthlyCardService:monthlyGuideTimer()
  self:refreshRedPoint()
  Z.EventMgr:Dispatch(Z.ConstValue.MonthlyCard.RefreshGuideGift)
end

function MonthlyCardService:refreshRedPoint()
  local counterTableMgr = Z.TableMgr.GetTable("CounterTableMgr")
  local counterId = Z.Global.MonthCardAwardCount
  local counterCfgData = counterTableMgr.GetRow(counterId)
  local normalAwardCount = 0
  local nowAwardCount = 0
  local maxLimitNum = 0
  if counterCfgData then
    maxLimitNum = counterCfgData.Limit
    if Z.ContainerMgr.CharSerialize.counterList.counterMap[counterId] then
      nowAwardCount = Z.ContainerMgr.CharSerialize.counterList.counterMap[counterId].counter
    end
  end
  normalAwardCount = maxLimitNum - nowAwardCount
  local hasGift = 0 < normalAwardCount
  Z.RedPointMgr.UpdateNodeCount(E.RedType.MonthlyCardGift, hasGift and 1 or 0)
end

function MonthlyCardService:OnLogout()
  self:unbindWatcher()
  if self.timerRegistered ~= nil and self.timerRegistered == true then
    Z.DIServiceMgr.ZCfgTimerService:UnRegisterTimerAction(220, self.worldBossTimer_)
    self.timerRegistered = false
  end
  self.monthlyGuideTimer_ = nil
end

function MonthlyCardService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    self:refreshRedPoint()
  end
end

function MonthlyCardService:OnLeaveScene()
end

return MonthlyCardService
