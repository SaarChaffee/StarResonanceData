local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_develop_intensify_windowView = class("Weapon_develop_intensify_windowView", super)
local loopGridView = require("ui.component.loop_grid_view")
local loopListView = require("ui.component.loop_list_view")
local decomposeMainLoopItem = require("ui.component.resonance_power.resonance_power_decomposemain_loop_item")
local createMainLoopItem = require("ui.component.resonance_power.resonance_power_createmain_loop_item")
local decomposeConsumeLoopItem = require("ui.component.resonance_power.resonance_power_decomposeconsume_loop_item")
local decomposeGetLoopItem = require("ui.component.resonance_power.resonance_power_decomposeget_loop_item")
local itemBinder = require("common.item_binder")
local itemFilter = require("ui.view.item_filters_view")
local bagRed = require("rednode.bag_red")

function Weapon_develop_intensify_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_develop_intensify_window")
  self.resonancePowerVM_ = Z.VMMgr.GetVM("resonance_power")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.createMode_ = true
  self.createResonancePower_ = {configId = -1, count = 1}
  self.maxCreateCount_ = 0
  self.canCreate_ = false
  self.createNotEnoughItem_ = nil
  self.decomposeList_ = {}
  self.createConsumeUnit = {}
  self.haveInitDecompose_ = false
  self.haveInitCreate_ = false
  self.canCreateColor_ = "#FFFFFF"
  self.cantCreateColor_ = "#FF0000"
  self.itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
  self.itemFilter_ = itemFilter.new(self)
end

function Weapon_develop_intensify_windowView:OnActive()
  self:binderEvent()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  self.uiBinder.group_tab_item_1.tog_tab_select:AddListener(function(isOn)
    if isOn then
      self:setMode(true)
    end
  end)
  self.uiBinder.group_tab_item_2.tog_tab_select:AddListener(function(isOn)
    if isOn then
      self:setMode(false)
    end
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.resonancePowerVM_.CloseResonancePowerView()
  end)
  self:AddClick(self.uiBinder.btn_cancel, function()
    self:cancelDecompose()
  end)
  self:AddAsyncClick(self.uiBinder.btn_confirm, function()
    self:startDecomposeCheck()
  end)
  self:AddAsyncClick(self.uiBinder.btn_make, function()
    self:startCreate()
  end)
  self:AddClick(self.uiBinder.binder_num_module_tpl_1.btn_add, function()
    if self.createResonancePower_.count + 1 > self.maxCreateCount_ then
      Z.TipsVM.ShowTips(150103)
      local notEnoughItem_ = self.resonancePowerVM_.GetNotEnoughItemByCount(self.createResonancePower_.configId, self.createResonancePower_.count + 1)
      if notEnoughItem_ then
        if self.sourceTipId_ then
          Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
        end
        self.sourceTipId_ = Z.TipsVM.OpenSourceTips(notEnoughItem_, self.uiBinder.tips_root)
      end
    end
    local count_ = math.min(self.createResonancePower_.count + 1, self.maxCreateCount_)
    self:setCreateCount(count_)
    self:refreshCreateRightInfo()
  end)
  self:AddClick(self.uiBinder.binder_num_module_tpl_1.btn_reduce, function()
    local count_ = self.createResonancePower_.count - 1
    if count_ < 0 then
      count_ = 0
    end
    self:setCreateCount(count_)
    self:refreshCreateRightInfo()
  end)
  self.uiBinder.binder_num_module_tpl_1.slider_temp:AddListener(function()
    self.createResonancePower_.count = math.floor(self.uiBinder.binder_num_module_tpl_1.slider_temp.value)
    self:refreshCreateRightInfo()
  end)
  self:AddClick(self.uiBinder.btn_filter, function()
    self:openItemFilter()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self:onAskBtnClick()
  end)
  self:initSortUi()
  self.createResonancePower_ = {configId = -1, count = 1}
  self.resonanceQualityList_ = {}
  self.createConsumeItemBinder_ = {}
