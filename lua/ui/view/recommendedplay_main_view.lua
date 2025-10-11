local UI = Z.UI
local super = require("ui.ui_view_base")
local Recommendedplay_mainView = class("Recommendedplay_mainView", super)
local loopScrollRect_ = require("ui.component.loop_list_view")
local seasonAwardItem = require("ui.component.season.seasaon_activity_award_loop_item")
local secondLoopItem = require("ui.component.recommendedplay.recommendedplay_second_loop_item")
local threeLoopItem = require("ui.component.recommendedplay.recommendedplay_three_loop_item")

function Recommendedplay_mainView:ctor()
  self.uiBinder = nil
  if Z.IsPCUI then
    Z.UIConfig.recommendedplay_main.PrefabPath = "recommendedplay/recommendedplay_main_pc"
  else
    Z.UIConfig.recommendedplay_main.PrefabPath = "recommendedplay/recommendedplay_main"
  end
  super.ctor(self, "recommendedplay_main")
  self.recommendedPlayData_ = Z.DataMgr.Get("recommendedplay_data")
  self.recommendedPlayVM_ = Z.VMMgr.GetVM("recommendedplay")
  self.awardpreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.quickJumpVM_ = Z.VMMgr.GetVM("quick_jump")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.worldBossVM_ = Z.VMMgr.GetVM("world_boss")
  self.unionTaskVM_ = Z.VMMgr.GetVM("union_task")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.itemVM_ = Z.VMMgr.GetVM("items")
  self.hero_dungeon_mainVM_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.assistFightVM_ = Z.VMMgr.GetVM("assist_fight")
  self.userSupportVM_ = Z.VMMgr.GetVM("user_support")
  self.heroDungeonMainVM_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.subviews_ = {
    [1] = require("ui/view/play_award_sub_view").new(),
    [2] = require("ui/view/play_lab_info_sub_view").new(),
    [3] = require("ui/view/play_time_sub_view").new()
  }
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
end

function Recommendedplay_mainView:initUiBinders()
  self.secondLoopList_ = self.uiBinder.scrollview_tab_2
  self.uiDepth_ = self.uiBinder.Ref.UIComp.UIDepth
  self.nodeUI_ = self.uiBinder.node_ui
  self.rimgUiDepth_ = self.uiBinder.rimg_uidepth
end

