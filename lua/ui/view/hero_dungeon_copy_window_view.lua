local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_copy_windowView = class("Hero_dungeon_copy_windowView", super)
local itemClass = require("common.item_binder")
local settlementPost = require("ui.component.dungeon_settlement_pos_comp")
local itemSortFactoryVm = Z.VMMgr.GetVM("item_sort_factory")
local MasterChallenDungeonTableMap = require("table.MasterChallenDungeonTableMap")
local rimgName = "ui/textures/dungeon_textures/hero_dungeon_masterdungeon_new"
local ColorWhite = Color.New(1, 1, 1, 1)
local ColorGreen = Color.New(0.4588235294117647, 0.5215686274509804, 0.2196078431372549, 1)

function Hero_dungeon_copy_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_copy_window")
  self.vm = Z.VMMgr.GetVM("hero_dungeon_copy_window")
  self.teamVm_ = Z.VMMgr.GetVM("team")
  self.dungeonMainData_ = Z.DataMgr.Get("hero_dungeon_main_data")
  self.dungeonVm_ = Z.VMMgr.GetVM("dungeon")
  self.heroDungeonMainVM_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.assistFightVM_ = Z.VMMgr.GetVM("assist_fight")
end

function Hero_dungeon_copy_windowView:initwidgets()
  self.node_content01_ = self.uiBinder.node_content01
  self.node_content02_ = self.uiBinder.node_content02
  self.continueBtn_ = self.uiBinder.btn_next
  self.cont_lab_bottom_ = self.uiBinder.cont_lab_bottom
  self.timeLab_ = self.cont_lab_bottom_.lab_desc
  self.lab_name_ = self.uiBinder.lab_name
  self.lab_mode_ = self.uiBinder.lab_mode
  self.matchingLab_ = self.uiBinder.lab_matching
  self.standingsItemNode1_ = self.node_content01_.node_entry
  self.standingsItemNode2_ = self.node_content02_.node_entry
  self.standingsNode_ = self.node_content02_.node_standings
  self.starNode2_ = self.node_content02_.node_rating
  self.targetNode_ = self.node_content02_.node_target
  self.awardNode_ = self.node_content02_.node_item
  self.awardContent1_ = self.node_content01_.content
  self.awardContent2_ = self.node_content02_.content
  self.starIcon1_ = self.node_content01_.img_rating
  self.starIcon2_ = self.node_content02_.img_rating
  self.dungeonNameNode_ = self.uiBinder.node_title_02
  self.lab_tips_ = self.uiBinder.lab_tips
  self.lab_assist_fight_tips_ = self.uiBinder.lab_assist_fight_tips
  self.lab_more_ = self.uiBinder.lab_more
  self.node_more_ = self.uiBinder.node_more
  self.playerLayoutTran_ = self.uiBinder.layout_play_info
  self.settlementPosComp_ = settlementPost.new(self, self.playerLayoutTran_, self:GetPrefabCacheDataNew(self.uiBinder.pcd, "praise_tpl"))
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect)
  self.uiBinder.node_effect:SetEffectGoVisible(true)
end

function Hero_dungeon_copy_windowView:OnActive()
  Z.AudioMgr:Play("sys_parkour_destination")
  self:initwidgets()
  self.vm.BeginDungeonSettle()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294965247, true)
  self.continueBtn_.Ref.UIComp:SetVisible(false)
  self.isTeamExceed_ = self.teamVm_.GetTeamMembersNum()
  self.itemClassTab_ = {}
  self.dungeonId_ = Z.StageMgr.GetCurrentDungeonId()
  self.dungeonTableRow_ = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
  self:AddAsyncClick(self.continueBtn_.btn, function()
    if self.isHaveVote_ then
      Z.VMMgr.GetVM("hero_dungeon_praise_window").OpenHeroView()
    else
      Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.DungeonSettle)
      Z.UITimelineDisplay:ClearTimeLine()
      self.vm.QuitDungeon(self.cancelSource:CreateToken())
    end
  end)
  self:init()
  Z.EventMgr:Add(Z.ConstValue.HeroDungeonSettleTime, self.btnShow, self)
  self:startAnimatedShow()
end

function Hero_dungeon_copy_windowView:OnRefresh()
end

function Hero_dungeon_copy_windowView:OnDeActive()
  self.isTeamExceed_ = false
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294965247, false)
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  self:ClearAllUnits()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect)
  self.uiBinder.node_effect:SetEffectGoVisible(false)
