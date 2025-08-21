local super = require("ui.component.loop_list_view_item")
local HomeWarehouseOneLoopItem = class("HomeWarehouseOneLoopItem", super)
local itemClass = require("common.item_binder")

function HomeWarehouseOneLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.iconImg_ = self.uiBinder.img_icon
  self.numLab_ = self.uiBinder.lab_num
  self.bgImg_ = self.uiBinder.img_bg
  self.homeData_ = Z.DataMgr.Get("home_editor_data")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.homeEditorVm_ = Z.VMMgr.GetVM("home_editor")
  self.itemClass_ = itemClass.new(self.uiView_)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function HomeWarehouseOneLoopItem:OnRefresh(data)
  if self.uiView_.IsWarehouse then
    Z.EventMgr:Add(Z.ConstValue.Home.RefreshWareHouseCount, self.refreshCount, self)
    self.data_ = data
    self.totalCount_ = self.homeData_:GetFurnitureWarehouseItemCount(self.data_.configId)
    self.count_ = self.totalCount_
    local count = self.totalCount_ - (self.homeData_.LocalCreateHomeFurnitureDic[self.data_.configId] or 0)
    local itemData = {}
    itemData.uiBinder = self.uiBinder
    itemData.configId = self.data_.configId
    itemData.uuid = self.data_.uuid
    itemData.itemInfo = self.data_
    itemData.isClickOpenTips = false
    itemData.labType = E.ItemLabType.Str
    itemData.lab = 0 < count and count or Z.RichTextHelper.ApplyStyleTag(count, E.TextStyleTag.TipsRed)
    itemData.isShowZero = true
    itemData.isShowOne = true
    self.itemClass_:RefreshByData(itemData)
  else
    self.data_ = data
    local itemData = {}
    itemData.uiBinder = self.uiBinder
    itemData.configId = self.data_.itemId
    itemData.lab = 1
    itemData.isShowOne = true
    itemData.isClickOpenTips = false
    self.itemClass_:RefreshByData(itemData)
  end
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.uisteer, E.DynamicSteerType.HomeEditorItemIndex, self.homeData_.SelectedTypeId .. "=" .. self.Index)
end

function HomeWarehouseOneLoopItem:setCountLab()
  if self.uiView_.IsWarehouse then
    self.itemClass_:SetLab(self.count_ > 0 and self.count_ or Z.RichTextHelper.ApplyStyleTag(self.count_, E.TextStyleTag.TipsRed))
  end
end

function HomeWarehouseOneLoopItem:OnPointerClick(go, eventData)
  self.homeEditorVm_.OnClickWareHouseItem(self.data_.configId, self.count_, self.uiView_.IsWarehouse, self.data_.clientUuid)
end

function HomeWarehouseOneLoopItem:refreshCount(configId)
  if self.data_.configId == configId then
    self.totalCount_ = self.homeData_:GetFurnitureWarehouseItemCount(self.data_.configId)
    self.count_ = self.totalCount_ - (self.homeData_.LocalCreateHomeFurnitureDic[configId] or 0)
    self:setCountLab()
  end
end

function HomeWarehouseOneLoopItem:OnRecycle()
  self.uiBinder.rimg_icon.enabled = false
  if self.uiView_.IsWarehouse then
    Z.EventMgr:Remove(Z.ConstValue.Home.RefreshWareHouseCount, self.refreshCount, self)
  end
  self.uiBinder.uisteer:ClearSteerList()
end

function HomeWarehouseOneLoopItem:OnUnInit()
  if self.uiView_.IsWarehouse then
    Z.EventMgr:Remove(Z.ConstValue.Home.RefreshWareHouseCount, self.refreshCount, self)
  end
  self.uiBinder.uisteer:ClearSteerList()
end

return HomeWarehouseOneLoopItem
