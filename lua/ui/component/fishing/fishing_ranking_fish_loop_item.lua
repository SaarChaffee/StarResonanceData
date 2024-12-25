local super = require("ui.component.loop_list_view_item")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local FishingRankingFishLoopItem = class("FishingRankingFishLoopItem", super)

function FishingRankingFishLoopItem:ctor()
end

function FishingRankingFishLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
end

function FishingRankingFishLoopItem:OnRefresh(data)
  self.data = data
  playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.com_head, self.data.rankData.playerData, nil)
  local fishingTableRow_ = Z.TableMgr.GetTable("FishingTableMgr").GetRow(self.data.fishId)
  self.uiBinder.rimg_icon:SetImage(fishingTableRow_.FishingIcon)
  self.uiBinder.rimg_mark:SetImage(fishingTableRow_.FishingIcon)
  self.uiBinder.lab_fish.text = fishingTableRow_.Name
  self.uiBinder.lab_size.text = self.data.rankData.size / 100
  if self.data.rankData.playerData.basicData then
    self.uiBinder.lab_name.text = self.data.rankData.playerData.basicData.name
  end
  self:SelectState()
end

function FishingRankingFishLoopItem:Selected(isSelected)
  if isSelected then
    self.parentUIView:OnClickRankItem(self.data.fishId)
  end
  self:SelectState()
end

function FishingRankingFishLoopItem:SelectState()
  local isSelected = self.IsSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
end

function FishingRankingFishLoopItem:OnSelected(isSelected)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.data = curData
  self:Selected(isSelected)
end

function FishingRankingFishLoopItem:OnUnInit()
end

return FishingRankingFishLoopItem
