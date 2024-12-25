local UI = Z.UI
local super = require("ui.ui_subview_base")
local Common_filter_subView = class("Common_filter_subView", super)
local MOD_DEFINE = require("ui.model.mod_define")
local modGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")

function Common_filter_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "common_filter_sub", "common_filter/common_filter_sub", UI.ECacheLv.None)
  self.helper_ = parent
  self.filter_1 = {
    MOD_DEFINE.ModType.Attack,
    MOD_DEFINE.ModType.Assistant,
    MOD_DEFINE.ModType.Defend
  }
  self.filter_2 = {
    E.ItemQuality.Blue,
    E.ItemQuality.Purple,
    E.ItemQuality.Yellow
  }
end

function Common_filter_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.lab_mod_screen.text = self.viewData.title
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    if self.viewData and self.viewData.closeFunc then
      self.viewData.closeFunc()
    else
      self:DeActive()
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_certain, function()
    self:certainFunc()
  end)
  self:AddClick(self.uiBinder.btn_clear, function()
    if self.viewData and self.viewData.clearFunc then
      self.viewData.clearFunc()
    else
      self:ClearFilter(true)
    end
  end)
  self.filterRes_ = {}
  if self.viewData.filterRes then
    for key, value in pairs(self.viewData.filterRes) do
      self.filterRes_[key] = {
        param = value.param,
        value = value.value
      }
    end
  end
  self.units_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    if self.viewData.filterTypes then
      for _, type in ipairs(self.viewData.filterTypes) do
        local func = Common_filter_subView["createFilterType_" .. type]
        func(self, self.filterRes_[type])
      end
    end
  end)()
end

function Common_filter_subView:OnDeActive()
  for _, unit in pairs(self.units_) do
    self:RemoveUiUnit(unit.name)
    for _, child in pairs(unit.children) do
      self:RemoveUiUnit(child.name)
    end
  end
end

function Common_filter_subView:OnRefresh()
end

function Common_filter_subView:ClearFilter(isNeedRefreshUI)
  if self.filterRes_ == nil then
    self.filterRes_ = {}
  end
  for type, _ in pairs(self.filterRes_) do
    self.filterRes_[type] = Common_filter_subView["initFilterTypeData_" .. type](self)
  end
  if isNeedRefreshUI then
    self:refreshFilterUnits()
    self:certainFunc()
  end
end

function Common_filter_subView:certainFunc()
  local tempRes = {}
  for type, data in pairs(self.filterRes_) do
    local count = 0
    for _, v in pairs(data.value) do
      count = count + 1
    end
    for _, v in pairs(data.param) do
      count = count + 1
    end
    if 0 < count then
      tempRes[type] = data
    end
  end
  if self.viewData.filterFunc then
    self.viewData.filterFunc(tempRes)
  end
end

function Common_filter_subView:refreshFilterUnits()
  Z.CoroUtil.create_coro_xpcall(function()
    for type, _ in pairs(self.units_) do
      self:refreshFilterUnitsByType(type)
    end
  end)()
end

