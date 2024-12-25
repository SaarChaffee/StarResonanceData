local UI = Z.UI
local super = require("ui.ui_subview_base")
local Equip_recast_subView = class("Equip_recast_subView", super)
local itemClass = require("common.item_binder")
local fightTableMgr = Z.TableMgr.GetTable("FightAttrTableMgr")
local equip_list_view_ = require("ui.view.equip_itemlist_view")
local equipLockView = require("ui.view.equip_lock_popup_view")
local equip_choice_view_ = require("ui.view.equip_choice_sub_view")

function Equip_recast_subView:ctor(parent)
  self.parent_ = parent
  self.uiBinder = nil
  super.ctor(self, "equip_recast_sub", "equip/equip_recast_sub", UI.ECacheLv.None)
  self.equipSystemVM_ = Z.VMMgr.GetVM("equip_system")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.equip_list_view_ = equip_list_view_.new(self)
  self.choiceItemClass_ = itemClass.new(self)
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.equipRecastVm_ = Z.VMMgr.GetVM("equip_recast")
  self.acquireVm_ = Z.VMMgr.GetVM("item_show")
  self.equipAttrParseVM_ = Z.VMMgr.GetVM("equip_attr_parse")
  self.tradeVM_ = Z.VMMgr.GetVM("trade")
  self.equipLockView_ = equipLockView.new(self)
  self.filterFuncs_ = {}
  self.equipCfgData_ = Z.DataMgr.Get("equip_config_data")
  self.choiceSubView_ = equip_choice_view_.new(self)
  table.insert(self.filterFuncs_, self.equipVm_.CheckCanRecast)
end

function Equip_recast_subView:initUiBinders()
  self.recastBtn_ = self.uiBinder.btn_recasting_one
  self.recastItemIcon_ = self.uiBinder.selected_icon
  self.addBtn_ = self.uiBinder.btn_one_click_add
  self.emptyNode_ = self.uiBinder.node_empty
  self.recastNode_ = self.uiBinder.group_recasting
  self.addItemBtn_ = self.uiBinder.btn_add
  self.choiceItemBinder_ = self.uiBinder.com_selected_item
  self.rightNode_ = self.uiBinder.node_right
  self.node_basics_item = self.uiBinder.node_basics_item
  self.node_special_item = self.uiBinder.node_special_item
  self.node_recast_item = self.uiBinder.node_recast_item
  self.prefectTipsNode_ = self.uiBinder.node_tips
  self.perfectionNumLab_ = self.uiBinder.lab_perfection_num
  self.progressImg_ = self.uiBinder.img_progress
  self.lockBtn_ = self.uiBinder.btn_lock
  self.lockRect_ = self.uiBinder.rect_lock
  self.equipName_ = self.uiBinder.lab_equip_name
  self.equipIconBtn_ = self.uiBinder.btn_equip_icon
  self.perfectionProgressLab_ = self.uiBinder.lab_one_perfection
  self.nodeItemSub_ = self.uiBinder.node_item_sub
  self.specialRef_ = self.uiBinder.node_prompt_special
  self.basicsRef_ = self.uiBinder.node_prompt_basics
  self.parent_.uiBinder.ui_depth:AddChildDepth(self.uiBinder.effect)
end

