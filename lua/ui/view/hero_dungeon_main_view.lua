local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_mainView = class("Hero_dungeon_mainView", super)
local itemClass = require("common.item_binder")
local competencyAssessView = require("ui.view.competency_assessment_sub_view")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
local MasterChallenDungeonTableMap = require("table.MasterChallenDungeonTableMap")
local loopListView = require("ui.component.loop_list_view")
local masterDiffItem = require("ui.component.hero_dungeon.master_challenge_dungeon_diff_item")
local difficultModel = {
  [1] = {
    name = Lang("BaseDifficulty"),
    unit = "btn_tab_01"
  },
  [2] = {
    name = Lang("SecondDifficulty"),
    unit = "btn_tab_02"
  },
  [3] = {
    name = Lang("MasterDifficulty"),
    unit = "btn_tab_03",
    isMaster = true
  }
}
local colorTag = {
  [1] = "FFFFFF",
  [2] = "E2E5CD"
}

function Hero_dungeon_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_main")
  self.vm = Z.VMMgr.GetVM("hero_dungeon_main")
  self.dataMgr = Z.DataMgr.Get("hero_dungeon_main_data")
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.matchVm_ = Z.VMMgr.GetVM("match")
  self.dungeonVm_ = Z.VMMgr.GetVM("dungeon")
  self.itemVM_ = Z.VMMgr.GetVM("items")
  self.capabilityAssessVM_ = Z.VMMgr.GetVM("capability_assessment")
  self.competencyAssessView_ = competencyAssessView.new()
  self.matchVm_ = Z.VMMgr.GetVM("match")
  self.matchTeamVm_ = Z.VMMgr.GetVM("match_team")
  self.matchTeamData_ = Z.DataMgr.Get("match_team_data")
  self.teamMainVm_ = Z.VMMgr.GetVM("team_main")
  self.teamData_ = Z.DataMgr.Get("team_data")
end

function Hero_dungeon_mainView:initwidgets()
  self.searchBtn_ = self.uiBinder.group_award.img_bg
  self.searchGO_ = self.uiBinder.group_award.group_search
  self.returnBtn_ = self.uiBinder.cont_panel.cont_btn_return.btn
  self.askBtn_ = self.uiBinder.btn_ask
  self.teamBtn_ = self.uiBinder.btn_team
  self.enterBtn_ = self.uiBinder.btn_go
  self.titleLabel_ = self.uiBinder.lab_title
  self.nameLabel_ = self.uiBinder.lab_name
  self.diffLabel_ = self.uiBinder.cont_panel.lab_label
  self.diff_img_label_ = self.uiBinder.cont_panel.img_label
  self.content_anim_ = self.uiBinder.anim
  self.awardTimesBG_ = self.uiBinder.group_award.group_title.img_bg
  self.awardTimesNum_ = self.uiBinder.group_award.group_title.lab_name2
  self.awardContent_ = self.uiBinder.group_award.node_content
  self.equipLevelLab_ = self.uiBinder.lab_gs1
  self.peopleLab_ = self.uiBinder.lab_gs2
  self.img_time_ = self.uiBinder.img_time
  self.limitTimeLab_ = self.uiBinder.lab_gs3
  self.completionLab_ = self.uiBinder.group_award.lab_task_completion
  self.taskContentLab_ = self.uiBinder.group_task.lab_content
  self.affixGO_ = self.uiBinder.scrollview_affix
  self.randomAffix_ = self.uiBinder.random_affix
  self.affixTipsGO_ = self.uiBinder.group_affix_tips
  self.affixItemRoot_ = self.uiBinder.content
  self.rimgBg_ = self.uiBinder.rimg_bg
  self.lab_scores_ = self.uiBinder.lab_fraction
  self.lab_scores_text_ = self.uiBinder.lab_scores
  self.lab_scores_bg_ = self.uiBinder.img_score
  self.lab_reward_title = self.uiBinder.lab_reward
  self.notRecord_ = self.uiBinder.lab_tips
  self.affix_set_ = self.uiBinder.btn_set
  self.btn_reward_ = self.uiBinder.btn_reward
  self.reward_root_ = self.uiBinder.node_reward
  self.lab_name_ = self.uiBinder.node_title_affix.lab_name
  self.img_label_ = self.uiBinder.node_title_affix.img_label
  self.red_bg_ = self.uiBinder.img_bg1
  self.rewardTitle_ = self.uiBinder.group_award.group_title.lab_name1
  self.scoreIcon_ = self.uiBinder.img_score_icon
  self.btn_week_ = self.uiBinder.btn_week
  self.btn_treasure_ = self.uiBinder.btn_treasure
  self.lab_suggest_ = self.uiBinder.lab_recommendations
  self.btnCompetencyAssess_ = self.uiBinder.btn_strength_assessment
  self.node_dungeonMultiaAward_ = self.uiBinder.node_dungeonMultiaAward
  self.btn_multiaAward_ = self.uiBinder.node_dungeonMultiaAward.btn
  self.multiaAwardOff_ = self.uiBinder.node_dungeonMultiaAward.img_off
  self.multiaAwardOn_ = self.uiBinder.node_dungeonMultiaAward.img_on
  self.matchBtn = self.uiBinder.btn_match
  self.unMatchBtn = self.uiBinder.btn_cancel_match
  self.firstNode_ = self.uiBinder.group_award.node_first
  self.firstTog_ = self.firstNode_.tog_first
  self.dropTog_ = self.firstNode_.tog_drop
  self.memberTogNode_ = self.uiBinder.node_tog
  self.digitTog_ = self.uiBinder.tog_digit
  self.teamTog_ = self.uiBinder.tog_team