function Common_filter_subView:refreshFilterUnitsByType(type)
  local data = self.filterRes_[type]
  if data == nil then
    data = {
      param = {},
      value = {}
    }
  end
  if self.units_[type] then
    if type == self.helper_.FilterType.ModEffectSelect then
      for _, child in pairs(self.units_[self.helper_.FilterType.ModEffectSelect].children) do
        self:RemoveUiUnit(child.name)
      end
      self.units_[self.helper_.FilterType.ModEffectSelect].children = {}
      local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
      coro(1, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
      self.uiBinder.rebuilder_content:ForceRebuildLayoutImmediate()
    else
      for key, child in pairs(self.units_[type].children) do
        local isOn = false
        if data.value and data.value[key] then
          isOn = true
        end
        child.unit.toggle:SetIsOnWithoutCallBack(isOn)
      end
    end
  end
end

function Common_filter_subView:initFilterTypeData_1()
  return {
    param = {},
    value = {}
  }
end

function Common_filter_subView:createFilterType_1()
  if self.filterRes_[self.helper_.FilterType.ModType] == nil then
    self.filterRes_[self.helper_.FilterType.ModType] = self:initFilterTypeData_1()
  end
  local path = self.uiBinder.uiprefab_cache:GetString("type_1")
  local filterType = self:AsyncLoadUiUnit(path, "filter_1", self.uiBinder.node_content, self.cancelSource:CreateToken())
  if filterType then
    self.units_[self.helper_.FilterType.ModType] = {
      unit = filterType,
      name = "filter_1",
      children = {}
    }
    filterType.lab_type.text = Lang("ByType")
    local unitPath = filterType.uiprefab_cache:GetString("item")
    for _, value in ipairs(self.filter_1) do
      local name = "filter_1_" .. value
      local unit = self:AsyncLoadUiUnit(unitPath, name, filterType.node_item, self.cancelSource:CreateToken())
      if unit then
        unit.lab_title.text = Lang("ModType_" .. value)
        unit.toggle:RemoveAllListeners()
        unit.toggle.isOn = self.filterRes_[self.helper_.FilterType.ModType].value[value] ~= nil and self.filterRes_[self.helper_.FilterType.ModType].value[value] or false
        unit.toggle:AddListener(function(isOn)
          if isOn then
            self.filterRes_[self.helper_.FilterType.ModType].value[value] = true
          else
            self.filterRes_[self.helper_.FilterType.ModType].value[value] = nil
          end
        end, true)
        self.units_[self.helper_.FilterType.ModType].children[value] = {unit = unit, name = name}
      end
    end
  end
end

function Common_filter_subView:initFilterTypeData_2()
  return {
    param = {},
    value = {}
  }
end

function Common_filter_subView:createFilterType_2()
  if self.filterRes_[self.helper_.FilterType.ModQuality] == nil then
    self.filterRes_[self.helper_.FilterType.ModQuality] = self:initFilterTypeData_2()
  end
  local path = self.uiBinder.uiprefab_cache:GetString("type_1")
  local filterType = self:AsyncLoadUiUnit(path, "filter_2", self.uiBinder.node_content, self.cancelSource:CreateToken())
  if filterType then
    self.units_[self.helper_.FilterType.ModQuality] = {
      unit = filterType,
      children = {}
    }
    filterType.lab_type.text = Lang("ByQuality")
    local unitPath = filterType.uiprefab_cache:GetString("item")
    for _, value in ipairs(self.filter_2) do
      local name = "filter_2_" .. value
      local unit = self:AsyncLoadUiUnit(unitPath, name, filterType.node_item, self.cancelSource:CreateToken())
      if unit then
        unit.lab_title.text = Lang("ModQuality_" .. value)
        unit.toggle:RemoveAllListeners()
        unit.toggle.isOn = self.filterRes_[self.helper_.FilterType.ModQuality].value[value] ~= nil and self.filterRes_[self.helper_.FilterType.ModQuality].value[value] or false
        unit.toggle:AddListener(function(isOn)
          if isOn then
            self.filterRes_[self.helper_.FilterType.ModQuality].value[value] = true
          else
            self.filterRes_[self.helper_.FilterType.ModQuality].value[value] = nil
          end
        end, true)
        self.units_[self.helper_.FilterType.ModQuality].children[value] = {unit = unit, name = name}
      end
    end
  end
end

function Common_filter_subView:initFilterTypeData_3()
  return {
    param = {
      [1] = 1,
      [2] = {}
    },
    value = {}
  }
end

function Common_filter_subView:createFilterType_3()
  if self.filterRes_[self.helper_.FilterType.ModEffectSelect] == nil then
    self.filterRes_[self.helper_.FilterType.ModEffectSelect] = self:initFilterTypeData_3()
  end
  local path = self.uiBinder.uiprefab_cache:GetString("type_2")
  local filterType = self:AsyncLoadUiUnit(path, "filter_3", self.uiBinder.node_content, self.cancelSource:CreateToken())
  if filterType then
    self:FilterType_3_UnitRefresh(filterType)
    local allModEffects = self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[2]
    self:ModReccreateFilterType_3_UnitsommendProfessionTplItem(allModEffects, filterType)
  end
end

function Common_filter_subView:FilterType_3_UnitRefresh(unit)
  self.units_[self.helper_.FilterType.ModEffectSelect] = {
    unit = unit,
    children = {}
  }
  unit.lab_num.text = self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[1]
  unit.btn_minus:AddListener(function()
    if self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[1] <= 1 then
      self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[1] = 1
      Z.TipsVM.ShowTipsLang(1042116)
    else
      self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[1] = self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[1] - 1
    end
    unit.lab_num.text = self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[1]
  end, true)
  unit.btn_add:AddListener(function()
    if self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[1] >= MOD_DEFINE.ModEffectMaxCount then
      self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[1] = MOD_DEFINE.ModEffectMaxCount
      Z.TipsVM.ShowTipsLang(1042115)
    else
      self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[1] = self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[1] + 1
    end
    unit.lab_num.text = self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[1]
  end, true)
  unit.btn_recommendation:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      local talentStageId = Z.VMMgr.GetVM("talent_skill").GetCurProfessionTalentStage()
      local talentStageConfig = Z.TableMgr.GetTable("TalentStageTableMgr").GetRow(talentStageId)
      if talentStageConfig then
        for _, recommendModEffect in pairs(talentStageConfig.RecommendModEffectId) do
          self.filterRes_[self.helper_.FilterType.ModEffectSelect].value[recommendModEffect] = recommendModEffect
          self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[2][recommendModEffect] = recommendModEffect
        end
        Common_filter_subView.ModReccreateFilterType_3_UnitsommendProfessionTplItem(self, self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[2], unit)
      end
    end)()
  end, true)
  unit.btn_bottom:AddListener(function()
    local viewData = {
      func = function(data)
        Z.CoroUtil.create_coro_xpcall(function()
          self.filterRes_[self.helper_.FilterType.ModEffectSelect].value = {}
          for _, recommendModEffect in pairs(data) do
            self.filterRes_[self.helper_.FilterType.ModEffectSelect].value[recommendModEffect] = recommendModEffect
            self.filterRes_[self.helper_.FilterType.ModEffectSelect].param[2][recommendModEffect] = recommendModEffect
          end
          Common_filter_subView.ModReccreateFilterType_3_UnitsommendProfessionTplItem(self, self.filterRes_[self.helper_.FilterType.ModEffectSelect].value, unit)
        end)()
      end
    }
    Z.UIMgr:OpenView("mod_term_recommend_popup", viewData)
  end, true)