end

function Hero_dungeon_copy_windowView:init()
  self:creatPlayerInfo()
  self.isShowTask_ = false
  self.node_content02_.Ref:SetVisible(self.starNode2_, false)
  self.node_content02_.Ref:SetVisible(self.targetNode_, false)
  self.node_content02_.Ref:SetVisible(self.standingsNode_, false)
  self.awards_ = {}
  self.firstItems_ = {}
  self:setTitle()
  self:creatTaskItem()
  self.node_content01_.Ref.UIComp:SetVisible(not self.isShowTaskNode_)
  self.node_content02_.Ref.UIComp:SetVisible(self.isShowTaskNode_)
  self:setTime(Z.ContainerMgr.DungeonSyncData.settlement.passTime)
  local isChalle = self.heroDungeonMainVM_.IsHeroChallengeDungeonScene()
  local isHero = self.heroDungeonMainVM_.IsHeroDungeonNormalScene()
  local isMaster = self.heroDungeonMainVM_.IsMasterChallengeDungeonScene()
  local showScore = not isChalle and not isHero and not isMaster
  if not showScore then
    if isChalle or isMaster then
      self:setDeadCount()
      if isMaster then
        self:setMasterFastestTime()
        self:setMasterScore()
      else
        self:setFastestTime()
      end
    end
  else
    self:setScore()
  end
  self:changeCopyState()
  self:getAward()
end

function Hero_dungeon_copy_windowView:setTitle()
  self.matchingLab_.text = Lang("Victory")
  self.uiBinder.lab_matching_shadow.text = Lang("Victory")
  if self.dungeonTableRow_ then
    self.lab_name_.text = self.dungeonTableRow_.Name
    local isMaster = self.heroDungeonMainVM_.IsMasterChallengeDungeonScene()
    local dungeonTypeName = self.dungeonTableRow_.DungeonTypeName
    if isMaster then
      local diff = Z.ContainerMgr.DungeonSyncData.dungeonSceneInfo.difficulty
      dungeonTypeName = self.heroDungeonMainVM_.GetHeroDungeonTypeName(self.dungeonId_, diff)
    end
    self.lab_mode_.text = dungeonTypeName
  end
end

function Hero_dungeon_copy_windowView:btnShow(time)
  local times = Z.Global.VictoryToTeamTime
  local tipsText = ""
  if self.isTeamExceed_ then
    tipsText = Lang("HeroDungeonNextTips")
  else
    tipsText = Lang("HeroDungeonCloseTips")
  end
  self.timeLab_.text = tonumber(times[1]) - time .. tipsText
  if time >= tonumber(times[1]) then
    self.cont_lab_bottom_.Ref.UIComp:SetVisible(false)
    self.cont_lab_bottom_.Ref:SetVisible(self.timeLab_, false)
    local state = Z.ContainerMgr.DungeonSyncData.flowInfo.state
    local btnName = Lang("QuitDungeon")
    if self.isTeamExceed_ and state == Z.PbEnum("EDungeonState", "DungeonStateVote") then
      btnName = Lang("Pass")
      self.isHaveVote_ = true
    end
    self.continueBtn_.lab_normal.text = btnName
    self.continueBtn_.Ref.UIComp:SetVisible(true)
    if time >= tonumber(times[2]) then
      self:closeView()
    end
  end
end

function Hero_dungeon_copy_windowView:startAnimatedShow()
  self.uiBinder.animator:PlayOnce("anim_hero_dungeon_settled_window_open")
end

function Hero_dungeon_copy_windowView:closeView()
  if self.isHaveVote_ then
    Z.VMMgr.GetVM("hero_dungeon_praise_window").OpenHeroView()
  else
    Z.UITimelineDisplay:ClearTimeLine()
  end
end

function Hero_dungeon_copy_windowView:changeCopyState()
  self.cont_lab_bottom_.Ref:SetVisible(self.timeLab_, true)
end

function Hero_dungeon_copy_windowView:setTime(num)
  self.node_content02_.Ref:SetVisible(self.standingsNode_, true)
  local itemPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "standingsItem")
  local trans = self.isShowTaskNode_ and self.standingsItemNode2_ or self.standingsItemNode1_
  if itemPath and itemPath ~= "" then
    Z.CoroUtil.create_coro_xpcall(function()
      local unit = self:AsyncLoadUiUnit(itemPath, "passTime", trans)
      if unit then
        local timeShow = Z.TimeFormatTools.FormatToDHMS(num, true)
        unit.lab_process.text = timeShow
        unit.lab_condition.text = Lang("TrialRoadPassTime")
      end
    end)()
  end
