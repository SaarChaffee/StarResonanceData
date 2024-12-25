local super = require("ui.component.loop_list_view_item")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local FishingRankingPlayerLoopItem = class("FishingRankingPlayerLoopItem", super)

function FishingRankingPlayerLoopItem:ctor()
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
end

function FishingRankingPlayerLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
end

function FishingRankingPlayerLoopItem:OnRefresh(data)
  self.data = data
  playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.com_head_46_item, self.data.rankData.playerData, function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(self.data.rankData.playerData.basicData.charID, self.parentUIView.cancelSource:CreateToken())
  end)
  self.uiBinder.node_lv.Ref.UIComp:SetVisible(self.data.rank <= 3)
  self.uiBinder.node_normal.Ref.UIComp:SetVisible(self.data.rank > 3)
  if self.data.rank <= 3 then
    self.uiBinder.node_lv.img_bg:SetImage(self.fishingData_.RankPathDict[self.data.rank])
    self.uiBinder.node_lv.lab_size.text = string.format(Lang("FishingSettlementLengthUnit"), self.data.rankData.size / 100)
    self.uiBinder.node_lv.lab_name.text = self.data.rankData.playerData.basicData.name
    self.uiBinder.node_lv.lab_digit.text = self.data.rank
  else
    self.uiBinder.node_normal.lab_size.text = string.format(Lang("FishingSettlementLengthUnit"), self.data.rankData.size / 100)
    self.uiBinder.node_normal.lab_name.text = self.data.rankData.playerData.basicData.name
    self.uiBinder.node_normal.lab_digit.text = self.data.rank
  end
end

function FishingRankingPlayerLoopItem:OnUnInit()
end

return FishingRankingPlayerLoopItem
