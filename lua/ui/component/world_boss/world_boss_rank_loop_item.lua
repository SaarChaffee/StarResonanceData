local super = require("ui.component.loop_grid_view_item")
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local loopListView = require("ui.component.loop_list_view")
local awardItem = require("ui.component.world_boss.world_boss_award_loop_item")
local WorldBossRankLoopItem = class("WorldBossRankLoopItem", super)
local FailColor = Color.New(0.8509803921568627, 0.8823529411764706, 0.9450980392156862, 1)
local PassColor = Color.New(0.8549019607843137, 0.8549019607843137, 0.8549019607843137, 1)

function WorldBossRankLoopItem:OnInit()
  local dataList = {}
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
  local hasPassAward = false
  if isPass then
    local charId = self.data_.charId
    hasPassAward = self:refreshPassAward(charId)
  end
  self:refreshRankVisible(hasPassAward, isPass)
  self:asyncRefreshSelfHead()
  self.uiBinder.img_frame.color = self.parent.UIView.isPass_ and PassColor or FailColor
end

function WorldBossRankLoopItem:refreshRankVisible(hasPassAward, isPass)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_pass, isPass and hasPassAward)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_reward, not isPass or not hasPassAward)
  if isPass then
    self.uiBinder.lab_reward.text = Lang("RewardNotGranted")
  else
    self.uiBinder.lab_reward.text = Lang("NotPassWordBossAwardPrompt")
  end
end

function WorldBossRankLoopItem:refreshPassAward(charId)
  local settlementAward = self.settlementAward
  local rewardList2 = settlementAward == nil and {} or settlementAward.items
  local hasAward = self:refreshAwards(rewardList2, self.loopPassAwardListView_)
  return hasAward
end

function WorldBossRankLoopItem:refreshAwards(awards, loopListView)
  local dataList = {}
  local index = 1
  for _, value in pairs(awards) do
    dataList[index] = value
    index = index + 1
  end
  if index == 1 then
    return false
  end
  table.sort(dataList, function(item1, item2)
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
    self.headItem_ = playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, socialData, nil, self.view_.cancelSource:CreateToken())
    local str = socialData.basicData.name
    if isSelf then
      str = Z.RichTextHelper.ApplyColorTag(str, "#DBFF00")
    end
    self.uiBinder.lab_player_name.text = str
    local professionID = socialData.professionData.professionId
    local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionID)
    if professionRow ~= nil then
      self.uiBinder.img_profession:SetImage(professionRow.Icon)
      self.uiBinder.lab_lv.text = Lang("ProfessionLevel", {
        level = socialData.basicData.level,
        name = professionRow.Name
      })
    end
  end
end

function WorldBossRankLoopItem:OnUnInit()
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
  self.loopPassAwardListView_:UnInit()
  self.loopPassAwardListView_ = nil
end

function WorldBossRankLoopItem:AddAsyncClick(btn, func)
  self.view_:AddAsyncClick(btn, func)
end

return WorldBossRankLoopItem
