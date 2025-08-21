local QuestLimitComp = class("QuestLimitComp")

function QuestLimitComp:ctor(parentView, funcDict)
  self.parent_ = parentView
  self.questVM_ = Z.VMMgr.GetVM("quest")
  if funcDict == nil then
    funcDict = {}
  end
  self.funcDict_ = funcDict
  self.limitConfigGroup_ = {}
  self.datetimers_ = {}
end

function QuestLimitComp:Init(questId, limitUIBinder)
  self:UnInit()
  self.questLimitVm_ = Z.VMMgr.GetVM("quest_limit")
  self.questTableRow_ = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId, true)
  if self.questTableRow_ == nil then
    return
  end
  self.timerMgr_ = Z.TimerMgr.new()
  self.questId_ = questId
  self.isActive_ = true
  self.uiBinder_ = limitUIBinder
  self.limitStates_ = {}
  self.limitConfigGroup_ = {}
  self.dateTimers_ = {}
  self.timerIdTypeTimers_ = {}
  self.limitConfigGroup_ = self.questLimitVm_.ParseLimitConfig(self.questTableRow_)
  self:checkItemCount()
  self:checkDateTime()
  self:checkRoleLv()
  self:checkQuestStep()
  self:checkTimer()
  self:bindEvents()
  self:refreshLimitUI()
end

function QuestLimitComp:UnInit()
  Z.EventMgr:RemoveObjAll(self)
  self.questId_ = nil
  self.limitStates_ = {}
  self.limitConfigGroup_ = {}
  self.isActive_ = false
  if self.timerMgr_ then
    self.timerMgr_:Clear()
  end
  self.timerMgr_ = nil
  self.dateTimers_ = {}
  self.timerIdTypeTimers_ = {}
end

function QuestLimitComp:stopAllDateTimer()
  if not self.timerMgr_ then
    return
  end
  for i = 1, #self.dateTimers_ do
    self.timerMgr_:StopTimer(self.dateTimers_[i])
  end
  self.dateTimers_ = {}
end

function QuestLimitComp:stopAllTimerIdTypeTimer()
  if not self.timerMgr_ then
    return
  end
  for i = 1, #self.timerIdTypeTimers_ do
    self.timerMgr_:StopTimer(self.timerIdTypeTimers_[i])
  end
  self.timerIdTypeTimers_ = {}
end

function QuestLimitComp:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onOwnItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onOwnItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onOwnItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.RoleLevelUp, self.onRoleLevelChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.StepFinish, self.onStepFinish, self)
end

function QuestLimitComp:checkItemCount()
  if not self.isActive_ then
    return
  end
  local countLimit = self.limitConfigGroup_[E.EQuestLimitType.ItemCount]
  self.limitStates_[E.EQuestLimitType.ItemCount] = self.questLimitVm_.CheckItemCount(countLimit)
end

function QuestLimitComp:checkDateTime()
  local dateLimit = self.limitConfigGroup_[E.EQuestLimitType.Date]
  self.limitStates_[E.EQuestLimitType.Date] = self.questLimitVm_.CheckDateTime(dateLimit)
end

function QuestLimitComp:checkRoleLv()
  local roleLimit = self.limitConfigGroup_[E.EQuestLimitType.RoleLv]
  self.limitStates_[E.EQuestLimitType.RoleLv] = self.questLimitVm_.CheckRoleLv(roleLimit)
end

function QuestLimitComp:checkQuestStep()
  local questStepLimit = self.limitConfigGroup_[E.EQuestLimitType.QuestStep]
  self.limitStates_[E.EQuestLimitType.QuestStep] = self.questLimitVm_.CheckQuestStep(questStepLimit)
end

function QuestLimitComp:checkTimer()
  local timeLimit = self.limitConfigGroup_[E.EQuestLimitType.Timer]
  self.limitStates_[E.EQuestLimitType.Timer] = self.questLimitVm_.CheckTimer(timeLimit)
end

function QuestLimitComp:refreshLimitUI()
  self:refreshItemCountUI()
  self:refreshDateUI()
  self:refreshRoleLvUI()
  self:refreshQuestStepUI()
  self:refrehsTimerUI()
  self:refrehsUIVisible()
end

function QuestLimitComp:onOwnItemCountChange(item)
  self:checkItemCount()
  self:refreshItemCountUI()
  self:refrehsUIVisible()
end

function QuestLimitComp:onRoleLevelChange()
  self:checkRoleLv()
  self:refreshRoleLvUI()
  self:refrehsUIVisible()
end

function QuestLimitComp:onStepFinish()
  self:checkQuestStep()
  self:refreshQuestStepUI()
  self:refrehsUIVisible()
end

function QuestLimitComp:refrehsUIVisible()
  local isVisible = false
  for _, stateInfos in pairs(self.limitStates_) do
    if stateInfos ~= nil then
      for _, info in pairs(stateInfos) do
        local state = info.state
        if state == E.QuestLimitState.NotMet then
          isVisible = true
          break
        end
      end
    end
  end
  if self.uiBinder_ ~= nil then
    self.uiBinder_.Ref.UIComp:SetVisible(isVisible)
    local layout_rebuilder = self.uiBinder_.layout_rebuilder
    if layout_rebuilder then
      layout_rebuilder:MarkLayoutForRebuild()
    end
  end
end

