local UI = Z.UI
local super = require("ui.ui_subview_base")
local Common_filter_subView = class("Common_filter_subView", super)
local MOD_DEFINE = require("ui.model.mod_define")
local modGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")

function Common_filter_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "common_filter_sub", "common_filter/common_filter_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "common_filter_sub", "common_filter/common_filter_sub", UI.ECacheLv.None)
  end
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
  self.tokens_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    if self.viewData.filterTypes then
      for _, type in ipairs(self.viewData.filterTypes) do
        local func = Common_filter_subView["createFilterType_" .. type]
        func(self, self.filterRes_[type])
      end
      self.uiBinder.rebuilder_content:ForceRebuildLayoutImmediate()
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
  for index, token in ipairs(self.tokens_) do
    Z.CancelSource.ReleaseToken(token)
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
    if type == E.CommonFilterType.ModEffectSelect then
      for _, child in pairs(self.units_[E.CommonFilterType.ModEffectSelect].children) do
        self:RemoveUiUnit(child.name)
      end
      self.units_[E.CommonFilterType.ModEffectSelect].children = {}
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
  if self.filterRes_[E.CommonFilterType.ModType] == nil then
    self.filterRes_[E.CommonFilterType.ModType] = self:initFilterTypeData_1()
  end
  local path = self.uiBinder.uiprefab_cache:GetString("type_1")
  local token = self.cancelSource:CreateToken()
  local name = "filter_1"
  self.tokens_[name] = token
  local filterType = self:AsyncLoadUiUnit(path, name, self.uiBinder.node_content, token)
  if filterType then
    self.units_[E.CommonFilterType.ModType] = {
      unit = filterType,
      name = "filter_1",
      children = {}
    }
    filterType.lab_type.text = Lang("ByType")
    local unitPath = filterType.uiprefab_cache:GetString("item")
    for _, value in ipairs(self.filter_1) do
      local unitName = "filter_1_" .. value
      local unitToken = self.cancelSource:CreateToken()
      self.tokens_[unitName] = unitToken
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, filterType.node_item, unitToken)
      if unit then
        unit.lab_title.text = Lang("ModType_" .. value)
        unit.toggle:RemoveAllListeners()
        unit.toggle.isOn = self.filterRes_[E.CommonFilterType.ModType].value[value] ~= nil and self.filterRes_[E.CommonFilterType.ModType].value[value] or false
        unit.toggle:AddListener(function(isOn)
          if isOn then
            self.filterRes_[E.CommonFilterType.ModType].value[value] = true
          else
            self.filterRes_[E.CommonFilterType.ModType].value[value] = nil
          end
        end, true)
        self.units_[E.CommonFilterType.ModType].children[value] = {unit = unit, name = name}
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
  if self.filterRes_[E.CommonFilterType.ModQuality] == nil then
    self.filterRes_[E.CommonFilterType.ModQuality] = self:initFilterTypeData_2()
  end
  local path = self.uiBinder.uiprefab_cache:GetString("type_1")
  local name = "filter_2"
  local token = self.cancelSource:CreateToken()
  self.tokens_[name] = token
  local filterType = self:AsyncLoadUiUnit(path, name, self.uiBinder.node_content, token)
  if filterType then
    self.units_[E.CommonFilterType.ModQuality] = {
      unit = filterType,
      children = {}
    }
    filterType.lab_type.text = Lang("ByQuality")
    local unitPath = filterType.uiprefab_cache:GetString("item")
    for _, value in ipairs(self.filter_2) do
      local unitName = "filter_2_" .. value
      local unitToken = self.cancelSource:CreateToken()
      self.tokens_[unitName] = unitToken
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, filterType.node_item, unitToken)
      if unit then
        unit.lab_title.text = Lang("ModQuality_" .. value)
        unit.toggle:RemoveAllListeners()
        unit.toggle.isOn = self.filterRes_[E.CommonFilterType.ModQuality].value[value] ~= nil and self.filterRes_[E.CommonFilterType.ModQuality].value[value] or false
        unit.toggle:AddListener(function(isOn)
          if isOn then
            self.filterRes_[E.CommonFilterType.ModQuality].value[value] = true
          else
            self.filterRes_[E.CommonFilterType.ModQuality].value[value] = nil
          end
        end, true)
        self.units_[E.CommonFilterType.ModQuality].children[value] = {unit = unit, name = name}
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
  if self.filterRes_[E.CommonFilterType.ModEffectSelect] == nil then
    self.filterRes_[E.CommonFilterType.ModEffectSelect] = self:initFilterTypeData_3()
  end
  local path = self.uiBinder.uiprefab_cache:GetString("type_2")
  local name = "filter_3"
  local token = self.cancelSource:CreateToken()
  self.tokens_[name] = token
  local filterType = self:AsyncLoadUiUnit(path, "filter_3", self.uiBinder.node_content, token)
  if filterType then
    self:FilterType_3_UnitRefresh(filterType)
    local allModEffects = self.filterRes_[E.CommonFilterType.ModEffectSelect].param[2]
    self:ModReccreateFilterType_3_UnitsommendProfessionTplItem(allModEffects, filterType)
  end
