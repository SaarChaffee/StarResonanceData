local Parkour_ranking_tplView = class("Parkour_ranking_tplView")
local imgNormalColor = Color.New(0.8235294117647058, 0.8313725490196079, 0.7686274509803922, 1)
local textNormalColor = Color.New(1, 1, 1, 1)
local imgRedColor = Color.New(0.996078431372549, 0.49411764705882355, 0.44313725490196076, 1)
local textRedColor = Color.New(0.996078431372549, 0.49411764705882355, 0.44313725490196076, 1)
local rankImgPath = "ui/textures/parkour/pakour_img_"
local unitEffPathPrefix = "ui/uieffect/prefab/ui_sfx_parkour_001/ui_sfx_node_ranking_level_00"

function Parkour_ranking_tplView:ctor()
  self.parkourData_ = Z.DataMgr.Get("parkour_tooltip_data")
end

function Parkour_ranking_tplView:Init(go, name, isShowRank, canPlayShowRank, rankCallBack)
  self.name = name
  self.unit = UICompBindLua(go)
  self.unit.Ref:SetOffSetMin(0, 0)
  self.unit.Ref:SetOffSetMax(0, 0)
  self.unit.Ref:SetVisible(true)
  self.isFirst_ = 0
  self.rankCallBack = rankCallBack
  self.node_ranking_current = self.unit.node_ranking_level
  self.img_bg_ranking = self.unit.rimg_bg
  self.img_num_rank_current = self.unit.img_num_current
  self.img_letter_ranking_current = self.unit.img_letter_current
  self.img_num_rank_last = self.unit.img_num_last
  self.img_letter_ranking_last = self.unit.img_letter_laset
  self.eff_root_ranking = self.unit.eff_root
  self.img_left = self.unit.img_left
  self.img_right = self.unit.img_right
  self.img_clock = self.unit.img_clock
  self.lab_time = self.unit.lab_time
  self.lab_ranking = self.unit.lab_ranking
  self.node_ranking = self.unit.node_start
  self.node_start_eff_root_ = self.unit.start_eff_root
  self.lab_num = self.unit.lab_num
  self.node_time = self.unit.node_time
  self.isShowRank = isShowRank
  self.rimg_start = self.unit.rimg_start
  self.img_green = self.unit.img_green
  self.img_red = self.unit.img_red
  self.add_time_label_arr = self.unit.lab_num
  self.img_green = self.unit.img_green
  self.img_red = self.unit.img_red
  self.realTime_ = 0
  self.img_red:SetVisible(false)
  self.img_green:SetVisible(false)
  self.lastRankingNum_ = 0
  self.ranking = 1
  self.timerMgr = Z.TimerMgr.new()
  self.timer = nil
  self.cancelSource = Z.CancelSource.Rent()
  self:SetNodeColor(false)
  self:SetRankingNodeIsOpen(isShowRank ~= nil and isShowRank ~= false)
  self:BindEvents()
  self:SetData(canPlayShowRank)
  self:ChangeCurrentRank()
  if canPlayShowRank then
    self.unit.node_audio.Audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.commonAudio_1)
    self.node_start_eff_root_.ZEff:CreatEFFGO("ui/uieffect/prefab/ui_sfx_parkour_001/ui_sfx_group_start_001", Vector3.zero, true)
    self.timerMgr:StartTimer(function()
      self.node_start_eff_root_.ZEff:ReleseEffGo()
    end, 2, 1)
  end
end

function Parkour_ranking_tplView:DeActive()
  self.isShowRank = nil
  self:UnbindEvents()
  self.timerMgr:Clear()
  self.rankCallBack = nil
  self.isFirst_ = 0
  self.eff_root_ranking.ZEff:ReleseEffGo()
  if self.cancelSource then
    self.cancelSource:Recycle()
    self.cancelSource = nil
  end
end

