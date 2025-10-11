local UI = Z.UI
local super = require("ui.ui_view_base")
local mod_intensify_window_view = class("mod_intensify_window_view", super)
local MOD_DEFINE = require("ui.model.mod_define")
local modCardAllTplItem = require("ui.component.mod.mod_card_all_tpl_item")
local loopListView_ = require("ui/component/loop_list_view")
local loopGridView_ = require("ui/component/loop_grid_view")
local modItemLongItem = require("ui.component.mod.mod_item_long_item")
local modEntryListTplItem = require("ui.component.mod.mod_entry_list_tpl_item")
local common_filter_helper = require("common.common_filter_helper")

function mod_intensify_window_view:ctor()
  self.uiBinder = nil
  super.ctor(self, "mod_intensify_window")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.modData_ = Z.DataMgr.Get("mod_data")
  self.modVM_ = Z.VMMgr.GetVM("mod")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.itemClass_ = {}
  self.filterHelper_ = common_filter_helper.new(self)
end

function mod_intensify_window_view:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:AddClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(400003)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("mod_intensify_window")
  end)
  self:AddClick(self.uiBinder.btn_preview, function()
    self.modVM_.EnterModView()
  end)
  self:AddClick(self.uiBinder.btn_cancel, function()
    self:clearSelectItem()
    self:refreshModLoops()
    self:refreshModListLoopByFilter()
    self:refreshDecompose()
  end)
  self:AddClick(self.uiBinder.btn_filter, function()
    local viewData = {
      filterRes = self.modData_.ModFilter
    }
    self.filterHelper_:ActiveFilterSub(viewData)
  end)
  self:AddClick(self.uiBinder.btn_recommend, function()
    local popViewData = {
      func = function(data)
        self.modData_.ModFilter[E.CommonFilterType.ModEffectSelect] = self.filterHelper_.filterSubView_.initFilterTypeData_3()
        for _, value in pairs(data) do
          self.modData_.ModFilter[E.CommonFilterType.ModEffectSelect].value[value] = value
          self.modData_.ModFilter[E.CommonFilterType.ModEffectSelect].param[2][value] = value
        end
        local viewData = {
          filterRes = self.modData_.ModFilter,
          filterFunc = function(filterRes)
            self:onSelectFilter(filterRes)
          end
        }
        self.filterHelper_:ActiveFilterSub(viewData)
      end
    }
    Z.UIMgr:OpenView("mod_term_recommend_popup", popViewData)
  end)
  self:AddAsyncClick(self.uiBinder.btn_confirm, function()
    self:confirmDecompose()
  end)
  self:AddAsyncClick(self.uiBinder.btn_oneclick_addition, function()
    self:selectAllBlueMod()
  end)
  self.uiBinder.group_tab_item_1.tog_tab_select:AddListener(function(isOn)
    if isOn then
      self:selectIntensityType(MOD_DEFINE.ModIntensifyType.Intensify, self.viewData.uuid)
    end
  end)
  self.uiBinder.group_tab_item_2.tog_tab_select:AddListener(function(isOn)
    if isOn then
      self:selectIntensityType(MOD_DEFINE.ModIntensifyType.Decompose)
    end
  end)
  if Z.IsPCUI then
    self.itemListView_ = loopListView_.new(self, self.uiBinder.loop_item, modEntryListTplItem, "mod_entry_list_tpl_pc")
  else
    self.itemListView_ = loopListView_.new(self, self.uiBinder.loop_item, modEntryListTplItem, "mod_entry_list_tpl")
  end
  self.itemListView_:Init({})
  if Z.IsPCUI then
    self.itemsModDecomposeGridView_ = loopGridView_.new(self, self.uiBinder.loop_decompose_mod, modItemLongItem, "com_item_long_2_pc")
  else
    self.itemsModDecomposeGridView_ = loopGridView_.new(self, self.uiBinder.loop_decompose_mod, modItemLongItem, "com_item_long_2")
  end
  self.itemsModDecomposeGridView_:Init({})
  if Z.IsPCUI then
    self.itemsDecomposeListView_ = loopListView_.new(self, self.uiBinder.loop_decompose_item, modItemLongItem, "com_item_square_8_pc")
  else
    self.itemsDecomposeListView_ = loopListView_.new(self, self.uiBinder.loop_decompose_item, modItemLongItem, "com_item_square_8")
  end
  self.itemsDecomposeListView_:Init({})
  local filterTypes = {
    E.CommonFilterType.ModType,
    E.CommonFilterType.ModQuality,
    E.CommonFilterType.ModEffectSelect
  }
  self.filterHelper_:Init(Lang("ModFilterTitle"), filterTypes, self.uiBinder.node_filter, self.uiBinder.node_filter_s, function(filterRes)
    self:onSelectFilter(filterRes)
  end)
  self.filterHelper_:ActiveEliminateSub(self.modData_.ModFilter)
  self.isUp_ = true
  self.isInIntensify_ = false
  self.filterTags_ = true
  self.IntensifyEffectId = nil
  self.IntensifyEffects = {}
  Z.EventMgr:Add(Z.ConstValue.Mod.OnModIntensify, self.refreshModIntensify, self)
  Z.EventMgr:Add(Z.ConstValue.Mod.OnModDecompose, self.refreshModDecompose, self)
