local Hero_dungeon_master_scoreTpl = class("Hero_dungeon_master_scoreTpl")
local MasterChallenDungeonTableMap = require("table.MasterChallenDungeonTableMap")
local titlePath = "ui/textures/hero_dungeon_master/hero_dungeon_popup_title_0"
local seasonPath = "ui/textures/hero_dungeon_master/hero_dungeon_popup_season_0"
local loopGridView = require("ui.component.loop_grid_view")
local hero_dungeon_master_score_item = require("ui.component.hero_dungeon.hero_dungeon_master_score_item")

function Hero_dungeon_master_scoreTpl:ctor(parent)
  self.parentView_ = parent
end

function Hero_dungeon_master_scoreTpl:Init(uibinder, viewData)
  self.viewData = viewData or {}
  self.uiBinder = uibinder
  self.heroDungeonMainVm_ = Z.VMMgr.GetVM("hero_dungeon_main")
  if self.viewData.isPlayer then
    self:initDpd()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, false)
    self.uiBinder.node_dpd.Ref.UIComp:SetVisible(true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, true)
    self.uiBinder.node_dpd.Ref.UIComp:SetVisible(false)
    self:refreshShare()
  end
end

function Hero_dungeon_master_scoreTpl:initDpd()
  self.uiBinder.lab_title.text = Lang("Master's Badge")
  local options_ = {}
  local showSeason = Z.GlobalDungeon.MasterHistoryScoreSeasonNum
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  for i = 1, showSeason do
    options_[i] = Lang("SeasonNum", {val = i})
  end
  self.uiBinder.node_dpd.dpd:ClearAll()
  self.uiBinder.node_dpd.dpd:AddListener(function(index)
    index = index + 1
    if index > seasonId then
      self.uiBinder.node_dpd.dpd.value = seasonId - 1
      Z.TipsVM.ShowTips(1003002)
      return
    end
    self:OnSeasonSelectChange(index)
    self.parentView_:OnSeasonSelectChange(index)
  end)
  self.uiBinder.node_dpd.dpd:AddOptions(options_)
  self.uiBinder.node_dpd.dpd.value = seasonId - 1
  self:OnSeasonSelectChange(seasonId)
end

function Hero_dungeon_master_scoreTpl:OnSeasonSelectChange(seasonId)
  local score = self.heroDungeonMainVm_.GetPlayerSeasonMasterDungeonScore(seasonId)
  local scoreText = self.heroDungeonMainVm_.GetPlayerSeasonMasterDungeonTotalScoreWithColor(score)
  self.uiBinder.lab_num.text = scoreText
  local scoreData = Z.DataMgr.Get("hero_dungeon_main_data"):GetMasterDungeonScore(seasonId)
  local data = {}
  for index, value in pairs(scoreData) do
    table.insert(data, value)
  end
  self:refreshLoop(data)
  self:refreshIcon(seasonId)
end

function Hero_dungeon_master_scoreTpl:refreshLoop(data)
  if self.loopGrid_ == nil then
    self.loopGrid_ = loopGridView.new(self.parentView_, self.uiBinder.layout_score, hero_dungeon_master_score_item, "hero_dungeon_master_score_item_tpl")
    self.loopGrid_:Init(data)
  else
    self.loopGrid_:RefreshListView(data)
  end
end

function Hero_dungeon_master_scoreTpl:refreshShare()
  self.uiBinder.lab_title.text = string.format(Lang("master_dungeon_score_title"), self.viewData.playerName)
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  if self.viewData.score then
    seasonId = self.viewData.score.seasonId
  end
  local totalScore = 0
  self.uiBinder.lab_name.text = Lang("SeasonNum", {val = seasonId})
  local data = {}
  local temp = {}
  for dungeonId, value in pairs(MasterChallenDungeonTableMap.DungeonId) do
    temp[dungeonId] = {
      score = 0,
      time = 0,
      diff = 1,
      dungeonId = dungeonId,
      masterChallengeDungeonId = value[1]
    }
  end
  if self.viewData.score and self.viewData.score.masterModeInfo then
    for dungeonId, masterModeDiffInfo in pairs(self.viewData.score.masterModeInfo) do
      for diff, dungeonInfo in pairs(masterModeDiffInfo.dungeonInfo) do
        if dungeonInfo.score > temp[dungeonId].score then
          temp[dungeonId].diff = diff
          temp[dungeonId].time = dungeonInfo.passTime
          temp[dungeonId].score = dungeonInfo.score
          temp[dungeonId].masterChallengeDungeonId = dungeonId * 100 + diff
        end
      end
    end
  end
  for _, value in pairs(temp) do
    totalScore = totalScore + value.score
    table.insert(data, value)
  end
  self.uiBinder.lab_num.text = self.heroDungeonMainVm_.GetPlayerSeasonMasterDungeonTotalScoreWithColor(totalScore)
  self:refreshLoop(data)
  self:refreshIcon(seasonId)
end

function Hero_dungeon_master_scoreTpl:refreshIcon(seasonId)
  seasonId = seasonId or Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  self.uiBinder.rimg_title:SetImage(titlePath .. seasonId)
  self.uiBinder.rimg_season:SetImage(seasonPath .. seasonId)
end

function Hero_dungeon_master_scoreTpl:UnInit()
  if self.loopGrid_ then
    self.loopGrid_:UnInit()
    self.loopGrid_ = nil
  end
end

return Hero_dungeon_master_scoreTpl
