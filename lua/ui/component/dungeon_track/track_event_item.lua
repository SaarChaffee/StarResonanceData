local TrackEventItem = class("TrackEventItem")
local trackTargetItem = require("ui.component.dungeon_track.track_target_item")
local UnitPath = "ui/prefabs/main/track/task_pace_main_tpl"
local UnitPathPC = "ui/prefabs/main/track/task_pace_main_tpl_pc"
local TimeSliderColor = {
  [1] = Color.New(0.8431372549019608, 0.30980392156862746, 0.30980392156862746, 1),
  [2] = Color.New(0.8627450980392157, 0.6392156862745098, 0.3333333333333333, 1),
  [3] = Color.New(0.5764705882352941, 0.6784313725490196, 0.16470588235294117, 1)
}
local TimeSliderImg = {
  [1] = "ui/atlas/hero_dungeon/hero_dungeon_slide_light03",
  [2] = "ui/atlas/hero_dungeon/hero_dungeon_slide_light02",
  [3] = "ui/atlas/hero_dungeon/hero_dungeon_slide_light01"
}
local TimeSliderColorState = {
  Red = 1,
  Yellow = 2,
  Green = 3
}

function TrackEventItem:ctor()
  self.trackEventVM_ = Z.VMMgr.GetVM("track_event")
  self.countDownTimeCfg_ = Z.Global.HeroChallengeEventCountdownColor
end

function TrackEventItem:Init(unit, parentView)
  self.unit_ = unit
  self.parentView_ = parentView
  self.targetItemDic_ = {}
  self.targetItemNameDic_ = {}
  self.eventLastTime_ = 0
  self.eventTimer_ = nil
  self.timerMgr_ = Z.TimerMgr.new()
  self.refreshTime_ = 0
  self.timeSliderColorState_ = nil
end

function TrackEventItem:SetData(eventData)
  self:ResetUnit()
  self.eventData_ = eventData
  local eventCfg = self.trackEventVM_.GetEventConfig(eventData.eventId)
  if not eventCfg then
    return
  end
  self:SetIcon(eventData)
  self:SetContent(eventCfg)
  self:SetTarget(eventData, eventCfg)
  self:SetCountDownTime(eventData, eventCfg)
end

function TrackEventItem:RefreshData(eventData)
  self.eventData_ = eventData
  if eventData.state == E.DungeonEventState.Running then
    self:RefreshTargets()
  elseif eventData.state == E.DungeonEventState.End then
    self:RefreshTargets()
    self:PlayResultAnim(eventData.result)
    self:ShowResultTips(eventData.result)
  end
  self:UpdateRefreshTime()
end

function TrackEventItem:RefreshTargets()
  for targetId, targetData in pairs(self.eventData_.dungeonTarget) do
    local targetItem = self.targetItemDic_[targetId]
    if targetItem then
      targetItem:RefreshData(targetData)
    end
  end
end

function TrackEventItem:PlayResultAnim(result)
  if result == E.DungeonEventResult.Success then
    local content = Lang("TrackEventSuccess", nil)
    self.unit_.lab_tips.text = Z.RichTextHelper.ApplyStyleTag(content, E.TextStyleTag.TipsGreen)
    self:WaitToRemoveEvent(2)
  elseif result == E.DungeonEventResult.End then
    Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.RemoveEvent, self.eventData_.eventId)
  elseif result == E.DungeonEventResult.TimeOut then
    if self:HasTargetComplete() then
      local content = Lang("TrackEventSuccess", nil)
      self.unit_.lab_tips.text = Z.RichTextHelper.ApplyStyleTag(content, E.TextStyleTag.TipsGreen)
      self:WaitToRemoveEvent(2)
    else
      local content = Lang("TrackEventFail", nil)
      self.unit_.lab_tips.text = Z.RichTextHelper.ApplyStyleTag(content, E.TextStyleTag.TipsRed)
      self:WaitToRemoveEvent(2)
    end
  elseif result == E.DungeonEventResult.NotPerfectnd then
    local content = Lang("TrackEventSuccess", nil)
    self.unit_.lab_tips.text = Z.RichTextHelper.ApplyStyleTag(content, E.TextStyleTag.TipsGreen)
    self:WaitToRemoveEvent(2)
  else
    local content = Lang("TrackEventFail", nil)
    self.unit_.lab_tips.text = Z.RichTextHelper.ApplyStyleTag(content, E.TextStyleTag.TipsRed)
    self:WaitToRemoveEvent(2)
  end
end

function TrackEventItem:ShowResultTips(result)
  if result == E.DungeonEventResult.Success then
    Z.TipsVM.ShowTipsLang(15001104)
  elseif result == E.DungeonEventResult.End then
    Z.TipsVM.ShowTipsLang(15001106)
  elseif result == E.DungeonEventResult.TimeOut then
    if self:HasTargetComplete() then
      Z.TipsVM.ShowTipsLang(15001107)
    else
      Z.TipsVM.ShowTipsLang(15001105)
    end
  elseif result == E.DungeonEventResult.NotPerfectnd then
    Z.TipsVM.ShowTipsLang(15001107)
  else
    Z.TipsVM.ShowTipsLang(15001105)
  end
