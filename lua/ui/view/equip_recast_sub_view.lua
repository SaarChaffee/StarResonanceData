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
  super.ctor(self, "equip_recast_sub", "equip/equip_recast_sub", UI.ECacheLv.None, true)
  self.equipSystemVM_ = Z.VMMgr.GetVM("equip_system")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.equip_list_view_ = equip_list_view_.new(self)
  self.choiceItemClass_ = itemClass.new(self)
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.equipRecastVm_ = Z.VMMgr.GetVM("equip_recast")
  self.acquireVm_ = Z.VMMgr.GetVM("item_show")
  self.equipAttrParseVM_ = Z.VMMgr.GetVM("equip_attr_parse")
  self.talentSkillVm_ = Z.VMMgr.GetVM("talent_skill")
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
  self.progress2Img_ = self.uiBinder.img_progress_02
  self.lockBtn_ = self.uiBinder.btn_lock
  self.lockRect_ = self.uiBinder.rect_lock
  self.equipName_ = self.uiBinder.lab_equip_name
  self.equipIconBtn_ = self.uiBinder.btn_equip_icon
  self.perfectionProgressLab_ = self.uiBinder.lab_one_perfection
  self.nodeItemSub_ = self.uiBinder.node_item_sub
  self.specialRef_ = self.uiBinder.node_prompt_special
  self.basicsRef_ = self.uiBinder.node_prompt_basics
  self.infoBtn_ = self.uiBinder.btn_info
  self.parent_.uiBinder.ui_depth:AddChildDepth(self.uiBinder.effect)
end

function Equip_recast_subView:initBtns()
  self:AddClick(self.addBtn_, function()
    self:addOneKey(true)
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
      items = self.items_,
      selectedEquipId = self.selectedItemconfigId_,
      tipsRoot = self.uiBinder.node_tips_root,
      title = Lang("SelectEquip"),
      labInfo = Lang("EquipObtainRecastMaterialTips"),
      isRecast = true
    }, self.nodeItemSub_.transform)
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
  end)
  self:AddClick(self.infoBtn_, function()
    Z.CommonTipsVM.ShowTipsContent(self.infoBtn_.transform, Lang("EquipAttention"))
  end)
  self:AddAsyncClick(self.recastBtn_, function()
    if not self.consumeItem_ then
      Z.TipsVM.ShowTips(150011)
      return
    end
    if not self.consumeItem_.IsEquipItem then
      local configId = self.consumeItem_.ConfigId
      local totalCount = self.itemsVm_.GetItemTotalCount(configId)
      if totalCount < self.consumeItem_.ExpendNum then
        local name = self.itemsVm_.ApplyItemNameWithQualityTag(configId)
        Z.TipsVM.ShowTips(150015, {val = name})
        if self.sourceTipsId_ then
          Z.TipsVM.CloseItemTipsView(self.sourceTipsId_)
          self.sourceTipsId_ = nil
        end
        self.sourceTipsId_ = Z.TipsVM.OpenSourceTips(configId, self.recastBtn_.transform)
        return
      end
    end
    local func = function()
      if self.selectedItem_.bindFlag == 1 and self.consumeItem_.IsEquipItem and self.consumeItem_.Item.bindFlag == 0 then
        self.equipVm_.OpenDayDialog(function()
          self:recastEquip()
        end, Lang("EquipRecastingBindingTips"), E.DlgPreferencesKeyType.EquipRecastingBindingTips)
        return
      end
      self:recastEquip()
    end
    if self.consumeItem_ and self.selectedItem_ then
      if self.selectedItem_.equipAttr.maxPerfectionValue == self.selectedItem_.equipAttr.perfectionValue then
        self.equipVm_.OpenDayDialog(function()
          func()
        end, Lang("EquipRecastMaxPerfect", {
          val = self.selectedItem_.equipAttr.maxPerfectionValue
        }), E.DlgPreferencesKeyType.EquipRecastMaxPerfect)
      else
        func()
      end
    end
  end, nil, nil)
end

function Equip_recast_subView:recastEquip()
  self.lastInfo_ = {}
  self:setLastAttrData(self.selectedItem_.equipAttr.basicAttr)
  self:setLastAttrData(self.selectedItem_.equipAttr.advanceAttr)
  if self.isRecast_ then
    self:setLastAttrData(self.selectedItem_.equipAttr.recastAttr)
  end
  self:asyncRecastEquip()
  self.playEffectTime_ = self.timerMgr:StartTimer(function()
    if self.playEffect_ then
      Z.TipsVM.ShowTips(150014)
    end
    self.playEffectTime_ = nil
  end, 3, 1)
  Z.AudioMgr:Play("UI_Event_Equipment_Rebuild")
