local UI = Z.UI
local super = require("ui.ui_subview_base")
local Equip_enchant_subView = class("Equip_enchant_subView", super)
local equip_list_view_ = require("ui.view.equip_itemlist_view")
local itemClass = require("common.item_binder")
local loop_list = require("ui.component.loop_list_view")
local equip_enchant_left_view_ = require("ui.view.equip_enchant_left_sub_view")
local consumeItem = require("ui.component.equip.equip_refine_consume_item")
local attrLoopItem = require("ui.component.equip.equip_enchant_attr_loop_item")

function Equip_enchant_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "equip_enchant_sub", "equip/equip_enchant_sub", UI.ECacheLv.None, true)
  self.parent_ = parent
  self.equip_list_view_ = equip_list_view_.new(self)
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.attrParseVm_ = Z.VMMgr.GetVM("equip_attr_parse")
  self.enchantVm_ = Z.VMMgr.GetVM("equip_enchant")
  self.choiceItemClass_ = itemClass.new(self)
  self.filterFuncs_ = {}
  self.equipCfgData_ = Z.DataMgr.Get("equip_config_data")
  table.insert(self.filterFuncs_, self.equipVm_.CheckCanEnchant)
  self.enchantLeftSubView_ = equip_enchant_left_view_.new(self)
end

function Equip_enchant_subView:initBinders()
  self.prefabCache_ = self.uiBinder.prefabcache
  self.leftNode_ = self.uiBinder.node_left
  self.leftItemNode_ = self.uiBinder.node_left_item
  self.equipBtn_ = self.uiBinder.btn_equip_icon
  self.equipIcon_ = self.uiBinder.rimg_equip_icon
  self.equipName_ = self.uiBinder.lab_equip_name
  self.infoLab_ = self.uiBinder.lab_attention
  self.enchantBtn_ = self.uiBinder.btn_enchant
  self.expendItemLoopList_ = self.uiBinder.loop_item
  self.selectedItem_ = self.uiBinder.selected_item
  self.selectedImg_ = self.uiBinder.img_on
  self.addBtn_ = self.uiBinder.btn_add
  self.noEnchantLab_ = self.uiBinder.lab_noenchant
  self.noEnchantTitle_ = self.uiBinder.img_enchant_bg
  self.rightTitleLab_ = self.uiBinder.lab_enchant_title
  self.rightAttrContent_ = self.uiBinder.right_attr_content
  self.middleEnchantLoopList_ = self.uiBinder.loop_item_middle
  self.middleContent_ = self.uiBinder.middle_content
  self.contrastNode_ = self.uiBinder.node_contrast
  self.switch_ = self.uiBinder.switch
  self.minusBtn_ = self.uiBinder.btn_minus
  self.emptyNode_ = self.uiBinder.node_empty
  self.togNode_ = self.uiBinder.node_expend_01
  self.selectedEnchantItemNameLab_ = self.uiBinder.lab_name
  self.enchantInfoNode_ = self.uiBinder.node_enchant_info
  self.middleEquipNode_ = self.uiBinder.node_middle_equip
  self.middleEnchantNode_ = self.uiBinder.node_enchant
  self.middleName_ = self.uiBinder.lab_enchant_name
  self.anim_do_ = self.uiBinder.anim_do
  self.togsBinder_ = self.uiBinder.togs_tab
  self.togs_ = {}
  self.line1_ = self.togsBinder_.img_line_1
  self.line2_ = self.togsBinder_.img_line_2
  self.togs_[E.EnchantType.Common] = self.togsBinder_.tog_common
  self.togs_[E.EnchantType.Middle] = self.togsBinder_.tog_middle
  self.togs_[E.EnchantType.Advanced] = self.togsBinder_.tog_advanced
  for index, value in ipairs(self.togs_) do
    value.group = self.togsBinder_.tog_group
  end
  self.rightNode_ = self.uiBinder.node_right
  self.middleNode_ = self.uiBinder.node_middle
end

