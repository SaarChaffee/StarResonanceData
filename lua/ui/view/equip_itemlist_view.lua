local UI = Z.UI
local super = require("ui.ui_subview_base")
local Equip_itemlistView = class("Equip_itemlistView", super)
local loopGridView = require("ui/component/loop_grid_view")
local default_equip_loop_list_item_ = require("ui.component.equip.new_default_equip_loop_list_item")
local equip_decompose_loop_list_item_ = require("ui.component.equip.equip_decompose_loop_list_item")

function Equip_itemlistView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "equip_list_sub", "equip/equip_list_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
  self.itemTypeTableMgr_ = Z.TableMgr.GetTable("ItemTypeTableMgr")
  self.equipTableMgr_ = Z.TableMgr.GetTable("EquipTableMgr")
  self.itemFilterFactoryVM_ = Z.VMMgr.GetVM("item_filter_factory")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  self.funcVm_ = Z.VMMgr.GetVM("gotofunc")
end

function Equip_itemlistView:initUiBinders()
  self.scrollView_ = self.uiBinder.scrollview_item
  self.sortRuleUibinder_ = self.uiBinder.binder_sort_rule
  self.toggleGroup_ = self.uiBinder.layout_tab
  self.tipsParent_ = self.uiBinder.group_item_tips_parent
end

function Equip_itemlistView:OnActive()
  self.uiBinder.Trans:SetAnchors(0, 1, 0, 1)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:onStartAnimShow()
  self:initUiBinders()
  if self.viewData and self.viewData.funcViewType then
    self.funcViewType_ = self.viewData.funcViewType
  end
  self:initSortUi()
  self.curPartId_ = nil
  self.firstSelected_ = true
  self:initEquipPartTabUi()
  self.partSelectItem_ = {}
  self:initEquipLoopItems()
  self:initEquipLoopScrollView()
  self:RefreshItemInfoDatas()
  Z.EventMgr:Add(Z.ConstValue.Equip.IsHideLeftView, self.isHideLeftView, self)
end

function Equip_itemlistView:initEquipLoopItems()
  self.funcLoopItems_ = {}
  self.funcLoopItems_[E.EquipFuncViewType.Weapon] = default_equip_loop_list_item_
  self.funcLoopItems_[E.EquipFuncViewType.Equip] = default_equip_loop_list_item_
  self.funcLoopItems_[E.EquipFuncViewType.Decompose] = equip_decompose_loop_list_item_
  self.funcLoopItems_[E.EquipFuncViewType.Recast] = default_equip_loop_list_item_
end

function Equip_itemlistView:initEquipLoopScrollView()
  self.multiSelectedItems_ = {}
  self.loopGridView_ = loopGridView.new(self, self.scrollView_, self.funcLoopItems_[self.funcViewType_], "com_item_long_3")
  self.loopGridView_:Init({})
  if self.funcViewType_ == E.EquipFuncViewType.Decompose then
    self.loopGridView_:SetCanMultiSelected(true)
  else
    self.loopGridView_:SetCanMultiSelected(false)
  end
end

