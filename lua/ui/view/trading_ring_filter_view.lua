local UI = Z.UI
local super = require("ui.ui_subview_base")
local Trading_ring_filtersView = class("Trading_ring_filtersView", super)

function Trading_ring_filtersView:ctor(parent)
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
  self.stallFilterDatas_ = Z.TableMgr.GetTable("StallFitterMgr"):GetDatas()
end

function Trading_ring_filtersView:OnActive()
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

function Trading_ring_filtersView:initFilterFunc()
  self.filterFuncs_ = {}
  for index, row in ipairs(self.stallFilterDatas_) do
    self.filterFuncs_[index] = {
      Id = row.Id,
      func = Trading_ring_filtersView["loadFilterType_" .. row.Id]
    }
  end
  table.sort(self.filterFuncs_, function(a, b)
    return a.Id < b.Id
  end)
end

function Trading_ring_filtersView:OnRefresh()
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
    for _, value in ipairs(self.filterType_) do
      self:commonLoadFilterType(value)
    end
    self.uiBinder.layout_filteruitems:ForceRebuildLayoutImmediate()
    self:refreshSelectUnit()
    self:SetVisible(true)
    local hasSelect = false
    for key, tags in pairs(self.selectedTags_) do
      if table.zcontains(self.filterType_, key) then
        hasSelect = true
      end
    end
    self:SetUIVisible(self.uiBinder.btn_close, hasSelect == true)
  end)()
end

function Trading_ring_filtersView:refreshSelectUnit()
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

function Trading_ring_filtersView:commonLoadFilterType(filterType)
  local stallFilterRow_ = Z.TableMgr.GetTable("StallFitterMgr").GetRow(filterType)
  local groupTitle = self.uiBinder.prefab_cache:GetString("filter_group_unit")
  local path = self.uiBinder.prefab_cache:GetString("filter_unit")
  local filterContent = self:AsyncLoadUiUnit(groupTitle, "filter_root_" .. filterType, self.typeParent_, self.cancelSource:CreateToken())
  filterContent.lab_name.text = stallFilterRow_.FitterName
  local root = filterContent.content
  local ChoiceIDs = string.split(stallFilterRow_.ChoiceID, "=")
  local ChoiceNames = string.split(stallFilterRow_.ChoiceName, "=")
  for index, value in pairs(ChoiceIDs) do
    local unit = self:AsyncLoadUiUnit(path, "filter_" .. filterType .. "_unit_" .. index, root, self.cancelSource:CreateToken())
    self:setFilterTagItemUnit(unit, filterType, tonumber(value), ChoiceNames[index])
  end
  filterContent.layout_content:ForceRebuildLayoutImmediate()
end

function Trading_ring_filtersView:setFilterTagItemUnit(unit, filterType, id, filterTagName, imagePath)
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

function Trading_ring_filtersView:onTagsSelected(filterType, tagsId, filterTagName, imagePath)
  local isSelect = false
  if self.selectedTags_[filterType] then
    local filters = self.selectedTags_[filterType]
    if filters[tagsId] then
      filters[tagsId] = nil
      isSelect = false
    else
      local stallFilterRow_ = Z.TableMgr.GetTable("StallFitterMgr").GetRow(filterType)
      local maxSelectCount = 1
      if not stallFilterRow_ and stallFilterRow_.MutiplyChoice == 1 then
        maxSelectCount = stallFilterRow_.MutiplyNumber
        return
      end
      if maxSelectCount <= table.zcount(filters) then
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
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close, self.selectedTagsCount_ > 0)
end

function Trading_ring_filtersView:asyncLoadSelectedTag(filterType, tagsId, filterTagName, imagePath)
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

function Trading_ring_filtersView:removeSelectedTag(filterType, tagsId)
  local name = self.selectedTagUnits_[filterType][tagsId]
  if name then
    self:RemoveUiUnit(name)
  end
end

function Trading_ring_filtersView:onSelectedConfirm()
  self.uiBinder.presscheck:StopCheck()
  self:closeAllItemUi()
  Z.EventMgr:Dispatch(Z.ConstValue.ItemFilterConfirm, self.selectedTags_)
  self:closeOrHide()
end

function Trading_ring_filtersView:closeAllItemUi()
  for _, value in pairs(self.allTagUnits_) do
    for _, unit in pairs(value) do
      self:RemoveUiUnit(unit.Name)
    end
  end
  self.allTagUnits_ = {}
end

function Trading_ring_filtersView:onCleraSelected()
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

function Trading_ring_filtersView:closeOrHide()
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

function Trading_ring_filtersView:OnDeActive()
  self:closeAllItemUi()
  self.minMode_ = false
  self.parentView_ = nil
  self.selectedTags_ = nil
  self.selectedTagsCount_ = 0
  self.allTagUnits_ = nil
  self.selectedTagUnits_ = nil
end

return Trading_ring_filtersView