function Equip_enchant_subView:initBtns()
  self:AddClick(self.minusBtn_, function()
    self.selectedEnchantItemRow_ = nil
    self.switch_.IsOn = false
    self:refreshRightInfo()
  end)
  self:AddClick(self.addBtn_, function()
    if not self.selectedEnchantItemRow_ then
      self.enchantLeftSubView_:Active(self.enchantVm_.GetSelectedEnchantItems(self.selectedItemConfigId_), self.leftItemNode_.transform)
      self.anim_do_:Restart(Z.DOTweenAnimType.Tween_0)
    end
  end)
  self:AddClick(self.switch_, function(isOn)
    self.uiBinder.Ref:SetVisible(self.middleEnchantNode_, isOn)
    self.uiBinder.Ref:SetVisible(self.middleEquipNode_, not isOn)
  end)
  self:AddClick(self.togs_[E.EnchantType.Common], function(isOn)
    if isOn then
      self.selectedTogType_ = E.EnchantType.Common
      self:refreshConsumeLoop()
    end
  end)
  self:AddClick(self.togs_[E.EnchantType.Middle], function(isOn)
    if isOn then
      self.selectedTogType_ = E.EnchantType.Middle
      self:refreshConsumeLoop()
    end
  end)
  self:AddClick(self.togs_[E.EnchantType.Advanced], function(isOn)
    if isOn then
      self.selectedTogType_ = E.EnchantType.Advanced
      self:refreshConsumeLoop()
    end
  end)
  self:AddAsyncClick(self.enchantBtn_, function()
    if self.selectedEnchantItemRow_ == nil then
      Z.TipsVM.ShowTips(150028)
      return
    end
    if self.enchantDatas_ and self.enchantDatas_[self.selectedTogType_] then
      if not self:checkItemCount(self.selectedEnchantItemRow_.Id, 1) then
        return
      end
      local data = self.enchantDatas_[self.selectedTogType_].EnchantConsume
      for index, value in ipairs(data) do
        if not self:checkItemCount(value[1], value[2]) then
          return
        end
      end
    end
    local func = function()
      self.enchantVm_.AsyncEquipEnchant(self.selectedItemUuid_, self.selectedEnchantItemRow_.Id, self.selectedTogType_, self.cancelSource:CreateToken())
    end
    local item = self.itemsVm_.GetItemInfobyItemId(self.selectedItemUuid_, self.selectedItemConfigId_)
    if item and item.bindFlag ~= 0 then
      self.equipVm_.OpenDayDialog(func, Lang("EquipEnchantBindingTips"), E.DlgPreferencesKeyType.EquipRecastingBindingTips)
      return
    end
    if Z.ContainerMgr.CharSerialize.equip.equipEnchant[self.selectedItemUuid_] then
      Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("EquipEnchantCoverTips"), func, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.EquipChangeEnchantItem)
      return
    end
    func()
  end)
  self:AddClick(self.equipBtn_, function()
    if self.tipsId_ then
      Z.TipsVM.CloseItemTipsView(self.tipsId_)
      self.tipsId_ = nil
    end
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.equipBtn_.transform, self.selectedItemConfigId_, self.selectedItemUuid_)
  end)
end

function Equip_enchant_subView:checkItemCount(configId, expendCount)
  local count = self.itemsVm_.GetItemTotalCount(configId)
  if expendCount > count then
    local itemRow = Z.TableMgr.GetRow("ItemTableMgr", configId)
    if itemRow then
      Z.TipsVM.ShowTips(150026, {
        val = itemRow.Name
      })
    end
    self.sourceTipsId_ = Z.TipsVM.OpenSourceTips(configId, self.enchantBtn_.transform)
    return false
  end
  return true
end

function Equip_enchant_subView:initData()
  self.selectedEnchantItemRow_ = nil
  self.nowEnchantAttr_ = {}
  self.rightAttrUnits_ = {}
  self.rightAttrTokens_ = {}
  self.middleAttrUnits_ = {}
  self.switchUnitName_ = ""