end

function Weapon_develop_intensify_windowView:initSortUi()
  self.isAscending_ = true
  self:AddClick(self.uiBinder.btn_sort, function()
    self:refreshSort(self.resonanceSortType_, not self.isAscending_)
  end)
  local options_ = {}
  self.sortRuleTypeNames_ = {
    E.ResonanceItemSortType.Quality
  }
  self.resonanceSortType_ = E.ResonanceItemSortType.Quality
  options_ = {
    [1] = Lang("ColorOrder")
  }
  self.uiBinder.dpd:AddListener(function(index)
    self:refreshSort(self.sortRuleTypeNames_[index + 1], self.isAscending_)
  end, true)
  self.uiBinder.dpd:ClearOptions()
  self.uiBinder.dpd:AddOptions(options_)
end

function Weapon_develop_intensify_windowView:refreshSort(type, isAscending)
  self.resonanceSortType_ = type
  self.isAscending_ = isAscending
  if self.createMode_ then
    self:refreshCreateUI()
  else
    self:refreshDecomposeUI()
  end
end

function Weapon_develop_intensify_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:unBinderEvent()
  self:unInitLoopListView()
  self.createConsumeUnit = {}
  self.haveInitCreate_ = false
  self.haveInitDecompose_ = false
  self.resonanceQualityList_ = {}
  for _, item_ in ipairs(self.createConsumeItemBinder_) do
    item_:UnInit()
  end
  self.createConsumeItemBinder_ = {}
  if self.itemFilter_ then
    self.itemFilter_:DeActive()
  end
  if self.sourceTipId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
  end
  self:unLoadMakeRedDotItem()
end

function Weapon_develop_intensify_windowView:OnRefresh()
  local togGroup = self.uiBinder.group_tab_item_1.tog_tab_select.group
  self.uiBinder.group_tab_item_1.tog_tab_select.group = nil
  self.uiBinder.group_tab_item_2.tog_tab_select.group = nil
  self.uiBinder.group_tab_item_1.tog_tab_select:SetIsOnWithoutCallBack(false)
  self.uiBinder.group_tab_item_2.tog_tab_select:SetIsOnWithoutCallBack(false)
  self.uiBinder.group_tab_item_1.tog_tab_select.group = togGroup
  self.uiBinder.group_tab_item_2.tog_tab_select.group = togGroup
  if self.viewData.createMode then
    self.uiBinder.group_tab_item_1.tog_tab_select.isOn = true
  else
    self.uiBinder.group_tab_item_2.tog_tab_select.isOn = true
  end
end

function Weapon_develop_intensify_windowView:binderEvent()
  Z.EventMgr:Add(Z.ConstValue.ItemFilterConfirm, self.onSelectFilter, self)
end

function Weapon_develop_intensify_windowView:unBinderEvent()
  Z.EventMgr:Remove(Z.ConstValue.ItemFilterConfirm, self.onSelectFilter, self)
end

function Weapon_develop_intensify_windowView:openItemFilter()
  local filterTypeParam_ = {}
  filterTypeParam_[E.ItemFilterType.ItemRare] = {}
  for k, _ in pairs(self.resonanceQualityList_) do
    table.insert(filterTypeParam_[E.ItemFilterType.ItemRare], k)
  end
  if table.zcount(self.resonanceQualityList_) > 0 then
    local viewData = {
      parentView = self,
      filterType = E.ItemFilterType.ItemRare,
      existFilterTags = self.filterTgas_,
      filterTypeParam_ = filterTypeParam_
    }
    self.itemFilter_:Active(viewData, self.uiBinder.node_filter_pos)
  else
    Z.TipsVM.ShowTips(150108)
  end
end

function Weapon_develop_intensify_windowView:onSelectFilter(filterTgas)
  if table.zcount(filterTgas) < 1 then
    self.filterTgas_ = nil
  end
  self.filterTgas_ = filterTgas
  if self.createMode_ then
    self:refreshCreateUI()
  else
    self:refreshDecomposeUI()
  end
