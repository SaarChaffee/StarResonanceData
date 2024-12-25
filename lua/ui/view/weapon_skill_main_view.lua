local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_skill_mainView = class("Weapon_skill_mainView", super)
local weaponSkillLevelView = require("ui.view.weapon_develop_skill_sub_view")
local weaponResonanceSkillTipsView = require("ui.view.weapon_resonance_skill_tips_view")
local loopGridView = require("ui.component.loop_grid_view")
local weaponResonanceSkillLoopItem = require("ui.component.weapon.weapon_resonance_skill_loop_item")
local itemFilter = require("ui.view.item_filters_view")
local subFuncIdDict = {
  [E.SkillType.WeaponSkill] = E.FunctionID.WeaponNormalSkill,
  [E.SkillType.MysteriesSkill] = E.FunctionID.WeaponAoyiSkill
}
local maxSkillDistance = 90

function Weapon_skill_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_skill_main")
  self.itemFilter_ = itemFilter.new(self)
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.professionVm_ = Z.VMMgr.GetVM("profession")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.subFuncIdDict_ = {
    [E.SkillType.WeaponSkill] = E.FunctionID.WeaponNormalSkill,
    [E.SkillType.MysteriesSkill] = E.FunctionID.WeaponAoyiSkill
  }
end

function Weapon_skill_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self:onStartAnimShow()
  self.EquipModel = false
  self.clearDirtyTag_ = false
  self.weaponSkillLevelUp_ = weaponSkillLevelView.new(self)
  self.weaponResonanceSkillTips_ = weaponResonanceSkillTipsView.new(self)
  self.professionId_ = self.professionVm_:GetCurProfession()
  self.skillDepth_ = {}
  self.skillEquip_ = {}
  self.skillShowEffEquip_ = {}
  self.skillUnitNames_ = {}
  self.skillTabUnitNames_ = {}
  self.skillEquipUnitNames_ = {}
  self.typeSelectSkillIds_ = {}
  self:initButton()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_right_trans, false)
  local togBinders = {
    [1] = self.uiBinder.tab_01,
    [2] = self.uiBinder.tab_02
  }
  for index, value in ipairs(togBinders) do
    local subFuncId = self.subFuncIdDict_[index]
    value.tog_tab_select.group = self.uiBinder.layout_tab
    value.tog_tab_select:RemoveAllListeners()
    value.tog_tab_select.isOn = false
    value.tog_tab_select:AddListener(function(isOn)
      if isOn then
        self.commonVM_.CommonPlayTogAnim(value.anim_tog, self.cancelSource:CreateToken())
        self.SelectSkillType = index
        self:onSkillTypeSelect()
      end
    end)
    value.tog_tab_select.OnPointClickEvent:AddListener(function()
      local isFuncOpen = self.funcVM_.CheckFuncCanUse(subFuncId)
      value.tog_tab_select.IsToggleCanSwitch = isFuncOpen
    end)
    local isUnlock = self.funcVM_.CheckFuncCanUse(subFuncId, true)
    value.Ref:SetVisible(value.img_lock, not isUnlock)
    local color = value.img_off.color
    color.a = isUnlock and 0.5 or 0.1
    value.img_off:SetColor(color)
  end
  self.depth_ = self.uiBinder.Ref.UIComp.UIDepth.Depth
  self:initSkillEquipSetting()
  self:initLoopGridView()
  self:initFilter()
  if self.viewData.skillId and self.viewData.skillId ~= 0 then
    self.SelectSkillId = self.viewData.skillId
  end
  self.SelectSkillType = 1
  if self.viewData and self.viewData.skillType and togBinders[self.viewData.skillType] then
    local isFuncOpen = self.funcVM_.CheckFuncCanUse(self.subFuncIdDict_[self.SelectSkillType])
    if isFuncOpen then
      self.SelectSkillType = self.viewData.skillType
    end
  end
  if togBinders[self.SelectSkillType].tog_tab_select.isOn then
    self:onSkillTypeSelect()
  else
    togBinders[self.SelectSkillType].tog_tab_select.isOn = true
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_right_trans, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.copy_skill_item_trans, false)
  self.uiBinder.lab_name.text = Lang("Assemble")
  if not self.professionVm_:CheckProfessionEquipWeapon() then
    local professionId = self.professionVm_:GetCurProfession()
    local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
    if professionRow == nil then
      return
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_prompt, true)
    self.uiBinder.lab_prompt.text = string.format(Lang("no_profession_weapon_tips"), professionRow.Name)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_prompt, false)
  end
  self:bindEvents()
  self:loadRedDotItem()
end

function Weapon_skill_mainView:initButton()
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    if self.EquipModel then
      self:closeEquipModel()
      self.EquipModel = false
      self:checkSkillUnitState()
    else
      self.weaponSkillVm_:CloseWeaponSkillView()
    end
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_assemble, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_assemble_exit, false)
  self:AddAsyncClick(self.uiBinder.btn_assemble, function()
    self:openEqiupModel()
    self:checkSkillUnitState()
  end)
  self:AddAsyncClick(self.uiBinder.btn_assemble_exit, function()
    self:closeEquipModel()
    self:checkSkillUnitState()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    if self.SelectSkillType == E.SkillType.WeaponSkill then
      self.helpsysVM_.OpenFullScreenTipsView(400101)
    elseif self.SelectSkillType == E.SkillType.MysteriesSkill then
      self.helpsysVM_.OpenFullScreenTipsView(400102)
    end
  end)
