local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_develop_intensify_windowView = class("Weapon_develop_intensify_windowView", super)
local makeSubView = require("ui.view.weapon_develop_make_sub_view")
local decomposeSubView = require("ui.view.weapon_develop_decompose_sub_view")
local loopGridView = require("ui.component.loop_grid_view")
local createMainLoopItem = require("ui.component.resonance_power.resonance_power_createmain_loop_item")
local decomposeMainLoopItem = require("ui.component.resonance_power.resonance_power_decomposemain_loop_item")
local common_filter_helper = require("common.common_filter_helper")

function Weapon_develop_intensify_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_develop_intensify_window")
  self.resonancePowerVM_ = Z.VMMgr.GetVM("resonance_power")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.makeSubView_ = makeSubView.new(self)
  self.decomposeSubView_ = decomposeSubView.new(self)
  self.filterHelper_ = common_filter_helper.new(self)
end

function Weapon_develop_intensify_windowView:initData()
  self.togConfig_ = {
    [E.ResonanceFuncId.Create] = self.uiBinder.group_tab_item_1,
    [E.ResonanceFuncId.Decompose] = self.uiBinder.group_tab_item_2
  }
  self.filterQualityList_ = {}
end

function Weapon_develop_intensify_windowView:initComponent()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  self:initToggle()
  self:initFilter()
  self:initDropDown()
  self:initLoopListView()
  self:AddClick(self.uiBinder.btn_close, function()
    self.resonancePowerVM_.CloseResonancePowerView()
  end)
  self:AddClick(self.uiBinder.btn_filter, function()
    self:openItemFilter()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self:onAskBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_sort, function()
    self:refreshSort(self.resonanceSortType_, not self.isAscending_)
  end)
end

function Weapon_develop_intensify_windowView:OnActive()
  self:bindEvents()
  self:initData()
  self:initComponent()
  self:switchOnOpen()
end

function Weapon_develop_intensify_windowView:initDropDown()
  self.isAscending_ = true
  self.resonanceSortType_ = E.ResonanceItemSortType.Quality
  local options_ = {
    [1] = Lang("ColorOrder")
  }
  local optionTypes = {
    [1] = E.ResonanceItemSortType.Quality
  }
  self.uiBinder.dpd:AddListener(function(index)
    self:refreshSort(optionTypes[index + 1], self.isAscending_)
  end, true)
  self.uiBinder.dpd:ClearOptions()
  self.uiBinder.dpd:AddOptions(options_)
end

function Weapon_develop_intensify_windowView:refreshSort(type, isAscending)
  self.resonanceSortType_ = type
  self.isAscending_ = isAscending
  self:RefreshListView(true)
end

function Weapon_develop_intensify_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:unBindEvents()
  self:unInitLoopListView()
  self:unInitFilter()
  self:closeSubView()
  Z.CommonTipsVM.CloseRichText()
end

function Weapon_develop_intensify_windowView:OnRefresh()
end

function Weapon_develop_intensify_windowView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.ItemFilterConfirm, self.onSelectFilter, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
end

function Weapon_develop_intensify_windowView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.ItemFilterConfirm, self.onSelectFilter, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
end

function Weapon_develop_intensify_windowView:initFilter()
  self.filterDatas_ = nil
  self.filterParam_ = nil
  self.filterTypesDict_ = {
    [E.ResonanceFuncId.Create] = {
      E.CommonFilterType.ResonanceHave,
      E.CommonFilterType.ResonanceSkillRarity,
      E.CommonFilterType.ResonanceSkillType
    },
    [E.ResonanceFuncId.Decompose] = {
      E.CommonFilterType.ResonanceSkillRarity,
      E.CommonFilterType.ResonanceSkillType
    }
  }
  local filterTypes = self.filterTypesDict_[E.ResonanceFuncId.Create]
  self.filterHelper_:Init(Lang("Screen"), filterTypes, self.uiBinder.node_filter_root, self.uiBinder.node_filter_pos, function(filterRes)
    self:onSelectFilter(filterRes)
  end)
  self.filterHelper_:ActiveEliminateSub(self.filterDatas_)
  self:AddClick(self.uiBinder.btn_filter, function()
    self:openItemFilter()
  end)
end

function Weapon_develop_intensify_windowView:unInitFilter()
  self:clearFilter()
end

function Weapon_develop_intensify_windowView:clearFilter()
  self.filterHelper_:DeActive()
  self.filterDatas_ = nil
  self.filterParam_ = nil
end