end

function Weapon_develop_intensify_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Weapon_develop_intensify_windowView:initLoopListViewDecompose()
  if not self.haveInitDecompose_ then
    self.haveInitDecompose_ = true
    self.loopViewDecomposeMain_ = loopGridView.new(self, self.uiBinder.loop_item_main_decompose, decomposeMainLoopItem, "com_item_long_1")
    self.loopViewDecomposeMain_:Init({})
    self.loopViewDecomposeMain_.LoopGridView.mCanMultiSelected = true
    self.loopViewDecomposeConsume_ = loopGridView.new(self, self.uiBinder.loop_item_consume_decompose, decomposeConsumeLoopItem, "com_item_long_8")
    self.loopViewDecomposeConsume_:Init({})
    self.loopViewDecomposeGet_ = loopListView.new(self, self.uiBinder.loop_item_get_decompose, decomposeGetLoopItem, "com_item_long_2")
    self.loopViewDecomposeGet_:Init({})
  end
end

function Weapon_develop_intensify_windowView:initLoopListViewCreate()
  if not self.haveInitCreate_ then
    self.haveInitCreate_ = true
    self.loopViewCreateMain_ = loopGridView.new(self, self.uiBinder.loop_item_main_create, createMainLoopItem, "com_item_long_1")
    self.loopViewCreateMain_:Init({})
  end
end

function Weapon_develop_intensify_windowView:unInitLoopListView()
  if self.haveInitCreate_ then
    self.loopViewCreateMain_:UnInit()
    self.loopViewCreateMain_ = nil
  end
  if self.haveInitDecompose_ then
    self.loopViewDecomposeMain_:UnInit()
    self.loopViewDecomposeMain_ = nil
    self.loopViewDecomposeConsume_:UnInit()
    self.loopViewDecomposeConsume_ = nil
    self.loopViewDecomposeGet_:UnInit()
    self.loopViewDecomposeGet_ = nil
  end
end

function Weapon_develop_intensify_windowView:setMode(createMode)
  self.createMode_ = createMode
  self.viewData.createMode = createMode
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_decompose, not createMode)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_make, createMode)
  self.decomposeList_ = {}
  if self.viewData.startDecomposeData then
    table.insert(self.decomposeList_, self.viewData.startDecomposeData)
    self.viewData.startDecomposeData = nil
    self.sortToFront_ = true
  end
  if self.viewData.startCreateData then
    self.createResonancePower_.configId = self.viewData.startCreateData.configId
    self.createResonancePower_.count = self.viewData.startCreateData.count
    self.viewData.startCreateData = nil
    self.sortToFront_ = true
  else
    self.createResonancePower_.configId = -1
    self.createResonancePower_.count = 1
  end
  self:setCreateCount(1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_main_decompose, not createMode)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_main_create, createMode)
  local commonVM = Z.VMMgr.GetVM("common")
  local funcId = E.ResonanceFuncId.Decompose
  if self.createMode_ then
    funcId = E.ResonanceFuncId.Create
  end
  commonVM.SetLabText(self.uiBinder.lab_title, {
    E.BackpackFuncId.ResonanceSkill,
    funcId
  })
  if self.itemFilter_ then
    self.filterTgas_ = nil
    self.itemFilter_:DeActive()
  end
  if createMode then
    self:refreshCreateUI()
  else
    self:refreshDecomposeUI()
  end
  if self.sourceTipId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
  end
end