end

function Hero_dungeon_copy_windowView:setScore()
  if not self.dungeonTableRow_ then
    return
  end
  if self.dungeonTableRow_.PlayType ~= E.DungeonType.HeroChallengeDungeon and self.dungeonTableRow_.PlayType ~= E.DungeonType.HeroNormalDungeon then
    return
  end
  local itemPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "standingsItem")
  if itemPath and itemPath ~= "" then
    local trans = self.isShowTaskNode_ and self.standingsItemNode2_ or self.standingsItemNode1_
    Z.CoroUtil.create_coro_xpcall(function()
      local unit = self:AsyncLoadUiUnit(itemPath, "Score", trans)
      if unit then
        local totalScore = Z.ContainerMgr.DungeonSyncData.dungeonScore.totalScore
        unit.lab_process.text = totalScore
        unit.lab_condition.text = Lang("BattleScore")
        local dungeonInfo = Z.ContainerMgr.CharSerialize.dungeonList.completeDungeon[self.dungeonId_]
        local maxScore = totalScore
        if dungeonInfo then
          unit.Ref:SetVisible(unit.img_label, totalScore > dungeonInfo.score)
          maxScore = totalScore > dungeonInfo.score and totalScore or dungeonInfo.score
        end
        self:setMaxScore(maxScore)
        self:setStarLevel(totalScore)
      end
    end)()
  end
end

function Hero_dungeon_copy_windowView:setMaxScore(score)
  local itemPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "standingsItem")
  Z.CoroUtil.create_coro_xpcall(function()
    if itemPath and itemPath ~= "" then
      local trans = self.isShowTaskNode_ and self.standingsItemNode2_ or self.standingsItemNode1_
      local unit = self:AsyncLoadUiUnit(itemPath, "MaxScore", trans)
      if unit then
        unit.lab_process.text = score
        unit.lab_condition.text = Lang("DungeonBestScore")
        unit.Ref:SetVisible(unit.img_label, false)
      end
    end
  end)()
end

function Hero_dungeon_copy_windowView:setMasterScore()
  local itemPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "standingsItem")
  Z.CoroUtil.create_coro_xpcall(function()
    if itemPath and itemPath ~= "" then
      local trans = self.isShowTaskNode_ and self.standingsItemNode2_ or self.standingsItemNode1_
      local unit = self:AsyncLoadUiUnit(itemPath, "masterScore", trans)
      if unit then
        local isNewRecordScore, addScore = self.heroDungeonMainVM_.CheckMasterDungeonScoreNewRecord(self.dungeonId_)
        local totalScore = self.heroDungeonMainVM_.GetPlayerSeasonMasterDungeonScore()
        local totalScoreText = self.heroDungeonMainVM_.GetPlayerSeasonMasterDungeonTotalScoreWithColor(totalScore)
        local diff = Z.ContainerMgr.DungeonSyncData.dungeonSceneInfo.difficulty
        local nowScore = self.heroDungeonMainVM_.GetDungeonDiffScore(self.dungeonId_, diff)
        local nowScoreText = self.heroDungeonMainVM_.GetPlayerSeasonMasterDungeonScoreWithColor(nowScore)
        if isNewRecordScore then
          unit.new_record:SetImage(rimgName)
          unit.lab_process.text = "(+" .. addScore .. ")" .. nowScoreText .. "/" .. totalScoreText
          unit.Ref:SetVisible(unit.new_record, true)
        else
          unit.lab_process.text = nowScoreText .. "/" .. totalScoreText
          unit.Ref:SetVisible(unit.new_record, false)
        end
        unit.lab_condition.text = Lang("MaterDungeonScore")
      end
    end
  end)()
end

function Hero_dungeon_copy_windowView:setMasterFastestTime()
  Z.CoroUtil.create_coro_xpcall(function()
    local itemPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "standingsItem")
    if itemPath and itemPath ~= "" then
      local trans = self.isShowTaskNode_ and self.standingsItemNode2_ or self.standingsItemNode1_
      local unit = self:AsyncLoadUiUnit(itemPath, "FastestTime", trans)
      if unit then
        local time = 0
        time = self.heroDungeonMainVM_.GetMasterDungeonFasterTime(self.dungeonId_)
        local timeShow = Z.TimeFormatTools.FormatToDHMS(time, true)
        unit.lab_process.text = timeShow
        unit.lab_condition.text = Lang("FastestTime")
      end
    end
  end)()
