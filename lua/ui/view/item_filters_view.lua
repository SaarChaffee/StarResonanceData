local UI = Z.UI
local super = require("ui.ui_subview_base")
local Item_filtersView = class("Item_filtersView", super)
local rareTypeName = Lang("Quality")
local modTypeName = Lang("ModTypeTitle")
local monsterHuntTypeName = Lang("MonsterHuntScreenInfo")
local modEffectName = Lang("ModEffectType")
local modEffectSuccessName = Lang("ModEffectSuccessType")
local MOD_DEFINE = require("ui.model.mod_define")
local resonanceSkillRarity = Lang("ResonanceSkillRarity")
local resonanceSkillType = Lang("ResonanceSkillType")

function Item_filtersView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "item_filter_tpl", "mod/item_filter_tpl", UI.ECacheLv.None)
  self.filterTypeParam_ = {
    [E.ItemQuality.White] = E.ItemQuality.White,
    [E.ItemQuality.Green] = E.ItemQuality.Green,
    [E.ItemQuality.Blue] = E.ItemQuality.Blue,
    [E.ItemQuality.Purple] = E.ItemQuality.Purple,
    [E.ItemQuality.Yellow] = E.ItemQuality.Yellow,
    [E.ItemQuality.Red] = E.ItemQuality.Red
  }
end

function Item_filtersView:OnActive()
  self:SetVisible(false)
  self.selectedTags_ = {}
  self.selectedTagsCount_ = 0
  self.allTagUnits_ = {}
  self.selectedTagUnits_ = {}
  self.allTagUnitsNames_ = {}
  self.allTagUnitsImagePaths_ = {}
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContain)
    if not isContain then
      self:onCleraSelected()
      self:onSelectedConfirm()
    end
  end, nil, nil)
  self:AddAsyncClick(self.uiBinder.btn_screen, function()
    self:onSelectedConfirm()
  end, nil, nil)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    self:onCleraSelected()
  end, nil, nil)
  self:initFilterFunc()
end

function Item_filtersView:initFilterFunc()
  self.filterFuncs_ = {}
  local index = 0
  for _, value in pairs(E.ItemFilterType) do
    index = index + 1
    self.filterFuncs_[index] = {
      value = value,
      func = Item_filtersView["loadFilterType_" .. value]
    }
  end
  table.sort(self.filterFuncs_, function(a, b)
    return a.value < b.value
  end)
end

