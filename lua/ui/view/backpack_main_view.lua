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
local item_operation_btnsView_ = require("ui.view.item_operation_btns_view")
local itemFilter = require("ui.view.item_filters_view")
local bagRed = require("rednode.bag_red")

function Backpack_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "backpack_main")
  self.item_operation_btnsView_ = item_operation_btnsView_.new()
  self.itemFilter_ = itemFilter.new(self)
  self.vm = nil
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
end

function Backpack_mainView:OnActive()
  self:initWidgets()
  self:startAnimatedShow()
  self.scenemask_:SetSceneMaskByKey(self.SceneMaskKey)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.backpackVm_ = Z.VMMgr.GetVM("backpack")
  self.backpackData_ = Z.DataMgr.Get("backpack_data")
  self.currencyVm_ = Z.VMMgr.GetVM("currency")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  self.itemFilterFactoryVM_ = Z.VMMgr.GetVM("item_filter_factory")
  self.isRefreshSelectedItem_ = false
  self.isDelItem_ = false
  self.isAddNewItem_ = false
  self.selectePackageType_ = nil
  self.selectedItemType_ = nil
  self.isAscending_ = false
  self.filterTgas_ = {}
  
  function self.packageWatcherFunc_(package, dirtyKeys)
    self:onPackageChanged(package, dirtyKeys)
  end
  
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
  self.isShowOpenAnimType_ = true
  self:refresh()
  self:BindEvents()
  self:RegisterInputActions()
end

function Backpack_mainView:initWidgets()
  self.returnBtn_ = self.uiBinder.returnBtn
  self.repairBtn_ = self.uiBinder.repairBtn
  self.sortBtn_ = self.uiBinder.sortBtn
  self.secondClassLoopScrollRect_ = self.uiBinder.secondClassLoopScrollRect
  self.itemsLoopScrollRect_ = self.uiBinder.itemsLoopScrollRect
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
  self.doTweenAnim_ = self.uiBinder.doTweenAnim
  self.scenemask_ = self.uiBinder.scenemask
end

function Backpack_mainView:refresh()
  self.secondClassListView_ = loopListView_.new(self, self.secondClassLoopScrollRect_, bag_secondclass_item, "bag_second_item_tpl")
  self.secondClassListView_:Init({})
  self.itemsGridView_ = loopGridView_.new(self, self.itemsLoopScrollRect_, bag_items_item_, "com_item_long_2")
  self.itemsGridView_:Init({})
  local currencyIds = self.currencyVm_.GetCurrencyIds()
  self.currencyVm_.OpenCurrencyView(currencyIds, self.uiBinder.Trans, self)
  local firstClassData = self.backpackVm_.GetFirstClassSortIdList()
  local initIndex = 1
  if self.viewData and self.viewData.selectePackageTypeIndex then
    initIndex = self.viewData.selectePackageTypeIndex
  end
  self.firstClassToggleGroup_ = toggleGroup_.new(self.firstClassTogGroup_, bag_firstclass_item_, firstClassData, self, Z.ConstValue.LoopItembindName.back_toggle_item)
  self.firstClassToggleGroup_:Init(initIndex, function(index)
    self:OnFirstClassSelected(firstClassData[index])
  end, "c_com_tab_item_1_tpl")
  self:OnFirstClassSelected(firstClassData[self.firstClassToggleGroup_:GetSelectedIndex()])
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
  self:UnRegisterInputActions()
  self.firstClassToggleGroup_:UnInit()
  self.isShowOpenAnimType_ = true
  self.viewData = nil
  if self.itemFilter_ then
    self.itemFilter_:DeActive()
  end
  Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
  self.itemTipsId_ = nil
  self.item_operation_btnsView_:DeActive()
  if self.package_ then
    self.package_.Watcher:UnregWatcher(self.packageWatcherFunc_)
  end
  self.secondClassListView_:UnInit()
  self.itemsGridView_:UnInit()
  self.currencyVm_.CloseCurrencyView(self)
  self.backpackData_ = nil
  self.currencyVm_ = nil
  self.backpackVm_ = nil
  self.package_ = nil
  self.packageWatcherFunc_ = nil
end

function Backpack_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Backpack.SortOver, self.backpackSortOver, self)
  Z.EventMgr:Add(Z.ConstValue.ItemFilterConfirm, self.onSelectFilter, self)
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
  local isRefresh = false
  for _, value in pairs(items) do
    if value:IsDel() then
      isRefresh = true
      self.isDelItem_ = true
      break
    end
    if value:IsNew() then
      self.isAddNewItem_ = true
      isRefresh = true
      break
    end
  end
  if isRefresh == false then
    local id = self.selectedId_
    self.selectedId_ = 0
    self:OnItemSelected(id)
    return
  end
  self.package_ = package
  self:setpackageCountUi()
  self.itemsGridView_:ClearAllSelect()
  self:refreshItemList(-1)
end

function Backpack_mainView:setpackageCountUi()
  local curCount = table.zcount(self.package_.items)
  local itemPackage = Z.TableMgr.GetTable("ItemPackageTableMgr").GetRow(self.selectePackageType_)
  if itemPackage then
    self.packageNameLab_.text = itemPackage.Name .. Lang("Capacity") .. ": "
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
  self.selectedItemType_ = id
  self.selectedId_ = nil
  self:refreshItemList(id)
