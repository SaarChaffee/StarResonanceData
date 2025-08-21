local UI = Z.UI
local super = require("ui.ui_view_base")
local Mod_mainView = class("Mod_mainView", super)
local MOD_DEFINE = require("ui.model.mod_define")
local loop_list_view = require("ui.component.loop_list_view")
local modEntryListTplItem = require("ui.component.mod.mod_entry_list_tpl_item")
local modListGeneralSituationTplItem = require("ui.component.mod.mod_list_general_situation_tpl_item")
local modListEntryDetailTplItem = require("ui.component.mod.mod_list_entry_detail_tpl_item")
local modItemTplItem = require("ui.component.mod.mod_item_tpl_item")
local common_filter_helper = require("common.common_filter_helper")
local UIShowLinkAttrCount = 4

function Mod_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "mod_main")
  self.modData_ = Z.DataMgr.Get("mod_data")
  self.modVM_ = Z.VMMgr.GetVM("mod")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.filterHelper_ = common_filter_helper.new(self)
end

function Mod_mainView:OnActive()
  Z.AudioMgr:Play("UI_Event_CharacterAttributes_Module")
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:AddClick(self.uiBinder.btn_ask, function()
    self.helpsysVM_.OpenFullScreenTipsView(400003)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.modData_.ModFilter = {}
    self.modData_:SetIntensifyModUuid(nil)
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_filter, function()
    local viewData = {
      filterRes = self.modData_.ModFilter,
      closeFunc = function()
        self.uiBinder.mod_info.Ref.UIComp:SetVisible(true)
        self.commonVM_.CommonDotweenPlay(self.uiBinder.dotween_anim, Z.DOTweenAnimType.Open, nil)
      end
    }
    self.filterHelper_:ActiveFilterSub(viewData)
    self.uiBinder.mod_info.Ref.UIComp:SetVisible(false)
    self:clearAttrShowEffect()
    self.commonVM_.CommonDotweenPlay(self.uiBinder.dotween_anim, Z.DOTweenAnimType.Tween_0, nil)
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
            self.modData_.ModFilter = filterRes
            self:setLoopList()
          end,
          closeFunc = function()
            self.uiBinder.mod_info.Ref.UIComp:SetVisible(true)
            self.commonVM_.CommonDotweenPlay(self.uiBinder.dotween_anim, Z.DOTweenAnimType.Open, nil)
          end
        }
        self.filterHelper_:ActiveFilterSub(viewData)
        self.uiBinder.mod_info.Ref.UIComp:SetVisible(false)
        self:clearAttrShowEffect()
        self.commonVM_.CommonDotweenPlay(self.uiBinder.dotween_anim, Z.DOTweenAnimType.Tween_0, nil)
      end
    }
    Z.UIMgr:OpenView("mod_term_recommend_popup", popViewData)
  end)
  self:AddClick(self.uiBinder.mod_info.btn_tips, function()
    local text = Lang("ModMainTips")
    Z.CommonTipsVM.ShowTipsContent(self.uiBinder.mod_info.rect_tips, text)
  end)
  for i = 1, MOD_DEFINE.ModSlotMaxCount do
    local tempUIBinder = self.uiBinder["mod_item_tpl_" .. i]
    self:AddClick(tempUIBinder.btn, function()
      local isUnlock = self.modVM_.CheckSlotIsUnlock(i, true)
      if isUnlock then
        self:SetSlotId(i)
      end
    end)
  end
  self.uiBinder.mod_info.tog_left:RemoveAllListeners()
  self.uiBinder.mod_info.tog_right:RemoveAllListeners()
  self.uiBinder.mod_info.tog_left.isOn = true
  self.uiBinder.mod_info.tog_left:AddListener(function()
    self.modEffectsShowIsOverview_ = true
    self:changeEffectShowOverview()
  end, true)
  self.uiBinder.mod_info.tog_right:AddListener(function()
    self.modEffectsShowIsOverview_ = false
    self:changeEffectShowOverview()
  end, true)
  self:AddAsyncClick(self.uiBinder.mod_info.btn_link_module, function()
    self.gotoFuncVM_.TraceOrSwitchFunc(E.FunctionID.ModTrace, false, MOD_DEFINE.ModIntensifyType.Intensify, self.selectModUuid_)
  end)
  self:AddAsyncClick(self.uiBinder.mod_info.btn_disboard.btn, function()
    local isEquip, slot = self.modVM_.IsModEquip(self.selectModUuid_)
    if isEquip then
      Z.AudioMgr:Play("UI_Event_Module_Remove")
      if slot == self.selectSlotId_ then
        self.modVM_.AsyncUninstallMod(self.selectSlotId_, self.cancelSource:CreateToken())
      else
        self.modVM_.AsyncEquipMod(self.selectModUuid_, self.selectSlotId_, self.cancelSource:CreateToken())
      end
    else
      Z.AudioMgr:Play("UI_Event_Module_Wear")
      self.modVM_.AsyncEquipMod(self.selectModUuid_, self.selectSlotId_, self.cancelSource:CreateToken())
    end
  end)
  self:AddAsyncClick(self.uiBinder.mod_info.btn_getmod.btn, function()
    self.modVM_.OpenModSearchTips(self.uiBinder.mod_info.btn_getmod.Trans)
  end)
  if Z.IsPCUI then
    self.itemListView_ = loop_list_view.new(self, self.uiBinder.loop_item, modEntryListTplItem, "mod_entry_list_tpl_pc")
    self.effectLeftListView_ = loop_list_view.new(self, self.uiBinder.mod_info.loop_item_left, modListGeneralSituationTplItem, "mod_list_general_situation_tpl_pc")
    self.effectRightListView_ = loop_list_view.new(self, self.uiBinder.mod_info.loop_item_right, modListEntryDetailTplItem, "mod_list_entry_details_tpl_pc")
  else
    self.itemListView_ = loop_list_view.new(self, self.uiBinder.loop_item, modEntryListTplItem, "mod_entry_list_tpl")
    self.effectLeftListView_ = loop_list_view.new(self, self.uiBinder.mod_info.loop_item_left, modListGeneralSituationTplItem, "mod_list_general_situation_tpl")
    self.effectRightListView_ = loop_list_view.new(self, self.uiBinder.mod_info.loop_item_right, modListEntryDetailTplItem, "mod_list_entry_details_tpl")
  end
  self.itemListView_:Init({})
  self.effectLeftListView_:Init({})
  self.effectRightListView_:Init({})
  local filterTypes = {
    E.CommonFilterType.ModType,
    E.CommonFilterType.ModQuality,
    E.CommonFilterType.ModEffectSelect
  }
  self.filterHelper_:Init(Lang("ModFilterTitle"), filterTypes, self.uiBinder.node_filter, self.uiBinder.node_filter_s, function(filterRes)
    self.modData_.ModFilter = filterRes
    self:setLoopList()
  end)
  self.filterHelper_:ActiveEliminateSub(self.modData_.ModFilter)
  self.uiBinder.mod_info.Ref.UIComp:SetVisible(true)
  for i = 1, MOD_DEFINE.ModSlotMaxCount do
    local tempUIBinder = self.uiBinder["mod_item_tpl_" .. i]
    self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(tempUIBinder.node_effect_equip)
    tempUIBinder.node_effect:SetEffectGoVisible(false)
    tempUIBinder.node_effect_equip:SetEffectGoVisible(false)
  end
  self.equipModItemClass_ = {}
  self.redNodeIds_ = {}
  self.playerModel_ = nil
  self.effectShowAttrs_ = {
    attr = {},
    isFirst = true
  }
  self.effectUnits_ = {}
  self.isUp_ = true
  self.modelQuaternion_ = Quaternion.Euler(Vector3.New(0, 180, 0))
  self.modelPos_ = Z.UnrealSceneMgr:GetTransPos("pos")
  self.isInPreviewSelectUuid_ = 0
  self.selectModUuid_ = 0
  self.selectSlotId_ = 1
  self.redMods_ = {}
  self.modEffectsShowIsOverview_ = true
  self.IsShowModEffectUIEffect = false
  self.ShowModEffectUIEffectId = nil
  if self.viewData and self.viewData.modSlotId then
    self.selectSlotId_ = self.viewData.modSlotId
  end
  self:showModel()
  self.commonVM_.CommonPlayAnim(self.uiBinder.anim, "anim_mod_main_open", self.cancelSource:CreateToken(), function()
  end)
  self:refreshEquipModState(false, true)
  self:refreshEquipMods()
  self:setLoopList()
  local selectModUuid = self.modData_:GetIntensifyModUuid()
  if selectModUuid and selectModUuid ~= 0 then
    if self.viewData and self.viewData.showModEffectId then
      self.IsShowModEffectUIEffect = true
      self.ShowModEffectUIEffectId = self.viewData.showModEffectId
    end
    self:SetSelectUuid(selectModUuid, true)
  end
  Z.EventMgr:Add(Z.ConstValue.Mod.OnModInstall, self.modInstallRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.Mod.OnModUnInstall, self.modUnInstallRefresh, self)