function Recommendedplay_mainView:initBtns()
  self:AddClick(self.uiBinder.node_title_close.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_service, self.userSupportVM_.CheckValid(E.UserSupportType.Activity))
  self:AddClick(self.uiBinder.btn_service, function()
    self.userSupportVM_.OpenUserSupportWebView(E.UserSupportType.Activity)
  end)
  self:AddClick(self.uiBinder.node_title_close.btn_ask, function()
    self.helpsysVM_.OpenFullScreenTipsView(30027)
  end)
  self:AddAsyncClick(self.uiBinder.btn_schedule, function()
    local funcVM = Z.VMMgr.GetVM("gotofunc")
    if not funcVM.FuncIsOn(E.FunctionID.WorldBoss) then
      return
    end
    local serverTimeData = self.recommendedPlayData_:GetServerData(E.SeasonActFuncType.Recommend, self.curRecommendedConfig_.Id)
    if serverTimeData == nil then
      self.worldBossVM_:OpenWorldBossScheduleView()
    else
      local nowTimeSec = Z.TimeTools.Now() / 1000
      if nowTimeSec < serverTimeData.startTimestamp or nowTimeSec > serverTimeData.endTimestamp then
        Z.TipsVM.ShowTipsLang(16002047)
        return
      else
        self.worldBossVM_:OpenWorldBossScheduleView()
      end
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_shop, function()
    self.worldBossVM_:OpenWorldBossScoreView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_goonce.btn, function()
    if self.curRecommendedConfig_ then
      if self.curRecommendedConfig_.FunctionId == E.FunctionID.WorldBoss and self.recommendedPlayVM_.CheckRedById(self.curRecommendedConfig_.Id) then
        local worldBossData = Z.DataMgr.Get("world_boss_data")
        worldBossData:SetRecommendRedChecked(true)
        Z.EventMgr:Dispatch(Z.ConstValue.WorldBoss.GetWorldBossInfoCall)
        self:refreshRedDot(true)
      end
      local isShowRedInfo = false
      local leisureActivityConfig = self.recommendedPlayData_:GetRecommendedPlayConfigByFunctionId(E.FunctionID.LeisureActivities)
      if self.curRecommendedConfig_.ParentId[1] ~= nil and self.curRecommendedConfig_.ParentId[1] == leisureActivityConfig.Id then
        isShowRedInfo = false
      else
        isShowRedInfo = self.recommendedPlayVM_.CheckRedById(self.curRecommendedConfig_.Id)
      end
      self.quickJumpVM_.DoJumpByConfigParam(self.curRecommendedConfig_.QuickJumpType, self.curRecommendedConfig_.QuickJumpParam, {
        DynamicFlagName = self.curRecommendedConfig_.Name,
        isShowRedInfo = isShowRedInfo
      })
    end
  end)
  self:AddClick(self.uiBinder.btn_week, function()
    if self.curRecommendedConfig_ and self.curRecommendedConfig_.RelatedDungeonId and self.curRecommendedConfig_.RelatedDungeonId ~= 0 then
      self.hero_dungeon_mainVM_.OpenTargetPopupView(self.curRecommendedConfig_.RelatedDungeonId)
    end
  end)
  self:AddClick(self.uiBinder.btn_treasure, function()
    local treasureVm = Z.VMMgr.GetVM("treasure")
    treasureVm:CheckOpenTreasureView()
  end)
  self:AddClick(self.uiBinder.btn_master_score, function()
    Z.VMMgr.GetVM("hero_dungeon_main").OpenMaseterScoreView()
  end)
  self:AddAsyncClick(self.uiBinder.node_dungeonMultiaAward.btn, function()
    self.heroDungeonMainVM_.AsyncCheckAndUseMultiaItem(self.cancelSource:CreateToken())
    self:refreshDungeonMultiaAwardBtn()
  end)
  self:AddAsyncClick(self.uiBinder.btn_friendship, function()
    Z.VMMgr.GetVM("shop").OpenShopView(E.FunctionID.FriendShipShop)
  end)
  self:AddAsyncClick(self.uiBinder.btn_viewguide, function()
    self.helpsysVM_.OpenMulHelpSysView(self.curRecommendedConfig_.HelpId)
  end)
end

function Recommendedplay_mainView:initDatas()
  self.selectFirstTag_ = nil
  self.selectSecondTag_ = nil
  self.selectThirdTag_ = nil
  self.curRecommendedConfig_ = nil
  self.firstTagUnits_ = {}
  self.secondTagUnits_ = {}
  self.thirdTagUnits_ = {}
  self.curSubView_ = nil
  self.seasonActTableMgr_ = Z.TableMgr.GetTable("SeasonActTableMgr")
end

function Recommendedplay_mainView:initUi()
  local functionConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.SeasonActivity)
  if functionConfig then
    self.uiBinder.node_title_close.lab_title.text = functionConfig.Name
  else
    self.uiBinder.node_title_close.lab_title.text = ""
  end
  self.secondLoopListView_ = loopScrollRect_.new(self, self.secondLoopList_)
  self.secondLoopListView_:SetGetItemClassFunc(function(data)
    if #data.ParentId == 0 then
      return secondLoopItem
    else
      return threeLoopItem
    end
  end)
  self.secondLoopListView_:SetGetPrefabNameFunc(function(data)
    if Z.IsPCUI then
      if #data.ParentId == 0 then
        return "play_tab_two_tpl_pc"
      else
        return "play_three_tpl_pc"
      end
    elseif #data.ParentId == 0 then
      return "play_tab_two_tpl"
    else
      return "play_three_tpl"
    end
  end)
  self.secondLoopListView_:Init({})
  if Z.IsPCUI then
    self.seasonAwardScrollRect_ = loopScrollRect_.new(self, self.uiBinder.loop_item, seasonAwardItem, "com_item_square_8_pc")
  else
    self.seasonAwardScrollRect_ = loopScrollRect_.new(self, self.uiBinder.loop_item, seasonAwardItem, "com_item_square_8")
  end
  self.seasonAwardScrollRect_:Init({})
  self:loadFirstTag()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.WorldBossScoreRed, self, self.uiBinder.rect_shop)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.WorldBossProgressRed, self, self.uiBinder.rect_schedule)
  if Z.IsPCUI then
    Z.RedPointMgr.LoadRedDotItem(E.RedType.Treasure, self, self.uiBinder.reddot_root_treasure.transform)
    Z.RedPointMgr.LoadRedDotItem(E.RedType.MasterScore, self, self.uiBinder.reddot_root_master_score.transform)
  else
    Z.RedPointMgr.LoadRedDotItem(E.RedType.Treasure, self, self.uiBinder.btn_treasure.transform)
    Z.RedPointMgr.LoadRedDotItem(E.RedType.MasterScore, self, self.uiBinder.btn_master_score.transform)
  end
