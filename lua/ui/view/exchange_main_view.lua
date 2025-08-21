local UI = Z.UI
local super = require("ui.ui_view_base")
local Exchange_mainView = class("Exchange_mainView", super)
local loopGridView = require("ui/component/loop_grid_view")
local loopListView = require("ui/component/loop_list_view")
local exchange_catalogue_item = require("ui.component.compose.exchange_catalogue_loop_item")
local exchange_materials_item = require("ui.component.compose.exchange_materials_loop_item")
local exchange_condition_item = require("ui.component.compose.exchange_condition_loop_item")
local numMod = require("ui.view.exchange_num_module_tpl_view")
local qualityPath = "ui/atlas/permanent/com_lab_quality_"
local currency_item_list = require("ui.component.currency.currency_item_list")
local refreshType2Desc = {
  [0] = "RemainingNum",
  [1] = "RemainingNumToday",
  [2] = "RemainingNumToday",
  [3] = "RemainingNumThisWeek",
  [4] = "RemainingNumThisWeek",
  [5] = "RemainingNumSeason",
  [6] = "RemainingNumSeason",
  [14] = "RemainingNumToday",
  [15] = "RemainingNumToday",
  [16] = "RemainingNumThisWeek",
  [17] = "RemainingNumThisWeek",
  [18] = "RemainingNumSeason",
  [24] = "RemainingNumMonth"
}

function Exchange_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "exchange_main")
  self.itemTraceView_ = require("ui.view.main_item_trace_sub_view").new()
  self.numMod_ = numMod.new(self, "black")
  self.exchangeVM_ = Z.VMMgr.GetVM("exchange")
  self.preview_ = Z.VMMgr.GetVM("item_preview")
  self.fashionVm_ = Z.VMMgr.GetVM("fashion")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemTraceVM_ = Z.VMMgr.GetVM("item_trace")
  self.weaponVM_ = Z.VMMgr.GetVM("weapon")
  self.professionConfigs_ = {}
  local index = 0
  local tempConfigs = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetDatas()
  for _, config in pairs(tempConfigs) do
    if config.IsOpen then
      index = index + 1
      self.professionConfigs_[index] = config
    end
  end
end

function Exchange_mainView:inituiBinders()
  self.numModRootTrans_ = self.uiBinder.group_num
  self.closeBtn_ = self.uiBinder.btn_close
  self.titleLab_ = self.uiBinder.lab_title
  self.img_icon = self.uiBinder.img_icon
  self.confirmBtn_ = self.uiBinder.btn_confirm
  self.bgBtn_ = self.uiBinder.btn_bg
  self.rightLab_ = self.uiBinder.lab_num_right
  self.upperlimitLab_ = self.uiBinder.lab_needitem
  self.tipsTras_ = self.uiBinder.node_item_tips
  self.materialsLoopList_ = self.uiBinder.loopscroll_materials
  self.catalogueLooGrid_ = self.uiBinder.loopscroll_catalogue
  self.conditionList_ = self.uiBinder.loop_condition_item
  self.conditionNode_ = self.uiBinder.node_condition
  self.bottomNode_ = self.uiBinder.node_bottom
  self.labCur_ = self.uiBinder.lab_info
  self.numGroup_ = self.uiBinder.group_num
  self.traceBtn_ = self.uiBinder.btn_material_tracking
  self.group_item_trace_ = self.uiBinder.group_item_trace
end