end

function TrackEventItem:HasTargetComplete()
  if self.eventData_ then
    for targetId, targetData in pairs(self.eventData_.dungeonTarget) do
      if targetData.complete == 1 then
        return true
      end
    end
  end
  return false
end

function TrackEventItem:WaitToRemoveEvent(seconds)
  self.timerMgr_:StartTimer(function()
    Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.RemoveEvent, self.eventData_.eventId)
  end, seconds)
end

function TrackEventItem:SetIcon(eventData)
  if eventData.result == E.DungeonEventResult.Null then
    self.unit_.Ref:SetVisible(self.unit_.img_icon, true)
  elseif eventData.result == E.DungeonEventResult.Success then
    self.unit_.Ref:SetVisible(self.unit_.img_ok, true)
    local content = Lang("TrackEventSuccess", nil)
    self.unit_.lab_tips.text = content
  else
    self.unit_.Ref:SetVisible(self.unit_.img_not, true)
    local content = Lang("TrackEventFail", nil)
    self.unit_.lab_tips.text = content
  end
end

function TrackEventItem:SetContent(eventCfg)
  self.unit_.lab_task_content.text = eventCfg.Name
end

function TrackEventItem:SetTarget(eventData, eventCfg)
  local path = Z.IsPCUI and UnitPathPC or UnitPath
  for index, eventId in ipairs(eventCfg.TargetList) do
    local targetData = eventData.dungeonTarget[eventId]
    if targetData then
      local targetItem = trackTargetItem.new()
      local name = string.format("target_%s", targetData.targetId)
      local unit = self.parentView_:AsyncLoadUiUnit(path, name, self.unit_.layout_main)
      local customIcon = self.trackEventVM_.GetEventTargetIcon(eventData.eventId, targetData.targetId)
      targetItem:Init(unit, self.parentView_)
      targetItem:SetData(targetData, customIcon)
      self.targetItemDic_[targetData.targetId] = targetItem
      self.targetItemNameDic_[targetData.targetId] = name
    end
  end
end

function TrackEventItem:SetCountDownTime(eventData, eventCfg)
  if eventCfg.Time == 0 then
    self.unit_.group_slider.gameObject:SetActive(false)
    return
  end
  self.unit_.group_slider.gameObject:SetActive(true)
  local serverTime = Z.ServerTime:GetServerTime()
  self.eventLastTime_ = eventCfg.Time - (serverTime / 1000 - eventData.startTime)
  self.unit_.slider_task.maxValue = eventCfg.Time
  self:RefreshCountDownTime()
  self.eventTimer_ = self.timerMgr_:StartTimer(function()
    self:RefreshCountDownTime()
  end, 1, -1)
end

function TrackEventItem:RefreshCountDownTime()
  if self.eventLastTime_ >= 0 then
    self.unit_.slider_task.value = self.eventLastTime_
    self.unit_.lab_time.text = Z.TimeTools.S2HMSFormat(self.eventLastTime_)
    self.eventLastTime_ = self.eventLastTime_ - 1
    if #self.countDownTimeCfg_ == 2 then
      local percent = self.unit_.slider_task.value * 100 / self.unit_.slider_task.maxValue
      local newState
      if percent > self.countDownTimeCfg_[2] then
        newState = TimeSliderColorState.Green
      elseif percent > self.countDownTimeCfg_[1] then
        newState = TimeSliderColorState.Yellow
      else
        newState = TimeSliderColorState.Red
      end
      if newState ~= self.timeSliderColorState_ then
        self.timeSliderColorState_ = newState
        self.unit_.img_progress:SetColor(TimeSliderColor[newState])
        self.unit_.img_spot:SetImage(TimeSliderImg[newState])
      end
    end
  else
    self.unit_.slider_task.value = 0
    self.unit_.lab_time.text = Z.TimeTools.S2HMSFormat(0)
    self.parentView_.timerMgr.StopTimer(self.eventTimer_)
  end
end

function TrackEventItem:UpdateRefreshTime()
  self.refreshTime_ = Z.ServerTime:GetServerTime()
end

function TrackEventItem:ResetUnit()
  self.unit_.Ref:SetVisible(self.unit_.img_ok, false)
  self.unit_.Ref:SetVisible(self.unit_.img_not, false)
  self.unit_.Ref:SetVisible(self.unit_.img_icon, false)
  self.unit_.lab_tips.text = ""
  self.unit_.lab_task_content.text = ""
end

function TrackEventItem:ClearUiUnit()
  for id, name in pairs(self.targetItemNameDic_) do
    self.targetItemDic_[id]:UnInit()
    self.parentView_:RemoveUiUnit(name)
  end
  self.targetItemNameDic_ = nil
  self.targetItemDic_ = nil
end

function TrackEventItem:UnInit()
  if self.timerMgr_ then
    self.timerMgr_:Clear()
  end
  self.timerMgr_ = nil
  self:ClearUiUnit()
  self.unit_ = nil
  self.parentView_ = nil
  self.eventLastTime_ = 0
  self.timeSliderColorState_ = nil
end

return TrackEventItem
