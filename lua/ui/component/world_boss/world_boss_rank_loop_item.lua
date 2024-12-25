local super = require("ui.component.loop_grid_view_item")
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local loopListView = require("ui.component.loop_list_view")
local awardItem = require("ui.component.world_boss.world_boss_award_loop_item")
local WorldBossRankLoopItem = class("WorldBossRankLoopItem", super)
local FailColor = Color.New(0.8509803921568627, 0.8823529411764706, 0.9450980392156862, 1)
local PassColor = Color.New(0.8549019607843137, 0.8549019607843137, 0.8549019607843137, 1)

function WorldBossRankLoopItem:OnInit()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  local dataList = {}
  self.loopRankAwardListView_ = loopListView.new(self, self.uiBinder.loop_item_rank, awardItem, "com_item_square_1_8")
  self.loopRankAwardListView_:Init(dataList)
  self.loopPassAwardListView_ = loopListView.new(self, self.uiBinder.loop_item_pass, awardItem, "com_item_square_1_8")
  self.loopPassAwardListView_:Init(dataList)
  self.view_ = self.parent.UIView
end

function WorldBossRankLoopItem:OnRefresh(data)
  self.data_ = data.rankData
  self.rankAward = data.rankAward
  self.settlementAward = data.settlementAward
  self.playInfo = data.playInfo
  local flowInfo = data.flowInfo
  local isPass = flowInfo.result == E.EDungeonResult.DungeonResultSuccess
  local rankNum = self.data_.rank
  if self.data_.score < Z.WorldBoss.WorldBossMinContribute then
    rankNum = 0
  end
  local showRankImg = rankNum <= 3 and 0 < rankNum
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_ranking_bg, showRankImg)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_ranking_num, not showRankImg)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_decorate, showRankImg)
  if rankNum <= 0 then
    self.uiBinder.lab_ranking_num.text = Lang("NotHasRankIndex")
  elseif showRankImg then
    self.uiBinder.img_ranking_bg:SetImage("ui/atlas/worldboss/world_boss_ranking_" .. rankNum)
    local path = string.format("ui/textures/worldboss/world_boss_base_%02d", rankNum)
    self.uiBinder.rimg_decorate:SetImage(path)
  else
    self.uiBinder.lab_ranking_num.text = rankNum
  end
  self.uiBinder.lab_active_num.text = self.data_.score
  local hasRankAward = false
  local hasPassAward = false
  if isPass then
    local charId = self.data_.charId
    hasRankAward = self:refreshRankAward(charId)
    hasPassAward = self:refreshPassAward(charId)
  end
  self:refreshRankVisible(hasRankAward, hasPassAward, isPass)
  self:asyncRefreshSelfHead()
  self.uiBinder.img_frame.color = self.parent.UIView.isPass_ and PassColor or FailColor
end

function WorldBossRankLoopItem:refreshRankVisible(hasRankAward, hasPassAward, isPass)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_pass, isPass and hasPassAward)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_rank, isPass and hasRankAward)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_reward, not isPass or not hasRankAward and not hasPassAward)
  if isPass then
    self.uiBinder.lab_reward.text = Lang("RewardNotGranted")
  else
    self.uiBinder.lab_reward.text = Lang("NotPassWordBossAwardPrompt")
  end
end

function WorldBossRankLoopItem:refreshRankAward(charId)
  local rankAward = self.rankAward
  local rewardList = rankAward == nil and {} or rankAward.items
  local hasAward = self:refreshAwards(rewardList, self.loopRankAwardListView_)
  return hasAward
end

function WorldBossRankLoopItem:refreshPassAward(charId)
  local settlementAward = self.settlementAward
  local rewardList2 = settlementAward == nil and {} or settlementAward.items
  local hasAward = self:refreshAwards(rewardList2, self.loopPassAwardListView_)
  return hasAward
end

function WorldBossRankLoopItem:refreshAwards(awardS, loopListView)
  local dataList = {}
  local index = 1
  for _, value in pairs(awardS) do
    dataList[index] = value
    index = index + 1
  end
  if index == 1 then
    return false
  end
  loopListView:RefreshListView(dataList, true)
  return true
end

function WorldBossRankLoopItem:asyncRefreshSelfHead()
  local charId_ = self.data_.charId
  local playinfo = self.playInfo
  local socialData = playinfo.socialData
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
  local selfCharId = Z.ContainerMgr.CharSerialize.charId
  local isSelf = charId_ == selfCharId
  if socialData then
    self.headItem_ = playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, socialData)
    local str = socialData.basicData.name
    if isSelf then
      str = Z.RichTextHelper.ApplyColorTag(str, "#DBFF00")
    end
    self.uiBinder.lab_player_name.text = str
  end
end

function WorldBossRankLoopItem:OnUnInit()
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
  self.loopRankAwardListView_:UnInit()
  self.loopRankAwardListView_ = nil
  self.loopPassAwardListView_:UnInit()
  self.loopPassAwardListView_ = nil
end

function WorldBossRankLoopItem:AddAsyncClick(btn, func)
  self.view_:AddAsyncClick(btn, func)
end

return WorldBossRankLoopItem
