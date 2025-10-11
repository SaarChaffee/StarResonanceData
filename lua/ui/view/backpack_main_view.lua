local UI = Z.UI
local dataMgr = require("ui.model.data_manager")
local super = require("ui.ui_view_base")
local Backpack_mainView = class("BackpackMainView", super)
local loopListView_ = require("ui/component/loop_list_view")
local loopGridView_ = require("ui/component/loop_grid_view")
local toggleGroup_ = require("ui/component/togglegroup")
local bag_firstclass_item_ = require("ui.component.bag.bag_firstclass_loop_item")
local bag_secondclass_item = require("ui.component.bag.bag_secondclass_loop_item")
local bag_items_item_ = require("ui.component.bag.bag_items_loop_item")
local btnBinder = require("common.btn_binder")
local bag_take_medicine_subView = require("ui.view.bag_take_medicine_sub_view")
local itemFilter = require("ui.view.item_filters_view")
local bagRed = require("rednode.bag_red")
local currency_item_list = require("ui.component.currency.currency_item_list")
local animName = {
  [1] = Z.DOTweenAnimType.Tween_0,
  [2] = Z.DOTweenAnimType.Tween_1,
  [3] = Z.DOTweenAnimType.Tween_2
}

function Backpack_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "backpack_main", "bag/bag_backpack_main")
  self.backpackVm_ = Z.VMMgr.GetVM("backpack")
  self.backpackData_ = Z.DataMgr.Get("backpack_data")
  self.currencyVm_ = Z.VMMgr.GetVM("currency")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  self.itemFilterFactoryVM_ = Z.VMMgr.GetVM("item_filter_factory")
  self.btnBinder = btnBinder.new(self)
  self.bagTakeMedicineSubView_ = bag_take_medicine_subView.new(self)
  self.itemFilter_ = itemFilter.new(self)
  self.vm = nil
end

function Backpack_mainView:OnActive()
  Z.AudioMgr:Play("UI_Menu_Backpack")
  self:initWidgets()
  self:BindEvents()
  self:startAnimatedShow()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.isRefreshSelectedItem_ = false
  self.selectePackageType_ = nil
  self.selectedItemType_ = nil
  self.isAscending_ = false
  self.isFirstOneEnter_ = true
  self.backpackData_.CurrentUseItemUuid = nil
  self.filterTags_ = {}
  
  function self.packageWatcherFunc_(package, dirtyKeys)
    self:onPackageChanged(package, dirtyKeys)
  end
  
  function self.counterListWatcherFunc_(package, dirtyKeys)
    self:refreshLimitLab()
  end
  
  Z.ContainerMgr.CharSerialize.counterList.Watcher:RegWatcher(self.counterListWatcherFunc_)
  self:AddClick(self.returnBtn_, function()
    self.backpackVm_.CloseBagView()
  end)
  self:AddAsyncClick(self.repairBtn_, function()
    self.backpackVm_.AsycSortPackage(self.selectePackageType_, self.cancelSource:CreateToken())
    self:OnSecondClassSelected(self.selectedItemType_)
  end, nil, function()
    local backPackData = Z.DataMgr.Get("backpack_data")
    backPackData.SortState = false
  end)
  self:AddClick(self.sortBtn_, function()
    self.isAscending_ = not self.isAscending_
    self:OnSecondClassSelected(self.selectedItemType_)
  end)
  self:AddClick(self.uiBinder.btn_takemedicine, function()
    local index = self:GetSelectedItemTypeIndex(E.ItemType.CostItem)
    if index and index ~= -1 then
      self.secondClassListView_:ClearAllSelect()
      self.secondClassListView_:SetSelected(index)
    end
    self.bagTakeMedicineSubView_:Active(function()
      local currencyIds = self.currencyVm_.GetCurrencyIds()
      if not self.currencyItemList_ then
        self.currencyItemList_ = currency_item_list.new()
      end
      self.currencyItemList_:Init(self.uiBinder.currency_info, currencyIds)
    end, self.uiBinder.takemedicine_sub)
  end)
  self:refresh()