function Weapon_develop_intensify_windowView:refreshDecomposeUI()
  self:initLoopListViewDecompose()
  local sortFunc = self.itemSortFactoryVm_.GetItemSortFunc(E.BackPackItemPackageType.ResonanceSkill, {
    equipSortType = self.resonanceSortType_,
    isAscending = self.isAscending_
  })
  self.resonanceQualityList_ = {}
  local dataList_ = {}
  local dataListTmp_ = self.itemsVM_.GetItemIds(E.BackPackItemPackageType.ResonanceSkill, nil, sortFunc, false)
  for k, v in ipairs(dataListTmp_) do
    local itemConfig_ = self.itemTableMgr_.GetRow(v.configId)
    local isAccord = true
    if self.resonanceQualityList_[itemConfig_.Quality] == nil then
      self.resonanceQualityList_[itemConfig_.Quality] = 1
    end
    if self.filterTgas_ and self.filterTgas_[1] and table.zcount(self.filterTgas_[1]) > 0 then
      isAccord = false
      for key, tga in pairs(self.filterTgas_[1]) do
        if itemConfig_.Quality == key and tga then
          isAccord = true
          break
        end
      end
    end
    if itemConfig_ and itemConfig_.Type == E.ResonanceSkillItemType.Prop and isAccord then
      table.insert(dataList_, v)
    end
  end
  local selectList_ = {}
  if self.sortToFront_ then
    for index, v in ipairs(dataList_) do
      for _, data in ipairs(self.decomposeList_) do
        if v.itemUuid == data.itemUuid then
          table.insert(selectList_, index)
        end
      end
    end
    for _, v in ipairs(selectList_) do
      local tmp_ = dataList_[v]
      table.remove(dataList_, v)
      table.insert(dataList_, 1, tmp_)
    end
    self.sortToFront_ = false
  end
  self.loopViewDecomposeMain_:RefreshListView(dataList_)
  self.loopViewDecomposeMain_:ClearAllSelect()
  self.decomposeList_ = {}
  for ii = 1, #selectList_ do
    self.loopViewDecomposeMain_:SetSelected(ii)
  end
  local awardList = self.resonancePowerVM_.GetDecomposeGetAward(self.decomposeList_)
  self.loopViewDecomposeGet_:RefreshListView(awardList)
  self.loopViewDecomposeConsume_:RefreshListView(self.decomposeList_)
  local showEmptyDecompose_ = #self.decomposeList_ == 0
  local showDataEmptyDecompose_ = #dataList_ == 0 and not self.createMode_
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_decompose, showEmptyDecompose_ and not showDataEmptyDecompose_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, showDataEmptyDecompose_)
end

function Weapon_develop_intensify_windowView:refreshCreateUI()
  self:initLoopListViewCreate()
  self.resonanceQualityList_ = {}
  local dataRows_ = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetDatas()
  local dataList_ = {}
  for k, v in pairs(dataRows_) do
    local isAccord = true
    local itemConfig_ = self.itemTableMgr_.GetRow(v.Id)
    if self.resonanceQualityList_[itemConfig_.Quality] == nil then
      self.resonanceQualityList_[itemConfig_.Quality] = 1
    end
    if self.filterTgas_ and self.filterTgas_[1] then
      isAccord = false
      for key, tga in pairs(self.filterTgas_[1]) do
        if itemConfig_.Quality == key and tga then
          isAccord = true
          break
        end
      end
    end
    if isAccord then
      table.insert(dataList_, v.Id)
    end
  end
  if self.resonanceSortType_ == E.ResonanceItemSortType.Quality then
    table.sort(dataList_, function(a, b)
      local configA = self.itemTableMgr_.GetRow(a)
      local configB = self.itemTableMgr_.GetRow(b)
      if configA.Quality > configB.Quality then
        return self.isAscending_
      elseif configA.Quality < configB.Quality then
        return not self.isAscending_
      end
      return a < b
    end)
  end
  if self.sortToFront_ then
    local startData_
    for key, value in ipairs(dataList_) do
      if self.createResonancePower_ and self.createResonancePower_.configId == value then
        startData_ = key
      end
    end
    if startData_ then
      local tmp_ = dataList_[startData_]
      table.remove(dataList_, startData_)
      table.insert(dataList_, 1, tmp_)
    end
    self.sortToFront_ = false
  end
  self.loopViewCreateMain_:RefreshListView(dataList_)
  self.loopViewCreateMain_:ClearAllSelect()
  local selectIndex_ = 1
  if self.createResonancePower_ then
    for k, v in ipairs(dataList_) do
      if v == self.createResonancePower_.configId then
        selectIndex_ = k
        break
      end
    end
  end
  self.loopViewCreateMain_:SetSelected(selectIndex_)