end

function Equip_recast_subView:addOneKey(showTips)
  if self.items_ and #self.items_ > 0 then
    local selectFun = function()
      self:selectedConsumeItem(self.items_[1])
    end
    if self.items_[1].IsEquipItem then
      if 0 < self.items_[1].Item.equipAttr.totalRecastCount then
        if showTips then
          Z.TipsVM.ShowTips(150022)
        end
        return
      end
      local canTrade = self.tradeVM_:CheckItemCanExchange(self.items_[1].Item.configId, self.items_[1].Item.uuid)
      if canTrade and showTips then
        self.equipVm_.OpenDayDialog(selectFun, Lang("EquipRecastCanTradeTips"), E.DlgPreferencesKeyType.EquipRecastCanTradeTips)
      else
        selectFun()
      end
    else
      selectFun()
    end
  elseif showTips then
    Z.TipsVM.ShowTips(150010)
  end
end

function Equip_recast_subView:setLastAttrData(attrs)
  local attrDatas = self.equipAttrParseVM_.GetEquipAttrEffectByAttrDic(attrs)
  for i, attrData in ipairs(attrDatas) do
    self.lastInfo_[attrData.attrId] = attrData.attrValue
  end
end

function Equip_recast_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.Ref.UIComp.UIDepth)
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
  Z.CommonTipsVM.CloseTipsContent()
  self.selectedItemUuid_ = 0
  self.parent_.uiBinder.ui_depth:RemoveChildDepth(self.uiBinder.effect)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.Ref.UIComp.UIDepth)
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
  if self.sourceTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipsId_)
    self.sourceTipsId_ = nil
  end
  self.choiceSubView_:DeActive()
end

function Equip_recast_subView:asyncRecastEquip()
  local ret = self.equipRecastVm_.AsyncRecastEquip(self.selectedItemUuid_, self.consumeItem_, self.cancelSource:CreateToken())
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
    self:addOneKey()
  else
    self.playEffect_ = false
  end
end