function Weapon_develop_intensify_windowView:openItemFilter()
  local viewData = {
    filterTypes = self.filterTypesDict_[self.curSubFuncId_],
    filterRes = self.filterParam_
  }
  self.filterHelper_:ActiveFilterSub(viewData)
end

function Weapon_develop_intensify_windowView:onSelectFilter(filterTags)
  if table.zcount(filterTags) < 1 then
    self.filterDatas_ = nil
  end
  self.filterDatas_ = filterTags
  self:RefreshListView(true)
end

function Weapon_develop_intensify_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Weapon_develop_intensify_windowView:initLoopListView()
  self.loopGridView_ = loopGridView.new(self, self.uiBinder.loop_item_main_decompose)
  self.loopGridView_:SetGetItemClassFunc(function()
    if self.curSubFuncId_ == E.ResonanceFuncId.Create then
      return createMainLoopItem
    elseif self.curSubFuncId_ == E.ResonanceFuncId.Decompose then
      return decomposeMainLoopItem
    end
  end)
  self.loopGridView_:SetGetPrefabNameFunc(function()
    if self.curSubFuncId_ == E.ResonanceFuncId.Create then
      return "item_create"
    elseif self.curSubFuncId_ == E.ResonanceFuncId.Decompose then
      return "item_decompose"
    end
  end)
  self.loopGridView_:Init({})
end

function Weapon_develop_intensify_windowView:RefreshListView(clearSelect, getSelectInfoFunc)
  if clearSelect then
    self.loopGridView_:ClearAllSelect()
  end
  self.curDataList_ = {}
  if self.curSubFuncId_ == E.ResonanceFuncId.Create then
    self.curDataList_ = self.resonancePowerVM_.GetResonanceMakeList(self.filterDatas_, self.resonanceSortType_, self.isAscending_)
  elseif self.curSubFuncId_ == E.ResonanceFuncId.Decompose then
    self.curDataList_ = self.resonancePowerVM_.GetResonanceDecomposeList(self.filterDatas_, self.resonanceSortType_, self.isAscending_, self.curSubView_.decomposeDict_)
  end
  self.loopGridView_:SetCanMultiSelected(self.curSubFuncId_ == E.ResonanceFuncId.Decompose)
  self.loopGridView_:RefreshListView(self.curDataList_)
  if self.curSubFuncId_ == E.ResonanceFuncId.Create then
    local selectIndex
    if self.viewData and self.viewData.SelectInfo then
      selectIndex = self.viewData.SelectInfo
      self.viewData.SelectInfo = nil
    elseif getSelectInfoFunc ~= nil then
      selectIndex = getSelectInfoFunc(self.curDataList_)
    end
    local curSelectIndex = selectIndex or self.loopGridView_:GetSelectedIndex()
    if curSelectIndex < 1 then
      curSelectIndex = 1
    end
    self.loopGridView_:SetSelected(curSelectIndex)
    self.loopGridView_:MovePanelToItemIndex(curSelectIndex)
  elseif self.curSubFuncId_ == E.ResonanceFuncId.Decompose then
    local selectIndexList
    if self.viewData and self.viewData.SelectInfo then
      selectIndexList = {}
      for i, v in ipairs(self.viewData.SelectInfo) do
        selectIndexList[i] = v
      end
      self.viewData.SelectInfo = nil
    elseif getSelectInfoFunc ~= nil then
      selectIndexList = getSelectInfoFunc(self.curDataList_)
    end
    if selectIndexList then
      for i, v in ipairs(selectIndexList) do
        self.loopGridView_:SetSelected(v)
      end
    end
  end
  local isEmpty = #self.curDataList_ == 0
  self:SetUIVisible(self.uiBinder.node_info, not isEmpty)
  self:SetUIVisible(self.uiBinder.node_empty_make, isEmpty and self.curSubFuncId_ == E.ResonanceFuncId.Create)
  self:SetUIVisible(self.uiBinder.node_empty_decompose, isEmpty and self.curSubFuncId_ == E.ResonanceFuncId.Decompose)
end

function Weapon_develop_intensify_windowView:unInitLoopListView()
  self.loopGridView_:UnInit()
  self.loopGridView_ = nil
end

