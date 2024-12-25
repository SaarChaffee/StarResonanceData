local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_mainView = class("Hero_dungeon_mainView", super)
local itemClass = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
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
    name = Lang("EpicDifficulty"),
    unit = "btn_tab_03"
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
  self.dungeonVm_ = Z.VMMgr.GetVM("dungeon")
  self.itemVM_ = Z.VMMgr.GetVM("items")
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
  self.btn_chance_binder_ = self.uiBinder.btn_chance
end

function Hero_dungeon_mainView:OnActive()
  self:initwidgets()
  self:startAnimatedShow()
  self.itemClassTab_ = {}
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:BindEvents()
  self.dungeonId_ = 1011
  self.diffValue_ = 0
  self:AddClick(self.searchBtn_, function()
    local awardId = 0
    if self.dataMgr.IsChellange then
      local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
      if cfgData then
        awardId = cfgData.FirstPassAward[1]
      end
    else
      local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
      if cfgData then
        awardId = cfgData.PassAward[1]
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
    if tab[self.nowLevel].LimitTime > 0 then
      Z.VMMgr.GetVM("helpsys").OpenMinTips(30031, self.img_time_.transform)
    else
      Z.VMMgr.GetVM("helpsys").OpenMinTips(30034, self.img_time_.transform)
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
    Z.VMMgr.GetVM("team_main").EnterTeamTargetByDungeonId(self.dungeonId_)
  end)
  self:AddAsyncClick(self.enterBtn_, function()
    local func = function()
      self.vm.AsyncStartEnterDungeon(self.dungeonId_, nil, self.cancelSource)
    end
    if self.dataMgr.IsChellange and not self.teamVM_.GetTeamMembersNum() then
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("HeroDungeonEnterConfirm"), function()
        func()
        Z.DialogViewDataMgr:CloseDialogView()
      end)
    else
      func()
    end
  end)
  self:AddClick(self.btn_week_, function()
    self.vm.OpenTargetPopupView(self.dungeonId_)
  end)
  self.nowLevel = 1
  self:challengeMode()
end

function Hero_dungeon_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.HeroDungeonAffixChange, self.onHeroDungeonAffixChange, self)
  Z.EventMgr:Add(Z.ConstValue.Recommendedplay.DungeonRed, self.refreshBtnWeek, self)
  Z.EventMgr:Add(Z.ConstValue.HeroDungeonProbailityChange, self.refreshBtnChance, self)
end

function Hero_dungeon_mainView:UnBindAllEvents()
  Z.EventMgr:Remove(Z.ConstValue.HeroDungeonAffixChange, self.onHeroDungeonAffixChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Recommendedplay.DungeonRed, self.refreshBtnWeek, self)
  Z.EventMgr:Remove(Z.ConstValue.HeroDungeonProbailityChange, self.refreshBtnChance, self)
end

function Hero_dungeon_mainView:challengeMode()
  self.titleLabel_.text = Lang("HeroChallenge")
  self.lastSelect_ = nil
  self.lastLevel_ = nil
  self:isChallenge(true)
  self:newShowLevel()
  self:isSatisfy()
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

function Hero_dungeon_mainView:isShowTeamBtn()
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

function Hero_dungeon_mainView:isSatisfy()
  local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr")
  local tab = self.dataMgr:GetChallengeScenceIdTab()
  self.dungeonId_ = tab[self.nowLevel].DungeonId
  self.vm.RefreshRed(self.dungeonId_)
  local data = dungeonData.GetRow(self.dungeonId_)
  if data == nil then
    logError("DungeonsTableMgr key={0} is null", self.dungeonId_)
    return
  end
  self.nameLabel_.text = data.Name
  self.diffValue_ = tab[self.nowLevel].BaseRatio
  self.diffLabel_.text = self.diffValue_ .. "%"
  self:setTaskExplain(data.Content)
  local challengeCfg = Z.TableMgr.GetTable("SceneEventDuneonConfigTableMgr").GetRow(self.dungeonId_)
  if challengeCfg.LimitTime <= 0 then
    self.limitTimeLab_.text = Lang("NoTimeLimit")
  else
    self.limitTimeLab_.text = Z.TimeTools.FormatToDHM(challengeCfg.LimitTime)
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
  self.vm.SetRecommendFightValue(self.dungeonId_)
  self.equipLevelLab_.text = Lang("GSSuggest", {
    val = self.dataMgr.RecommendFightValue
  })
  Z.RedPointMgr.LoadRedDotItem(E.RedType.HeroDungeonReward, self, self.red_bg_)
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

function Hero_dungeon_mainView:showRandomAffix()
  self.uiBinder.Ref:SetVisible(self.randomAffix_.Ref, true)
  self:AddClick(self.randomAffix_.btn_affix, function()
    Z.CommonTipsVM.ShowTipsTitleContent(self.affixTipsGO_.transform, Lang("HeroNormalAffixTitle"), Lang("HeroNormalAffixContext"))
  end)
end

