local UI = Z.UI
local super = require("ui.ui_subview_base")
local Tips_warehouse_tplView = class("Tips_warehouse_tplView", super)

function Tips_warehouse_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "tips_warehouse_tpl", "common_tips/tips_warehouse_tpl", UI.ECacheLv.None)
  self.vm_ = Z.VMMgr.GetVM("warehouse")
  self.socialVM_ = Z.VMMgr.GetVM("social")
  self.data_ = Z.DataMgr.Get("warehouse_data")
end

function Tips_warehouse_tplView:initBinders()
  self.numbModuleBinder_ = self.uiBinder.node_num_module_tpl
  self.selectedNumLab_ = self.numbModuleBinder_.lab_num
  self.maxBtn_ = self.numbModuleBinder_.btn_max
  self.minusBtn_ = self.numbModuleBinder_.btn_reduce
  self.addBtn_ = self.numbModuleBinder_.btn_add
  self.slider_ = self.numbModuleBinder_.slider_temp
  self.bindTipsLab_ = self.uiBinder.lab_tips
  self.materialsLab_ = self.uiBinder.lab_need_materials
  self.warehouseCountLab_ = self.uiBinder.lab_warehouse_count
end

function Tips_warehouse_tplView:TakeOutWarehouse()
  if self.viewData.warehouseGrid then
    self.vm_.AsyncTakeOutWarehouse(self.viewData.warehouseGrid.pos, self.selectedNum_, self.viewData.warehouseGrid.itemInfo.configId, self.viewData.warehouseGrid.ownerCharId, self.cancelSource:CreateToken())
    Z.TipsVM.CloseItemTipsView(self.viewData.tipsId)
  end
end

function Tips_warehouse_tplView:DepositWarehouse()
  self.vm_.AsyncDepositWarehouse(self.viewData.configId, self.viewData.itemUuid, self.selectedNum_, self.cancelSource:CreateToken())
  Z.TipsVM.CloseItemTipsView(self.viewData.tipsId)
end

function Tips_warehouse_tplView:initBtns()
  self:AddClick(self.maxBtn_, function()
    self.slider_.value = self.sliderMaxValue_
  end)
  self:AddClick(self.addBtn_, function()
    if self.selectedNum_ < self.sliderMaxValue_ then
      self.slider_.value = self.selectedNum_ + 1
    end
  end)
  self:AddClick(self.minusBtn_, function()
    if self.selectedNum_ > 0 then
      self.slider_.value = self.selectedNum_ - 1
    end
  end)
end

function Tips_warehouse_tplView:initUI()
  self.uiBinder.Ref:SetVisible(self.warehouseCountLab_, false)
  self.uiBinder.Ref:SetVisible(self.bindTipsLab_, false)
end

function Tips_warehouse_tplView:initData()
  self.configId_ = self.viewData.configId
  self.warehouseRow_ = {}
  self.isBind_ = false
  local warehouse = self.vm_.GetItemConfigWarehouse(self.configId_)
  if warehouse then
    self.isBind_ = warehouse[2] == 0
    self.warehouseRow_ = Z.TableMgr.GetTable("WarehouseTableMgr").GetRow(warehouse[1])
  end
  if self.viewData.warehouseGrid == nil then
    self:depositItem()
  else
    self:takeOutItem()
  end
end

function Tips_warehouse_tplView:OnActive()
  self:bindEvent()
end

function Tips_warehouse_tplView:depositItem()
  if self.warehouseRow_ == nil then
    return
  end
  local item = self.viewData.itemInfo
  local depositCount = Z.CounterHelper.GetCounterLimitCount(self.warehouseRow_.DepositCount)
  local residueCount = Z.CounterHelper.GetCounterResidueLimitCount(self.warehouseRow_.DepositCount, depositCount)
  self.sliderMaxValue_ = residueCount < item.count and residueCount or item.count
  local item = {
    name = self.warehouseRow_.Name
  }
  self.materialsLab_.text = Lang("WarehouseDepositItemTips", {item = item}) .. Lang("season_achievement_progress", {val1 = residueCount, val2 = depositCount})
  if self.isBind_ then
    self.bindTipsLab_.text = Lang("WarehouseDepositIBindItemTips")
    self.uiBinder.Ref:SetVisible(self.bindTipsLab_, true)
  end
  self.uiBinder.Ref:SetVisible(self.warehouseCountLab_, true)
  local warehouseItemCount, selfCount = self.vm_.GetItemCountAndCurCountByConfigId(self.configId_)
  local str = ""
  if 0 < selfCount then
    str = Lang("WarehouseDepositICountTips", {val = warehouseItemCount}) .. Lang("WarehouseSelfDepositICountTips", {val = selfCount})
  else
    str = Lang("WarehouseDepositICountTips", {val = warehouseItemCount})
  end
  self.warehouseCountLab_.text = str
  self:initNumSlider()
end

function Tips_warehouse_tplView:takeOutItem()
  if self.warehouseRow_ == nil then
    return
  end
  local warehouseGrid = self.viewData.warehouseGrid
  if warehouseGrid == nil then
    return
  end
  if warehouseGrid.ownerCharId == Z.ContainerMgr.CharSerialize.charBase.charId then
    self.materialsLab_.text = Lang("WarehouseGetSelfItemTips")
    self.sliderMaxValue_ = warehouseGrid.itemInfo.count
  else
    local takeCount = Z.CounterHelper.GetCounterLimitCount(self.warehouseRow_.TakeCount)
    local residueCount = Z.CounterHelper.GetCounterResidueLimitCount(self.warehouseRow_.TakeCount, takeCount)
    local item = {
      name = self.warehouseRow_.Name
    }
    self.materialsLab_.text = Lang("WarehouseGetItemTips", {item = item}) .. Lang("season_achievement_progress", {val1 = residueCount, val2 = takeCount})
    self.sliderMaxValue_ = residueCount < warehouseGrid.itemInfo.count and residueCount or warehouseGrid.itemInfo.count
    if self.isBind_ then
      self.bindTipsLab_.text = Lang("WarehouseGetBindItemTips")
      self.uiBinder.Ref:SetVisible(self.bindTipsLab_, true)
    end
  end
  self:initNumSlider()
end

function Tips_warehouse_tplView:initNumSlider()
  self.slider_.maxValue = self.sliderMaxValue_
  self.slider_.minValue = 1
  self.selectedNumLab_.text = 1
  self.slider_.value = 1
  self.selectedNum_ = 1
  self:AddClick(self.slider_, function(value)
    self.selectedNumLab_.text = math.floor(value)
    self.selectedNum_ = tonumber(value)
  end)
end

function Tips_warehouse_tplView:OnDeActive()
end

function Tips_warehouse_tplView:OnRefresh()
  if self.viewData then
    self:initBinders()
    self:initBtns()
    self:initUI()
    self:initData()
  end
end

function Tips_warehouse_tplView:removeWarehouseItem(pos, charId)
  if self.viewData and self.viewData.warehouseGrid and self.viewData.warehouseGrid.pos == pos and charId ~= Z.ContainerMgr.CharSerialize.charBase.charId then
    Z.TipsVM.ShowTips(122003)
    Z.TipsVM.CloseItemTipsView(self.viewData.tipsId)
  end
end

function Tips_warehouse_tplView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Warehouse.RemoveWarehouseItme, self.removeWarehouseItem, self)
end

return Tips_warehouse_tplView