end

function Backpack_mainView:OnInputBack()
  if self.IsResponseInput then
    if self.bagTakeMedicineSubView_:CheckSecondDialog() then
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("SecondCheck"), function()
        Z.UIMgr:CloseView(self.ViewConfigKey)
      end)
    else
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end
end

function Backpack_mainView:initWidgets()
  self.returnBtn_ = self.uiBinder.returnBtn
  self.repairBtn_ = self.uiBinder.repairBtn
  self.sortBtn_ = self.uiBinder.sortBtn
  self.secondClassLoopScrollRect_ = self.uiBinder.secondClassLoopScrollRect
  self.itemsLoopScrollRect_ = self.uiBinder.itemsLoopScrollRect
  self.itemRect_ = self.uiBinder.item_rect
  self.firstClassTogGroup_ = self.uiBinder.firstClassTogGroup
  self.packageNameLab_ = self.uiBinder.packageNameLab
  self.packageCapacityLab_ = self.uiBinder.packageCapacityLab
  self.packageCountLab_ = self.uiBinder.packageCountLab
  self.layoutPackageCapacity_ = self.uiBinder.layoutPackageCapacity
  self.filterSortNodeTran_ = self.uiBinder.filterSortNodeTran
  self.leftLayout_ = self.uiBinder.leftLayout
  self.returnTitleLab_ = self.uiBinder.returnTitleLab
  self.emptyNode_ = self.uiBinder.emptyNode
  self.nodeTipsPosTrans_ = self.uiBinder.nodeTipsPosTrans
  self.nodeWeapTrans_ = self.uiBinder.nodeWeapTrans
  self.nodeTipsTrans_ = self.uiBinder.nodeTipsTrans
  self.btnNodes_ = self.uiBinder.img_btn_bg
  self.item_operation_btns_ = self.uiBinder.item_operation_btns
  self.doTweenAnim_ = self.uiBinder.doTweenAnim
  if not Z.IsPCUI then
    self.scenemask_ = self.uiBinder.scenemask
    self.scenemask_:SetSceneMaskByKey(self.SceneMaskKey)
  else
    self.imgLine_ = self.uiBinder.img_line
    self.rimgIcon_ = self.uiBinder.rimg_icon
  end
end

function Backpack_mainView:refresh()
  local secondItemName = Z.IsPCUI and "bag_second_item_tpl_pc" or "bag_second_item_tpl"
  self.secondClassListView_ = loopListView_.new(self, self.secondClassLoopScrollRect_, bag_secondclass_item, secondItemName)
  self.secondClassListView_:Init({})
  local itemLongName = Z.IsPCUI and "com_item_long_2_pc" or "com_item_long_2"
  self.itemsGridView_ = loopGridView_.new(self, self.itemsLoopScrollRect_, bag_items_item_, itemLongName)
  self.itemsGridView_:Init({})
  local currencyIds = self.currencyVm_.GetCurrencyIds()
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, currencyIds)
  local firstClassData = self.backpackVm_.GetFirstClassSortIdList()
  local initIndex = 1
  if self.viewData and self.viewData.selectePackageTypeIndex then
    initIndex = self.viewData.selectePackageTypeIndex
  end
  self:setLineHeight(154 + 78 * (initIndex - 1))
  self.firstClassToggleGroup_ = toggleGroup_.new(self.firstClassTogGroup_, bag_firstclass_item_, firstClassData, self)
  self.firstClassToggleGroup_:Init(initIndex, function(index)
    self:setLineHeight(154 + 78 * (index - 1))
    self:OnFirstClassSelected(firstClassData[index])
  end)
  self:OnFirstClassSelected(firstClassData[self.firstClassToggleGroup_:GetSelectedIndex()])
end

function Backpack_mainView:setLineHeight(height)
  if Z.IsPCUI and self.imgLine_ then
    self.imgLine_.transform:SetHeight(height)
  end
end