function Hero_dungeon_mainView:challengeModeInit(isflag)
  self:awardMaxContent(isflag, Lang("HeroChallengeTips"))
  if not isflag then
    local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
    if dungeonData then
      local awardData = dungeonData.PassAward
      local awardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(awardData[1])
      local haveGet, clothItemId = self.vm.CheckProbabilityHaveGet(self.dungeonId_)
      if haveGet then
        local index
        for k, v in ipairs(awardList) do
          if v.awardId == clothItemId then
            index = k
          end
        end
        table.remove(awardList, index)
      end
      if awardList then
        self:creatAwardItem(awardList)
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

function Hero_dungeon_mainView:setTaskExplain(content)
  self.taskContentLab_.text = content
end

function Hero_dungeon_mainView:creatAwardItem(awardList)
  local prefabPath = self:GetPrefabCacheData("item")
  Z.CoroUtil.create_coro_xpcall(function()
    for key, value in pairs(awardList) do
      local itemName = "hero_award_item" .. key
      local item = self:AsyncLoadUiUnit(prefabPath, itemName, self.awardContent_)
      self.itemClassTab_[itemName] = itemClass.new(self)
      local itemData = {
        uiBinder = item,
        configId = value.awardId,
        isSquareItem = true,
        PrevDropType = value.PrevDropType,
        HideTag = true,
        dungeonId = self.dungeonId_
      }
      itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(value)
      self.itemClassTab_[itemName]:Init(itemData)
    end
  end)()
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
    for i = 1, #affixList do
      local index = i
      local item = self.affixItemList_[index]
      if not item then
        item = self:AsyncLoadUiUnit(prefabPath, "affixitem" .. index, self.affixItemRoot_)
        item.Ref:SetVisible(item.img_clock, self.vm.IsRegularAffix(affix, affixList[i]))
        self.affixItemList_[index] = item
        self:AddClick(item.btn_affix, function()
          self:onAffixItemClick(index)
        end)
      end
      item.Ref:SetVisible(item.img_key, false)
      local cfg = affixCfgs.GetRow(affixList[i])
      if cfg then
        item.Ref:SetVisible(item.node_root, true)
        item.img_affix:SetImage(cfg.Icon)
      else
        item.Ref:SetVisible(item.node_root, false)
      end
    end
    for i = #affixList + 1, #self.affixItemList_ do
      local item_ = self.affixItemList_[i]
      if item_ then
        item_.Ref:SetVisible(item_.node_root, false)
      end
    end
  end)()
end

function Hero_dungeon_mainView:onAffixItemClick(index)
  Z.CommonTipsVM.OpenAffixTips({
    self.AffixArray_[index]
  }, self.affixTipsGO_.transform)
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
  self.vm.ReqExtremeSpaceAffix(id)
  self.rimgBg_:SetImage(data.Background)
end

function Hero_dungeon_mainView:seleLevel(len)
  self.nowLevel = len
  self:isSatisfy()
  self:getPlayerInfo()
  local isChallenge = self.nowLevel == 2
  self.lab_reward_title.text = not isChallenge and Lang("ChallengeRecord") or Lang("RatingRewards")
  self.uiBinder.Ref:SetVisible(self.btn_reward_, isChallenge)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line01, isChallenge)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line02, not isChallenge)
  self:refreshBtnChance()
  self:refreshBtnWeek()
  self.content_anim_:Restart(Z.DOTweenAnimType.Tween_0)
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

function Hero_dungeon_mainView:refreshBtnChance(dungeonId)
  local _, buffCount, maxBuffCount, clothItemId, _ = self.vm.GetChallengeHeroDungeonProbability(self.dungeonId_)
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(clothItemId)
  if itemCfg then
    local itemVM = Z.VMMgr.GetVM("items")
    local iconPath = itemVM.GetItemIcon(clothItemId)
    if iconPath then
      self.btn_chance_binder_.img_icon:SetImage(iconPath)
    end
    self.btn_chance_binder_.img_bg:SetImage(Z.ConstValue.QualityImgRoundBg .. itemCfg.Quality)
  end
  local haveGet = self.vm.CheckProbabilityHaveGet(self.dungeonId_)
  self.btn_chance_binder_.Ref:SetVisible(self.btn_chance_binder_.lab_haveget, haveGet)
  self.btn_chance_binder_.Ref:SetVisible(self.btn_chance_binder_.img_get, haveGet)
  self.btn_chance_binder_.Ref:SetVisible(self.btn_chance_binder_.node_lab, not haveGet)
  self.btn_chance_binder_.img_bg_group.alpha = haveGet and 0.4 or 1
  self.vm.SetProbabilityCountUI(buffCount, self.btn_chance_binder_)
  self.btn_chance_binder_.btn_chance:RemoveAllListeners()
  if not haveGet then
    self:AddClick(self.btn_chance_binder_.btn_chance, function()
      self.vm.OpenProbabilityPopup(self.dungeonId_)
    end)
  end
end

function Hero_dungeon_mainView:onHeroDungeonAffixChange()
  self:createAffixItem(self.vm.GetExtremeSpaceAffix(self.dungeonId_))
end

function Hero_dungeon_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:UnBindAllEvents()
  self.affixItemList_ = nil
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  Z.TipsVM.CloseItemTipsView()
  Z.CommonTipsVM.CloseTipsTitleContent()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.HeroDungeonReward)
  Z.VMMgr.GetVM("helpsys").CloseTitleContentBtn()
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

return Hero_dungeon_mainView