end

function Mod_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.EventMgr:Remove(Z.ConstValue.Mod.OnModInstall, self.modInstallRefresh, self)
  Z.EventMgr:Remove(Z.ConstValue.Mod.OnModUnInstall, self.modUnInstallRefresh, self)
  for _, equipModItemClass in pairs(self.equipModItemClass_) do
    equipModItemClass:UnInit()
  end
  self.equipModItemClass_ = {}
  for _, nodeId in pairs(self.redNodeIds_) do
    Z.RedPointMgr.RemoveChildNodeData(E.RedType.ModTab, nodeId)
  end
  self.redNodeIds_ = {}
  for i = 1, MOD_DEFINE.ModSlotMaxCount do
    local tempUIBinder = self.uiBinder["mod_item_tpl_" .. i]
    self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(tempUIBinder.node_effect_equip)
  end
  self:clearAttrShowEffect()
  self.effectShowAttrs_ = {
    attr = {},
    isFirst = true
  }
  if self.playerModel_ then
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
    self.playerModel_ = nil
  end
  Z.CommonTipsVM.CloseTipsContent()
  if Z.UIMgr:IsActive("mod_item_popup") then
    Z.UIMgr:CloseView("mod_item_popup")
  end
  if Z.UIMgr:IsActive("tips_approach") then
    Z.UIMgr:CloseView("tips_approach")
  end
  self.itemListView_:UnInit()
  self.itemListView_ = nil
  self.effectLeftListView_:UnInit()
  self.effectLeftListView_ = nil
  self.effectRightListView_:UnInit()
  self.effectRightListView_ = nil
  self.filterHelper_:DeActive()
  self.isUp_ = true
  self.isInPreviewSelectUuid_ = 0
  self.selectModUuid_ = 0
  self.selectSlotId_ = 1
  self.redMods_ = {}
  self.modEffectsShowIsOverview_ = true
  self.IsShowModEffectUIEffect = false
  self.ShowModEffectUIEffectId = nil
