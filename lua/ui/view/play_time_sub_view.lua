local UI = Z.UI
local super = require("ui.ui_subview_base")
local Play_time_subView = class("Play_time_subView", super)

function Play_time_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "play_time_sub", "recommendedplay/play_time_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "play_time_sub", "recommendedplay/play_time_sub", UI.ECacheLv.None)
  end
  self.recommendedPlayData_ = Z.DataMgr.Get("recommendedplay_data")
end

function Play_time_subView:OnActive()
  local config = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(self.viewData)
  if config == nil then
    return
  end
  self.uiBinder.lab_title.text = config.Name
  self.uiBinder.lab_info.text = config.OtherDes .. "\n" .. config.ActDes
  local timeId = Z.WorldBoss.WorldBossOpenTimerId
  local startTimeList, endTimeList = Z.TimeTools.GetCycleTimeDataByTimeId(timeId)
  local strTable = {}
  if startTimeList[1] then
    local str = string.format("%02d:%02d", startTimeList[1].hour, startTimeList[1].min)
    table.insert(strTable, str)
  end
  if endTimeList[1] then
    local str = string.format("%02d:%02d", endTimeList[1].hour, endTimeList[1].min)
    table.insert(strTable, str)
  end
  local timeStr = table.zconcat(strTable, "-")
  self.uiBinder.lab_todaytime.text = timeStr
  local serverTimeData = self.recommendedPlayData_:GetSreverData(config.Id)
  if serverTimeData == nil or serverTimeData.isOpen then
    self.uiBinder.Ref:SetVisible(self.uiBinder.layout_team, true)
    local leftTime = serverTimeData.endTimestamp - Z.TimeTools.Now() / 1000
    if 0 < leftTime then
      self.uiBinder.lab_lefttime.text = Z.TimeTools.FormatToDHMSStr(leftTime)
    end
    local today = Z.TimeTools.Tp2YMDHMS(math.floor(Z.TimeTools.Now() / 1000))
    if startTimeList[1] then
      local startDay = startTimeList[1]
      if today.year == startDay.year and today.month == startDay.month and today.day == startDay.day then
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, true)
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, false)
      end
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, false)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.layout_team, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, false)
  end
end

function Play_time_subView:OnDeActive()
end

function Play_time_subView:OnRefresh()
end

return Play_time_subView