function Equip_recast_subView:onItemSelected(itemUuid, configId)
  self.equipName_.text = self.itemsVm_.ApplyItemNameWithQualityTag(configId)
  self.recastItemIcon_:SetImage(self.itemsVm_.GetItemIcon(configId))
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
  self.items_ = self.equipRecastVm_.GetRecastItems(configId, itemUuid, true)
  if #self.items_ > 0 then
    table.sort(self.items_, function(leftItem, rightItem)
      if not leftItem.IsEquipItem and rightItem.IsEquipItem then
        return true
      end
      if leftItem.IsEquipItem and not rightItem.IsEquipItem then
        return false
      end
      if not leftItem.IsEquipItem and not rightItem.IsEquipItem then
        return false
      end
      if leftItem.Item.equipAttr.totalRecastCount < rightItem.Item.equipAttr.totalRecastCount then
        return true
      elseif leftItem.Item.equipAttr.totalRecastCount > rightItem.Item.equipAttr.totalRecastCount then
        return false
      end
      local canTradeLeft = self.tradeVM_:CheckItemCanExchange(leftItem.Item.configId, leftItem.Item.uuid)
      local canTradeRight = self.tradeVM_:CheckItemCanExchange(rightItem.Item.configId, rightItem.Item.uuid)
      if canTradeLeft and not canTradeRight then
        return false
      elseif not canTradeLeft and canTradeRight then
        return true
      end
      if leftItem.Item.bindFlag == 0 and rightItem.Item.bindFlag ~= 0 then
        return true
      elseif leftItem.Item.bindFlag ~= 0 and rightItem.Item.bindFlag == 0 then
        return false
      end
      if leftItem.Item.equipAttr.perfectionValue < rightItem.Item.equipAttr.perfectionValue then
        return true
      elseif leftItem.Item.equipAttr.perfectionValue > rightItem.Item.equipAttr.perfectionValue then
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
  local maxPerfectionValue = self.selectedItem_.equipAttr.maxPerfectionValue == 0 and 100 or self.selectedItem_.equipAttr.maxPerfectionValue
  self.progressImg_.fillAmount = self.selectedItem_.equipAttr.perfectionValue / 100
  self.progress2Img_.fillAmount = (100 - maxPerfectionValue) / 100
  self.perfectionNumLab_.text = Lang("season_achievement_progress", {
    val1 = self.selectedItem_.equipAttr.perfectionValue,
    val2 = maxPerfectionValue
  })
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
  local width = self.progress2Img_.rectTransform.rect.width
  local x = width * (maxPerfectionValue / 100)
  local str = Lang("EquipRecastPerfectUpperLimitTips", {val = maxPerfectionValue}) or ""
  self.equipLockTips_ = Lang("EquipPerfectvalExplainTips", {val = maxPerfectionValue}) or ""
  self.perfectionProgressLab_.text = str
  self.lockRect_:SetAnchorPosition(x - self.lockRect_.rect.width / 2, 5)
end

function Equip_recast_subView:OnRefresh()
end

function Equip_recast_subView:selectedConsumeItem(item)
  if item then
    self.choiceItemBinder_.Ref.UIComp:SetVisible(true)
    self.uiBinder.Ref:SetVisible(self.addItemBtn_, false)
    local itemData = {
      uiBinder = self.choiceItemBinder_,
      configId = item.ConfigId,
      itemInfo = item.IsEquipItem and item.Item,
      uuid = item.IsEquipItem and item.Item.uuid,
      expendCount = not item.IsEquipItem and item.ExpendNum or nil,
      labType = not item.IsEquipItem and E.ItemLabType.Expend or nil,
      lab = self.itemsVm_.GetItemTotalCount(item.ConfigId),
      isSquareItem = true
    }
    self.choiceItemClass_:RefreshByData(itemData)
    self.choiceItemBinder_.Ref:SetVisible(self.choiceItemBinder_.btn_minus, true)
    self.consumeItem_ = item
  end
end

function Equip_recast_subView:getAttrData(attrArray)
  return self.equipAttrParseVM_.GetEquipAttrEffectByAttrDic(attrArray)
end

function Equip_recast_subView:setEquipAttr(equipAttr)
  for k, unit in pairs(self.allUnit_) do
    unit.effect:SetEffectGoVisible(false)
    unit.effect:Stop()
    unit.effect_blue:SetEffectGoVisible(false)
    unit.effect_blue:Stop()
  end
  self.equipAttr_ = equipAttr
  self.allUnit_ = {}
  self.newAttrData = {}
  self.isRecast_ = self.equipSystemVM_.CheckCanRecast(nil, self.selectedItemconfigId_)
  self:ClearAllUnits()
  local equipTableRow = Z.TableMgr.GetRow("EquipTableMgr", self.selectedItem_.configId)
  if equipTableRow == nil then
    return
  end
  if equipTableRow.BasicAttrLibId[1] ~= 2 then
    self:loadEquipAttrUnit(self:getAttrData(equipAttr.basicAttr), self.node_basics_item, "baseAttrInfo", true)
  else
    self:loadSchoolAttrUnits(true)
  end
  if equipTableRow.AdvancedAttrLibId[1] == 2 then
    self:loadSchoolAttrUnits(false)
  else
    self:loadEquipAttrUnit(self:getAttrData(equipAttr.rareQualityAttr), self.uiBinder.node_special_item, "rareQualityAttrInfo", false, false, true)
  end
  self:loadEquipAttrUnit(self:getAttrData(equipAttr.advanceAttr), self.node_special_item, "advanceAttrInfo", false)
  if self.isRecast_ then
    self:loadEquipAttrUnit(self:getAttrData(equipAttr.recastAttr), self.node_recast_item, "recastAttrInfo", false, true)
  end
end

function Equip_recast_subView:getBreakAttrByLibIds(attrLibIds, randomValue, talentSchoolId)
  local attrType = 0
  local basicAttr = {}
  for index, value in ipairs(attrLibIds) do
    if index == 1 then
      attrType = value
    elseif attrType == 1 then
      table.zmerge(basicAttr, self.equipAttrParseVM_.GetEquipAttrDataByAttrLibId(value, randomValue))
    else
      table.zmerge(basicAttr, self.equipAttrParseVM_.GetEquipAttrDataBySchoolAttrLibId(value, talentSchoolId, index - 1, randomValue))
    end
  end
  return basicAttr
end

function Equip_recast_subView:loadSchoolAttrUnits(isBasicAttr)
  local curProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  local talentSchoolId = self.equipCfgData_.TalentSchoolMap[self.talentSkillVm_.GetProfressionTalentStage(curProfessionId)]
  if isBasicAttr then
    local basicAttr = {}
    if self.equipAttr_ and table.zcount(self.equipAttr_.equipAttrSet.basicAttr) ~= 0 then
      basicAttr = self.equipAttrParseVM_.GetEquipShoolAttrByAttrDic(self.equipAttr_.equipAttrSet.basicAttr, talentSchoolId)
      self:loadEquipAttrUnit(basicAttr, self.uiBinder.node_basics_item, "baseAttrInfo", true)
    end
  else
    local advancedAttr = {}
    if self.equipAttr_ and table.zcount(self.equipAttr_.equipAttrSet.advanceAttr) ~= 0 then
      advancedAttr = self.equipAttrParseVM_.GetEquipShoolAttrByAttrDic(self.equipAttr_.equipAttrSet.advanceAttr, talentSchoolId)
      self:loadEquipAttrUnit(advancedAttr, self.uiBinder.node_special_item, "advanceAttrInfo", false)
    end
  end
end

function Equip_recast_subView:loadEquipAttrUnit(attrData, attrWidget, unitName, isBaseAttr, isRecastAttr, isRare)
  if attrData == nil or table.zcount(attrData) == nil then
    self.uiBinder.Ref:SetVisible(attrWidget, false)
    self.uiBinder.Ref:SetVisible(self.node_special_item, false)
    if isBaseAttr then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_basics_item, false)
    end
    return
  end
  local utilPath
  if Z.IsPCUI then
    utilPath = Z.ConstValue.Unit_equip_arr_tpl_pc
  else
    utilPath = Z.ConstValue.Unit_equip_arr_tpl
  end
  local equipRow
  if isRare then
    equipRow = Z.TableMgr.GetRow("EquipTableMgr", self.selectedItemconfigId_)
    if not equipRow or equipRow.QualitychiIdType == 0 then
      return
    end
  end
  local recommendAttrs, recommendDescAttrs = self.fightAttrParseVm_.GetRecommendFightAttrId()
  if attrData and 0 < #attrData then
    for key, value in ipairs(attrData) do
      local name = table.zconcat({unitName, key}, isRecastAttr and "recastAttr" or "_")
      local unit = self:AsyncLoadUiUnit(utilPath, name, attrWidget.transform)
      if unit then
        self.allUnit_[value.attrId] = unit
        self.newAttrData[value.attrId] = value.attrValue
        do
          local name = value.des
          local num = value.attrValue
          unit.Ref:SetVisible(unit.img_bg, isRecastAttr)
          if isRare then
            name = Z.RichTextHelper.ApplyColorTag(name, E.EquipRareQualityColor[equipRow.QualitychiIdType])
            num = Z.RichTextHelper.ApplyColorTag(num, E.EquipRareQualityColor[equipRow.QualitychiIdType])
            unit.img_icon:SetColorByHex(E.EquipRareQualityColor[equipRow.QualitychiIdType])
          else
            if not value.IsFitProfessionAttr then
              name = Z.RichTextHelper.ApplyColorTag(name, Z.Global.EquipAttColourNotSuitable)
              num = Z.RichTextHelper.ApplyColorTag(num, Z.Global.EquipAttColourNotSuitable)
            end
            unit.img_icon:SetColorByHex(E.ColorHexValues.White)
          end
          unit.Ref:SetVisible(unit.img_praise, table.zcontains(recommendAttrs, value.attrId))
          unit.lab_name.text = name
          unit.lab_num.text = num
          unit.Ref:SetVisible(unit.img_up_or_down, false)
          unit.img_icon:SetImage(value.iconPath)
          self:AddAsyncClick(unit.node_btn, function()
            self.fightAttrParseVm_.ShowRecommendAttrsTips(unit.Trans, recommendDescAttrs)
          end)
        end
      end
    end
  elseif isRecastAttr then
    self.uiBinder.Ref:SetVisible(self.basicsRef_, true)
    self.uiBinder.Ref:SetVisible(self.specialRef_, true)
    local recastUtilPath
    if Z.IsPCUI then
      recastUtilPath = GetLoadAssetPath(Z.ConstValue.Unit_Multi_Line_Labe_Addr_PC)
    else
      recastUtilPath = GetLoadAssetPath(Z.ConstValue.Unit_Multi_Line_Labe_Addr)
    end
    local name = table.zconcat({unitName, "recastAttr"}, "_")
    local unit = self:AsyncLoadUiUnit(recastUtilPath, name, attrWidget.transform)
    if unit then
      unit.Ref:SetVisible(unit.img_bg, true)
      unit.tmp_Desc.text = Z.RichTextHelper.ApplyColorTag(Lang("EquipNoRecastingState") .. Lang("RecastUnLock"), Z.Global.EquipAttColourNotActive)
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
          self.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(unit.effect)
          unit.effect:SetEffectGoVisible(true)
          unit.effect:Play()
        elseif newValue ~= lastValue then
          self.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(unit.effect_blue)
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
