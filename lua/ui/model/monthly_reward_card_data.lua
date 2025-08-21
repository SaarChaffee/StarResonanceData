local super = require("ui.model.data_base")
local MonthlyRewardCardData = class("MonthlyRewardCardData", super)

function MonthlyRewardCardData:ctor()
  super.ctor(self)
  self.cardInfo_ = {}
  self.showCardInfo_ = {}
  self.showListData_ = {}
end

function MonthlyRewardCardData:OnLanguageChange()
  self:initTableMgr()
end

function MonthlyRewardCardData:Init()
  self.IsOpenedTipsCardView = false
  self:initTableMgr()
end

function MonthlyRewardCardData:initTableMgr()
  self.monthCardTable_ = Z.TableMgr.GetTable("MonthCardTableMgr")
  self.awardPackageTableMgr_ = Z.TableMgr.GetTable("AwardPackageTableMgr")
  self.noteMonthCardTableMgr_ = Z.TableMgr.GetTable("NoteMonthCardTableMgr")
  self.awardTableMgr_ = Z.TableMgr.GetTable("AwardTableMgr")
  self.itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
  self.monthCardPrivilegeTableMgr_ = Z.TableMgr.GetTable("MonthCardPrivilegeTableMgr")
end

function MonthlyRewardCardData:Clear()
  self.showCardInfo_ = {}
  self.showListData_ = {}
  self.IsOpenedTipsCardView = false
end

function MonthlyRewardCardData:UnInit()
  self.showCardInfo_ = {}
  self.showListData_ = {}
end

function MonthlyRewardCardData:GetCardInfo(monthlyCardKey)
  if not monthlyCardKey then
    return
  end
  local monthCardRow = self.monthCardTable_.GetRow(monthlyCardKey)
  if not monthCardRow then
    return
  end
  local cardInfo = {}
  cardInfo.MonthCardConfig = monthCardRow
  local awardInfo = self.awardPackageTableMgr_.GetRow(monthCardRow.MonthLimitAwardId)
  if awardInfo then
    local awardTableInfo = self.awardTableMgr_.GetRow(awardInfo.PackContent[1][1])
    local noteMonthCardTableRow = self.noteMonthCardTableMgr_.GetRow(awardTableInfo.GroupContent[1][1])
    local itemInfo = self.itemTableMgr_.GetRow(awardTableInfo.GroupContent[1][1])
    local awardItemInfo = self.itemTableMgr_.GetRow(awardTableInfo.GroupContent[2][1])
    cardInfo.ItemConfig = itemInfo
    cardInfo.AwardIcon = awardItemInfo.Icon
    cardInfo.NoteMonthCardConfig = noteMonthCardTableRow
    cardInfo.ValidityPeriod = math.floor(Z.Global.MonthCardDay / 86400)
  end
  return cardInfo
end

function MonthlyRewardCardData:AssemblyData(monthlyCardId)
  if not monthlyCardId then
    return
  end
  local currentCardInfo = {}
  local cardInfo = self:GetCardInfo(monthlyCardId)
  currentCardInfo.CardInfo = cardInfo
  local privilegeTableData = self.monthCardPrivilegeTableMgr_.GetDatas()
  currentCardInfo.RewardList = {}
  for k, v in pairs(privilegeTableData) do
    local rewardInfo = {}
    rewardInfo.MonthCardPrivilegeConfig = v
    if v.Type == E.MonthlyAwardType.EReward or v.Type == E.MonthlyAwardType.EFixedItem then
      rewardInfo.AwardId = self:getMonthlyAwardId(v.SortId, cardInfo.MonthCardConfig)
      rewardInfo.AwardType = v.SortId
    end
    table.insert(currentCardInfo.RewardList, rewardInfo)
  end
  table.sort(currentCardInfo.RewardList, function(a, b)
    return a.MonthCardPrivilegeConfig.SortId < b.MonthCardPrivilegeConfig.SortId
  end)
  return currentCardInfo
end

function MonthlyRewardCardData:getMonthlyAwardId(type, monthCardConfig)
  local awardId
  if type == E.MonthlyAwardItemType.MonthLimitAwardId then
    awardId = monthCardConfig.MonthLimitAwardId
  elseif type == E.MonthlyAwardItemType.MonthAward then
    awardId = monthCardConfig.MonthAwardId
  elseif type == E.MonthlyAwardItemType.DayAward then
    awardId = monthCardConfig.DayAwardId
  end
  return awardId
end

function MonthlyRewardCardData:GetShowCardInfo()
  local monthlyCardData = Z.ContainerMgr.CharSerialize.monthlyCard.monthlyCardInfo
  self.showCardInfo_ = {}
  self.showListData_ = {}
  if not monthlyCardData then
    return self.showCardInfo_
  end
  for k, monthlyCardInfo in pairs(monthlyCardData) do
    self.showCardInfo_[k] = self:GetCardInfo(k)
    table.insert(self.showListData_, self.showCardInfo_[k])
  end
  return self.showListData_
end

function MonthlyRewardCardData:GetShowListDataByIndex(index)
  if not index then
    return {}
  end
  local data = self.showListData_[index] or {}
  return data
end

function MonthlyRewardCardData:GetShowListDataCount()
  return #self.showListData_
end

return MonthlyRewardCardData
