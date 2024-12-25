local UI = Z.UI
local super = require("ui.ui_view_base")
local mod_fantasy_window_view = class("mod_fantasy_window_view", super)
local MOD_DEFINE = require("ui.model.mod_define")
local TalentSkillDefine = require("ui.model.talent_skill_define")
local ModItemCardTplItem = require("ui.component.mod.mod_item_card_tpl_item")
local ModFabtassyTplItem = require("ui.component.mod.mod_fabtassy_tpl_item")
local loopListView_ = require("ui/component/loop_list_view")
local itemFilter = require("ui.view.item_filters_view")

function mod_fantasy_window_view:ctor()
  self.uiBinder = nil
  super.ctor(self, "mod_fantasy_window")
  self.modData_ = Z.DataMgr.Get("mod_data")
  self.modVM_ = Z.VMMgr.GetVM("mod")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.itemFilter_ = itemFilter.new(self)
  self.isShowOn_ = false
end

function mod_fantasy_window_view:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:AddClick(self.uiBinder.btn_ask, function()
    self.helpsysVM_.OpenFullScreenTipsView(400003)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("mod_fantasy_window")
  end)
  self:AddClick(self.uiBinder.btn_filter, function()
    self:openItemFilter()
  end)
  self.slotEffects_ = {}
  local slotModInfo = {}
  if Z.ContainerMgr.CharSerialize.mod and Z.ContainerMgr.CharSerialize.mod.modSlots then
    slotModInfo = Z.ContainerMgr.CharSerialize.mod.modSlots
  end
  for i = 1, MOD_DEFINE.ModSlotMaxCount do
    local unitUIBinder = self.uiBinder.node_mod["node_mod_item_card_tpl" .. i]
    local modUuid = slotModInfo[i]
    local modId
    if modUuid then
      local itemInfo = self.itemsVM_.GetItemInfo(modUuid, E.BackPackItemPackageType.Mod)
      if itemInfo then
        modId = itemInfo.configId
      end
      self.slotEffects_[i] = {}
      local tempRes = self.modVM_.GetModEffectIdAndSuccessTimes(modUuid)
      for _, res in ipairs(tempRes) do
        self.slotEffects_[i][res.id] = res.successTimes
      end
    end
    local isUnLock, level = self.modVM_.CheckSlotIsUnlock(i)
    ModItemCardTplItem.RefreshTpl(unitUIBinder, modId, isUnLock, i, level)
    self:AddAsyncClick(unitUIBinder.img_bg, function()
      self.modVM_.EnterModView(i)
    end)
  end
  self:AddAsyncClick(self.uiBinder.node_mod.btn_view_details, function()
  end)
  self:AddAsyncClick(self.uiBinder.btn_preview, function()
    self.modVM_.EnterModPreviewView()
  end)
  self.isShowOn_ = false
  self.isOnEffects_ = {}
  local index = 0
  for _, slotInfo in pairs(self.slotEffects_) do
    for effectId, successTime in pairs(slotInfo) do
      if self.isOnEffects_[effectId] == nil then
        self.isOnEffects_[effectId] = 0
      end
      self.isOnEffects_[effectId] = self.isOnEffects_[effectId] + successTime
      index = index + 1
    end
  end
  local allEffectConfigs = self.modData_:GetAllEffectList()
  self.modEffectListData_ = {}
  local tempModEffectListIndex = 0
  for effectId, _ in pairs(allEffectConfigs) do
    tempModEffectListIndex = tempModEffectListIndex + 1
    if self.isOnEffects_[effectId] ~= nil then
      self.modEffectListData_[tempModEffectListIndex] = {
        effectId = effectId,
        successTimes = self.isOnEffects_[effectId],
        isOnEffect = true
      }
    else
      self.modEffectListData_[tempModEffectListIndex] = {
        effectId = effectId,
        successTimes = 0,
        isOnEffect = false
      }
    end
  end
  table.sort(self.modEffectListData_, function(a, b)
    local aState = self.isOnEffects_[a.effectId] ~= nil and 0 or 1
    local bState = self.isOnEffects_[b.effectId] ~= nil and 0 or 1
    if aState == bState then
      if a.successTimes == b.successTimes then
        return a.effectId < b.effectId
      else
        return a.successTimes > b.successTimes
      end
    else
      return aState < bState
    end
  end)
  self.uiBinder.tog_show:AddListener(function(isOn)
    self.isShowOn_ = isOn
    self:refreshEffectList()
  end)
  self.isShowOn_ = false
  self.uiBinder.tog_show:SetIsOnWithoutCallBack(false)
  self.list_ = loopListView_.new(self, self.uiBinder.looplist_item, ModFabtassyTplItem, "mod_fabtassy_tpl")
  self.list_:Init(self.modEffectListData_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_verti, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
  self.uiBinder.anim:Play(Z.DOTweenAnimType.Open)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  Z.EventMgr:Add(Z.ConstValue.ItemFilterConfirm, self.onSelectFilter, self)
end

function mod_fantasy_window_view:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.ItemFilterConfirm, self.onSelectFilter, self)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.CommonTipsVM.CloseTipsContent()
  if self.itemFilter_ then
    self.itemFilter_:DeActive()
  end
  if self.list_ then
    self.list_:UnInit()
    self.list_ = nil
  end
  if Z.UIMgr:IsActive("mod_item_popup") then
    Z.UIMgr:CloseView("mod_item_popup")
  end