end

function Hero_dungeon_mainView:initBtns()
  self:AddClick(self.searchBtn_, function()
    local awardId = 0
    if self.dataMgr.IsChellange then
      local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
      if cfgData then
        awardId = cfgData.FirstPassAward
      end
    else
      local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
      if cfgData then
        awardId = cfgData.PassAward
      end
    end
    local awardList = awardPreviewVm.GetAllAwardPreListByIds(awardId)
    awardPreviewVm.OpenRewardDetailViewByListData(awardList)
  end)
  self:AddClick(self.returnBtn_, function()
    self.content_anim_:CoroPlay(Z.DOTweenAnimType.Close, function()
      self.vm.CloseHeroView()
    end, function(err)
      logError(err)
    end)
  end)
  self:AddClick(self.uiBinder.btn_masterdungeon, function()
    self.vm.OpenMaseterScoreView()
  end)
  self:AddClick(self.btnCompetencyAssess_, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.CompetencyAssess)
    if not isOn then
      return
    end
    if self.dungeonId_ then
      self.competencyAssessView_:Active({
        dungeonId = self.dungeonId_,
        difficulty = self.curMasterDungeonDiff_,
        isMasterDungeon = self.isMasterDungeon_
      }, self.uiBinder.Trans)
    end
  end)
  self:AddClick(self.askBtn_, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(self.helpLibraryId_)
  end)
  self:AddClick(self.uiBinder.cont_panel.img_label, function()
    Z.VMMgr.GetVM("helpsys").OpenMinTips(30023, self.uiBinder.cont_panel.img_label.transform)
  end)
  self:AddClick(self.img_label_, function()
    Z.VMMgr.GetVM("helpsys").OpenMinTips(30024, self.img_label_.transform)
  end)
  self:AddClick(self.img_time_, function()
    local tab = self.dataMgr:GetChallengeScenceIdTab()
    local challengeCfg = Z.TableMgr.GetTable("SceneEventDuneonConfigTableMgr").GetRow(self.dungeonId_)
    if challengeCfg.LimitTime <= 0 then
      Z.VMMgr.GetVM("helpsys").OpenMinTips(30034, self.img_time_.transform)
    else
      Z.VMMgr.GetVM("helpsys").OpenMinTips(30031, self.img_time_.transform)
    end
  end)
  self:AddClick(self.affix_set_, function()
    local data = self.dataMgr:GetChallengeScenceIdTab()[self.nowLevel]
    if data then
      self.vm.OpenAffixPopupView(data)
    end
  end)
  self:AddClick(self.btn_reward_, function()
    local data = self.dataMgr:GetChallengeScenceIdTab()[self.nowLevel]
    if data then
      self.vm.OpenScorePopupView(data)
    end
  end)
  self:AddClick(self.teamBtn_, function()
    local teamMainVm = Z.VMMgr.GetVM("team_main")
    teamMainVm.EnterTeamTargetByDungeonId(self.dungeonId_)
  end)
  self:AddAsyncClick(self.enterBtn_, function()
    if self.toggleIsTeam_ or self.dungeonRow_ and self.dungeonRow_.SingleModeDungeonId == 0 then
      local func = function()
        self.vm.AsyncStartEnterDungeon(self.dungeonId_, nil, self.cancelSource, 2, nil, self.curMasterDungeonDiff_)
      end
      if self.dataMgr.IsChellange and not self.teamVM_.GetTeamMembersNum() then
        Z.DialogViewDataMgr:OpenNormalDialog(Lang("HeroDungeonEnterConfirm"), function()
          func()
        end)
      else
        func()
      end
    else
      local count = table.zcount(self.teamData_.TeamInfo.members)
      local selectType = 2
      local keyUuid = 0
      local func = function()
        self.vm.AsyncStartEnterDungeon(self.dungeonId_, nil, self.cancelSource, selectType, keyUuid, self.curMasterDungeonDiff_)
      end
      if not self.toggleIsTeam_ then
        local maxCount = self.dataMgr.MaxCount
        if count > maxCount then
          Z.TipsVM.ShowTips(3333)
          return
        end
        local data = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
        if data and data.SingleAiMode == 1 then
          selectType = 1
        end
      else
        local minCount = self.dataMgr.MinCount
        if count < minCount then
          local str = Lang("UnionHuntMultiNumLimit")
          Z.DialogViewDataMgr:OpenNormalDialog(str, function()
            if self.teamVM_.CheckIsInTeam() then
              if self.teamVM_.GetYouIsLeader() then
                self.teamVM_.AsyncSetTeamTargetInfo(self.teamTargetId_, self.teamData_.TeamInfo.baseInfo.desc, true, self.teamData_.TeamInfo.baseInfo.hallShow, self.cancelSource:CreateToken())
              end
            else
              local requestParam = {}
              requestParam.targetId = self.teamTargetId_
              requestParam.checkTags = {}
              requestParam.wantLeader = 1
              self.matchVm_.AsyncBeginMatchNew(E.MatchType.Team, requestParam, false, self.cancelSource:CreateToken())
              self.matchVm_.SetSelfMatchData(self.teamTargetId_, "targetId")
            end
            self.teamMainVm_.OpenTeamMainView(self.teamTargetId_)
          end)
          return
        end
      end
      func()
    end
  end)
  self:AddClick(self.btn_week_, function()
    self.vm.OpenTargetPopupView(self.dungeonId_)
  end)
  self:AddClick(self.btn_treasure_, function()
    local treasureVm = Z.VMMgr.GetVM("treasure")
    treasureVm:CheckOpenTreasureView()
  end)
  self:AddAsyncClick(self.btn_multiaAward_, function()
    self.vm.AsyncCheckAndUseMultiaItem(self.cancelSource:CreateToken())
    self:refreshDungeonMultiaAwardBtn()
  end)
  self:AddClick(self.matchBtn, function()
    if not self.toggleIsTeam_ then
      Z.TipsVM.ShowTips(1000644)
      return
    end
    self.matchVm_.RequestBeginMatch(E.MatchType.Team, self.dungeonId_, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.unMatchBtn, function()
    self.matchVm_.AsyncCancelMatch()
  end)
  self:AddClick(self.digitTog_, function(isOn)
    if not self.dungeonRow_ then
      return
    end
    if isOn then
      if not Z.ConditionHelper.CheckCondition(self.dungeonRow_.SingleAiCondition, true) then
        self.teamTog_.isOn = true
        return
      end
      if self.toggleIsTeam_ == true then
        self.toggleIsTeam_ = false
        self:refreshShowDungeon()
      end
      local isCanMatch = self.matchTeamVm_.IsShowMatchBtn(self.dungeonId_)
      self.uiBinder.Ref:SetVisible(self.teamBtn_, not isCanMatch)
      self.uiBinder.Ref:SetVisible(self.matchBtn, isCanMatch)
      self.uiBinder.Ref:SetVisible(self.unMatchBtn, false)
      self.matchBtn.IsDisabled = true
    end
  end)
  self:AddClick(self.teamTog_, function(isOn)
    if not self.dungeonRow_ then
      return
    end
    if isOn then
      if self.toggleIsTeam_ == false then
        self.toggleIsTeam_ = true
        self:refreshShowDungeon()
      end
      local isCanMatch = self.matchTeamVm_.IsShowMatchBtn(self.dungeonId_)
      local isMatching = self.matchVm_.IsMatching()
      local curMatchingDungeonId = self.matchTeamData_:GetCurMatchingDungeonId()
      self.uiBinder.Ref:SetVisible(self.teamBtn_, not isCanMatch)
      self.uiBinder.Ref:SetVisible(self.matchBtn, isCanMatch and (not isMatching or curMatchingDungeonId ~= self.dungeonId_))
      self.uiBinder.Ref:SetVisible(self.unMatchBtn, isCanMatch and isMatching and curMatchingDungeonId == self.dungeonId_)
      self.matchBtn.IsDisabled = false
    end
  end)
  self:AddClick(self.firstTog_, function(isOn)
    if not self.dungeonRow_ then
      return
    end
    if isOn and self.showFirstAward_ == false then
      self.showFirstAward_ = true
      self:challengeModeInit(self.isFlag_)
    end
  end)
  self:AddClick(self.dropTog_, function(isOn)
    if isOn and self.showFirstAward_ == true then
      self.showFirstAward_ = false
      self:challengeModeInit(self.isFlag_)
    end
  end)
end

function Hero_dungeon_mainView:initData()
  self.itemClassTab_ = {}
  self.units_ = {}
  self.unitTokens_ = {}
  self.dungeonId_ = 1011
  self.diffValue_ = 0
  self.curMasterDungeonDiff_ = 0
  self.masterDiffLoopView_ = loopListView.new(self, self.uiBinder.loop_left, masterDiffItem, "hero_dungeon_main_difficulty_tpl")
  self.masterDiffLoopView_:Init({})
end

function Hero_dungeon_mainView:OnActive()
  self:initwidgets()
  self:initData()
  self:initBtns()
  self.toggleIsTeam_ = true
  self.showFirstAward_ = false
  self.nowLevel = 1
  self:startAnimatedShow()
  self:BindEvents()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:refreshDungeonMultiaAwardBtn()
  self:challengeMode()
  self:showOrHideLeftAndTop(false)
  self.teamTog_.isOn = true
  self.dropTog_.isOn = true
end

function Hero_dungeon_mainView:challengeMode()
  self.titleLabel_.text = Lang("HeroChallenge")
  self.lastSelect_ = nil
  self.lastLevel_ = nil
  self:isChallenge(true)
  self:newShowLevel()
  self:refreshRightUi()
  self.helpLibraryId_ = 30012
end

function Hero_dungeon_mainView:isChallenge(show)
  if not show then
    self.equipLevelLab_.text = Lang("GSSuggestNoLimit")
  end
  self.uiBinder.Ref:SetVisible(self.reward_root_, show)
  self.uiBinder.node_title_affix.Ref:SetVisible(self.img_label_, show)
  self.uiBinder.Ref:SetVisible(self.affix_set_, show)
  self.uiBinder.Ref:SetVisible(self.affixGO_, show)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_lab, show)
  self.uiBinder.Ref:SetVisible(self.randomAffix_.Ref, false)
  self.rewardTitle_.text = Lang("ClearReward")
  self.uiBinder.group_award.group_title.Ref:SetVisible(self.awardTimesBG_, not show)
  self.uiBinder.group_award.group_title.Ref:SetVisible(self.awardTimesNum_, not show)