function Equip_recast_subView:initBtns()
  self:AddClick(self.addBtn_, function()
    if self.items_ and #self.items_ > 0 then
      if 0 < self.items_[1].equipAttr.totalRecastCount then
        Z.TipsVM.ShowTips(150022)
        return
      end
      local selectFun = function()
        self:selectedConsumeItem(self.items_[1])
      end
      local canTrade = self.tradeVM_:CheckItemCanExchange(self.items_[1].configId, self.items_[1].uuid)
      if canTrade then
        self.equipVm_.OpenDayDialog(selectFun, Lang("EquipRecastCanTradeTips"), E.DlgPreferencesKeyType.EquipRecastCanTradeTips)
      else
        selectFun()
      end
    else
      Z.TipsVM.ShowTips(150010)
    end
  end)
  self:AddClick(self.equipIconBtn_, function()
    if self.tipsId_ then
      Z.TipsVM.CloseItemTipsView(self.tipsId_)
      self.tipsId_ = nil
    end
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.equipIconBtn_.transform, self.selectedItemconfigId_, self.selectedItemUuid_)
  end)
  self:AddClick(self.choiceItemBinder_.btn_minus, function()
    self.choiceItemBinder_.Ref.UIComp:SetVisible(false)
    self.uiBinder.Ref:SetVisible(self.addItemBtn_, true)
    self.consumeItem_ = nil
  end)
  self:AddClick(self.lockBtn_, function()
    self.equipLockView_:Active({
      tips = self.equipLockTips_ or ""
    }, self.prefectTipsNode_.transform)
  end)
  self:AddClick(self.addItemBtn_, function()
    self.choiceSubView_:Active({
      items = self.items_
    }, self.nodeItemSub_.transform)
  end)
  self:AddAsyncClick(self.recastBtn_, function()
    local func = function()
      self.lastInfo_ = {}
      self:setLastAttrData(self.selectedItem_.equipAttr.basicAttr)
      self:setLastAttrData(self.selectedItem_.equipAttr.advanceAttr)
      if self.isRecast_ then
        self:setLastAttrData(self.selectedItem_.equipAttr.recastAttr)
      end
      self.uiBinder.effect:SetEffectGoVisible(true)
      self.uiBinder.effect:Play()
      self:asyncRecastEquip()
      self.playEffectTime_ = self.timerMgr:StartTimer(function()
        self:playAttrUnitEffect()
        self.playEffectTime_ = nil
      end, 3, 1)
      Z.AudioMgr:Play("UI_Event_Equipment_Rebuild")
    end
    if self.consumeItem_ and self.selectedItem_ then
      if self.selectedItem_.bindFlag == 1 and self.consumeItem_.bindFlag == 0 then
        self.equipVm_.OpenDayDialog(func, Lang("EquipRecastingBindingTips"), E.DlgPreferencesKeyType.EquipRecastingBindingTips)
        return
      end
      func()
    else
      Z.TipsVM.ShowTips(150011)
    end
  end, nil, nil)
end

function Equip_recast_subView:setLastAttrData(attrs)
  local attrDatas = self.equipAttrParseVM_.GetEquipAttrEffectByAttrDic(attrs)
  for i, attrData in ipairs(attrDatas) do
    self.lastInfo_[attrData.attrId] = attrData.attrValue
  end
end

function Equip_recast_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:initUiBinders()
  self:onStartAnimShow()
  self:initBtns()
  self:bindEvents()
  self.allUnit_ = {}
  self.newAttrData = {}
  self.lastInfo_ = {}
  local choiceItemData = {
    uiBinder = self.choiceItemBinder_,
    isClickOpenTips = true,
    isSquareItem = true
  }
  self.choiceItemClass_:Init(choiceItemData)
  self.uiBinder.effect:SetEffectGoVisible(false)
  if self.viewData and self.viewData.configId and self.viewData.itemUuid then
    self.equip_list_view_:Active({
      funcViewType = E.EquipFuncViewType.Recast,
      filterFuncs = self.filterFuncs_,
      showItemTips = true,
      itemSelectedFunc = function(itemUuid, configId)
        self:onItemSelected(itemUuid, configId)
      end,
      itemUuid = self.viewData.itemUuid,
      configId = self.viewData.configId
    }, self.uiBinder.node_left.transform)
  else
    self.equip_list_view_:Active({
      funcViewType = E.EquipFuncViewType.Recast,
      filterFuncs = self.filterFuncs_,
      showItemTips = true,
      itemSelectedFunc = function(itemUuid, configId)
        self:onItemSelected(itemUuid, configId)
      end
    }, self.uiBinder.node_left.transform)
  end
end

function Equip_recast_subView:OnDeActive()
  self.selectedItemUuid_ = 0
  self.parent_.uiBinder.ui_depth:AddChildDepth(self.uiBinder.effect)
  self.equip_list_view_:DeActive()
  self.equipLockView_:DeActive()
  self.choiceItemClass_:UnInit()
  for k, unit in pairs(self.allUnit_) do
    unit.effect:SetEffectGoVisible(false)
    unit.effect:Stop()
    unit.effect_blue:SetEffectGoVisible(false)
    unit.effect_blue:Stop()
  end
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  self.choiceSubView_:DeActive()
end

