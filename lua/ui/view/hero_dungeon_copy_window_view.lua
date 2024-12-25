local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_copy_windowView = class("Hero_dungeon_copy_windowView", super)
local itemClass = require("common.item_binder")
local itemSortFactoryVm = Z.VMMgr.GetVM("item_sort_factory")
local ColorWhite = Color.New(1, 1, 1, 1)
local ColorGreen = Color.New(0.4588235294117647, 0.5215686274509804, 0.2196078431372549, 1)

function Hero_dungeon_copy_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_copy_window")
  self.vm = Z.VMMgr.GetVM("hero_dungeon_copy_window")
  self.teamVm_ = Z.VMMgr.GetVM("team")
  self.dungeonVm_ = Z.VMMgr.GetVM("dungeon")
  self.heroDungeonMainVM_ = Z.VMMgr.GetVM("hero_dungeon_main")
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
  self.planetMemoryLeaveGO_ = self.uiBinder.btn_leave
  self.planetMemoryBtnGo_ = self.uiBinder.btn_continue
  self.dungeonNameNode_ = self.uiBinder.node_title_02
  self.lab_tips_ = self.uiBinder.lab_tips
end

function Hero_dungeon_copy_windowView:OnActive()
  Z.AudioMgr:Play("sys_parkour_destination")
  self:initwidgets()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294965247, true)
  self.continueBtn_.Ref.UIComp:SetVisible(false)
  self.uiBinder.Ref:SetVisible(self.planetMemoryBtnGo_, false)
  self.uiBinder.Ref:SetVisible(self.planetMemoryLeaveGO_, false)
  self.isPlanetmemory = Z.VMMgr.GetVM("planetmemory").IsPlanetmemory()
  self.isTeamExceed_ = self.teamVm_.GetTeamMembersNum()
  self.itemClassTab_ = {}
  self.dungeonId_ = Z.StageMgr.GetCurrentDungeonId()
  self.dungeonData_ = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
  self:AddAsyncClick(self.continueBtn_.btn, function()
    if self.isHaveVote_ then
      Z.VMMgr.GetVM("hero_dungeon_praise_window").OpenHeroView()
    else
      Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.DungeonSettle)
      Z.UITimelineDisplay:ClearTimeLine()
      self.vm.QuitDungeon(self.cancelSource:CreateToken())
    end
  end)
  self:AddAsyncClick(self.planetMemoryBtnGo_, function()
    if not self.isTeamExceed_ then
      Z.DataMgr.Get("planetmemory_data"):SetPlanetMemoryIsContinue(true)
    end
    self:closeView()
  end)
  self:AddAsyncClick(self.planetMemoryLeaveGO_, function()
    self:closeView()
  end)
  self:init()
  self.vm.PlayModelAction()
  self.vm.BeginDungeonSettle()
  Z.EventMgr:Add(Z.ConstValue.HeroDungeonSettleTime, self.btnShow, self)
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
end

function Hero_dungeon_copy_windowView:init()
  self.isShowTask_ = false
  self.node_content02_.Ref:SetVisible(self.starNode2_, false)
  self.node_content02_.Ref:SetVisible(self.targetNode_, false)
  self.node_content02_.Ref:SetVisible(self.standingsNode_, false)
  self.awards_ = {}
  self:setTitle()
  self:creatTaskItem()
  self.node_content01_.Ref.UIComp:SetVisible(not self.isShowTaskNode_)
  self.node_content02_.Ref.UIComp:SetVisible(self.isShowTaskNode_)
  self:setTime(Z.ContainerMgr.DungeonSyncData.settlement.passTime)
  local isChalle = self.heroDungeonMainVM_.IsHeroChallengeDungeonScene()
  local isHero = self.heroDungeonMainVM_.IsHeroDungeonNormalScene()
  local showScore = not isChalle and not isHero
  if not showScore then
    if isChalle then
      self:setDeadCount()
      self:setFastestTime()
    end
  else
    self:setScore()
  end
  self:changeCopyState()
  self:getAward()
end

function Hero_dungeon_copy_windowView:setTitle()
  self.matchingLab_.text = Lang("Victory")
  if self.dungeonData_ then
    self.lab_name_.text = self.dungeonData_.Name
    self.lab_mode_.text = self.dungeonData_.DungeonTypeName
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
    self.uiBinder.Ref:SetVisible(self.planetMemoryBtnGo_, self.isPlanetmemory)
    self.uiBinder.Ref:SetVisible(self.planetMemoryLeaveGO_, self.isPlanetmemory and not self.isTeamExceed_)
    self.continueBtn_.Ref.UIComp:SetVisible(not self.isPlanetmemory)
    if time >= tonumber(times[2]) then
      self:closeView()
    end
  end
end

function Hero_dungeon_copy_windowView:startAnimatedShow()
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
  local itemPaht = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "standingsItem")
  local trans = self.isShowTaskNode_ and self.standingsItemNode2_ or self.standingsItemNode1_
  if itemPaht and itemPaht ~= "" then
    Z.CoroUtil.create_coro_xpcall(function()
      local unit = self:AsyncLoadUiUnit(itemPaht, "passTime", trans)
      if unit then
        local timeShow = Z.TimeTools.S2HMSFormat(num)
        unit.lab_process.text = timeShow
        unit.lab_condition.text = Lang("Hash_3435796028")
      end
    end)()
  end