end

function Hero_dungeon_mainView:newShowLevel()
  local challengeData = self.dataMgr:GetChallengeScenceIdTab()
  for _, v in pairs(difficultModel) do
    local unit = self.uiBinder[v.unit]
    unit.Ref.UIComp:SetVisible(false)
  end
  for _, v in ipairs(challengeData) do
    local diffData = difficultModel[v.StarLevel]
    if diffData then
      local unit = self.uiBinder[diffData.unit]
      if unit then
        self:initDiffTab(unit, v, diffData)
      end
    end
  end
  self:seleLevel(self.nowLevel)
end

function Hero_dungeon_mainView:initDiffTab(unit, data, diffData)
  unit.Ref.UIComp:SetVisible(true)
  local isSelect = data.StarLevel == self.nowLevel
  unit.lab_basics_off.text = diffData.name
  unit.lab_basics_on.text = diffData.name
  unit.lab_basics_not.text = diffData.name
  unit.img_adorn_not:SetImage(data.LabelPic)
  unit.img_adorn_off:SetImage(data.LabelPic)
  unit.img_adorn_on:SetImage(data.LabelPic)
  local open, type, des = self.vm.IsUnlockDungeonId(data.DungeonId)
  unit.Ref:SetVisible(unit.node_on, isSelect)
  unit.Ref:SetVisible(unit.node_off, not isSelect)
  unit.Ref:SetVisible(unit.node_not, not open)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_difficulty, false)
  if not open then
    unit.lab_time.text = des
  end
  if data.StarLevel == self.nowLevel then
    self.lastSelect_ = unit
    self.lastLevel_ = data.StarLevel
  end
  self:AddClick(unit.btn, function()
    if self.nowLevel == data.StarLevel then
      return
    end
    local open, type, des = self.vm.IsUnlockDungeonId(data.DungeonId)
    if open then
      self:seleLevel(data.StarLevel)
      if self.lastSelect_ then
        self.lastSelect_.Ref:SetVisible(self.lastSelect_.node_on, false)
        self.lastSelect_.Ref:SetVisible(self.lastSelect_.node_off, true)
      end
      unit.Ref:SetVisible(unit.node_on, true)
      unit.Ref:SetVisible(unit.node_off, false)
      self.lastSelect_ = unit
      self.lastLevel_ = data.StarLevel
    end
  end)
