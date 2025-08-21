local UnionWardanceCountDown = class("UnionWardanceCountDown")
local danceActivityMgr_ = Z.TableMgr.GetTable("DanceActivityMgr")

function UnionWardanceCountDown:ctor(parentView)
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionWarDanceData_ = Z.DataMgr.Get("union_wardance_data")
  self.timerMgr = Z.TimerMgr.new()
  self.unionWarDanceVM_ = Z.VMMgr.GetVM("union_wardance")
  self.parentView_ = parentView
end

function UnionWardanceCountDown:Init(uiBinder)
  self.inited = true
  self.cancelSource = Z.CancelSource.Rent()
  self.uiBinder = uiBinder
  self.progressNodes_ = {
    self.uiBinder.node_item_01,
    self.uiBinder.node_item_02,
    self.uiBinder.node_item_03
  }
  self.progressBGs_ = {
    self.uiBinder.node_item_bg_01,
    self.uiBinder.node_item_bg_02,
    self.uiBinder.node_item_bg_03
  }
  self.progressBuffBtns_ = {
    self.uiBinder.buffbtn1,
    self.uiBinder.buffbtn2,
    self.uiBinder.buffbtn3
  }
  self.progressBuffTipsTrans = {
    self.uiBinder.buff_tips_trans1,
    self.uiBinder.buff_tips_trans2,
    self.uiBinder.buff_tips_trans3
  }
  self.hasRemain = true
  self.tipsBoxShowPopupVM = Z.VMMgr.GetVM("tips_box_show_popup")
  self.seasonVM_ = Z.VMMgr.GetVM("season")
  local seasonID = self.seasonVM_.GetCurrentSeasonId()
  self.danceActivityTableRow = self.unionWarDanceData_:GetConfigDataBySeasonID(seasonID)
  if not self.danceActivityTableRow then
    return
  end
  self:initProgressNodePos()
  self:refresh()
  self:registerEvent()
  self:bindEvent()
  if not self.timer then
    self:startTimer()
  end
end

function UnionWardanceCountDown:UnInit()
  self.inited = false
  self:unRegisterEvent()
  self:stopTime()
  self.cancelSource:Recycle()
  self.uiBinder = nil
end

function UnionWardanceCountDown:bindEvent()
  self.uiBinder.btn_ask:AddListener(function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(500200)
  end)
  self.uiBinder.btn_ask_time:AddListener(function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(500200)
  end)
  for i = 1, #self.progressBuffBtns_ do
    self.progressBuffBtns_[i]:AddListener(function()
      if not self.danceActivityTableRow then
        return
      end
      if i > #self.danceActivityTableRow.BuffID or i > #self.danceActivityTableRow.BuffLevel then
        return
      end
      local buffID = self.danceActivityTableRow.BuffID[i]
      local buffGained = self.progress * 100 >= self.danceActivityTableRow.BuffLevel[i]
      local buffTab = Z.TableMgr.GetTable("BuffTableMgr").GetRow(buffID)
      local info = {}
      info.showTitle = buffGained and Lang("WarDanceBuffGainedTitle", {
        val = buffTab.Name
      }) or Lang("WarDanceBuffNotGainedTitle", {
        val = buffTab.Name
      })
      info.showContent = buffTab.Desc
      info.parentTrans = self.progressBuffTipsTrans[i].transform
      self.tipsBoxShowPopupVM.ShowTips(info)
    end)
  end
  self.parentView_:AddAsyncClick(self.uiBinder.btn_gift, function()
    local danceInfo = self.unionWarDanceData_:GetDancedInfo()
    if danceInfo == nil then
      self:showPreviewAward()
    elseif danceInfo.hasSend then
      self:showPreviewAward()
    elseif self.canReceive then
      self.unionWarDanceVM_:AsyncGetPersonalReward(self.cancelSource:CreateToken())
    else
      Z.TipsVM.ShowTipsLang(1005007)
      self:showPreviewAward()
    end
  end)
end

