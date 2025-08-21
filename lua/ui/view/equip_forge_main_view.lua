local UI = Z.UI
local super = require("ui.ui_view_base")
local Equip_forge_mainView = class("Equip_forge_mainView", super)
local loopListView = require("ui.component.loop_list_view")
local expendLoopItem = require("ui.component.equip.equip_forge_expend_loop_item")
local leftLoopItem = require("ui.component.equip.equip_forge_loop_item")
local itemBinder = require("common.item_binder")
local equip_forge_left_sub_view = require("ui.view.equip_forge_left_sub_view")
local common_filter_helper = require("common.common_filter_helper")

function Equip_forge_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "equip_forge_main")
  self.equipCfgData_ = Z.DataMgr.Get("equip_config_data")
  self.equipAttrParseVM_ = Z.VMMgr.GetVM("equip_attr_parse")
  self.equipSystemVM_ = Z.VMMgr.GetVM("equip_system")
  self.equipForgeVM_ = Z.VMMgr.GetVM("equip_forge")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.equip_forge_left_sub_view_ = equip_forge_left_sub_view.new(self)
  self.filterHelper_ = common_filter_helper.new(self)
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.talentSkillVm_ = Z.VMMgr.GetVM("talent_skill")
end

function Equip_forge_mainView:initBinders()
  self.prefabCache_ = self.uiBinder.cache
  self.iconTitleImg_ = self.uiBinder.img_icon
  self.closeBtn_ = self.uiBinder.btn
  self.askBtn_ = self.uiBinder.btn_ask
  self.titleLab_ = self.uiBinder.lab_title
  self.emptyLab_ = self.uiBinder.lab_empty
  self.emptyGetNode_ = self.uiBinder.btn_get
  self.siftNode_ = self.uiBinder.node_sift
  self.infoNode_ = self.uiBinder.node_info
  self.leftNode_ = self.uiBinder.node_left
  self.leftItemList_ = self.leftNode_.scrollview_left
  self.sortDpd_ = self.leftNode_.binder_sort_rule.dpd
  self.filterBtn_ = self.leftNode_.btn_filter
  self.filterS_ = self.leftNode_.node_filter_s
  self.middleNode_ = self.uiBinder.node_middle
  self.nameLab_ = self.middleNode_.lab_name
  self.gsLab_ = self.middleNode_.lab_gs
  self.perfectLab_ = self.middleNode_.lab_perfect
  self.talentStageDpd_ = self.middleNode_.node_dpd.dpd
  self.basicsItemNode_ = self.middleNode_.node_basics_item
  self.specialItemNode_ = self.middleNode_.node_special_item
  self.describeItemNode_ = self.middleNode_.node_equip_describe
  self.desLab_ = self.middleNode_.lab_prompt
  self.rightNode_ = self.uiBinder.node_right
  self.gsBgNode_ = self.rightNode_.img_gs_bg
  self.oldGsLab_ = self.rightNode_.lab_gs_old
  self.newGsLab_ = self.rightNode_.lab_gs_new
  self.haveNode_ = self.rightNode_.node_have
  self.conditionNode_ = self.rightNode_.layout_condition
  self.rightTitleLab_ = self.rightNode_.lab_right_title
  self.makeNode_ = self.rightNode_.node_make_item
  self.makeItemList_ = self.rightNode_.scrollview_make_item
  self.makeBinderItem_ = self.rightNode_.binder_item
  self.makeAddImg_ = self.rightNode_.img_add
  self.forgeLab_ = self.rightNode_.lab_digit
  self.forgeBtn_ = self.rightNode_.btn_forge
  self.breakItemList_ = self.rightNode_.scrollview_break_item
  self.addItemBtn_ = self.rightNode_.btn_add
  self.bottomNode_ = self.rightNode_.img_bottom_bg
  self.haveLab_ = self.rightNode_.lab_have
  self.expendListView1_ = loopListView.new(self, self.breakItemList_, expendLoopItem, "com_item_square_1_8")
  self.expendListView1_:Init({})
  self.expendListView2_ = loopListView.new(self, self.makeItemList_, expendLoopItem, "com_item_square_2_8_pc")
  self.expendListView2_:Init({})
  self.leftListView_ = loopListView.new(self, self.leftItemList_, leftLoopItem, "equip_left_item_tpl")
  self.leftListView_:Init({})
  self.itemClass_ = itemBinder.new(self)
  self.itemClass_:Init({
    uiBinder = self.makeBinderItem_
  })
  local filterTypes = {
    E.CommonFilterType.SeasonEquip,
    E.CommonFilterType.EquipGs,
    E.CommonFilterType.UnlockProfession
  }
  self.filterHelper_:Init(Lang("EquipFilterTitle"), filterTypes, self.siftNode_.transform, self.filterS_.transform, function(filterRes)
    self.filterRes_ = filterRes
    self:filterItemList()
  end)
end

