local UI = Z.UI
local super = require("ui.ui_view_base")
local Warehouse_mainView = class("Warehouse_mainView", super)
local loopGridView = require("ui/component/loop_grid_view")
local toggleGroup = require("ui/component/togglegroup")
local warehouse_firstclass_loop_item = require("ui.component.warehouse.warehouse_firstclass_loop_item")
local warehouseLoopItem = require("ui.component.warehouse.warehouse_loop_item")
local warehouseBagLoopItem = require("ui.component.warehouse.warehouse_bag_loop_item")
local currency_item_list = require("ui.component.currency.currency_item_list")

function Warehouse_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "warehouse_main")
  self.vm_ = Z.VMMgr.GetVM("warehouse")
  self.houseVm_ = Z.VMMgr.GetVM("house_warehouse")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.data_ = Z.DataMgr.Get("warehouse_data")
  self.warehouseTipsSubView_ = require("ui/view/warehouse_tips_sub_view").new(self)
  self.currencyVm_ = Z.VMMgr.GetVM("currency")
end

function Warehouse_mainView:initBinders()
  self.closeBtn_ = self.uiBinder.btn_close
  self.memberBtn_ = self.uiBinder.btn_member
  self.warehouseLoopGridView_ = self.uiBinder.left_loop_item
  self.bagLoopGridView_ = self.uiBinder.right_loop_item
  self.firstClassTogGroup_ = self.uiBinder.firstClassTogGroup
  self.accessBtn_ = self.uiBinder.btn_access
  self.volumeLab_ = self.uiBinder.lab_volume
  self.takeLab_ = self.uiBinder.lab_take
  self.depositLab_ = self.uiBinder.lab_deposit
  self.wareTipsParent_ = self.uiBinder.ware_tips_parent
  self.node_empty = self.uiBinder.node_empty
  self.tipsLeftParent_ = self.uiBinder.node_tips_left
  self.tipsRightParent_ = self.uiBinder.node_tips_right
  self.node_eff = self.uiBinder.node_loop_eff
  self.anim_do_ = self.uiBinder.anim_do
end

function Warehouse_mainView:initBtns()
  self:AddAsyncClick(self.closeBtn_, function()
    self.vm_.CloseWareView()
  end)
  self:AddClick(self.memberBtn_, function()
    self.vm_.OpenWareMmberPopupView()
  end)
  self:AddClick(self.accessBtn_, function()
    self.warehouseTipsSubView_:Active({
      type = self.warehouseType_
    }, self.wareTipsParent_.transform)
  end)
end

function Warehouse_mainView:initData()
  self.warehouseTab_ = {
    [E.WarehouseType.Normal] = {
      WarehouseCapacity = Z.Global.WarehouseCapacity
    },
    [E.WarehouseType.House] = {
      WarehouseCapacity = Z.GlobalHome.HouseWarehouseCapacity
    }
  }
  self.warehouseType_ = self.viewData or E.WarehouseType.Normal
  if self.warehouseType_ == E.WarehouseType.Normal then
    self.vm_.AsyncGetWarehouse(self.cancelSource:CreateToken())
  elseif self.warehouseType_ == E.WarehouseType.House then
    self.houseVm_.AsyncGetWarehouse(self.cancelSource:CreateToken())
  end
end

function Warehouse_mainView:initUi()
  self.wareLoopGrid_ = loopGridView.new(self, self.warehouseLoopGridView_, warehouseLoopItem, "com_item_long_2")
  self.wareLoopGrid_:Init({})
  self.bagLoopGrid_ = loopGridView.new(self, self.bagLoopGridView_, warehouseBagLoopItem, "com_item_long_2")
  self.bagLoopGrid_:Init({})
  self.node_empty.Ref.UIComp:SetVisible(false)
  local currencyIds = self.currencyVm_.GetCurrencyIds()
  local isHouseWarehouse = self.warehouseType_ == E.WarehouseType.House
  self.uiBinder.currency_info.Ref.UIComp:SetVisible(not isHouseWarehouse)
  self.uiBinder.Ref:SetVisible(self.memberBtn_, not isHouseWarehouse)
  self.currencyItemList_:Init(self.uiBinder.currency_info, currencyIds)
  local data = self.data_:GetWarehouseTypeList(self.warehouseType_)
  local initIndex = 1
  self.firstClassToggleGroup_ = toggleGroup.new(self.firstClassTogGroup_, warehouse_firstclass_loop_item, data, self, Z.ConstValue.LoopItembindName.back_toggle_item)
  self.firstClassToggleGroup_:Init(initIndex, function(index)
    if index == 1 then
      self:OnSecondClassSelected(-1)
    else
      self:OnSecondClassSelected(data[index])
    end
  end)
end

function Warehouse_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.isFirstOpen_ = true
  self:initBinders()
  self:onStartAnimShow()
  self:initBtns()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.node_eff)
  self.node_eff:SetEffectGoVisible(true)
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {})
  Z.CoroUtil.create_coro_xpcall(function()
    self:initData()
    self:initUi()
    self:bindEvent()
  end)()
end

