local UI = Z.UI
local super = require("ui.ui_view_base")
local Raid_mainView = class("Raid_mainView", super)
local loopListView = require("ui.component.loop_list_view")
local previewRewardItem = require("ui.component.common_recharge.common_preview_loop_item")

function Raid_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "raid_main")
  self.matchVm_ = Z.VMMgr.GetVM("match")
  self.matchTeamVm_ = Z.VMMgr.GetVM("match_team")
  self.matchTeamData_ = Z.DataMgr.Get("match_team_data")
end

function Raid_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.raidVm_ = Z.VMMgr.GetVM("raid")
  self.dungeonVM_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self:AddAsyncClick(self.uiBinder.btn_team, function()
    local teamMainVm = Z.VMMgr.GetVM("team_main")
    teamMainVm.EnterTeamTargetByDungeonId(self.dungeonId_)
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self.helpsysVM_.OpenFullScreenTipsView(self.curRaidDungeonData_.Content)
  end)
  self:AddAsyncClick(self.uiBinder.btn_go, function()
    local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
    if dungeonData == nil then
      return
    end
    self.raidVm_:AsyncStartEnterDungeon(dungeonData.FunctionID, self.dungeonId_, self.dungeonVM_.GetAffix(self.dungeonId_), self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    self.raidVm_:CloseRaidMainView()
  end)
  self.rewardLoopList_ = loopListView.new(self, self.uiBinder.loop_item, previewRewardItem, "com_item_square_1_8")
  self.rewardLoopList_:Init({})
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  local raidDungeonData = Z.TableMgr.GetTable("RaidDungeonTableMgr").GetDatas()
  self.raidDungeons_ = {}
  for _, value in pairs(raidDungeonData) do
    if value.SeasonId == seasonId then
      self.raidDungeons_[value.Difficult] = value
    end
  end
  self.nodeBossTitles_ = {
    [1] = self.uiBinder.node_title_01,
    [2] = self.uiBinder.node_title_02,
    [3] = self.uiBinder.node_title_03
  }
  self.toggles_ = {
    [1] = self.uiBinder.tog_easy,
    [2] = self.uiBinder.tog_difficulty,
    [3] = self.uiBinder.tog_nightmare
  }
  for diff, value in ipairs(self.toggles_) do
    value.isOn = false
    value.group = self.uiBinder.node_select
    value:AddListener(function(isOn)
      if isOn then
        self:OnClickDiffToggle(diff)
      end
    end)
  end
  self.diff_ = self.viewData.diff or 1
  if not self.toggles_[self.diff_].isOn then
    self.toggles_[self.diff_].isOn = true
  else
    self:OnClickDiffToggle(self.diff_)
  end
  self:AddClick(self.uiBinder.btn_match, function()
    self.matchVm_.RequestBeginMatch(E.MatchType.Team, {
      dungeonId = self.dungeonId_
    }, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.uiBinder.btn_cancel_match, function()
    self.matchVm_.AsyncCancelMatch()
  end)
  Z.EventMgr:Add(Z.ConstValue.Match.MatchStateChange, self.refreshMatchState, self)
end

function Raid_mainView:refreshMatchState()
  local isCanMatch = self.matchTeamVm_.IsShowMatchBtn(self.dungeonId_)
  local isMatching = self.matchVm_.IsMatching()
  local curMatchingDungeonID = self.matchTeamData_:GetCurMatchingDungeonId()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_team, not isCanMatch)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_match, isCanMatch and (not isMatching or curMatchingDungeonID ~= self.dungeonId_))
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_cancel_match, isCanMatch and isMatching and curMatchingDungeonID == self.dungeonId_)
end

