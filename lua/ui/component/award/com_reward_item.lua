local super = require("ui.component.loopscrollrectitem")
local ComRewardItem = class("ComRewardItem", super)
local item = require("common.item")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function ComRewardItem:OnInit()
  self.itemClass_ = item.new(self.parent.uiView)
end

function ComRewardItem:Refresh()
  local index_ = self.component.Index + 1
  self.data = self.parent:GetDataByIndex(index_)
  local itemData = {}
  itemData.unit = self.unit
  itemData.configId = self.data.awardId
  itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(self.data)
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isShowReceive = self.data.received
  itemData.isSquareItem = true
  itemData.PrevDropType = self.data.PrevDropType
  
  function itemData.goToCallFunc()
    Z.UIMgr:CloseView("reward_preview_popup")
  end
  
  self.itemClass_:Init(itemData)
  self.itemClass_:SetRedDot(false)
end

function ComRewardItem:OnPointerClick(go, eventData)
  Z.TipsVM.ShowItemTipsView(self.unit.Trans, self.data.awardId)
end

function ComRewardItem:OnUnInit()
  self.itemClass_:UnInit()
end

return ComRewardItem