function Weapon_develop_intensify_windowView:initToggle()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  for k, v in pairs(self.togConfig_) do
    v.tog_tab_select.group = self.uiBinder.tog_group_tab
    v.tog_tab_select:AddListener(function(isOn)
      if isOn then
        self.commonVM_.CommonPlayTogAnim(v.anim_tog, self.cancelSource:CreateToken())
        self:switchSubView(k)
      end
    end)
    v.tog_tab_select.OnPointClickEvent:AddListener(function()
      local isFuncOpen = gotoFuncVM.CheckFuncCanUse(k)
      v.tog_tab_select.IsToggleCanSwitch = isFuncOpen
    end)
    local isFuncOpen = gotoFuncVM.CheckFuncCanUse(E.ResonanceFuncId.Create, true)
    v.Ref.UIComp:SetVisible(isFuncOpen)
  end
end

function Weapon_develop_intensify_windowView:switchOnOpen()
  local subFuncId = E.ResonanceFuncId.Create
  if self.viewData and self.viewData.FuncId then
    subFuncId = self.viewData.FuncId
  end
  local binder = self.togConfig_[subFuncId]
  if binder.tog_tab_select.isOn then
    self:switchSubView(subFuncId)
  else
    binder.tog_tab_select.isOn = true
  end
end

function Weapon_develop_intensify_windowView:switchSubView(subFuncId)
  if self.curSubFuncId_ and self.curSubFuncId_ == subFuncId then
    return
  end
  self:closeSubView()
  self:clearFilter()
  self.curSubFuncId_ = subFuncId
  if self.curSubFuncId_ == E.ResonanceFuncId.Create then
    self.curSubView_ = self.makeSubView_
  elseif self.curSubFuncId_ == E.ResonanceFuncId.Decompose then
    self.curSubView_ = self.decomposeSubView_
  else
    return
  end
  self.uiBinder.lab_title.text = self.commonVM_.GetTitleByConfig({
    E.FunctionID.WeaponAoyiSkill,
    subFuncId
  })
  if self.curSubView_ then
    self.curSubView_:Active(nil, self.uiBinder.node_right)
  end
end

function Weapon_develop_intensify_windowView:closeSubView()
  if self.curSubView_ then
    self.curSubView_:DeActive()
    self.curSubView_ = nil
  end
  self.curSubFuncId_ = nil
end

function Weapon_develop_intensify_windowView:onAskBtnClick()
  local helpSysVM = Z.VMMgr.GetVM("helpsys")
  if self.curSubFuncId_ == E.ResonanceFuncId.Create then
    helpSysVM.CheckAndShowView(400103)
  elseif self.curSubFuncId_ == E.ResonanceFuncId.Decompose then
    helpSysVM.CheckAndShowView(400104)
  end
end

function Weapon_develop_intensify_windowView:GetCacheData()
  local viewData = self.viewData or {}
  viewData.FuncId = self.curSubFuncId_
  if self.curSubFuncId_ and self.curSubFuncId_ == E.ResonanceFuncId.Create then
    viewData.SelectInfo = self.loopGridView_:GetSelectedIndex()
  elseif self.curSubFuncId_ and self.curSubFuncId_ == E.ResonanceFuncId.Decompose then
    local list = self.loopGridView_:GetMultiSelectedIndexList()
    viewData.SelectInfo = {}
    for i = 0, list.Count - 1 do
      viewData.SelectInfo[i + 1] = list[i] + 1
    end
  end
  return viewData
end

function Weapon_develop_intensify_windowView:onItemChange(item)
  if item == nil or item.configId == nil then
    return
  end
  if self.curSubView_ and self.curSubView_.OnItemChanged then
    self.curSubView_:OnItemChanged()
  end
end

function Weapon_develop_intensify_windowView:GetFilterQualityList()
  return self.filterQualityList_
end

function Weapon_develop_intensify_windowView:GetCurrentDataList()
  return self.curDataList_
end

function Weapon_develop_intensify_windowView:GetDecomposeSelectCount(itemUuid)
  if self.curSubView_ and self.curSubView_.GetDecomposeSelectCount then
    return self.curSubView_:GetDecomposeSelectCount(itemUuid)
  else
    return 0
  end
end

function Weapon_develop_intensify_windowView:OnSelectResonancePowerItemCreate(data)
  if self.curSubView_ and self.curSubView_.OnSelectResonancePowerItemCreate then
    self.curSubView_:OnSelectResonancePowerItemCreate(data)
  end
end

function Weapon_develop_intensify_windowView:OnSelectResonancePowerItemDecompose(isSelected, data)
  if self.curSubView_ and self.curSubView_.OnSelectResonancePowerItemDecompose then
    self.curSubView_:OnSelectResonancePowerItemDecompose(isSelected, data)
  end
end

return Weapon_develop_intensify_windowView