end

function mod_intensify_window_view:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.Mod.OnModIntensify, self.refreshModIntensify, self)
  Z.EventMgr:Remove(Z.ConstValue.Mod.OnModDecompose, self.refreshModDecompose, self)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.itemListView_:UnInit()
  self.itemListView_ = nil
  self.itemsModDecomposeGridView_:UnInit()
  self.itemsModDecomposeGridView_ = nil
  self.itemsDecomposeListView_:UnInit()
  self.itemsDecomposeListView_ = nil
  for _, itemClass in pairs(self.itemClass_) do
    itemClass:UnInit()
  end
  self.itemClass_ = {}
  self.intensityType_ = nil
  self.filterHelper_:DeActive()
  self.filterTags_ = true
  Z.CommonTipsVM.CloseTipsContent()
  if Z.UIMgr:IsActive("mod_item_popup") then
    Z.UIMgr:CloseView("mod_item_popup")
  end
  self:closeSourceTip()
  self.IntensifyEffectId = nil
  self:clearIntensifyEffects()
end

function mod_intensify_window_view:OnRefresh()
  local intensifyIsOn = self.gotoFuncVM_.CheckFuncCanUse(E.FunctionID.ModIntensify, true)
  local decomposeIsOn = self.gotoFuncVM_.CheckFuncCanUse(E.FunctionID.ModDecompose, true)
  self.uiBinder.group_tab_item_1.Ref.UIComp:SetVisible(intensifyIsOn)
  self.uiBinder.group_tab_item_2.Ref.UIComp:SetVisible(decomposeIsOn)
  local intensifyType
  if self.viewData and self.viewData.intensifyType then
    if MOD_DEFINE.ModIntensifyType.Intensify == self.viewData.intensifyType then
      if intensifyIsOn then
        intensifyType = MOD_DEFINE.ModIntensifyType.Intensify
      else
        intensifyType = MOD_DEFINE.ModIntensifyType.Decompose
      end
    elseif MOD_DEFINE.ModIntensifyType.Decompose == self.viewData.intensifyType then
      if decomposeIsOn then
        intensifyType = MOD_DEFINE.ModIntensifyType.Decompose
      else
        intensifyType = MOD_DEFINE.ModIntensifyType.Intensify
      end
    end
  end
  if intensifyType then
    if intensifyType == MOD_DEFINE.ModIntensifyType.Intensify then
      if self.uiBinder.group_tab_item_1.tog_tab_select.isOn then
        self:selectIntensityType(MOD_DEFINE.ModIntensifyType.Intensify, self.viewData.uuid)
      else
        self.uiBinder.group_tab_item_1.tog_tab_select.isOn = true
      end
    elseif intensifyType == MOD_DEFINE.ModIntensifyType.Decompose then
      if self.uiBinder.group_tab_item_2.tog_tab_select.isOn then
        self:selectIntensityType(MOD_DEFINE.ModIntensifyType.Decompose, self.viewData.uuid)
      else
        self.uiBinder.group_tab_item_2.tog_tab_select.isOn = true
      end
    end
  elseif self.uiBinder.group_tab_item_1.tog_tab_select.isOn then
    self:selectIntensityType(MOD_DEFINE.ModIntensifyType.Intensify)
  elseif self.uiBinder.group_tab_item_2.tog_tab_select.isOn then
    self:selectIntensityType(MOD_DEFINE.ModIntensifyType.Decompose)
  end
