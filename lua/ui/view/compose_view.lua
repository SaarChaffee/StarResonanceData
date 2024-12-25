local UI = Z.UI
local super = require("ui.ui_view_base")
local ComposeView = class("ComposeView", super)
local item = require("common.item")
local loopScrollRect = require("ui/component/loopscrollrect")
local compose_catalogue_item = require("ui.component.compose.compose_catalogue_loop_item")
local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")
local itemTypeTbl = Z.TableMgr.GetTable("ItemTypeTableMgr")
local composeTbl = Z.TableMgr.GetTable("ComposeTableMgr")
local EUnitName = {
  bindConsume = "bindConsume",
  unbindConsume = "unbindConsume",
  bindProduct = "bindProduct",
  unbindProduct = "unbindProduct"
}

function ComposeView:ctor()
  self.panel = nil
  super.ctor(self, "compose")
  self.composeVM_ = Z.VMMgr.GetVM("compose")
  self.productTipsId_ = nil
  self.consumeTipsId_ = nil
end

function ComposeView:SwitchItemByConsumeId(id)
  if self.consumeId_ == id then
    return
  end
  self.consumeId_ = id
  if self.consumeId_ == -1 then
    self.panel.module_operation:SetVisible(false)
    self.panel.module_product_tips:SetVisible(false)
    if self.isAllUnitLoaded_ then
      self.units[EUnitName.bindConsume]:SetVisible(false)
      self.units[EUnitName.unbindConsume]:SetVisible(false)
      self.units[EUnitName.bindProduct]:SetVisible(false)
      self.units[EUnitName.unbindProduct]:SetVisible(false)
    end
    return
  end
  self.panel.module_operation:SetVisible(true)
  self.panel.module_product_tips:SetVisible(true)
  self.composeData_ = composeTbl.GetRow(self.consumeId_)
  self.ownNumData_ = self.composeVM_.GetOwnNumDataByConsumeId(self.consumeId_)
  if self.composeData_ == nil then
    return
  end
  self.panel.tog_only_unbind:SetVisible(self.composeData_.ConsumableTips == 1)
  self.panel.tog_only_unbind.Tog.isOn = false
  self:setComposeTimes(1)
  self:refreshOperationItemIcon()
  self:refreshProbability()
  local productTipsData = {}
  productTipsData.tipsId = self.productTipsId_
  productTipsData.configId = self.composeData_.ObtainID
  productTipsData.showType = E.EItemTipsShowType.OnlyClient
  productTipsData.isResident = true
  productTipsData.posType = E.EItemTipsPopType.Parent
  productTipsData.parentTrans = self.panel.module_product_tips.Trans
  productTipsData.isVisible = true
  productTipsData.isShowBg = true
  self.productTipsId_ = Z.TipsVM.OpenItemTipsView(productTipsData)
  Z.TipsVM.SetItemTipsVisible(self.consumeTipsId_, false)
end

function ComposeView:ShowConsumeItemTips(consumeId)
  local consumeTipsData = {}
  consumeTipsData.tipsId = self.consumeTipsId_
  consumeTipsData.configId = consumeId
  consumeTipsData.posType = E.EItemTipsPopType.Parent
  consumeTipsData.isResident = true
  consumeTipsData.showType = E.EItemTipsShowType.OnlyClient
  consumeTipsData.parentTrans = self.panel.module_consume_tips.Trans
  consumeTipsData.isVisible = true
  consumeTipsData.isShowBg = true
  self.consumeTipsId_ = Z.TipsVM.OpenItemTipsView(consumeTipsData)
end