end

function Mod_mainView:OnRefresh()
end

function Mod_mainView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Mod_mainView:GetCacheData()
  return {
    modSlotId = self.selectSlotId_
  }
end

function Mod_mainView:OnInputBack()
  self.modData_.ModFilter = {}
  self.modData_:SetIntensifyModUuid(nil)
  super.OnInputBack(self)
end

function Mod_mainView:showModel()
  Z.CoroUtil.create_coro_xpcall(function()
    self.playerModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
      model:SetAttrGoPosition(self.modelPos_)
      model:SetAttrGoRotation(self.modelQuaternion_)
      model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
      model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
      model:SetLuaAnimBase(Z.AnimBaseData.Rent(Panda.ZAnim.EAnimBase.EIdle))
    end)
  end)()
end

function Mod_mainView:SetSlotId(slotId)
  if self.selectSlotId_ == slotId then
    return
  end
  self.selectSlotId_ = slotId
  self:refreshModInfo()
  self:refreshEquipModState(false, true)
  self:setLoopList()
  self:refreshModBtns()
end

function Mod_mainView:SetSelectUuid(uuid, notShowDotween)
  if uuid then
    local equipUuid = self.modVM_.GetSlotEquipModUuid(self.selectSlotId_)
    local isEquip, slotId = self.modVM_.IsModEquip(uuid)
    if equipUuid and equipUuid == uuid or isEquip then
      self.isInPreviewSelectUuid_ = 0
    else
      self.isInPreviewSelectUuid_ = uuid
    end
    self.selectModUuid_ = uuid
  else
    self.isInPreviewSelectUuid_ = 0
    self.selectModUuid_ = 0
  end
  self:refreshModInfo()
  self:refreshEquipModState(false, false)
  self:refreshLoopItems()
  self:refreshModBtns()
  if notShowDotween == nil or not notShowDotween then
    self.commonVM_.CommonDotweenPlay(self.uiBinder.dotween_anim, Z.DOTweenAnimType.Open, nil)
  end