function Equip_recast_subView:asyncRecastEquip()
  local ret = self.equipRecastVm_.AsyncRecastEquip(self.selectedItemUuid_, self.consumeItem_.uuid, self.cancelSource:CreateToken())
  if ret == 0 then
    self.recastSurcced_ = true
    self.equip_list_view_:RefreshItemInfoDatas()
    self.equip_list_view_:Active({
      funcViewType = E.EquipFuncViewType.Recast,
      showItemTips = true,
      partId = self.equip_list_view_:GetCurSelectPartId(),
      itemSelectedFunc = function(itemUuid, configId, isSelected)
        self:onItemSelected(itemUuid, configId, isSelected)
      end,
      itemUuid = self.selectedItemUuid_,
      configId = self.selectedItemconfigId_
    }, self.uiBinder.node_left.transform)
  else
    self.playEffect_ = false
  end
end

function Equip_recast_subView:onItemSelected(itemUuid, configId)
  self.equipName_.text = self.itemsVm_.ApplyItemNameWithQualityTag(configId)
  local itemsVm = Z.VMMgr.GetVM("items")
  self.recastItemIcon_:SetImage(itemsVm.GetItemIcon(configId))
  self.playEffect_ = self.selectedItemUuid_ == itemUuid
  if self.playEffect_ and self.recastSurcced_ then
    self.uiBinder.effect:SetEffectGoVisible(true)
  else
    self.uiBinder.effect:SetEffectGoVisible(false)
  end
  if self.recastSurcced_ then
    self.recastSurcced_ = false
  elseif self.playEffectTime_ then
    self.timerMgr:StopTimer(self.playEffectTime_)
  end
  if not self.playEffect_ then
    self.uiBinder.effect:Stop()
  end
  self.selectedItemUuid_ = itemUuid
  self.selectedItemconfigId_ = configId
  self.choiceItemBinder_.Ref.UIComp:SetVisible(false)
  self.uiBinder.Ref:SetVisible(self.addItemBtn_, true)
  self.consumeItem_ = nil
  self.items_ = self.equipVm_.GetEquipsByConfigId(configId, itemUuid, true)
  if #self.items_ > 0 then
    table.sort(self.items_, function(leftItem, rightItem)
      if leftItem.equipAttr.totalRecastCount < rightItem.equipAttr.totalRecastCount then
        return true
      elseif leftItem.equipAttr.totalRecastCount > rightItem.equipAttr.totalRecastCount then
        return false
      end
      local canTradeLeft = self.tradeVM_:CheckItemCanExchange(leftItem.configId, leftItem.uuid)
      local canTradeRight = self.tradeVM_:CheckItemCanExchange(rightItem.configId, rightItem.uuid)
      if canTradeLeft and not canTradeRight then
        return false
      elseif not canTradeLeft and canTradeRight then
        return true
      end
      if leftItem.bindFlag == 0 and rightItem.bindFlag ~= 0 then
        return true
      elseif leftItem.bindFlag ~= 0 and rightItem.bindFlag == 0 then
        return false
      end
      if leftItem.equipAttr.perfectionValue < rightItem.equipAttr.perfectionValue then
        return true
      elseif leftItem.equipAttr.perfectionValue > rightItem.equipAttr.perfectionValue then
        return false
      end
      return false
    end)
  end
  self.selectedItem_ = self.itemsVm_.GetItemInfo(itemUuid, E.BackPackItemPackageType.Equip)
  if self.selectedItem_ then
    self:refrshLockInfo()
    Z.CoroUtil.create_coro_xpcall(function()
      self:setEquipAttr(self.selectedItem_.equipAttr)
    end)()
  end
end