end

function Weapon_skill_mainView:initSkillEquipSetting()
  self.skillNodes_ = {
    [1] = self.uiBinder.node_right.node_skill_01,
    [2] = self.uiBinder.node_right.node_skill_02,
    [3] = self.uiBinder.node_right.node_skill_03,
    [4] = self.uiBinder.node_right.node_skill_04,
    [5] = self.uiBinder.node_right.node_skill_05,
    [6] = self.uiBinder.node_right.node_skill_06,
    [7] = self.uiBinder.node_right.node_skill_07,
    [8] = self.uiBinder.node_right.node_skill_08,
    [9] = self.uiBinder.node_right.node_skill_09
  }
  self.skillDepth_ = {
    [1] = self.uiBinder.node_right.node_skill_01_depth,
    [2] = self.uiBinder.node_right.node_skill_02_depth,
    [3] = self.uiBinder.node_right.node_skill_03_depth,
    [4] = self.uiBinder.node_right.node_skill_04_depth,
    [5] = self.uiBinder.node_right.node_skill_05_depth,
    [6] = self.uiBinder.node_right.node_skill_06_depth,
    [7] = self.uiBinder.node_right.node_skill_07_depth,
    [8] = self.uiBinder.node_right.node_skill_08_depth,
    [9] = self.uiBinder.node_right.node_skill_09_depth
  }
  self.skillEquipCheckNode_ = {
    [1] = self.uiBinder.node_right.checkNode_1,
    [2] = self.uiBinder.node_right.checkNode_2,
    [3] = self.uiBinder.node_right.checkNode_3,
    [4] = self.uiBinder.node_right.checkNode_4,
    [5] = self.uiBinder.node_right.checkNode_5,
    [6] = self.uiBinder.node_right.checkNode_6,
    [7] = self.uiBinder.node_right.checkNode_7,
    [8] = self.uiBinder.node_right.checkNode_8,
    [9] = self.uiBinder.node_right.checkNode_9
  }
  self.steerUnits_ = {
    [1] = self.uiBinder.node_right.steer_skill_3,
    [2] = self.uiBinder.node_right.steer_skill_4,
    [3] = self.uiBinder.node_right.steer_skill_5
  }
  self.steerSkillId = {
    [1] = 3,
    [2] = 4,
    [3] = 5
  }
  for _, value in pairs(self.skillDepth_) do
    value:UpdateDepth(self.depth_ - 1, true)
  end
  self:refreshSkillEquipSetting()
end

function Weapon_skill_mainView:GetCacheData()
  local viewData = {
    skillType = self.SelectSkillType,
    skillId = self.SelectSkillId
  }
  return viewData
end

function Weapon_skill_mainView:initFilter()
  self.filterDatas_ = nil
  self.filterParam_ = {
    [E.ItemFilterType.ResonanceSkillRarity] = {},
    [E.ItemFilterType.ResonanceSkillType] = {}
  }
  local skillConfigs = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetDatas()
  for k, value in pairs(skillConfigs) do
    if not self.filterParam_[E.ItemFilterType.ResonanceSkillRarity][value.RarityType] then
      self.filterParam_[E.ItemFilterType.ResonanceSkillRarity][value.RarityType] = Lang("ResonanceSkillRarityDesc_" .. value.RarityType)
    end
    if not self.filterParam_[E.ItemFilterType.ResonanceSkillType][value.ShowSkillType] then
      self.filterParam_[E.ItemFilterType.ResonanceSkillType][value.ShowSkillType] = Lang("ShowSkillType_" .. value.ShowSkillType)
    end
  end
  self:AddClick(self.uiBinder.btn_filter, function()
    self:openItemFilter()
  end)
end

function Weapon_skill_mainView:unInitFilter()
  self.itemFilter_:DeActive()
  self.filterDatas_ = nil
  self.filterParam_ = nil
end

function Weapon_skill_mainView:openItemFilter()
  local viewData = {
    parentView = self,
    filterType = E.ItemFilterType.ResonanceSkillRarity + E.ItemFilterType.ResonanceSkillType,
    existFilterTags = self.filterDatas_,
    filterTypeParam = self.filterParam_
  }
  self.itemFilter_:Active(viewData, self.uiBinder.node_filter_pos)
end

function Weapon_skill_mainView:onSelectFilter(filterTgas)
  if table.zcount(filterTgas) < 1 then
    self.filterDatas_ = nil
  end
  self.filterDatas_ = filterTgas
  self:refreshLoopGridView()
end

function Weapon_skill_mainView:initLoopGridView()
  self.loopGridView_ = loopGridView.new(self, self.uiBinder.loop_grid_view, weaponResonanceSkillLoopItem, "weapon_resonance_skill_tpl")
  local dataList = {}
  self.loopGridView_:Init(dataList)
end

function Weapon_skill_mainView:refreshLoopGridView()
  local skillDataList = self.weaponSkillVm_:GetMysteriesSkillList(self.filterDatas_)
  if 0 < #skillDataList then
    if self.typeSelectSkillIds_[E.SkillType.MysteriesSkill] == nil then
      self.typeSelectSkillIds_[E.SkillType.MysteriesSkill] = skillDataList[1].Config.Id
    end
    local isInSkillArray = false
    for __, value in ipairs(skillDataList) do
      if value.Config.Id == self.SelectSkillId then
        isInSkillArray = true
      end
    end
    if isInSkillArray then
      self:onSkillItemSelect(self.SelectSkillId)
    else
      self:onSkillItemSelect(self.typeSelectSkillIds_[E.SkillType.MysteriesSkill])
    end
  end
  self.loopGridView_:RefreshListView(skillDataList)