function ComposeView:OnActive()
  self.consumeId_ = -1
  self.composeTimes_ = 1
  self.isAllUnitLoaded_ = false
  self.typeList_ = {}
  self.selectType_ = 0
  self.isConsumeEnough_ = false
  self.catalogueItemDataList_ = nil
  self.unbindToBindNum_ = 0
  self.itemClassTab_ = {}
  self.panel.module_operation:SetVisible(false)
  self.panel.module_product_tips:SetVisible(false)
  self:initCatalogueData()
  self:initCatalogue()
  self:initOperationInfo()
  self:AddClick(self.panel.btn_close.Btn, function()
    self.composeVM_.CloseComposeView()
  end)
  self:AddClick(self.panel.btn_bg.Btn, function()
    Z.TipsVM.SetItemTipsVisible(self.consumeTipsId_, false)
  end)
  self:AddClick(self.panel.btn_add.Btn, function()
    self:onClickAddBtn()
  end)
  self:AddClick(self.panel.btn_subtract.Btn, function()
    self:onClickSubtractBtn()
  end)
  self:AddAsyncClick(self.panel.btn_compose.Btn, function()
    self:onClickComposeBtn()
  end)
  self.panel.tog_only_unbind.Tog:AddListener(function(isOn)
    self:refreshOperationItemIcon()
  end)
  self.panel.tog_show_composable.Tog:AddListener(function(isOn)
    self:refreshCatalogueScroll(true)
  end)
  self:BindEvents()
end

function ComposeView:initCatalogueData()
  self.catalogueItemDataList_ = self.composeVM_.GetComposeCatalogueItemDataList()
  if self.viewData.selectId ~= nil then
    local selectData_
    for index, data in ipairs(self.catalogueItemDataList_) do
      if data.configId == self.viewData.selectId then
        selectData_ = data
        table.remove(self.catalogueItemDataList_, index)
        break
      end
    end
    table.insert(self.catalogueItemDataList_, 1, selectData_)
  end
end

function ComposeView:initCatalogue()
  self.panel.dpd_type.Dropdown:AddListener(function(index)
    self.selectType_ = self.typeList_[index + 1]
    self:refreshCatalogueScroll(true)
  end, true)
  self.catalogueScrollRect_ = loopScrollRect.new(self.panel.loopscroll_catalogue.VLoopScrollRect, self, compose_catalogue_item)
  self:refreshItemTypeDropdown()
  self:refreshCatalogueScroll(true)
end

function ComposeView:refreshItemTypeDropdown()
  self.typeList_ = {}
  local type2Name = {}
  for _, data in ipairs(self.catalogueItemDataList_) do
    local cfgData = itemTbl.GetRow(data.configId)
    if cfgData then
      local type = cfgData.Type
      if type2Name[type] == nil then
        local typeData = itemTypeTbl.GetRow(type)
        if typeData then
          type2Name[type] = typeData.Name
          table.insert(self.typeList_, type)
        end
      end
    end
  end
  table.sort(self.typeList_, function(left, right)
    local leftData = itemTypeTbl.GetRow(left)
    local rightData = itemTypeTbl.GetRow(right)
    if leftData == nil or rightData == nil then
      return false
    end
    local rightSortId = rightData.SortId
    local leftSortId = leftData.SortId
    if leftSortId ~= rightSortId then
      return rightSortId < leftSortId
    end
    return right < left
  end)
  table.insert(self.typeList_, 1, 0)
  type2Name[0] = Lang("All")
  local options = {}
  for _, type in ipairs(self.typeList_) do
    table.insert(options, type2Name[type])
  end
  self.panel.dpd_type.Dropdown:ClearOptions()
  self.panel.dpd_type.Dropdown:AddOptions(options)
end