function Equip_forge_mainView:initBtns()
  self:AddClick(self.emptyGetNode_.btn, function()
    self.equipForgeVM_.OpenEquipMakeView()
  end)
  self:AddClick(self.closeBtn_, function()
    self.equipForgeVM_.CloseEquipForgeView()
  end)
  self:AddClick(self.askBtn_, function()
    local helpId = self.isMakeState_ and 400107 or 400106
    self.helpsysVM_.OpenFullScreenTipsView(helpId)
  end)
  self:AddClick(self.filterBtn_, function()
    local viewData = {
      filterFunc = function(filterRes)
        self.filterRes_ = filterRes
      end,
      closeFunc = function()
        self.filterRes_ = {}
      end
    }
    self.filterHelper_:ActiveFilterSub(viewData)
  end)
  self:AddAsyncClick(self.forgeBtn_, function()
    if self.sourceTipsId_ then
      Z.TipsVM.CloseItemTipsView(self.sourceTipsId_)
      self.sourceTipsId_ = nil
    end
    local func = function()
      if self.isMakeState_ then
        if not Z.ConditionHelper.CheckCondition(self.selectedCreateItem_.CreateCondition, true) then
          return
        end
        local consumeuUid
        if self.selectedCreateItem_.EquipNameGroupId ~= 0 then
          if not self.consumeItem_ then
            return
          end
          consumeuUid = self.consumeItem_.Item.uuid
        end
        for index, value in ipairs(self.selectedCreateItem_.ConsumableItems) do
          if not self:checkItemCount(value[1], value[2]) then
            return
          end
        end
        local isSucceed = self.equipForgeVM_.AsyncEquipCreate(self.selectedCreateItem_.Id, consumeuUid, self.cancelSource:CreateToken())
        if isSucceed then
          self:refreshMiddleInfo()
          self:refreshRightInfo()
        end
      else
        if not Z.ConditionHelper.CheckCondition(self.breakThroughRow_.Condition, true) then
          return
        end
        for index, value in ipairs(self.breakThroughRow_.Consume) do
          if not self:checkItemCount(value[1], value[2]) then
            return
          end
        end
        local isSucceed = self.equipForgeVM_.AsyncEquipBreach(self.selectedCreateItem_.Item.uuid, self.cancelSource:CreateToken())
        if isSucceed then
          self.itemList_ = self.equipSystemVM_.GetEquipItemsByConfigIdMap(self.equipCfgData_.EquipBreakConfigIdMap, nil, true)
          self:filterItemList()
        end
      end
    end
    local configId = self.isMakeState_ and self.selectedCreateItem_.Id or self.selectedCreateItem_.ConfigId
    local weaponRow = Z.TableMgr.GetRow("EquipWeaponTableMgr", configId)
    local curProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
    if weaponRow and weaponRow.ProfessionId ~= curProfessionId then
      local desc = self.isMakeState_ and Lang("EquipCreateJobTips") or Lang("EquipBreakThroughJobTips")
      Z.DialogViewDataMgr:OpenNormalDialog(desc, function()
        func()
      end)
    else
      func()
    end
  end)
  self:AddClick(self.addItemBtn_, function()
    local map = self.equipSystemVM_.GetEquipConfigMapByGroupId(self.selectedCreateItem_.EquipNameGroupId)
    local items = self.equipSystemVM_.GetEquipItemsByConfigIdMap(map, nil, true)
    local showItems = {}
    local showIndex = 1
    for i = #items, 1, -1 do
      local itemData = items[i]
      local equipRow = Z.TableMgr.GetRow("EquipTableMgr", itemData.ConfigId)
      if equipRow and itemData.Item.equipAttr.perfectionValue >= self.selectedCreateItem_.PerfectCondition then
        showItems[showIndex] = itemData
        showIndex = showIndex + 1
      end
    end
    if showIndex == 1 then
      self.equip_forge_left_sub_view_:Active({
        items = table.zkeys(map),
        tipsRoot = self.uiBinder.node_middle.Trans,
        title = "",
        labInfo = "",
        isPreview = true,
        perfectValue = self.selectedCreateItem_.PerfectCondition
      }, self.uiBinder.Trans)
    else
      self.equip_forge_left_sub_view_:Active({
        items = showItems,
        tipsRoot = self.uiBinder.node_middle.Trans,
        title = "",
        labInfo = "",
        isPreview = false
      }, self.uiBinder.Trans)
    end
  end)
  self:AddClick(self.makeBinderItem_.btn_minus, function()
    self.makeBinderItem_.Ref.UIComp:SetVisible(false)
    self.rightNode_.Ref:SetVisible(self.addItemBtn_, true)
    self.consumeItem_ = nil
  end)
  self.uiBinder.raying_drag.onDrag:AddListener(function(go, eventData)
    for index, model in pairs(self.weaponModel_) do
      self:onModelDrag(model, eventData)
    end
  end)
  Z.EventMgr:Add(Z.ConstValue.Equip.SelectedRecastItem, self.selectedConsumeItem, self)