function Equip_itemlistView:initEquipPartTabUi()
  self.equipPartTabs_ = {}
  self.equipPartTabs_[E.EquipPart.Weapon] = self.uiBinder.binder_tab_item_weapon
  self.equipPartTabs_[E.EquipPart.Helmet] = self.uiBinder.binder_tab_item_helmet
  self.equipPartTabs_[E.EquipPart.Clothes] = self.uiBinder.binder_tab_item_clothes
  self.equipPartTabs_[E.EquipPart.Handguards] = self.uiBinder.binder_tab_item_handguards
  self.equipPartTabs_[E.EquipPart.Shoe] = self.uiBinder.binder_tab_item_shoes
  self.equipPartTabs_[E.EquipPart.Necklace] = self.uiBinder.binder_tab_item_necklace
  self.equipPartTabs_[E.EquipPart.Earring] = self.uiBinder.binder_tab_item_earring
  self.equipPartTabs_[E.EquipPart.Ring] = self.uiBinder.binder_tab_item_ring
  self.equipPartTabs_[E.EquipPart.LeftBracelet] = self.uiBinder.binder_tab_item_left_bracelet
  self.equipPartTabs_[E.EquipPart.RightBracelet] = self.uiBinder.binder_tab_item_right_bracelet
  self.equipPartTabs_[E.EquipPart.Amulet] = self.uiBinder.binder_tab_item_amulet
  for k, v in pairs(self.equipPartTabs_) do
    local partId = k
    v.tog_tab.group = self.toggleGroup_
    v.eff_two_tog:SetEffectGoVisible(false)
    local equipPartRow = Z.TableMgr.GetTable("EquipPartTableMgr").GetRow(partId)
    local shouldShowLock = Z.ConditionHelper.CheckCondition(equipPartRow.UnlockCondition)
    v.Ref:SetVisible(v.img_lock, not shouldShowLock)
    local colorA = shouldShowLock and 128 or 64
    v.img_icon_off:SetColor(Color.New(1, 1, 1, colorA / 255))
    if equipPartRow then
      v.tog_tab:AddListener(function(isOn)
        if isOn then
          if Z.ConditionHelper.CheckCondition(equipPartRow.UnlockCondition, true) then
            if self.funcViewType_ == E.EquipFuncViewType.Decompose then
              self.unSelectTag_ = true
            end
            self:refreshEquipListByPartId(partId, false, v)
            if self.funcViewType_ == E.EquipFuncViewType.Decompose then
              self.unSelectTag_ = false
            end
          elseif self.curPartId_ then
            self.equipPartTabs_[self.curPartId_].tog_tab.isOn = true
          end
        end
      end, nil)
    end
  end
end

function Equip_itemlistView:initSortUi()
  if self.funcViewType_ and self.funcViewType_ == E.EquipFuncViewType.Decompose then
    self.isAscending_ = true
  else
    self.isAscending_ = false
  end
  self:AddClick(self.sortRuleUibinder_.sort_btn, function()
    self.selectedItemUuid_ = nil
    self:refreshSort(self.equipSortTyp_, not self.isAscending_)
  end)
  local options_ = {}
  self.sortRuleTypeNames_ = {
    E.EquipItemSortType.Quality,
    E.EquipItemSortType.GS
  }
  self.equipSortTyp_ = E.EquipItemSortType.Quality
  options_ = {
    [1] = Lang("ColorOrder"),
    [2] = Lang("GsOrder")
  }
  self.sortRuleUibinder_.dpd:ClearAll()
  self.sortRuleUibinder_.dpd:AddListener(function(index)
    self.selectedItemUuid_ = nil
    self:refreshSort(self.sortRuleTypeNames_[index + 1], self.isAscending_)
  end, true)
  self.sortRuleUibinder_.dpd:AddOptions(options_)
end

function Equip_itemlistView:RefreshItemInfoDatas()
  if self.viewData and self.viewData.filterFuncs then
    self.filterFuncs_ = self.viewData.filterFuncs
  end
  self.allEquipInfos_ = self.itemsVm_.GetItemIds(E.BackPackItemPackageType.Equip, self.filterFuncs_, nil)
end

function Equip_itemlistView:OnDeActive()
  if self.equipPartTabs_ then
    for k, v in pairs(self.equipPartTabs_) do
      v.tog_tab:RemoveAllListeners()
    end
  end
  if self.loopGridView_ then
    self.loopGridView_:UnInit()
    self.loopGridView_ = nil
  end
  self.curPartId_ = nil
  self.equipPartTabs_ = nil
  self.itemSelectedFunc_ = nil
  self.sortRuleInfos_ = nil
  self.sortRuleTypeNames_ = nil
  self.viewData = nil
  self.selectedConfigId_ = nil
  self.selectedItemUuid_ = nil
  self.multiSelectedItems_ = nil
  self.isSetData_ = false
  self.isClearingSelecte_ = false
  self.funcViewType_ = nil
  self.funcLoopItems_ = nil
  self.onPartChanged_ = nil