function Exchange_mainView:initBtns()
  self:AddClick(self.closeBtn_, function()
    self.exchangeVM_.CloseExchangeView()
  end)
  self:AddClick(self.bgBtn_, function()
    self:closeItemInfoTips()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self:onAskBtnClick()
  end)
  self:AddClick(self.traceBtn_.btn, function()
    self.itemTraceVM_.TraceExchangeItem(self.exchangeItemData_.itemId, self.consumeList_)
    if self.traceTimer_ then
      self.timerMgr:StopTimer(self.traceTimer_)
      self.traceTimer_ = nil
    end
    self.itemTraceView_:Active(E.ItemTracePosType.Right, self.group_item_trace_.transform)
    self.traceTimer_ = self.timerMgr:StartTimer(function()
      self.itemTraceView_:DeActive()
      self.traceTimer_ = nil
    end, 1, 1)
  end)
  self:AddAsyncClick(self.confirmBtn_, function()
    if self.exchangeChance_ <= 0 and self.limitType ~= E.ExchangeLimitType.Not then
      Z.TipsVM.ShowTipsLang(100113)
      return
    elseif self.canExchangeMinNum_ == 0 or self.curNum_ > self.canExchangeMinNum_ then
      Z.TipsVM.ShowTipsLang(100002)
      return
    end
    if self:checkIsCurProfessionEquip() then
      self:buyExchangeGoods()
    else
      Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("ExchangeNotCurProfessionItem"), function()
        self:buyExchangeGoods()
      end, nil, E.DlgPreferencesType.Day, E.DlgPreferencesKeyType.ExchangeShopExchangeNoCurProfession)
    end
  end)
  self.uiBinder.node_dpd.dpd:AddListener(function(index)
    if self.professionConfigs_[index + 1].ProfessionId == self.filterProfessionId_ then
      return
    end
    self.filterProfessionId_ = self.professionConfigs_[index + 1].ProfessionId
    local list = self.exchangeVM_.GetGoodsIdListByShopId(self.shopId_, self.filterProfessionId_)
    self.catalogueScrollRect_:RefreshListView(list)
    self.catalogueScrollRect_:SetSelected(1)
    if list and 0 < #list then
      self:SelectGoods(list[1])
    end
  end, true)
end

function Exchange_mainView:ShowTips()
  local exchangeItemRow = Z.TableMgr.GetTable("ExchangeItemTableMgr").GetRow(self.exchangeItemData_.goodsId)
  if exchangeItemRow then
    local configId = exchangeItemRow.GetItemId
    self:showItemInfoTips(configId)
  end
end

function Exchange_mainView:checkCondition()
  if self.exchangeItemData_.conditionData and #self.exchangeItemData_.conditionData > 0 then
    self.conditionRectList_:RefreshListView(self.exchangeItemData_.conditionData)
  end
end

function Exchange_mainView:SelectGoods(exchangeItemData)
  self.exchangeItemData_ = exchangeItemData
  self:checkCondition()
  self.uiBinder.Ref:SetVisible(self.conditionNode_, not self.exchangeItemData_.isUnlock)
  self.uiBinder.Ref:SetVisible(self.bottomNode_, self.exchangeItemData_.isUnlock)
  self.uiBinder.Ref:SetVisible(self.confirmBtn_, self.exchangeItemData_.isUnlock)
  self.uiBinder.Ref:SetVisible(self.upperlimitLab_, self.exchangeItemData_.isUnlock)
  if self.exchangeItemData_.isUnlock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_currency_cost, false)
  end
  self.uiBinder.btn_preview_btn:RemoveAllListeners()
  local exchangeItemRow = Z.TableMgr.GetTable("ExchangeItemTableMgr").GetRow(self.exchangeItemData_.goodsId)
  if exchangeItemRow ~= nil then
    local itemConfigId = exchangeItemRow.GetItemId
    local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemConfigId)
    if itemCfg then
      self.uiBinder.lab_item_name.text = itemCfg.Name
      self.uiBinder.rimg_item_icon:SetImage(itemCfg.Icon)
      self.uiBinder.img_name_quality_bg:SetImage(qualityPath .. itemCfg.Quality)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bind, exchangeItemRow.Bind == 1)
    local canPreview = self.fashionVm_.CheckIsFashion(itemConfigId)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_preview, canPreview)
    self:AddClick(self.uiBinder.btn_preview_btn, function()
      self.preview_.GotoPreview(itemConfigId)
    end)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info, self.exchangeItemData_.isUnlock)
  self:refreshNumShowState(self.exchangeItemData_)
  if self.exchangeItemData_.isUnlock then
    self:refreshMaterialsData()
    self:refreshGoodsExchangeNum()
    self:refreshExchangeBtn()
    self:setRightLimitDes()
  end