end

function Weapon_skill_mainView:unInitLoopGridView()
  self.loopGridView_:UnInit()
  self.loopGridView_ = nil
end

function Weapon_skill_mainView:setSteerId()
  local isAlreadySet = false
  for index, steer in pairs(self.steerUnits_) do
    local skillId = self.weaponSkillVm_:GetSkillBySlot(self.steerSkillId[index])
    if skillId == 0 and not isAlreadySet then
      isAlreadySet = true
      Z.GuideMgr:SetSteerIdByComp(steer, E.DynamicSteerType.WeaponSkillSlot, 1)
    else
      steer:ClearSteerList()
    end
  end
end

function Weapon_skill_mainView:refreshSkillEquipSetting()
  self:setSteerId()
  for _, value in pairs(self.skillEquipUnitNames_) do
    self:RemoveUiUnit(value)
  end
  self.skillEquipUnitNames_ = {}
  self.skillEquipUnits_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    for id, root in pairs(self.skillNodes_) do
      local skillType = self.weaponSkillVm_:GetSkillTypeBySlotId(id)
      local skillId = self.weaponSkillVm_:GetSkillBySlot(id)
      local path = self.uiBinder.prefab_cache:GetString("skill_item")
      local isNormalStyle = true
      if skillType == E.SkillType.MysteriesSkill and skillId ~= 0 then
        isNormalStyle = false
        path = self.uiBinder.prefab_cache:GetString("resonance_skill")
      end
      local unit = self:AsyncLoadUiUnit(path, "skill_item_" .. id, root)
      self.skillEquipUnits_[id] = unit
      table.insert(self.skillEquipUnitNames_, "skill_item_" .. id)
      unit.Ref:SetVisible(unit.root, true)
      unit.Ref:SetVisible(unit.img_assemble, false)
      unit.Ref:SetVisible(unit.img_on, false)
      unit.node_eff_loop:SetEffectGoVisible(false)
      unit.node_eff_show:SetEffectGoVisible(false)
      unit.Ref:SetVisible(unit.lab_lock, false)
      unit.Ref:SetVisible(unit.img_lock, false)
      if Z.IsPCUI and skillId ~= 0 then
        unit.Ref:SetVisible(unit.img_pc, true)
        local iconName, path = self.weaponSkillVm_:GetKeyCodeNameBySkillId(self.weaponSkillVm_:GetOriginSkillId(skillId))
        if path then
          unit.Ref:SetVisible(unit.img_pc_icon, true)
          unit.img_pc_icon:SetImage(path)
        else
          unit.Ref:SetVisible(unit.img_pc_icon, false)
        end
        unit.lab_figure.text = iconName
      else
        unit.Ref:SetVisible(unit.img_pc, false)
      end
      if isNormalStyle then
        unit.Ref:SetVisible(unit.img_mark, false)
        unit.Ref:SetVisible(unit.node_lab, false)
        unit.Ref:SetVisible(unit.img_light, false)
      else
        unit.Ref:SetVisible(unit.lab_name, false)
        local skillAoyiRow = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetRow(skillId)
        if skillAoyiRow then
          local bgImgPath = Z.ConstValue.Resonance_skill_bg .. skillAoyiRow.RarityType
          unit.img_bg:SetImage(bgImgPath)
          local advanceLevel = self.weaponSkillVm_:GetSkillRemodelLevel(skillId)
          unit.lab_advance_level.text = advanceLevel
          unit.Ref:SetVisible(unit.img_advance_level, 0 < advanceLevel)
          unit.Ref:SetVisible(unit.node_red_dot, false)
          if Z.IsPCUI then
            unit.lab_key.text = self.weaponSkillVm_:GetKeyCodeNameBySkillId(self.weaponSkillVm_:GetOriginSkillId(skillId))
          end
          unit.Ref:SetVisible(unit.img_key, Z.IsPCUI)
          unit.Ref:SetVisible(unit.img_assemble, not Z.IsPCUI)
          unit.Ref:SetVisible(unit.img_frame, false)
          unit.img_on:SetImage(Z.ConstValue.Resonance_skill_select .. skillAoyiRow.RarityType)
        end
      end
      local subFuncId = subFuncIdDict[skillType]
      local isFuncOpen = true
      if subFuncId then
        local isFuncOpen = self.funcVM_.CheckFuncCanUse(subFuncId, true)
        unit.Ref:SetVisible(unit.img_lock, not isFuncOpen)
      end
      local slotConfig = Z.TableMgr.GetRow("SkillSlotPositionTableMgr", id)
      local slotUnlock = true
      if slotConfig and slotConfig.UnlockCondition then
        slotUnlock = Z.ConditionHelper.CheckCondition(slotConfig.UnlockCondition)
        if not slotUnlock then
          for _, condition in ipairs(slotConfig.UnlockCondition) do
            if condition[1] == E.ConditionType.Level then
              unit.Ref:SetVisible(unit.lab_lock, true)
              unit.lab_lock.text = Lang("Grade", {
                val = condition[2]
              })
            end
          end
        end
      end
      unit.Ref:SetVisible(unit.img_lock, not slotUnlock or not isFuncOpen)
      unit.Trans:SetAnchorPosition(0, 0)
      if skillId == 0 then
        unit.Ref:SetVisible(unit.img_icon, false)
      else
        unit.Ref:SetVisible(unit.img_icon, true)
        local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
        unit.img_icon:SetImage(skillRow.Icon)
      end
      self:AddAsyncClick(unit.btn, function()
        if self.SelectSkillId and self.skillEquip_[id] then
          local nowSkillId = self.weaponSkillVm_:GetSkillBySlot(id)
          self.weaponSkillVm_:AsyncSkillInstall(id, self.SelectSkillId, self.cancelSource:CreateToken())
          local unlock = self.weaponSkillVm_:CheckSkillUnlock(self.SelectSkillId)
          if nowSkillId and self.SelectSkillId ~= nowSkillId and unlock then
            self:onShowOrHideEff(id)
          end
        end
      end)
      unit.event_trigger:ClearAll()
      if skillId ~= 0 then
        local canEquip = self.weaponSkillVm_:CheckSkillCanEquip(skillId)
        if canEquip then
          self:initDraw(unit, skillId, true)
        end
      end
    end
    self:refreshSkillEquipInfo()
  end)()