function UnionWardanceCountDown:showPreviewAward()
  local info = {}
  info.showTitle = Lang("RewardPreview")
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  info.itemList = awardPreviewVm.GetAllAwardPreListByIds(self.danceActivityTableRow.AwardId)
  info.parentTrans = self.uiBinder.reward_tips_trans.transform
  self.tipsBoxShowPopupVM.ShowTips(info)
end

function UnionWardanceCountDown:registerEvent()
  Z.EventMgr:RemoveObjAll(self)
  Z.EventMgr:Add(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceMemberCnt, self.changeMemberCnt, self)
  Z.EventMgr:Add(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceTotalTime, self.changeTotalTime, self)
  Z.EventMgr:Add(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceSelfTotalTime, self.changeSelfTotalTime, self)
  Z.EventMgr:Add(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceSelfRewardSended, self.changeSelfRewardSended, self)
  Z.EventMgr:Add(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceSelfActivityStart, self.refresh, self)
end

function UnionWardanceCountDown:unRegisterEvent()
  Z.EventMgr:RemoveObjAll(self)
end

function UnionWardanceCountDown:changeMemberCnt(memberCount)
  self.uiBinder.lab_people.text = Lang("UnionWarDanceTotalPeople", {val = memberCount})
end

function UnionWardanceCountDown:changeTotalTime(totalTime)
  self:refreshProgress(totalTime)
end

function UnionWardanceCountDown:changeSelfTotalTime(selfDancedTime)
  self.selfDancedTime_ = selfDancedTime
  if not self.danceActivityTableRow then
    return
  end
  if not self.hasRemain then
    return
  end
  local totalTime = self.danceActivityTableRow.SoloSpeed
  local remainTime = totalTime - self.selfDancedTime_
  if remainTime < 0 and self.hasRemain then
    self.hasRemain = false
    local danceInfo = self.unionWarDanceData_:GetDancedInfo()
    self:changeSelfRewardSended(danceInfo.hasSend)
    self.uiBinder.img_ing.fillAmount = 1
  elseif 0 <= remainTime then
    self.uiBinder.lab_personal_time.text = Lang("UnionWardancePersonalTimer", {val = remainTime})
    self.uiBinder.img_ing.fillAmount = totalTime == 0 and 1 or self.selfDancedTime_ / totalTime
  end
end

function UnionWardanceCountDown:changeSelfRewardSended(hasSend)
  local totalTime = self.danceActivityTableRow.SoloSpeed
  local danceInfo = self.unionWarDanceData_:GetDancedInfo()
  self.canReceive = false
  if danceInfo then
    self.canReceive = totalTime - danceInfo.danceSecs <= 0
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_gift_off, not hasSend and not self.canReceive)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_gift_on, not hasSend and self.canReceive)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_complete, hasSend)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_personal_obtained, hasSend)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_personal_time, not hasSend and not self.canReceive)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_can_receive, not hasSend and self.canReceive)
end

function UnionWardanceCountDown:refresh()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_time, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_wardance, false)
  self.timeLanguage = "UnionWardanceCountDown"
  if self.unionWarDanceVM_:isInWarDanceActivity() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_wardance, true)
    self:refreshWarDanceOpen()
    self.timerID = self.danceActivityTableRow.TimerId
    self.timerLab = self.uiBinder.lab_time
  elseif self.unionWarDanceVM_:isinWillOpenWarDanceActivity() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_time, true)
    self.timerID = self.danceActivityTableRow.PreTimerId
    self.timerLab = self.uiBinder.lab_time_not_open
    self.timeLanguage = "UnionWardanceCountDownPre"
  end
  local hasEnd, _, endTime = Z.TimeTools.GetCycleStartEndTimeByTimeId(self.timerID)
  if hasEnd then
    local dTime = math.floor(endTime - Z.ServerTime:GetServerTime() / 1000)
    if 0 <= dTime then
      local time = Z.TimeFormatTools.FormatToDHMS(dTime)
      self.timerLab.text = Lang(self.timeLanguage, {val = time})
    end
  end
end

function UnionWardanceCountDown:refreshWarDanceOpen()
  self:refreshMemberCnt()
  self:refreshSelfReward()
  local curTotalScore = self.unionWarDanceData_:GetDancedScore()
  self:refreshProgress(curTotalScore)