end

function mod_fantasy_window_view:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function mod_fantasy_window_view:OnRefresh()
end

function mod_fantasy_window_view:openItemFilter()
  local viewData = {
    parentView = self,
    filterType = E.ItemFilterType.ModEffectType + E.ItemFilterType.ModSuccessTimes,
    existFilterTags = self.filterTgas_
  }
  self.itemFilter_:Active(viewData, self.uiBinder.node_filter_pos)
end

function mod_fantasy_window_view:onSelectFilter(filterTgas)
  if table.zcount(filterTgas) < 1 then
    self.filterTgas_ = nil
  end
  self.filterTgas_ = filterTgas
  self:refreshEffectList()
end

function mod_fantasy_window_view:refreshEffectList()
  if self.filterTgas_ then
    local tempmodLoopItems = {}
    local tempmodLoopItemsIndex = 0
    for _, item in ipairs(self.modEffectListData_) do
      local isAccord1 = true
      if self.filterTgas_[E.ItemFilterType.ModEffectType] and next(self.filterTgas_[E.ItemFilterType.ModEffectType]) then
        isAccord1 = false
        for key, tga in pairs(self.filterTgas_[E.ItemFilterType.ModEffectType]) do
          local attrConfig = self.modData_:GetEffectTableConfig(item.effectId, 0)
          if attrConfig.EffectType == key and tga then
            isAccord1 = true
            break
          end
        end
      end
      local isAccord2 = true
      if self.filterTgas_[E.ItemFilterType.ModSuccessTimes] and next(self.filterTgas_[E.ItemFilterType.ModSuccessTimes]) then
        isAccord2 = false
        for key, tga in pairs(self.filterTgas_[E.ItemFilterType.ModSuccessTimes]) do
          if tga then
            local successTimestable = Z.Global.ModFilterCriteria[key]
            if tonumber(successTimestable[2]) <= item.successTimes and item.successTimes <= tonumber(successTimestable[3]) then
              isAccord2 = true
              break
            end
          end
        end
      end
      local isAccord3 = self.isShowOn_ == false or self.isShowOn_ == true and self.isOnEffects_[item.effectId] ~= nil
      if isAccord1 and isAccord2 and isAccord3 then
        tempmodLoopItemsIndex = tempmodLoopItemsIndex + 1
        tempmodLoopItems[tempmodLoopItemsIndex] = item
      end
    end
    self.list_:RefreshListView(tempmodLoopItems)
  else
    local tempmodLoopItems = {}
    local tempmodLoopItemsIndex = 0
    for _, item in ipairs(self.modEffectListData_) do
      local isAccord3 = self.isShowOn_ == false or self.isShowOn_ == true and self.isOnEffects_[item.effectId] ~= nil
      if isAccord3 then
        tempmodLoopItemsIndex = tempmodLoopItemsIndex + 1
        tempmodLoopItems[tempmodLoopItemsIndex] = item
      end
    end
    self.list_:RefreshListView(tempmodLoopItems)
  end
end

return mod_fantasy_window_view
