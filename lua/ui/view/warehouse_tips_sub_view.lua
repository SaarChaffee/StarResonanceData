local UI = Z.UI
local super = require("ui.ui_subview_base")
local Warehouse_tips_subView = class("Warehouse_tips_subView", super)

function Warehouse_tips_subView:ctor(parent)
  self.uiBinder = nil
  self.parent = parent
  super.ctor(self, "warehouse_tips_sub", "warehouse/warehouse_tips_sub", UI.ECacheLv.None)
  self.data_ = Z.DataMgr.Get("warehouse_data")
end

function Warehouse_tips_subView:initBinders()
  self.prefabCache_ = self.uiBinder.prefab_cache
  self.itemParent_ = self.uiBinder.node_materials
  self.tipsLab_ = self.uiBinder.lab_tips
  self.tipsIcon_ = self.uiBinder.img_icon
  self.presscheck_ = self.uiBinder.presscheck
end

function Warehouse_tips_subView:initBtns()
  self:AddClick(self.presscheck_.ContainGoEvent, function(icCheck)
    if not icCheck then
      self.parent:CloseWarehouseTipsSubView()
    end
  end)
end

function Warehouse_tips_subView:initUi()
  self.presscheck_:StartCheck()
  self.times_ = {}
end

function Warehouse_tips_subView:OnActive()
  self:initBinders()
  self:initBtns()
  self:initUi()
  self:loadItem()
end

function Warehouse_tips_subView:loadItem()
  local itemPath = self.prefabCache_:GetString("item")
  if itemPath == "" or itemPath == nil then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for type, warehouseTableRow in pairs(self.data_.WarehouseTableDatas) do
      local item = self:AsyncLoadUiUnit(itemPath, type, self.itemParent_.transform)
      local counterTableRow = Z.TableMgr.GetTable("CounterTableMgr").GetRow(warehouseTableRow.TakeCount)
      if counterTableRow then
        self:starTime(type, counterTableRow.TimeTableId, item.lab_time)
      end
      if item then
        item.lab_take_out.text = Lang("TakeCount") .. Z.CounterHelper.GetResidueLimitCountByCounterId(warehouseTableRow.TakeCount)
        item.lab_deposit.text = Lang("DepositCount") .. Z.CounterHelper.GetResidueLimitCountByCounterId(warehouseTableRow.DepositCount)
      end
      item.btn_binder.lab_normal.text = warehouseTableRow.Name
      self:AddClick(item.btn_materials, function()
        local itemList = self.data_:GetWarehouseCfgDataByType(type)
        local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
        awardPreviewVm.OpenRewardDetailViewByItemList(itemList, "Look")
      end)
    end
  end)()
end

function Warehouse_tips_subView:starTime(type, timerId, tmpText)
  local time = Z.TimeTools.GetTimeLeftInSpecifiedTime(timerId)
  if self.times_[type] == nil then
    self.times_[type] = self.timerMgr:StartTimer(function()
      time = time - 1
      if time <= 0 then
        time = Z.TimeTools.GetTimeLeftInSpecifiedTime(timerId)
      end
      tmpText.text = Z.TimeTools.FormatToDHM(time)
    end, 1, -1)
  end
end

function Warehouse_tips_subView:OnDeActive()
  self.presscheck_:StopCheck()
end

function Warehouse_tips_subView:OnRefresh()
end

return Warehouse_tips_subView