end

function Hero_dungeon_copy_windowView:setDeadCount()
  Z.CoroUtil.create_coro_xpcall(function()
    local itemPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "standingsItem")
    if itemPath and itemPath ~= "" then
      local trans = self.isShowTaskNode_ and self.standingsItemNode2_ or self.standingsItemNode1_
      local unit = self:AsyncLoadUiUnit(itemPath, "DeadCount", trans)
      if unit then
        local attrDeathCount = Z.PbAttrEnum("AttrDeathCount")
        local deadCount = Z.World:GetWorldLuaAttr(attrDeathCount)
        unit.lab_process.text = deadCount.Value
        unit.lab_condition.text = Lang("DeadCount")
      end
    end
  end)()
end

function Hero_dungeon_copy_windowView:setFastestTime()
  Z.CoroUtil.create_coro_xpcall(function()
    local itemPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "standingsItem")
    if itemPath and itemPath ~= "" then
      local trans = self.isShowTaskNode_ and self.standingsItemNode2_ or self.standingsItemNode1_
      local unit = self:AsyncLoadUiUnit(itemPath, "FastestTime", trans)
      if unit then
        local time = 0
        if Z.ContainerMgr.CharSerialize.challengeDungeonInfo.dungeonInfo[self.dungeonId_] then
          time = Z.ContainerMgr.CharSerialize.challengeDungeonInfo.dungeonInfo[self.dungeonId_].passTime
        end
        local timeShow = Z.TimeFormatTools.FormatToDHMS(time, true)
        unit.lab_process.text = timeShow
        unit.lab_condition.text = Lang("FastestTime")
      end
    end
  end)()
end

function Hero_dungeon_copy_windowView:setStarLevel(totalScore)
  if not self.dungeonVm_.HasScoreLevel(self.dungeonId_) then
    return
  end
  local starLevel = self.dungeonVm_.GetNowLevelByScore(totalScore, self.dungeonVm_.GetScoreLevelTab(self.dungeonId_))
  local startIcon = self.isShowTaskNode_ and self.starIcon2_ or self.starIcon1_
  if starLevel and startIcon then
    local path = self.dungeonVm_.GetScoreIcon(starLevel)
    startIcon:SetImage(path)
  end
end

function Hero_dungeon_copy_windowView:creatTaskItem()
  self.isShowTaskNode_ = false
  self.uiBinder.Ref:SetVisible(self.dungeonNameNode_, true)
  self.node_content02_.Ref:SetVisible(self.targetNode_, false)
  if self.dungeonTableRow_ == nil then
    return
  end
  if self.dungeonTableRow_.FunctionID == Z.PbEnum("EFunctionType", "FunctionTypeLinearDungeon") then
    local enterDungeonSceneVm = Z.VMMgr.GetVM("ui_enterdungeonscene")
    local valueTab = enterDungeonSceneVm.GetNowFinishTargetsDungeon()
    self.uiBinder.Ref:SetVisible(self.dungeonNameNode_, false)
    if table.zcount(valueTab) == 0 then
      return
    end
    local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "taskItem")
    if not path and path == "" then
      return
    end
    self.node_content02_.Ref:SetVisible(self.targetNode_, true)
    self.isShowTask_ = true
    self.isShowTaskNode_ = true
    Z.CoroUtil.create_coro_xpcall(function()
      local parent = self.node_content02_.node_target_content
      local scrollview = self.node_content02_.scrollview_target
      for index, task in ipairs(valueTab) do
        local tagetItem = self:AsyncLoadUiUnit(path, "taskItem" .. index, parent)
        local exploreInfo, tagetTab = Z.VMMgr.GetVM("target").GetExploreTarget(task.id)
        if exploreInfo ~= nil and tagetTab ~= nil and tagetItem then
          if task.done then
            tagetItem.lab_condition.text = tagetTab.TargetDes
            tagetItem.Ref:SetVisible(tagetItem.lab_process, true)
            tagetItem.Ref:SetVisible(tagetItem.img_toggle, true)
            tagetItem.lab_process.text = task.num .. "/" .. tagetTab.Num
            tagetItem.lab_condition.color = ColorGreen
            tagetItem.lab_process.color = ColorGreen
          else
            tagetItem.Ref:SetVisible(tagetItem.img_toggle, false)
            tagetItem.lab_condition.color = ColorWhite
            tagetItem.lab_process.color = ColorWhite
            if exploreInfo.Type == E.DungeonExploreType.HideTarget then
              if task.num == 0 then
                tagetItem.lab_condition.text = Lang("ToBeExplored")
                tagetItem.Ref:SetVisible(tagetItem.lab_process, false)
              else
                tagetItem.lab_condition.text = tagetTab.TargetDes
                tagetItem.lab_process.text = task.num .. "/" .. tagetTab.Num
                tagetItem.Ref:SetVisible(tagetItem.lab_process, true)
              end
            elseif exploreInfo.Type == E.DungeonExploreType.VagueTarget then
              if task.num > 0 then
                tagetItem.lab_condition.text = tagetTab.TargetDes
                tagetItem.Ref:SetVisible(tagetItem.lab_process, true)
                tagetItem.lab_process.text = task.num .. "/" .. tagetTab.Num
              else
                tagetItem.lab_condition.text = exploreInfo.Param
                tagetItem.Ref:SetVisible(tagetItem.lab_process, false)
              end
            else
              tagetItem.Ref:SetVisible(tagetItem.lab_process, true)
              tagetItem.lab_condition.text = tagetTab.TargetDes
              tagetItem.lab_process.text = task.num .. "/" .. tagetTab.Num
            end
          end
        end
        scrollview.VerticalNormalizedPosition = 0
        Z.Delay(0.7, self.cancelSource:CreateToken())
      end
    end)()
  end