end

function Exchange_mainView:setRightLimitDes()
  local exchangeItemRow = Z.TableMgr.GetTable("ExchangeItemTableMgr").GetRow(self.exchangeItemData_.goodsId)
  if exchangeItemRow == nil then
    return
  end
  local itemId = exchangeItemRow.GetItemId
  local complete = self.exchangeChance_ <= 0
  local itemVM = Z.VMMgr.GetVM("items")
  local isFashion = self.fashionVm_.CheckIsFashion(itemId)
  local count = itemVM.GetItemTotalCount(itemId)
  local fashionComplete = isFashion and (0 < count or complete)
  self.upperlimitLab_.text = fashionComplete and Lang("ExchangeFashionNumLimit") or Lang("ExchangeNumLimit")
end

function Exchange_mainView:SelectConsumeItem(configId)
  self:showItemInfoTips(configId)
end

function Exchange_mainView:GetCacheData()
  return table.zclone(self.viewData)
end

function Exchange_mainView:OnActive()
  Z.UIMgr:FadeIn({
    IsInstant = true,
    TimeOut = Z.UICameraHelperFadeTime
  })
  self:inituiBinders()
  self:initBtns()
  if self.numMod_ then
    self.numMod_:Active({SetWidth = 510}, self.numModRootTrans_.transform)
  end
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.curNum_ = 1
  self.maxNum_ = 0
  self.minNum_ = 0
  self.canExchangeMinNum_ = 0
  self.shopId_ = self.viewData.shopId
  self.npcId = self.viewData.npcId
  self.shopInfo_ = Z.ContainerMgr.CharSerialize.exchangeItems.exchangeInfo[self.shopId_]
  self.exchangeItemData_ = {}
  self.exchangeChance_ = 0
  self.isConsumeItemEnough_ = false
  self.itemTipsId_ = nil
  self.consumeList_ = {}
  self.filterProfessionId_ = nil
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {})
  self.exchangeConfig_ = Z.TableMgr.GetTable("ExchangeTableMgr").GetRow(self.shopId_)
  if self.exchangeConfig_ then
    self.titleLab_.text = self.exchangeConfig_.ShopName
    local funcCfg = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(self.exchangeConfig_.SystemId)
    if funcCfg then
      self.img_icon:SetImage(funcCfg.Icon)
    end
    if 0 < table.zcount(self.exchangeConfig_.CurrencyDisplay) then
      self.currencyItemList_:Init(self.uiBinder.currency_info, self.exchangeConfig_.CurrencyDisplay)
      self.isOpenCurrency_ = true
    end
    if self.exchangeConfig_.ExchangeBtnName ~= "" then
      self.uiBinder.lab_content.text = self.exchangeConfig_.ExchangeBtnName
    else
      self.uiBinder.lab_content.text = Lang("Exchange")
    end
    if self.exchangeConfig_.Screen and self.exchangeConfig_.Screen ~= 0 then
      self.filterProfessionId_ = self.weaponVM_.GetCurWeapon()
    end
  end
  if self.filterProfessionId_ ~= nil then
    self.uiBinder.node_dpd.Ref.UIComp:SetVisible(true)
    self.uiBinder.node_dpd.dpd:ClearOptions()
    self.uiBinder.node_dpd.dpd:AddOptions(self:getFilterProfessionName())
    self.uiBinder.node_dpd.dpd.value = self:getIndexByProfessionId(self.filterProfessionId_)
    self.uiBinder.node_left_topandbottom:SetSizeDelta(512, -272)
  else
    self.uiBinder.node_dpd.Ref.UIComp:SetVisible(false)
    self.uiBinder.node_left_topandbottom:SetSizeDelta(512, -185)
  end
  self.conditionRectList_ = loopListView.new(self, self.conditionList_, exchange_condition_item, "exchange_task_tpl")
  self.conditionRectList_:Init({})
  self.catalogueScrollRect_ = loopGridView.new(self, self.catalogueLooGrid_, exchange_catalogue_item, "exchange_item_tpl")
  local list = self.exchangeVM_.GetGoodsIdListByShopId(self.shopId_, self.filterProfessionId_)
  self.catalogueScrollRect_:Init(list)
  self.catalogueScrollRect_:SetSelected(1)
  if list and 0 < #list then
    self:SelectGoods(list[1])
  else
    return
  end
  self.curConsumeList_ = self.exchangeVM_.GetConsumeItemDataListByGoodsId(self.exchangeItemData_.goodsId)
  self:checkSpecialCostItem(self.curConsumeList_)
  self.loopScroll_materialsRect_ = loopListView.new(self, self.materialsLoopList_, exchange_materials_item, "com_item_square_1_8")
  self.loopScroll_materialsRect_:Init(self.curConsumeList_)
  self.exchangeVM_.RegGoodsChangeWatcherByShopId(self.shopId_)
  self:BindEvents()
  self:initCamera()
  self.exchangeVM_.ResetEntityAndUIVisible(true)