end

function Equip_forge_mainView:checkItemCount(configId, expendCount)
  local count = self.itemsVm_.GetItemTotalCount(configId)
  if expendCount > count then
    local itemRow = Z.TableMgr.GetRow("ItemTableMgr", configId)
    if itemRow then
      local tipsId = self.isMakeState_ and 150035 or 150034
      Z.TipsVM.ShowTips(tipsId, {
        val = itemRow.Name
      })
    end
    self.sourceTipsId_ = Z.TipsVM.OpenSourceTips(configId, self.forgeBtn_.transform)
    return false
  end
  return true
end

function Equip_forge_mainView:initDatas()
  self.isMakeState_ = tonumber(self.viewData) == 1
  self.forgeLab_.text = self.isMakeState_ and Lang("CraftWeapons") or Lang("Breach")
  self.curTalentStageId = 0
  self.attrUnits_ = {}
  self.attrTokens_ = {}
  self.weaponModel_ = {}
  self.itemList_ = self.isMakeState_ and self.equipCfgData_.EquipCreateTableRows or self.equipSystemVM_.GetEquipItemsByConfigIdMap(self.equipCfgData_.EquipBreakConfigIdMap, nil, true)
end

function Equip_forge_mainView:initUi()
  self.rightNode_.Ref:SetVisible(self.gsBgNode_, not self.isMakeState_)
  self.rightNode_.Ref:SetVisible(self.makeNode_, self.isMakeState_)
  self.rightNode_.Ref:SetVisible(self.breakItemList_, not self.isMakeState_)
  self.haveLab_.text = self.isMakeState_ and Lang("EquipHave") or Lang("EquipBreakMaxLevel")
  local functionId = self.isMakeState_ and E.EquipFuncId.EquipMake or E.EquipFuncId.EquipBreak
  local functionRow = Z.TableMgr.GetRow("FunctionTableMgr", functionId)
  if functionRow then
    self.uiBinder.lab_title.text = functionRow.Name
    self.iconTitleImg_:SetImage(functionRow.Icon)
  end
  local options_ = {}
  self.sortRuleTypeNames_ = {
    E.EquipItemSortType.GS,
    E.EquipItemSortType.Season
  }
  self.equipSortTyp_ = E.EquipItemSortType.GS
  options_ = {
    [1] = Lang("GsOrder")
  }
  self.sortDpd_:ClearAll()
  self.sortDpd_:AddListener(function(index)
    self.equipSortTyp_ = self.sortRuleTypeNames_[index + 1]
    self:refreshMiddleInfo()
  end, true)
  self.sortDpd_:AddOptions(options_)
end

function Equip_forge_mainView:GetViewState()
  return self.isMakeState_
end

function Equip_forge_mainView:refreshLeftList()
  self:sortItemList()
  self.leftListView_:ClearAllSelect()
  self.leftListView_:RefreshListView(self.showItemList_)
  local isEmpty = #self.showItemList_ == 0
  self.uiBinder.Ref:SetVisible(self.infoNode_, not isEmpty)
  self.uiBinder.Ref:SetVisible(self.emptyLab_, isEmpty)
  self.emptyGetNode_.Ref.UIComp:SetVisible(isEmpty and not self.isMakeState_)
  if #self.itemList_ == 0 then
    self.emptyLab_.text = self.isMakeState_ and Lang("NoEquipCanCreate") or Lang("NoEquipmentNeedPierce")
  elseif isEmpty then
    self.emptyLab_.text = Lang("NoEquipEligible")
  end
  local selectedIndex = 1
  if self.selectedCreateItem_ then
    for index, value in ipairs(self.showItemList_) do
      local configId = self.isMakeState_ and value.Id or value.ConfigId
      local lastConfigId = self.isMakeState_ and self.selectedCreateItem_.Id or self.selectedCreateItem_.ConfigId
      if lastConfigId == configId then
        selectedIndex = index
        break
      end
    end
  end
  self.leftListView_:SetSelected(selectedIndex)
  self.leftListView_:MovePanelToItemIndex(selectedIndex)
end

function Equip_forge_mainView:getEquipGs(item)
  local breakThroughTime = item.Item.equipAttr.breakThroughTime
  if breakThroughTime == 0 then
    local equipRow = Z.TableMgr.GetRow("EquipTableMgr", item.ConfigId)
    if equipRow then
      return equipRow.EquipGs
    end
  else
    local levels = self.equipCfgData_.EquipBreakIdLevelMap[item.ConfigId]
    if levels then
      local rowId = levels[breakThroughTime]
      if rowId then
        local breakThroughRow = Z.TableMgr.GetRow("EquipBreakThroughTableMgr", rowId)
        if breakThroughRow then
          return breakThroughRow.EquipGs
        end
      end
    end
  end
  return 0
end