end

function Mod_mainView:modInstallRefresh()
  self.isInPreviewSelectUuid_ = 0
  self:refreshEquipModState(true, false)
  self:refreshEquipMods()
  self:setLoopList()
  self:refreshModInfo()
  self:refreshModBtns()
end

function Mod_mainView:modUnInstallRefresh()
  self.isInPreviewSelectUuid_ = self.selectModUuid_
  self:refreshEquipModState(false, false)
  self:refreshEquipMods()
  self:setLoopList()
  self:refreshModInfo()
  self:refreshModBtns()
end

function Mod_mainView:clearAttrShowEffect()
  for _, effect in ipairs(self.effectUnits_) do
    self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(effect)
    effect:ReleseEffGo()
  end
  self.effectUnits_ = {}
end

function Mod_mainView:refreshModInfo()
  local allSuccessTimes = self.modVM_.GetAllEquipSuccessTimes()
  self:clearAttrShowEffect()
  local curModLinkEffectConfig = self.modData_:GetModLinkEffectConfig(allSuccessTimes)
  local attrPath = self.uiBinder.mod_info.uiprefab_cache:GetString("attr")
  if self.isInPreviewSelectUuid_ ~= 0 then
    local previewSuccessTimes = self.modVM_.GetPreviewEquipSuccessTimes(self.selectSlotId_, self.isInPreviewSelectUuid_)
    self.uiBinder.mod_info.lab_lv.text = previewSuccessTimes
    if allSuccessTimes < previewSuccessTimes then
      self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.img_arrow_up, true)
      self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.img_arrow_down, false)
    elseif allSuccessTimes == previewSuccessTimes then
      self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.img_arrow_up, false)
      self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.img_arrow_down, false)
    else
      self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.img_arrow_up, false)
      self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.img_arrow_down, true)
    end
    local previewModLinkEffectConfig = self.modData_:GetModLinkEffectConfig(previewSuccessTimes)
    local mergeAttrs = self.modData_:MergeModLinkEffectConfigAttr(curModLinkEffectConfig, previewModLinkEffectConfig)
    for i = 1, UIShowLinkAttrCount do
      local unit = self.uiBinder.mod_info["mod_attr_tpl_" .. i]
      if unit then
        if mergeAttrs[i] then
          self:refreshAttrUnit(unit, mergeAttrs[i].attrId, mergeAttrs[i].curValue, mergeAttrs[i].nextValue, true)
        else
          self:refreshAttrUnit(unit)
        end
      end
    end
    self.effectShowAttrs_ = {
      attr = {},
      isFirst = false
    }
    for i = 1, UIShowLinkAttrCount do
      self.effectShowAttrs_.attr[mergeAttrs[i].attrId] = mergeAttrs[i].curValue
    end
  else
    self.uiBinder.mod_info.lab_lv.text = allSuccessTimes
    self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.img_arrow_up, false)
    self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.img_arrow_down, false)
    local modLinkEffectNextLevelConfig = self.modData_:GetModLinkEffectNextLevelConfig(allSuccessTimes)
    local mergeAttrs = self.modData_:MergeModLinkEffectConfigAttr(curModLinkEffectConfig, modLinkEffectNextLevelConfig)
    for i = 1, UIShowLinkAttrCount do
      local unit = self.uiBinder.mod_info["mod_attr_tpl_" .. i]
      if unit then
        if mergeAttrs[i] then
          self:refreshAttrUnit(unit, mergeAttrs[i].attrId, mergeAttrs[i].curValue, mergeAttrs[i].nextValue, false)
        else
          self:refreshAttrUnit(unit)
        end
      end
    end
    self.effectShowAttrs_ = {
      attr = {},
      isFirst = false
    }
    for i = 1, UIShowLinkAttrCount do
      self.effectShowAttrs_.attr[mergeAttrs[i].attrId] = mergeAttrs[i].curValue
    end
  end
  self:refreshEffectLoopInfo()
end