end

function Exchange_mainView:checkSpecialCostItem(consumeList)
  local isShowSpecial = false
  local specialId = 0
  local specialCount = 0
  local ownCount = 0
  for i = #consumeList, 1, -1 do
    for j = 1, #Z.Global.ExchangeSpecialItemId do
      if consumeList[i].id == Z.Global.ExchangeSpecialItemId[j] then
        specialId = Z.Global.ExchangeSpecialItemId[j]
        specialCount = consumeList[i].consumeNum
        ownCount = consumeList[i].ownNum
        table.remove(consumeList, i)
        isShowSpecial = true
        break
      end
    end
  end
  if not isShowSpecial or self.cantExchange_ then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_currency_cost, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_currency_cost, true)
    local type = specialCount > ownCount and E.TextStyleTag.TipsRed or E.TextStyleTag.TipsGreen
    self.uiBinder.lab_cost.text = Z.RichTextHelper.ApplyStyleTag(specialCount, type)
    local itemTableData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(specialId)
    if itemTableData then
      local itemsVm = Z.VMMgr.GetVM("items")
      self.uiBinder.rimg_cost:SetImage(itemsVm.GetItemIcon(specialId))
    end
  end
end

function Exchange_mainView:initCamera()
  if self.exchangeConfig_ then
    if self.exchangeConfig_.SystemId == E.ExchangeFuncId.UnionExchange then
      local unionVM = Z.VMMgr.GetVM("union")
      local buildConfig = unionVM:GetUnionBuildConfig(E.UnionBuildId.Mall)
      Z.CameraMgr:CameraInvoke(E.CameraState.Position, true, buildConfig.CameraTemplateId, false)
    elseif #self.exchangeConfig_.CameraTemplateId > 0 then
      Z.CameraMgr:CameraInvoke(E.CameraState.Position, true, self.exchangeConfig_.CameraTemplateId, false)
    else
      Z.NpcBehaviourMgr:SetDialogCameraByConfigId(301, self.npcId)
    end
  end
end

function Exchange_mainView:unInitCamera()
  if self.exchangeConfig_ then
    if self.exchangeConfig_.SystemId == E.ExchangeFuncId.UnionExchange then
      local unionVM = Z.VMMgr.GetVM("union")
      local buildConfig = unionVM:GetUnionBuildConfig(E.UnionBuildId.Mall)
      Z.CameraMgr:CameraInvoke(E.CameraState.Position, false, buildConfig.CameraTemplateId, false)
    elseif #self.exchangeConfig_.CameraTemplateId > 0 then
      Z.CameraMgr:CameraInvoke(E.CameraState.Position, false, self.exchangeConfig_.CameraTemplateId, false)
    else
      Z.CameraMgr:CloseDialogCamera()
    end
  end
end

