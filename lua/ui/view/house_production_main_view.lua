local UI = Z.UI
local super = require("ui.ui_view_base")
local House_production_mainView = class("House_production_mainView", super)
local numMod = require("ui.view.exchange_num_module_tpl_view")
local loopGridView = require("ui.component.loop_grid_view")
local loopListView = require("ui.component.loop_list_view")
local materialsItem = require("ui.component.house.house_furniture_materials_loop_item")
local furnitureItem = require("ui.component.house.house_production_furniture_loop_item")
local productionListItem = require("ui.component.house.house_production_list_loop_item")
local currency_item_list = require("ui.component.currency.currency_item_list")

function House_production_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_production_main")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.numMod_ = numMod.new(self, "black")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.commonVm_ = Z.VMMgr.GetVM("common")
  self.homeEditorVm_ = Z.VMMgr.GetVM("home_editor")
end

function House_production_mainView:initBinders()
  self.titleLab_ = self.uiBinder.lab_title
  self.closeBtn_ = self.uiBinder.close_btn
  self.productionTog_ = self.uiBinder.tog_production_queue
  self.furnitureTog_ = self.uiBinder.tog_furniture_list
  self.togGroup_ = self.uiBinder.node_tog
  self.productionLoopList_ = self.uiBinder.loopscroll_production
  self.catalogueLoopList_ = self.uiBinder.loopscroll_catalogue
  self.bookBtn_ = self.uiBinder.btn_book.btn
  self.dpd_ = self.uiBinder.dpd
  self.dpdNode_ = self.uiBinder.node_dpd
  self.filterBtn_ = self.uiBinder.btn_filter
  self.sortBtn_ = self.uiBinder.btn_refresh
  self.anim_do_ = self.uiBinder.anim_do
  self.rightBinder_ = self.uiBinder.node_right
  self.productionIngNode_ = self.rightBinder_.node_right_bottom_1
  self.productionReadyNode_ = self.rightBinder_.node_right_bottom
  self.icon_ = self.rightBinder_.rimg_item_icon
  self.bindImg_ = self.rightBinder_.img_bind
  self.nameLab_ = self.rightBinder_.lab_item_name
  self.contentLab_ = self.rightBinder_.lab_current_number
  self.qualityBgImg_ = self.rightBinder_.img_name_quality_bg
  self.currentLab_ = self.rightBinder_.lab_current_number
  self.materialsLoopList_ = self.rightBinder_.loopscroll_materials
  self.costRImg_ = self.rightBinder_.rimg_cost
  self.costCountLab_ = self.rightBinder_.lab_cost
  self.needTimeLab_ = self.rightBinder_.lab_needtime
  self.productionBtn_ = self.rightBinder_.btn_production
  self.numParent_ = self.rightBinder_.node_num
  self.completeLab_ = self.rightBinder_.lab_complete
  self.ingNode_ = self.rightBinder_.node_ing
  self.remainingLab_ = self.rightBinder_.lab_remaining
  self.progressImg1_ = self.rightBinder_.img_progress_1
  self.progressImg2_ = self.rightBinder_.img_progress_2
  self.progressImg2_.fillAmount = 0
  self.rimg_monthly_card_bg = self.rightBinder_.rimg_monthly_card_bg
  self.getBtn_ = self.rightBinder_.btn_get.btn
  self.stopBtn_ = self.rightBinder_.btn_termination.btn
  self.skipBtn_ = self.rightBinder_.btn_obtained_directly.btn
end

function House_production_mainView:initData()
  self.productionType_ = 1
  self.isProduction_ = true
  self.isAscending_ = false
  self.curSelBuildFurnitureInfo_ = {}
end