function Equip_forge_mainView:filterItemList()
  if self.filterRes_ == nil then
    self.filterRes_ = {}
  end
  local showIndex = 1
  self.showItemList_ = {}
  for index, item in ipairs(self.itemList_) do
    local isShow = true
    local configId = 0
    if self.isMakeState_ then
      configId = item.Id
    else
      configId = item.ConfigId
    end
    local equipRow = Z.TableMgr.GetRow("EquipTableMgr", configId)
    if equipRow then
      if self.filterRes_[E.CommonFilterType.SeasonEquip] then
        for seasonId, value in pairs(self.filterRes_[E.CommonFilterType.SeasonEquip].value) do
          if equipRow.SeasonId ~= seasonId then
            isShow = false
            break
          end
        end
      end
      if isShow and self.filterRes_[E.CommonFilterType.EquipGs] then
        for equipScreenGSIndex, value in pairs(self.filterRes_[E.CommonFilterType.EquipGs].value) do
          local minGs = tonumber(Z.Global.EquipScreenGS[equipScreenGSIndex][1])
          local maxGs = tonumber(Z.Global.EquipScreenGS[equipScreenGSIndex][2])
          local equipGs = equipRow.EquipGs
          if not self.isMakeState_ then
            equipGs = self:getEquipGs(item)
          end
          if minGs > equipGs or maxGs < equipGs then
            isShow = false
            break
          end
        end
      end
      if isShow and self.filterRes_[E.CommonFilterType.UnlockProfession] then
        local equipWeaponTableRow = Z.TableMgr.GetRow("EquipWeaponTableMgr", configId)
        if equipWeaponTableRow then
          for professionId, value in pairs(self.filterRes_[E.CommonFilterType.UnlockProfession].value) do
            if equipWeaponTableRow.ProfessionId ~= professionId then
              isShow = false
              break
            end
          end
        end
      end
      if isShow and self.isMakeState_ and not Z.ConditionHelper.CheckCondition(item.ShowCondition) then
        isShow = false
      end
      if isShow then
        self.showItemList_[showIndex] = item
        showIndex = showIndex + 1
      end
    end
  end
  self:refreshLeftList()
end

function Equip_forge_mainView:sortItemList()
  local curProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  table.sort(self.showItemList_, function(leftRow, rightRow)
    local leftConfigId = self.isMakeState_ and leftRow.Id or leftRow.ConfigId
    local rightConfig = self.isMakeState_ and rightRow.Id or rightRow.ConfigId
    local leftEquipRow = Z.TableMgr.GetRow("EquipTableMgr", leftConfigId)
    local rightEquipRow = Z.TableMgr.GetRow("EquipTableMgr", rightConfig)
    local leftWeaponRow = Z.TableMgr.GetRow("EquipWeaponTableMgr", leftConfigId)
    local rightWeaponRow = Z.TableMgr.GetRow("EquipWeaponTableMgr", rightConfig)
    if not leftEquipRow or not rightEquipRow then
      return false
    end
    if not self.isMakeState_ then
      local leftEquipInfo = self.equipSystemVM_.GetSamePartEquipAttr(leftConfigId)
      local rightEquipInfo = self.equipSystemVM_.GetSamePartEquipAttr(leftConfigId)
      if leftEquipInfo and rightEquipInfo then
        if leftEquipInfo.itemUuid == leftRow.Item.uuid and rightEquipInfo.itemUuid ~= rightRow.Item.uuid then
          return true
        elseif leftEquipInfo.itemUuid ~= leftRow.Item.uuid and rightEquipInfo.itemUuid == rightRow.Item.uuid then
          return false
        end
      end
    end
    if leftWeaponRow and rightWeaponRow then
      if leftWeaponRow.ProfessionId == curProfessionId and rightWeaponRow.ProfessionId ~= curProfessionId then
        return true
      elseif leftWeaponRow.ProfessionId ~= curProfessionId and rightWeaponRow.ProfessionId == curProfessionId then
        return false
      end
    end
    if leftEquipRow.EquipGs > rightEquipRow.EquipGs then
      return true
    elseif leftEquipRow.EquipGs < rightEquipRow.EquipGs then
      return false
    end
    if leftEquipRow.SeasonId > rightEquipRow.SeasonId then
      return true
    elseif leftEquipRow.EquipGs < rightEquipRow.EquipGs then
      return false
    end
    return false
  end)
end

function Equip_forge_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UnrealSceneMgr:SwitchGroupReflection(true)
  self:OnOpenAnimShow()
  self:initBinders()
  self:initBtns()
  self:initDatas()
  self:initUi()
end