end

function Weapon_skill_mainView:refreshSlotRedDot()
  for id, unit in pairs(self.skillEquipUnits_) do
    local skillType = self.weaponSkillVm_:GetSkillTypeBySlotId(id)
    local slotNodeId = self.weaponSkillVm_:GetSlotEquipRedId(id)
    if skillType == self.SelectSkillType then
      Z.RedPointMgr.LoadRedDotItem(slotNodeId, self, unit.btn.transform)
    else
      Z.RedPointMgr.RemoveNodeItem(slotNodeId, self)
    end
  end
end

function Weapon_skill_mainView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.ItemFilterConfirm, self.onSelectFilter, self)
  
  function self.onContainerChanged(container, dirty)
    if dirty.professionList or dirty.aoyiSkillInfoMap then
      self:refreshSkillLoop()
    end
  end
  
  Z.ContainerMgr.CharSerialize.professionList.Watcher:RegWatcher(self.onContainerChanged)
  
  function self.onSlotChange(container, dirty)
    if dirty.slots then
      self:refreshSkillEquipSetting()
      self:refreshSkillLoop()
    end
  end
  
  Z.ContainerMgr.CharSerialize.slots.Watcher:RegWatcher(self.onSlotChange)
end

function Weapon_skill_mainView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.ItemFilterConfirm, self.onSelectFilter, self)
  Z.ContainerMgr.CharSerialize.professionList.Watcher:UnregWatcher(self.onContainerChanged)
  Z.ContainerMgr.CharSerialize.slots.Watcher:UnregWatcher(self.onSlotChange)
  self.onContainerChanged = nil
  self.onSlotChange = nil
end

function Weapon_skill_mainView:onSkillTypeSelect()
  self:closeEquipHideEff()
  self:HideAllTipsSubView()
  self.commonVM_.SetLabText(self.uiBinder.lab_title, {
    E.FunctionID.WeaponSkill,
    self.subFuncIdDict_[self.SelectSkillType]
  })
  self:clearSkillItemSelect()
  self:refreshSkillLoop()
  self:refreshSkillEquipLab()
end

function Weapon_skill_mainView:refreshSkillEquipLab()
end

function Weapon_skill_mainView:refreshSkillLoop()
  self:removeSkillRed()
  for _, value in pairs(self.skillUnitNames_) do
    self:RemoveUiUnit(value)
  end
  self.skillUnitNames_ = {}
  self.skillTabDatas_ = {}
  self.skillUnits_ = {}
  if self.SelectSkillType == E.SkillType.WeaponSkill then
    self:refreshNormalSkill()
    Z.RedPointMgr.LoadRedDotItem(E.RedType.SkillEquipBtn, self, self.uiBinder.btn_assemble.transform)
    Z.RedPointMgr.RemoveNodeItem(E.RedType.ResonanceSkillEquipBtn, self)
  elseif self.SelectSkillType == E.SkillType.MysteriesSkill then
    self:refreshAoyiSkill()
    Z.RedPointMgr.LoadRedDotItem(E.RedType.ResonanceSkillEquipBtn, self, self.uiBinder.btn_assemble.transform)
    Z.RedPointMgr.RemoveNodeItem(E.RedType.SkillEquipBtn, self)
  end
  self:refreshSlotRedDot()
  self:checkSkillUnitState()
end