function Mod_mainView:refreshEquipMods(slotId)
  if slotId then
    if self.equipModItemClass_[slotId] then
      self.equipModItemClass_[slotId]:UnInit()
    end
  else
    for _, equipModItemClass in pairs(self.equipModItemClass_) do
      equipModItemClass:UnInit()
    end
    for i = 1, MOD_DEFINE.ModSlotMaxCount do
      local tempItemClass = modItemTplItem.RefreshTpl(self.uiBinder["mod_item_tpl_" .. i], i, self.equipModItemClass_[i], self)
      if tempItemClass then
        self.equipModItemClass_[i] = tempItemClass
      end
    end
  end
end

function Mod_mainView:refreshEquipModState(showEquipSlotEffect, changeSelectSlotEffect)
  for i = 1, MOD_DEFINE.ModSlotMaxCount do
    local tempUIBinder = self.uiBinder["mod_item_tpl_" .. i]
    local isRed, mods = self.modVM_.IsHaveRedDot(i)
    if isRed then
      self.redMods_[i] = mods
    else
      self.redMods_[i] = {}
    end
    tempUIBinder.node_red_eff:SetEffectGoVisible(isRed)
    tempUIBinder.Ref:SetVisible(tempUIBinder.curslot_effect, i == self.selectSlotId_)
    if changeSelectSlotEffect then
      tempUIBinder.node_effect:SetEffectGoVisible(self.selectSlotId_ == i)
    end
    if showEquipSlotEffect then
      tempUIBinder.node_effect_equip:SetEffectGoVisible(self.selectSlotId_ == i)
    else
      tempUIBinder.node_effect_equip:SetEffectGoVisible(false)
    end
  end
end

function Mod_mainView:setLoopList()
  self.modItems_ = {}
  local sortType = E.EquipItemSortType.Quality
  local sortFunc = self.itemSortFactoryVm_.GetItemSortFunc(E.BackPackItemPackageType.Mod, {
    sortType = sortType,
    slot = self.selectSlotId_,
    isUp = self.isUp_
  })
  self.modItems_ = self.itemsVM_.GetItemIds(E.BackPackItemPackageType.Mod, nil, sortFunc, true)
  self.modLoopItems_ = {}
  local modLoopItemsCount = 0
  if #self.modItems_ > 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rect_item_empty, false)
    local equipUuid = 0
    local selectExit = false
    local firstUnEquipUuid = 0
    for _, item in pairs(self.modItems_) do
      local isRed = false
      if self.redMods_[self.selectSlotId_] and self.redMods_[self.selectSlotId_][item.itemUuid] then
        isRed = true
        local nodeId = E.RedType.ModTab .. item.itemUuid
        Z.RedPointMgr.AddChildNodeData(E.RedType.ModTab, E.RedType.ModTab, nodeId)
        Z.RedPointMgr.UpdateNodeCount(nodeId, 1)
        self.redNodeIds_[nodeId] = nodeId
      end
      local byFiltering = true
      local tempFilterRes = {}
      local modConfig = Z.TableMgr.GetTable("ModTableMgr").GetRow(item.configId)
      local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(item.configId)
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
          local itemInfo = self.itemsVM_.GetItemInfo(item.itemUuid, E.BackPackItemPackageType.Mod)
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
      local tempIsEquip, tempSlotId = self.modVM_.IsModEquip(item.itemUuid)
      if byFiltering or tempIsEquip then
        modLoopItemsCount = modLoopItemsCount + 1
        if tempIsEquip and tempSlotId == self.selectSlotId_ then
          equipUuid = item.itemUuid
        end
        if not tempIsEquip and firstUnEquipUuid == 0 then
          firstUnEquipUuid = item.itemUuid
        end
        if item.itemUuid == self.selectModUuid_ then
          selectExit = true
        end
        self.modLoopItems_[modLoopItemsCount] = {
          configId = item.configId,
          uuid = item.itemUuid,
          isSelected = false,
          isRed = isRed,
          curSlot = self.selectSlotId_
        }
      end
    end
    if self.selectModUuid_ == 0 then
      if equipUuid == 0 then
        if firstUnEquipUuid == 0 then
          if self.modLoopItems_[1] ~= nil then
            self:SetSelectUuid(self.modLoopItems_[1].uuid, false)
          else
            self:SetSelectUuid(nil, false)
          end
        else
          self:SetSelectUuid(firstUnEquipUuid, false)
        end
      else
        self:SetSelectUuid(equipUuid, false)
      end
    elseif selectExit then
      self:refreshLoopItems()
    elseif self.modLoopItems_[1] then
      self:SetSelectUuid(self.modLoopItems_[1].uuid, false)
    else
      self:SetSelectUuid(nil, false)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rect_item_empty, true)
    self:SetSelectUuid(nil, false)
  end