end

function Common_filter_subView:FilterType_3_UnitRefresh(unit)
  self.units_[E.CommonFilterType.ModEffectSelect] = {
    unit = unit,
    children = {}
  }
  unit.lab_num.text = self.filterRes_[E.CommonFilterType.ModEffectSelect].param[1]
  unit.btn_minus:AddListener(function()
    if self.filterRes_[E.CommonFilterType.ModEffectSelect].param[1] <= 1 then
      self.filterRes_[E.CommonFilterType.ModEffectSelect].param[1] = 1
      Z.TipsVM.ShowTipsLang(1042116)
    else
      self.filterRes_[E.CommonFilterType.ModEffectSelect].param[1] = self.filterRes_[E.CommonFilterType.ModEffectSelect].param[1] - 1
    end
    unit.lab_num.text = self.filterRes_[E.CommonFilterType.ModEffectSelect].param[1]
  end, true)
  unit.btn_add:AddListener(function()
    if self.filterRes_[E.CommonFilterType.ModEffectSelect].param[1] >= MOD_DEFINE.ModEffectMaxCount then
      self.filterRes_[E.CommonFilterType.ModEffectSelect].param[1] = MOD_DEFINE.ModEffectMaxCount
      Z.TipsVM.ShowTipsLang(1042115)
    else
      self.filterRes_[E.CommonFilterType.ModEffectSelect].param[1] = self.filterRes_[E.CommonFilterType.ModEffectSelect].param[1] + 1
    end
    unit.lab_num.text = self.filterRes_[E.CommonFilterType.ModEffectSelect].param[1]
  end, true)
  unit.btn_recommendation:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      local talentStageId = Z.VMMgr.GetVM("talent_skill").GetCurProfessionTalentStage()
      local talentStageConfig = Z.TableMgr.GetTable("TalentStageTableMgr").GetRow(talentStageId)
      if talentStageConfig then
        for _, recommendModEffect in pairs(talentStageConfig.RecommendModEffectId) do
          self.filterRes_[E.CommonFilterType.ModEffectSelect].value[recommendModEffect] = recommendModEffect
          self.filterRes_[E.CommonFilterType.ModEffectSelect].param[2][recommendModEffect] = recommendModEffect
        end
        Common_filter_subView.ModReccreateFilterType_3_UnitsommendProfessionTplItem(self, self.filterRes_[E.CommonFilterType.ModEffectSelect].param[2], unit)
      end
    end)()
  end, true)
  unit.btn_bottom:AddListener(function()
    local viewData = {
      func = function(data)
        Z.CoroUtil.create_coro_xpcall(function()
          self.filterRes_[E.CommonFilterType.ModEffectSelect].value = {}
          for _, recommendModEffect in pairs(data) do
            self.filterRes_[E.CommonFilterType.ModEffectSelect].value[recommendModEffect] = recommendModEffect
            self.filterRes_[E.CommonFilterType.ModEffectSelect].param[2][recommendModEffect] = recommendModEffect
          end
          Common_filter_subView.ModReccreateFilterType_3_UnitsommendProfessionTplItem(self, self.filterRes_[E.CommonFilterType.ModEffectSelect].value, unit)
        end)()
      end
    }
    Z.UIMgr:OpenView("mod_term_recommend_popup", viewData)
  end, true)