end

function Recommendedplay_mainView:OnActive()
  Z.AudioMgr:Play("UI_Menu_Recommend_Open")
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initDatas()
  self:initUiBinders()
  self:SetDepth()
  self:initBtns()
  self:initUi()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  Z.EventMgr:Add(Z.ConstValue.Recommendedplay.ViewRedRefresh, self.refreshRedDot, self)
  Z.EventMgr:Add(Z.ConstValue.HeroDungeonProbailityChange, self.refreshBtnChance, self)
end

function Recommendedplay_mainView:SetDepth()
  self.uiDepth_:AddChildDepth(self.nodeUI_)
  self.uiDepth_:AddChildDepth(self.rimgUiDepth_)
end

function Recommendedplay_mainView:loadFirstTag()
  Z.CoroUtil.create_coro_xpcall(function()
    local firstTags = self.recommendedPlayData_:GetAllFirstTags()
    local tempFirstTags = {}
    local tempIndex = 0
    local mgr = Z.TableMgr.GetTable("SeasonActTypeTableMgr")
    for _, type in pairs(firstTags) do
      tempIndex = tempIndex + 1
      tempFirstTags[tempIndex] = mgr.GetRow(type)
    end
    table.sort(tempFirstTags, function(a, b)
      return a.sort < b.sort
    end)
    for _, typeConfig in ipairs(tempFirstTags) do
      local path = ""
      if Z.IsPCUI then
        path = self.uiBinder.uiprefab_cache:GetString("firsttag_pc")
      else
        path = self.uiBinder.uiprefab_cache:GetString("firsttag")
      end
      local name = "firsttag_" .. typeConfig.Id
      local unit = self:AsyncLoadUiUnit(path, name, self.uiBinder.layout_first_tab)
      if unit then
        unit.tog_tab_select.group = self.uiBinder.tog_group
        unit.tog_tab_select:RemoveAllListeners()
        unit.tog_tab_select:AddListener(function(isOn)
          self.commonVM_.CommonPlayTogAnim(unit.anim_tog, self.cancelSource:CreateToken())
          if isOn then
            self:selectFirstTag(typeConfig.Id)
          end
        end, true)
        unit.img_on:SetImage(typeConfig.Icon)
        unit.img_off:SetImage(typeConfig.Icon)
        unit.lab_name.text = typeConfig.TypeDes
        self.firstTagUnits_[typeConfig.Id] = unit
      end
    end
    if self.viewData then
      self:selectRecommended(self.viewData, true)
    else
      self:selectFirstTag(tempFirstTags[1].Id)
    end
    if self.firstTagUnits_[self.selectFirstTag_] then
      self.firstTagUnits_[self.selectFirstTag_].tog_tab_select.isOn = true
    end
  end)()
end

function Recommendedplay_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.selectFirstTag_ = nil
  self.selectSecondTag_ = nil
  self.selectThirdTag_ = nil
  self.curRecommendedConfig_ = nil
  Z.EventMgr:Remove(Z.ConstValue.Recommendedplay.ViewRedRefresh, self.refreshRedDot, self)
  Z.EventMgr:Remove(Z.ConstValue.HeroDungeonProbailityChange, self.refreshBtnChance, self)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.WorldBossScoreRed)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.WorldBossProgressRed)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.Treasure)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.MasterScore)
  for _, unit in ipairs(self.thirdTagUnits_) do
    self:RemoveUiUnit(unit.name)
  end
  self.thirdTagUnits_ = {}
  for _, unit in ipairs(self.secondTagUnits_) do
    self:RemoveUiUnit(unit.name)
  end
  self.secondTagUnits_ = {}
  if self.curSubView_ ~= nil then
    self.curSubView_:DeActive()
    self.curSubView_ = nil
  end
  if self.secondLoopListView_ then
    self.secondLoopListView_:UnInit()
    self.secondLoopListView_ = nil
  end
  self.seasonAwardScrollRect_:UnInit()
  self.seasonAwardScrollRect_ = nil
  self.uiDepth_:RemoveChildDepth(self.rimgUiDepth_)
  self.uiDepth_:RemoveChildDepth(self.nodeUI_)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect)
  self.uiBinder.node_effect:ReleseEffGo()