function House_production_mainView:initUi()
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_item_list, {
    E.CurrencyType.Home
  })
  local options_ = {}
  self.commonVm_.SetLabText(self.titleLab_, E.FunctionID.HouseProduction)
  self.sortRuleTypeNames_ = {
    E.EquipItemSortType.Quality,
    E.EquipItemSortType.GS
  }
  self.equipSortTyp_ = E.EquipItemSortType.Quality
  options_ = {
    [1] = Lang("ColorOrder")
  }
  self.dpd_:ClearAll()
  self.dpd_:AddListener(function(index)
    self.equipSortTyp_ = self.sortRuleTypeNames_[index]
    self:setFurnitureList()
  end, true)
  self.rightBinder_.Ref.UIComp:SetVisible(false)
  self.dpd_:AddOptions(options_)
  if self.numMod_ then
    self.numMod_:Active({SetWidth = 510, tipsId = 1044013}, self.numParent_.transform)
  end
  self.productionListView_ = loopListView.new(self, self.productionLoopList_, productionListItem, "house_production_item_tpl")
  self.productionListView_:Init({})
  self.furnitureGridView_ = loopGridView.new(self, self.catalogueLoopList_, furnitureItem, "com_item_long_1")
  self.furnitureGridView_:Init({})
  self.materialsListView_ = loopListView.new(self, self.materialsLoopList_, materialsItem, "com_item_square_1_8")
  self.materialsListView_:Init({})
  self.productionTog_.group = self.togGroup_
  self.furnitureTog_.group = self.togGroup_
  self.productionTog_.isOn = true
  self.isProduction_ = true
  self:selectedTog()
end