function ComposeView:refreshCatalogueScroll(isResetSelect)
  local rangeList = {}
  if self.panel.tog_show_composable.Tog.isOn then
    for _, data in ipairs(self.catalogueItemDataList_) do
      local cfgData = composeTbl.GetRow(data.configId)
      if cfgData then
        if data.num >= cfgData.Nums then
          table.insert(rangeList, data)
        end
      else
        logError("composeTbl key={0} is null", data.configId)
      end
    end
  else
    rangeList = self.catalogueItemDataList_
  end
  local itemDataList = {}
  if self.selectType_ == 0 then
    itemDataList = rangeList
  else
    for _, data in ipairs(rangeList) do
      local itemData = itemTbl.GetRow(data.configId)
      if itemData and self.selectType_ == itemData.Type then
        table.insert(itemDataList, data)
      end
    end
  end
  if isResetSelect then
    self.catalogueScrollRect_:ClearSelected()
    self.catalogueScrollRect_:SetData(itemDataList)
    self.catalogueScrollRect_:SetSelected(0)
  else
    local scrollSelectIndex = -1
    for index, data in ipairs(itemDataList) do
      if self.consumeId_ == data.configId then
        scrollSelectIndex = index - 1
      end
    end
    if scrollSelectIndex == -1 then
      local lastSelected_ = self.catalogueScrollRect_:GetSelected()
      scrollSelectIndex = lastSelected_ == -1 and 0 or math.min(lastSelected_, #itemDataList - 1)
    end
    self.catalogueScrollRect_:ClearSelected()
    self.catalogueScrollRect_:SetData(itemDataList)
    self.catalogueScrollRect_:SetSelected(scrollSelectIndex)
  end
  if next(itemDataList) == nil then
    self:SwitchItemByConsumeId(-1)
  end
end

function ComposeView:initOperationInfo()
  Z.CoroUtil.create_coro_xpcall(function()
    local assetPath = "ui/prefabs/new_common/c_com_item_backpack_tpl"
    self:AsyncLoadUiUnit(assetPath, EUnitName.bindConsume, self.panel.module_consume.Trans)
    self:AsyncLoadUiUnit(assetPath, EUnitName.unbindConsume, self.panel.module_consume.Trans)
    self:AsyncLoadUiUnit(assetPath, EUnitName.bindProduct, self.panel.module_product.Trans)
    self:AsyncLoadUiUnit(assetPath, EUnitName.unbindProduct, self.panel.module_product.Trans)
    self.itemClassTab_[EUnitName.bindConsume] = item.new(self)
    self.itemClassTab_[EUnitName.unbindConsume] = item.new(self)
    self.itemClassTab_[EUnitName.bindProduct] = item.new(self)
    self.itemClassTab_[EUnitName.unbindProduct] = item.new(self)
    self.isAllUnitLoaded_ = true
    self:refreshOperationItemIcon()
  end)()
end

function ComposeView:setComposeTimes(times)
  self.composeTimes_ = times
  self.panel.lab_compose_num.TMPLab.text = tostring(self.composeTimes_)
end

function ComposeView:refreshOperationItemIcon()
  if not self.isAllUnitLoaded_ then
    return
  end
  if self.consumeId_ == -1 then
    self.units[EUnitName.bindConsume]:SetVisible(false)
    self.units[EUnitName.unbindConsume]:SetVisible(false)
    self.units[EUnitName.bindProduct]:SetVisible(false)
    self.units[EUnitName.unbindProduct]:SetVisible(false)
    return
  end
  self.isConsumeEnough_ = true
  local consumeTotalNum = self.composeTimes_ * self.composeData_.Nums
  local consumeNumData = self:getConsumeNumData(consumeTotalNum)
  local consumeBindNum = consumeNumData.bind
  local consumeUnbindNum = consumeNumData.unbind
  local productBindNum = math.ceil(consumeBindNum / self.composeData_.Nums) * self.composeData_.ObtainNum
  local productUnbindNum = self.composeTimes_ * self.composeData_.ObtainNum - productBindNum
  if consumeBindNum % self.composeData_.Nums ~= 0 then
    self.unbindToBindNum_ = self.composeData_.Nums - consumeBindNum % self.composeData_.Nums
  else
    self.unbindToBindNum_ = 0
  end
  local itemUnit = self.units[EUnitName.bindConsume]
  if self.ownNumData_.bind ~= 0 or consumeBindNum ~= 0 then
    itemUnit:SetVisible(true)
    itemUnit.cont_info.img_bind:SetVisible(true)
    local countStr = consumeBindNum .. "/" .. self.ownNumData_.bind
    if consumeBindNum > self.ownNumData_.bind then
      countStr = Z.RichTextHelper.ApplyStyleTag(countStr, E.TextStyleTag.Red)
      self.isConsumeEnough_ = false
    end
    self.itemClassTab_[EUnitName.bindConsume]:Init({
      unit = itemUnit,
      configId = self.composeData_.Id,
      lab = countStr,
      labType = E.ItemLabType.Str
    })
  else
    itemUnit:SetVisible(false)
  end
  itemUnit = self.units[EUnitName.unbindConsume]
  if self.ownNumData_.unbind ~= 0 or consumeUnbindNum ~= 0 then
    itemUnit:SetVisible(true)
    itemUnit.cont_info.img_bind:SetVisible(false)
    local countStr = consumeUnbindNum .. "/" .. self.ownNumData_.unbind
    if consumeUnbindNum > self.ownNumData_.unbind then
      countStr = Z.RichTextHelper.ApplyStyleTag(countStr, E.TextStyleTag.Red)
      self.isConsumeEnough_ = false
    end
    self.itemClassTab_[EUnitName.unbindConsume]:Init({
      unit = itemUnit,
      configId = self.composeData_.Id,
      lab = countStr,
      labType = E.ItemLabType.Str
    })
  else
    itemUnit:SetVisible(false)
  end
  itemUnit = self.units[EUnitName.bindProduct]
  if productBindNum ~= 0 then
    itemUnit:SetVisible(true)
    self.itemClassTab_[EUnitName.bindProduct]:Init({
      unit = itemUnit,
      configId = self.composeData_.ObtainID,
      lab = productBindNum,
      labType = E.ItemLabType.Str
    })
    itemUnit.cont_info.img_bind:SetVisible(true)
    itemUnit.cont_info.lab_count:SetVisible(productBindNum ~= 1)
  else
    itemUnit:SetVisible(false)
  end
  itemUnit = self.units[EUnitName.unbindProduct]
  if productUnbindNum ~= 0 then
    itemUnit:SetVisible(true)
    self.itemClassTab_[EUnitName.unbindProduct]:Init({
      unit = itemUnit,
      configId = self.composeData_.ObtainID,
      lab = productUnbindNum,
      labType = E.ItemLabType.Str
    })
    itemUnit.cont_info.img_bind:SetVisible(false)
    itemUnit.cont_info.lab_count:SetVisible(productUnbindNum ~= 1)
  else
    itemUnit:SetVisible(false)
  end
end

function ComposeView:getConsumeNumData(totalNum)
  local bindNum = 0
  local unbindNum = 0
  if self.panel.tog_only_unbind.Tog.isOn then
    unbindNum = totalNum
  elseif self.ownNumData_.bind == 0 and self.ownNumData_.unbind ~= 0 then
    unbindNum = totalNum
  elseif self.ownNumData_.bind ~= 0 and self.ownNumData_.unbind == 0 then
    bindNum = totalNum
  else
    if totalNum <= self.ownNumData_.bind + self.ownNumData_.unbind then
      bindNum = math.min(totalNum, self.ownNumData_.bind)
    else
      bindNum = totalNum - self.ownNumData_.unbind
    end
    unbindNum = totalNum - bindNum
  end
  return {bind = bindNum, unbind = unbindNum}
end

function ComposeView:refreshProbability()
  local probability = self.composeData_.SuccessfulProbability // 100
  self.panel.module_probability:SetVisible(probability ~= 100)
  local fProbability = self.composeData_.SuccessfulProbability / 100
  local param = Z.Placeholder.SetMePlaceholder({})
  param.val = fProbability
  self.panel.lab_probability.TMPLab.text = Lang("SuccessfulProbability", param)
end

function ComposeView:onClickAddBtn()
  local consumeTotalNum = (self.composeTimes_ + 1) * self.composeData_.Nums
  if consumeTotalNum > self.ownNumData_.bind + self.ownNumData_.unbind then
    Z.TipsVM.ShowTipsLang(100114)
    return
  end
  self:setComposeTimes(self.composeTimes_ + 1)
  self:refreshOperationItemIcon()
end

function ComposeView:onClickSubtractBtn()
  if self.composeTimes_ <= 1 then
    return
  end
  self:setComposeTimes(self.composeTimes_ - 1)
  self:refreshOperationItemIcon()
end

function ComposeView:onClickComposeBtn()
  self:checkIsConsumeEnough()
end

function ComposeView:checkIsConsumeEnough()
  if self.isConsumeEnough_ then
    self:checkIsProbabilityEnough()
  else
    Z.TipsVM.ShowTipsLang(100112)
  end
end

function ComposeView:checkIsProbabilityEnough()
  if self.composeData_.SuccessfulProbability // 100 < 100 then
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("ComposeProbabilityNotEnough"), function()
      self:checkIsUnbindToBind()
      Z.DialogViewDataMgr:CloseDialogView()
    end)
  else
    self:checkIsUnbindToBind()
  end