end

function Equip_enchant_subView:initUI()
  local itemPath
  if Z.IsPCUI then
    itemPath = "com_item_square_3_8_pc"
  else
    itemPath = "com_item_square_3_8"
  end
  self.loopListView_ = loop_list.new(self, self.expendItemLoopList_, consumeItem, itemPath)
  self.loopListView_:Init({})
  if self.viewData and self.viewData.configId and self.viewData.itemUuid then
    self.equip_list_view_:Active({
      funcViewType = E.EquipFuncViewType.Enchant,
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
      funcViewType = E.EquipFuncViewType.Enchant,
      filterFuncs = self.filterFuncs_,
      showItemTips = true,
      itemSelectedFunc = function(itemUuid, configId)
        self:onItemSelected(itemUuid, configId)
      end
    }, self.uiBinder.node_left.transform)
  end
  local choiceItemData = {
    uiBinder = self.selectedItem_
  }
  self.choiceItemClass_:Init(choiceItemData)
  self.selectedItem_.Ref.UIComp:SetVisible(false)
  self.uiBinder.Ref:SetVisible(self.selectedImg_, false)
  self.uiBinder.Ref:SetVisible(self.middleEquipNode_, true)
  self.switch_.IsOn = false
  self:refreshRightInfo()
end

function Equip_enchant_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.Ref.UIComp.UIDepth)
  self:bindEvents()
  self:initBinders()
  self:onStartAnimShow()
  self:initBtns()
  self:initData()
  self:initUI()
end

function Equip_enchant_subView:refreshConsumeLoop()
  if self.selectedEnchantItemRow_ and self.enchantDatas_ and self.enchantDatas_[self.selectedTogType_] then
    self.loopListView_:RefreshListView(self.enchantDatas_[self.selectedTogType_].EnchantConsume)
  end
  self:setPreviewAttr()
end

function Equip_enchant_subView:onItemSelected(itemUuid, configId)
  self.selectedItemConfigId_ = configId
  self.selectedItemUuid_ = itemUuid
  self.equipName_.text = self.itemsVm_.ApplyItemNameWithQualityTag(configId)
  self.equipIcon_:SetImage(self.itemsVm_.GetItemIcon(configId))
  self.curEquipEnchantInfo_ = Z.ContainerMgr.CharSerialize.equip.equipEnchant[itemUuid]
  if self.curEquipEnchantInfo_ then
    self.curEnchantRow_ = self.enchantVm_.GetEnchantItemByTypeAndLevel(self.curEquipEnchantInfo_.enchantItemTypeId, self.curEquipEnchantInfo_.enchantLevel)
    if self.curEnchantRow_ then
      self.nowEnchantAttr_ = self.enchantVm_.GetAttrByEnchantItemRow(self.curEnchantRow_)
      local name = self.itemsVm_.ApplyItemNameWithQualityTag(self.curEnchantRow_.Id)
      self.middleName_.text = name
    end
  else
    self.curEnchantRow_ = nil
    self.nowEnchantAttr_ = {}
  end
  self.switch_.IsOn = false
  self.selectedItem_.Ref.UIComp:SetVisible(false)
  self.uiBinder.Ref:SetVisible(self.selectedImg_, false)
  self.selectedEnchantItemRow_ = nil
  self:refreshMiddleAttrs()
  self:refreshRightInfo()
end

function Equip_enchant_subView:equipEnchantResult(isSuccess)
  if isSuccess then
    self.recastSucceed_ = true
    self.equip_list_view_:RefreshItemInfoDatas()
    self.equip_list_view_:Active({
      funcViewType = E.EquipFuncViewType.Enchant,
      showItemTips = true,
      partId = self.equip_list_view_:GetCurSelectPartId(),
      itemSelectedFunc = function(itemUuid, configId)
        self:onItemSelected(itemUuid, configId)
      end,
      itemUuid = self.selectedItemUuid_,
      configId = self.selectedItemConfigId_
    }, self.uiBinder.node_left.transform)
  end