end

function Hero_dungeon_mainView:OnDiffSelectChange(diff)
  self.curMasterDungeonDiff_ = diff
  self:refreshRightUi()
  self:getPlayerInfo()
  self:refreshCompetencyAssess()
end

function Hero_dungeon_mainView:initMasterDiffLoop()
  self.masterDiffLoopView_:ClearAllSelect()
  local dungeonIds = MasterChallenDungeonTableMap.DungeonId[self.dungeonId_] or {}
  self.masterDiffLoopView_:RefreshListView(dungeonIds)
  local maxDiff = self.vm.GetMasterDungeonMaxDiff(self.dungeonId_)
  local select = maxDiff + 1
  if maxDiff >= #dungeonIds then
    select = #dungeonIds
  end
  self.masterDiffLoopView_:SetSelected(select)
  self.masterDiffLoopView_:MovePanelToItemIndex(select - 2)
end

function Hero_dungeon_mainView:showRandomAffix()
  self.uiBinder.Ref:SetVisible(self.randomAffix_.Ref, true)
  self:AddClick(self.randomAffix_.btn_affix, function()
    Z.CommonTipsVM.ShowTipsTitleContent(self.affixTipsGO_.transform, Lang("HeroNormalAffixTitle"), Lang("HeroNormalAffixContext"))
  end)
