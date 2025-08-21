local super = require("ui.component.loop_list_view_item")
local CollectionMembershipListItem = class("CollectionMembershipListItem", super)
local item = require("common.item_binder")

function CollectionMembershipListItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
end

function CollectionMembershipListItem:OnRefresh(data)
  if data.Type == E.FashionPrivilegeType.MoonGift then
    local itemData = {}
    itemData.configId = data.awardId
    itemData.labType, itemData.lab = self.awardPreviewVm_.GetPreviewShowNum(data)
    itemData.isShowZero = false
    itemData.isShowOne = true
    itemData.isShowReceive = data.beGet ~= nil and data.beGet
    itemData.isSquareItem = true
    itemData.PrevDropType = data.PrevDropType
    self.itemClass_:RefreshByData(itemData)
  elseif data.Type == E.FashionPrivilegeType.ExclusiveShop then
    local itemData = {
      configId = data.row.ItemId,
      labType = E.ItemLabType.Num,
      lab = data.Quantity,
      isShowZero = false,
      isShowOne = true,
      isSquareItem = true
    }
    self.itemClass_:RefreshByData(itemData)
  end
end

function CollectionMembershipListItem:OnUnInit()
  self.itemClass_:UnInit()
  self.awardPreviewVm_ = nil
end

return CollectionMembershipListItem