end

function Equip_enchant_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Equip.RefreshEmptyState, self.EmptyState, self)
  Z.EventMgr:Add(Z.ConstValue.Equip.SelectedEnchantItem, self.selectedEnchantItem, self)
  Z.EventMgr:Add(Z.ConstValue.Equip.EquipEnchantResult, self.equipEnchantResult, self)
end

function Equip_enchant_subView:selectedEnchantItem(item)
  if item then
    local itemData = {
      uiBinder = self.selectedItem_,
      configId = item.Id,
      isSquareItem = true,
      isClickOpenTips = true
    }
    self.choiceItemClass_:RefreshByData(itemData)
    self.selectedEnchantItemRow_ = item
    self:refreshRightInfo()
    if self.curEquipEnchantInfo_ then
      self.switch_.IsOn = true
    end
    if self.curEquipEnchantInfo_ then
      self.togs_[self.curEquipEnchantInfo_.enchantType].isOn = true
    end
    self:refreshConsumeLoop()
  end
end

function Equip_enchant_subView:refreshRightInfo()
  if self.selectedEnchantItemRow_ then
    local equipRow = Z.TableMgr.GetRow("EquipTableMgr", self.selectedItemConfigId_)
    if equipRow then
      self.enchantDatas_ = self.equipCfgData_.EnchantTableData[equipRow.EnchantId]
    end
    if self.enchantDatas_ then
      for index, value in ipairs(self.togs_) do
        self.togsBinder_.Ref:SetVisible(value, self.enchantDatas_[index] ~= nil)
      end
      self.togsBinder_.Ref:SetVisible(self.line1_, self.enchantDatas_[E.EnchantType.Common] ~= nil)
      self.togsBinder_.Ref:SetVisible(self.line2_, self.enchantDatas_[E.EnchantType.Advanced] ~= nil)
      self.selectedTogType_ = E.EnchantType.Common
      self.togs_[E.EnchantType.Common].isOn = true
    end
    self.rightTitleLab_.text = Lang("Postenchantmentstate")
    self:setPreviewAttr()
  else
    self.rightTitleLab_.text = Lang("Enchantment")
    self:refreshRightAttrs()
  end
  self:refreshTipsNode()
end