end

function Common_filter_subView:ModReccreateFilterType_3_UnitsommendProfessionTplItem(effects, parentUnit)
  if self.units_[E.CommonFilterType.ModEffectSelect] and self.units_[E.CommonFilterType.ModEffectSelect].children then
    for _, child in pairs(self.units_[E.CommonFilterType.ModEffectSelect].children) do
      self:RemoveUiUnit(child.name)
    end
    self.units_[E.CommonFilterType.ModEffectSelect].children = {}
  end
  local count = 0
  local mod_data = Z.DataMgr.Get("mod_data")
  local unitPath = parentUnit.uiprefab_cache:GetString("item")
  for effectId, _ in pairs(effects) do
    local name = "filter_3_" .. effectId
    local token = self.cancelSource:CreateToken()
    self.tokens_[name] = token
    local unit = self:AsyncLoadUiUnit(unitPath, name, parentUnit.rect_effect, token)
    if unit then
      modGlossaryItemTplItem.RefreshTpl(unit.node_glossary_item_tpl, effectId)
      local config = mod_data:GetEffectTableConfig(effectId, 0)
      unit.lab_title.text = config.EffectName
      self.units_[E.CommonFilterType.ModEffectSelect].children[effectId] = {unit = unit, name = name}
      unit.btn_effect:AddListener(function()
        local viewData = {
          parent = self.parentTrans,
          effectId = effectId,
          config = config
        }
        Z.UIMgr:OpenView("mod_item_popup", viewData)
      end, true)
      unit.toggle.isOn = self.filterRes_[E.CommonFilterType.ModEffectSelect].value[effectId] ~= nil and true or false
      unit.toggle:AddListener(function(isOn)
        if isOn then
          self.filterRes_[E.CommonFilterType.ModEffectSelect].value[effectId] = true
        else
          self.filterRes_[E.CommonFilterType.ModEffectSelect].value[effectId] = nil
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

function Common_filter_subView:initFilterTypeData_4()
  return {
    param = {},
    value = {}
  }
end

function Common_filter_subView:createFilterType_4()
  if self.filterRes_[E.CommonFilterType.SeasonEquip] == nil then
    self.filterRes_[E.CommonFilterType.SeasonEquip] = self:initFilterTypeData_4()
  end
  local path = self.uiBinder.uiprefab_cache:GetString("type_1")
  local name = "filter_4"
  local token = self.cancelSource:CreateToken()
  self.tokens_[name] = token
  local filterType = self:AsyncLoadUiUnit(path, name, self.uiBinder.node_content, token)
  if filterType then
    self.units_[E.CommonFilterType.SeasonEquip] = {
      unit = filterType,
      name = name,
      children = {}
    }
    filterType.lab_type.text = Lang("EquipBreakThroughFilterSeason")
    local unitPath = filterType.uiprefab_cache:GetString("item_3")
    local seasonData = Z.DataMgr.Get("season_data")
    local curSeasonId = seasonData.CurSeasonId
    local seasonTableRows = {}
    for _, seasonGlobalTableRow in pairs(seasonData.SeasonGlobalTableDatas) do
      local seasonId = seasonGlobalTableRow.SeasonId
      if curSeasonId >= seasonId then
        seasonTableRows[#seasonTableRows + 1] = seasonGlobalTableRow
      end
    end
    table.sort(seasonTableRows, function(left, right)
      if left.SeasonId == curSeasonId then
        return true
      elseif right.SeasonId == curSeasonId then
        return false
      end
      return left.SeasonId > right.SeasonId
    end)
    for _, seasonGlobalTableRow in ipairs(seasonTableRows) do
      local seasonId = seasonGlobalTableRow.SeasonId
      if curSeasonId >= seasonId then
        do
          local name = "filter_4_" .. seasonId
          local token = self.cancelSource:CreateToken()
          self.tokens_[name] = token
          local unit = self:AsyncLoadUiUnit(unitPath, name, filterType.node_item_two, token)
          if unit then
            unit.lab_off.text = Lang("EquipBreakThroughFilterSeasonNum", {
              val = seasonGlobalTableRow.SeasonId
            })
            unit.lab_on.text = Lang("EquipBreakThroughFilterSeasonNum", {
              val = seasonGlobalTableRow.SeasonId
            })
            unit.toggle:RemoveAllListeners()
            unit.toggle.isOn = self.filterRes_[E.CommonFilterType.SeasonEquip].value[seasonId] ~= nil and self.filterRes_[E.CommonFilterType.SeasonEquip].value[seasonId] or false
            unit.toggle:AddListener(function(isOn)
              if isOn then
                self.filterRes_[E.CommonFilterType.SeasonEquip].value[seasonId] = true
              else
                self.filterRes_[E.CommonFilterType.SeasonEquip].value[seasonId] = nil
              end
            end, true)
            self.units_[E.CommonFilterType.SeasonEquip].children[seasonId] = {unit = unit, name = name}
          end
        end
      end
    end
  end
end

function Common_filter_subView:initFilterTypeData_5()
  return {
    param = {},
    value = {}
  }
end

function Common_filter_subView:createFilterType_5()
  if self.filterRes_[E.CommonFilterType.EquipGs] == nil then
    self.filterRes_[E.CommonFilterType.EquipGs] = self:initFilterTypeData_4()
  end
  local path = self.uiBinder.uiprefab_cache:GetString("type_1")
  local name = "filter_5"
  local token = self.cancelSource:CreateToken()
  self.tokens_[name] = token
  local filterType = self:AsyncLoadUiUnit(path, name, self.uiBinder.node_content, token)
  if filterType then
    self.units_[E.CommonFilterType.EquipGs] = {
      unit = filterType,
      name = name,
      children = {}
    }
    filterType.lab_type.text = Lang("Equipping")
    local unitPath = filterType.uiprefab_cache:GetString("item_3")
    for key, gs in ipairs(Z.Global.EquipScreenGS) do
      local name = "filter_5_" .. key
      local token = self.cancelSource:CreateToken()
      self.tokens_[name] = token
      local unit = self:AsyncLoadUiUnit(unitPath, name, filterType.node_item_two, token)
      if unit then
        local content = Lang("ValueGSEqual", {
          val = gs[3]
        })
        unit.lab_off.text = content
        unit.lab_on.text = content
        unit.toggle:RemoveAllListeners()
        unit.toggle.isOn = self.filterRes_[E.CommonFilterType.EquipGs].value[key] ~= nil and self.filterRes_[E.CommonFilterType.EquipGs].value[key] or false
        unit.toggle:AddListener(function(isOn)
          if isOn then
            self.filterRes_[E.CommonFilterType.EquipGs].value[key] = true
          else
            self.filterRes_[E.CommonFilterType.EquipGs].value[key] = nil
          end
        end, true)
        self.units_[E.CommonFilterType.EquipGs].children[key] = {unit = unit, name = name}
      end
    end
  end
end

function Common_filter_subView:initFilterTypeData_6()
  return {
    param = {},
    value = {}
  }
end

function Common_filter_subView:createFilterType_6()
  if self.filterRes_[E.CommonFilterType.UnlockProfession] == nil then
    self.filterRes_[E.CommonFilterType.UnlockProfession] = self:initFilterTypeData_4()
  end
  local path = self.uiBinder.uiprefab_cache:GetString("type_1")
  local name = "filter_6"
  local token = self.cancelSource:CreateToken()
  self.tokens_[name] = token
  local filterType = self:AsyncLoadUiUnit(path, name, self.uiBinder.node_content, token)
  if filterType then
    self.units_[E.CommonFilterType.UnlockProfession] = {
      unit = filterType,
      name = name,
      children = {}
    }
    filterType.lab_type.text = Lang("Occupation")
    local unitPath = filterType.uiprefab_cache:GetString("item_3")
    local curProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
    local professionList = Z.ContainerMgr.CharSerialize.professionList.professionList
    local professIds = {}
    for professionId, value in pairs(professionList) do
      professIds[#professIds + 1] = professionId
    end
    table.sort(professIds, function(left, right)
      if left == curProfessionId then
        return true
      elseif right == curProfessionId then
        return false
      end
      return right < left
    end)
    for _, professionId in pairs(professIds) do
      local professionRow = Z.TableMgr.GetRow("ProfessionSystemTableMgr", professionId)
      if professionRow then
        local name = "filter_6_" .. professionId
        local token = self.cancelSource:CreateToken()
        self.tokens_[name] = token
        local unit = self:AsyncLoadUiUnit(unitPath, name, filterType.node_item, token)
        if unit then
          unit.lab_off.text = professionRow.Name
          unit.Trans:SetWidth(Z.IsPCUI and 420 or 560)
          unit.lab_on.text = professionRow.Name
          unit.toggle:RemoveAllListeners()
          unit.toggle.isOn = false
          unit.toggle:AddListener(function(isOn)
            if isOn then
              self.filterRes_[E.CommonFilterType.UnlockProfession].value[professionId] = true
            else
              self.filterRes_[E.CommonFilterType.UnlockProfession].value[professionId] = nil
            end
          end, true)
          self.units_[E.CommonFilterType.UnlockProfession].children[professionId] = {unit = unit, name = name}
        end
      end
    end
  end
end

function Common_filter_subView:initFilterTypeData_7()
  local data = {
    param = {},
    value = {}
  }
  local skillConfigs = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetDatas()
  for k, config in pairs(skillConfigs) do
    if not data.param[config.RarityType] then
      data.param[config.RarityType] = Lang("ResonanceSkillRarityDesc_" .. config.RarityType)
    end
  end
  return data
end

function Common_filter_subView:createFilterType_7()
  local curType = E.CommonFilterType.ResonanceSkillRarity
  if self.filterRes_[curType] == nil then
    self.filterRes_[curType] = self:initFilterTypeData_7()
  end
  local itemPath = self.uiBinder.uiprefab_cache:GetString("type_1")
  local itemName = "resonanceSkillRarityContent"
  local itemUnit = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.node_content, self.cancelSource:CreateToken())
  if itemUnit then
    self.units_[curType] = {
      unit = itemUnit,
      children = {}
    }
    itemUnit.lab_type.text = Lang("ResonanceSkillRarity")
    local subItemPath = itemUnit.uiprefab_cache:GetString("item")
    for index, desc in pairs(self.filterRes_[curType].param) do
      local subItemName = "resonanceSkillRarityItem_" .. index
      local subItemUnit = self:AsyncLoadUiUnit(subItemPath, subItemName, itemUnit.node_item, self.cancelSource:CreateToken())
      if subItemUnit then
        subItemUnit.lab_title.text = desc
        subItemUnit.toggle:RemoveAllListeners()
        subItemUnit.toggle.isOn = self.filterRes_[curType].value[index] ~= nil and self.filterRes_[curType].value[index] or false
        subItemUnit.toggle:AddListener(function(isOn)
          if isOn then
            self.filterRes_[curType].value[index] = true
          else
            self.filterRes_[curType].value[index] = nil
          end
        end, true)
        self.units_[curType].children[index] = {unit = subItemUnit, name = subItemName}
      end
    end
  end
end

function Common_filter_subView:initFilterTypeData_8()
  local data = {
    param = {},
    value = {}
  }
  local skillConfigs = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetDatas()
  for k, config in pairs(skillConfigs) do
    for i, type in ipairs(config.ShowSkillType) do
      if not data.param[type] then
        data.param[type] = Lang("ShowSkillType_" .. type)
      end
    end
  end
  return data
end

function Common_filter_subView:createFilterType_8()
  local curType = E.CommonFilterType.ResonanceSkillType
  if self.filterRes_[curType] == nil then
    self.filterRes_[curType] = self:initFilterTypeData_8()
  end
  local itemPath = self.uiBinder.uiprefab_cache:GetString("type_1")
  local itemName = "resonanceSkillTypeContent"
  local itemUnit = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.node_content, self.cancelSource:CreateToken())
  if itemUnit then
    self.units_[curType] = {
      unit = itemUnit,
      children = {}
    }
    itemUnit.lab_type.text = Lang("ResonanceSkillType")
    local subItemPath = itemUnit.uiprefab_cache:GetString("item")
    for index, desc in pairs(self.filterRes_[curType].param) do
      local subItemName = "resonanceSkillTypeItem_" .. index
      local subItemUnit = self:AsyncLoadUiUnit(subItemPath, subItemName, itemUnit.node_item, self.cancelSource:CreateToken())
      if subItemUnit then
        subItemUnit.lab_title.text = desc
        subItemUnit.toggle:RemoveAllListeners()
        subItemUnit.toggle.isOn = self.filterRes_[curType].value[index] ~= nil and self.filterRes_[curType].value[index] or false
        subItemUnit.toggle:AddListener(function(isOn)
          if isOn then
            self.filterRes_[curType].value[index] = true
          else
            self.filterRes_[curType].value[index] = nil
          end
        end, true)
        self.units_[curType].children[index] = {unit = subItemUnit, name = subItemName}
      end
    end
  end
end

function Common_filter_subView:initFilterTypeData_9()
  local data = {
    param = {
      [0] = Lang("ResonanceHaveState_0"),
      [1] = Lang("ResonanceHaveState_1")
    },
    value = {}
  }
  return data
end

function Common_filter_subView:createFilterType_9()
  local curType = E.CommonFilterType.ResonanceHave
  if self.filterRes_[curType] == nil then
    self.filterRes_[curType] = self:initFilterTypeData_9()
  end
  local itemPath = self.uiBinder.uiprefab_cache:GetString("type_1")
  local itemName = "resonanceHaveContent"
  local itemUnit = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.node_content, self.cancelSource:CreateToken())
  if itemUnit then
    self.units_[curType] = {
      unit = itemUnit,
      children = {}
    }
    itemUnit.lab_type.text = Lang("ResonanceHaveLabel")
    local subItemPath = itemUnit.uiprefab_cache:GetString("item")
    for index, desc in pairs(self.filterRes_[curType].param) do
      local subItemName = "resonanceHaveItem_" .. index
      local subItemUnit = self:AsyncLoadUiUnit(subItemPath, subItemName, itemUnit.node_item, self.cancelSource:CreateToken())
      if subItemUnit then
        subItemUnit.lab_title.text = desc
        subItemUnit.toggle:RemoveAllListeners()
        subItemUnit.toggle.isOn = self.filterRes_[curType].value[index] ~= nil and self.filterRes_[curType].value[index] or false
        subItemUnit.toggle:AddListener(function(isOn)
          if isOn then
            self.filterRes_[curType].value[index] = true
          else
            self.filterRes_[curType].value[index] = nil
          end
        end, true)
        self.units_[curType].children[index] = {unit = subItemUnit, name = subItemName}
      end
    end
  end
end

return Common_filter_subView