function QuestLimitComp:refreshItemCountUI()
  local itemCountLimitStateInfo = self.limitStates_[E.EQuestLimitType.ItemCount]
  if itemCountLimitStateInfo == nil or #itemCountLimitStateInfo < 1 then
    return
  end
  for i = 1, #itemCountLimitStateInfo do
    local params = itemCountLimitStateInfo[i].params
    local state = itemCountLimitStateInfo[i].state
    if state == E.QuestLimitState.NotMet then
      local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(params[1])
      if itemRow then
        local itemName = itemRow.Name
        local minNum = tonumber(params[2])
        local param = {
          item = {name = itemName, num = minNum}
        }
        if self.uiBinder_ and self.uiBinder_.lab_special_explain then
          self.uiBinder_.lab_special_explain.text = Lang("QuestItemLimit", param)
        end
      end
    end
  end
end

function QuestLimitComp:refreshDateUI()
  local dateLimitStateInfo = self.limitStates_[E.EQuestLimitType.Date]
  if dateLimitStateInfo == nil or #dateLimitStateInfo < 1 then
    return
  end
  self:stopAllDateTimer()
  for i = 1, #dateLimitStateInfo do
    local params = dateLimitStateInfo[i].params
    local state = dateLimitStateInfo[i].state
    local func = self.funcDict_[E.EQuestLimitType.Date]
    if func then
      func(state)
    end
    if state == E.QuestLimitState.NotMet then
      local dateSce = params[1]
      local timer = self.timerMgr_:StartTimer(function()
        dateSce = dateSce - 1
        if dateSce <= 0 then
          self:checkDateTime()
          self:refreshDateUI()
          self:refreshLimitUI()
          return
        end
        if self.uiBinder_ and self.uiBinder_.lab_special_explain then
          self.uiBinder_.lab_special_explain.text = self:getDateLimitStr(dateSce)
        end
      end, 1, -1, true)
      table.insert(self.dateTimers_, timer)
      if self.uiBinder_ and self.uiBinder_.lab_special_explain then
        self.uiBinder_.lab_special_explain.text = self:getDateLimitStr(dateSce)
      end
    end
  end
end

function QuestLimitComp:getDateLimitStr(dateSce)
  local str = Z.TimeFormatTools.FormatToDHMS(dateSce)
  return Lang("remainderLimit", {str = str})
end

function QuestLimitComp:refreshRoleLvUI()
  local roleLvLimitStateInfo = self.limitStates_[E.EQuestLimitType.RoleLv]
  if roleLvLimitStateInfo == nil or #roleLvLimitStateInfo < 1 then
    return
  end
  for i = 1, #roleLvLimitStateInfo do
    local params = roleLvLimitStateInfo[i].params
    local state = roleLvLimitStateInfo[i].state
    if state == E.QuestLimitState.NotMet and self.uiBinder_ and self.uiBinder_.lab_special_explain then
      self.uiBinder_.lab_special_explain.text = Lang("NeedRoleLevel", {
        lv = params[1]
      })
    end
  end
end

function QuestLimitComp:refreshQuestStepUI()
  local questStepLimitStateInfo = self.limitStates_[E.EQuestLimitType.QuestStep]
  if questStepLimitStateInfo == nil or #questStepLimitStateInfo < 1 then
    return
  end
  for i = 1, #questStepLimitStateInfo do
    local params = questStepLimitStateInfo[i].params
    local state = questStepLimitStateInfo[i].state
    if state == E.QuestLimitState.NotMet then
      local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(params[1])
      if questRow and self.uiBinder_ and self.uiBinder_.lab_special_explain then
        self.uiBinder_.lab_special_explain.text = Lang("NeedAdvanceTaskStart", {
          str = questRow.QuestName
        })
      end
    end
  end
end

function QuestLimitComp:refrehsTimerUI()
  local timerLimitStateInfo = self.limitStates_[E.EQuestLimitType.Timer]
  if not timerLimitStateInfo or #timerLimitStateInfo < 1 then
    return
  end
  self:stopAllDateTimer()
  local serverTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local lab = self.uiBinder_ and self.uiBinder_.lab_special_explain
  for _, stateInfo in ipairs(timerLimitStateInfo) do
    if stateInfo.state == E.QuestLimitState.NotMet then
      local params = stateInfo.params
      local startTime, endTime, hasend = params.startTime, params.endTime, params.hasend
      local content = Lang("NotInTimeRange")
      if self.funcDict_[E.EQuestLimitType.Timer] then
        self.funcDict_[E.EQuestLimitType.Timer](stateInfo.state)
      end
      local timer
      if serverTime < startTime then
        timer, content = self:createCountdownTimer(math.floor(startTime - serverTime), "remainderLimit", function()
          self:onTimerCompleted()
        end)
      elseif hasend and serverTime < endTime then
        timer, content = self:createCountdownTimer(math.floor(endTime - serverTime), "EndingTimeRemaining", function()
          self:onTimerCompleted()
        end)
      end
      if timer then
        table.insert(self.timerIdTypeTimers_, timer)
      end
      if lab then
        lab.text = content
      end
    end
  end
end

function QuestLimitComp:createCountdownTimer(countdownSec, langKey, onComplete)
  local lab = self.uiBinder_ and self.uiBinder_.lab_special_explain
  local content = Lang(langKey, {
    str = Z.TimeFormatTools.FormatToDHMS(countdownSec)
  })
  if lab then
    lab.text = content
  end
  local timer = self.timerMgr_:StartTimer(function()
    countdownSec = countdownSec - 1
    if countdownSec <= 0 then
      if onComplete then
        onComplete()
      end
      return
    end
    if lab then
      lab.text = Lang(langKey, {
        str = Z.TimeFormatTools.FormatToDHMS(countdownSec)
      })
    end
  end, 1, -1, true)
  return timer, content
end

function QuestLimitComp:onTimerCompleted()
  self:checkTimer()
  self:refrehsTimerUI()
  self:refreshLimitUI()
end

return QuestLimitComp