function House_production_mainView:initBtns()
  self:AddClick(self.closeBtn_, function()
    self.houseVm_.CloseHouseProductionView()
  end)
  self:AddClick(self.bookBtn_, function()
    self.houseVm_.OpenHouseFurnitureGuideView()
  end)
  self:AddAsyncClick(self.getBtn_, function()
    self.houseVm_.AsyncBuildFurnitureReceive(self.selectedBuildInfo_.buildUuid, self.selectedBuildInfo_.furnitureId, self.selectedBuildInfo_.furnitureCount - self.selectedBuildInfo_.accelerateCount, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.skipBtn_, function()
    if self.selectedBuildInfo_ then
      self.houseVm_.OpenHoseGetItemView(self.selectedBuildInfo_)
    end
  end)
  self:AddClick(self.stopBtn_, function()
    local data = {
      dlgType = E.DlgType.YesNo,
      labTitle = Lang("CancelBuildHouseItemTitle"),
      labYes = Lang("BtnNameConfirm"),
      labNo = Lang("BtnNo"),
      labDesc = Lang("CancelBuildHouseItemContent"),
      onConfirm = function()
        self.houseVm_.AsyncBuildFurnitureCancel(self.selectedBuildInfo_.buildUuid, self.cancelSource:CreateToken())
      end
    }
    Z.DialogViewDataMgr:OpenDialogView(data)
  end)
  self:AddClick(self.sortBtn_, function()
    self.isAscending_ = not self.isAscending_
    self:setFurnitureList()
  end)
  self:AddClick(self.filterBtn_, function()
  end)
  self:AddAsyncClick(self.productionBtn_.btn, function()
    if self.selectedHousingItem_ and self.curNum_ > 0 then
      if self.currencyCount_ < self.expendCurrencyNum_ then
        Z.TipsVM.ShowTips(2504)
        return
      end
      local ret = self.houseVm_.AsyncCommunityBuildFurniture(self.selectedHousingItem_.Id, self.curNum_, self.cancelSource:CreateToken())
      if ret == 0 then
        self:OnSelectedFurnitureItem(self.selectedHousingItem_)
      end
    end
  end)
  self:AddClick(self.productionTog_, function(isOn)
    if isOn then
      self.isProduction_ = isOn
      self:onTogStartAnimShow()
      self.uiBinder.Ref:SetVisible(self.dpdNode_, false)
      self:selectedTog()
    end
  end)
  self:AddClick(self.furnitureTog_, function(isOn)
    if isOn then
      self.isProduction_ = false
      self:onTogStartAnimShow()
      self.uiBinder.Ref:SetVisible(self.dpdNode_, true)
      self:selectedTog()
    end
  end)
end

function House_production_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initBinders()
  self:onStartAnimShow()
  self:initData()
  self:initBtns()
  self.uiBinder.node_right.Ref.UIComp:SetVisible(false)
  Z.CoroUtil.create_coro_xpcall(function()
    self.homeEditorVm_.AsyncHomelandFurnitureWarehouseData()
    self.uiBinder.node_right.Ref.UIComp:SetVisible(true)
    self:initUi()
    Z.EventMgr:Add(Z.ConstValue.House.RefreshBuildList, self.refreshBuildList, self)
  end)()
end

function House_production_mainView:refreshBuildList()
  if self.isProduction_ then
    self:selectedTog()
    Z.TipsVM.ShowTips(1044011)
  end
end

function House_production_mainView:setFurnitureList()
  local list = self.houseVm_.GetUnlockFurnitureItemList(self.productionType_)
  table.sort(list, function(left, right)
    return self:getSortFunc()({
      configId = left.Id
    }, {
      configId = right.Id
    })
  end)
  self.furnitureGridView_:RefreshListView(list)
  self.furnitureGridView_:ClearAllSelect()
  self.furnitureGridView_:SetSelected(1)
end

function House_production_mainView:getSortFunc()
  return self.itemSortFactoryVm_.GetItemSortFunc(E.BackPackItemPackageType.FurnitureItem, {
    equipSortType = self.equipSortTyp_,
    isAscending = self.isAscending_
  })
end

function House_production_mainView:selectedTog()
  Z.CoroUtil.create_coro_xpcall(function()
    if self.isProduction_ then
      self.houseVm_.AsyncGetHomelandBuildFurnitureInfo(self.productionType_, self.cancelSource:CreateToken())
    end
    self.rightBinder_.Ref:SetVisible(self.productionIngNode_, self.isProduction_)
    self.rightBinder_.Ref:SetVisible(self.productionReadyNode_, not self.isProduction_)
    self.uiBinder.Ref:SetVisible(self.productionLoopList_, self.isProduction_)
    self.uiBinder.Ref:SetVisible(self.catalogueLoopList_, not self.isProduction_)
    self.rightBinder_.Ref.UIComp:SetVisible(false)
    if self.isProduction_ then
      local maxBuildCount = 0
      local cohabitantCount = self.houseData_:GetHomeCohabitantCount()
      for index, value in ipairs(Z.GlobalHome.BuildMaxCount) do
        if value[1] == self.productionType_ then
          maxBuildCount = value[2] * cohabitantCount
          break
        end
      end
      local list = {}
      for i = 1, maxBuildCount do
        list[i] = {}
      end
      self.productionListView_:ClearAllSelect()
      self.productionListView_:RefreshListView(list)
      self.productionListView_:SetSelected(1)
    else
      self:setFurnitureList()
    end
  end)()
end

function House_production_mainView:refreshSelectedItemTips(selectedConfigId)
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", selectedConfigId)
  if itemRow then
    self.nameLab_.text = itemRow.Name
    local itemVm = Z.VMMgr.GetVM("items")
    local itemIcon = itemVm.GetItemIcon(selectedConfigId)
    self.icon_:SetImage(itemIcon)
    self.contentLab_.text = itemRow.Description
  end
end

function House_production_mainView:refreshProductionInfo(isFinish)
  self.uiBinder.node_right.Ref:SetVisible(self.completeLab_, isFinish)
  self.uiBinder.node_right.btn_get.Ref.UIComp:SetVisible(isFinish)
  self.uiBinder.node_right.btn_termination.Ref.UIComp:SetVisible(not isFinish)
  self.uiBinder.node_right.btn_obtained_directly.Ref.UIComp:SetVisible(not isFinish)
  self.uiBinder.node_right.Ref:SetVisible(self.ingNode_, not isFinish)
end

function House_production_mainView:OnSelectedProductionItem(data)
  self.selectedBuildInfo_ = data
  if data.furnitureId then
    self:onItemStartAnimShow()
    self.rightBinder_.Ref.UIComp:SetVisible(true)
    local isFinish = data.endTime <= Z.ServerTime:GetServerTime() / 1000
    local configID = data.furnitureId
    self:refreshSelectedItemTips(configID)
    self:refreshProductionInfo(isFinish)
    if self.timer_ then
      self.timerMgr:StopTimer(self.timer_)
    end
    if not isFinish then
      local furnitureItemRow = Z.TableMgr.GetRow("HousingItemsMgr", data.furnitureId)
      if not furnitureItemRow then
        return
      end
      local time1 = furnitureItemRow.BuildTime * (data.furnitureCount - data.accelerateCount)
      local residueTime = math.ceil(data.endTime - Z.ServerTime:GetServerTime() / 1000)
      self.timer_ = self.timerMgr:StartTimer(function()
        local curTime = Z.ServerTime:GetServerTime() / 1000
        local residueTime = math.ceil(data.endTime - curTime)
        self.remainingLab_.text = Lang("RemainingTime:") .. Z.TimeFormatTools.FormatToDHMS(residueTime)
        self.progressImg1_.fillAmount = 1 - residueTime / time1
        if residueTime <= 0 then
          self:refreshProductionInfo(true)
        end
      end, 1, residueTime, nil, nil, true)
    end
  end
end

function House_production_mainView:OnSelectedFurnitureItem(data)
  self.rightBinder_.Ref.UIComp:SetVisible(true)
  self:onItemStartAnimShow()
  self.selectedHousingItem_ = data
  local configID = data.Id
  self:refreshSelectedItemTips(configID)
  local consumeId = data.ConsumeCash[1]
  local consumeNum = data.ConsumeCash[2]
  self.needTimeLab_.text = Lang("MakeNeedTime", {
    val = data.BuildTime
  })
  local consumeItemRow = Z.TableMgr.GetRow("ItemTableMgr", consumeId)
  if consumeItemRow then
    local itemVm = Z.VMMgr.GetVM("items")
    local itemIcon = itemVm.GetItemIcon(consumeId)
    self.costRImg_:SetImage(itemIcon)
    self.costCountLab_.text = consumeNum
  end
  local canBuyCount = -1
  for k, v in ipairs(data.Consume) do
    local configId = v[1]
    local expendCount = v[2]
    local ownNum = self.itemVm_.GetItemTotalCount(configId)
    local tmp = Mathf.Floor(ownNum / expendCount)
    if canBuyCount == -1 or canBuyCount > tmp then
      canBuyCount = tmp
    end
  end
  self.maxNum_ = canBuyCount
  self.minNum_ = 0
  if self.numMod_ then
    self.numMod_:changeExchangeItem(configID)
    self.numMod_:SetMoneyId(consumeId, consumeNum)
    self.numMod_:ReSetValue(self.minNum_, self.maxNum_, self.maxNum_, function(num)
      if num > self.maxNum_ then
        return
      end
      self.curNum_ = math.floor(num)
      self.materialsListView_:RefreshListView(data.Consume)
      self.productionBtn_.btn.IsDisabled = self.curNum_ == 0
      self.currencyCount_ = self.itemVm_.GetItemTotalCount(consumeId)
      self.expendCurrencyNum_ = self.curNum_ * consumeNum
      self.costCountLab_.text = self.currencyCount_ < self.expendCurrencyNum_ and Z.RichTextHelper.ApplyStyleTag(self.expendCurrencyNum_, E.TextStyleTag.TipsRed) or self.expendCurrencyNum_
      self.needTimeLab_.text = Lang("MakeNeedTime", {
        val = Z.TimeFormatTools.FormatToDHMS(data.BuildTime * self.curNum_)
      })
    end)
  end
end

function House_production_mainView:GetCurSelectedCount()
  return self.curNum_
end

function House_production_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.numMod_ then
    self.numMod_:DeActive()
  end
  if self.materialsListView_ then
    self.materialsListView_:UnInit()
    self.materialsListView_ = nil
  end
  if self.furnitureGridView_ then
    self.furnitureGridView_:UnInit()
    self.furnitureGridView_ = nil
  end
  if self.productionListView_ then
    self.productionListView_:UnInit()
    self.productionListView_ = nil
  end
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
end

function House_production_mainView:OnRefresh()
end

function House_production_mainView:onStartAnimShow()
  self.anim_do_:Restart(Z.DOTweenAnimType.Open)
end

function House_production_mainView:onTogStartAnimShow()
  self.anim_do_:Restart(Z.DOTweenAnimType.Tween_0)
end

function House_production_mainView:onItemStartAnimShow()
  self.anim_do_:Restart(Z.DOTweenAnimType.Tween_1)
end

function House_production_mainView:GetCurrentType()
  return self.productionType_
end

return House_production_mainView