function Backpack_mainView:GetCacheData()
  local cacheData = {}
  cacheData.selectePackageTypeIndex = self:GetSelectedPackageTypeIndex()
  cacheData.selectedItemTypeIndex = self:GetSelectedItemTypeIndex(self.selectedItemType_)
  cacheData.selectedItemIndex = self:GetSelectedItemIndex()
  cacheData.selectedItemUuid = self.selectedId_
  cacheData.itemViewPosY = self.itemsLoopScrollRect_.ContainerTrans.anchoredPosition.y
  cacheData.isAscending = self.isAscending_
  return cacheData
end

function Backpack_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.firstClassToggleGroup_:UnInit()
  self.viewData = nil
  if self.itemFilter_ then
    self.itemFilter_:DeActive()
  end
  self:clearTips()
  if self.package_ then
    self.package_.Watcher:UnregWatcher(self.packageWatcherFunc_)
  end
  Z.ContainerMgr.CharSerialize.counterList.Watcher:UnregWatcher(self.counterListWatcherFunc_)
  self.secondClassListView_:UnInit()
  self.itemsGridView_:UnInit()
  self.bagTakeMedicineSubView_:DeActive()
  self.package_ = nil
  self.packageWatcherFunc_ = nil
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
end

function Backpack_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Backpack.SortOver, self.backpackSortOver, self)
  Z.EventMgr:Add(Z.ConstValue.ItemFilterConfirm, self.onSelectFilter, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.RefreshBtnSubState, self.refreshBtnSubState, self)
end

function Backpack_mainView:refreshBtnSubState(isShow)
  if Z.IsPCUI then
    self.uiBinder.Ref:SetVisible(self.btnNodes_, isShow)
  end
end

function Backpack_mainView:backpackSortOver()
  self.backpackData_.NewItems = {}
  bagRed.RemoveAllRed()
  local selectedItemType = self.selectedItemType_
  self:OnFirstClassSelected(self.selectePackageType_)
  local index = self:GetSelectedItemTypeIndex(selectedItemType)
  if index and index ~= -1 then
    self.secondClassListView_:ClearAllSelect()
    self.secondClassListView_:SetSelected(index)
  end
end

function Backpack_mainView:onPackageChanged(package, dirtyKeys)
  if self.backpackData_.SortState then
    return
  end
  local items = dirtyKeys.items
  if items == nil then
    return
  end
  local isNew = false
  for _, value in pairs(items) do
    if value:IsDel() then
      self.selectedId_ = nil
      break
    end
    if value:IsNew() then
      isNew = true
      break
    end
  end
  if isNew and self.backpackData_.CurrentUseItemUuid ~= self.selectedId_ then
    self.selectedId_ = nil
  end
  self.package_ = package
  self:setpackageCountUi()
  self:refreshItemList()
end

function Backpack_mainView:setpackageCountUi()
  local curCount = table.zcount(self.package_.items)
  local itemPackage = Z.TableMgr.GetTable("ItemPackageTableMgr").GetRow(self.selectePackageType_)
  if itemPackage then
    self.packageNameLab_.text = Lang("Capacity") .. ": "
  end
  self.packageCapacityLab_.text = "/" .. self.package_.maxCapacity
  if curCount > self.package_.maxCapacity then
    curCount = Z.RichTextHelper.ApplyStyleTag(curCount, E.TextStyleTag.TipsRed)
  else
    curCount = Z.RichTextHelper.ApplyStyleTag(curCount, E.TextStyleTag.White)
  end
  self.packageCountLab_.text = tostring(curCount)
  self.layoutPackageCapacity_:ForceRebuildLayoutImmediate()
end