end

function Weapon_develop_intensify_windowView:startDecomposeCheck()
  if table.zcount(self.decomposeList_) < 1 then
    Z.TipsVM.ShowTipsLang(150102)
    return
  end
  local haveHightQuality_ = false
  for k, v in pairs(self.decomposeList_) do
    local itemTableRow = self.itemTableMgr_.GetRow(v.configId)
    if itemTableRow and itemTableRow.Quality >= 3 then
      haveHightQuality_ = true
      break
    end
  end
  if haveHightQuality_ then
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("ResonancePowerDecomposeConfirm"), function()
      self:startDecompose()
    end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.ResonancePower_Decompose_Prompt)
  else
    self:startDecompose()
  end
end

function Weapon_develop_intensify_windowView:startDecompose()
  local uuids = {}
  for k, v in pairs(self.decomposeList_) do
    table.insert(uuids, v.itemUuid)
  end
  self.resonancePowerVM_.ReqDecomposeResonancePower(uuids, self.cancelSource:CreateToken())
  self.decomposeList_ = {}
  self:refreshDecomposeUI()
end

function Weapon_develop_intensify_windowView:cancelDecompose()
  self.decomposeList_ = {}
  self:refreshDecomposeUI()
end

function Weapon_develop_intensify_windowView:OnSelectResonancePowerItemDecompose(data)
  local index = -1
  for k, v in ipairs(self.decomposeList_) do
    if v == data then
      index = k
    end
  end
  if index ~= -1 then
    table.remove(self.decomposeList_, index)
  else
    table.insert(self.decomposeList_, data)
  end
  local awardList = self.resonancePowerVM_.GetDecomposeGetAward(self.decomposeList_)
  self.loopViewDecomposeGet_:RefreshListView(awardList)
  self.loopViewDecomposeConsume_:RefreshListView(self.decomposeList_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_decompose, #self.decomposeList_ == 0)
end

function Weapon_develop_intensify_windowView:OnSelectResonancePowerItemCreate(configId)
  self.createResonancePower_.configId = configId
  self:setCreateCount(1)
  self.maxCreateCount_, self.canCreate_, self.createNotEnoughItem_ = self.resonancePowerVM_.GetMaxCreateCount(configId)
  self.uiBinder.binder_num_module_tpl_1.slider_temp.maxValue = self.maxCreateCount_
  self.uiBinder.binder_num_module_tpl_1.slider_temp.minValue = 1
  self:refreshCreateRightInfo()
  self:loadMakeRedDotItem(configId)
end

function Weapon_develop_intensify_windowView:loadMakeRedDotItem(itemId)
  self:unLoadMakeRedDotItem()
  self.redDotId_ = bagRed.GetResonanceMakeRedId(itemId)
  Z.RedPointMgr.LoadRedDotItem(self.redDotId_, self, self.uiBinder.btn_make.transform)
end

function Weapon_develop_intensify_windowView:unLoadMakeRedDotItem()
  if self.redDotId_ then
    Z.RedPointMgr.RemoveNodeItem(self.redDotId_)
    self.redDotId_ = nil
  end
end

function Weapon_develop_intensify_windowView:setCreateCount(count)
  self.uiBinder.binder_num_module_tpl_1.slider_temp.value = count
end

function Weapon_develop_intensify_windowView:refreshCreateRightInfo()
  if self.createResonancePower_.configId == -1 then
    return
  end
  local itemConfig_ = self.itemTableMgr_.GetRow(self.createResonancePower_.configId)
  local aoyiItemConfig_ = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetRow(self.createResonancePower_.configId)
  local aoyiConfig_ = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetRow(aoyiItemConfig_.SkillId)
  if itemConfig_ and aoyiConfig_ then
    self.uiBinder.rimg_icon:SetImage(aoyiConfig_.ArtPreview)
    self.uiBinder.lab_createdes.text = itemConfig_.Description
  end
  self.uiBinder.binder_num_module_tpl_1.lab_num.text = self.createResonancePower_.count
  self.uiBinder.binder_num_module_tpl_1.slider_temp.value = self.createResonancePower_.count
  self.uiBinder.btn_make.IsDisabled = not self.canCreate_
  self.uiBinder.lab_createmax.text = self.maxCreateCount_
  if self.canCreate_ then
    self.uiBinder.lab_createmin.text = Z.RichTextHelper.ApplyColorTag("1", self.canCreateColor_)
  else
    self.uiBinder.lab_createmin.text = Z.RichTextHelper.ApplyColorTag("1", self.cantCreateColor_)
  end
  self:refreshCreateRightItemList()
end

function Weapon_develop_intensify_windowView:refreshCreateRightItemList()
  if self.IsLoadedConsumeItem_ then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.IsLoadedConsumeItem_ = true
    for k, v in ipairs(self.createConsumeUnit) do
      self:RemoveUiUnit(v)
    end
    self.createConsumeUnit = {}
    local consumeData_ = self.resonancePowerVM_.GetCreateConsumeAward(self.createResonancePower_.configId, self.createResonancePower_.count)
    local keys_ = {}
    for k, _ in pairs(consumeData_) do
      table.insert(keys_, k)
    end
    table.sort(keys_)
    for i = 1, #keys_ do
      local unitName_ = "CreateResueItem" .. keys_[i]
      local item_ = self:AsyncLoadUiUnit(GetLoadAssetPath("Resonance_power_item_long"), unitName_, self.uiBinder.layout_item)
      local ownNum = self.itemsVM_.GetItemTotalCount(keys_[i])
      local itemBinder_ = self.createConsumeItemBinder_[i]
      local itemViewData_ = {
        uiBinder = item_,
        lab = ownNum,
        expendCount = consumeData_[keys_[i]],
        labType = E.ItemLabType.Expend,
        configId = keys_[i],
        isClickOpenTips = true
      }
      if itemBinder_ == nil then
        itemBinder_ = itemBinder.new(self)
        table.insert(self.createConsumeItemBinder_, itemBinder_)
      end
      itemBinder_:Init(itemViewData_)
      table.insert(self.createConsumeUnit, unitName_)
    end
    self.IsLoadedConsumeItem_ = false
  end)()
end

function Weapon_develop_intensify_windowView:startCreate()
  if not self.canCreate_ then
    Z.TipsVM.ShowTips(150104)
    if self.createNotEnoughItem_ then
      if self.sourceTipId_ then
        Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
      end
      self.sourceTipId_ = Z.TipsVM.OpenSourceTips(self.createNotEnoughItem_, self.uiBinder.tips_root)
    end
    return
  end
  if self.createResonancePower_.configId == -1 then
    return
  end
  local success_ = self.resonancePowerVM_.ReqCreateResonancePower(self.createResonancePower_.configId, self.createResonancePower_.count, self.cancelSource:CreateToken())
  if success_ then
    self:refreshCreateUI()
  end
end

function Weapon_develop_intensify_windowView:onAskBtnClick()
  local helpsysVM = Z.VMMgr.GetVM("helpsys")
  if self.createMode_ then
    helpsysVM.CheckAndShowView(400103)
  else
    helpsysVM.CheckAndShowView(400104)
  end
end

function Weapon_develop_intensify_windowView:GetCacheData()
  local viewData = self.viewData or {}
  viewData.createMode = self.createMode_
  return viewData
end

return Weapon_develop_intensify_windowView