function Raid_mainView:OnClickDiffToggle(diff)
  if not self:checkDungeonAnyBossOpen(diff) then
    self.toggles_[self.diff_].isOn = true
    return
  end
  self.diff_ = diff
  self.curRaidDungeonData_ = self.raidDungeons_[diff]
  self.dungeonId_ = self.curRaidDungeonData_.DungeonId
  self:refreshMatchState()
  self.dungeonRow_ = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
  if self.dungeonRow_ == nil then
    return
  end
  self.uiBinder.lab_title.text = self.dungeonRow_.Name
  self.uiBinder.lab_left_title.text = self.curRaidDungeonData_.Name
  self.uiBinder.lab_tips.text = self.curRaidDungeonData_.Desc
  self.uiBinder.lab_ability.text = Lang("GSSuggest", {
    val = self.dungeonRow_.RecommendFightValue
  })
  local limitedArray = self.dungeonRow_.LimitedNum
  local minCount = limitedArray[1]
  local maxCount = limitedArray[2]
  if minCount == maxCount then
    self.uiBinder.lab_person.text = string.format(Lang("SetPeopleOnScreenNum", {val = minCount}))
  else
    self.uiBinder.lab_person.text = string.format(Lang("DungeonNumber"), minCount, maxCount)
  end
  self.uiBinder.rimg_monster:SetImage(self.curRaidDungeonData_.MonsterShowTexture)
  self.uiBinder.rimg_bg:SetImage(self.curRaidDungeonData_.DiffBgTexture)
  for diff, value in ipairs(self.nodeBossTitles_) do
    local bossId = self.curRaidDungeonData_.BossId[diff]
    value.rimg_panel:SetImage(self.curRaidDungeonData_.TitleBgTexture)
    local monsterRow = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(bossId)
    if monsterRow then
      value.lab_name.text = monsterRow.Name
    end
    local raidBossRow = Z.TableMgr.GetTable("RaidBossTableMgr").GetRow(bossId)
    local isOpen = false
    if raidBossRow then
      isOpen = Z.TimeTools.CheckIsInTimeByTimeId(raidBossRow.OpenTimerId)
    end
    if not isOpen then
      local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
      local startTime = Z.TimeTools.GetStartEndTimeByTimerId(raidBossRow.OpenTimerId)
      value.lab_num.text = Lang("WillOpenDesc", {
        time = Z.TimeFormatTools.FormatToDHMS(startTime - nowTime)
      })
    else
      local countId = self.raidVm_:GetBossCountId(bossId)
      local finishCount = Z.CounterHelper.GetOwnCount(countId)
      local totalCount = Z.CounterHelper.GetCounterLimitCount(countId)
      value.lab_num.text = Lang("RaidRewardCount", {
        val1 = totalCount - finishCount,
        val2 = totalCount
      })
    end
    self:AddAsyncClick(value.btn, function()
      local raidBossRow = Z.TableMgr.GetTable("RaidBossTableMgr").GetRow(bossId)
      if not Z.TimeTools.CheckIsInTimeByTimeId(raidBossRow.OpenTimerId) then
        bossId = self.curRaidDungeonData_.BossId[1]
      end
      self.raidVm_:OpenRaidMonsterView(self.dungeonId_, bossId)
    end)
  end
  self:refreshLoopReward(self.curRaidDungeonData_.PassAward)
end

function Raid_mainView:checkDungeonAnyBossOpen(diff)
  local dungeonData = self.raidDungeons_[diff]
  local recentStartTime = 0
  local dungeonsConfig = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonData.DungeonId)
  if not self.gotoFuncVM_.CheckFuncCanUse(dungeonsConfig.FunctionID) then
    return false
  end
  for index, bossId in ipairs(dungeonData.BossId) do
    local raidBossRow = Z.TableMgr.GetTable("RaidBossTableMgr").GetRow(bossId)
    if raidBossRow then
      if not Z.TimeTools.CheckIsInTimeByTimeId(raidBossRow.OpenTimerId) then
        local startTime = Z.TimeTools.GetStartEndTimeByTimerId(raidBossRow.OpenTimerId)
        if recentStartTime == 0 or recentStartTime > startTime then
          recentStartTime = startTime
        end
      else
        return true
      end
    end
  end
  if recentStartTime == 0 then
    return true
  else
    local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
    local date = {
      longstring = Lang("WillOpenDesc", {
        time = Z.TimeFormatTools.FormatToDHMS(recentStartTime - nowTime)
      })
    }
    local tipsParam = {date = date, str = ""}
    Z.TipsVM.ShowTips(124001, tipsParam)
    return false
  end
end

function Raid_mainView:refreshLoopReward(reward)
  local awardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(reward)
  self.rewardLoopList_:RefreshListView(awardList)
end

function Raid_mainView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.Match.MatchStateChange, self.refreshMatchState, self)
  if self.rewardLoopList_ then
    self.rewardLoopList_:UnInit()
    self.rewardLoopList_ = nil
  end
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  for diff, value in ipairs(self.toggles_) do
    value:RemoveAllListeners()
  end
end

function Raid_mainView:OnRefresh()
end

return Raid_mainView