function Backpack_mainView:OnFirstClassSelected(id)
  if self.selectePackageType_ == id then
    return
  end
  self:setLabText(id)
  self.itemTipsId_ = Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
  if self.package_ then
    self.package_.Watcher:UnregWatcher(self.packageWatcherFunc_)
  end
  if not self.isFirstOneEnter_ then
    self.doTweenAnim_:Restart(Z.DOTweenAnimType.Tween_0)
  end
  self.isFirstOneEnter_ = false
  self.package_ = Z.ContainerMgr.CharSerialize.itemPackage.packages[id]
  if self.package_ then
    self.package_.Watcher:RegWatcher(self.packageWatcherFunc_)
  end
  self.secondClassListView_:ClearAllSelect()
  self.selectePackageType_ = id
  self.selectedItemType_ = -1
  self.isRefreshSelectedItem_ = true
  self:setpackageCountUi()
  local infos = self.backpackVm_.GetSecondClassSortData(id)
  self.secondClassListView_:RefreshListView(infos, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_takemedicine, self.selectePackageType_ == E.BackPackItemPackageType.Item)
  if self.viewData and self.viewData.selectedItemTypeIndex then
    self.secondClassListView_:SetSelected(self.viewData.selectedItemTypeIndex)
    self.viewData.selectedItemTypeIndex = nil
  else
    self.secondClassListView_:SetSelected(1)
  end
  self.itemsVm_.RemoveNewPackageItems(id)
  self.uiBinder.Ref:SetVisible(self.filterSortNodeTran_, false)
  self.leftLayout_:ForceRebuildLayoutImmediate()
end

function Backpack_mainView:setLabText(id)
  local backPackData = Z.DataMgr.Get("backpack_data")
  local commonVM = Z.VMMgr.GetVM("common")
  local funcId = backPackData.ItemBackIdxToFuncId[id]
  commonVM.SetLabText(self.returnTitleLab_, {
    E.BackpackFuncId.Backpack,
    funcId
  })
end

function Backpack_mainView:OnSecondClassSelected(id)
  if self.ids_ and #self.ids_ ~= 0 then
    for index, itemData in ipairs(self.ids_) do
      self.backpackData_.NewItems[itemData.itemUuid] = nil
      bagRed.RemoveRed(itemData.itemUuid)
    end
  end
  self.isFirstSecondEnter_ = false
  self.selectedItemType_ = id
  self.selectedId_ = nil
  self:refreshItemList()
  self.bagTakeMedicineSubView_:DeActive()
end

function Backpack_mainView:addEmptyData()
  if not Z.IsPCUI then
    return self.ids_
  end
  local width = self.itemRect_.rect.height
  local count = self.itemsGridView_:GetFixedRowOrColumnCount() * math.ceil(width / 104)
  if count <= #self.ids_ then
    return self.ids_
  end
  local data = table.zvalues(self.ids_)
  for i = #self.ids_ + 1, count do
    data[i] = {IsEmpty = true}
  end
  return data
end

