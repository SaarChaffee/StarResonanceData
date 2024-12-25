local UI = Z.UI
local super = require("ui.ui_view_base")
local World_boss_settlementView = class("World_boss_settlementView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local awardItem = require("ui.component.world_boss.world_boss_award_loop_item")
local rankItem = require("ui.component.world_boss.world_boss_rank_loop_item")
local loopListView = require("ui.component.loop_list_view")
local FailTitleColor = Color.New(0.8941176470588236, 0.9294117647058824, 0.9725490196078431, 1)
local PassTitleColor = Color.New(1.0, 0.9490196078431372, 0.8980392156862745, 1)
local FailTimeColor = Color.New(0.5019607843137255, 0.5019607843137255, 0.5019607843137255, 1)
local PassTimeColor = Color.New(0.9215686274509803, 0.5529411764705883, 0.1607843137254902, 1)
local FailColor = Color.New(0.8509803921568627, 0.8823529411764706, 0.9450980392156862, 1)
local PassColor = Color.New(0.8549019607843137, 0.8549019607843137, 0.8549019607843137, 1)
local WorldBossFailEffect = "ui/uieffect/prefab/weaponhero/ui_sfx_group_world_boss_hit_biue"
local WorldBossSuccessEffect = "ui/uieffect/prefab/weaponhero/ui_sfx_group_world_boss_hit_yellow"

function World_boss_settlementView:ctor()
  self.uiBinder = nil
  super.ctor(self, "world_boss_settlement")
end

function World_boss_settlementView:OnActive()
  self.uiBinder.anim:PlayOnce("anim_world_boss_settlement_an")
  self:initBaseData()
  self:initBinders()
  self:refreshSettlementInfo()
end

function World_boss_settlementView:OnDeActive()
  self.loopRankItem:UnInit()
  self.loopRankItem = nil
  self.loopAwardItem:UnInit()
  self.loopAwardItem = nil
  self.playerRankAwardLoopView:UnInit()
  self.playerRankAwardLoopView = nil
  self.playerAwardLoopView:UnInit()
  self.playerAwardLoopView = nil
  self.uiBinder.node_eff:ReleseEffGo()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff)
end

function World_boss_settlementView:OnRefresh()
end

function World_boss_settlementView:initBaseData()
  self.worldBossVM_ = Z.VMMgr.GetVM("world_boss")
  self.worldBossData_ = Z.DataMgr.Get("world_boss_data")
  local worldBossSettlement = Z.ContainerMgr.DungeonSyncData.settlement.worldBossSettlement
  local flowInfo = Z.ContainerMgr.DungeonSyncData.flowInfo
  self.isPass_ = flowInfo.result == E.EDungeonResult.DungeonResultSuccess
  local hasLastHitReward = worldBossSettlement.lastHitAward and worldBossSettlement.bossHpPercent <= 0
  self.showLastHit = hasLastHitReward and self.isPass_
end

function World_boss_settlementView:initBinders()
  self:AddAsyncClick(self.uiBinder.btn_leave_copy, function()
    self.worldBossVM_.AsyncExitDungeon(self.cancelSource:CreateToken())
  end)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  local dataList = {}
  self.loopRankItem = not self.showLastHit and loopListView.new(self, self.uiBinder.scrollview, rankItem, "world_boss_list_tpl") or loopListView.new(self, self.uiBinder.scrollview_end, rankItem, "world_boss_list_tpl_end")
  self.loopAwardItem = loopListView.new(self, self.uiBinder.loop_item_rank, awardItem, "com_item_square_1_8")
  self.loopRankItem:Init(dataList)
  self.loopAwardItem:Init(dataList)
  local item = not self.showLastHit and self.uiBinder.group_oneself_list_tpl or self.uiBinder.group_oneself_list_tpl_end
  self.playerRankAwardLoopView = loopListView.new(self, item.loop_item_rank, awardItem, "com_item_square_1_8")
  self.playerAwardLoopView = loopListView.new(self, item.loop_item_pass, awardItem, "com_item_square_1_8")
  self.playerRankAwardLoopView:Init(dataList)
  self.playerAwardLoopView:Init(dataList)
end

