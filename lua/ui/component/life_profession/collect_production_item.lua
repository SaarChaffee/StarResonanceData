local super = require("ui.component.loop_list_view_item")
local CollectProductionItem = class("CollectProductionItem", super)
local item = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function CollectProductionItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function CollectProductionItem:OnRefresh(data)
  if data == nil then
    return
  end
  local awardData_ = data.data
  local itemData = {}
  itemData.configId = awardData_.awardId
  itemData.uiBinder = self.uiBinder
  itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(awardData_)
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isShowReceive = awardData_.beGet ~= nil and awardData_.beGet
  itemData.isSquareItem = true
  itemData.PrevDropType = data.isExtra and E.AwardPrevDropType.Probability or awardData_.PrevDropType
  itemData.ShowTag = data.isExtra
  self.itemClass_:RefreshByData(itemData)
  self.itemClass_:SetImgLockState(not data.isUnlocked)
  local itemSellrow = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(awardData_.awardId, true)
  local trade = false
  if itemSellrow then
    trade = true
  end
  self.itemClass_:SetImgTradeState(not data.isFree and trade)
  if self.uiBinder.lab_prob then
    self.uiBinder.lab_prob.text = Lang("EquipExtraText")
  end
end

function CollectProductionItem:OnUnInit()
  self.itemClass_:UnInit()
end

function CollectProductionItem:OnRecycle()
  self.uiBinder.rimg_icon.enabled = false
end

return CollectProductionItem