end

function Equip_itemlistView:OnRefresh()
  if self.viewData then
    if self.viewData.itemSelectedFunc then
      self.itemSelectedFunc_ = self.viewData.itemSelectedFunc
    end
    if self.viewData.itemUuid then
      self.selectedItemUuid_ = self.viewData.itemUuid
    end
    if self.viewData.itemids then
      self.multiSelectedItems_ = self.viewData.itemids
    end
    if self.viewData.onPartChanged then
      self.onPartChanged_ = self.viewData.onPartChanged
    end
    self.showItemTips_ = self.viewData.showItemTips
  end
  if self.viewData and self.viewData.configId then
    local equipTableRow = self.equipTableMgr_.GetRow(self.viewData.configId)
    if equipTableRow == nil then
      return
    end
    self.curPartId_ = equipTableRow.EquipPart
  elseif self.viewData and self.viewData.partId then
    self.curPartId_ = self.viewData.partId
  elseif self.selectedConfigId_ then
    local equipTableRow = self.equipTableMgr_.GetRow(self.selectedConfigId_)
    if equipTableRow == nil then
      return
    end
    self.curPartId_ = equipTableRow.EquipPart
  elseif self.multiSelectedItems_ then
    for key, value in pairs(self.multiSelectedItems_) do
      local equipTableRow = self.equipTableMgr_.GetRow(value)
      if equipTableRow == nil then
        return
      end
      self.curPartId_ = equipTableRow.EquipPart
      break
    end
  end
  self.viewData = nil
  if not self.curPartId_ then
    self.curPartId_ = E.EquipPart.Weapon
  end
  self:refreshEquipListByPartId(self.curPartId_, true, self.equipPartTabs_[self.curPartId_])
end

function Equip_itemlistView:refreshEquipListByPartId(partId, force, animUiBinder)
  if partId == self.curPartId_ and not force then
    return
  end
  if self.curPartId_ then
    self.equipPartTabs_[self.curPartId_].eff_two_tog:SetEffectGoVisible(false)
  end
  animUiBinder.tog_tab_select_anim:Restart(Z.DOTweenAnimType.Open)
  self.equipPartTabs_[partId].eff_two_tog:SetEffectGoVisible(true)
  self.equipPartTabs_[partId].tog_tab.isOn = true
  self.curPartId_ = partId
  if self.onPartChanged_ then
    self.onPartChanged_(partId)
  end
  self:refreshloopScrollView()
end

function Equip_itemlistView:refreshSort(type, isAscending)
  self.equipSortTyp_ = type
  self.isAscending_ = isAscending
  if self.funcViewType_ == E.EquipFuncViewType.Decompose then
    self.unSelectTag_ = true
  end
  self:refreshloopScrollView(false)
  if self.funcViewType_ == E.EquipFuncViewType.Decompose then
    self.unSelectTag_ = false
  end
end

function Equip_itemlistView:refreshloopScrollView(playAnim)
  local data = {}
  local equipTabMgr = Z.TableMgr.GetTable("EquipTableMgr")
  for _, value in pairs(self.allEquipInfos_) do
    local equipTableData = equipTabMgr.GetRow(value.configId)
    if equipTableData and equipTableData.EquipPart == self.curPartId_ then
      table.insert(data, {
        configId = value.configId,
        itemUuid = value.itemUuid
      })
    end
  end
  table.sort(data, self:getSortFunc())
  self:setItemDatas(data, playAnim)
end

function Equip_itemlistView:NeedShowItemTips()
  return self.showItemTips_
end

function Equip_itemlistView:ItemSelected(itemUuid, configId, isSelected)
  if self.isClearingSelecte_ then
    return
  end
  if isSelected then
    self.selectedItemUuid_ = itemUuid
    self.selectedConfigId_ = configId
    self.multiSelectedItems_[itemUuid] = configId
  elseif not self.unSelectTag_ then
    self.multiSelectedItems_[itemUuid] = nil
  end
  if self.unSelectTag_ then
    return
  end
  if self.itemSelectedFunc_ then
    self.itemSelectedFunc_(itemUuid, configId, isSelected)
  end