end

function Backpack_mainView:refreshItemList(id)
  local itemSortData = self.itemSortFactoryVm_.GetSortData(self.selectePackageType_)
  local itemFilterData = self:getFilterData()
  local sortFunc = self.itemSortFactoryVm_.GetItemSortFunc(self.selectePackageType_, itemSortData)
  local filterFuncs = self.itemFilterFactoryVM_.GetBackpackItemFilterFunc(itemFilterData)
  self.ids_ = self.itemsVm_.GetItemIds(self.selectePackageType_, filterFuncs, sortFunc)
  self.itemsGridView_:ClearAllSelect()
  if self.isShowOpenAnimType_ == true then
    self.isShowOpenAnimType_ = false
  else
  end
  self.itemsGridView_:RefreshListView(self.ids_, true)
  if self.viewData and self.viewData.selectedItemIndex then
    self.viewData.selectedItemIndex = nil
  elseif self.ids_ and #self.ids_ == 0 then
    self:OnItemSelected(-1)
  end
  self.uiBinder.Ref:SetVisible(self.emptyNode_, #self.ids_ == 0)
  local cacheIndex = 1
  for index, itemData in ipairs(self.ids_) do
    if self.viewData and self.viewData.selectedItemUuid then
      self.viewData.selectedItemIndex = nil
      if itemData.itemUuid == self.viewData.selectedItemUuid then
        cacheIndex = index
        break
      end
    end
  end
  if self.viewData and self.viewData.itemViewPosY then
    self.itemsLoopScrollRect_.ContainerTrans.anchoredPosition = Vector3.New(0, self.viewData.itemViewPosY, 0)
  end
  if self.isDelItem_ then
    self.isDelItem_ = false
    self.itemsGridView_:SetSelected(cacheIndex)
  else
    if self.isRefreshSelectedItem_ then
      self.itemsGridView_:SetSelected(cacheIndex)
      self.isRefreshSelectedItem_ = false
    end
    if self.isAddNewItem_ then
      self.itemsGridView_:SetSelected(cacheIndex)
      self.isAddNewItem_ = false
    else
      self.itemsGridView_:SetSelected(cacheIndex)
    end
  end
  self:refreshBottmPos()
end

function Backpack_mainView:clearTips()
  Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
  self.itemTipsId_ = nil
  self.item_operation_btnsView_:DeActive()
end

function Backpack_mainView:OnItemSelected(itemUuId)
  if itemUuId == nil or self.package_.items[itemUuId] == nil then
    self:clearTips()
    return
  end
  if self.selectedId_ == itemUuId then
    return
  end
  self.selectedId_ = itemUuId
  self:clearTips()
  if itemUuId == nil or itemUuId == -1 then
    self.item_operation_btnsView_:DeActive()
  else
    self.backpackData_.NewItems[itemUuId] = nil
    bagRed.RemoveRed(itemUuId)
    local configId = self.package_.items[itemUuId].configId
    local itemTipsViewData = {}
    itemTipsViewData.configId = configId
    itemTipsViewData.itemUuid = itemUuId
    itemTipsViewData.isResident = true
    itemTipsViewData.posType = E.EItemTipsPopType.Parent
    itemTipsViewData.isShowBg = true
    itemTipsViewData.isShowFixBg = true
    itemTipsViewData.parentTrans = self.nodeTipsPosTrans_
    if self.selectePackageType_ == E.BackPackItemPackageType.Mod then
      itemTipsViewData.parentTrans = self.nodeWeapTrans_
    end
    self.itemTipsId_ = Z.TipsVM.OpenItemTipsView(itemTipsViewData)
    self.item_operation_btnsView_:Active({
      configId = configId,
      itemId = itemUuId,
      btnData = {
        viewConfigKey = self.viewConfigKey
      }
    }, self.nodeTipsTrans_)
  end
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
  data.filterTgas = self.filterTgas_
  return data
end

function Backpack_mainView:onSelectFilter(filterTgas)
  if table.zcount(filterTgas) < 1 then
    self.filterTgas_ = nil
  end
  local tags = {}
  for filterType, value in pairs(filterTgas) do
    for tag, _ in pairs(value) do
      if tags[filterType] == nil then
        tags[filterType] = {}
      end
      table.insert(tags[filterType], tag)
    end
  end
  self.filterTgas_ = tags
  self:refreshItemList(self.selectedItemType_)
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

function Backpack_mainView:refreshBottmPos()
end

function Backpack_mainView:startAnimatedShow()
  self.doTweenAnim_:Rewind(Panda.ZUi.DOTweenAnimType.Open)
  self.doTweenAnim_:Restart(Panda.ZUi.DOTweenAnimType.Open)
end

function Backpack_mainView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.doTweenAnim_.CoroPlay)
  coro(self.doTweenAnim_, Panda.ZUi.DOTweenAnimType.Close)
end

function Backpack_mainView:RegisterInputActions()
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Backpack)
end

function Backpack_mainView:UnRegisterInputActions()
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Backpack)
end

return Backpack_mainView