function Item_filtersView:OnRefresh()
  self.minMode_ = false
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_filteruitems, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close, false)
  self.uiBinder.presscheck:StartCheck()
  self.parentView_ = self.viewData.parentView
  self.filterType_ = self.viewData.filterType
  self.cancelSource:CancelAll()
  self.typeParent_ = self.uiBinder.node_filteruitems
  Z.CoroUtil.create_coro_xpcall(function()
    for _, value in ipairs(self.filterFuncs_) do
      if Z.BitAND(tonumber(self.filterType_), tonumber(value.value)) > 0 and value.func then
        value.func(self, value.value)
      end
    end
    self.uiBinder.layout_filteruitems:ForceRebuildLayoutImmediate()
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
    coro(2, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
    self.uiBinder.scrollview.verticalNormalizedPosition = 1
    self:refreshSelectUnit()
    self:SetVisible(true)
    local hasSelect = false
    for key, tags in pairs(self.selectedTags_) do
      if Z.BitAND(tonumber(self.filterType_), tonumber(key)) > 0 and 0 < table.zcount(tags) then
        hasSelect = true
      end
    end
    self:SetUIVisible(self.uiBinder.btn_close, hasSelect == true)
  end)()
end

function Item_filtersView:refreshSelectUnit()
  local existFilterTags = self.viewData.existFilterTags
  if existFilterTags == nil then
    return
  end
  self.selectedTags_ = {}
  self.selectedTagsCount_ = 0
  for filterType, value in pairs(existFilterTags) do
    for tag, _ in pairs(value) do
      if self.allTagUnits_[filterType] and self.allTagUnits_[filterType][tag] then
        local name = self.allTagUnitsNames_[filterType][tag]
        local imagePath = self.allTagUnitsImagePaths_[filterType][tag]
        self:onTagsSelected(filterType, tag, name, imagePath)
      end
    end
  end
end

function Item_filtersView.loadFilterType_1(Item_filters, filterType)
  local groupTitle = Item_filters.uiBinder.prefab_cache:GetString("filter_group_unit")
  local path = Item_filters.uiBinder.prefab_cache:GetString("filter_unit")
  local itemRareContent = Item_filters:AsyncLoadUiUnit(groupTitle, "itemRareContent", Item_filters.typeParent_, Item_filters.cancelSource:CreateToken())
  itemRareContent.lab_name.text = rareTypeName
  local root = itemRareContent.content
  local name = "item_rare_"
  if Item_filters.viewData.filterTypeParam_ and Item_filters.viewData.filterTypeParam_[filterType] then
    for _, value in pairs(Item_filters.viewData.filterTypeParam_[filterType]) do
      local unit = Item_filters:AsyncLoadUiUnit(path, "itemRareUnit_" .. value, root, Item_filters.cancelSource:CreateToken())
      Item_filters:setFilterTagItemUnit(unit, filterType, value, Lang(name .. value))
    end
  else
    for i = 0, 5 do
      local unit = Item_filters:AsyncLoadUiUnit(path, "itemRareUnit_" .. i, root, Item_filters.cancelSource:CreateToken())
      Item_filters:setFilterTagItemUnit(unit, filterType, i, Lang(name .. i))
    end
  end
  itemRareContent.layout_content:ForceRebuildLayoutImmediate()
end

function Item_filtersView.loadFilterType_8(Item_filters, filterType)
  local groupTitle = Item_filters.uiBinder.prefab_cache:GetString("filter_group_unit")
  local path = Item_filters.uiBinder.prefab_cache:GetString("filter_unit")
  local modTypeContent = Item_filters:AsyncLoadUiUnit(groupTitle, "modTypeContent", Item_filters.typeParent_, Item_filters.cancelSource:CreateToken())
  modTypeContent.lab_name.text = monsterHuntTypeName
  local root = modTypeContent.content
  for _, value in pairs(Item_filters.viewData.filterTypeParam[filterType]) do
    local unit = Item_filters:AsyncLoadUiUnit(path, "itemRareUnit_" .. value, root, Item_filters.cancelSource:CreateToken())
    local table_ = Z.TableMgr.GetTable("SceneTableMgr")
    local row_ = table_.GetRow(value)
    local str_ = row_ == nil and "" or row_.Name
    Item_filters:setFilterTagItemUnit(unit, filterType, value, str_)
  end
  modTypeContent.layout_content:ForceRebuildLayoutImmediate()
end

function Item_filtersView.loadFilterType_64(Item_filters, filterType)
  local itemPath = Item_filters.uiBinder.prefab_cache:GetString("filter_group_unit")
  local itemName = "resonanceSkillRarityContent"
  local token = Item_filters.cancelSource:CreateToken()
  local resonanceSkillContent = Item_filters:AsyncLoadUiUnit(itemPath, itemName, Item_filters.typeParent_, token)
  resonanceSkillContent.lab_name.text = resonanceSkillRarity
  local subItemRoot = resonanceSkillContent.content
  local subItemPath = Item_filters.uiBinder.prefab_cache:GetString("filter_unit")
  for id, desc in pairs(Item_filters.viewData.filterTypeParam[filterType]) do
    local subItemName = "resonanceSkillRarityItem_" .. id
    local subItemToken = Item_filters.cancelSource:CreateToken()
    local subItem = Item_filters:AsyncLoadUiUnit(subItemPath, subItemName, subItemRoot, subItemToken)
    Item_filters:setFilterTagItemUnit(subItem, filterType, id, desc)
  end
  resonanceSkillContent.layout_content:ForceRebuildLayoutImmediate()
end

function Item_filtersView.loadFilterType_128(Item_filters, filterType)
  local itemPath = Item_filters.uiBinder.prefab_cache:GetString("filter_group_unit")
  local itemName = "resonanceSkillTypeContent"
  local token = Item_filters.cancelSource:CreateToken()
  local resonanceSkillContent = Item_filters:AsyncLoadUiUnit(itemPath, itemName, Item_filters.typeParent_, token)
  resonanceSkillContent.lab_name.text = resonanceSkillType
  local subItemRoot = resonanceSkillContent.content
  local subItemPath = Item_filters.uiBinder.prefab_cache:GetString("filter_unit")
  for id, desc in pairs(Item_filters.viewData.filterTypeParam[filterType]) do
    local subItemName = "resonanceSkillTypeItem_" .. id
    local subItemToken = Item_filters.cancelSource:CreateToken()
    local subItem = Item_filters:AsyncLoadUiUnit(subItemPath, subItemName, subItemRoot, subItemToken)
    Item_filters:setFilterTagItemUnit(subItem, filterType, id, desc)
  end
  resonanceSkillContent.layout_content:ForceRebuildLayoutImmediate()
end

function Item_filtersView.loadFilterType_512(Item_filters, filterType)
  local groupTitle = Item_filters.uiBinder.prefab_cache:GetString("filter_group_unit")
  local path = Item_filters.uiBinder.prefab_cache:GetString("filter_unit")
  local itemRareContent = Item_filters:AsyncLoadUiUnit(groupTitle, "profession", Item_filters.typeParent_, Item_filters.cancelSource:CreateToken())
  itemRareContent.lab_name.text = Lang("ProfessionEquip")
  local root = itemRareContent.content
  local unit = Item_filters:AsyncLoadUiUnit(path, "professionEquip", root, Item_filters.cancelSource:CreateToken())
  Item_filters:setFilterTagItemUnit(unit, filterType, 1, Lang("ProfessionEquip"))
  itemRareContent.layout_content:ForceRebuildLayoutImmediate()
end

function Item_filtersView.loadFilterType_1024(Item_filters, filterType)
  local groupTitle = Item_filters.uiBinder.prefab_cache:GetString("filter_group_unit")
  local path = Item_filters.uiBinder.prefab_cache:GetString("filter_unit")
  local itemRareContent = Item_filters:AsyncLoadUiUnit(groupTitle, "gs", Item_filters.typeParent_, Item_filters.cancelSource:CreateToken())
  itemRareContent.lab_name.text = Lang("Equipping")
  local root = itemRareContent.content
  for k, v in ipairs(Z.Global.EquipScreenGS) do
    local unit = Item_filters:AsyncLoadUiUnit(path, "gs" .. k, root, Item_filters.cancelSource:CreateToken())
    Item_filters:setFilterTagItemUnit(unit, filterType, k, Lang("ValueGSEqual", {
      val = v[3]
    }))
  end
  itemRareContent.layout_content:ForceRebuildLayoutImmediate()
end

function Item_filtersView.loadFilterType_2048(Item_filters, filterType)
  local groupTitle = Item_filters.uiBinder.prefab_cache:GetString("filter_group_unit")
  local path = Item_filters.uiBinder.prefab_cache:GetString("filter_unit")
  local itemRareContent = Item_filters:AsyncLoadUiUnit(groupTitle, "recast", Item_filters.typeParent_, Item_filters.cancelSource:CreateToken())
  itemRareContent.lab_name.text = Lang("RacastCount")
  local root = itemRareContent.content
  local count = #Z.Global.EquipScreenType
  for k, v in ipairs(Z.Global.EquipScreenType) do
    local unit = Item_filters:AsyncLoadUiUnit(path, "recast" .. k, root, Item_filters.cancelSource:CreateToken())
    local labContent = count == k and Lang("MoreThan", {
      val = v[3]
    }) or Lang("Frequencys", {
      val = v[3]
    })
    Item_filters:setFilterTagItemUnit(unit, filterType, k, labContent)
  end
  itemRareContent.layout_content:ForceRebuildLayoutImmediate()
end

function Item_filtersView.loadFilterType_4096(Item_filters, filterType)
  local groupTitle = Item_filters.uiBinder.prefab_cache:GetString("filter_group_unit")
  local path = Item_filters.uiBinder.prefab_cache:GetString("filter_unit")
  local itemRareContent = Item_filters:AsyncLoadUiUnit(groupTitle, "perfect", Item_filters.typeParent_, Item_filters.cancelSource:CreateToken())
  itemRareContent.lab_name.text = Lang("EquipPerfaceLab")
  local root = itemRareContent.content
  for k, v in ipairs(Z.Global.EquipScreenPerfectVal) do
    local unit = Item_filters:AsyncLoadUiUnit(path, "perfect" .. k, root, Item_filters.cancelSource:CreateToken())
    Item_filters:setFilterTagItemUnit(unit, filterType, k, Lang("Between", {
      val = v[3]
    }))
  end
  itemRareContent.layout_content:ForceRebuildLayoutImmediate()
end

function Item_filtersView:setFilterTagItemUnit(unit, filterType, id, filterTagName, imagePath)
  if self.allTagUnits_[filterType] == nil then
    self.allTagUnits_[filterType] = {}
  end
  if self.allTagUnitsNames_[filterType] == nil then
    self.allTagUnitsNames_[filterType] = {}
  end
  if self.allTagUnitsImagePaths_[filterType] == nil then
    self.allTagUnitsImagePaths_[filterType] = {}
  end
  self.allTagUnits_[filterType][id] = unit
  local isSelect = self.selectedTags_ ~= nil and self.selectedTags_[filterType] and self.selectedTags_[filterType][id] ~= nil
  unit.Ref:SetVisible(unit.on, isSelect)
  unit.Ref:SetVisible(unit.off, not isSelect)
  if imagePath then
    unit.Ref:SetVisible(unit.lab_on_name, false)
    unit.Ref:SetVisible(unit.lab_off_name, false)
    unit.Ref:SetVisible(unit.img_on_icon, true)
    unit.Ref:SetVisible(unit.img_off_icon, true)
    unit.img_on_icon:SetImage(imagePath)
    unit.img_off_icon:SetImage(imagePath)
  else
    unit.Ref:SetVisible(unit.lab_on_name, true)
    unit.Ref:SetVisible(unit.lab_off_name, true)
    unit.lab_on_name.text = filterTagName
    unit.lab_off_name.text = filterTagName
    unit.Ref:SetVisible(unit.img_on_icon, false)
    unit.Ref:SetVisible(unit.img_off_icon, false)
  end
  self.allTagUnitsNames_[filterType][id] = filterTagName
  self.allTagUnitsImagePaths_[filterType][id] = imagePath
  self:AddAsyncClick(unit.btn_selected, function()
    self:onTagsSelected(filterType, id, filterTagName, imagePath)
  end, nil, nil)
  local selectList = self.viewData.selectList
  if selectList and selectList[filterType] and selectList[filterType][id] then
    self:onTagsSelected(filterType, id, filterTagName, imagePath)
  end
end

function Item_filtersView:onTagsSelected(filterType, tagsId, filterTagName, imagePath)
  local isSelect = false
  if self.selectedTags_[filterType] then
    local filters = self.selectedTags_[filterType]
    if filters[tagsId] then
      filters[tagsId] = nil
      isSelect = false
      if table.zcount(self.selectedTags_[filterType]) == 0 then
        self.selectedTags_[filterType] = nil
      end
    else
      if self.viewData.selectedTags_ and self.viewData.selectedTags_[filterType] <= table.zcount(filters) then
        self.selectedTags_[filterType] = filters
        Z.TipsVM.ShowTips(1000803)
        return
      end
      filters[tagsId] = true
      isSelect = true
    end
  else
    local filters = {
      [tagsId] = true
    }
    self.selectedTags_[filterType] = filters
    isSelect = true
  end
  self.allTagUnits_[filterType][tagsId].Ref:SetVisible(self.allTagUnits_[filterType][tagsId].on, isSelect)
  self.allTagUnits_[filterType][tagsId].Ref:SetVisible(self.allTagUnits_[filterType][tagsId].off, not isSelect)
  if isSelect then
    self.selectedTagsCount_ = self.selectedTagsCount_ + 1
    self:asyncLoadSelectedTag(filterType, tagsId, filterTagName, imagePath)
  else
    self.selectedTagsCount_ = self.selectedTagsCount_ - 1
    self:removeSelectedTag(filterType, tagsId)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close, 0 < self.selectedTagsCount_)
