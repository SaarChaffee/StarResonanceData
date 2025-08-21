local super = require("ui.component.loop_grid_view_item")
local EquipForgetPreviewLooItem = class("EquipForgetPreviewLooItem", super)
local item = require("common.item_binder")

function EquipForgetPreviewLooItem:ctor()
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
end

function EquipForgetPreviewLooItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function EquipForgetPreviewLooItem:OnRefresh(data)
  self.data_ = data
  local itemData = {
    uiBinder = self.uiBinder,
    configId = data,
    isSquareItem = true,
    tipsBindPressCheckComp = self.uiView_:GetCheck()
  }
  self.itemClass_:RefreshByData(itemData)
end

function EquipForgetPreviewLooItem:OnUnInit()
  self.itemClass_:UnInit()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
end

function EquipForgetPreviewLooItem:OnBeforePlayAnim()
end

return EquipForgetPreviewLooItem
