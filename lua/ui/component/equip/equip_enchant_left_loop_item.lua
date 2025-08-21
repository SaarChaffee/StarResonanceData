local super = require("ui.component.loop_list_view_item")
local EquipEnchantLeftLooItem = class("EquipEnchantLeftLooItem", super)
local item = require("common.item_binder")

function EquipEnchantLeftLooItem:ctor()
  self.itemVm_ = Z.VMMgr.GetVM("items")
end

function EquipEnchantLeftLooItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder.item
  })
end

function EquipEnchantLeftLooItem:OnRefresh(data)
  self.data_ = data
  self.count_ = self.itemVm_.GetItemTotalCount(self.data_.Id)
  self.name_ = ""
  local itemData = {
    uiBinder = self.uiBinder.item,
    configId = self.data_.Id,
    isShowOne = true,
    isShowZero = true,
    lab = self.count_,
    labType = E.ItemLabType.Str
  }
  self.itemClass_:RefreshByData(itemData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", self.data_.Id)
  if itemRow then
    self.name_ = itemRow.Name
    self.uiBinder.lab_name.text = self.name_
  end
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.node_steer, E.DynamicSteerType.EquipEnchantItemIndex, self.Index)
end

function EquipEnchantLeftLooItem:OnSelected(isSelected)
  if isSelected and self.count_ == 0 then
    Z.TipsVM.ShowTips(150027, {
      val = self.name_
    })
    self.parent:UnSelectIndex(self.Index)
    self.sourceTipsId_ = Z.TipsVM.OpenSourceTips(self.data_.Id, self.uiBinder.Trans, nil, {
      tipsBindPressCheckComp = self.uiView_.PressComp
    })
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  if isSelected then
    self.uiView_:OnSelectedItem(self.data_)
  end
end

function EquipEnchantLeftLooItem:OnRecycle()
  self.uiBinder.node_steer:ClearSteerList()
end

function EquipEnchantLeftLooItem:OnUnInit()
  self.uiBinder.node_steer:ClearSteerList()
  self.itemClass_:UnInit()
  if self.sourceTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipsId_)
  end
end

function EquipEnchantLeftLooItem:OnBeforePlayAnim()
end

return EquipEnchantLeftLooItem