function Equip_forge_mainView:OnSelectedCreateItem(selectedData)
  self.selectedCreateItem_ = selectedData
  if self.isMakeState_ then
    self.makeBinderItem_.Ref.UIComp:SetVisible(false)
    self.rightNode_.Ref:SetVisible(self.addItemBtn_, true)
    self.consumeItem_ = nil
    self.forgeBtn_.IsDisabled = not Z.ConditionHelper.CheckCondition(self.selectedCreateItem_.CreateCondition)
    self.uiBinder.node_right.lab_create_condition.text = ""
    for k, v in pairs(self.selectedCreateItem_.CreateCondition) do
      local params = {}
      local condType = v[1]
      if v[2] then
        table.insert(params, v[2])
      end
      if v[3] then
        table.insert(params, v[3])
      end
      local bResult, unlockDesc = Z.ConditionHelper.GetSingleConditionDesc(condType, table.unpack(params))
      if not bResult then
        self.uiBinder.node_right.lab_create_condition.text = unlockDesc
      end
    end
  end
  local configId = self.isMakeState_ and self.selectedCreateItem_.Id or self.selectedCreateItem_.ConfigId
  local equipRow = Z.TableMgr.GetRow("EquipTableMgr", configId)
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", configId)
  local attrIds = {}
  local basicAttrLibId = {}
  local advancedAttrLibId = {}
  if equipRow and itemRow then
    self.gsLab_.text = Lang("GSEqual", {
      val = equipRow.EquipGs
    })
    self.nameLab_.text = itemRow.Name
    self.perfectLab_.text = Lang("EquipPerfaceLab") .. 100
    self:refreshWeaponModel(equipRow.Id)
    advancedAttrLibId = equipRow.AdvancedAttrLibId
    basicAttrLibId = equipRow.BasicAttrLibId
    if not self.isMakeState_ then
      local levels = self.equipCfgData_.EquipBreakIdLevelMap[self.selectedCreateItem_.ConfigId]
      if levels then
        local breakCount = self.selectedCreateItem_.Item.equipAttr.breakThroughTime or 0
        local rowId = levels[breakCount]
        if rowId then
          local breakThroughRow = Z.TableMgr.GetRow("EquipBreakThroughTableMgr", rowId)
          if breakThroughRow then
            self.oldGsLab_.text = breakThroughRow.EquipGs
            self.gsLab_.text = Lang("GSEqual", {
              val = breakThroughRow.EquipGs
            })
            advancedAttrLibId = breakThroughRow.AdvancedAttrLibId
            basicAttrLibId = breakThroughRow.BasicAttrLibId
          end
        end
      end
      self.perfectLab_.text = Lang("EquipPerfaceLab") .. self.selectedCreateItem_.Item.equipAttr.perfectionValue
    end
  end
  for index, value in ipairs(basicAttrLibId) do
    if 1 < index then
      attrIds[value] = value
    end
  end
  for index, value in ipairs(advancedAttrLibId) do
    if 1 < index then
      attrIds[value] = value
    end
  end
  self:refreshMiddleInfo()
  self:refreshRightInfo()
  self:refreshTalentDpd(attrIds)
end

function Equip_forge_mainView:refreshWeaponModel(equipId)
  self:clearWeaponModel()
  local equipWeaponRow = Z.TableMgr.GetRow("EquipWeaponTableMgr", equipId)
  if equipWeaponRow == nil then
    return
  end
  local weaponSkinRow = Z.TableMgr.GetRow("WeaponSkinTableMgr", equipWeaponRow.WeaponSkinId)
  if weaponSkinRow == nil then
    return
  end
  local weaponModelIdelAnim = {}
  local professionRow = Z.TableMgr.GetRow("ProfessionTableMgr", equipWeaponRow.ProfessionId)
  if professionRow == nil then
    return
  end
  local equipCreatRow = Z.TableMgr.GetRow("EquipCreateTableMgr", equipId)
  if equipCreatRow == nil then
    return
  end
  Z.UnrealSceneMgr:ChangeWaterSSprHeight(equipCreatRow.ssprHeight)
  weaponModelIdelAnim = professionRow.WeaponIdle
  for index, modelId in ipairs(weaponSkinRow.WeaponModelId) do
    if modelId ~= 0 then
      self.weaponModel_[index] = Z.UnrealSceneMgr:GenModelByLua(nil, modelId, function(model)
        local posOffset = Vector3.zero
        if equipCreatRow.ModelPos and #equipCreatRow.ModelPos > 0 then
          posOffset = Vector3.New(equipCreatRow.ModelPos[index][1], equipCreatRow.ModelPos[index][2], equipCreatRow.ModelPos[index][3])
        end
        model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos") + posOffset)
        local modelRot = Vector3.New(0, 180, 0)
        if equipCreatRow.ModelRot and 0 < #equipCreatRow.ModelRot then
          modelRot = Vector3.New(equipCreatRow.ModelRot[index][1], equipCreatRow.ModelRot[index][2], equipCreatRow.ModelRot[index][3])
        end
        model:SetAttrGoRotation(Quaternion.Euler(modelRot))
        if equipCreatRow.ModelScale and 0 < #equipCreatRow.ModelScale then
          model:SetLuaAttrGoScale(equipCreatRow.ModelScale[index])
        end
        local modeIdleAnim = weaponModelIdelAnim[index]
        if modeIdleAnim ~= nil then
          model:SetLuaAttrModelPreloadClip(modeIdleAnim[1])
          model:SetLuaAnimBase(Z.AnimBaseData.Rent(modeIdleAnim[1]))
        end
      end)
    end
  end