function Weapon_skill_mainView:refreshSkillUnit(data, unit)
  if data == nil then
    unit.Ref:SetVisible(unit.root, false)
    return
  end
  local repalceSkillId = self.weaponSkillVm_:GetReplaceSkillId(data.skillId)
  local replaceSkillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(repalceSkillId)
  if replaceSkillRow then
    unit.img_icon:SetImage(replaceSkillRow.Icon)
    unit.lab_skill.text = Z.RichTextHelper.ApplyStyleTag(replaceSkillRow.Name, E.TextStyleTag.Lab_num_black)
  end
  unit.Ref:SetVisible(unit.root, true)
  local remouldNodeId = self.weaponSkillVm_:GetSkillRemouldRedId(data.skillId)
  local upNodeId = self.weaponSkillVm_:GetSkillUpRedId(data.skillId)
  local unlockNodeId = self.weaponSkillVm_:GetSkillUnlockRedId(data.skillId)
  local equipNodeId = self.weaponSkillVm_:GetSkillEquipRedId(data.skillId)
  if self.EquipModel then
    Z.RedPointMgr.LoadRedDotItem(equipNodeId, self, unit.red_root.transform)
  else
    Z.RedPointMgr.LoadRedDotItem(upNodeId, self, unit.red_root.transform)
    Z.RedPointMgr.LoadRedDotItem(remouldNodeId, self, unit.red_root.transform)
    Z.RedPointMgr.LoadRedDotItem(unlockNodeId, self, unit.red_root.transform)
  end
  unit.Ref:SetVisible(unit.img_on, data.skillId == self.SelectSkillId)
  if data.skillId == self.SelectSkillId then
    self:ChangeSelectState(data.skillId, unit, false)
  end
  local isUnlock = self.weaponSkillVm_:CheckSkillUnlock(data.skillId)
  local isHadEquip = self.weaponSkillVm_:CheckSkillEquip(data.skillId)
  unit.Ref:SetVisible(unit.lab_lock, false)
  if not isUnlock then
    unit.lab_skill.text = Z.RichTextHelper.ApplyStyleTag(replaceSkillRow.Name, E.TextStyleTag.SkillUnlock)
    local upgradeId = self.weaponSkillVm_:GetSkillUpgradeId(data.skillId)
    local skillLevelData = self.weaponSkillVm_:GetLevelUpSkilllRow(upgradeId, 1)
    unit.Ref:SetVisible(unit.lab_lock, true)
    unit.lab_lock.text = Z.RichTextHelper.ApplyStyleTag(Lang("CanUnlock"), E.TextStyleTag.SkillUnlock)
    for _, value in ipairs(skillLevelData.UnlockConditions) do
      if not Z.ConditionHelper.CheckSingleCondition(value[1], false, value[2]) then
        local bResult, unlockDesc, progress = Z.ConditionHelper.GetSingleConditionDesc(value[1], value[2])
        if value[1] == E.ConditionType.Level then
          unlockDesc = Lang("Grade", {
            val = value[2]
          })
        elseif value[1] == E.ConditionType.OpenServerDay then
          unlockDesc = Lang("DaysAfter", {val = progress})
        end
        unlockDesc = Z.RichTextHelper.ApplyStyleTag(unlockDesc, E.TextStyleTag.SkillUnlock)
        unit.lab_lock.text = unlockDesc
        break
      end
    end
  end
  unit.Ref:SetVisible(unit.img_mark, not isUnlock)
  unit.Ref:SetVisible(unit.img_lock, not isUnlock)
  unit.Ref:SetVisible(unit.img_assemble, isHadEquip)
  local level = self.weaponVm_.GetShowSkillLevel(nil, data.skillId)
  local remodelLevel = self.weaponSkillVm_:GetSkillRemodelLevel(data.skillId)
  unit.Ref:SetVisible(unit.img_label, isUnlock)
  unit.lab_grade.text = Lang("Grade", {val = level})
  unit.lab_order.text = remodelLevel
  if Z.IsPCUI and isHadEquip then
    local iconName, path = self.weaponSkillVm_:GetKeyCodeNameBySkillId(data.skillId)
    unit.Ref:SetVisible(unit.img_pc, true)
    if path then
      unit.Ref:SetVisible(unit.img_pc_icon, true)
      unit.img_pc_icon:SetImage(path)
    else
      unit.Ref:SetVisible(unit.img_pc_icon, false)
    end
    unit.lab_figure.text = iconName
  else
    unit.Ref:SetVisible(unit.img_pc, false)
  end
  if self.SelectSkillType == E.SkillType.SupportSkill then
    unit.lab_name.text = Lang("ShowSkillType_" .. data.type)
  end
  self.skillUnits_[data.skillId] = unit
  self:AddClick(unit.btn, function()
    self:OnItemClick(data.skillId, unit)
  end)
  unit.event_trigger:ClearAll()
  self:initDraw(unit, data.skillId)
end

function Weapon_skill_mainView:removeSkillRed()
  if not self.skillUnits_ then
    return
  end
  for skillId, unit in pairs(self.skillUnits_) do
    Z.RedPointMgr.RemoveChildernNodeItem(unit.red_root.transform, self)
  end
end

function Weapon_skill_mainView:refreshSkillEquipReddot()
  if self.SelectSkillType == E.SkillType.WeaponSkill then
    for skillId, unit in pairs(self.skillUnits_) do
      local remouldNodeId = self.weaponSkillVm_:GetSkillRemouldRedId(skillId)
      local upNodeId = self.weaponSkillVm_:GetSkillUpRedId(skillId)
      local unlockNodeId = self.weaponSkillVm_:GetSkillUnlockRedId(skillId)
      local equipNodeId = self.weaponSkillVm_:GetSkillEquipRedId(skillId)
      if self.EquipModel then
        Z.RedPointMgr.LoadRedDotItem(equipNodeId, self, unit.red_root.transform)
        Z.RedPointMgr.RemoveNodeItem(upNodeId, self)
        Z.RedPointMgr.RemoveNodeItem(remouldNodeId, self)
        Z.RedPointMgr.RemoveNodeItem(unlockNodeId, self)
      else
        Z.RedPointMgr.LoadRedDotItem(upNodeId, self, unit.red_root.transform)
        Z.RedPointMgr.LoadRedDotItem(remouldNodeId, self, unit.red_root.transform)
        Z.RedPointMgr.LoadRedDotItem(unlockNodeId, self, unit.red_root.transform)
        Z.RedPointMgr.RemoveNodeItem(equipNodeId, self)
      end
    end
  else
    Z.EventMgr:Dispatch(Z.ConstValue.Weapon.OnSkillEquipRedChange)
  end
