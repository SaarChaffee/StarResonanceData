local Parkour_time_prepare_tplView = class("Parkour_time_prepare_tplView")

function Parkour_time_prepare_tplView:ctor()
end

function Parkour_time_prepare_tplView:Init(go, name)
  self.name = name
  self.unit = UICompBindLua(go)
  self.unit.Ref:SetOffSetMin(0, 0)
  self.unit.Ref:SetOffSetMax(0, 0)
  self.unit.Ref:SetVisible(true)
  self.lab_num_enter = self.unit.lab_num_enter
  self.lab_matching = self.unit.lab_matching.TMPLab
  self.img_green = self.unit.img_green
  self.img_red = self.unit.img_red
  self.add_time_label_arr = self.unit.lab_num
  self.img_red:SetVisible(false)
  self.img_green:SetVisible(false)
  self.timerMgr = Z.TimerMgr.new()
  self.realTime_ = 0
  self:onPlayAnim()
  self:SetData()
end

function Parkour_time_prepare_tplView:DeActive()
  self.timerMgr:Clear()
  self.timer = nil
  self:onCloseAnim()
end

function Parkour_time_prepare_tplView:CountDownFunc(timeInfo)
  local endTime = timeInfo.timeNumber
  if timeInfo.timeNumber <= 0 or not timeInfo.startTime then
    return
  end
  if timeInfo.isShowZeroSecond then
    endTime = timeInfo.timeNumber - 1000
  end
  self:clearTimer()
  self.realTime_ = math.floor((endTime - Z.ServerTime:GetServerTime()) / 1000)
  local showTimeString = self.realTime_
  if timeInfo.timingDirection == E.DungeonTimerDirection.DungeonTimerDirectionUp then
    showTimeString = math.floor((Z.ServerTime:GetServerTime() - timeInfo.startTime * 1000) / 1000)
  end
  local time = Z.TimeFormatTools.FormatToDHMS(showTimeString, true, true)
  if timeInfo.outLookType == E.DungeonTimerTimerLookType.EDungeonTimerTimerLookTypeRed then
    time = Z.RichTextHelper.ApplyStyleTag(time, E.TextStyleTag.TipsRed)
  end
  self.lab_num_enter.TMPLab.text = time
  local isFirst = true
  if 0 < timeInfo.pauseTime then
    return
  end
  self:showAddTimeUI(timeInfo.addTime, timeInfo.addTimeUiType)
  self.isCalledFinsishFunc = false
  local t = self.realTime_
  self.timer = self.timerMgr:StartTimer(function()
    if timeInfo.timingDirection == E.DungeonTimerDirection.DungeonTimerDirectionUp then
      t = t + 1
    else
      t = t - 1
    end
    if t < 0 then
      t = 0
    end
    local curTime = Z.TimeFormatTools.FormatToDHMS(t, true, true)
    if timeInfo.outLookType == E.DungeonTimerTimerLookType.EDungeonTimerTimerLookTypeRed then
      curTime = Z.RichTextHelper.ApplyStyleTag(curTime, E.TextStyleTag.TipsRed)
    end
    self.lab_num_enter.TMPLab.text = curTime
    if timeInfo.limitTime ~= nil and t <= timeInfo.limitTime and isFirst then
      isFirst = false
      if timeInfo.timeLimitFunc then
        timeInfo.timeLimitFunc()
      end
    end
    if timeInfo.timeCallFunc then
      timeInfo.timeCallFunc()
    end
  end, 1, self.realTime_, true, function()
    if self.isCalledFinsishFunc == false then
      self.unit.Ref:SetVisible(false)
      self.isCalledFinsishFunc = true
    end
    if timeInfo.timeFinishFunc then
      timeInfo.timeFinishFunc()
    end
  end)
end

function Parkour_time_prepare_tplView:showAddTimeUI(addTime, showUiType)
  if addTime and addTime ~= 0 then
    local addTimeZWidget, addTimeLabel
    if showUiType == E.DungeonTimerEffectType.EDungeonTimerEffectTypeAdd then
      addTimeZWidget = self.img_red
      addTimeLabel = self.add_time_label_arr[2].TMPLab
    elseif showUiType == E.DungeonTimerEffectType.EDungeonTimerEffectTypeSub then
      addTimeZWidget = self.img_green
      addTimeLabel = self.add_time_label_arr[1].TMPLab
    end
    if not addTimeZWidget or not addTimeLabel then
      return
    end
    addTimeZWidget:SetVisible(true)
    addTimeLabel.text = addTime
    self.timerMgr:StartTimer(function()
      addTimeZWidget:SetVisible(false)
    end, 2)
  end
end

function Parkour_time_prepare_tplView:SetData()
  self.lab_matching.text = Lang("WorldEvent_prepareText")
end

function Parkour_time_prepare_tplView:onPlayAnim()
  self.unit.img_frame.TweenContainer:Rewind(Z.DOTweenAnimType.Open)
  self.unit.img_frame.TweenContainer:Restart(Z.DOTweenAnimType.Open)
end

function Parkour_time_prepare_tplView:onCloseAnim()
  self.unit.img_frame.TweenContainer:Rewind(Z.DOTweenAnimType.Close)
  self.unit.img_frame.TweenContainer:Restart(Z.DOTweenAnimType.Close)
end

function Parkour_time_prepare_tplView:clearTimer()
  if self.timer then
    self.isCalledFinsishFunc = true
    self.timer:Stop()
  end
  self.realTime_ = 0
end

return Parkour_time_prepare_tplView