function Backpack_mainView:refreshItemList()
  local itemSortData = self.itemSortFactoryVm_.GetSortData(self.selectePackageType_)
  local itemFilterData = self:getFilterData()
  local sortFunc = self.itemSortFactoryVm_.GetItemSortFunc(self.selectePackageType_, itemSortData)
  local filterFuncs = self.itemFilterFactoryVM_.GetBackpackItemFilterFunc(itemFilterData)
  self.ids_ = self.itemsVm_.GetItemIds(self.selectePackageType_, filterFuncs, sortFunc)
  self.itemsGridView_:ClearAllSelect()
  local data = self:addEmptyData()
  self.itemsGridView_:RefreshListView(data, true)
  if self.ids_ and #self.ids_ == 0 then
    self:OnItemSelected(-1)
  elseif self.viewData and self.viewData.selectedItemIndex then
    self.viewData.selectedItemIndex = nil
  end
  self.uiBinder.Ref:SetVisible(self.emptyNode_, #self.ids_ == 0)
  local cacheIndex = 1
  local selectedUuid
  if self.viewData then
    selectedUuid = self.viewData.selectedItemUuid
    self.viewData.selectedItemUuid = nil
  end
  if selectedUuid == nil then
    selectedUuid = self.selectedId_
  else
    self.viewData.selectedItemIndex = nil
  end
  if selectedUuid then
    for index, itemData in ipairs(self.ids_) do
      if itemData.itemUuid == selectedUuid then
        cacheIndex = index
        break
      end
    end
  end
  if self.viewData and self.viewData.itemViewPosY then
    self.itemsLoopScrollRect_.ContainerTrans.anchoredPosition = Vector3.New(0, self.viewData.itemViewPosY, 0)
  end
  self.itemsGridView_:SetSelected(cacheIndex)
  self.itemsGridView_:MovePanelToItemIndex(cacheIndex)
end

function Backpack_mainView:clearTips()
  if Z.IsPCUI then
    self.uiBinder.Ref:SetVisible(self.rimgIcon_, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_box_limit, false)
  end
  Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
  self.itemTipsId_ = nil
  self.item_operation_btns_.Ref.UIComp:SetVisible(false)
  self.btnBinder:OnUnInit()
end

function Backpack_mainView:refreshLimitLab()
  if self.selectedId_ == nil then
    return
  end
  local configId = self.package_.items[self.selectedId_].configId
  local itemFunctionTableRow = Z.TableMgr.GetRow("ItemFunctionTableMgr", configId, true)
  if itemFunctionTableRow and itemFunctionTableRow.CounterId ~= 0 then
    local counterRow = Z.TableMgr.GetRow("CounterTableMgr", itemFunctionTableRow.CounterId)
    if counterRow then
      local timerConfigItem = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerItem(counterRow.TimeTableId)
      local timeType = timerConfigItem and timerConfigItem.TimerType or 0
      local limit = Z.CounterHelper.GetCounterLimitCount(itemFunctionTableRow.CounterId)
      local residueCount = Z.CounterHelper.GetCounterResidueLimitCount(itemFunctionTableRow.CounterId, limit)
      if Z.IsPCUI then
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_box_limit, true)
        self.uiBinder.lab_box_limit.text = Lang("RestrictedUseOfItemsThe" .. timeType, {val1 = residueCount, val2 = limit})
      end
    end
  end
end

function Backpack_mainView:OnItemSelected(itemUuId)
  if itemUuId == -1 or itemUuId == nil or self.package_.items[itemUuId] == nil then
    self:clearTips()
    self.uiBinder.Ref:SetVisible(self.nodeTipsTrans_, false)
    return
  end
  if self.backpackData_.CurrentUseItemUuid ~= itemUuId then
    self.backpackData_.CurrentUseItemUuid = nil
  end
  self.selectedId_ = itemUuId
  self:clearTips()
  if itemUuId == nil or itemUuId == -1 then
    self.btnBinder:OnUnInit()
    self.item_operation_btns_.Ref.UIComp:SetVisible(false)
    self.uiBinder.Ref:SetVisible(self.nodeTipsTrans_, false)
  else
    self.uiBinder.Ref:SetVisible(self.nodeTipsTrans_, true)
    self.backpackData_.NewItems[itemUuId] = nil
    bagRed.RemoveRed(itemUuId)
    local configId = self.package_.items[itemUuId].configId
    self:refreshLimitLab()
    local itemTipsViewData = {}
    itemTipsViewData.configId = configId
    itemTipsViewData.itemUuid = itemUuId
    itemTipsViewData.isResident = true
    itemTipsViewData.posType = E.EItemTipsPopType.Parent
    itemTipsViewData.isShowBg = true
    itemTipsViewData.isShowFixBg = true
    itemTipsViewData.parentTrans = self.nodeTipsPosTrans_
    itemTipsViewData.isPcTips = Z.IsPCUI
    itemTipsViewData.isPlay = false
    if self.selectePackageType_ == E.BackPackItemPackageType.Mod and not Z.IsPCUI then
      itemTipsViewData.parentTrans = self.nodeWeapTrans_
    end
    if Z.IsPCUI then
      local path = self.itemsVm_.GetItemIcon(configId)
      if path and path ~= "" then
        self.uiBinder.Ref:SetVisible(self.rimgIcon_, true)
        self.rimgIcon_:SetImage(path)
      end
      itemTipsViewData.isShowBg = false
    end
    self.itemTipsId_ = Z.TipsVM.OpenItemTipsView(itemTipsViewData)
    local btnBinderInfo = {
      viewBtns = E.BtnViewType.Bag[self.selectedItemType_],
      uiBinder = self.item_operation_btns_,
      configId = configId,
      itemUuId = itemUuId,
      btnData = {
        viewConfigKey = self.viewConfigKey
      }
    }
    self.btnBinder:InitData(btnBinderInfo)
  end