end

function Equip_forge_mainView:clearWeaponModel()
  if self.weaponModel_ == nil then
    return
  end
  for index, value in pairs(self.weaponModel_) do
    Z.UnrealSceneMgr:ClearModel(value)
  end
  self.weaponModel_ = {}
end

function Equip_forge_mainView:onModelDrag(model, eventData)
  if not model then
    return
  end
  local rotation = model:GetAttrGoRotation()
  if not rotation then
    return
  end
  local curShowModelRotation = rotation.eulerAngles
  curShowModelRotation.y = curShowModelRotation.y - eventData.delta.x * Z.ConstValue.ModelRotationScaleValue
  model:SetAttrGoRotation(Quaternion.Euler(curShowModelRotation))
end

function Equip_forge_mainView:refreshTalentDpd(attrIds)
  local schoolIds = self.equipCfgData_:GetTalentSchoolIdsByAttrLibIds(attrIds)
  local talentOptions = {}
  local talentSchoolRowMap = {}
  local index = 1
  for key, id in pairs(schoolIds) do
    local talentSchoolDatas = Z.TableMgr.GetRow("TalentSchoolTableMgr", id)
    if talentSchoolDatas then
      self.talentIds_[index] = id
      talentSchoolRowMap[id] = talentSchoolDatas
      index = index + 1
    end
  end
  local curProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  local talentSchoolId = self.equipCfgData_.TalentSchoolMap[self.talentSkillVm_.GetProfressionTalentStage(curProfessionId)]
  table.sort(self.talentIds_, function(left, right)
    if left == talentSchoolId and right ~= talentSchoolId then
      return true
    elseif left ~= talentSchoolId and right == talentSchoolId then
      return false
    end
    return left < right
  end)
  for i, v in ipairs(self.talentIds_) do
    talentOptions[i] = talentSchoolId == v and talentSchoolRowMap[v].SchoolName .. Lang("EquipSchoolTalentNow") or talentSchoolRowMap[v].SchoolName
  end
  if self.talentIds_[1] and self.talentIds_[1] ~= talentSchoolId then
    talentOptions[1] = talentOptions[1] .. Lang("EquipSchoolTalentDefault")
  end
  self.talentStageDpd_:ClearAll()
  self.talentStageDpd_:AddListener(function(index)
    self:loadAttrUnits(index + 1)
  end, true)
  self.talentStageDpd_:AddOptions(talentOptions)
  self:loadAttrUnits(1)
end

