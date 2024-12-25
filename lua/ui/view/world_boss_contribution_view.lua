local UI = Z.UI
local super = require("ui.ui_subview_base")
local World_boss_contributionView = class("World_boss_contributionView", super)

function World_boss_contributionView:ctor(parent)
  self.uiBinder = nil
  local assetPath = Z.IsPCUI and "worldboss/world_boss_contribution_pc" or "worldboss/world_boss_contribution"
  super.ctor(self, "world_boss_contribution", assetPath, UI.ECacheLv.None)
  self.worldBossData_ = Z.DataMgr.Get("world_boss_data")
end

function World_boss_contributionView:OnActive()
  self:BindEvents()
  self:refreshData()
end

function World_boss_contributionView:OnDeActive()
end

function World_boss_contributionView:OnRefresh()
  self:refreshData()
end

function World_boss_contributionView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Dungeon.ContributionInfoChange, self.refreshData, self)
end

function World_boss_contributionView:refreshData()
  local rankInfos = self.worldBossData_:GetWorldBossRankInfo()
  table.sort(rankInfos, function(a, b)
    if a.score == b.score then
      return a.charId < b.charId
    end
    return a.score > b.score
  end)
  self:refreshRanks(rankInfos)
  self:refreshSelf(rankInfos)
end

function World_boss_contributionView:refreshRanks(rankInfos)
  local playerInfo = Z.ContainerMgr.DungeonSyncData.dungeonPlayerList.playerInfos
  for i = 1, 3 do
    local rankInfo = rankInfos[i]
    self:refreshRank(i, rankInfo, playerInfo)
  end
end

function World_boss_contributionView:refreshRank(index, rankInfo, playerInfo)
  local item = self.uiBinder["group_" .. index]
  self:SetUIVisible(item.Ref, rankInfo ~= nil)
  if rankInfo then
    local charId = rankInfo.charId
    local name = ""
    local playinfo = playerInfo[charId]
    if playinfo then
      name = playinfo.socialData.basicData.name
    end
    item.lab_ranking.text = index
    item.lab_name.text = name
    item.lab_num.text = rankInfo.score
  end
end

function World_boss_contributionView:refreshSelf(rankInfos)
  local selfInfoData
  local randNum = 0
  for index, value in ipairs(rankInfos) do
    if value.charId == Z.ContainerMgr.CharSerialize.charId then
      randNum = index
      selfInfoData = value
    end
  end
  local selfItem = self.uiBinder.group_oneself
  if selfInfoData then
    selfItem.lab_ranking.text = randNum
    selfItem.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
    selfItem.lab_num.text = selfInfoData.score
  else
    selfItem.lab_ranking.text = Lang("None")
    selfItem.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
    selfItem.lab_num.text = "0"
  end
end

return World_boss_contributionView
