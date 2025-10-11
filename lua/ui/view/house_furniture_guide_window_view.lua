local UI = Z.UI
local super = require("ui.ui_view_base")
local House_furniture_guide_windowView = class("House_furniture_guide_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local loopGridView = require("ui.component.loop_grid_view")
local materialsItem = require("ui.component.house.house_furniture_materials_loop_item")
local firstclass_item = require("ui.component.house.house_firstclass_loop_item")
local guideItem = require("ui.component.house.house_furniture_guide_loop_item")
local toggleGroup_ = require("ui/component/togglegroup")

function House_furniture_guide_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_furniture_guide_window")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  self.helpSysVM_ = Z.VMMgr.GetVM("helpsys")
  self.commonVm_ = Z.VMMgr.GetVM("common")
end

function House_furniture_guide_windowView:initBinders()
  self.closeBtn_ = self.uiBinder.close_btn
  self.sortBtn_ = self.uiBinder.btn_sort
  self.filterBtn_ = self.uiBinder.btn_filter
  self.itemLoopList_ = self.uiBinder.scrollview_item
  self.dpd_ = self.uiBinder.dpd
  self.tipsBinder_ = self.uiBinder.cont_right_info
  self.itemIconRImg_ = self.tipsBinder_.rimg_icon
  self.nameLab_ = self.tipsBinder_.lab_name
  self.infoLab_ = self.tipsBinder_.lab_info
  self.unlockBtn_ = self.tipsBinder_.btn_lock.btn
  self.conditionParent_ = self.tipsBinder_.node_learn_conditions
  self.materialNode_ = self.tipsBinder_.node_needddd_item
  self.materialsLoopList_ = self.tipsBinder_.scrollview
  self.studyImg_ = self.tipsBinder_.img_product_bg
  self.prefabCache_ = self.uiBinder.prefab_cache
  self.firstClassTogGroup_ = self.uiBinder.layout_left_tab
  self.emptyNode_ = self.uiBinder.node_empty
  self.middleNode_ = self.uiBinder.node_middle
  self.titleLab_ = self.uiBinder.lab_title
  self.askBtn_ = self.uiBinder.btn_ask
  self.anim_do_ = self.uiBinder.anim_do
end

function House_furniture_guide_windowView:initData()
  self.selectedItem_ = nil
  self.equipSortTyp_ = E.EquipItemSortType.Quality
  self.isAscending_ = false
  self.itemUnits_ = {}
  self.itemTokens_ = {}
end

function House_furniture_guide_windowView:initBtns()
  self:AddClick(self.closeBtn_, function()
    self.houseVm_.CloseHouseFurnitureGuideView()
  end)
  self:AddAsyncClick(self.unlockBtn_, function()
    if self.lockBntIsDisabled_ then
      return
    end
    if Z.ConditionHelper.CheckCondition(self.selectedItem_.UnlockCondition, true) then
      local ret = self.houseVm_.AsyncUnlockFurnitureRecipe(self.selectedItem_.Id, self.cancelSource:CreateToken())
      if ret == 0 then
        self.curUnlockId_ = self.selectedItem_.Id
      end
    end
  end)
  self:AddClick(self.askBtn_, function()
    self.helpSysVM_.OpenFullScreenTipsView(40003)
  end)
  self:AddClick(self.sortBtn_, function()
    self.isAscending_ = not self.isAscending_
    self:getFurnitureItemList(self.selectedType_)
  end)
  self:AddClick(self.filterBtn_, function()
  end)
end

function House_furniture_guide_windowView:getFurnitureItemList(type)
  self.selectedType_ = type
  self.allFurnitureItemList_ = self.houseVm_.GetFurnitureItemList(type)
  local lockList = {}
  local unlockList = {}
  local lockIndex = 1
  local unlockIndex = 1
  for index, value in ipairs(self.allFurnitureItemList_) do
    if #value.UnlockItem > 0 or 0 < #value.UnlockCondition then
      local isUnlock = false
      if 0 < #value.UnlockCondition then
        isUnlock = Z.ConditionHelper.CheckCondition(value.UnlockCondition)
      else
        isUnlock = true
      end
      if #value.UnlockItem > 0 and isUnlock then
        isUnlock = self.houseVm_.CheckIsUnlock(value.Id)
      end
      if isUnlock then
        unlockList[unlockIndex] = value
        unlockIndex = unlockIndex + 1
      else
        lockList[lockIndex] = value
        lockIndex = lockIndex + 1
      end
    else
      unlockList[unlockIndex] = value
      unlockIndex = unlockIndex + 1
    end
  end
  table.sort(lockList, function(left, right)
    return self:getSortFunc()({
      configId = left.Id
    }, {
      configId = right.Id
    })
  end)
  table.sort(unlockList, function(left, right)
    return self:getSortFunc()({
      configId = left.Id
    }, {
      configId = right.Id
    })
  end)
  table.zmerge(unlockList, lockList)
  local isEmpty = #unlockList == 0
  self.uiBinder.Ref:SetVisible(self.emptyNode_, isEmpty)
  self.uiBinder.Ref:SetVisible(self.middleNode_, not isEmpty)
  self.tipsBinder_.Ref.UIComp:SetVisible(not isEmpty)
  local selectedIndex = 1
  self.itemGridView_:RefreshListView(unlockList)
  if self.curUnlockId_ then
    for index, value in ipairs(unlockList) do
      if value.Id == self.curUnlockId_ then
        selectedIndex = index
        self.curUnlockId_ = nil
        break
      end
    end
  end
  self.itemGridView_:ClearAllSelect()
  self.itemGridView_:SetSelected(selectedIndex)
  self.itemGridView_:MovePanelToItemIndex(selectedIndex)
end

function House_furniture_guide_windowView:getSortFunc()
  return self.itemSortFactoryVm_.GetItemSortFunc(E.BackPackItemPackageType.FurnitureItem, {
    equipSortType = self.equipSortTyp_,
    isAscending = self.isAscending_
  })
end

function House_furniture_guide_windowView:initUi()
  local options_ = {}
  self.commonVm_.SetLabText(self.titleLab_, E.FunctionID.HouseFurnitureGuide)
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
    self:getFurnitureItemList(self.selectedType_)
  end, true)
  self.dpd_:AddOptions(options_)
  self.materialsListView_ = loopListView.new(self, self.materialsLoopList_, materialsItem, "com_item_square_1_8")
  self.itemGridView_ = loopGridView.new(self, self.itemLoopList_, guideItem, "house_item_long")
  self.materialsListView_:Init({})
  self.itemGridView_:Init({})
  self.firstClassToggleGroup_ = toggleGroup_.new(self.firstClassTogGroup_, firstclass_item, self.houseData_.HousingItemGroupTypes, self)
  self.firstClassToggleGroup_:Init(1, function(index)
    self:getFurnitureItemList(self.houseData_.HousingItemGroupTypes[index])
  end, function()
    self:onTogStartAnimShow()
  end)
  self:getFurnitureItemList(self.houseData_.HousingItemGroupTypes[1])