end

function UnionWardanceCountDown:refreshMemberCnt()
  local memberCount = self.unionWarDanceData_:GetMemberCount()
  self.uiBinder.lab_people.text = Lang("UnionWarDanceTotalPeople", {val = memberCount})
end

function UnionWardanceCountDown:refreshSelfReward()
  local totalTime = self.danceActivityTableRow.SoloSpeed
  local danceInfo = self.unionWarDanceData_:GetDancedInfo()
  if not danceInfo then
    self.selfDancedTime_ = 0
    local remainTime = totalTime - self.selfDancedTime_
    if remainTime < 0 then
      remainTime = 0
    end
    self.uiBinder.lab_personal_time.text = Lang("UnionWardancePersonalTimer", {val = remainTime})
    self.uiBinder.img_ing.fillAmount = 0
    self:changeSelfRewardSended(false)
    return
  end
  self.selfDancedTime_ = danceInfo.danceSecs
  local remainTime = totalTime - self.selfDancedTime_
  if remainTime < 0 then
    remainTime = 0
  end
  self.uiBinder.lab_personal_time.text = Lang("UnionWardancePersonalTimer", {val = remainTime})
  self.uiBinder.img_ing.fillAmount = totalTime == 0 and 1 or self.selfDancedTime_ / totalTime
  self:changeSelfRewardSended(danceInfo.hasSend)
end

function UnionWardanceCountDown:initProgressNodePos()
  if not self.danceActivityTableRow then
    return
  end
  local progressWidth = self.uiBinder.img_frame.rect.width
  for i = 1, #self.progressNodes_ do
    if i > #self.danceActivityTableRow.BuffLevel then
      self.uiBinder.Ref:SetVisible(self.progressNodes_[i], false)
    else
      self.uiBinder.Ref:SetVisible(self.progressNodes_[i], true)
      local x = self.danceActivityTableRow.BuffLevel[i] / 100 * progressWidth
      self.progressNodes_[i].anchoredPosition = Vector2.New(x, -24)
    end
  end
end

function UnionWardanceCountDown:refreshProgress(curTotalScore)
  local totalScore = self.danceActivityTableRow.TotalScore
  self.progress = 0
  if totalScore == 0 then
    self.progress = 1
  else
    self.progress = curTotalScore / totalScore
  end
  self.uiBinder.img_on.fillAmount = self.progress
  self.uiBinder.lab_percent.text = Lang("UnionWarDanceProgress", {
    val = string.format("%0.1f", self.progress * 100)
  })
  for i = 1, #self.progressBGs_ do
    if i <= #self.danceActivityTableRow.BuffLevel then
      if self.progress * 100 >= self.danceActivityTableRow.BuffLevel[i] then
        self.progressBGs_[i].color = Color.New(1.0, 0.7843137254901961, 0.40784313725490196, 1)
      else
        self.progressBGs_[i].color = Color.New(0.8431372549019608, 0.8392156862745098, 84.47843137254903, 1)
      end
    end
  end
end

function UnionWardanceCountDown:startTimer()
  local hasEnd, _, endTime = Z.TimeTools.GetCycleStartEndTimeByTimeId(self.timerID)
  if not hasEnd then
    return
  end
  if not self.timer then
    self.timer = self.timerMgr:StartTimer(function()
      self:countdownTime(endTime)
    end, 1, -1)
  end
end

function UnionWardanceCountDown:countdownTime(endTime)
  if not self.inited then
    return
  end
  local dTime = math.floor(endTime - Z.ServerTime:GetServerTime() / 1000)
  if not self.timerLab then
    self:refresh()
    self:stopTime()
  end
  if 0 <= dTime then
    local time = Z.TimeFormatTools.FormatToDHMS(dTime)
    self.timerLab.text = Lang(self.timeLanguage, {val = time})
  else
    self:refresh()
    self:stopTime()
  end
end

function UnionWardanceCountDown:stopTime()
  if self.timer then
    self.timerMgr:StopTimer(self.timer)
    self.timer = nil
  end
end

return UnionWardanceCountDown