end

function ComposeView:checkIsUnbindToBind()
  if self.unbindToBindNum_ ~= 0 then
    local consumeData = itemTbl.GetRow(self.consumeId_)
    if consumeData == nil then
      return
    end
    local consumeName = consumeData.Name
    local obtainData = itemTbl.GetRow(self.composeData_.ObtainID)
    if obtainData == nil then
      return
    end
    local productName = obtainData.Name
    local param = {
      item = {
        names = {
          [1] = consumeName,
          [2] = productName
        },
        num = self.unbindToBindNum_
      }
    }
    local desc = Lang("ComposeUnbindToBind", param)
    Z.DialogViewDataMgr:OpenNormalDialog(desc, function()
      self:sendCompose()
      Z.DialogViewDataMgr:CloseDialogView()
    end)
  else
    self:sendCompose()
  end
end

function ComposeView:sendCompose()
  self.composeVM_.AsyncSendCompose(self.consumeId_, self.composeTimes_, self.panel.tog_only_unbind.Tog.isOn, self.cancelSource:CreateToken())
end

function ComposeView:OnDeActive()
  for _, item in pairs(self.units) do
    item:SetVisible(true)
  end
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  Z.TipsVM.CloseItemTipsView(self.productTipsId_)
  Z.TipsVM.CloseItemTipsView(self.consumeTipsId_)
