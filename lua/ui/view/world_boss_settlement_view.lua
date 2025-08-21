local UI = Z.UI
local super = require("ui.ui_view_base")
local World_boss_settlementView = class("World_boss_settlementView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local awardItem = require("ui.component.world_boss.world_boss_award_loop_item")
local rankItem = require("ui.component.world_boss.world_boss_rank_loop_item")
local loopListView = require("ui.component.loop_list_view")
local FailTitleColor = Color.New(0.8941176470588236, 0.9294117647058824, 0.9725490196078431, 1)
local PassTitleColor = Color.New(1.0, 0.9490196078431372, 0.8980392156862745, 1)
local SuccessAnim = "anim_world_boss_settlement_an"
local FailAnim = "anim_world_boss_settlement_01_an"

function World_boss_settlementView:ctor()
  self.uiBinder = nil
  super.ctor(self, "world_boss_settlement")
end

function World_boss_settlementView:OnActive()
  self:initBaseData()
  self:initBinders()
  self:refreshSettlementInfo()
end

function World_boss_settlementView:OnDeActive()
  self.loopRankItem:UnInit()
  self.loopRankItem = nil
  self.playerAwardLoopView:UnInit()
  self.playerAwardLoopView = nil
  self.uiBinder.node_fail_result:SetEffectGoVisible(false)
  self.uiBinder.node_pass_result:SetEffectGoVisible(false)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_fail_result)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_pass_result)
end

function World_boss_settlementView:OnRefresh()
end

function World_boss_settlementView:initBaseData()
  self.worldBossVM_ = Z.VMMgr.GetVM("world_boss")
  self.worldBossData_ = Z.DataMgr.Get("world_boss_data")
  local flowInfo = Z.ContainerMgr.DungeonSyncData.flowInfo
  self.isPass_ = flowInfo.result == E.EDungeonResult.DungeonResultSuccess
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_fail_result)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_pass_result)
  if self.isPass_ then
    self.uiBinder.node_pass_result:SetEffectGoVisible(true)
  else
    self.uiBinder.node_pass_result:SetEffectGoVisible(true)
  end
  local stateName = self.isPass_ and SuccessAnim or FailAnim
  self.uiBinder.anim:PlayOnce(stateName)
end

function World_boss_settlementView:initBinders()
  self.uiBinder.scenemask:SetSceneMaskByKey(Z.UI.ESceneMaskKey.Default)
  self:AddAsyncClick(self.uiBinder.btn_leave_copy, function()
    self.worldBossVM_.AsyncExitDungeon(self.cancelSource:CreateToken())
  end)
  local dataList = {}
  self.loopRankItem = loopListView.new(self, self.uiBinder.scrollview, rankItem, "world_boss_list_tpl")
  self.loopRankItem:Init(dataList)
  local item = self.uiBinder.group_oneself_list_tpl
  self.playerAwardLoopView = loopListView.new(self, item.loop_item_pass, awardItem, "com_item_square_1_8")
  self.playerAwardLoopView:Init(dataList)
end

function World_boss_settlementView:setTime(num)
  local h = math.floor(num / 3600)
  local time = os.date("%M:%S", num)
  local worldBossSettlement = Z.ContainerMgr.DungeonSyncData.settlement.worldBossSettlement
  if self.isPass_ then
    self.uiBinder.lab_time.text = Lang("WorldBossWinBattleTime", {
      hour = h,
      time = time,
      hp = worldBossSettlement.bossHpPercent
    })
  else
    self.uiBinder.lab_time.text = Lang("WorldBossLoseBattleTime", {
      hour = h,
      time = time,
      hp = worldBossSettlement.bossHpPercent
    })
  end
end

function World_boss_settlementView:refreshSettlementInfo()
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
  self:setTime(Z.ContainerMgr.DungeonSyncData.settlement.passTime)
  if self.isPass_ then
    self:refreshPassResult()
  else
    self:refreshFailResult()
  end
end

function World_boss_settlementView:refreshPassResult()
  self.uiBinder.rimg_title_bg:SetImage("ui/textures/worldboss/world_boss_win")
  self.uiBinder.lab_title.text = Lang("BattleSettlement")
  self.uiBinder.lab_title.color = PassTitleColor
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
  self.loopRankItem:RefreshListView(ranks, true)
end

function World_boss_settlementView:refreshSelfData()
  local charId = Z.ContainerMgr.CharSerialize.charId
  local item = self.uiBinder.group_oneself_list_tpl
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
    if hasPassAwards then
      item.Ref:SetVisible(item.lab_reward, false)
    else
      item.Ref:SetVisible(item.lab_reward, true)
      if reCount <= 0 then
        item.lab_reward.text = Lang("NumberRewardsUsedUp")
      else
        item.lab_reward.text = Lang("WorldBossNotEnoughContribution", {
          val = Z.WorldBoss.WorldBossMinContribute
        })
      end
    end
  else
    item.Ref:SetVisible(item.loop_item_pass, false)
    item.Ref:SetVisible(item.lab_reward, true)
    item.lab_reward.text = Lang("NotPassWordBossAwardPrompt")
  end
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
  table.sort(awards, function(item1, item2)
    local aItemId = item1.configId
    local bItemId = item2.configId
    local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
    local aItemConfig = itemsTableMgr.GetRow(aItemId)
    local bItemConfig = itemsTableMgr.GetRow(bItemId)
    if aItemConfig.Quality == bItemConfig.Quality then
      if aItemConfig.SortID == bItemConfig.SortID then
        return aItemConfig.Id < bItemConfig.Id
      else
        return aItemConfig.SortID < bItemConfig.SortID
      end
    else
      return aItemConfig.Quality > bItemConfig.Quality
    end
  end)
  self.playerAwardLoopView:RefreshListView(awards, false)
  return true
end

function World_boss_settlementView:refreshSelfHead(charId, item)
  local playerInfo = Z.ContainerMgr.DungeonSyncData.dungeonPlayerList.playerInfos
  local playinfo = playerInfo[charId]
  if playinfo then
    local socialData = playinfo.socialData
    self.headItem_ = playerPortraitHgr.InsertNewPortraitBySocialData(item.binder_head, socialData, nil, self.cancelSource:CreateToken())
    local professionID = socialData.professionData.professionId
    local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionID)
    if professionRow ~= nil then
      item.img_profession:SetImage(professionRow.Icon)
      item.lab_lv.text = Lang("ProfessionLevel", {
        level = socialData.basicData.level,
        name = professionRow.Name
      })
    end
  end
  local charData = Z.ContainerMgr.CharSerialize.charBase
  local item = self.uiBinder.group_oneself_list_tpl
  item.lab_player_name.text = charData.name
end

return World_boss_settlementView