function Warehouse_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.node_eff)
  self.node_eff:SetEffectGoVisible(false)
  self.isFirstOpen_ = false
  if self.bagLoopGrid_ then
    self.bagLoopGrid_:UnInit()
    self.bagLoopGrid_ = nil
  end
  if self.wareLoopGrid_ then
    self.wareLoopGrid_:UnInit()
    self.wareLoopGrid_ = nil
  end
  if self.secondClassListView_ then
    self.secondClassListView_:UnInit()
    self.secondClassListView_ = nil
  end
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  if self.refreshLab_ then
    Z.ContainerMgr.CharSerialize.counterList.Watcher:UnregWatcher(self.refreshLab_)
    self.refreshLab_ = nil
  end
  if self.firstClassToggleGroup_ ~= nil then
    self.firstClassToggleGroup_:UnInit()
  end
  self:CloseWarehouseTipsSubView()
  if self.currencyItemList_ then
    self.currencyItemList_:UnInit()
    self.currencyItemList_ = nil
  end
end

function Warehouse_mainView:CloseWarehouseTipsSubView()
  self.warehouseTipsSubView_:DeActive()
end

function Warehouse_mainView:OnSecondClassSelected(type)
  self.uiBinder.Ref:SetVisible(self.takeLab_, type ~= -1)
  self.uiBinder.Ref:SetVisible(self.depositLab_, type ~= -1)
  if not self.isFirstOpen_ then
    self.anim_do_:Restart(Z.DOTweenAnimType.Tween_0)
  end
  self.isFirstOpen_ = false
  self.type_ = type
  self:refreshLab()
  self:refreshWarehouseLoopGrid()
  self:refreshBagLoopGrid()
end

function Warehouse_mainView:refreshBagLoopGrid()
  local data = self.vm_.GetBagItemsByType(self.type_)
  self.bagLoopGrid_:RefreshListView(data)
end

function Warehouse_mainView:refreshWarehouseLoopGrid()
  local data = self.vm_.GetWarehouseItemsByType(self.type_, self.warehouseType_)
  self.wareLoopGrid_:RefreshListView(data)
  self:setpackageCountUi()
end

function Warehouse_mainView:openTips(item, trans, warehouseGrid)
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  local itemTipsViewData = {}
  itemTipsViewData.configId = item.configId
  itemTipsViewData.itemUuid = item.uuid
  itemTipsViewData.isWarehouse = true
  itemTipsViewData.showType = E.EItemTipsShowType.Default
  itemTipsViewData.posType = E.EItemTipsPopType.Parent
  itemTipsViewData.isHideSource = true
  itemTipsViewData.parentTrans = trans
  itemTipsViewData.itemInfo = item
  itemTipsViewData.isShowBg = true
  itemTipsViewData.isResident = false
  itemTipsViewData.warehouseGrid = warehouseGrid
  itemTipsViewData.isHideMaterial = true
  itemTipsViewData.warehouseType = self.warehouseType_
  self.tipsId_ = Z.TipsVM.OpenItemTipsView(itemTipsViewData)
end

function Warehouse_mainView:OnSelectedWarehouseItem(data, trans)
  self:openTips(data.itemInfo, self.tipsRightParent_.transform, data)
end

function Warehouse_mainView:OnSelectedBagItem(data, trans)
  self:openTips(data, self.tipsLeftParent_.transform)
end

function Warehouse_mainView:quitWarehouse()
  self.vm_.CloseWareView()
end

function Warehouse_mainView:bagItemChange(item)
  if self.vm_.CheckConfigIdIsGotoWarehouse(item.configId) then
    self:refreshBagLoopGrid()
  end
end

function Warehouse_mainView:refreshWarehouse()
  if self.type_ then
    self:refreshWarehouseLoopGrid()
    self:refreshBagLoopGrid()
  end
end

function Warehouse_mainView:bindEvent()
  function self.refreshLab_(container, dirtys)
    self:refreshLab(container, dirtys)
  end
  
  Z.ContainerMgr.CharSerialize.counterList.Watcher:RegWatcher(self.refreshLab_)
  Z.EventMgr:Add(Z.ConstValue.Warehouse.WarehouseExistDisband, self.quitWarehouse, self)
  Z.EventMgr:Add(Z.ConstValue.Warehouse.WarehouseExistBeKickOut, self.quitWarehouse, self)
  Z.EventMgr:Add(Z.ConstValue.Warehouse.OnWarehouseItemChange, self.refreshWarehouseLoopGrid, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.OpenPrivateChat, self.quitWarehouse, self)
  Z.EventMgr:Add(Z.ConstValue.Warehouse.RefreshWarehouse, self.refreshWarehouse, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.bagItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.bagItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.bagItemChange, self)
end

function Warehouse_mainView:refreshLab()
  if self.type_ ~= -1 then
    self.takeLab_.text = Lang("TakeCount") .. self.vm_.GetResidueTakeCountByType(self.type_, self.warehouseType_)
    self.depositLab_.text = Lang("DepositCount") .. self.vm_.GetResidueDepositCountByType(self.type_, self.warehouseType_)
  end
end

function Warehouse_mainView:setpackageCountUi()
  local capacity = self.warehouseTab_[self.warehouseType_].WarehouseCapacity
  local curCount = self.vm_.GetWarehouseItemCount(self.warehouseType_)
  local str = curCount .. "/" .. capacity
  if capacity < curCount then
    str = Z.RichTextHelper.ApplyStyleTag(str, E.TextStyleTag.TipsRed)
  else
    str = Z.RichTextHelper.ApplyStyleTag(str, E.TextStyleTag.White)
  end
  self.volumeLab_.text = string.zconcat(Lang("Capacity"), ": ", str)
end

function Warehouse_mainView:OnRefresh()
end

function Warehouse_mainView:onStartAnimShow()
  self.anim_do_:Restart(Z.DOTweenAnimType.Open)
end

return Warehouse_mainView