end

function Mod_mainView:refreshLoopItems()
  for _, item in ipairs(self.modLoopItems_) do
    item.isSelected = self.selectModUuid_ == item.uuid
    item.curSlot = self.selectSlotId_
  end
  self.itemListView_:RefreshListView(self.modLoopItems_)
end

function Mod_mainView:refreshAttrUnit(uibinder, id, num1, num2, isPreview)
  if id == nil then
    uibinder.Ref:SetVisible(uibinder.img_empty, true)
    uibinder.Ref:SetVisible(uibinder.img_bottom, false)
  else
    uibinder.Ref:SetVisible(uibinder.img_empty, false)
    uibinder.Ref:SetVisible(uibinder.img_bottom, true)
    local fightAttrData = self.fightAttrParseVm_.GetFightAttrTableRow(id)
    if fightAttrData then
      uibinder.lab_name.text = fightAttrData.OfficialName
    end
    if isPreview then
      local str1 = self.fightAttrParseVm_.ParseFightAttrNumber(id, num1, true)
      uibinder.lab_num1.text = str1
      local str2 = self.fightAttrParseVm_.ParseFightAttrNumber(id, num2, true)
      uibinder.lab_num2.text = str2
      if num1 < num2 then
        uibinder.Ref:SetVisible(uibinder.img_arrow_up, true)
        uibinder.Ref:SetVisible(uibinder.img_arrow_down, false)
        uibinder.Ref:SetVisible(uibinder.img_arrow, true)
        uibinder.Ref:SetVisible(uibinder.lab_num1, true)
      elseif num1 == num2 then
        uibinder.Ref:SetVisible(uibinder.img_arrow_up, false)
        uibinder.Ref:SetVisible(uibinder.img_arrow_down, false)
        uibinder.Ref:SetVisible(uibinder.img_arrow, false)
        uibinder.Ref:SetVisible(uibinder.lab_num1, false)
      else
        uibinder.Ref:SetVisible(uibinder.img_arrow_up, false)
        uibinder.Ref:SetVisible(uibinder.img_arrow_down, true)
        uibinder.Ref:SetVisible(uibinder.img_arrow, true)
        uibinder.Ref:SetVisible(uibinder.lab_num1, true)
      end
    else
      local str1 = self.fightAttrParseVm_.ParseFightAttrNumber(id, num1, true)
      uibinder.lab_num2.text = str1
      uibinder.Ref:SetVisible(uibinder.img_arrow_up, false)
      uibinder.Ref:SetVisible(uibinder.img_arrow_down, false)
      uibinder.Ref:SetVisible(uibinder.img_arrow, false)
      uibinder.Ref:SetVisible(uibinder.lab_num1, false)
    end
    if not self.effectShowAttrs_.isFirst then
      if self.effectShowAttrs_.attr[id] == nil then
        uibinder.node_effect:CreatEFFGO(MOD_DEFINE.ModMainViewAttrEffect[1], Vector3.zero)
        uibinder.node_effect:SetEffectGoVisible(true)
        self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(uibinder.node_effect)
        table.insert(self.effectUnits_, uibinder.node_effect)
      elseif num1 > self.effectShowAttrs_.attr[id] then
        uibinder.node_effect:CreatEFFGO(MOD_DEFINE.ModMainViewAttrEffect[1], Vector3.zero)
        uibinder.node_effect:SetEffectGoVisible(true)
        self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(uibinder.node_effect)
        table.insert(self.effectUnits_, uibinder.node_effect)
      elseif num1 < self.effectShowAttrs_.attr[id] then
        uibinder.node_effect:CreatEFFGO(MOD_DEFINE.ModMainViewAttrEffect[2], Vector3.zero)
        uibinder.node_effect:SetEffectGoVisible(true)
        self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(uibinder.node_effect)
        table.insert(self.effectUnits_, uibinder.node_effect)
      end
    end
  end
end

