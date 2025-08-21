local UI = Z.UI
local super = require("ui.ui_subview_base")
local World_team_signView = class("World_team_signView", super)

function World_team_signView:ctor(parent)
  self.uiBinder = nil
  local assetPath = Z.IsPCUI and "worldboss/world_team_sign_pc" or "worldboss/world_team_sign"
  super.ctor(self, "world_team_sign", assetPath, UI.ECacheLv.None)
  self.matchTeamVm_ = Z.VMMgr.GetVM("match_team")
  self.matchVm_ = Z.VMMgr.GetVM("match")
end

function World_team_signView:OnActive()
  self:BindEvents()
  self:AddClick(self.uiBinder.btn_arrow, function()
    self.matchVm_.CancelMatchDialog()
  end)
end

function World_team_signView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Match.MatchStartTimeChange, self.refreshState, self)
end

function World_team_signView:OnDeActive()
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
end

function World_team_signView:OnRefresh()
  self:refreshState(self.viewData.matchType)
end

function World_team_signView:refreshState(matchType)
  local matchData_ = Z.DataMgr.Get("match_data")
  local matchTime = matchData_:GetMatchStartTime()
  if matchTime <= 0 then
    self:DeActive()
  else
    if matchType == E.MatchType.Activity then
      local matchActivityData_ = Z.DataMgr.Get("match_activity_data")
      local seasonActId = matchActivityData_:GetActivityId()
      local seasonActTableRow = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(seasonActId)
      local targetName = ""
      if seasonActTableRow then
        targetName = seasonActTableRow.Name
      end
      self.uiBinder.lab_name.text = targetName
    elseif matchType == E.MatchType.Team then
      local matchTeamData = Z.DataMgr.Get("match_team_data")
      local dungeonID = matchTeamData:GetCurMatchingDungeonId()
      local cfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonID)
      local targetName = ""
      if cfg then
        targetName = cfg.Name
      end
      self.uiBinder.lab_name.text = targetName
    end
    if self.timer_ then
      self.timerMgr:StopTimer(self.timer_)
      self.timer_ = nil
    end
    local time2 = (Z.TimeTools.Now() - matchTime) / 1000
    self.uiBinder.lab_time.text = Z.TimeFormatTools.FormatToDHMS(time2, true, true)
    self.timer_ = self.timerMgr:StartTimer(function()
      local time = (Z.TimeTools.Now() - matchTime) / 1000
      self.uiBinder.lab_time.text = Z.TimeFormatTools.FormatToDHMS(time, true, true)
    end, 1, -1)
  end
end

return World_team_signView