end

function Weapon_skill_mainView:initDraw(skillUnit, skillId, canUnload)
  local unlock = self.weaponSkillVm_:CheckSkillUnlock(skillId)
  local canEquip = self.weaponSkillVm_:CheckSkillCanEquip(skillId)
  skillUnit.event_trigger.onBeginDrag:AddListener(function()
    if not unlock then
      Z.TipsVM.ShowTips(1045003)
      return
    end
    if not canEquip then
      Z.TipsVM.ShowTips(1045002)
      return
    end
    self:OnItemBeginDrag(skillId)
    self:ChangeSelectState(skillId, skillUnit, false)
  end)
  skillUnit.event_trigger.onDrag:AddListener(function(go, pointerData)
    self:OnItemDrag(skillId, pointerData)
  end)
  skillUnit.event_trigger.onEndDrag:AddListener(function()
    if not unlock then
      return
    end
    if not canEquip then
      return
    end
    self:OnItemEndDrag(canUnload)
  end)
end

function Weapon_skill_mainView:OnItemClick(skillId, item)
  if self.EquipModel then
    local isUnlock = self.weaponSkillVm_:CheckSkillUnlock(skillId)
    local isCanEquip = self.weaponSkillVm_:CheckSkillCanEquip(skillId)
    if not isUnlock then
      Z.TipsVM.ShowTips(1045003)
      return
    end
    if not isCanEquip then
      Z.TipsVM.ShowTips(1045002)
      return
    end
  end
  self:ChangeSelectState(skillId, item, true)
end

function Weapon_skill_mainView:ChangeSelectState(skillId, item, isInvoke)
  if self.selectItem_ then
    self.selectItem_.Ref:SetVisible(self.selectItem_.img_on, false)
  end
  if item then
    item.Ref:SetVisible(item.img_on, true)
  end
  self.selectItem_ = item
  if isInvoke then
    self:onSkillItemSelect(skillId)
  end
end

function Weapon_skill_mainView:OnItemBeginDrag(skillId)
  self.EquipModel = true
  self:openEqiupModel()
  self:checkSkillUnitState()
  self:onSkillItemSelect(skillId, true)
  local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  self.uiBinder.copy_skill_item.img_icon:SetImage(skillRow.Icon)
  self.uiBinder.Ref:SetVisible(self.uiBinder.copy_skill_item_trans, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.mask, true)
end

function Weapon_skill_mainView:OnItemDrag(skillId, pointerData)
  if not self.EquipModel then
    return
  end
  local trans_ = self.uiBinder.copy_skill_item_trans
  local _, uiPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(trans_, pointerData.position, nil)
  local posX, posY = trans_:GetAnchorPosition(nil, nil)
  posX = posX + uiPos.x
  posY = posY + uiPos.y
  trans_:SetAnchorPosition(posX, posY)
end

function Weapon_skill_mainView:OnItemEndDrag(canUnload)
  self.uiBinder.Ref:SetVisible(self.uiBinder.mask, false)
  if not self.EquipModel then
    return
  end
  local minDis = maxSkillDistance
  local minDisSlotId = -1
  self.isEquip_ = false
  for slotId, _ in pairs(self.skillEquip_) do
    local trans = self.skillEquipCheckNode_[slotId]
    if trans then
      local distance = Panda.LuaAsyncBridge.GetScreenDistance(trans.position, self.uiBinder.copy_skill_item_trans.position)
      if minDis > distance then
        minDis = distance
        minDisSlotId = slotId
      end
    end
  end
  if minDisSlotId ~= -1 then
    if self.skillEquip_[minDisSlotId] then
      Z.CoroUtil.create_coro_xpcall(function()
        self.weaponSkillVm_:AsyncSkillInstall(minDisSlotId, self.SelectSkillId, self.cancelSource:CreateToken())
        self:onShowOrHideEff(minDisSlotId)
      end)()
    end
  elseif self.weaponSkillVm_:CheckSkillEquip(self.SelectSkillId) and canUnload then
    Z.CoroUtil.create_coro_xpcall(function()
      local slotId = self.weaponSkillVm_:GetSlotIdBySkillId(self.SelectSkillId)
      self.weaponSkillVm_:AsyncSkillInstall(slotId, 0, self.cancelSource:CreateToken())
    end)()
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.copy_skill_item_trans, false)
end

function Weapon_skill_mainView:onShowOrHideEff(SlotId)
  for index, value in pairs(self.skillEquipUnits_) do
    value.node_eff_show:SetEffectGoVisible(false)
    if self.skillShowEffEquip_[index] then
      value.node_eff_loop:SetEffectGoVisible(false)
    end
  end
  for index, value in pairs(self.skillEquipUnits_) do
    if index == SlotId then
      self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(value.node_eff_show)
      value.node_eff_show:SetEffectGoVisible(true)
    end
  end
end