function World_boss_settlementView:setTime(num)
  local h = math.floor(num / 3600)
  local time = os.date("%M:%S", num)
  local worldBossSettlement = Z.ContainerMgr.DungeonSyncData.settlement.worldBossSettlement
  self.uiBinder.lab_time.text = Lang("BattleTime") .. h .. ":" .. time .. Lang("WorldBossLeftHP") .. worldBossSettlement.bossHpPercent .. "%"
  self.uiBinder.lab_time.color = self.isPass_ and PassTimeColor or FailTimeColor
end

function World_boss_settlementView:refreshSettlementInfo()
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
  self:setTime(Z.ContainerMgr.DungeonSyncData.settlement.passTime)
  self.uiBinder.node_info_end.gameObject:SetActive(self.showLastHit)
  self.uiBinder.node_info.gameObject:SetActive(not self.showLastHit)
  if self.isPass_ then
    self:refreshPassResult()
    self.uiBinder.node_eff:CreatEFFGO(WorldBossSuccessEffect, Vector3.zero)
    self.uiBinder.node_eff:SetEffectGoVisible(true)
  else
    self:refreshFailResult()
    self.uiBinder.node_eff:CreatEFFGO(WorldBossFailEffect, Vector3.zero)
    self.uiBinder.node_eff:SetEffectGoVisible(true)
  end
end

function World_boss_settlementView:refreshPassResult()
  self.uiBinder.rimg_title_bg:SetImage("ui/textures/worldboss/world_boss_win")
  self.uiBinder.lab_title.text = Lang("BattleSettlement")
  self.uiBinder.lab_title.color = PassTitleColor
  self:refreshLastHitData()
  self:refreshRankContents()
  self:refreshSelfData()
end

function World_boss_settlementView:refreshFailResult()
  self.uiBinder.rimg_title_bg:SetImage("ui/textures/worldboss/world_boss_lose")
  self.uiBinder.lab_title.text = Lang("BattleLost")
  self.uiBinder.lab_title.color = FailTitleColor
  self:refreshRankContents()
  self:refreshSelfData()
end

function World_boss_settlementView:refreshLastHitData()
  local worldBossSettlement = Z.ContainerMgr.DungeonSyncData.settlement.worldBossSettlement
  local playerInfo = Z.ContainerMgr.DungeonSyncData.dungeonPlayerList.playerInfos
  local hasLastHitReward = worldBossSettlement.lastHitAward and worldBossSettlement.bossHpPercent <= 0
  if not hasLastHitReward then
    return
  end
  for key, value in pairs(worldBossSettlement.lastHitAward) do
    local itemData = value.items
    local l = {}
    for _, value in pairs(itemData) do
      l[#l + 1] = value
    end
    self.loopAwardItem:RefreshListView(l, true)
    local playinfo = playerInfo[key]
    if playinfo then
      local socialData = playinfo.socialData
      self.uiBinder.lab_name.text = socialData.basicData.name
      self.headItem_ = playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.group_head, socialData)
    end
    break
  end
end

function World_boss_settlementView:refreshRankContents()
  local worldBossSettlement = Z.ContainerMgr.DungeonSyncData.settlement.worldBossSettlement
  local rankData = worldBossSettlement.dungeonBossRank.bossRank
  local ranks = {}
  local index = 1
  for _, value in pairs(rankData) do
    local rankInfo = {}
    rankInfo.rankData = value
    rankInfo.rankAward = Z.ContainerMgr.DungeonSyncData.settlement.worldBossSettlement.bossRankAward[value.charId]
    rankInfo.settlementAward = Z.ContainerMgr.DungeonSyncData.settlement.worldBossSettlement.award[value.charId]
    rankInfo.playInfo = Z.ContainerMgr.DungeonSyncData.dungeonPlayerList.playerInfos[value.charId]
    rankInfo.flowInfo = Z.ContainerMgr.DungeonSyncData.flowInfo
    ranks[index] = rankInfo
    index = index + 1
  end
  table.sort(ranks, function(a, b)
    return a.rankData.rank < b.rankData.rank
  end)
  self.loopRankItem:RefreshListView(ranks, true)
end