end

function Recommendedplay_mainView:GetCacheData()
  if self.curRecommendedConfig_ then
    return self.curRecommendedConfig_.Id
  end
  return self.recommendedPlayData_:GetDefaultSelect()
end

function Recommendedplay_mainView:selectFirstTag(tag)
  if self.selectFirstTag_ == tag then
    return
  end
  local secondTags = self.recommendedPlayData_:GetSecondTagsByType(tag)
  table.sort(secondTags, Recommendedplay_mainView.tagsSort)
  self:selectRecommended(secondTags[1].Id, true, tag)
end

function Recommendedplay_mainView:refreshLoopItem()
  local secondTags = self.recommendedPlayData_:GetSecondTagsByType(self.selectFirstTag_)
  table.sort(secondTags, Recommendedplay_mainView.tagsSort)
  local thirdTags = self.recommendedPlayData_:GetThirdTagsById(self.selectSecondTag_)
  local config = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(self.selectSecondTag_)
  if thirdTags and config and config.FunctionId ~= E.FunctionID.LeisureActivities then
    table.sort(thirdTags, Recommendedplay_mainView.tagsSort)
  end
  local selectedSecondIndex = 1
  self.selectedThirdIndex_ = nil
  for index, row in ipairs(secondTags) do
    if row.Id == self.selectSecondTag_ then
      if thirdTags then
        for i = #thirdTags, 1, -1 do
          table.insert(secondTags, index + 1, thirdTags[i])
          if self.selectThirdTag_ == thirdTags[i].Id then
            self.selectedThirdIndex_ = index + i
          end
        end
      end
      selectedSecondIndex = index
      break
    end
  end
  if secondTags then
    self.secondLoopListView_:RefreshListView(secondTags)
    self.secondLoopListView_:SetSelected(selectedSecondIndex)
    if self.selectedThirdIndex_ then
      self.secondLoopListView_:SetSelected(self.selectedThirdIndex_)
    end
  end
end

function Recommendedplay_mainView:selectSecondTag(tag)
  local thirdTags = self.recommendedPlayData_:GetThirdTagsById(tag)
  if thirdTags then
    self:selectRecommended(thirdTags[1].Id, true, self.selectFirstTag_)
  else
    self:selectRecommended(tag, true, self.selectFirstTag_)
  end
end

function Recommendedplay_mainView:selectThreeTag(tag, index)
  self.selectThirdTag_ = tag
  self:selectRecommended(tag, false, self.selectFirstTag_)
  self.selectedThirdIndex_ = index
end

function Recommendedplay_mainView:selectRecommended(id, isRefreshLoop, selectFirstTag)
  local tempRecommendedPlayConfig = self.seasonActTableMgr_.GetRow(id)
  if tempRecommendedPlayConfig == nil then
    return
  end
  if tempRecommendedPlayConfig.ParentId == nil or #tempRecommendedPlayConfig.ParentId == 0 then
    local tempThirdTags = self.recommendedPlayData_:GetThirdTagsById(tempRecommendedPlayConfig.Id)
    if tempThirdTags ~= nil then
      tempRecommendedPlayConfig = tempThirdTags[1]
    end
  end
  self.curRecommendedConfig_ = tempRecommendedPlayConfig
  if selectFirstTag then
    self.selectFirstTag_ = selectFirstTag
  else
    self.selectFirstTag_ = self.curRecommendedConfig_.Type[1]
  end
  if self.curRecommendedConfig_.ParentId and #self.curRecommendedConfig_.ParentId ~= 0 then
    self.selectSecondTag_ = self.curRecommendedConfig_.ParentId[1]
    self.selectThirdTag_ = self.curRecommendedConfig_.Id
  else
    self.selectSecondTag_ = self.curRecommendedConfig_.Id
    self.selectThirdTag_ = nil
  end
  if isRefreshLoop then
    self:refreshLoopItem()
  end
  self:refreshInfo()
  self:refreshSub()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