end

function Item_filtersView:asyncLoadSelectedTag(filterType, tagsId, filterTagName, imagePath)
  if filterTagName == nil then
    return
  end
  local unitName = "selected_" .. filterTagName
  local path = self.uiBinder.prefab_cache:GetString("filter_select_unit")
  local root = self.uiBinder.content
  local unit = self:AsyncLoadUiUnit(path, unitName, root, self.cancelSource:CreateToken())
  if imagePath == nil then
    unit.Ref:SetVisible(unit.lab_name, true)
    unit.Ref:SetVisible(unit.img_icon, false)
    unit.lab_name.text = filterTagName
  else
    unit.Ref:SetVisible(unit.lab_name, false)
    unit.Ref:SetVisible(unit.img_icon, true)
    unit.img_icon:SetImage(imagePath)
  end
  if self.selectedTagUnits_[filterType] == nil then
    self.selectedTagUnits_[filterType] = {}
  end
  self.selectedTagUnits_[filterType][tagsId] = unitName
end

function Item_filtersView:removeSelectedTag(filterType, tagsId)
  if self.selectedTagUnits_ and self.selectedTagUnits_[filterType] and self.selectedTagUnits_[filterType][tagsId] then
    local name = self.selectedTagUnits_[filterType][tagsId]
    self:RemoveUiUnit(name)
  end