end

function Hero_dungeon_copy_windowView:getAward()
  local isMultiaAward = false
  local awardData = Z.ContainerMgr.DungeonSyncData.settlement.award
  if awardData[Z.EntityMgr.PlayerUuid] then
    local items = awardData[Z.EntityMgr.PlayerUuid].items
    if table.zcount(items) > 0 then
      table.insert(self.awards_, awardData[Z.EntityMgr.PlayerUuid].items)
    end
    self.firstItems_ = awardData[Z.EntityMgr.PlayerUuid].firstItems or {}
    local flagAssist = awardData[Z.EntityMgr.PlayerUuid].flagAssist
    isMultiaAward = awardData[Z.EntityMgr.PlayerUuid].awardCount ~= nil and awardData[Z.EntityMgr.PlayerUuid].awardCount > 1
    self.uiBinder.Ref:SetVisible(self.lab_assist_fight_tips_, flagAssist == E.AssistType.AssistLimit)
  end
  local isHaveAward = 0 < #self.awards_
  self.node_content02_.Ref:SetVisible(self.awardNode_, isHaveAward)
  self.uiBinder.Ref:SetVisible(self.lab_more_, isMultiaAward)
  self.uiBinder.Ref:SetVisible(self.node_more_, isMultiaAward)
  local isLimit = self:isHasLimit()
  if not isHaveAward then
    isLimit = true
  end
  self.uiBinder.Ref:SetVisible(self.lab_tips_, isLimit)
  self:isHaveAward(isHaveAward, isLimit)
end

function Hero_dungeon_copy_windowView:isHasLimit()
  if self.dungeonTableRow_ then
    if self.dungeonTableRow_.CountLimit ~= 0 then
      local residueLimitCount = Z.CounterHelper.GetResidueLimitCountByCounterId(self.dungeonTableRow_.CountLimit)
      if residueLimitCount <= 0 then
        return true
      end
    end
    local isMaster = self.heroDungeonMainVM_.IsMasterChallengeDungeonScene()
    local singleCountId = 0
    if isMaster then
      local diff = Z.ContainerMgr.DungeonSyncData.dungeonSceneInfo.difficulty
      local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[self.dungeonId_][diff]
      local masterChallengeDungeonRow = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId)
      singleCountId = masterChallengeDungeonRow.SingleAwardCounterId
    else
      singleCountId = self.dungeonTableRow_.SingleAwardCounterId
    end
    if singleCountId ~= 0 then
      local residueLimitCount = Z.CounterHelper.GetResidueLimitCountByCounterId(singleCountId)
      if residueLimitCount <= 0 then
        return true
      end
    end
  end
  return false
