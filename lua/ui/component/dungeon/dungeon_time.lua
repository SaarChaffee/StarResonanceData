local DungeonTime = class("DungeonTime")
local scoreSliderColor = {
  [0] = Color.New(0.7372549019607844, 0.9294117647058824, 0.34901960784313724, 1),
  [1] = Color.New(0.7372549019607844, 0.9294117647058824, 0.34901960784313724, 1),
  [2] = Color.New(0.8117647058823529, 0.5686274509803921, 1.0, 1),
  [3] = Color.New(1.0, 0.7529411764705882, 0.3215686274509804, 1)
}
local rankBGColor = {
  [0] = Color.New(0.3254901960784314, 0.6666666666666666, 0 / 255, 0.1),
  [1] = Color.New(0.3254901960784314, 0.6666666666666666, 0 / 255, 1),
  [2] = Color.New(0.7647058823529411, 0.40784313725490196, 0.9725490196078431, 1),
  [3] = Color.New(0.9176470588235294, 0.6549019607843137, 0.0196078431372549, 1)
}
local scoreFrameImage = {
  [0] = "ui/atlas/hero_dungeon/hero_dungeon_com_frame",
  [1] = "ui/atlas/hero_dungeon/hero_dungeon_com_frame",
  [2] = "ui/atlas/hero_dungeon/hero_dungeon_outstanding_frame",
  [3] = "ui/atlas/hero_dungeon/hero_dungeon_perfect_frame"
}

function DungeonTime:ctor()
  self.dungeonTimerData = Z.DataMgr.Get("dungeon_timer_data")
end