end

function Backpack_mainView:OnPlayAnim(indexTab)
  self.doTweenAnim_:Restart(animName[indexTab])
end

function Backpack_mainView:getSortData()
  if self.selectePackageType_ == E.BackPackItemPackageType.Item then
    return nil
  elseif self.selectePackageType_ == E.BackPackItemPackageType.Equip then
    local data = {}
    data.equipSortType = E.EquipItemSortType.Quality
    data.isAscending = true
    return data
  elseif self.selectePackageType_ == E.BackPackItemPackageType.Mod then
    local data = {}
    data.sortType = E.EquipItemSortType.Quality
    return data
  end
end

function Backpack_mainView:getFilterData()
  local data = {}
  data.filterMask = E.ItemFilterType.ItemType + E.ItemFilterType.ItemRare
  data.itemType = self.selectedItemType_
  data.filterTags = self.filterTags_
  return data
end

function Backpack_mainView:onSelectFilter(filterTags)
  if table.zcount(filterTags) < 1 then
    self.filterTags_ = nil
  end
  local tags = {}
  for filterType, value in pairs(filterTags) do
    for tag, _ in pairs(value) do
      if tags[filterType] == nil then
        tags[filterType] = {}
      end
      table.insert(tags[filterType], tag)
    end
  end
  self.filterTags_ = tags
  self:refreshItemList()
end

function Backpack_mainView:GetSelectedItemType()
  return self.selectedItemType_
end

function Backpack_mainView:GetSelectedPackageType()
  return self.selectePackageType_
end

function Backpack_mainView:GetSelectedItemTypeIndex(selectedItemType)
  for index, value in ipairs(self.secondClassListView_:GetData()) do
    if value[2] and tonumber(value[2]) == selectedItemType then
      return index
    end
  end
  return 1
end

function Backpack_mainView:GetSelectedPackageTypeIndex()
  local firstClassData = self.backpackVm_.GetFirstClassSortIdList()
  for index, value in ipairs(firstClassData) do
    if value == self.selectePackageType_ then
      return index
    end
  end
  return nil
end

function Backpack_mainView:GetSelectedItemIndex()
  if self.ids_ then
    for index, value in ipairs(self.ids_) do
      if value.itemUuid == self.selectedId_ then
        return index
      end
    end
  end
  return nil
end

function Backpack_mainView:startAnimatedShow()
  self.doTweenAnim_:Rewind(Panda.ZUi.DOTweenAnimType.Open)
  self.doTweenAnim_:Restart(Panda.ZUi.DOTweenAnimType.Open)
  if Z.IsPCUI then
    self:startAnimatedShowEff()
  end
end

function Backpack_mainView:startAnimatedHide()
  if not Z.IsPCUI then
    local coro = Z.CoroUtil.async_to_sync(self.doTweenAnim_.CoroPlay)
    coro(self.doTweenAnim_, Panda.ZUi.DOTweenAnimType.Close)
  end
end

function Backpack_mainView:startAnimatedShowEff()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
end

function Backpack_mainView:OnBeginDragItem(configId, pointerData)
  self.bagTakeMedicineSubView_:OnBeginDragItem(configId, pointerData)
end

function Backpack_mainView:OnDragItem(pointerData)
  self.bagTakeMedicineSubView_:OnDragItem(pointerData)
end

function Backpack_mainView:OnEndDragItem()
  self.bagTakeMedicineSubView_:OnEndDragItem()
end

function Backpack_mainView:SetMask(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.mask, isShow)
end

return Backpack_mainView
