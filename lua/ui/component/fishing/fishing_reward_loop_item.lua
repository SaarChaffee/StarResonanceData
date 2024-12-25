local super = require("ui.component.loop_grid_view_item")
local FishingRewardLoopItem = class("FishingRewardLoopItem", super)
local loopListView = require("ui.component.loop_list_view")
local commonRewardItem = require("ui.component.explore_monster.explore_monster_reward_item")
local fishingRed = require("rednode.fishing_red")

function FishingRewardLoopItem:ctor()
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
end

function FishingRewardLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.awardScrollRect_ = loopListView.new(self.parentUIView, self.uiBinder.loop_list_item, commonRewardItem, "com_item_square_8")
  self.awardScrollRect_:Init({})
end

function FishingRewardLoopItem:OnRefresh(data)
  self.data = data
  self:SetCanSelect(false)
  self.uiBinder.lab_lv.text = data.FishingLevel
  self.uiBinder.lab_content.text = data.ExtraText
  local isGet = Z.ContainerMgr.CharSerialize.fishSetting.levelReward[data.FishingLevel]
  local canGet = self.fishingData_.FishingLevel >= data.FishingLevel
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_receive, canGet and not isGet)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_complete, isGet)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_ing, not canGet)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mark, isGet)
  self.uiBinder.btn_receive:RemoveAllListeners()
  if canGet and not isGet then
    self:AddAsyncListener(self.uiBinder.btn_receive, function()
      self.fishingVM_.GetLevelReward(self.data.FishingLevel, self.parentUIView.cancelSource:CreateToken())
    end)
  end
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local awardList = awardPreviewVm.GetAllAwardPreListByIds(data.ItemAward)
  for k, v in pairs(awardList) do
    v.beGet = self.state_ == E.TrialRoadTargetState.GetReward
  end
  self.awardScrollRect_:RefreshListView(awardList)
  fishingRed.LoadShopLevelAwardRedItem(data.FishingLevel, self.parentUIView, self.uiBinder.btn_receive_trans)
end

function FishingRewardLoopItem:OnUnInit()
  self:unInitLoopListView()
end

function FishingRewardLoopItem:unInitLoopListView()
  self.awardScrollRect_:UnInit()
  self.awardScrollRect_ = nil
end

return FishingRewardLoopItem
