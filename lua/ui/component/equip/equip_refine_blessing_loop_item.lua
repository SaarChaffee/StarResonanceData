local super = require("ui.component.loop_list_view_item")
local EquipRefineBlessingItem = class("EquipRefineBlessingItem", super)
local item = require("common.item_binder")

function EquipRefineBlessingItem:ctor()
  self.itemData_ = nil
  super:ctor()
  self.equipRefineData_ = Z.DataMgr.Get("equip_refine_data")
end

function EquipRefineBlessingItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.parent.UIView:AddClick(self.uiBinder.btn_minus, function()
    if self.data_ then
      self.equipRefineData_.CurSelBlessingData[self.data_.configId] = nil
      Z.EventMgr:Dispatch(Z.ConstValue.Equip.EquipRefreshSelBlessingData)
    end
  end)
end

function EquipRefineBlessingItem:OnRefresh(data)
  self.data_ = data
  self.itemClass_:RefreshByData({
    uiBinder = self.uiBinder,
    configId = data.configId,
    labType = E.ItemLabType.Expend,
    lab = self.itemsVm_.GetItemTotalCount(data.configId),
    expendCount = data.num,
    isSquareItem = true
  })
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_minus, true)
end

function EquipRefineBlessingItem:OnUnInit()
  self.itemClass_:UnInit()
end

return EquipRefineBlessingItem