end

function Equip_itemlistView:IsNeedSelected(itemUuid)
  for index, value in ipairs(self.loopGridView_.DataList) do
    if not self.multiSelectedItems_ then
      return
    elseif itemUuid == value.itemUuid and self.multiSelectedItems_[itemUuid] then
      return true
    end
  end
  return false
end

function Equip_itemlistView:GetEquipItemTipsParent()
  return self.tipsParent_.transform
end

function Equip_itemlistView:getSortFunc()
  return self.itemSortFactoryVm_.GetItemSortFunc(E.BackPackItemPackageType.Equip, {
    equipSortType = self.equipSortTyp_,
    isAscending = self.isAscending_
  })
end

function Equip_itemlistView:getSelectIndex(data)
  if data == nil then
    return
  end
  self.curItemDatas_ = data
  if self.funcViewType_ == E.EquipFuncViewType.Equip and self.selectedItemUuid_ == nil then
    local equipInfo = Z.ContainerMgr.CharSerialize.equip.equipList[self.curPartId_]
    for index, value in ipairs(data) do
      if not equipInfo then
        return index
      end
      if value.itemUuid == equipInfo.itemUuid then
        return index
      end
    end
    return
  end
  if self.funcViewType_ == E.EquipFuncViewType.Decompose then
    if self.firstSelected_ and self.selectedItemUuid_ then
      for index, value in ipairs(data) do
        if value.itemUuid == self.selectedItemUuid_ then
          return index
        end
      end
    end
    self.firstSelected_ = false
    return
  end
  if self.selectedItemUuid_ then
    for index, value in ipairs(data) do
      if value.itemUuid == self.selectedItemUuid_ then
        return index
      end
    end
  end
end

function Equip_itemlistView:setItemDatas(data, playAnim)
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.RefreshEmptyState, table.zcount(data) ~= 0, Lang("EquipItemListEmpty" .. self.funcViewType_))
  local selectIndex = self:getSelectIndex(data) or 1
  self.loopGridView_:ClearAllSelect()
  self.loopGridView_:RefreshListView(data, false)
  self.loopGridView_:MovePanelToItemIndex(selectIndex)
  if self.funcViewType_ == E.EquipFuncViewType.Decompose then
    if self.firstSelected_ then
      self.loopGridView_:SetSelected(selectIndex)
      self.firstSelected_ = false
    end
  else
    self.loopGridView_:SetSelected(selectIndex)
  end
end

function Equip_itemlistView:getDecomposeListOffset(data)
  for index, value in ipairs(data) do
    if self.multiSelectedItems_ then
      for uuid, configId in pairs(self.multiSelectedItems_) do
        if uuid == value.itemUuid then
          return index - 1
        end
      end
    else
      break
    end
  end
  return 0
end

function Equip_itemlistView:ClearAllSelect()
  if not self.loopGridView_ then
    return
  end
  self.multiSelectedItems_ = {}
  self.loopGridView_:ClearAllSelect()
  self.selectedConfigId_ = nil
  self.selectedItemUuid_ = nil
end

function Equip_itemlistView:SetSelectItem(selectedItemUuid)
  for index, value in ipairs(self.curItemDatas_) do
    if value.itemUuid == selectedItemUuid then
      self.loopGridView_:SetSelected(index)
      return
    end
  end
end

function Equip_itemlistView:GetCurSelectPartId()
  return self.curPartId_
end

function Equip_itemlistView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Equip_itemlistView:AddSelectedItems(items)
  if not self.multiSelectedItems_ then
    self.multiSelectedItems_ = {}
  end
  for uuid, configId in pairs(items) do
    if self.multiSelectedItems_[uuid] == nil then
      self.multiSelectedItems_[uuid] = configId
      self:SetSelectItem(uuid)
    end
  end
end

function Equip_itemlistView:isHideLeftView(isHide)
  self.uiBinder.Ref.UIComp:SetVisible(not isHide)
end

return Equip_itemlistView
