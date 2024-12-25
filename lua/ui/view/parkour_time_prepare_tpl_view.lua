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
  self:onPlayAnim()
  self:SetData()
end

function Parkour_time_prepare_tplView:DeActive()
  self.timerMgr:Clear()
  self.timer = nil
  self:onCloseAnim()
end

function Parkour_time_prepare_tplView:CountDownFunc(timeNumber, startTime, timingDirection, addTime, addTimeUiType, limitTime, timeFinishFunc, timeCallFunc, timeLimitFunc, isShowZeroSecond)
  local detailTime = timeNumber
  if timeNumber <= 0 or not startTime then
    return
  end
  if isShowZeroSecond then
    detailTime = timeNumber - 1000
  end
  local realT = math.floor((detailTime - Z.ServerTime:GetServerTime()) / 1000)
  local showTimeString = realT
  if timingDirection == E.DungeonTimerDirection.DungeonTimerDirectionUp then
    showTimeString = math.floor((Z.ServerTime:GetServerTime() - startTime * 1000) / 1000)
  end
  self.lab_num_enter.TMPLab.text = Z.TimeTools.S2MSFormat(showTimeString)
  local isFirst = true
  if self.timer then
    self.isCalledFinsishFunc = true
    self.timer:Stop()
  end
  self:showAddTimeUI(addTime, addTimeUiType)
  self.isCalledFinsishFunc = false
  self.timer = self.timerMgr:StartTimer(function()
    local t = 0
    if timingDirection == E.DungeonTimerDirection.DungeonTimerDirectionUp then
      t = math.floor((Z.ServerTime:GetServerTime() - startTime * 1000) / 1000)
    else
      t = math.floor((detailTime - Z.ServerTime:GetServerTime()) / 1000)
    end
    self.lab_num_enter.TMPLab.text = Z.TimeTools.S2MSFormat(t)
    if limitTime ~= nil and t <= limitTime and isFirst then
      isFirst = false
      self:SetNodeColor(true)
      if timeLimitFunc then
        self.timeLimitFunc()
      end
    end
    if timeCallFunc then
      timeCallFunc()
    end
  end, 1, realT, true, function()
    if self.isCalledFinsishFunc == false then
      self.unit.Ref:SetVisible(false)
      self.isCalledFinsishFunc = true
    end
    if timeFinishFunc then
      timeFinishFunc()
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

return Parkour_time_prepare_tplView