function Exchange_mainView:calculateNum()
  local canExchange = {}
  for k, v in pairs(self.consumeList_) do
    table.insert(canExchange, math.floor(v.ownNum / v.consumeNum))
  end
  table.sort(canExchange, function(a, b)
    return a < b
  end)
  self.canExchangeMinNum_ = canExchange[1]
end

function Exchange_mainView:showItemInfoTips(configId)
  self:closeItemInfoTips()
  local tipsData = {}
  tipsData.tipsId = self.itemTipsId_
  tipsData.configId = configId
  tipsData.isResident = true
  tipsData.posType = E.EItemTipsPopType.Parent
  tipsData.parentTrans = self.tipsTras_.transform
  tipsData.showType = E.EItemTipsShowType.OnlyClient
  tipsData.isVisible = true
  tipsData.isShowBg = true
  self.itemTipsId_ = Z.TipsVM.OpenItemTipsView(tipsData)
end

function Exchange_mainView:closeItemInfoTips()
  if self.itemTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
    self.itemTipsId_ = nil
  end
end

function Exchange_mainView:refreshGoodsExchangeNum()
  local exchangeItemRow = Z.TableMgr.GetTable("ExchangeItemTableMgr").GetRow(self.exchangeItemData_.goodsId)
  if exchangeItemRow == nil then
    return
  end
  local itemConfigId = exchangeItemRow.GetItemId
  local curExchangeNum = self.shopInfo_.exchangeData[self.exchangeItemData_.goodsId].curExchangeCount
  local maxNum = exchangeItemRow.RefreshNum
  local haveCount = self.itemsVM_.GetItemTotalCount(itemConfigId)
  self.labCur_.text = string.format(Lang("SeasonShopOwn"), haveCount)
  self.limitType = self.exchangeVM_.GetExchangeLimitType(exchangeItemRow.Id)
  self.exchangeChance_ = maxNum - curExchangeNum
  self:refreshNumShowState(self.exchangeItemData_)
  if self.limitType ~= E.ExchangeLimitType.Not then
    local showText = refreshType2Desc[exchangeItemRow.RefreshType]
    showText = showText or refreshType2Desc[0]
    self.uiBinder.lab_purchase_num.text = Lang(showText, {
      val1 = maxNum - curExchangeNum,
      val2 = maxNum
    })
  end
  self.isUpperLimmit_ = self.exchangeVM_.IsUpperLimmit(exchangeItemRow.Id)
  local exchangeOut = self.exchangeChance_ <= 0 and self.limitType ~= E.ExchangeLimitType.Not
  self.cantExchange_ = self.isUpperLimmit_ or exchangeOut
  self.uiBinder.Ref:SetVisible(self.upperlimitLab_, self.cantExchange_)
  self.uiBinder.Ref:SetVisible(self.numGroup_, not self.cantExchange_)
  if self.cantExchange_ then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_currency_cost, false)
  end
  local canBuyCount = -1
  for k, v in pairs(self.consumeList_) do
    local tmp = Mathf.Floor(v.ownNum / v.consumeNum)
    if canBuyCount == -1 or canBuyCount > tmp then
      canBuyCount = tmp
    end
  end
  self.maxNum_ = self.limitType ~= E.ExchangeLimitType.Not and maxNum - curExchangeNum or canBuyCount + 1
  self.curNum_ = 1
  self:calculateNum()
  if self.numMod_ then
    if 0 < self.maxNum_ and not self.isUpperLimmit_ then
      self.uiBinder.Ref:SetVisible(self.confirmBtn_, true)
      self.numMod_:changeExchangeItem(itemConfigId)
      self.numMod_:SetMoneyId(self.consumeList_[1].id, self.consumeList_[1].consumeNum)
      self.numMod_:ReSetValue(self.minNum_, self.maxNum_, canBuyCount, function(num)
        self.curNum_ = math.floor(num)
        self:updateNumData()
      end)
      self.numMod_:SetVisible(true)
    else
      self.uiBinder.Ref:SetVisible(self.confirmBtn_, false)
      self.numMod_:SetVisible(false)
      self:updateNumData()
    end
  end
