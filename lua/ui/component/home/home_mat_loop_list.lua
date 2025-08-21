local super = require("ui.component.loop_list_view_item")
local HomeMatLoopItem = class("HomeMatLoopItem", super)
local itemClass = require("common.item_binder")

function HomeMatLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.homeData_ = Z.DataMgr.Get("home_editor_data")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.homeEditorVm_ = Z.VMMgr.GetVM("home_editor")
  self.itemClass_ = itemClass.new(self.uiView_)
  self.itemClass_:Init({
    uiBinder = self.uiBinder.item_binder
  })
end

function HomeMatLoopItem:OnRefresh(data)
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshWareHouseCount, self.refreshCount, self)
  self.data_ = data
  self.totalCount_ = self.homeData_:GetFurnitureWarehouseItemCount(self.data_.configId)
  self.count_ = self.totalCount_
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.data_.configId)
  if itemCfg then
    self.uiBinder.lab_name.text = itemCfg.Name
  end
  local count = self.totalCount_ - (self.homeData_.LocalCreateHomeFurnitureDic[self.data_.configId] or 0)
  local itemData = {}
  itemData.uiBinder = self.uiBinder.item_binder
  itemData.configId = self.data_.configId
  itemData.uuid = self.data_.uuid
  itemData.itemInfo = self.data_
  itemData.isClickOpenTips = false
  itemData.labType = E.ItemLabType.Str
  itemData.lab = 0 < count and count or Z.RichTextHelper.ApplyStyleTag(count, E.TextStyleTag.TipsRed)
  itemData.isShowZero = true
  itemData.isShowOne = true
  self.itemClass_:RefreshByData(itemData)
end

function HomeMatLoopItem:setCountLab()
  if self.uiView_.IsWarehouse then
    self.itemClass_:SetLab(self.count_ > 0 and self.count_ or Z.RichTextHelper.ApplyStyleTag(self.count_, E.TextStyleTag.TipsRed))
  end
end

function HomeMatLoopItem:OnPointerClick(go, eventData)
  self.homeEditorVm_.OnClickWareHouseItem(self.data_.configId, self.count_, true, self.uiView_:GetSelectedMatUuid())
end

function HomeMatLoopItem:refreshCount(configId)
  if self.data_.configId == configId then
    self.totalCount_ = self.homeData_:GetFurnitureWarehouseItemCount(self.data_.configId)
    self.count_ = self.totalCount_ - (self.homeData_.LocalCreateHomeFurnitureDic[configId] or 0)
    self:setCountLab()
  end
end

function HomeMatLoopItem:OnRecycle()
  if self.uiView_.IsWarehouse then
    Z.EventMgr:Remove(Z.ConstValue.Home.RefreshWareHouseCount, self.refreshCount, self)
  end
end

function HomeMatLoopItem:OnUnInit()
  if self.uiView_.IsWarehouse then
    Z.EventMgr:Remove(Z.ConstValue.Home.RefreshWareHouseCount, self.refreshCount, self)
  end
end

return HomeMatLoopItem