end

function ComposeView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onAddItem, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onDelItem, self)
end

function ComposeView:onItemCountChange(item)
  if item.configId == self.consumeId_ then
    self.ownNumData_ = self.composeVM_.GetOwnNumDataByConsumeId(self.consumeId_)
    self:refreshOperationItemIcon()
  end
  for _, data in ipairs(self.catalogueItemDataList_) do
    if data.configId == item.configId then
      local ownData = self.composeVM_.GetOwnNumDataByConsumeId(data.configId)
      local ownNum = ownData.bind + ownData.unbind
      data.num = ownNum
      break
    end
  end
  self:refreshCatalogueScroll()
end

function ComposeView:onAddItem(item)
  if not composeTbl.GetRow(item.configId, true) then
    logError("composeTbl key={0} is null", item.configId)
    return
  end
  local isInList = false
  for _, data in ipairs(self.catalogueItemDataList_) do
    if data.configId == item.configId then
      isInList = true
      break
    end
  end
  if isInList then
    return
  end
  local ownData = self.composeVM_.GetOwnNumDataByConsumeId(item.configId)
  local ownNum = ownData.bind + ownData.unbind
  local itemData = {
    configId = item.configId,
    num = ownNum
  }
  local isAtLast = true
  for index, data in ipairs(self.catalogueItemDataList_) do
    if self.composeVM_.SortComposeCatalogueItemData(itemData, data) then
      table.insert(self.catalogueItemDataList_, index, itemData)
      isAtLast = false
      break
    end
  end
  if isAtLast then
    table.insert(self.catalogueItemDataList_, itemData)
  end
  self:refreshItemTypeDropdown()
  self:refreshCatalogueScroll()
end

function ComposeView:onDelItem(item)
  for index, data in ipairs(self.catalogueItemDataList_) do
    if data.configId == item.configId then
      local ownData = self.composeVM_.GetOwnNumDataByConsumeId(item.configId)
      local ownNum = ownData.bind + ownData.unbind
      if ownNum == 0 then
        table.remove(self.catalogueItemDataList_, index)
        self:refreshItemTypeDropdown()
        self:refreshCatalogueScroll()
        break
      end
      self:onItemCountChange(item)
      break
    end
  end
end

return ComposeView