function Equip_enchant_subView:refreshTipsNode()
  local isSelectedItem = self.selectedEnchantItemRow_ ~= nil
  self.selectedItem_.Ref.UIComp:SetVisible(isSelectedItem)
  self.uiBinder.Ref:SetVisible(self.selectedImg_, isSelectedItem)
  self.uiBinder.Ref:SetVisible(self.minusBtn_, isSelectedItem)
  self.uiBinder.Ref:SetVisible(self.emptyNode_, not isSelectedItem)
  self.uiBinder.Ref:SetVisible(self.togNode_, isSelectedItem)
  if not isSelectedItem then
    self.uiBinder.Ref:SetVisible(self.noEnchantLab_, self.nowEnchantAttr_ and #self.nowEnchantAttr_ == 0)
    self.uiBinder.Ref:SetVisible(self.noEnchantTitle_, self.nowEnchantAttr_ and #self.nowEnchantAttr_ == 0)
    self.selectedEnchantItemNameLab_.text = Lang("PleaseSelectAMagicStone")
  else
    self.uiBinder.Ref:SetVisible(self.noEnchantLab_, false)
    self.uiBinder.Ref:SetVisible(self.noEnchantTitle_, false)
    local name = self.itemsVm_.ApplyItemNameWithQualityTag(self.selectedEnchantItemRow_.Id)
    self.selectedEnchantItemNameLab_.text = name
  end
  self.uiBinder.Ref:SetVisible(self.expendItemLoopList_, isSelectedItem)
  self.uiBinder.Ref:SetVisible(self.contrastNode_, isSelectedItem and self.curEnchantRow_ ~= nil)
end

function Equip_enchant_subView:EmptyState(state)
  self.uiBinder.Ref:SetVisible(self.rightNode_, state)
  self.uiBinder.Ref:SetVisible(self.middleNode_, state)
end

function Equip_enchant_subView:setPreviewAttr()
  if self.selectedEnchantItemRow_ == nil then
    return
  end
  local attrTpl = self.prefabCache_:GetString("attr_tpl")
  if not attrTpl or attrTpl == "" then
    return
  end
  local itemPath = self.prefabCache_:GetString("equip_enchant_lab_item_tpl")
  if not itemPath or itemPath == "" then
    return
  end
  local equipEnchantItemTables = self.equipCfgData_.EnchantItemTableData[self.selectedEnchantItemRow_.EnchantItemTypeId]
  if equipEnchantItemTables == nil then
    return
  end
  local effects = {}
  if self.selectedTogType_ == E.EnchantType.Common then
    effects = self.selectedEnchantItemRow_.OrdinaryAddEffects
  elseif self.selectedTogType_ == E.EnchantType.Middle then
    effects = self.selectedEnchantItemRow_.IntermediateAddEffects
  elseif self.selectedTogType_ == E.EnchantType.Advanced then
    effects = self.selectedEnchantItemRow_.AdvancedAddEffects
  end
  local langKey = 1 < #effects and "EquipEnchantProbabilityTips" or "EquipEnchantTypeOrdinaryTips"
  for index, value in pairs(self.rightAttrTokens_) do
    Z.CancelSource.ReleaseToken(value)
  end
  self.rightAttrTokens_ = {}
  for k, v in pairs(self.rightAttrUnits_) do
    self:RemoveUiUnit(k)
  end
  self.rightAttrUnits_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    for key, value in ipairs(effects) do
      local level = value[1]
      local rate = math.floor(value[2] / 100)
      local row = equipEnchantItemTables[level]
      if row then
        local attrs = self.enchantVm_.GetAttrByEnchantItemRow(row)
        if attrs and 0 < #attrs then
          local unitName = "preview_attr_node" .. key
          local token = self.cancelSource:CreateToken()
          self.rightAttrTokens_[unitName] = token
          local unit = self:AsyncLoadUiUnit(attrTpl, unitName, self.rightAttrContent_.transform, token)
          if unit then
            self.rightAttrUnits_[unitName] = unit
            self:AddClick(unit.tog, function(isOn)
              unit.Ref:SetVisible(unit.content, isOn)
            end)
            unit.Ref:SetVisible(unit.content, true)
            unit.tog.isOn = true
            unit.lab_equip_enchant.text = 1 < #effects and Lang(langKey, {val = rate}) or Lang(langKey .. key)
            unit.lab_enchant_name.text = self.itemsVm_.ApplyItemNameWithQualityTag(row.Id)
            for index, data in ipairs(attrs) do
              local token = self.cancelSource:CreateToken()
              local itemName = "preview_attr" .. key .. index
              self.rightAttrTokens_[itemName] = token
              local item = self:AsyncLoadUiUnit(itemPath, itemName, unit.content.transform, token)
              if item then
                self.rightAttrUnits_[itemName] = item
                local isBuffAttr = data.attrType == E.RemodelInfoType.Buff
                item.Ref:SetVisible(item.lab_content, isBuffAttr)
                item.Ref:SetVisible(item.node_lab_01, not isBuffAttr)
                if isBuffAttr then
                  item.lab_content.text = data.buffInfo
                else
                  item.lab_nature.text = data.attrName
                  item.lab_number.text = "+" .. data.attrValue
                end
              end
            end
          end
        end
      end
    end
  end)()
end

function Equip_enchant_subView:refreshRightAttrs()
  for index, value in pairs(self.rightAttrTokens_) do
    Z.CancelSource.ReleaseToken(value)
  end
  self.rightAttrTokens_ = {}
  for k, v in pairs(self.rightAttrUnits_) do
    self:RemoveUiUnit(k)
  end
  self.rightAttrUnits_ = {}
  if not self.nowEnchantAttr_ or #self.nowEnchantAttr_ == 0 then
    return
  end
  local itemPath = self.prefabCache_:GetString("equip_enchant_lab_item_tpl_1")
  if not itemPath or itemPath == nil then
    return
  end
  local attrTpl = self.prefabCache_:GetString("attr_tpl")
  if not attrTpl or attrTpl == "" then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local unitName = "right_attr_node"
    local token = self.cancelSource:CreateToken()
    self.rightAttrTokens_[unitName] = token
    local unit = self:AsyncLoadUiUnit(attrTpl, unitName, self.rightAttrContent_.transform, token)
    if unit then
      self:AddClick(unit.tog, function(isOn)
        unit.Ref:SetVisible(unit.content, isOn)
      end)
      unit.Ref:SetVisible(unit.content, true)
      unit.tog.isOn = true
      self.rightAttrUnits_[unitName] = unit
      unit.lab_equip_enchant.text = Lang("EnchantResult")
      unit.lab_enchant_name.text = self.itemsVm_.ApplyItemNameWithQualityTag(self.curEnchantRow_.Id)
      for index, data in ipairs(self.nowEnchantAttr_) do
        local itemName = "right_attr" .. index
        local item = self:AsyncLoadUiUnit(itemPath, itemName, unit.content.transform)
        if item then
          self.rightAttrUnits_[itemName] = item
          local isBuffAttr = data.attrType == E.RemodelInfoType.Buff
          item.Ref:SetVisible(item.lab_content, isBuffAttr)
          item.Ref:SetVisible(item.node_lab_01, not isBuffAttr)
          self:onPlayEffAnim(item)
          if isBuffAttr then
            item.lab_content.text = data.buffInfo
          else
            item.lab_nature.text = data.attrName
            item.lab_number.text = "+" .. data.attrValue
          end
          self.middleAttrUnits_[unitName] = item
        end
      end
    end
  end)()