end

function Hero_dungeon_copy_windowView:isHaveAward(isHaveAward, isflag)
  if isHaveAward then
    self:createAwardItem()
  end
  if isflag then
    self.uiBinder.Ref:SetVisible(self.lab_assist_fight_tips_, false)
    local str = Lang("CompleteCopyRepeatNoReward")
    if self.dungeonTableRow_ then
      if self.dungeonTableRow_.PlayType == E.DungeonType.HeroKeyDungeon then
        local keyCharid = Z.ContainerMgr.DungeonSyncData.heroKey.charId
        if keyCharid ~= 0 then
          local keyInfo = Z.ContainerMgr.DungeonSyncData.heroKey.keyInfo[1]
          if keyInfo then
            if keyCharid ~= Z.ContainerMgr.CharSerialize.charId then
              local limitID = Z.Global.RollRewardLimitId
              local count = Z.CounterHelper.GetResidueLimitCountByCounterId(limitID)
              if 0 < count then
                str = Lang("HeroKyeHaveAward")
              else
                str = Lang("HeroKyeNotKeyAward")
              end
            else
              str = Lang("HeroKyeNotUseKeyAward")
            end
          end
        end
      elseif self.dungeonTableRow_.PlayType == E.DungeonType.UnionHunt then
        str = Lang("UnionHuntRepeatNoReward")
      elseif self.dungeonTableRow_.PlayType == E.DungeonType.HeroChallengeDungeon then
        str = Lang("HeroDungeonNoReward")
      elseif self.dungeonTableRow_.FunctionID == Z.PbEnum("EFunctionType", "FunctionTypeHeroDungeonChallenge") then
        self.isChallenge = true
        str = Lang("CompleteCopyRepeatNoReward")
      elseif self.dungeonTableRow_.FunctionID == Z.PbEnum("EFunctionType", "FunctionTypeHeroDungeonNormal") then
        self.isChallenge = false
        str = Lang("HeroNormalTips")
      end
    end
    local isMaster = self.heroDungeonMainVM_.IsMasterChallengeDungeonScene()
    if isMaster then
      str = Lang("HeroDungeonNoReward")
    end
    self.lab_tips_.text = str
  end
end

function Hero_dungeon_copy_windowView:createAwardItem()
  local parent = self.isShowTaskNode_ and self.awardContent2_ or self.awardContent1_
  Z.CoroUtil.create_coro_xpcall(function()
    local itemPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "item")
    if itemPath and itemPath ~= "" then
      local lstAward = {}
      local flagAssist
      local awardData = Z.ContainerMgr.DungeonSyncData.settlement.award
      if awardData[Z.EntityMgr.PlayerUuid] then
        flagAssist = awardData[Z.EntityMgr.PlayerUuid].flagAssist
      end
      local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
      local assistItemId = 0
      if flagAssist == E.AssistType.AssistReward and dungeonsTable and 0 < table.zcount(dungeonsTable.AssitNumber) then
        assistItemId = dungeonsTable.AssitNumber[1]
      end
      for key, value in pairs(self.awards_[1]) do
        table.insert(lstAward, {
          configId = value.configId,
          uuid = value.uuid,
          itemInfo = value,
          count = value.count,
          isShowAssistFight = assistItemId == value.configId,
          index = key
        })
      end
      itemSortFactoryVm.DefaultSendAwardSortByConfigId(lstAward)
      for key, value in ipairs(lstAward) do
        local itemName = "hero_award_item" .. key
        local item = self:AsyncLoadUiUnit(itemPath, itemName, parent)
        local isShowFirstNode = table.zcontains(self.firstItems_, value.index)
        self.itemClassTab_[itemName] = itemClass.new(self)
        self.itemClassTab_[itemName]:Init({
          uiBinder = item,
          configId = value.configId,
          itemInfo = value.itemInfo,
          lab = value.count,
          isSquareItem = true,
          isHideSource = true,
          isShowLuckyEff = true,
          isShowAssistFight = value.isShowAssistFight,
          isShowFirstNode = isShowFirstNode
        })
      end
    end
  end)()
end

function Hero_dungeon_copy_windowView:creatPlayerInfo()
  Z.CoroUtil.create_coro_xpcall(function()
    self.settlementPosComp_:AsyncSetPos()
    self.vm.PlayModelAction()
  end)()
end

return Hero_dungeon_copy_windowView