function Weapon_skill_mainView:refreshNormalSkillUnit(skillArray, index, showTitle)
  local path = self.uiBinder.prefab_cache:GetString("skill_unit_tpl_1")
  local parent = self.uiBinder.node_content_1
  local data = {}
  local count = 0
  for index_, value in ipairs(skillArray) do
    count = count + 1
    if self.SelectSkillType == E.SkillType.SupportSkill then
      table.insert(data, value)
    else
      local tmp = {}
      tmp.skillId = value
      table.insert(data, tmp)
    end
    if index_ % 3 == 0 or index_ == #skillArray then
      local name = self.SelectSkillType .. "skill_tpl_" .. index .. "_" .. index_
      local unit = self:AsyncLoadUiUnit(path, name, parent)
      table.insert(self.skillUnitNames_, name)
      self:refreshSkillUnit(data[1], unit.weapon_skill_1)
      self:refreshSkillUnit(data[2], unit.weapon_skill_2)
      self:refreshSkillUnit(data[3], unit.weapon_skill_3)
      local diff = (index - 1) * index_
      Z.GuideMgr:SetSteerIdByComp(unit.weapon_skill_1.uisteer, E.DynamicSteerType.ChooseSkillIndex, 1 + diff)
      Z.GuideMgr:SetSteerIdByComp(unit.weapon_skill_2.uisteer, E.DynamicSteerType.ChooseSkillIndex, 2 + diff)
      Z.GuideMgr:SetSteerIdByComp(unit.weapon_skill_3.uisteer, E.DynamicSteerType.ChooseSkillIndex, 3 + diff)
      showTitle = showTitle and index_ / 3 == 1
      unit.Ref:SetVisible(unit.skill_type_root, showTitle)
      unit.root_layout_rebulider:ForceRebuildLayoutImmediate()
      if self.skillTabDatas_[index] == nil then
        self.skillTabDatas_[index] = {}
        self.skillTabDatas_[index].count = 0
      end
      self.skillTabDatas_[index].count = self.skillTabDatas_[index].count + 1
      data = {}
    end
  end
end

function Weapon_skill_mainView:refreshNormalSkill()
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_01, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_grid_view, false)
  local weaponSystem = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.professionId_)
  local data = {}
  if self.typeSelectSkillIds_[E.SkillType.WeaponSkill] == nil then
    self.typeSelectSkillIds_[E.SkillType.WeaponSkill] = self.weaponSkillVm_:GetSkillBySlot(tonumber(E.SkillSlot.SkillSlot_1))
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local lockSkill = {}
    for _, value in ipairs(weaponSystem.NormalAttackSkill) do
      table.insert(lockSkill, value)
    end
    for _, value in ipairs(weaponSystem.SpecialSkill) do
      table.insert(lockSkill, value)
    end
    for _, value in ipairs(weaponSystem.UltimateSkill) do
      table.insert(lockSkill, value)
    end
    table.insert(data, lockSkill)
    table.insert(data, weaponSystem.NormalSkill)
    local isInSkillArray = false
    for _, skillArray in ipairs(data) do
      for __, skillId in ipairs(skillArray) do
        if skillId == self.SelectSkillId then
          isInSkillArray = true
        end
      end
    end
    if isInSkillArray then
      self:onSkillItemSelect(self.SelectSkillId)
    else
      self:onSkillItemSelect(self.typeSelectSkillIds_[E.SkillType.WeaponSkill])
    end
    for index, value in ipairs(data) do
      self:refreshNormalSkillUnit(value, index, index == #data)
    end
    self.skillTabDatas_[1].lab = Lang("fixed_skill")
    self.skillTabDatas_[2].lab = Lang("weapon_skill")
    self.skillTabDatas_[1].img = "ui/atlas/weap_skill/weapo_skill_tab_on"
    self.skillTabDatas_[2].img = "ui/atlas/weap_skill/weapo_skill_fixed_tab_on"
    self.uiBinder.node_content_1_rebuild:ForceRebuildLayoutImmediate()
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_01, true)
    self.uiBinder.loop_item_01_scroll.verticalNormalizedPosition = 1
  end)()
end

function Weapon_skill_mainView:refreshAoyiSkill()
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_01, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_grid_view, true)
  self:refreshLoopGridView()
end

function Weapon_skill_mainView:openEqiupModel()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_assemble, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_assemble_exit, true)
  self.EquipModel = true
  self.uiBinder.lab_name.text = Lang("ExitAssemble")
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_right_trans, true)
  self:HideAllTipsSubView()
  self:refreshSkillEquipInfo()
  self:refreshSkillEquipReddot()
end

function Weapon_skill_mainView:closeEquipModel()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_assemble, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_assemble_exit, false)
  self.EquipModel = false
  self.uiBinder.lab_name.text = Lang("Assemble")
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_right_trans, false)
  for index, value in pairs(self.skillEquipUnits_) do
    value.Ref:SetVisible(value.img_on, false)
    value.node_eff_loop:SetEffectGoVisible(false)
    value.node_eff_show:SetEffectGoVisible(false)
  end
  if self.SelectSkillId then
    self:ShowTipsSubView(self.SelectSkillId, self.professionId_)
  end
  self:refreshSkillEquipReddot()
end

function Weapon_skill_mainView:closeEquipHideEff()
  for index, value in pairs(self.skillEquipUnits_) do
    value.node_eff_loop:SetEffectGoVisible(false)
    value.node_eff_show:SetEffectGoVisible(false)
  end
end