function Equip_recast_subView:refrshLockInfo()
  self.progressImg_.fillAmount = self.selectedItem_.equipAttr.perfectionValue / 100
  self.perfectionNumLab_.text = self.selectedItem_.equipAttr.perfectionValue
  local equipRow = Z.TableMgr.GetRow("EquipTableMgr", self.selectedItem_.configId)
  if not equipRow then
    return
  end
  local rows = self.equipCfgData_.RecastPerfectTab[equipRow.PerfectLibId]
  if not rows then
    return
  end
  local equipPerfectLibTable = rows[self.selectedItem_.equipAttr.perfectionLevel]
  if not equipPerfectLibTable then
    return
  end
  local tableRow = rows[equipPerfectLibTable.PartLevel]
  if not tableRow then
    return
  end
  local minAttrValue = equipPerfectLibTable.PerfectPart[1]
  local x = 0
  local width = self.uiBinder.img_progress.rectTransform.rect.width
  local str = ""
  local maxLevel = self.equipCfgData_.RecastMaxLevleTab[equipRow.PerfectLibId]
  local isMaxLevel = maxLevel == self.selectedItem_.equipAttr.perfectionLevel
  if tableRow.PerfectType[1] == 1 then
    self.equipLockTips_ = Lang("EquipPerfectvalExplainTips", {val = minAttrValue}) or ""
    self.perfectionProgressLab_.text = tableRow.PerfectLibId
    local nexLevleCount = tableRow.MinimumGuarantee - self.selectedItem_.equipAttr.recastCount
    if isMaxLevel then
      str = Lang("EquipRecastPerfectTips3", {val = minAttrValue})
    else
      local nextAttrValue = self.equipSystemVM_.GetEquipMinPerfectByLevel(self.selectedItem_.configId, self.selectedItem_.equipAttr.perfectionLevel + 1)
      str = Lang("EquipRecastPerfectTips2", {
        val1 = minAttrValue,
        val2 = nexLevleCount,
        val3 = nextAttrValue
      })
    end
    x = width / 100 * (minAttrValue - 1)
  elseif tableRow.PerfectType[1] == 2 then
    local maxAttrValue = equipPerfectLibTable.PerfectPart[2]
    self.equipLockTips_ = Lang("EquipPerfectvalExplainTips", {val = maxAttrValue}) or ""
    if isMaxLevel then
      str = Lang("EquipRecastPerfectTips3", {val = minAttrValue})
      x = width * (self.selectedItem_.equipAttr.perfectionValue / 100)
    else
      local minValue = tableRow.PerfectType[3]
      local maxValue = tableRow.PerfectType[4]
      x = width * (maxAttrValue / 100)
      str = Lang("EquipRecastPerfectTips1", {
        val1 = maxAttrValue,
        val2 = minValue,
        val3 = maxValue
      })
    end
  end
  self.perfectionProgressLab_.text = str
  self.lockRect_:SetAnchorPosition(x, 5)
end

function Equip_recast_subView:OnRefresh()
end

function Equip_recast_subView:selectedConsumeItem(item)
  if item then
    self.choiceItemBinder_.Ref.UIComp:SetVisible(true)
    self.uiBinder.Ref:SetVisible(self.addItemBtn_, false)
    local itemData = {
      uiBinder = self.choiceItemBinder_,
      configId = item.configId,
      uuid = item.uuid,
      isSquareItem = true
    }
    self.choiceItemClass_:Init(itemData)
    self.choiceItemBinder_.Ref:SetVisible(self.choiceItemBinder_.btn_minus, true)
    self.consumeItem_ = item
  end
end

function Equip_recast_subView:setEquipAttr(equipAttr)
  for k, unit in pairs(self.allUnit_) do
    unit.effect:SetEffectGoVisible(false)
    unit.effect:Stop()
    unit.effect_blue:SetEffectGoVisible(false)
    unit.effect_blue:Stop()
  end
  self.allUnit_ = {}
  self.newAttrData = {}
  self.isRecast_ = self.equipSystemVM_.CheckCanRecast(nil, self.selectedItemconfigId_)
  self:ClearAllUnits()
  self:loadEquipAttrUnit(equipAttr.basicAttr, self.node_basics_item, "baseAttrInfo", true)
  self:loadEquipAttrUnit(equipAttr.advanceAttr, self.node_special_item, "advanceAttrInfo", false)
  if self.isRecast_ then
    self:loadEquipAttrUnit(equipAttr.recastAttr, self.node_recast_item, "recastAttrInfo", false, true)
  end
end