end

function Exchange_mainView:refreshNumShowState(exchangeItemData)
  local exchangeItemRow = Z.TableMgr.GetRow("ExchangeItemTableMgr", exchangeItemData.goodsId)
  if exchangeItemRow == nil then
    return
  end
  local maxNum = exchangeItemRow.RefreshNum
  local limitType = self.exchangeVM_.GetExchangeLimitType(exchangeItemRow.Id)
  if maxNum >= Z.Global.ExchangeLimitHide then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_purchase_num, false)
  else
    local showLimit = limitType ~= E.ExchangeLimitType.Not and exchangeItemData.isUnlock
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_purchase_num, showLimit)
  end
end

function Exchange_mainView:updateNumData()
  self:refreshMaterialsData()
end

function Exchange_mainView:refreshMaterialsData()
  self.isConsumeItemEnough_ = true
  self.consumeList_ = self.exchangeVM_.GetConsumeItemDataListByGoodsId(self.exchangeItemData_.goodsId)
  if self.loopScroll_materialsRect_ then
    self:checkSpecialCostItem(self.consumeList_)
    self.loopScroll_materialsRect_:RefreshListView(self.consumeList_)
  end
  self.isShowTraceBtn_ = false
  if self.exchangeItemData_.isUnlock and not self.isUpperLimmit_ and self.exchangeConfig_ and self.exchangeConfig_.Trace then
    for index, value in ipairs(self.consumeList_) do
      if value.consumeNum > value.ownNum then
        self.isShowTraceBtn_ = true
        break
      end
    end
  end
  self.traceBtn_.Ref.UIComp:SetVisible(self.isShowTraceBtn_)
end

function Exchange_mainView:refreshCatalogueData()
  local list = self.exchangeVM_.GetGoodsIdListByShopId(self.shopId_, self.filterProfessionId_)
  if self.catalogueScrollRect_ then
    self.catalogueScrollRect_:RefreshListView(list)
    if self.exchangeItemData_ then
      for i, item in ipairs(list) do
        if item.goodsId == self.exchangeItemData_.goodsId then
          self.catalogueScrollRect_:SetSelected(i)
          break
        end
      end
    end
  end
end

function Exchange_mainView:refreshExchangeBtn()
  self.confirmBtn_.IsDisabled = not self.isConsumeItemEnough_ or self.exchangeChance_ <= 0 and self.limitType ~= E.ExchangeLimitType.Not
end

function Exchange_mainView:OnDeActive()
  if self.numMod_ then
    self.numMod_:DeActive()
  end
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.loopScroll_materialsRect_:UnInit()
  self.loopScroll_materialsRect_ = nil
  self.conditionRectList_:UnInit()
  self.conditionRectList_ = nil
  self.catalogueScrollRect_:UnInit()
  self.catalogueScrollRect_ = nil
  self:closeItemInfoTips()
  self.exchangeVM_.UnregGoodsChangeWatcherByShopId(self.shopId_)
  self:unInitCamera()
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
  self.itemTraceView_:DeActive()
  self.exchangeVM_.ResetEntityAndUIVisible(false)
end

function Exchange_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Backpack.AllChange, self.onItemCountChange, self)
  Z.EventMgr:Add("GoodsExchangeCountChange", self.onGoodsExchangeCountChange, self)
end

function Exchange_mainView:onItemCountChange()
  self:refreshMaterialsData()
  self:refreshExchangeBtn()
  self:calculateNum()
  self:setRightLimitDes()
end

function Exchange_mainView:onGoodsExchangeCountChange()
  self:refreshCatalogueData()
  self:refreshGoodsExchangeNum()
  self:refreshExchangeBtn()
  self:setRightLimitDes()
end

function Exchange_mainView:onAskBtnClick()
  local helpsysVM = Z.VMMgr.GetVM("helpsys")
  if self.exchangeConfig_ and self.exchangeConfig_.SystemId == E.ExchangeFuncId.UnionExchange then
    helpsysVM.OpenFullScreenTipsView(5001065)
  end