end

function mod_intensify_window_view:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function mod_intensify_window_view:refreshModIntensify(effectId)
  self:refreshModLoops()
  self:refreshModListLoopByFilter()
  self:refreshIntensify(effectId)
end

function mod_intensify_window_view:refreshModDecompose()
  self:clearSelectItem()
  self:refreshModLoops()
  self:refreshModListLoopByFilter()
  self:refreshDecompose()
end

function mod_intensify_window_view:refreshModLoops()
  local modConfigMgr = Z.TableMgr.GetTable("ModTableMgr")
  local sortType = E.EquipItemSortType.Quality
  local sortFunc = self.itemSortFactoryVm_.GetItemSortFunc(E.BackPackItemPackageType.Mod, {
    sortType = sortType,
    1,
    isUp = self.isUp_
  })
  self.modItems_ = self.itemsVM_.GetItemIds(E.BackPackItemPackageType.Mod, nil, sortFunc, true)
  if #self.modItems_ > 0 then
    if self.intensityType_ == MOD_DEFINE.ModIntensifyType.Intensify and self.selectUuids_[1] == nil then
      self.selectUuids_[1] = self.modItems_[1].itemUuid
    end
    self.modLoopItems_ = {}
    local awardIndex = 0
    for _, itemInfo in pairs(self.modItems_) do
      local isSelect = false
      local isShow = false
      if self.intensityType_ == MOD_DEFINE.ModIntensifyType.Decompose then
        if self.selectUuids_[itemInfo.itemUuid] then
          isSelect = true
        end
        isShow = true
      else
        local modConfig = modConfigMgr.GetRow(itemInfo.configId)
        if modConfig and modConfig.IsCanLink then
          isShow = true
        end
      end
      if isShow then
        awardIndex = awardIndex + 1
        self.modLoopItems_[awardIndex] = {
          configId = itemInfo.configId,
          uuid = itemInfo.itemUuid,
          isSelected = isSelect
        }
      end
    end
    self.itemListView_:RefreshListView(self.modLoopItems_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
  else
    self.selectUuids_ = {}
    self.modLoopItems_ = {}
    self.itemListView_:RefreshListView({})
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, self.intensityType_ == MOD_DEFINE.ModIntensifyType.Intensify)
  end
end

function mod_intensify_window_view:selectIntensityType(type, uuid)
  if self.intensityType_ == type then
    return
  end
  self.intensityType_ = type
  self:clearSelectItem()
  if uuid then
    self.selectUuids_[1] = uuid
    self.viewData.uuid = nil
  end
  if self.intensityType_ == MOD_DEFINE.ModIntensifyType.Intensify then
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_card, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_decompose, false)
    self.commonVM_.CommonPlayTogAnim(self.uiBinder.group_tab_item_1.anim_tog, self.cancelSource:CreateToken())
    self:refreshModLoops()
    self:refreshModListLoopByFilter()
    self:refreshIntensify()
    self.uiBinder.lab_empty_name.text = Lang("Mod_None_Reinforced_Tips")
    local commonVM = Z.VMMgr.GetVM("common")
    commonVM.SetLabText(self.uiBinder.lab_title, E.FunctionID.ModIntensify)
  elseif self.intensityType_ == MOD_DEFINE.ModIntensifyType.Decompose then
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_card, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_decompose, true)
    self.commonVM_.CommonPlayTogAnim(self.uiBinder.group_tab_item_2.anim_tog, self.cancelSource:CreateToken())
    self:refreshModLoops()
    self:refreshModListLoopByFilter()
    self:refreshDecompose()
    self.uiBinder.lab_empty_name.text = Lang("NoDecomposableItems")
    local commonVM = Z.VMMgr.GetVM("common")
    commonVM.SetLabText(self.uiBinder.lab_title, E.FunctionID.ModDecompose)
  end
  self.uiBinder.anim:Play(Z.DOTweenAnimType.Open)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function mod_intensify_window_view:clearSelectItem()
  self.selectUuids_ = {}