function Equip_recast_subView:loadEquipAttrUnit(attrArray, attrWidget, unitName, isBaseAttr, isRecastAttr)
  if attrArray == nil or next(attrArray) == nil then
    self.uiBinder.Ref:SetVisible(attrWidget, false)
    self.uiBinder.Ref:SetVisible(self.node_special_item, false)
    if isBaseAttr then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_basics_item, false)
    end
    return
  end
  local utilPath = Z.ConstValue.Unit_equip_arr_tpl
  local attrData = self.equipAttrParseVM_.GetEquipAttrEffectByAttrDic(attrArray)
  if isRecastAttr then
    if attrData and 0 < #attrData then
      self.uiBinder.Ref:SetVisible(self.basicsRef_, false)
      self.uiBinder.Ref:SetVisible(self.specialRef_, false)
      for key, value in ipairs(attrData) do
        local name = table.zconcat({unitName, key}, "recastAttr")
        local unit = self:AsyncLoadUiUnit(utilPath, name, attrWidget.transform)
        if unit then
          self.allUnit_[value.attrId] = unit
          self.newAttrData[value.attrId] = value.attrValue
          local fightAttrData = self.fightAttrParseVm_.GetFightAttrTableRow(value.attrId)
          if fightAttrData then
            local nameText = fightAttrData.OfficialName
            local num = value.attrValue
            unit.Ref:SetVisible(unit.img_bg, true)
            if not value.IsFitProfessionAttr then
              nameText = Z.RichTextHelper.ApplyColorTag(nameText, Z.Global.EquipAttColourNotSuitable)
              num = Z.RichTextHelper.ApplyColorTag(num, Z.Global.EquipAttColourNotSuitable)
            end
            unit.lab_name.text = nameText
            unit.lab_num.text = num
            unit.Ref:SetVisible(unit.img_up_or_down, false)
            local itemFunctionTableRow = fightTableMgr.GetRow(fightAttrData.Id, true)
            unit.img_icon:SetImage(itemFunctionTableRow.Icon)
          end
        end
      end
    else
      self.uiBinder.Ref:SetVisible(self.basicsRef_, true)
      self.uiBinder.Ref:SetVisible(self.specialRef_, true)
      utilPath = GetLoadAssetPath(Z.ConstValue.Unit_Multi_Line_Labe_Addr)
      local name = table.zconcat({unitName, "recastAttr"}, "_")
      local unit = self:AsyncLoadUiUnit(utilPath, name, attrWidget.transform)
      if unit then
        unit.Ref:SetVisible(unit.img_bg, true)
        unit.tmp_Desc.text = Z.RichTextHelper.ApplyColorTag(Lang("EquipNoRecastingState") .. Lang("RecastUnLock"), Z.Global.EquipAttColourNotActive)
      end
    end
  else
    for key, value in pairs(attrData) do
      local name = table.zconcat({unitName, key}, "_")
      local unit = self:AsyncLoadUiUnit(utilPath, name, attrWidget.transform)
      if unit then
        unit.Ref:SetVisible(unit.img_bg, false)
        self.allUnit_[value.attrId] = unit
        self.newAttrData[value.attrId] = value.attrValue
        local fightAttrData = self.fightAttrParseVm_.GetFightAttrTableRow(value.attrId)
        if fightAttrData then
          local name = fightAttrData.OfficialName
          local num = value.attrValue
          unit.Ref:SetVisible(unit.img_up_or_down, false)
          local itemFunctionTableRow = fightTableMgr.GetRow(fightAttrData.Id, true)
          unit.img_icon:SetImage(itemFunctionTableRow.Icon)
          if not value.IsFitProfessionAttr then
            name = Z.RichTextHelper.ApplyColorTag(name, Z.Global.EquipAttColourNotSuitable)
            num = Z.RichTextHelper.ApplyColorTag(num, Z.Global.EquipAttColourNotSuitable)
          else
          end
          unit.lab_name.text = name
          unit.lab_num.text = num
        end
      end
    end
  end
end

function Equip_recast_subView:playAttrUnitEffect()
  if self.playEffect_ then
    Z.TipsVM.ShowTips(150014)
    for k, unit in pairs(self.allUnit_) do
      local newValue = self.newAttrData[k]
      local lastValue = self.lastInfo_[k]
      if newValue then
        if not lastValue then
          unit.effect:SetEffectGoVisible(true)
          unit.effect:Play()
        elseif newValue ~= lastValue then
          unit.effect_blue:SetEffectGoVisible(true)
          unit.effect_blue:Play()
        end
      end
    end
  end
end

function Equip_recast_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Equip.RefreshEmptyState, self.EmptyState, self)
  Z.EventMgr:Add(Z.ConstValue.Equip.SelectedRecastItem, self.selectedConsumeItem, self)
end

function Equip_recast_subView:EmptyState(state)
  self.uiBinder.Ref:SetVisible(self.rightNode_, state)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_middon, state)
  if not state then
    self.selectedItemUuid_ = nil
  end
end

function Equip_recast_subView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Equip_recast_subView