end

function Hero_dungeon_mainView:challengeModeInit(isFlag)
  self.isFlag_ = isFlag
  self:awardMaxContent(isFlag, Lang("HeroChallengeTips"))
  if not isFlag then
    local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
    if dungeonData then
      local awardData = dungeonData.PassAward
      if self.isMasterDungeon_ then
        local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[self.dungeonId_][self.curMasterDungeonDiff_]
        local dungonCfg = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId)
        if dungonCfg then
          awardData = dungonCfg.PassAward
          if not self.isComplete_ and self.showFirstAward_ and #dungonCfg.FirstPassAward ~= 0 then
            awardData = dungonCfg.FirstPassAward
          end
        end
      elseif not self.isComplete_ and self.showFirstAward_ and #dungeonData.FirstPassAward ~= 0 then
        awardData = dungeonData.FirstPassAward
      end
      local awardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(awardData)
      local haveGet, clothItemId = self.vm.CheckProbabilityHaveGet(self.dungeonId_)
      if haveGet then
        local index
        for k, v in ipairs(awardList) do
          if v.awardId == clothItemId then
            index = k
          end
        end
        if index then
          table.remove(awardList, index)
        end
      end
      if awardList then
        self:createAwardItem(awardList)
      end
    end
  end
end

function Hero_dungeon_mainView:setAwardContent(num)
  self.awardTimesNum_.text = Lang("HeroDungeonAwardTimes", {
    arrval = {
      num,
      self.dataMgr:GetNormalHeroAwardCount()
    }
  })
end

function Hero_dungeon_mainView:awardMaxContent(isflag, tpsi)
  self.dataMgr.IsHaveAward = not isflag
  self.dataMgr:SetHaveAward(isflag)
  self.uiBinder.group_award.Ref:SetVisible(self.completionLab_, isflag)
  self.uiBinder.group_award.Ref:SetVisible(self.awardContent_, not isflag)
  self.uiBinder.group_award.Ref:SetVisible(self.searchGO_, false)
  self.completionLab_.text = tpsi
end

function Hero_dungeon_mainView:onAffixItemClick(affixId)
  Z.CommonTipsVM.OpenAffixTips({affixId}, self.affixTipsGO_.transform)
end

function Hero_dungeon_mainView:isLock(index)
  return true
end

function Hero_dungeon_mainView:getPlayerInfo()
  local dungeonList = Z.ContainerMgr.CharSerialize.dungeonList.completeDungeon
  local data = self.dataMgr:GetChallengeScenceIdTab()[self.nowLevel]
  local id = data.DungeonId
  if dungeonList[id] then
    if dungeonList[id].awardFlg == 1 then
      self:challengeModeInit(false)
    else
      self:challengeModeInit(false)
    end
  else
    self:challengeModeInit(false)
  end
  self.vm.ReqExtremeSpaceAffix(id, self.curMasterDungeonDiff_)
  self.rimgBg_:SetImage(data.Background)
end

function Hero_dungeon_mainView:refreshShowDungeon()
  local tab = self.dataMgr:GetChallengeScenceIdTab()
  self.dungeonId_ = tab[self.nowLevel].DungeonId
  self.dungeonRow_ = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
  if self.dungeonRow_ == nil then
    return
  end
  local isHaveSingle = self.dungeonRow_.SingleModeDungeonId ~= 0
  self.uiBinder.Ref:SetVisible(self.memberTogNode_, isHaveSingle)
  if not self.toggleIsTeam_ and isHaveSingle then
    self.dungeonId_ = self.dungeonRow_.SingleModeDungeonId
    self.showDungeonRow_ = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
  end
  self.teamTargetId_ = self.teamMainVm_.GetTargetIdByDungeonId(self.dungeonId_)
  local isChallenge = self.nowLevel == 2
  if self.nowLevel == 3 then
    self.isMasterDungeon_ = true
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_difficulty, true)
    self:initMasterDiffLoop()
  else
    self.isMasterDungeon_ = false
    self.curMasterDungeonDiff_ = 0
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_difficulty, false)
    self:refreshRightUi()
    self:getPlayerInfo()
    self:refreshCompetencyAssess()
  end
  self.lab_reward_title.text = not isChallenge and Lang("ChallengeRecord") or Lang("RatingRewards")
  self.uiBinder.Ref:SetVisible(self.btn_reward_, isChallenge)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line01, isChallenge)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line02, not isChallenge)
  self:refreshBtnChance()
  self:refreshBtnWeek()