function Parkour_ranking_tplView:CountDownFunc(timeInfo)
  local detailTime = timeInfo.timeNumber
  if timeInfo.timeNumber <= 0 then
    return
  end
  if timeInfo.isShowZeroSecond then
    detailTime = timeInfo.timeNumber - 1000
  end
  self:clearTimer()
  self.realTime_ = math.floor((detailTime - Z.ServerTime:GetServerTime()) / 1000)
  local showTimeString = self.realTime_
  if timeInfo.timingDirection == E.DungeonTimerDirection.DungeonTimerDirectionUp then
    showTimeString = math.floor((Z.ServerTime:GetServerTime() - timeInfo.startTime * 1000) / 1000)
  end
  local curTime = Z.TimeFormatTools.FormatToDHMS(showTimeString, true, true)
  self.lab_time.TMPLab.text = self:changeLabColor(curTime)
  if 0 < timeInfo.pauseTime then
    return
  end
  self:showAddTimeUI(timeInfo.addLimitTime, timeInfo.addTimeUiType)
  local isTirggerLimitTime = true
  self.isCalledFinsishFunc = false
  local t = self.realTime_
  self.timer = self.timerMgr:StartTimer(function()
    if timeInfo.timingDirection == E.DungeonTimerDirection.DungeonTimerDirectionUp then
      t = t + 1
    else
      t = t - 1
    end
    if t <= 0 then
      t = 0
    end
    if timeInfo.limitTime ~= nil then
      if t <= timeInfo.limitTime then
        if isTirggerLimitTime then
          isTirggerLimitTime = false
          self:SetNodeColor(true)
          if timeInfo.timeLimitFunc then
            timeInfo.timeLimitFunc()
          end
        end
      else
        self:SetNodeColor(false)
      end
    end
    if timeInfo.timeCallFunc then
      timeInfo.timeCallFunc()
    end
    local curShowTime = Z.TimeFormatTools.FormatToDHMS(t, true, true)
    self.lab_time.TMPLab.text = self:changeLabColor(curShowTime)
    if t == 0 then
      self.timer:Stop()
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

function Parkour_ranking_tplView:showAddTimeUI(addTime, showUiType)
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

function Parkour_ranking_tplView:SetData(canPlayShowRank)
  if not self.node_ranking.Ref.IsVisible then
    return
  end
  if not canPlayShowRank then
    self.node_ranking:SetVisible(false)
  else
    self.timerMgr:StartTimer(function()
      self.node_ranking:SetVisible(false)
      if self.rankCallBack then
        self.rankCallBack()
      end
    end, 2)
    self.rimg_start.RImg:SetImage("ui/textures/parkour/pakour_img_start")
  end
  self.node_ranking_current:SetVisible(false)
end

function Parkour_ranking_tplView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.ParkourActionEvt.SyncRankInfo, self.ChangeCurrentRank, self)
end

function Parkour_ranking_tplView:UnbindEvents()
  Z.EventMgr:Remove(Z.ConstValue.ParkourActionEvt.SyncRankInfo, self.ChangeCurrentRank, self)
end

function Parkour_ranking_tplView:ChangeCurrentRank(currentRankNum)
  if not self.isShowRank then
    return
  end
  local rankNum = 0
  if currentRankNum and currentRankNum ~= 0 then
    rankNum = currentRankNum
  end
  if self.isFirst_ == 0 then
    self.isFirst_ = self.isFirst_ + 1
  end
  self:playRankAudio(rankNum)
  self:SetRankingIamge(rankNum)
end

function Parkour_ranking_tplView:playRankAudio(currentRankNum)
  if currentRankNum > self.lastRankingNum_ and currentRankNum ~= 1 then
    self.unit.node_audio.Audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.commonAudio_2)
  elseif currentRankNum == 1 then
    self.unit.node_audio.Audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.commonAudio_3)
  elseif currentRankNum < self.lastRankingNum_ then
    self.unit.node_audio.Audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.commonAudio_4)
  end