end

function Exchange_mainView:getFilterProfessionName()
  local names = {}
  local mgr = Z.TableMgr.GetTable("ProfessionSystemTableMgr")
  for _, profession in ipairs(self.professionConfigs_) do
    local professionConfig = mgr.GetRow(profession.Id)
    if professionConfig then
      if professionConfig.ProfessionId == self.filterProfessionId_ then
        table.insert(names, professionConfig.Name .. Lang("FilterCurrent"))
      else
        table.insert(names, professionConfig.Name)
      end
    end
  end
  return names
end

function Exchange_mainView:getIndexByProfessionId(professionId)
  local index = 1
  for k, profession in ipairs(self.professionConfigs_) do
    if profession.ProfessionId == professionId then
      index = k
      break
    end
  end
  return index - 1
end

function Exchange_mainView:checkIsCurProfessionEquip()
  local isProfessionEquipItem = false
  if self.exchangeConfig_ and self.exchangeConfig_.Screen and self.exchangeConfig_ ~= 0 then
    local exchangeItemRow = Z.TableMgr.GetTable("ExchangeItemTableMgr").GetRow(self.exchangeItemData_.goodsId)
    if exchangeItemRow then
      local equipConfig = Z.TableMgr.GetTable("EquipTableMgr").GetRow(exchangeItemRow.GetItemId, true)
      if equipConfig then
        for _, pro in ipairs(equipConfig.EquipProfession) do
          if pro == self.weaponVM_.GetCurWeapon() then
            isProfessionEquipItem = true
            break
          end
        end
      else
        isProfessionEquipItem = true
      end
    else
      isProfessionEquipItem = true
    end
  else
    isProfessionEquipItem = true
  end
  return isProfessionEquipItem
end

function Exchange_mainView:buyExchangeGoods()
  if self.isConsumeItemEnough_ and self.curNum_ > 0 and self.curNum_ <= self.canExchangeMinNum_ then
    if self.curNum_ >= Z.Global.BuyMaxTips then
      local itemRow
      local exchangeItemRow = Z.TableMgr.GetTable("ExchangeItemTableMgr").GetRow(self.exchangeItemData_.goodsId)
      if exchangeItemRow then
        itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(exchangeItemRow.GetItemId)
      end
      if itemRow == nil then
        return
      end
      local itemName = Z.RichTextHelper.ApplyStyleTag(itemRow.Name, "ItemQuality_" .. itemRow.Quality)
      local costContent = ""
      local consumeList = self.exchangeVM_.GetConsumeItemDataListByGoodsId(self.exchangeItemData_.goodsId)
      for index, value in pairs(consumeList) do
        local costItemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(value.id)
        if costItemRow then
          local costItemName = Z.RichTextHelper.ApplyStyleTag(costItemRow.Name, "ItemQuality_" .. costItemRow.Quality)
          if index ~= 1 then
            costContent = string.zconcat(costContent, Lang("Comma"))
          end
          costContent = string.zconcat(costContent, costItemName, "x", math.floor(value.consumeNum * self.curNum_))
        end
      end
      Z.DialogViewDataMgr:OpenNormalDialog(string.format(Lang("ExchangeItemMaxTip"), costContent, itemName, math.floor(self.curNum_)), function()
        self.exchangeVM_.AsyncSendExchange(self.shopId_, self.exchangeItemData_.goodsId, self.curNum_, self.cancelSource:CreateToken())
        if self.curNum_ == self.exchangeChance_ then
          self:closeItemInfoTips()
        end
      end)
      return
    end
    self.exchangeVM_.AsyncSendExchange(self.shopId_, self.exchangeItemData_.goodsId, self.curNum_, self.cancelSource:CreateToken())
    if self.curNum_ == self.exchangeChance_ then
      self:closeItemInfoTips()
    end
  end
end

return Exchange_mainView