end

function Hero_dungeon_copy_windowView:setScore()
  if not self.dungeonData_ then
    return
  end
  if self.dungeonData_.PlayType ~= E.DungeonType.HeroChallengeDungeon and self.dungeonData_.PlayType ~= E.DungeonType.HeroNormalDungeon then
    return
  end
  local itemPaht = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "standingsItem")
  if itemPaht and itemPaht ~= "" then
    local trans = self.isShowTaskNode_ and self.standingsItemNode2_ or self.standingsItemNode1_
    Z.CoroUtil.create_coro_xpcall(function()
      local unit = self:AsyncLoadUiUnit(itemPaht, "Score", trans)
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
  local itemPaht = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "standingsItem")
  if itemPaht and itemPaht ~= "" then
    local trans = self.isShowTaskNode_ and self.standingsItemNode2_ or self.standingsItemNode1_
    local unit = self:AsyncLoadUiUnit(itemPaht, "MaxScore", trans)
    if unit then
      unit.lab_process.text = score
      unit.lab_condition.text = Lang("DungeonBestScore")
      unit.Ref:SetVisible(unit.img_label, false)
    end
  end
end

function Hero_dungeon_copy_windowView:setDeadCount()
  Z.CoroUtil.create_coro_xpcall(function()
    local itemPaht = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "standingsItem")
    if itemPaht and itemPaht ~= "" then
      local trans = self.isShowTaskNode_ and self.standingsItemNode2_ or self.standingsItemNode1_
      local unit = self:AsyncLoadUiUnit(itemPaht, "DeadCount", trans)
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
    local itemPaht = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "standingsItem")
    if itemPaht and itemPaht ~= "" then
      local trans = self.isShowTaskNode_ and self.standingsItemNode2_ or self.standingsItemNode1_
      local unit = self:AsyncLoadUiUnit(itemPaht, "FastestTime", trans)
      if unit then
        local time = 0
        if Z.ContainerMgr.CharSerialize.challengeDungeonInfo.dungeonInfo[self.dungeonId_] then
          time = Z.ContainerMgr.CharSerialize.challengeDungeonInfo.dungeonInfo[self.dungeonId_].passTime
        end
        local timeShow = Z.TimeTools.S2HMSFormat(time)
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
  if self.dungeonData_ == nil then
    return
  end
  if self.dungeonData_.FunctionID == Z.PbEnum("EFunctionType", "FunctionTypeLinearDungeon") then
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
  local awardData = Z.ContainerMgr.DungeonSyncData.settlement.award
  if awardData[Z.EntityMgr.PlayerUuid] then
    local items = awardData[Z.EntityMgr.PlayerUuid].items
    if table.zcount(items) > 0 then
      table.insert(self.awards_, awardData[Z.EntityMgr.PlayerUuid].items)
    end
  end
  local isHaveAward = 0 < #self.awards_
  self.node_content02_.Ref:SetVisible(self.awardNode_, isHaveAward)
  local dataMgr = Z.DataMgr.Get("hero_dungeon_main_data")
  self.uiBinder.Ref:SetVisible(self.lab_tips_, not isHaveAward)
  self:isHaveAward(isHaveAward)
end

function Hero_dungeon_copy_windowView:isHaveAward(isflag)
  if isflag then
    self:creatAwardItem()
  else
    local str = ""
    if self.dungeonData_ then
      if self.dungeonData_.PlayType == E.DungeonType.HeroKeyDungeon then
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
      elseif self.dungeonData_.PlayType == E.DungeonType.UnionHunt then
        str = Lang("UnionHuntRepeatNoReward")
      elseif self.dungeonData_.FunctionID == Z.PbEnum("EFunctionType", "FunctionTypeHeroDungeonChallenge") then
        self.isChallenge = true
        str = Lang("CompleteCopyRepeatNoReward")
      elseif self.dungeonData_.FunctionID == Z.PbEnum("EFunctionType", "FunctionTypeHeroDungeonNormal") then
        self.isChallenge = false
        str = Lang("HeroNormalTips")
      end
    end
    self.lab_tips_.text = str
  end
end

function Hero_dungeon_copy_windowView:creatAwardItem()
  local parent = self.isShowTaskNode_ and self.awardContent2_ or self.awardContent1_
  Z.CoroUtil.create_coro_xpcall(function()
    local itemPaht = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "item")
    if itemPaht and itemPaht ~= "" then
      local lstAward = {}
      for key, value in pairs(self.awards_[1]) do
        table.insert(lstAward, {
          configId = value.configId,
          uuid = value.uuid,
          itemInfo = value,
          count = value.count
        })
      end
      itemSortFactoryVm.DefaultSendAwardSortByConfigId(lstAward)
      for key, value in ipairs(lstAward) do
        local itemName = "hero_award_item" .. key
        local item = self:AsyncLoadUiUnit(itemPaht, itemName, parent)
        self.itemClassTab_[itemName] = itemClass.new(self)
        self.itemClassTab_[itemName]:Init({
          uiBinder = item,
          configId = value.configId,
          itemInfo = value.itemInfo,
          lab = value.count,
          isSquareItem = true,
          isHideSource = true
        })
      end
    end
  end)()
end

return Hero_dungeon_copy_windowView