function Equip_forge_mainView:refreshMiddleInfo()
  if self.selectedCreateItem_ == nil then
    return
  end
  self.talentIds_ = {}
  self.nowBreakAdvancedAttr_ = {}
  self.nowBreakBasicAttr_ = {}
  self.advancedAttrLibIds_ = {}
  self.basicAttrLibIds_ = {}
  if self.isMakeState_ then
    local equipRow = Z.TableMgr.GetRow("EquipTableMgr", self.selectedCreateItem_.Id)
    if equipRow then
      self.advancedAttrLibIds_ = equipRow.AdvancedAttrLibId
      self.basicAttrLibIds_ = equipRow.BasicAttrLibId
    end
    self.desLab_.text = ""
  else
    local curBreakCount = self.selectedCreateItem_.Item.equipAttr.breakThroughTime
    local levels = self.equipCfgData_.EquipBreakIdLevelMap[self.selectedCreateItem_.ConfigId]
    if levels then
      local maxCountId = levels[#levels]
      local row = Z.TableMgr.GetRow("EquipBreakThroughTableMgr", maxCountId)
      if row then
        self.desLab_.text = Lang("EquipBreakThroughExplanationTips", {
          val = row.EquipGs
        })
      end
      local rowId = levels[curBreakCount + 1]
      if rowId then
        self.isBreakMaxLevel_ = false
        self.breakThroughRow_ = Z.TableMgr.GetRow("EquipBreakThroughTableMgr", rowId)
        if self.breakThroughRow_ then
          self.advancedAttrLibIds_ = self.breakThroughRow_.AdvancedAttrLibId
          self.basicAttrLibIds_ = self.breakThroughRow_.BasicAttrLibId
        end
      else
        self.isBreakMaxLevel_ = true
      end
    end
  end
end

function Equip_forge_mainView:clearAttrUnits()
  for unitName, unit in pairs(self.attrUnits_) do
    self:RemoveUiUnit(unitName)
  end
  self.attrUnits_ = {}
  for key, token in pairs(self.attrTokens_) do
    Z.CancelSource.ReleaseToken(token)
  end
  self.attrTokens_ = {}
end

function Equip_forge_mainView:getBreakAttrByLibIds(attrLibIds, randomValue, talentSchoolId)
  local attrType = 0
  local basicAttr = {}
  for index, value in ipairs(attrLibIds) do
    if index == 1 then
      attrType = value
    elseif attrType == 1 then
      table.zmerge(basicAttr, self.equipAttrParseVM_.GetEquipAttrDataByAttrLibId(value, randomValue))
    else
      table.zmerge(basicAttr, self.equipAttrParseVM_.GetEquipAttrDataBySchoolAttrLibId(value, talentSchoolId, 1, randomValue))
    end
  end
  return basicAttr
end

function Equip_forge_mainView:getBreakAttrList(curAttrList, breakAttrList)
  local attrs = {}
  local advancedAttr = {}
  if not self.isMakeState_ then
    for index, value in ipairs(curAttrList) do
      if attrs[value.attrId] == nil then
        attrs[value.attrId] = value
        attrs[value.attrId].curAttrValue = value.attrValue
        attrs[value.attrId].breakAttrValue = 0
      end
    end
    for index, value in ipairs(breakAttrList) do
      if attrs[value.attrId] == nil then
        attrs[value.attrId] = value
        attrs[value.attrId].curAttrValue = 0
      end
      attrs[value.attrId].breakAttrValue = value.attrValue
    end
  end
  return table.zvalues(attrs)
end

function Equip_forge_mainView:loadAttrUnits(attrIndex)
  local itemPath = self.prefabCache_:GetString("attr_item")
  if itemPath == "" or not itemPath then
    return
  end
  self:clearAttrUnits()
  self.basicAttr_ = {}
  self.advancedAttr_ = {}
  local randomValue = 100
  local talentSchoolId = self.talentIds_[attrIndex]
  if not self.isMakeState_ and self.breakThroughRow_ then
    randomValue = self.breakThroughRow_.EquipGs
  end
  self.basicAttr_ = self:getBreakAttrByLibIds(self.basicAttrLibIds_, randomValue, talentSchoolId)
  self.advancedAttr_ = self:getBreakAttrByLibIds(self.advancedAttrLibIds_, randomValue, talentSchoolId)
  if not self.isMakeState_ then
    local curBasicAttr = self.equipAttrParseVM_.GetEquipShoolAttrByAttrDic(self.selectedCreateItem_.Item.equipAttr.equipAttrSet.basicAttr, talentSchoolId)
    local curAdvancedAttr = self.equipAttrParseVM_.GetEquipShoolAttrByAttrDic(self.selectedCreateItem_.Item.equipAttr.equipAttrSet.advanceAttr, talentSchoolId)
    self.basicAttr_ = self:getBreakAttrList(curBasicAttr, self.basicAttr_)
    self.advancedAttr_ = self:getBreakAttrList(curAdvancedAttr, self.advancedAttr_)
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self:loadAttrUnit(self.basicAttr_, "basic", self.basicsItemNode_.transform)
    self:loadAttrUnit(self.advancedAttr_, "special", self.specialItemNode_.transform)
    if not self.isMakeState_ then
      self:loadConditionUnit()
    end
  end)()
end

function Equip_forge_mainView:loadConditionUnit()
  local itemPath = self.prefabCache_:GetString("condition_item")
  if not self.breakThroughRow_ or itemPath == "" or not itemPath then
    return
  end
  local condition = Z.ConditionHelper.GetConditionDescList(self.breakThroughRow_.Condition)
  for index, value in ipairs(condition) do
    local name = "condition" .. index
    local token = self.cancelSource:CreateToken()
    self.attrTokens_[name] = token
    local unit = self:AsyncLoadUiUnit(itemPath, name, self.conditionNode_.transform, token)
    self.attrUnits_[name] = unit
    if unit then
      unit.lab_condition.text = value.Desc
      unit.Ref:SetVisible(unit.img_finished, value.IsUnlock)
      unit.Ref:SetVisible(unit.img_no, not value.IsUnlock)
    end
  end
end

function Equip_forge_mainView:loadAttrUnit(attr, unitName, parent)
  local itemPath = self.prefabCache_:GetString("attr_item")
  if itemPath == "" or not itemPath then
    return
  end
  for index, value in ipairs(attr) do
    local name = unitName .. value.attrId
    local token = self.cancelSource:CreateToken()
    self.attrTokens_[name] = token
    local unit = self:AsyncLoadUiUnit(itemPath, name, parent, token)
    self.attrUnits_[name] = unit
    if unit then
      unit.lab_name.text = value.des
      unit.Ref:SetVisible(unit.img_arrow, not self.isMakeState_ and not self.isBreakMaxLevel_)
      unit.Ref:SetVisible(unit.lab_old_num, not self.isMakeState_ and not self.isBreakMaxLevel_)
      if self.isMakeState_ then
        unit.lab_change_num.text = value.attrValue
      elseif self.isBreakMaxLevel_ then
        unit.lab_change_num.text = value.curAttrValue
      else
        unit.lab_change_num.text = value.breakAttrValue
        unit.lab_old_num.text = value.curAttrValue
      end
    end
  end
