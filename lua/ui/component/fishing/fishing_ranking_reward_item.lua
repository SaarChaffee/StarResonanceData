local super = require("ui.component.loop_list_view_item")
local FishingRankingRewardItem = class("FishingRankingRewardItem", super)
local loopListView = require("ui.component.loop_list_view")
local commonRewardItem = require("ui.component.explore_monster.explore_monster_reward_item")

function FishingRankingRewardItem:ctor()
end

function FishingRankingRewardItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.itemsListView_ = loopListView.new(self.parentUIView, self.uiBinder.loop_list_item, commonRewardItem, "com_item_square_8")
  self.itemsListView_:Init({})
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
end

function FishingRankingRewardItem:OnRefresh(data)
  local rankString = ""
  if data.minRank == data.maxRank - 1 then
    rankString = data.maxRank
  else
    rankString = string.zconcat(data.minRank, "-", data.maxRank)
  end
  self.uiBinder.lab_lv.text = rankString
  local fishingTableRow = Z.TableMgr.GetTable("FishingTableMgr").GetRow(data.fishId)
  self.uiBinder.lab_content.text = Lang("FishingRankRewardContent", {
    fishName = fishingTableRow.Name,
    rankStr = rankString
  })
  local awardList = self.awardPreviewVm_.GetAllAwardPreListByIds(data.awardPackageId)
  self.itemsListView_:RefreshListView(awardList)
end

function FishingRankingRewardItem:OnUnInit()
  self.itemsListView_:UnInit()
  self.itemsListView_ = nil
end

return FishingRankingRewardItem