function Weapon_skill_mainView:checkSkillUnitState()
  if self.EquipModel then
    for skillId, unit in pairs(self.skillUnits_) do
      local unlock = self.weaponSkillVm_:CheckSkillUnlock(skillId)
      local canEquip = self.weaponSkillVm_:CheckSkillCanEquip(skillId)
      if not unlock or not canEquip then
        unit.Ref:SetVisible(unit.img_mark, true)
        unit.img_icon:SetColor((Color.New(1, 1, 1, 0.7)))
        unit.img_lock:SetColor((Color.New(1, 1, 1, 0.7)))
      else
        unit.Ref:SetVisible(unit.img_mark, false)
        unit.img_icon:SetColor((Color.New(1, 1, 1, 1)))
        unit.img_lock:SetColor((Color.New(1, 1, 1, 1)))
      end
    end
  else
    for skillId, unit in pairs(self.skillUnits_) do
      local unlock = self.weaponSkillVm_:CheckSkillUnlock(skillId)
      unit.Ref:SetVisible(unit.img_mark, not unlock)
      if not unlock then
        unit.img_icon:SetColor((Color.New(1, 1, 1, 0.7)))
        unit.img_lock:SetColor((Color.New(1, 1, 1, 0.7)))
      else
        unit.img_icon:SetColor((Color.New(1, 1, 1, 1)))
        unit.img_lock:SetColor((Color.New(1, 1, 1, 1)))
      end
    end
  end
end

function Weapon_skill_mainView:refreshSkillEquipInfo()
  self.skillEquip_ = {}
  self.skillShowEffEquip_ = {}
  if self.SelectSkillId then
    local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.SelectSkillId)
    if skillRow then
      for _, value in pairs(skillRow.SlotPositionId) do
        if value ~= 0 then
          local slotRow = Z.TableMgr.GetTable("SkillSlotPositionTableMgr").GetRow(value)
          if slotRow.IsReplace then
            self.skillEquip_[value] = true
            self.skillShowEffEquip_[value] = true
            local slotUnlock = true
            if slotRow and slotRow.UnlockCondition then
              slotUnlock = Z.ConditionHelper.CheckCondition(slotRow.UnlockCondition)
              if not slotUnlock then
                self.skillShowEffEquip_[value] = false
              end
            end
          end
        end
      end
      for index, value in pairs(self.skillDepth_) do
        if self.skillEquip_[index] then
          value:UpdateDepth(self.depth_ + 1, true)
        else
          value:UpdateDepth(self.depth_ - 1, true)
        end
      end
      for index, value in pairs(self.skillEquipUnits_) do
        value.Ref:SetVisible(value.img_on, self.skillEquip_[index])
      end
      for index, value in pairs(self.skillEquipUnits_) do
        local effectVisible = self.skillShowEffEquip_[index]
        value.node_eff_loop:SetEffectGoVisible(effectVisible or false)
        if effectVisible then
          self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(value.node_eff_loop)
        end
      end
    end
  else
    for index, value in pairs(self.skillDepth_) do
      value:UpdateDepth(self.depth_ - 1, true)
    end
    for index, value in pairs(self.skillEquipUnits_) do
      value.Ref:SetVisible(value.img_on, false)
    end
  end
end

function Weapon_skill_mainView:onSkillItemSelect(skillId, ingoreSetSkillId)
  if skillId == nil or skillId == 0 then
    return
  end
  self.SelectSkillId = skillId
  if not ingoreSetSkillId then
    self.typeSelectSkillIds_[self.SelectSkillType] = skillId
  end
  if self.EquipModel then
    self:refreshSkillEquipInfo()
    self:HideAllTipsSubView()
  else
    self:ShowTipsSubView(skillId, self.professionId_)
  end
end

function Weapon_skill_mainView:clearSkillItemSelect()
  if not self.clearDirtyTag_ then
    self.clearDirtyTag_ = true
  else
    self:ChangeSelectState(nil, nil, false)
    self.SelectSkillId = nil
    self:refreshSkillEquipInfo()
  end
end

function Weapon_skill_mainView:HideAllTipsSubView()
  self.weaponSkillLevelUp_:DeActive()
  self.weaponResonanceSkillTips_:DeActive()
end

function Weapon_skill_mainView:ShowTipsSubView(skillId, professionId)
  local viewData = {}
  viewData.skillId = skillId
  viewData.professionId = professionId
  viewData.skillType = self.SelectSkillType
  if self.SelectSkillType == E.SkillType.MysteriesSkill then
    self.weaponSkillLevelUp_:DeActive()
    self.weaponResonanceSkillTips_:Active(viewData, self.uiBinder.skill_sub_root)
  else
    self.weaponResonanceSkillTips_:DeActive()
    self.weaponSkillLevelUp_:Active(viewData, self.uiBinder.skill_sub_root)
  end
end

function Weapon_skill_mainView:OnDeActive()
  self:HideAllTipsSubView()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:unBindEvents()
  self:unInitLoopGridView()
  self:unInitFilter()
  self:unLoadRedDotItem()
  self.skillShowEffEquip_ = {}
  self.skillUnits_ = {}
  self.selectItem_ = nil
  self.SelectSkillId = nil
end

function Weapon_skill_mainView:OnDestory()
end

function Weapon_skill_mainView:OnRefresh()
end

function Weapon_skill_mainView:loadRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.WeaponResonanceTab, self, self.uiBinder.tab_02.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.NormalSkillTab, self, self.uiBinder.tab_01.Trans)
end

function Weapon_skill_mainView:unLoadRedDotItem()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.WeaponResonanceTab, self)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.SkillEquipBtn, self)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.ResonanceSkillEquipBtn, self)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.NormalSkillTab, self)
end

function Weapon_skill_mainView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Weapon_skill_mainView