end

function mod_intensify_window_view:clearIntensifyEffects()
  for _, effect in ipairs(self.IntensifyEffects) do
    self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(effect)
    effect:ReleseEffGo()
  end
  self.IntensifyEffects = {}
end

function mod_intensify_window_view:refreshIntensify(effectId)
  self.IntensifyEffectId = effectId
  self:clearIntensifyEffects()
  for _, itemClass in pairs(self.itemClass_) do
    itemClass:UnInit()
  end
  self.itemClass_ = {}
  self.uiBinder.Ref:SetVisible(self.uiBinder.rect_bottom, false)
  self.uiBinder.lab_mod_intensifytitle.text = ""
  if self.selectUuids_[1] then
    self.modData_:SetIntensifyModUuid(self.selectUuids_[1])
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_card, true)
    local unitPath = self.uiBinder.prefab_cash:GetString("mod_card_all_tpl")
    self.uiBinder.Ref:SetVisible(self.uiBinder.rect_bottom, true)
    local itemInfo = self.itemsVM_.GetItemInfo(self.selectUuids_[1], E.BackPackItemPackageType.Mod)
    local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemInfo.configId)
    if itemConfig then
      self.uiBinder.lab_mod_intensifytitle.text = self.itemsVM_.ApplyItemNameWithQualityTag(itemInfo.configId)
    end
    if itemInfo and itemInfo.modNewAttr then
      local allIntensify = true
      for i = 1, MOD_DEFINE.ModEffectMaxCount do
        local unit = self.uiBinder["mod_card_all_tpl_" .. i]
        local attr = itemInfo.modNewAttr.modParts[i]
        if attr then
          local logs = {}
          local logsIndex = 0
          if Z.ContainerMgr.CharSerialize.mod and Z.ContainerMgr.CharSerialize.mod.modInfos and Z.ContainerMgr.CharSerialize.mod.modInfos[self.selectUuids_[1]] then
            local modInfo = Z.ContainerMgr.CharSerialize.mod.modInfos[self.selectUuids_[1]]
            for _, upgrade in ipairs(modInfo.upgradeRecords) do
              if upgrade.partId == attr then
                logsIndex = logsIndex + 1
                logs[logsIndex] = upgrade.isSuccess
              end
            end
          end
          if unit then
            local itemClass, tempIntensify = modCardAllTplItem.RefreshTpl(unit, attr, logs, self.selectUuids_[1], self, false)
            table.insert(self.itemClass_, itemClass)
            allIntensify = allIntensify and tempIntensify
          end
        elseif unit then
          modCardAllTplItem.RefreshTpl(unit, nil, nil, nil, nil, true)
        end
      end
    end
  else
    self.modData_:SetIntensifyModUuid(nil)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_card, false)
  end
end