end

function Hero_dungeon_mainView:seleLevel(len)
  self.nowLevel = len
  self.teamTog_.isOn = true
  self:refreshShowDungeon()
  self.content_anim_:Restart(Z.DOTweenAnimType.Tween_0)
end

function Hero_dungeon_mainView:refreshCompetencyAssess()
  if self.isMasterDungeon_ then
    local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[self.dungeonId_][self.curMasterDungeonDiff_]
    local dungonCfg = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId)
    if dungonCfg then
      local _, suggest = self.capabilityAssessVM_.GetAllAttrValue(dungonCfg.AssessId)
      self.lab_suggest_.text = Lang("ReviewSuggestions") .. suggest
    end
  else
    local dungonCfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
    if dungonCfg then
      local _, suggest = self.capabilityAssessVM_.GetAllAttrValue(dungonCfg.AssessId)
      self.lab_suggest_.text = Lang("ReviewSuggestions") .. suggest
    end
  end
end

function Hero_dungeon_mainView:refreshBtnChance(dungeonId)
end

function Hero_dungeon_mainView:onHeroDungeonAffixChange()
  self:createAffixItem(self.vm.GetExtremeSpaceAffix(self.dungeonId_, self.curMasterDungeonDiff_))
end

function Hero_dungeon_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:UnBindAllEvents()
  self.affixItemList_ = nil
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  self.dungeonRow_ = nil
  self.teamTog_:RemoveAllListeners()
  Z.TipsVM.CloseItemTipsView()
  Z.CommonTipsVM.CloseTipsTitleContent()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.HeroDungeonReward)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.Treasure)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.MasterScore)
  Z.VMMgr.GetVM("helpsys").CloseTitleContentBtn()
  self.competencyAssessView_:DeActive()
  if self.masterDiffLoopView_ then
    self.masterDiffLoopView_:UnInit()
    self.masterDiffLoopView_ = nil
  end
end

function Hero_dungeon_mainView:startAnimatedShow()
  self.content_anim_:Restart(Z.DOTweenAnimType.Open)
end

function Hero_dungeon_mainView:OnRefresh()
end

function Hero_dungeon_mainView:GetPrefabCacheData(key)
  if self.uiBinder.prefabcache_root == nil then
    return nil
  end
  return self.uiBinder.prefabcache_root:GetString(key)
end

function Hero_dungeon_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.HeroDungeonAffixChange, self.onHeroDungeonAffixChange, self)
  Z.EventMgr:Add(Z.ConstValue.Recommendedplay.DungeonRed, self.refreshBtnWeek, self)
  Z.EventMgr:Add(Z.ConstValue.HeroDungeonProbailityChange, self.refreshBtnChance, self)
  Z.EventMgr:Add(Z.ConstValue.CompetencyAssess.IsHideLeftView, self.showOrHideLeftAndTop, self)
  Z.EventMgr:Add(Z.ConstValue.Match.MatchStateChange, self.refreshMatchStatus, self)
end

function Hero_dungeon_mainView:UnBindAllEvents()
  Z.EventMgr:Remove(Z.ConstValue.HeroDungeonAffixChange, self.onHeroDungeonAffixChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Recommendedplay.DungeonRed, self.refreshBtnWeek, self)
  Z.EventMgr:Remove(Z.ConstValue.HeroDungeonProbailityChange, self.refreshBtnChance, self)
  Z.EventMgr:Remove(Z.ConstValue.CompetencyAssess.IsHideLeftView, self.showOrHideLeftAndTop, self)
  Z.EventMgr:Remove(Z.ConstValue.Match.MatchStateChange, self.refreshMatchStatus, self)
end

function Hero_dungeon_mainView:refreshMatchStatus()
  local isCanMatch = self.matchTeamVm_.IsShowMatchBtn(self.dungeonId_)
  local isMatching = self.matchVm_.IsMatching()
  local curMatchingDungeonID = self.matchTeamData_:GetCurMatchingDungeonId()
  self.uiBinder.Ref:SetVisible(self.teamBtn_, not isCanMatch)
  self.uiBinder.Ref:SetVisible(self.matchBtn, isCanMatch and (not isMatching or curMatchingDungeonID ~= self.dungeonId_))
  self.uiBinder.Ref:SetVisible(self.unMatchBtn, isCanMatch and isMatching and curMatchingDungeonID == self.dungeonId_)
end

function Hero_dungeon_mainView:showOrHideLeftAndTop(hide)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_left_title, not hide)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_left_topandbottom, not hide)
end