function World_boss_settlementView:refreshSelfData()
  local charId = Z.ContainerMgr.CharSerialize.charId
  local item = not self.showLastHit and self.uiBinder.group_oneself_list_tpl or self.uiBinder.group_oneself_list_tpl_end
  local rankIndex, score = self.worldBossVM_:GetSelfRankAndScore()
  self:refreshRankAndScore(rankIndex, score, item)
  self:refreshSelfHead(charId, item)
  local countID = Z.WorldBoss.WorldBossAwardCountId
  local limtCount = Z.CounterHelper.GetCounterLimitCount(countID)
  local count = 0
  if Z.ContainerMgr.CharSerialize.counterList.counterMap[countID] then
    count = Z.ContainerMgr.CharSerialize.counterList.counterMap[countID].counter
  end
  local reCount = limtCount - count
  if self.isPass_ then
    local hasPassAwards = self:refreshPassAwards(charId, item)
    local hasRankAwards = self:refreshRankAwards(charId, item)
    if hasPassAwards or hasRankAwards then
      item.Ref:SetVisible(item.lab_reward, false)
    else
      item.Ref:SetVisible(item.lab_reward, true)
      if rankIndex == nil or rankIndex <= 0 then
        item.lab_reward.text = Lang("WorldBossNotEnoughContribution", {
          val = Z.WorldBoss.WorldBossMinContribute
        })
      elseif reCount <= 0 then
        item.lab_reward.text = Lang("NumberRewardsUsedUp")
      else
        item.lab_reward.text = ""
      end
    end
  else
    item.Ref:SetVisible(item.loop_item_pass, false)
    item.Ref:SetVisible(item.loop_item_rank, false)
    item.Ref:SetVisible(item.lab_reward, true)
    item.lab_reward.text = Lang("NotPassWordBossAwardPrompt")
  end
end

function World_boss_settlementView:refreshRankAndScore(rankIndex, score, item)
  local isShowRankImg = false
  if rankIndex <= 0 or rankIndex == nil then
    item.lab_ranking_num.text = Lang("NotHasRankIndex")
  elseif rankIndex <= 3 then
    item.img_ranking_bg:SetImage("ui/atlas/worldboss/world_boss_ranking_" .. rankIndex)
    isShowRankImg = true
  else
    item.lab_ranking_num.text = rankIndex
  end
  item.img_frame.color = self.isPass_ and PassColor or FailColor
  item.lab_active_num.text = score
  item.Ref:SetVisible(item.img_ranking_bg, isShowRankImg)
  item.Ref:SetVisible(item.lab_ranking_num, not isShowRankImg)
end

function World_boss_settlementView:refreshPassAwards(charId, item)
  local d = Z.ContainerMgr.DungeonSyncData.settlement.worldBossSettlement
  local settlementAward = d.award[charId]
  local rewardList2 = settlementAward == nil and {} or settlementAward.items
  local awards = {}
  local index = 1
  for _, value in pairs(rewardList2) do
    awards[index] = value
    index = index + 1
  end
  if index == 1 then
    item.Ref:SetVisible(item.loop_item_pass, false)
    return false
  end
  item.Ref:SetVisible(item.loop_item_pass, true)
  self.playerAwardLoopView:RefreshListView(awards, false)
  return true
end

function World_boss_settlementView:refreshRankAwards(charId, item)
  local d = Z.ContainerMgr.DungeonSyncData.settlement.worldBossSettlement
  local rankAward = d.bossRankAward[charId]
  local rewardList = rankAward == nil and {} or rankAward.items
  local awards = {}
  local index = 1
  for _, value in pairs(rewardList) do
    awards[index] = value
    index = index + 1
  end
  if index == 1 then
    item.Ref:SetVisible(item.loop_item_rank, false)
    return false
  end
  item.Ref:SetVisible(item.loop_item_rank, true)
  self.playerRankAwardLoopView:RefreshListView(awards, false)
  return true
end

function World_boss_settlementView:refreshSelfHead(charId, item)
  local playerInfo = Z.ContainerMgr.DungeonSyncData.dungeonPlayerList.playerInfos
  local playinfo = playerInfo[charId]
  if playinfo then
    local socialData = playinfo.socialData
    self.headItem_ = playerPortraitHgr.InsertNewPortraitBySocialData(item.binder_head, socialData)
  end
  local charData = Z.ContainerMgr.CharSerialize.charBase
  local item = not self.showLastHit and self.uiBinder.group_oneself_list_tpl or self.uiBinder.group_oneself_list_tpl_end
  item.lab_player_name.text = charData.name
end

return World_boss_settlementView