function mod_intensify_window_view:refreshDecompose()
  self.modData_:SetIntensifyModUuid(nil)
  local selectUuids = {}
  local index = 1
  for _, uuid in pairs(self.selectUuids_) do
    local itemInfo = self.itemsVM_.GetItemInfo(uuid, E.BackPackItemPackageType.Mod)
    selectUuids[index] = {
      type = modItemLongItem.Type.ModResolve,
      uuid = uuid,
      configId = itemInfo.configId
    }
    index = index + 1
  end
  self.itemsModDecomposeGridView_:RefreshListView(selectUuids)
  local awards = {}
  local awardIndex = 0
  local decomposeItem = self.modVM_.GetModDecompose(selectUuids)
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  for _, item in pairs(decomposeItem) do
    awardIndex = awardIndex + 1
    local labType, lab = awardPreviewVm.GetPreviewShowNum(item)
    awards[awardIndex] = {
      type = modItemLongItem.Type.DecomposeItem,
      configId = item.awardId,
      isSelected = false,
      prevDropType = item.PrevDropType,
      count = item.awardNum,
      labType = labType,
      lab = item.PrevDropType == E.AwardPrevDropType.Probability and "" or lab
    }
  end
  self.itemsDecomposeListView_:RefreshListView(awards)
  if 1 < index then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_decompose, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_decompose, true)
    if 0 < #self.modLoopItems_ then
      self.uiBinder.lab_empty_decompose.text = Lang("PleaseSelectItemWantDecomposeItemLeft")
    else
      self.uiBinder.lab_empty_decompose.text = Lang("NoDecomposableItems")
    end
  end
  self.uiBinder.btn_cancel.IsDisabled = index == 1
  self.uiBinder.btn_confirm.IsDisabled = index == 1
end

function mod_intensify_window_view:SetSelectUuid(uuid)
  if self.intensityType_ == MOD_DEFINE.ModIntensifyType.Intensify then
    self.selectUuids_[1] = uuid
    self:refreshModLoops()
    self:refreshModListLoopByFilter()
    self:refreshIntensify()
  else
    if self.modVM_.IsModEquip(uuid) then
      Z.TipsVM.ShowTipsLang(1042107)
      return
    end
    if self.selectUuids_[uuid] then
      self.selectUuids_[uuid] = nil
    elseif table.zcount(self.selectUuids_) >= Z.Global.ModDecomposeLimit then
      Z.TipsVM.ShowTipsLang(150044)
    else
      self.selectUuids_[uuid] = uuid
    end
    self:refreshModLoops()
    self:refreshModListLoopByFilter()
    self:refreshDecompose()
  end
end

function mod_intensify_window_view:selectAllBlueMod()
  local tempCount = table.zcount(self.selectUuids_)
  if tempCount >= Z.Global.ModDecomposeLimit then
    Z.TipsVM.ShowTipsLang(150045)
  end
  local mgr = Z.TableMgr.GetTable("ItemTableMgr")
  for _, item in ipairs(self.modLoopItems_) do
    local itemConfig = mgr.GetRow(item.configId)
    if itemConfig.Quality == E.ItemQuality.Blue and not self.modVM_.IsModEquip(item.uuid) then
      self.selectUuids_[item.uuid] = item.uuid
      tempCount = tempCount + 1
      if tempCount >= Z.Global.ModDecomposeLimit then
        break
      end
    end
  end
  if tempCount == 0 then
    Z.TipsVM.ShowTipsLang(1042114)
  else
    self:refreshModLoops()
    self:refreshModListLoopByFilter()
    self:refreshDecompose()
  end
end

function mod_intensify_window_view:onSelectFilter(filterRes)
  self.modData_.ModFilter = filterRes
  self.filterTags_ = true
  self:refreshModListLoopByFilter()
end