end

function Recommendedplay_mainView:refreshInfo()
  if self.curRecommendedConfig_ == nil then
    return
  end
  if self.curRecommendedConfig_.FunctionId ~= E.FunctionID.WorldBoss then
    self.uiBinder.rimg_secene_picture:SetImage(self.curRecommendedConfig_.BackGroundPic)
  end
  local parentRecommendedConfig
  if self.curRecommendedConfig_.ParentId and #self.curRecommendedConfig_.ParentId ~= 0 then
    parentRecommendedConfig = self.seasonActTableMgr_.GetRow(self.curRecommendedConfig_.ParentId[1])
  end
  local awardList = self:checkIsAssistFight(self.curRecommendedConfig_.FunctionId)
  self.seasonAwardScrollRect_:RefreshListView(awardList, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_schedule, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_shop, false)
  self.uiBinder.btn_chance.Ref.UIComp:SetVisible(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_week, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_treasure, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_master_score, false)
  self.uiBinder.node_dungeonMultiaAward.Ref.UIComp:SetVisible(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_surplusetime, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_friendship, false)
  if self.curRecommendedConfig_.FunctionId == E.FunctionID.WorldEvent then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_surplusetime, true)
    self.uiBinder.lab_surplusetime.text = Lang("WorldQuestInteractiveCanAccept") .. Z.ContainerMgr.CharSerialize.worldEventMap.acceptCount
  elseif self.curRecommendedConfig_.FunctionId == E.FunctionID.UnionTask then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_surplusetime, true)
    local count = self.recommendedPlayVM_.GetRecommendSurpluseCount(self.curRecommendedConfig_)
    self.uiBinder.lab_surplusetime.text = Lang("DailyRemainingAttempts", {val1 = count, val2 = 1})
  elseif self.curRecommendedConfig_.FunctionId == E.FunctionID.ExploreMonsterElite then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_surplusetime, true)
    local count = self.itemVM_.GetItemTotalCount(Z.MonsterHunt.MonsterHuntEliteBootyKeyId)
    self.uiBinder.lab_surplusetime.text = Lang("RecommendedplayExploreMonsterSurpluseTime", {val = count})
  elseif self.curRecommendedConfig_.FunctionId == E.FunctionID.ExploreMonsterBoss then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_surplusetime, true)
    local count = self.itemVM_.GetItemTotalCount(Z.MonsterHunt.MonsterHuntBossBootyKeyId)
    self.uiBinder.lab_surplusetime.text = Lang("RecommendedplayExploreMonsterSurpluseTime", {val = count})
  elseif self.curRecommendedConfig_.FunctionId == E.FunctionID.WorldBoss then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_surplusetime, true)
    local countID = Z.WorldBoss.WorldBossAwardCountId
    local limtCount = Z.CounterHelper.GetCounterLimitCount(countID)
    local normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(countID, limtCount)
    local langString = Lang("WorldBossAward")
    self.uiBinder.lab_surplusetime.text = langString .. normalAwardCount .. "/" .. limtCount
    local switchVm = Z.VMMgr.GetVM("switch")
    local isWorldBossScheduleOpen = switchVm.CheckFuncSwitch(E.FunctionID.WorldBossSchedule)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_schedule, isWorldBossScheduleOpen)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_shop, true)
    local isWorldBossOpen = switchVm.CheckFuncSwitch(E.FunctionID.WorldBoss)
    if isWorldBossOpen then
      Z.CoroUtil.create_coro_xpcall(function()
        self.worldBossVM_:AsyncGetWorldBossInfo(self.cancelSource:CreateToken(), function(ret)
          local bossSwitchID = ret.bossCfgId
          local worldBossSwitchTableRow = Z.TableMgr.GetTable("WorldBossSwitchTableMgr").GetRow(bossSwitchID)
          if worldBossSwitchTableRow then
            self.uiBinder.rimg_secene_picture:SetImage(worldBossSwitchTableRow.RecommendMainPic)
          else
            self.uiBinder.rimg_secene_picture:SetImage(self.curRecommendedConfig_.BackGroundPic)
          end
        end)
      end)()
    else
      self.uiBinder.rimg_secene_picture:SetImage(self.curRecommendedConfig_.BackGroundPic)
    end
  elseif self.curRecommendedConfig_.FunctionId == E.FunctionID.SeasonBattlePass then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_surplusetime, true)
    local seasonActivationVm = Z.VMMgr.GetVM("season_activation")
    local awardData = seasonActivationVm.GetActivationAwards()
    local maxProgress = 0
    if next(awardData) then
      maxProgress = awardData[#awardData - 1].Activation
    end
    self.uiBinder.lab_surplusetime.text = Lang("ActivityProgress", {
      cur = Z.ContainerMgr.CharSerialize.seasonActivation.activationPoint,
      max = maxProgress
    })
  elseif self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroChallengeDungeon or self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroChallengeJuTaYiJi or self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroChallengeJuLongZhuaHen or self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroDungeonGoblin or self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroChallengeKaNiMan or self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroDungeonDarkFort or self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroChallengeDarkFort then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_treasure, true)
    local isMasterDungeonOpen = Z.VMMgr.GetVM("hero_dungeon_main").CheckAnyMasterDungeonOpen()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_master_score, isMasterDungeonOpen)
    self:refreshDungeonMultiaAwardBtn()
    self:refreshBtnChance(self.curRecommendedConfig_.RelatedDungeonId)
  elseif self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroDungeonDiNa or self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroDungeonJuTaYiJi or self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroDungeonJuLongZhuaHen or self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroDungeonKaNiMan then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_surplusetime, true)
    local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.curRecommendedConfig_.RelatedDungeonId)
    if dungeonData then
      local dungeonNormalCounterId = dungeonData.CountLimit
      local limtCount = Z.CounterHelper.GetCounterLimitCount(dungeonNormalCounterId)
      local normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(dungeonNormalCounterId, limtCount)
      self.uiBinder.lab_surplusetime.text = Lang("HeroDungeonAwardTimes", {
        arrval = {normalAwardCount, limtCount}
      })
    else
      self.uiBinder.lab_surplusetime.text = ""
    end
  elseif self.curRecommendedConfig_.FunctionId == E.FunctionID.UnionHunt then
    self:RefreshUnionActivityRewardNum(E.FunctionID.UnionHunt)
    if self.recommendedPlayVM_.CheckRedById(self.curRecommendedConfig_.Id) then
      local unionData = Z.DataMgr.Get("union_data")
      unionData:SetHuntRecommendRedChecked(true)
      Z.EventMgr:Dispatch(Z.ConstValue.Union.UnionHuntRedRefresh)
      self:refreshRedDot(true)
    end
  elseif self.curRecommendedConfig_.FunctionId == E.FunctionID.UnionWarDance then
    self:RefreshUnionActivityRewardNum(E.FunctionID.UnionWarDance)
    if self.recommendedPlayVM_.CheckRedById(self.curRecommendedConfig_.Id) then
      local unionWarDanceData = Z.DataMgr.Get("union_wardance_data")
      unionWarDanceData:SetRecommendRedChecked(true)
      Z.EventMgr:Dispatch(Z.ConstValue.Union.UnionWarDanceRedRefresh)
      self:refreshRedDot(true)
    end
  elseif self.curRecommendedConfig_.FunctionId == E.FunctionID.UnionDailySign then
    if self.recommendedPlayVM_.CheckRedById(self.curRecommendedConfig_.Id) then
      local unionData = Z.DataMgr.Get("union_data")
      unionData:SetSignRecommendRedChecked(true)
      Z.EventMgr:Dispatch(Z.ConstValue.Union.UnionSignRedRefresh)
      self:refreshRedDot(true)
    end
  elseif self.curRecommendedConfig_.FunctionId == E.FunctionID.LeisureActivities or parentRecommendedConfig ~= nil and parentRecommendedConfig.FunctionId == E.FunctionID.LeisureActivities then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_friendship, true)
  end
  local serverTimeData = self.recommendedPlayData_:GetServerData(E.SeasonActFuncType.Recommend, self.curRecommendedConfig_.Id)
  if serverTimeData == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_nexttime, false)
    self.uiBinder.btn_goonce.Ref.UIComp:SetVisible(true)
  else
    local startTime, endTime = self.recommendedPlayVM_.GetTimeStampByServerData(serverTimeData)
    if startTime > Z.TimeTools.Now() / 1000 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_nexttime, true)
      self.uiBinder.btn_goonce.Ref.UIComp:SetVisible(false)
      local leftTime = startTime - Z.TimeTools.Now() / 1000
      local timeStr = Z.TimeFormatTools.FormatToDHMS(leftTime)
      self.uiBinder.lab_nexttime.text = Lang("remainderLimit", {str = timeStr})
    elseif endTime < Z.TimeTools.Now() / 1000 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_nexttime, true)
      self.uiBinder.btn_goonce.Ref.UIComp:SetVisible(false)
      self.uiBinder.lab_nexttime.text = Lang("SeasonNotOpen")
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_nexttime, false)
      self.uiBinder.btn_goonce.Ref.UIComp:SetVisible(true)
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_viewguide, self.curRecommendedConfig_.HelpId and self.curRecommendedConfig_.HelpId ~= 0)
  self:refreshRedDot(true)
  self:SetDepth()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect)
  self.uiBinder.node_effect:ReleseEffGo()
  if self.curRecommendedConfig_.Effect ~= nil and self.curRecommendedConfig_.Effect ~= "" then
    self.uiBinder.node_effect:CreatEFFGO(self.curRecommendedConfig_.Effect, Vector3.zero)
    self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect)
  end
