local UI = Z.UI
local super = require("ui.ui_view_base")
local World_boss_matchingView = class("World_boss_matchingView", super)

function World_boss_matchingView:ctor()
  self.uiBinder = nil
  super.ctor(self, "world_boss_matching")
  self.worldBossVM_ = Z.VMMgr.GetVM("world_boss")
  self.worldBossData_ = Z.DataMgr.Get("world_boss_data")
  self.matchVm_ = Z.VMMgr.GetVM("match")
  self.matchData_ = Z.DataMgr.Get("match_data")
end

function World_boss_matchingView:OnActive()
  Z.AudioMgr:Play("UI_Event_WorldBoss")
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initBaseData()
  self:initBinders()
  self:BindEvents()
  self:refreshMatchStage()
  self.depth_ = self.uiBinder.Ref.UIComp.UIDepth.Depth
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_title_effect)
  self.uiBinder.content_depth:UpdateDepth(self.depth_ + 10, true)
  self.uiBinder.btn_reject.IsDisabled = self.hasSelect == true
  Z.CoroUtil.create_coro_xpcall(function()
    self.worldBossVM_:AsyncGetWorldBossInfo(self.cancelSource:CreateToken(), function(ret)
      self:refreshWorldBossSwitch(ret)
      self:refreshPropress()
    end)
  end)()
end

function World_boss_matchingView:refreshWorldBossSwitch(ret)
  local bossSwitchID = ret.bossCfgId
  local worldBossSwitchTableRow = Z.TableMgr.GetTable("WorldBossSwitchTableMgr").GetRow(bossSwitchID)
  if worldBossSwitchTableRow then
    self.uiBinder.rimg_bg:SetImage(worldBossSwitchTableRow.MatchPic)
    self.uiBinder.rimg_title:SetImage(worldBossSwitchTableRow.MatchBossText)
    self.uiBinder.node_effect:CreatEFFGO(worldBossSwitchTableRow.MatchBossEffect, Vector3.zero)
    self.uiBinder.node_effect:SetEffectGoVisible(true)
    self.uiBinder.node_title_effect:CreatEFFGO(worldBossSwitchTableRow.MatchBossTextEffect, Vector3.zero)
    self.uiBinder.node_title_effect:SetEffectGoVisible(true)
    local matchTableRow = Z.TableMgr.GetTable("MatchTableMgr").GetRow(worldBossSwitchTableRow.MatchId)
    self.maxMemberCount_ = matchTableRow.MatchMaxNum
    self.maxCheckTime_ = matchTableRow.ConfirmTime - (Z.TimeTools.Now() / 1000 - self.matchData_:GetMatchSuccessTime())
    self.checkTime_ = self.maxCheckTime_
    self.uiBinder.lab_tips.text = Lang("Start12PeopleRefusalStopMatchCurrentTeam", {
      val = matchTableRow.MatchMinNum
    })
    self.hasSelect = false
  end
end

function World_boss_matchingView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_title_effect)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.uiBinder.btn_reject.IsDisabled = false
end

function World_boss_matchingView:OnRefresh()
end

function World_boss_matchingView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Match.MatchPlayerInfoChange, self.refreshMemberCount, self)
end

function World_boss_matchingView:initBinders()
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
  local countID = Z.WorldBoss.WorldBossAwardCountId
  local limtCount = Z.CounterHelper.GetCounterLimitCount(countID)
  local normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(countID, limtCount)
  self.uiBinder.lab_count.text = "" .. normalAwardCount .. "/" .. limtCount
  self.uiBinder.btn_accept.IsDisabled = false
end

function World_boss_matchingView:refreshPropress()
  self.uiBinder.img_top.fillAmount = 1
  if self.timer_ == nil then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  self.timer_ = self.timerMgr:StartTimer(function()
    self.checkTime_ = self.checkTime_ - 0.1
    if self.checkTime_ >= 0 then
      local num = self.checkTime_ / self.maxCheckTime_
      self.uiBinder.img_top.fillAmount = num
    end
  end, 0.1, -1)
end

function World_boss_matchingView:initBaseData()
end

function World_boss_matchingView:refreshMatchStage()
  self:refreshMemberCount()
end

function World_boss_matchingView:refreshMemberCount()
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

return World_boss_matchingView