end

function House_furniture_guide_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initBinders()
  self:onStartAnimShow()
  self:initData()
  self:initBtns()
  self:initUi()
  
  function self.recipesFunc_(package, dirtyKeys)
    if dirtyKeys.unlockedRecipes then
      self:getFurnitureItemList(self.selectedType_)
    end
  end
  
  Z.ContainerMgr.CharSerialize.communityHomeInfo.Watcher:RegWatcher(self.recipesFunc_)
end

function House_furniture_guide_windowView:setDpd()
end

function House_furniture_guide_windowView:loadTargetItem()
end

function House_furniture_guide_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.materialsListView_ then
    self.materialsListView_:UnInit()
    self.materialsListView_ = nil
  end
  if self.itemGridView_ then
    self.itemGridView_:UnInit()
    self.itemGridView_ = nil
  end
  self.firstClassToggleGroup_:UnInit()
  Z.ContainerMgr.CharSerialize.communityHomeInfo.Watcher:UnregWatcher(self.recipesFunc_)
end

function House_furniture_guide_windowView:OnSelected(data)
  if data == nil then
    return
  end
  if self.selectedItem_ and self.selectedItem_.Id == data.Id then
    return
  end
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", data.Id)
  if itemRow == nil then
    return
  end
  self.selectedItem_ = data
  local iconPath = self.itemsVm_.GetItemIcon(data.Id)
  if iconPath ~= "" then
    self.itemIconRImg_:SetImage(iconPath)
  end
  self.nameLab_.text = self.itemsVm_.ApplyItemNameWithQualityTag(data.Id)
  self.infoLab_.text = itemRow.Description
  self.tipsBinder_.Ref:SetVisible(self.studyImg_, false)
  self.tipsBinder_.Ref:SetVisible(self.conditionParent_, false)
  self.tipsBinder_.Ref:SetVisible(self.materialNode_, false)
  local isUnlock = false
  self.lockBntIsDisabled_ = false
  if #data.UnlockItem > 0 or 0 < #data.UnlockCondition then
    if 0 < #data.UnlockCondition then
      isUnlock = Z.ConditionHelper.CheckCondition(data.UnlockCondition)
      self.lockBntIsDisabled_ = not isUnlock
    else
      isUnlock = true
    end
    if #data.UnlockItem > 0 and isUnlock then
      isUnlock = self.houseVm_.CheckIsUnlock(data.Id)
      if not isUnlock then
        for _, value in ipairs(data.UnlockItem) do
          local totalCount = self.itemsVm_.GetItemTotalCount(value[1])
          if totalCount < value[2] then
            self.lockBntIsDisabled_ = true
            break
          end
        end
      end
    end
  else
    isUnlock = true
  end
  self.tipsBinder_.btn_lock.btn.IsDisabled = self.lockBntIsDisabled_
  self.tipsBinder_.btn_lock.Ref.UIComp:SetVisible(not isUnlock)
  if #data.UnlockItem > 0 and not isUnlock then
    self.tipsBinder_.Ref:SetVisible(self.materialNode_, true)
    self.materialsListView_:RefreshListView(data.UnlockItem)
  end
  if 0 < #data.UnlockCondition and not isUnlock then
    local itemPath = self.prefabCache_:GetString("house_learn_item_tpl")
    if itemPath == "" or itemPath == nil then
      logError("house_learn_item_tpl path is nil or empty")
      return
    end
    for name, token in pairs(self.itemTokens_) do
      Z.CancelSource.ReleaseToken(token)
    end
    self.itemTokens_ = {}
    for name, unit in pairs(self.itemUnits_) do
      self:RemoveUiUnit(name)
    end
    self.itemUnits_ = {}
    Z.CoroUtil.create_coro_call(function()
      self.tipsBinder_.Ref:SetVisible(self.conditionParent_, true)
      self.tipsBinder_.Ref:SetVisible(self.studyImg_, true)
      local descList = Z.ConditionHelper.GetConditionDescList(data.UnlockCondition)
      for index, value in ipairs(descList) do
        local itemName = "house_learn_item_tpl" .. index
        local token = self.cancelSource:CreateToken()
        self.itemTokens_[itemName] = token
        local item = self:AsyncLoadUiUnit(itemPath, itemName, self.conditionParent_.transform, token)
        if item then
          self.itemUnits_[itemName] = item
          item.lab_conditions.text = value.Desc
          item.Ref:SetVisible(item.img_finished, value.IsUnlock)
          item.Ref:SetVisible(item.img_unfinished, not value.IsUnlock)
        end
      end
    end)()
  end
end

function House_furniture_guide_windowView:onStartAnimShow()
  self.anim_do_:Restart(Z.DOTweenAnimType.Open)
end

function House_furniture_guide_windowView:OnRefresh()
end

function House_furniture_guide_windowView:onTogStartAnimShow()
  self.anim_do_:Restart(Z.DOTweenAnimType.Tween_0)
end

function House_furniture_guide_windowView:OnItemStartAnimShow()
  self.anim_do_:Restart(Z.DOTweenAnimType.Tween_1)
end

return House_furniture_guide_windowView