end

function Common_filter_subView:ModReccreateFilterType_3_UnitsommendProfessionTplItem(effects, parentUnit)
  if self.units_[self.helper_.FilterType.ModEffectSelect] and self.units_[self.helper_.FilterType.ModEffectSelect].children then
    for _, child in pairs(self.units_[self.helper_.FilterType.ModEffectSelect].children) do
      self:RemoveUiUnit(child.name)
    end
    self.units_[self.helper_.FilterType.ModEffectSelect].children = {}
  end
  local count = 0
  local mod_data = Z.DataMgr.Get("mod_data")
  local unitPath = parentUnit.uiprefab_cache:GetString("item")
  for effectId, _ in pairs(effects) do
    local name = "filter_3_" .. effectId
    local unit = self:AsyncLoadUiUnit(unitPath, name, parentUnit.rect_effect, self.cancelSource:CreateToken())
    if unit then
      modGlossaryItemTplItem.RefreshTpl(unit.node_glossary_item_tpl, effectId, 0)
      local config = mod_data:GetEffectTableConfig(effectId, 0)
      unit.lab_title.text = config.EffectName
      self.units_[self.helper_.FilterType.ModEffectSelect].children[effectId] = {unit = unit, name = name}
      unit.btn_effect:AddListener(function()
        local viewData = {
          parent = self.parentTrans,
          effectId = effectId,
          config = config
        }
        Z.UIMgr:OpenView("mod_item_popup", viewData)
      end, true)
      unit.toggle.isOn = self.filterRes_[self.helper_.FilterType.ModEffectSelect].value[effectId] ~= nil and true or false
      unit.toggle:AddListener(function(isOn)
        if isOn then
          self.filterRes_[self.helper_.FilterType.ModEffectSelect].value[effectId] = true
        else
          self.filterRes_[self.helper_.FilterType.ModEffectSelect].value[effectId] = nil
        end
      end, true)
      count = count + 1
    end
  end
  local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
  coro(1, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
  self.uiBinder.rebuilder_content:ForceRebuildLayoutImmediate()
  if 0 < count then
    self.uiBinder.node_content:SetAnchorPosition(0, 58 * (count - 1))
  else
    self.uiBinder.node_content:SetAnchorPosition(0, 0)
  end
end

return Common_filter_subView
