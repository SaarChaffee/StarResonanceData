local UI = Z.UI
local super = require("ui.ui_subview_base")
local Warehouse_tips_subView = class("Warehouse_tips_subView", super)
local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")

function Warehouse_tips_subView:ctor(parent)
  self.uiBinder = nil
  self.parent = parent
  super.ctor(self, "warehouse_tips_sub", "warehouse/warehouse_tips_sub", UI.ECacheLv.None)
  self.data_ = Z.DataMgr.Get("warehouse_data")
  self.monthlyCardVM_ = Z.VMMgr.GetVM("monthly_reward_card")
  self.monthlyCardData_ = Z.DataMgr.Get("monthly_reward_card_data")
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
  self:AddClick(self.uiBinder.btn_arrow, function()
    Z.VMMgr.GetVM("gotofunc").GoToFunc(E.ShopFuncID.MonthlyCard)
  end)
end

function Warehouse_tips_subView:initUi()
  self.presscheck_:StartCheck()
  self.times_ = {}
end

function Warehouse_tips_subView:OnActive()
  self:initBinders()
  self:initBtns()
  self.warehouseType_ = self.viewData.type or E.WarehouseType.Normal
  self:initUi()
  self:loadItem()
end

function Warehouse_tips_subView:loadItem()
  local itemPath = self.prefabCache_:GetString("item")
  if itemPath == "" or itemPath == nil then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local list = self.data_:GetWarehouseTypeList(self.warehouseType_)
    for type, id in ipairs(list) do
      if id ~= -1 then
        local warehouseTableRow = Z.TableMgr.GetRow("WarehouseTableMgr", id)
        if warehouseTableRow then
          local item = self:AsyncLoadUiUnit(itemPath, type, self.itemParent_.transform)
          local counterTableRow = Z.TableMgr.GetTable("CounterTableMgr").GetRow(warehouseTableRow.HomeTakeCount)
          if counterTableRow then
            self:starTime(type, counterTableRow.TimeTableId, item.lab_time)
          end
          if item then
            item.lab_take_out.text = Lang("TakeCount") .. Z.CounterHelper.GetResidueLimitCountByCounterId(warehouseTableRow.HomeTakeCount)
            item.lab_deposit.text = Lang("DepositCount") .. Z.CounterHelper.GetResidueLimitCountByCounterId(warehouseTableRow.HomeDepositCount)
          end
          item.btn_binder.lab_normal.text = warehouseTableRow.Name
          self:AddClick(item.btn_materials, function()
            local itemList = self.data_:GetWarehouseCfgDataByType(type)
            local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
            awardPreviewVm.OpenRewardDetailViewByItemList(itemList, "Look")
          end)
        end
      end
    end
  end)()
end

function Warehouse_tips_subView:starTime(type, timerId, tmpText)
  local leftTime, beforeLeftTime = Z.TimeTools.GetLeftTimeByTimerId(timerId)
  local time = leftTime
  if leftTime <= 0 then
    time = beforeLeftTime
  end
  if self.times_[type] == nil then
    self.times_[type] = self.timerMgr:StartTimer(function()
      time = time - 1
      if time <= 0 then
        time = Z.TimeTools.GetLeftTimeByTimerId(timerId)
      end
      tmpText.text = Z.TimeFormatTools.FormatToDHMS(math.max(time, 0))
    end, 1, -1, nil, nil, true)
  end
end

function Warehouse_tips_subView:OnDeActive()
  self.presscheck_:StopCheck()
end

function Warehouse_tips_subView:OnRefresh()
  self:refreshMonthCardTips()
end

function Warehouse_tips_subView:refreshMonthCardTips()
  local warehouseType = self.warehouseType_ == E.WarehouseType.Normal and E.MonthCardPrivilegeLabType.NormalWarehouseCount or E.MonthCardPrivilegeLabType.HomeWarehouseCount
  local monthCardPrivilegeDesTableRow = self.monthlyCardVM_:MonthCardPrivilegeDesTableRow(warehouseType)
  if not gotoFuncVM.FuncIsOn(E.FunctionID.MonthlyCard, true) or monthCardPrivilegeDesTableRow.IsHide then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_warehouse_privilege, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_warehouse_privilege, true)
  local hasMonthlyCard = self.monthlyCardVM_:GetIsBuyCurrentMonthCard()
  local monthlyCardKey = self.monthlyCardVM_:GetActiveMonthlyCardKey()
  if monthlyCardKey == 0 then
    monthlyCardKey = self.monthlyCardVM_:GetCurrentMonthlyCardKey()
  end
  local monthlyCardData = self.monthlyCardData_:GetCardInfo(monthlyCardKey)
  if not monthlyCardData then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_warehouse_privilege, false)
    return
  end
  local labPrivilegeTitle = hasMonthlyCard and Lang("MonthlyCardPrivilegesIsOn") or Lang("MonthlyCardPrivileges")
  self.uiBinder.lab_title.text = labPrivilegeTitle
  if monthlyCardData then
    self.uiBinder.uiBinder_card.rimg_card:SetImage(monthlyCardData.ItemConfig.Icon)
  else
    hasMonthlyCard = false
  end
  if monthCardPrivilegeDesTableRow then
    self.uiBinder.lab_content.text = monthCardPrivilegeDesTableRow.PrivilegeDes
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_arrow, not hasMonthlyCard)
end

return Warehouse_tips_subView