end

function Equip_forge_mainView:refreshRightInfo()
  if self.selectedCreateItem_ == nil then
    return
  end
  self.rightNode_.Ref:SetVisible(self.makeNode_, false)
  self.rightNode_.Ref:SetVisible(self.breakItemList_, false)
  self.rightNode_.Ref:SetVisible(self.haveNode_, false)
  if self.isMakeState_ then
    local isHave = self.equipSystemVM_.CheckIsHaveEquipByConfigId(self.selectedCreateItem_.Id)
    self.rightNode_.Ref:SetVisible(self.haveNode_, isHave)
    self.rightNode_.Ref:SetVisible(self.bottomNode_, not isHave)
    if self.selectedCreateItem_.EquipNameGroupId ~= 0 then
      self.rightTitleLab_.text = Lang("EquipMakeConsumeEquipAndItem")
      self.rightNode_.Ref:SetVisible(self.makeNode_, true)
      self.expendListView2_:RefreshListView(self.selectedCreateItem_.ConsumableItems)
    else
      self.rightTitleLab_.text = Lang("EquipMakeConsumeItem")
      self.rightNode_.Ref:SetVisible(self.breakItemList_, true)
      self.expendListView1_:RefreshListView(self.selectedCreateItem_.ConsumableItems)
    end
  else
    self.rightNode_.Ref:SetVisible(self.haveNode_, self.isBreakMaxLevel_)
    self.rightNode_.Ref:SetVisible(self.gsBgNode_, not self.isBreakMaxLevel_)
    self.rightNode_.Ref:SetVisible(self.bottomNode_, not self.isBreakMaxLevel_)
    if self.breakThroughRow_ then
      self.rightTitleLab_.text = Lang("EquipBreakConsumeItem")
      self.expendListView1_:RefreshListView(self.breakThroughRow_.Consume)
      self.newGsLab_.text = self.breakThroughRow_.EquipGs
      if self.breakThroughRow_.BreakThroughTime == 1 then
        local equipRow = Z.TableMgr.GetRow("EquipTableMgr", self.selectedCreateItem_.ConfigId)
        if equipRow then
          self.oldGsLab_.text = equipRow.EquipGs
        end
      else
        local levels = self.equipCfgData_.EquipBreakIdLevelMap[self.selectedCreateItem_.ConfigId]
        if levels then
          local rowId = levels[self.breakThroughRow_.BreakThroughTime - 1]
          if rowId then
            local breakThroughRow = Z.TableMgr.GetRow("EquipBreakThroughTableMgr", rowId)
            if breakThroughRow then
              self.oldGsLab_.text = breakThroughRow.EquipGs
              self.gsLab_.text = Lang("GSEqual", {
                val = breakThroughRow.EquipGs
              })
            end
          end
        end
      end
    end
    self.rightNode_.Ref:SetVisible(self.breakItemList_, true)
  end
end

function Equip_forge_mainView:selectedConsumeItem(item)
  if item then
    self.makeBinderItem_.Ref.UIComp:SetVisible(true)
    self.rightNode_.Ref:SetVisible(self.addItemBtn_, false)
    local itemData = {
      uiBinder = self.makeBinderItem_,
      configId = item.ConfigId,
      itemInfo = item.IsEquipItem and item.Item,
      uuid = item.IsEquipItem and item.Item.uuid,
      expendCount = not item.IsEquipItem and item.ExpendNum or nil,
      labType = not item.IsEquipItem and E.ItemLabType.Expend or nil,
      isSquareItem = true
    }
    self.itemClass_:RefreshByData(itemData)
    self.makeBinderItem_.Ref:SetVisible(self.makeBinderItem_.btn_minus, true)
    self.consumeItem_ = item
  end
end

function Equip_forge_mainView:OnOpenAnimShow()
  self.uiBinder.anim_main:Restart(Z.DOTweenAnimType.Open)
end

function Equip_forge_mainView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("equip_forge_main")
end

function Equip_forge_mainView:OnDeActive()
  if self.expendListView1_ then
    self.expendListView1_:UnInit()
    self.expendListView1_ = nil
  end
  if self.expendListView2_ then
    self.expendListView2_:UnInit()
    self.expendListView2_ = nil
  end
  if self.leftListView_ then
    self.leftListView_:UnInit()
    self.leftListView_ = nil
  end
  if self.sourceTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipsId_)
    self.sourceTipsId_ = nil
  end
  self.filterHelper_:DeActive()
  self.equip_forge_left_sub_view_:DeActive()
  self:clearWeaponModel()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function Equip_forge_mainView:OnRefresh()
  self:filterItemList()
end

return Equip_forge_mainView