end

function Equip_enchant_subView:onPlayEffAnim(unitItem)
  if self.recastSucceed_ then
    unitItem.Ref:SetVisible(unitItem.node_eff, true)
    unitItem.anim_light:PlayByTime("anim_item_equip_light_01_tpl_open", -1)
  else
    unitItem.Ref:SetVisible(unitItem.node_eff, false)
  end
end

function Equip_enchant_subView:refreshMiddleAttrs()
  local itemPath = self.prefabCache_:GetString("equip_enchant_lab_item_tpl_1")
  if not itemPath or itemPath == nil then
    return
  end
  for k, v in pairs(self.middleAttrUnits_) do
    self:RemoveUiUnit(k)
  end
  self.middleAttrUnits_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    for index, data in ipairs(self.nowEnchantAttr_) do
      local unitName = "middleAttrs" .. index
      local unit = self:AsyncLoadUiUnit(itemPath, unitName, self.middleContent_.transform)
      if unit then
        local isBuffAttr = data.attrType == E.RemodelInfoType.Buff
        unit.Ref:SetVisible(unit.lab_content, isBuffAttr)
        unit.Ref:SetVisible(unit.node_lab_01, not isBuffAttr)
        if isBuffAttr then
          unit.lab_content.text = data.buffInfo
        else
          unit.lab_nature.text = data.attrName
          unit.lab_number.text = "+" .. data.attrValue
        end
        self.middleAttrUnits_[unitName] = unit
      end
    end
  end)()
end

function Equip_enchant_subView:OnDeActive()
  if self.loopListView_ then
    self.loopListView_:UnInit()
    self.loopListView_ = nil
  end
  self.equip_list_view_:DeActive()
  self.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.Ref.UIComp.UIDepth)
  if self.sourceTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipsId_)
  end
  self.enchantLeftSubView_:DeActive()
end

function Equip_enchant_subView:OnRefresh()
end

function Equip_enchant_subView:onStartAnimShow()
  self.anim_do_:Restart(Z.DOTweenAnimType.Open)
end

return Equip_enchant_subView
