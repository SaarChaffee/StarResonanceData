local UI = Z.UI
local super = require("ui.ui_view_base")
local Common_matchingView = class("Common_matchingView", super)

function Common_matchingView:ctor()
  self.uiBinder = nil
  super.ctor(self, "common_matching")
  self.matchActivityData_ = Z.DataMgr.Get("match_activity_data")
  self.matchData_ = Z.DataMgr.Get("match_data")
  self.matchVm_ = Z.VMMgr.GetVM("match")
end

function Common_matchingView:OnActive()
  self:setActivityViewInfo()
  self:refreshMemberCount()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initBinders()
  self:BindEvents()
end

function Common_matchingView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.uiBinder.btn_reject.IsDisabled = false
  Z.EventMgr:Remove(Z.ConstValue.Match.MatchPlayerInfoChange, self.refreshMemberCount, self)
end

function Common_matchingView:OnRefresh()
end

function Common_matchingView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Match.MatchPlayerInfoChange, self.refreshMemberCount, self)
end

function Common_matchingView:initBinders()
  self:AddAsyncClick(self.uiBinder.btn_accept, function()
    if self.hasSelect ~= true then
      self.matchVm_.AsyncMatchReady(true)
      self.hasSelect = true
      self.uiBinder.btn_accept.IsDisabled = true
      self.uiBinder.btn_reject.IsDisabled = true
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_reject, function()
    self.matchVm_.AsyncMatchReady(false)
  end)
  self.uiBinder.btn_accept.IsDisabled = false
end

function Common_matchingView:refreshPropress()
  self.uiBinder.img_top.fillAmount = 1
  if self.timer_ == nil then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  self.timer_ = self.timerMgr:StartTimer(function()
    self.checkTime_ = self.checkTime_ - 0.1
    if self.checkTime_ >= 0 and 0 < self.maxCheckTime_ then
      local num = self.checkTime_ / self.maxCheckTime_
      self.uiBinder.img_top.fillAmount = num
    end
  end, 0.1, -1)
end

function Common_matchingView:setActivityViewInfo()
  local seasonActId = self.matchActivityData_:GetActivityId()
  local seasonActTableRow = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(seasonActId)
  if not seasonActTableRow then
    return
  end
  local matchActTableRow = Z.TableMgr.GetTable("MatchActTableMgr").GetRow(seasonActTableRow.Id)
  if matchActTableRow then
    self.uiBinder.rimg_bg:SetImage(matchActTableRow.MatchPic)
  end
  self.uiBinder.lab_title.text = seasonActTableRow.Name
  local matchTableRow = Z.TableMgr.GetTable("MatchTableMgr").GetRow(matchActTableRow.MatchId)
  local lastTime = matchTableRow.ConfirmTime
  self.checkTime_ = lastTime
  self.maxCheckTime_ = lastTime
  self:refreshPropress()
end

function Common_matchingView:refreshMemberCount()
  local count = self.matchData_:GetReadyMemberCount()
  local matchStates = self.matchData_:GetMatchPlayerInfo()
  if matchStates == nil then
    self.uiBinder.lab_member.text = ""
    logError("matchStates is nil")
    return
  end
  local totalCouont = table.zcount(matchStates)
  self.uiBinder.lab_member.text = count .. "/" .. totalCouont
end

return Common_matchingView
