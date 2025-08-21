local super = require("ui.component.loop_grid_view_item")
local ChatBackpackItem = class("ChatBackpackItem", super)
local item = require("common.item_binder")

function ChatBackpackItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
end

function ChatBackpackItem:OnUnInit()
  self.itemClass_:UnInit()
  self:closeTips()
end

function ChatBackpackItem:OnRefresh(data)
  self:closeTips()
  self.data_ = data
  local itemsVm = Z.VMMgr.GetVM("items")
  self.package_ = itemsVm.GetPackageInfobyItemId(data.configId)
  if self.package_ == nil then
    return
  end
  self.itemData_ = {
    uiBinder = self.uiBinder,
    configId = data.configId,
    uuid = data.itemUuid,
    itemInfo = self.package_.items[data.itemUuid],
    isClickOpenTips = false
  }
  self.itemClass_:Init(self.itemData_)
  if self.uiBinder.img_select then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  end
end

function ChatBackpackItem:OnSelected(isSelected)
  if isSelected then
    self.parent.UIView:OnSelectBackpackItem(self.data_)
    local extraParams = {
      itemInfo = self.itemData_.itemInfo
    }
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.Trans, self.itemData_.configId, self.itemData_.uuid, extraParams)
  end
  if self.uiBinder.img_select then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  end
end

function ChatBackpackItem:closeTips()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
end

return ChatBackpackItem