end

function Recommendedplay_mainView:RefreshUnionActivityRewardNum(functionID)
  local unionActivityData = Z.DataMgr.Get("union_activity_data")
  local countid = unionActivityData:GetCounterByFuncID(functionID)
  if countid == 0 then
    return
  end
  local maxLimitNum = 0
  local counterCfgData = Z.TableMgr.GetTable("CounterTableMgr").GetRow(countid)
  local normalAwardCount = 0
  local nowAwardCount = 0
  if counterCfgData then
    maxLimitNum = counterCfgData.Limit
    if Z.ContainerMgr.CharSerialize.counterList.counterMap[countid] then
      nowAwardCount = Z.ContainerMgr.CharSerialize.counterList.counterMap[countid].counter
    end
  end
  normalAwardCount = maxLimitNum - nowAwardCount
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_surplusetime, true)
  self.uiBinder.lab_surplusetime.text = Lang("UnionHuntAwardTotalCount", {cur = normalAwardCount, max = maxLimitNum})
end

function Recommendedplay_mainView:refreshSub()
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  if self.curRecommendedConfig_.FunctionId == E.FunctionID.WorldBoss then
    self.curSubView_ = self.subviews_[3]
  else
    self.curSubView_ = self.subviews_[2]
  end
  self.curSubView_:Active(self.curRecommendedConfig_.Id, self.uiBinder.node_sub)