function Mod_mainView:refreshEffectLoopInfo()
  local equipUuids = {}
  local modList = Z.ContainerMgr.CharSerialize.mod
  if modList and modList.modSlots then
    for pos, uuid in pairs(modList.modSlots) do
      equipUuids[pos] = uuid
    end
  end
  local curSelectModEffect = self.modVM_.GetModEffectIdAndSuccessTimes(self.selectModUuid_)
  local hashCurSelectModEffect = {}
  for _, value in ipairs(curSelectModEffect) do
    hashCurSelectModEffect[value.id] = value.successTimes
  end
  local equipModEffects = self.modVM_.GetEquipModEffectAndLevel(equipUuids)
  local effectList = {}
  local effectListCount = 0
  if self.isInPreviewSelectUuid_ ~= 0 then
    equipUuids[self.selectSlotId_] = self.isInPreviewSelectUuid_
    local preEquipModEffects = self.modVM_.GetEquipModEffectAndLevel(equipUuids)
    local mergeModEffects = self.modVM_.MergeEquipModEffectAndLevel(equipModEffects, preEquipModEffects)
    for _, value in ipairs(mergeModEffects) do
      effectListCount = effectListCount + 1
      effectList[effectListCount] = {
        id = value.id,
        curValue = value.curValue,
        nextValue = value.nextValue,
        isSelect = hashCurSelectModEffect[value.id] ~= nil
      }
    end
  else
    for _, value in ipairs(equipModEffects) do
      effectListCount = effectListCount + 1
      effectList[effectListCount] = {
        id = value.id,
        curValue = value.successTimes,
        isSelect = hashCurSelectModEffect[value.id] ~= nil
      }
    end
  end
  self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.loop_item_left, self.modEffectsShowIsOverview_)
  self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.loop_item_right, not self.modEffectsShowIsOverview_)
  if effectListCount == 0 then
    self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.rimg_empty, true)
    self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.togs, false)
    self.effectLeftListView_:RefreshListView({})
    self.effectRightListView_:RefreshListView({})
  else
    self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.rimg_empty, false)
    self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.togs, true)
    table.sort(effectList, function(a, b)
      if a.curValue == b.curValue then
        return a.id < b.id
      else
        return a.curValue > b.curValue
      end
    end)
    self.effectLeftListView_:RefreshListView(effectList, true)
    self.effectRightListView_:RefreshListView(effectList, true)
    if not self.IsShowModEffectUIEffect then
      self.ShowModEffectUIEffectId = nil
    end
    if self.IsShowModEffectUIEffect then
      self.IsShowModEffectUIEffect = false
    end
  end
end

function Mod_mainView:changeEffectShowOverview()
  self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.loop_item_left, self.modEffectsShowIsOverview_)
  self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.loop_item_right, not self.modEffectsShowIsOverview_)
end

function Mod_mainView:refreshModBtns()
  if self.selectModUuid_ == 0 then
    self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.btn_link_module, false)
    self.uiBinder.mod_info.btn_disboard.Ref.UIComp:SetVisible(false)
    if 0 < #self.modItems_ then
      self.uiBinder.mod_info.btn_getmod.Ref.UIComp:SetVisible(false)
    else
      self.uiBinder.mod_info.btn_getmod.Ref.UIComp:SetVisible(true)
    end
  else
    local isFuncCanShow = self.gotoFuncVM_.CheckFuncCanUse(E.FunctionID.ModTrace, true)
    self.uiBinder.mod_info.Ref:SetVisible(self.uiBinder.mod_info.btn_link_module, isFuncCanShow)
    self.uiBinder.mod_info.btn_disboard.Ref.UIComp:SetVisible(true)
    self.uiBinder.mod_info.btn_getmod.Ref.UIComp:SetVisible(false)
    local isEquip, slot = self.modVM_.IsModEquip(self.selectModUuid_)
    if isEquip then
      if slot == self.selectSlotId_ then
        self.uiBinder.mod_info.btn_disboard.lab_normal.text = Lang("Remove")
      else
        self.uiBinder.mod_info.btn_disboard.lab_normal.text = Lang("Replace")
      end
    else
      local uuid = self.modVM_.GetSlotEquipModUuid(self.selectSlotId_)
      if uuid then
        self.uiBinder.mod_info.btn_disboard.lab_normal.text = Lang("Replace")
      else
        self.uiBinder.mod_info.btn_disboard.lab_normal.text = Lang("Assemble")
      end
    end
  end
end

return Mod_mainView