end

function Parkour_ranking_tplView:SetRankingIamge(rankingNum)
  local rankingImgPath = ""
  local rankBgPath = ""
  local rankingImgPath_last = ""
  local rankBgPath_last = ""
  local currentRankingNum = rankingNum
  local isPlayAni = currentRankingNum ~= self.lastRankingNum_
  local isShow = false
  if rankingNum == 0 then
    isShow = false
  else
    if self.lastRankingNum_ == 0 then
      self.lastRankingNum_ = currentRankingNum
    end
    rankingImgPath = rankImgPath .. currentRankingNum
    local rankImgBgPath = self.unit.Ref.PrefabCacheData:GetString("rankImgBgPath")
    local bgPathNum = 4 < currentRankingNum and 4 or currentRankingNum
    rankBgPath = rankImgBgPath .. bgPathNum
    rankingImgPath_last = rankImgPath .. self.lastRankingNum_
    rankBgPath_last = rankImgBgPath .. self.lastRankingNum_
    if rankingImgPath == "" or rankBgPath == "" or rankingImgPath_last == "" or rankBgPath_last == "" then
      isShow = false
    else
      isShow = true
    end
  end
  self.node_ranking_current:SetVisible(isShow)
  if not isShow then
    return
  end
  if not isPlayAni then
    return
  end
  self.lastRankingNum_ = rankingNum
  self.img_bg_ranking.RImg:SetImage(rankBgPath)
  local curChar = self:characterConversion(currentRankingNum)
  self.img_num_rank_current.UVOffsetImage:SetValue(curChar)
  self.eff_root_ranking.ZEff:CreatEFFGO(unitEffPathPrefix .. currentRankingNum, Vector3.zero, true)
  self.eff_root_ranking.ZEff:SetEffectGoVisible(true)
  self:onPlayAnim()
end

function Parkour_ranking_tplView:onPlayAnim()
  local anim = ""
  if self.isFirst_ == 1 then
    anim = "ui_anim_parkour_ranking_tpl_node_ranking_level_fade_in_one"
  else
    anim = "ui_anim_parkour_ranking_tpl_node_ranking_level_fade_in"
  end
  local m_anim = self.node_ranking_current.anim
  m_anim:ResetAniState(anim)
  m_anim:PlayOnce(anim)
  self.isFirst_ = 2
end

function Parkour_ranking_tplView:SetRankingNodeIsOpen(isOpen)
  self.node_ranking_current:SetVisible(isOpen)
  self.node_ranking:SetVisible(isOpen)
end

function Parkour_ranking_tplView:SetNodeColor(isChangeColor)
  local imgColor = imgNormalColor
  local textColor = textNormalColor
  if isChangeColor then
    imgColor = imgRedColor
    textColor = textRedColor
  end
  if self.img_left.Img.color == imgColor then
    return
  end
  self.img_left.Img:SetColor(imgColor)
  self.img_right.Img:SetColor(imgColor)
  self.img_clock.Img:SetColor(textColor)
  self.lab_time.TMPLab.color = textColor
end

function Parkour_ranking_tplView:clearTimer()
  if self.timer then
    self.isCalledFinsishFunc = true
    self.timer:Stop()
  end
  self.realTime_ = 0
end

function Parkour_ranking_tplView:changeLabColor(curTime, outLookType)
  if outLookType == E.DungeonTimerTimerLookType.EDungeonTimerTimerLookTypeRed then
    curTime = Z.RichTextHelper.ApplyStyleTag(curTime, E.TextStyleTag.TipsRed)
  end
  return curTime
end

function Parkour_ranking_tplView:characterConversion(currentNum)
  local curChar = 1
  if currentNum == 1 then
    curChar = "a"
  elseif currentNum == 2 then
    curChar = "b"
  elseif currentNum == 3 then
    curChar = "c"
  else
    curChar = currentNum
  end
  return curChar
end

return Parkour_ranking_tplView