function DungeonTime:Init(view, unit, data, ignoreChange)
  self.view_ = view
  self.unit_ = unit
  self.data_ = data
  self.realTime_ = 0
  self.scoreLevle_ = -1
  self.worldAttrWatcherToken = {}
  if self.unit_ then
    self.unit_.Trans:SetOffsetMin(0, 0)
    self.unit_.Trans:SetOffsetMax(0, 0)
  end
  self:refresh()
  self:initDead()
  if not ignoreChange then
    self:showTimeChange()
  end
  if self.data_.isShowStartAnim or ignoreChange then
    self:onStartAnimatedShow()
  end
  Z.EventMgr:Add(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
  Z.EventMgr:Add(Z.ConstValue.Dungeon.ContributionInfoChange, self.refreshWorldBoss, self)
end

function DungeonTime:refresh()
  if self.data_ == nil then
    self.unit_.Ref.UIComp:SetVisible(false)
    return
  else
    self.unit_.Ref.UIComp:SetVisible(true)
  end
  if self.data_.pauseTime == 0 then
    self.dungeonTimerData.IsPausing = false
  end
  self.unit_.Ref:SetVisible(self.unit_.node_timing, false)
  if self.data_.isShowScore then
    self.unit_.Ref:SetVisible(self.unit_.layout_lab, true)
    self.unit_.Ref:SetVisible(self.unit_.node_rank, true)
  else
    self.unit_.Ref:SetVisible(self.unit_.layout_lab, false)
    self.unit_.Ref:SetVisible(self.unit_.node_rank, false)
  end
  self.unit_.lab_time_name.text = self.data_.timeLab or Lang("Time")
  if self.dungeonTimerData.IsPausing then
    local dTime = self:getShowTimeByPauseTime()
    self.realTime_ = dTime
    self:setTimeLab()
    return
  end
  self:calcTime()
  self:setTimeLab()
  self.unit_.lab_score.text = 0
  self:isShowTime(true)
  self:setTime()
  if self.data_.isShowScore then
    self:initScore()
  end
  self.unit_.Ref:SetVisible(self.unit_.node_contribution, self:checkIsWorldBoss())
  self:refreshWorldBoss()
  if self.data_.pauseTime > 0 then
    self:stopTime()
    self.dungeonTimerData.IsPausing = true
  end
end

function DungeonTime:getShowTimeByPauseTime()
  local deathSubTimeSecond = 0
  if self.data_.showDead then
    local deathSecond = Z.World:GetWorldLuaAttr(Z.PbAttrEnum("AttrDeathSubTimeSecond"))
    if deathSecond and 0 < deathSecond.Value then
      deathSubTimeSecond = deathSecond.Value
    end
  end
  local dTime = self.data_.curPauseTimestamp - self.data_.startTime + deathSubTimeSecond
  return dTime
end

function DungeonTime:setTimeLab()
  local defaultTime = 0
  if self.data_.showType == E.DungeonTimeShowType.num then
    defaultTime = math.floor(self.realTime_)
  else
    defaultTime = Z.TimeFormatTools.FormatToDHMS(self.realTime_, true, true)
  end
  if self.data_.lookType == E.DungeonTimerTimerLookType.EDungeonTimerTimerLookTypeRed then
    defaultTime = Z.RichTextHelper.ApplyStyleTag(defaultTime, E.TextStyleTag.TipsRed)
  end
  self.unit_.lab_time.text = defaultTime
end

function DungeonTime:initDead()
  if self.unit_.node_dead_father then
    self.unit_.node_dead_father.Ref.UIComp:SetVisible(self.data_.showDead)
  end
  
  function self.refreshDeadUI()
    if self.data_.showDead then
      local attrDeathCount = Z.PbAttrEnum("AttrDeathCount")
      local deadCount = Z.World:GetWorldLuaAttr(attrDeathCount)
      local attrDeathSubTimeSecond = Z.PbAttrEnum("AttrDeathSubTimeSecond")
      local deathSubTimeSecond = Z.World:GetWorldLuaAttr(attrDeathSubTimeSecond)
      local deathSubTimeShow = Z.TimeFormatTools.FormatToDHMS(deathSubTimeSecond.Value, true, true)
      if self.unit_ then
        self.unit_.node_dead_father.lab_deadcount.text = deadCount.Value
        self.unit_.node_dead_father.lab_deadreduce.text = deathSubTimeShow
        self:stopTime()
        self:refresh()
      end
    end
  end
  
  if self.data_.showDead then
    local attrType = Z.PbAttrEnum("AttrDeathCount")
    local attrIndex = {attrType}
    local token = Z.World:BindWorldLuaAttrWatcher(attrIndex, self.refreshDeadUI)
    table.insert(self.worldAttrWatcherToken, token)
  end
  self.refreshDeadUI()
end

function DungeonTime:RefreshData(data)
  self.data_ = data
  self:refresh()
end

function DungeonTime:showTimeChange()
  if not (self.data_ and self.data_.changeTimeNumber and self.data_.changeTimeType) or self.data_.changeTimeNumber == 0 then
    return
  end
  local bgImage
  if self.data_.changeTimeType == E.DungeonTimerEffectType.EDungeonTimerEffectTypeAdd then
    bgImage = self.unit_.pcd:GetString("timeChangeRedBg")
    self.data_.changeTimeNumber = Z.RichTextHelper.ApplyStyleTag(self.data_.changeTimeNumber, E.TextStyleTag.TipsRed)
  elseif self.data_.changeTimeType == E.DungeonTimerEffectType.EDungeonTimerEffectTypeSub then
    bgImage = self.unit_.pcd:GetString("timeChangeGreenBg")
    self.data_.changeTimeNumber = Z.RichTextHelper.ApplyStyleTag(self.data_.changeTimeNumber, E.TextStyleTag.TipsGreen)
  end
  if not bgImage then
    return
  end
  self.unit_.Ref:SetVisible(self.unit_.node_timing, true)
  self.unit_.lab_time_01.text = self.data_.changeTimeNumber
  self.unit_.img_light:SetImage(bgImage)
  self.view_.timerMgr:StartTimer(function()
    self.unit_.Ref:SetVisible(self.unit_.node_timing, false)
  end, 2)
end

function DungeonTime:isShowTime(isShow)
  self.unit_.Ref:SetVisible(self.unit_.node_time, isShow)
end

function DungeonTime:stopTime()
  if self.time_ then
    self.view_.timerMgr:StopTimer(self.time_)
    self.time_ = nil
  end
  self.realTime_ = 0
end

function DungeonTime:justTime()
  self.realTime_ = self.realTime_ + 1
  if self.realTime_ >= 0 then
    local time
    if self.data_.showType == E.DungeonTimeShowType.num then
      time = math.floor(self.realTime_)
    else
      time = Z.TimeFormatTools.FormatToDHMS(self.realTime_, true, true)
    end
    if self.data_.lookType == E.DungeonTimerTimerLookType.EDungeonTimerTimerLookTypeRed then
      time = Z.RichTextHelper.ApplyStyleTag(time, E.TextStyleTag.TipsRed)
    end
    self.unit_.lab_time.text = time
  else
    self:stopTime()
  end
end

function DungeonTime:countdownTime()
  self.realTime_ = self.realTime_ - 1
  if self.realTime_ >= 0 then
    local time
    if self.data_.showType == E.DungeonTimeShowType.num then
      time = math.floor(self.realTime_)
    else
      time = Z.TimeFormatTools.FormatToDHMS(self.realTime_, true, true)
    end
    if self.data_.lookType == E.DungeonTimerTimerLookType.EDungeonTimerTimerLookTypeRed then
      time = Z.RichTextHelper.ApplyStyleTag(time, E.TextStyleTag.TipsRed)
    end
    self.unit_.lab_time.text = time
  else
    self:stopTime()
  end
end

function DungeonTime:setTime()
  self:stopTime()
  self:calcTime()
  if self.data_.timeType == E.DungeonTimerDirection.DungeonTimerDirectionUp then
    if self.data_.startTime then
      local func = function()
        self:justTime()
      end
      self.time_ = self.view_.timerMgr:StartTimer(func, 1, -1)
    end
  elseif self.data_.timeType == E.DungeonTimerDirection.DungeonTimerDirectionDown then
    local func = function()
      self:countdownTime()
    end
    if self.data_.endTime then
      self.time_ = self.view_.timerMgr:StartTimer(func, 1, self.realTime_)
    end
  end
end

function DungeonTime:refreshContribution()
  local worldBossData = Z.DataMgr.Get("world_boss_data")
  local rankInfos = worldBossData:GetWorldBossRankInfo()
  local selfInfoData
  local randNum = 0
  if not selfInfoData then
    for index, value in ipairs(rankInfos) do
      if value.charId == Z.ContainerMgr.CharSerialize.charId then
        randNum = index
        selfInfoData = value
      end
    end
  end
  local curContribution = 0
  if selfInfoData ~= nil then
    curContribution = selfInfoData.score
  end
  local hasReward = curContribution >= Z.WorldBoss.WorldBossMinContribute
  if hasReward then
    self.unit_.lab_rewards.text = Lang("WorldBossContributionEnough", {
      cur = curContribution,
      max = Z.WorldBoss.WorldBossMinContribute
    })
  else
    self.unit_.lab_rewards.text = Lang("WorldBossContributionNotEnough", {
      cur = curContribution,
      max = Z.WorldBoss.WorldBossMinContribute
    })
  end
end

function DungeonTime:refreshWorldBoss()
  if not self:checkIsWorldBoss() then
    return
  end
  self:refreshContribution()
end

function DungeonTime:checkIsWorldBoss()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  if 0 < dungeonId then
    local dungeonTable = Z.TableMgr.GetTable("DungeonsTableMgr")
    local tableRow = dungeonTable.GetRow(dungeonId)
    if tableRow and tableRow.PlayType == E.DungeonType.WorldBoss then
      return true
    end
  end
  return false
end

function DungeonTime:initScore()
  local ratio = Z.ContainerMgr.DungeonSyncData.dungeonScore.curRatio
  if self.data_.baseScoreRatio then
    ratio = Z.ContainerMgr.DungeonSyncData.dungeonScore.curRatio + self.data_.baseScoreRatio
  end
  self.dungeonVm_ = Z.VMMgr.GetVM("dungeon")
  self.nowDungeonId_ = Z.StageMgr.GetCurrentDungeonId()
  self.scoreLevelTab_ = self.dungeonVm_.GetScoreLevelTab(self.nowDungeonId_)
  
  function self.watcherFun_(container, dirtys)
    self:changeScore(container, ratio, dirtys)
  end
  
  self.dungeonScore_ = Z.ContainerMgr.DungeonSyncData.dungeonScore
  if self.dungeonScore_ then
    self:SetScore(self.dungeonScore_.totalScore, ratio)
    self.dungeonScore_.Watcher:RegWatcher(self.watcherFun_)
  end
end

function DungeonTime:changeScore(container, ratio, dirtys)
  if dirtys and dirtys.totalScore then
    self:SetScore(dirtys.totalScore:Get(), ratio)
  end
end

function DungeonTime:SetScore(score, ratio)
  self.unit_.lab_score.text = string.zconcat(score, "(x ", ratio, "%)")
  self:setScoreIcon(score)
end

function DungeonTime:calcTime()
  if self.data_.timeType == E.DungeonTimerDirection.DungeonTimerDirectionUp then
    local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
    local deathSubTimeSecond = 0
    if self.data_.showDead then
      local deathSecond = Z.World:GetWorldLuaAttr(Z.PbAttrEnum("AttrDeathSubTimeSecond"))
      if deathSecond and 0 < deathSecond.Value then
        deathSubTimeSecond = deathSecond.Value
      end
    end
    local dTime = nowTime - self.data_.startTime - self.data_.totalPauseTime + deathSubTimeSecond
    self.realTime_ = dTime
  elseif self.data_.timeType == E.DungeonTimerDirection.DungeonTimerDirectionDown then
    self.realTime_ = math.floor(self.data_.endTime - Z.ServerTime:GetServerTime() / 1000)
  end
end

function DungeonTime:setScoreIcon(score)
  if not self.dungeonVm_.HasScoreLevel(self.nowDungeonId_) then
    self.unit_.Ref:SetVisible(self.unit_.node_lab, false)
    self.unit_.Ref:SetVisible(self.unit_.node_rank, false)
    return
  end
  self.unit_.Ref:SetVisible(self.unit_.node_lab, true)
  self.unit_.Ref:SetVisible(self.unit_.node_rank, true)
  local level = self.dungeonVm_.GetNowLevelByScore(score, self.scoreLevelTab_)
  if level and level ~= self.scoreLevel_ then
    self.unit_.lab_rank.text = Lang(string.zconcat("DungeonPassRank", level))
    self.unit_.img_right:SetColor(rankBGColor[level])
    self.unit_.img_right_1:SetColor(rankBGColor[level])
    self.unit_.img_on:SetColor(scoreSliderColor[level])
    self.unit_.img_frame:SetImage(scoreFrameImage[level])
    self.scoreLevel_ = level
  end
  self.unit_.img_on.fillAmount = self.dungeonVm_.GetScoreProgress(score, self.scoreLevelTab_, level)
end

function DungeonTime:onStartAnimatedShow()
  self.unit_.node_copy_anim:PlayOnce("anim_ui_hero_dungeon_time_tpl_open")
end

function DungeonTime:DeActive()
  if self.watcherFun_ and self.dungeonScore_ then
    self.dungeonScore_.Watcher:UnregWatcher(self.watcherFun_)
    self.dungeonScore_ = nil
    self.watcherFun_ = nil
  end
  for _, v in ipairs(self.worldAttrWatcherToken) do
    Z.World:UnbindWorldLuaAttrWater(v)
  end
  self.worldAttrWatcherToken = {}
  self:stopTime()
  Z.EventMgr:Remove(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
  Z.EventMgr:Remove(Z.ConstValue.Dungeon.ContributionInfoChange, self.refreshWorldBoss, self)
end

function DungeonTime:OnHideHalfScreenView(isOpen, viewConfigKey)
  if not Z.IsPCUI then
    return
  end
  self.unit_.Ref.UIComp:SetVisible(not isOpen)
end

return DungeonTime