end

function Recommendedplay_mainView:refreshRedDot(notRefreshLoop)
  for type, unit in pairs(self.firstTagUnits_) do
    unit.Ref:SetVisible(unit.img_reddot, self.recommendedPlayVM_.CheckTypeIsRed(type))
  end
  if self.curRecommendedConfig_ then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, self.recommendedPlayVM_.CheckRedById(self.curRecommendedConfig_.Id))
    if self.curRecommendedConfig_.FunctionId == E.FunctionID.WorldBoss then
      local bossRed_ = require("rednode.world_boss_red")
      local showRP = bossRed_.CheckHasAwardInOpenTime() and not bossRed_.RedChecked()
      if not showRP then
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, false)
      end
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, false)
  end
  if notRefreshLoop then
  else
    self.secondLoopListView_:RefreshAllShownItem()
  end
  if self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroChallengeDungeon or self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroChallengeJuTaYiJi or self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroChallengeJuLongZhuaHen or self.curRecommendedConfig_.FunctionId == E.FunctionID.HeroChallengeKaNiMan then
    self:refreshBtnWeek(self.curRecommendedConfig_.RelatedDungeonId)
  end
end

function Recommendedplay_mainView:SelectedThirdItem()
  if self.selectedThirdIndex_ then
    self.secondLoopListView_:SetSelected(self.selectedThirdIndex_)
  end