function Hero_dungeon_mainView:refreshBtnWeek()
  local showRed = false
  local targetList, groupId = self.vm.GetChallengeHeroDungeonTarget(self.dungeonId_)
  local dungeonInfo = Z.ContainerMgr.CharSerialize.challengeDungeonInfo.dungeonTargetAward[groupId]
  for k, v in ipairs(targetList) do
    if dungeonInfo and dungeonInfo.dungeonTargetProgress[v.targetId] and dungeonInfo.dungeonTargetProgress[v.targetId].awardState == E.DrawState.CanDraw then
      showRed = true
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_week_dot, showRed)
end

function Hero_dungeon_mainView:refreshRightUi()
  local dungeonRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
  if dungeonRow == nil then
    logError("DungeonsTableMgr key={0} is null", self.dungeonId_)
    return
  end
  local tab = self.dataMgr:GetChallengeScenceIdTab()
  self.nameLabel_.text = dungeonRow.Name
  self.diffValue_ = tab[self.nowLevel].BaseRatio
  self.diffLabel_.text = self.diffValue_ .. "%"
  self.taskContentLab_.text = dungeonRow.Content
  local challengeCfg = Z.TableMgr.GetTable("SceneEventDuneonConfigTableMgr").GetRow(self.dungeonId_)
  if challengeCfg.LimitTime <= 0 then
    self.limitTimeLab_.text = Lang("NoTimeLimit")
  else
    self.limitTimeLab_.text = Z.TimeFormatTools.FormatToDHMS(challengeCfg.LimitTime)
  end
  self.vm.RefreshRed(self.dungeonId_)
  local data = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
  if data == nil then
    logError("DungeonsTableMgr key={0} is null", self.dungeonId_)
    return
  end
  local score = self.vm.GetHighestScore(self.dungeonId_)
  local isScore = score and 0 < score
  self.uiBinder.Ref:SetVisible(self.lab_scores_text_, isScore)
  self.uiBinder.Ref:SetVisible(self.lab_scores_bg_, isScore)
  self.uiBinder.Ref:SetVisible(self.notRecord_, not isScore)
  if isScore then
    self.lab_scores_.text = score
    local starLevel = self.dungeonVm_.GetNowLevelByScore(score, self.dungeonVm_.GetScoreLevelTab(self.dungeonId_))
    local path = self.dungeonVm_.GetScoreIcon(starLevel)
    self.scoreIcon_:SetImage(path)
  end
  if 0 < table.zcount(data.Condition) then
    self.vm.DungeonPeopleCount(self.dungeonId_)
    self:beginDungeonTeamCount()
    local equipAttr = Z.ContainerMgr.CharSerialize.equip.equipAttr
    if equipAttr then
      self.dataMgr:SetPlayerGs(0)
    end
  end
  self.vm.SetRecommendFightValue(self.dungeonId_, self.curMasterDungeonDiff_)
  self.equipLevelLab_.text = Lang("GSSuggest", {
    val = self.dataMgr.RecommendFightValue
  })
  local firstPassAward = dungeonRow.FirstPassAward
  if self.isMasterDungeon_ then
    self.isComplete_ = self.vm.GetMasterDungeonIsComplete(self.dungeonId_, self.curMasterDungeonDiff_)
    local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[self.dungeonId_][self.curMasterDungeonDiff_]
    local masterDungonCfg = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId)
    firstPassAward = masterDungonCfg.FirstPassAward
  else
    self.isComplete_ = self.vm.CheckDungeonIsComplete(self.dungeonId_)
  end
  self.uiBinder.group_award.group_title.Ref.UIComp:SetVisible(self.isComplete_ or #firstPassAward == 0)
  if self.isComplete_ or #firstPassAward == 0 then
    self.showFirstAward_ = false
    self.dropTog_.isOn = true
  end
  self.firstNode_.Ref.UIComp:SetVisible(not self.isComplete_ and 0 < #firstPassAward)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.HeroDungeonReward, self, self.red_bg_)
  if Z.IsPCUI then
    Z.RedPointMgr.LoadRedDotItem(E.RedType.Treasure, self, self.uiBinder.reddot_root_treasure.transform)
    Z.RedPointMgr.LoadRedDotItem(E.RedType.MasterScore, self, self.uiBinder.reddot_root_master_score.transform)
  else
    Z.RedPointMgr.LoadRedDotItem(E.RedType.Treasure, self, self.uiBinder.btn_treasure.transform)
    Z.RedPointMgr.LoadRedDotItem(E.RedType.MasterScore, self, self.uiBinder.btn_masterdungeon.transform)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_masterdungeon, self.vm.CheckAnyMasterDungeonOpen())
  local isCanMatch = self.matchTeamVm_.IsShowMatchBtn(self.dungeonId_)
  local isMatching = self.matchVm_.IsMatching()
  local curMatchingDungeonID = self.matchTeamData_:GetCurMatchingDungeonId()
  self.uiBinder.Ref:SetVisible(self.teamBtn_, not isCanMatch)
  self.uiBinder.Ref:SetVisible(self.matchBtn, isCanMatch and (not isMatching or curMatchingDungeonID ~= self.dungeonId_))
  self.uiBinder.Ref:SetVisible(self.unMatchBtn, isCanMatch and isMatching and curMatchingDungeonID == self.dungeonId_)
end

function Hero_dungeon_mainView:beginDungeonTeamCount()
  local min = self.dataMgr.MinCount
  local max = self.dataMgr.MaxCount
  if min == max then
    self.peopleLab_.text = string.format(Lang("SetPeopleOnScreenNum", {val = min}))
  else
    self.peopleLab_.text = string.format(Lang("DungeonNumber"), min, max)
  end
end

function Hero_dungeon_mainView:refreshDungeonMultiaAwardBtn()
  if self.vm.IsInDungeonMultiaAward() then
    self.node_dungeonMultiaAward_.Ref.UIComp:SetVisible(true)
  else
    self.node_dungeonMultiaAward_.Ref.UIComp:SetVisible(false)
  end
end

function Hero_dungeon_mainView:createAffixItem(affixList, isRandom)
  self.AffixArray_ = affixList
  if not affixList or #affixList <= 0 then
    self.uiBinder.Ref:SetVisible(self.affixGO_, false)
    self.uiBinder.node_title_affix.lab_label.text = "+0%"
    self.uiBinder.lab_digit.text = self.diffValue_ .. "%"
    return
  end
  if not isRandom then
    local affixValue = self.vm.GetChalleAffixValue(self.dungeonId_, affixList)
    local allValue = affixValue + self.diffValue_
    local totalStr
    if 0 < allValue then
      totalStr = Z.RichTextHelper.ApplyStyleTag(allValue .. "%", E.TextStyleTag.White)
    else
      totalStr = Z.RichTextHelper.ApplyStyleTag(allValue .. "%", E.TextStyleTag.Red)
    end
    self.uiBinder.node_title_affix.lab_label.text = (0 < affixValue and "+" .. affixValue or affixValue) .. "%"
    self.uiBinder.lab_digit.text = totalStr
  end
  self.uiBinder.Ref:SetVisible(self.affixGO_, true)
  local prefabPath = self:GetPrefabCacheData("c_com_affix_tpl")
  if prefabPath == nil then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.affixItemList_ = self.affixItemList_ or {}
    local affix = {}
    if not isRandom then
      local tab = self.dataMgr:GetChallengeScenceIdTab()
      affix = tab[self.nowLevel].Affix
    end
    local affixCfgs = Z.TableMgr.GetTable("AffixTableMgr")
    local index = 0
    for i = 1, #affixList do
      local cfg = affixCfgs.GetRow(affixList[i])
      if cfg and cfg.IsShowUI then
        index = index + 1
        local item = self.affixItemList_[index]
        if not item then
          item = self:AsyncLoadUiUnit(prefabPath, "affixitem" .. index, self.affixItemRoot_)
          item.Ref:SetVisible(item.img_clock, self.vm.IsRegularAffix(affix, affixList[i]))
          self.affixItemList_[index] = item
        end
        self:AddClick(item.btn_affix, function()
          self:onAffixItemClick(affixList[i])
        end)
        item.Ref:SetVisible(item.img_key, false)
        item.Ref:SetVisible(item.node_root, true)
        item.img_affix:SetImage(cfg.Icon)
      end
    end
    for i = index + 1, #self.affixItemList_ do
      local item_ = self.affixItemList_[i]
      if item_ then
        item_.Ref:SetVisible(item_.node_root, false)
      end
    end
  end)()
end

function Hero_dungeon_mainView:createAwardItem(awardList)
  local prefabPath = self:GetPrefabCacheData("item")
  for unitName, value in pairs(self.units_) do
    self:RemoveUiUnit(unitName)
  end
  self.units_ = {}
  for tokenName, token in pairs(self.unitTokens_) do
    Z.CancelSource.ReleaseToken(token)
  end
  self.unitTokens_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    for key, value in pairs(awardList) do
      local itemName = "hero_award_item" .. key
      local token = self.cancelSource:CreateToken()
      self.unitTokens_[itemName] = token
      local item = self:AsyncLoadUiUnit(prefabPath, itemName, self.awardContent_, token)
      self.units_[itemName] = item
      self.itemClassTab_[itemName] = itemClass.new(self)
      local itemData = {
        uiBinder = item,
        configId = value.awardId,
        isSquareItem = true,
        PrevDropType = value.PrevDropType,
        HideTag = true,
        dungeonId = self.dungeonId_,
        isShowFirstNode = self.showFirstAward_
      }
      itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(value)
      self.itemClassTab_[itemName]:Init(itemData)
    end
  end)()
end

return Hero_dungeon_mainView