function mod_intensify_window_view:refreshModListLoopByFilter()
  if self.filterTags_ then
    local selectNeedReset = false
    if self.intensityType_ == MOD_DEFINE.ModIntensifyType.Intensify then
      selectNeedReset = true
    end
    local tempmodLoopItems = {}
    local tempmodLoopItemsIndex = 0
    for _, item in ipairs(self.modLoopItems_) do
      local modConfig = Z.TableMgr.GetTable("ModTableMgr").GetRow(item.configId)
      local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(item.configId)
      local byFiltering = true
      local tempFilterRes = {}
      local effectValueCount = 0
      if self.modData_.ModFilter[E.CommonFilterType.ModEffectSelect] and self.modData_.ModFilter[E.CommonFilterType.ModEffectSelect].value then
        effectValueCount = table.zcount(self.modData_.ModFilter[E.CommonFilterType.ModEffectSelect].value)
      end
      for type, data in pairs(self.modData_.ModFilter) do
        tempFilterRes[type] = true
        if type == E.CommonFilterType.ModType then
          tempFilterRes[type] = false
          if data.value[modConfig.ModType] then
            tempFilterRes[type] = true
          end
        end
        if type == E.CommonFilterType.ModQuality then
          tempFilterRes[type] = false
          if data.value[itemConfig.Quality] then
            tempFilterRes[type] = true
          end
        end
        if type == E.CommonFilterType.ModEffectSelect and 0 < effectValueCount then
          local itemInfo = self.itemsVM_.GetItemInfo(item.uuid, E.BackPackItemPackageType.Mod)
          tempFilterRes[type] = false
          local needCount = 1
          if data.param and data.param[1] then
            needCount = data.param[1]
          end
          local tempCount = 0
          for _, attr in ipairs(itemInfo.modNewAttr.modParts) do
            if data.value[attr] then
              tempCount = tempCount + 1
            end
          end
          tempFilterRes[type] = needCount <= tempCount
        end
      end
      for _, res in pairs(tempFilterRes) do
        byFiltering = byFiltering and res
      end
      if byFiltering then
        tempmodLoopItemsIndex = tempmodLoopItemsIndex + 1
        tempmodLoopItems[tempmodLoopItemsIndex] = item
        if selectNeedReset and item.uuid == self.selectUuids_[1] then
          selectNeedReset = false
        end
      end
    end
    if selectNeedReset then
      if tempmodLoopItems[1] and tempmodLoopItems[1].uuid then
        self.selectUuids_[1] = tempmodLoopItems[1].uuid
        for _, item in ipairs(tempmodLoopItems) do
          item.isSelected = self.selectUuids_[1] == item.uuid
        end
      else
        self.selectUuids_ = {}
      end
      self:refreshIntensify()
    elseif self.intensityType_ == MOD_DEFINE.ModIntensifyType.Intensify then
      for _, item in ipairs(tempmodLoopItems) do
        item.isSelected = self.selectUuids_[1] == item.uuid
      end
    elseif self.intensityType_ == MOD_DEFINE.ModIntensifyType.Decompose then
      for _, item in ipairs(tempmodLoopItems) do
        item.isSelected = self.selectUuids_[item.uuid] ~= nil
      end
    end
    self.itemListView_:RefreshListView(tempmodLoopItems)
  else
    if self.intensityType_ == MOD_DEFINE.ModIntensifyType.Intensify then
      for _, item in ipairs(self.modLoopItems_) do
        item.isSelected = self.selectUuids_[1] == item.uuid
      end
    end
    self.itemListView_:RefreshListView(self.modLoopItems_)
  end
end

function mod_intensify_window_view:confirmDecompose()
  local highQualityMod = false
  local uuids = {}
  local count = 1
  for _, uuid in pairs(self.selectUuids_) do
    uuids[count] = uuid
    count = count + 1
    local modInfo = self.itemsVM_.GetItemInfo(uuid, E.BackPackItemPackageType.Mod)
    local modConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(modInfo.configId)
    if modConfig.Quality >= E.ItemQuality.Purple then
      highQualityMod = true
    end
  end
  if #uuids == 0 then
    return
  end
  local hightQualityCertainFunc = function()
    local confirmFunc = function()
      self.modVM_.AsyncDecomposeMods(uuids, self.cancelSource:CreateToken())
    end
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("ModDecomposeCertain"), confirmFunc, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.ModDecomposeCertain)
  end
  if highQualityMod then
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("ModDecomposeHighQualityCertain"), function()
      hightQualityCertainFunc()
    end)
  else
    hightQualityCertainFunc()
  end
end

function mod_intensify_window_view:closeSourceTip()
  if self.sourceTipId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
    self.sourceTipId_ = nil
  end
end

function mod_intensify_window_view:openNotEnoughItemTips(itemId, rect)
  self:closeSourceTip()
  self.sourceTipId_ = Z.TipsVM.OpenSourceTips(itemId, rect)
end

return mod_intensify_window_view