end

function Recommendedplay_mainView:GetThreeSelectedId()
  return self.selectThirdTag_
end

function Recommendedplay_mainView:GetSecondSelectedId()
  return self.selectSecondTag_
end

function Recommendedplay_mainView.tagsSort(a, b)
  local recommendedPlayVM = Z.VMMgr.GetVM("recommendedplay")
  local aState = recommendedPlayVM.GetRecommendSurpluseCount(a) == 0 and 1 or 0
  local bState = recommendedPlayVM.GetRecommendSurpluseCount(b) == 0 and 1 or 0
  if aState == bState then
    if a.Sort == b.Sort then
      return a.Id < b.Id
    else
      return a.Sort < b.Sort
    end
  else
    return aState < bState
  end
end

function Recommendedplay_mainView:refreshBtnWeek(dungeonId)
  local showRed = false
  local targetList, groupId = self.hero_dungeon_mainVM_.GetChallengeHeroDungeonTarget(dungeonId)
  local dungeonInfo = Z.ContainerMgr.CharSerialize.challengeDungeonInfo.dungeonTargetAward[groupId]
  for k, v in ipairs(targetList) do
    if dungeonInfo and dungeonInfo.dungeonTargetProgress[v.targetId] and dungeonInfo.dungeonTargetProgress[v.targetId].awardState == E.DrawState.CanDraw then
      showRed = true
      break
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_week_dot, showRed)
end

function Recommendedplay_mainView:refreshBtnChance(dungeonId)
  local _, buffCount, maxBuffCount, clothItemId, _ = self.hero_dungeon_mainVM_.GetChallengeHeroDungeonProbability(dungeonId)
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(clothItemId)
  if itemCfg then
    local itemVm = Z.VMMgr.GetVM("items")
    local itemIcon = itemVm.GetItemIcon(clothItemId)
    self.uiBinder.btn_chance.img_icon:SetImage(itemIcon)
    self.uiBinder.btn_chance.img_bg:SetImage(Z.ConstValue.QualityImgRoundBg .. itemCfg.Quality)
  end
  local haveGet = self.hero_dungeon_mainVM_.CheckProbabilityHaveGet(dungeonId)
  self.uiBinder.btn_chance.Ref:SetVisible(self.uiBinder.btn_chance.lab_haveget, haveGet)
  self.uiBinder.btn_chance.Ref:SetVisible(self.uiBinder.btn_chance.img_get, haveGet)
  self.uiBinder.btn_chance.Ref:SetVisible(self.uiBinder.btn_chance.node_lab, not haveGet)
  self.uiBinder.btn_chance.img_bg_group.alpha = haveGet and 0.4 or 1
  self.hero_dungeon_mainVM_.SetProbabilityCountUI(buffCount, self.uiBinder.btn_chance)
  self.uiBinder.btn_chance.btn_chance:RemoveAllListeners()
  if not haveGet then
    self:AddClick(self.uiBinder.btn_chance.btn_chance, function()
      self.hero_dungeon_mainVM_.OpenProbabilityPopup(dungeonId)
    end)
  end
end

function Recommendedplay_mainView:checkIsAssistFight(functionId)
  local awardList = self.awardpreviewVM_.GetAllAwardPreListByIds(self.curRecommendedConfig_.PreviewAward)
  local canShowAssist = self.assistFightVM_:GetRecommendedPlay(self.curRecommendedConfig_.RelatedDungeonId, functionId)
  if self.curRecommendedConfig_.HelpAward and canShowAssist then
    local tempAwardTable = {
      awardId = self.curRecommendedConfig_.HelpAward,
      awardNum = 0,
      awardNumExtend = 0,
      PrevDropType = 0,
      isShowAssistFight = true
    }
    table.insert(awardList, 1, tempAwardTable)
  end
  return awardList
end

function Recommendedplay_mainView:refreshDungeonMultiaAwardBtn()
  if self.heroDungeonMainVM_.IsInDungeonMultiaAward() then
    self.uiBinder.node_dungeonMultiaAward.Ref.UIComp:SetVisible(true)
  else
    self.uiBinder.node_dungeonMultiaAward.Ref.UIComp:SetVisible(false)
  end
end

return Recommendedplay_mainView