end

function Item_filtersView:onSelectedConfirm()
  self.uiBinder.presscheck:StopCheck()
  self:closeAllItemUi()
  Z.EventMgr:Dispatch(Z.ConstValue.ItemFilterConfirm, self.selectedTags_)
  self:closeOrHide()
end

function Item_filtersView:closeAllItemUi()
  for _, value in pairs(self.allTagUnits_) do
    for _, unit in pairs(value) do
      self:RemoveUiUnit(unit.Name)
    end
  end
  self.allTagUnits_ = {}
end

function Item_filtersView:onCleraSelected()
  if self.minMode_ then
    self.selectedTags_ = {}
    self.selectedTagsCount_ = 0
    Z.EventMgr:Dispatch(Z.ConstValue.ItemFilterConfirm, self.selectedTags_)
    self:DeActive()
    return
  end
  for key, value in pairs(self.selectedTags_) do
    for tag, _ in pairs(value) do
      self:onTagsSelected(key, tag, "")
    end
  end
  self.selectedTags_ = {}
  self.selectedTagsCount_ = 0
end

function Item_filtersView:closeOrHide()
  if table.zcount(self.selectedTags_) > 0 then
    local isHaveSelect = false
    for _, tag in pairs(self.selectedTags_) do
      for _, v in pairs(tag) do
        if v then
          isHaveSelect = true
          break
        end
      end
    end
    if isHaveSelect then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_filteruitems, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn, false)
      self.minMode_ = true
      self.uiBinder.layout_filteruitems:ForceRebuildLayoutImmediate()
    else
      self:DeActive()
    end
  else
    self:DeActive()
  end
end

function Item_filtersView:OnDeActive()
  self:closeAllItemUi()
  self.minMode_ = false
  self.parentView_ = nil
  self.selectedTags_ = nil
  self.selectedTagsCount_ = 0
  self.allTagUnits_ = nil
  self.selectedTagUnits_ = nil
end

return Item_filtersView
