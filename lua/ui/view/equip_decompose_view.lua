local UI = Z.UI
local super = require("ui.ui_subview_base")
local Equip_decomposeView = class("Equip_decomposeView", super)
local equip_list_view_ = require("ui.view.equip_itemlist_view")
local itemClass = require("common.item_binder")

function Equip_decomposeView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "equip_decompose_sub", "equip/equip_decompose_sub", UI.ECacheLv.None, true)
  self.parent_ = parent
  self.equip_list_view_ = equip_list_view_.new(self)
  self.equipTableMgr_ = Z.TableMgr.GetTable("EquipTableMgr")
  self.itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.enchantVm_ = Z.VMMgr.GetVM("equip_enchant")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
end

function Equip_decomposeView:initUiBinders()
  self.cancelBtn_ = self.uiBinder.cont_cancel
  self.confirmBtn_ = self.uiBinder.cont_confirm
  self.listParent_ = self.uiBinder.group_list_parent
  self.materialScrollview_ = self.uiBinder.scrollview_material_list
  self.selectitemScrollview_ = self.uiBinder.scrollview_selectitem_list
  self.group_ = self.uiBinder.group_equip_decompose
  self.oneAddBtn_ = self.uiBinder.btn_one_add
  self.prefabCache_ = self.uiBinder.prefab_cache
  self.emptyLab_ = self.uiBinder.lab_empty
  self.rightNode_ = self.uiBinder.node_right
end

function Equip_decomposeView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:initUiBinders()
  self:startAnimatedShow()
  self.itemClassTab_ = {}
  self.selectedItems_ = {}
  self.filterFuncs_ = {}
  self.unitTokenDict_ = {}
  table.insert(self.filterFuncs_, self.equipVm_.CheckEquipDecomonece)
  self:AddClick(self.cancelBtn_, function()
    self:onCancelBtnClick()
  end)
  self:AddClick(self.oneAddBtn_, function()
    if self.equip_list_view_.curPartId_ then
      self.allEquipInfos_ = self.itemsVm_.GetItemIds(E.BackPackItemPackageType.Equip, self.filterFuncs_, nil)
      local data = {}
      local equipTabMgr = Z.TableMgr.GetTable("EquipTableMgr")
      local itemTabMgr = Z.TableMgr.GetTable("ItemTableMgr")
      local isShowTips = false
      local dataIndex = 1
      for _, value in pairs(self.allEquipInfos_) do
        local equipTableData = equipTabMgr.GetRow(value.configId)
        local itemTabMgrData = itemTabMgr.GetRow(value.configId)
        local itemInfo = self.itemsVm_.GetItemInfo(value.itemUuid, E.BackPackItemPackageType.Equip)
        if itemInfo and itemTabMgrData and equipTableData and itemTabMgrData.Quality <= E.ItemQuality.Blue then
          data[dataIndex] = {
            itemUuid = value.itemUuid,
            configId = value.configId
          }
          dataIndex = dataIndex + 1
          if self.equipVm_.CheckCanRecast(nil, value.configId) and itemInfo.equipAttr.perfectionValue > Z.Global.EquipPerfectvalDecomTips then
            isShowTips = true
          end
        end
      end
      if dataIndex == 1 then
        Z.TipsVM.ShowTips(150020)
        return
      end
      table.sort(data, self:getSortFunc())
      if isShowTips then
        self.equipVm_.OpenDayDialog(function()
          self:checkAllItem(data)
        end, Lang("EquipEquipPerfectvalDecomposeTips", {
          val = Z.Global.EquipPerfectvalDecomTips
        }), E.DlgPreferencesKeyType.EquipEquipDecomposeTips)
      else
        self:checkAllItem(data)
      end
    end
  end)
  self:AddAsyncClick(self.confirmBtn_, function()
    self:onConfirmBtnClick()
  end, nil, nil)
  self:BindEvents()
end

function Equip_decomposeView:getSortFunc()
  return self.itemSortFactoryVm_.GetItemSortFunc(E.BackPackItemPackageType.Equip, {
    equipSortType = E.BackPackItemPackageType.Equip,
    isAscending = false
  })
end

function Equip_decomposeView:checkAllItem(data)
  self.equip_list_view_:AddSelectedItems(data)
  for k, v in ipairs(data) do
    self:onItemSelected(v.itemUuid, v.configId, true)
  end
end

function Equip_decomposeView:OnDeActive()
  self:clearAll()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  self.equip_list_view_:DeActive()
end

function Equip_decomposeView:EmptyState(state)
  self.uiBinder.Ref:SetVisible(self.rightNode_, state)
end

function Equip_decomposeView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Equip.RefreshEmptyState, self.EmptyState, self)
end

function Equip_decomposeView:OnRefresh()
  self:refreshBtns()
  if self.viewData and self.viewData.configId and self.viewData.itemUuid then
    self.equip_list_view_:Active({
      itemUuid = self.viewData.itemUuid,
      configId = self.viewData.configId,
      showItemTips = true,
      funcViewType = E.EquipFuncViewType.Decompose,
      filterFuncs = self.filterFuncs_,
      itemSelectedFunc = function(itemUuid, configId, isSelected)
        self:onItemSelected(itemUuid, configId, isSelected)
      end
    }, self.listParent_.transform)
  elseif self.viewData and self.viewData.itemids then
    self.equip_list_view_:Active({
      itemids = self.viewData.itemids,
      showItemTips = true,
      funcViewType = E.EquipFuncViewType.Decompose,
      filterFuncs = self.filterFuncs_,
      itemSelectedFunc = function(itemUuid, configId, isSelected)
        self:onItemSelected(itemUuid, configId, isSelected)
      end
    }, self.listParent_.transform)
  else
    self.equip_list_view_:Active({
      funcViewType = E.EquipFuncViewType.Decompose,
      filterFuncs = self.filterFuncs_,
      showItemTips = true,
      itemSelectedFunc = function(itemUuid, configId, isSelected)
        self:onItemSelected(itemUuid, configId, isSelected)
      end
    }, self.listParent_.transform)
  end
end

function Equip_decomposeView:GetCacheData()
  return nil
end

function Equip_decomposeView:onItemSelected(itemUuid, configId, isSelected)
  local materialInfo = self:getMaterialView(itemUuid, configId)
  if not materialInfo then
    return
  end
  if isSelected then
    if self.selectedItems_[itemUuid] then
      return
    end
    self:addSelectedUnit(itemUuid, configId)
    for index, value in ipairs(materialInfo) do
      self:addMaterial(value)
    end
  elseif self.selectedItems_[itemUuid] then
    self:removeSelectedUnit(itemUuid)
    for index, value in ipairs(materialInfo) do
      self:removeMaterial(value)
    end
  end
  self:refreshBtns()
end

function Equip_decomposeView:refreshBtns()
  self:setprevMaterialVisible(table.zcount(self.selectedItems_) > 0)
end

function Equip_decomposeView:setprevMaterialVisible(isShow)
  self.cancelBtn_.IsDisabled = not isShow
  self.confirmBtn_.IsDisabled = not isShow
  self.uiBinder.Ref:SetVisible(self.emptyLab_, not isShow)
end

function Equip_decomposeView:addSelectedUnit(itemUuid, configId)
  if self.selectedItems_[itemUuid] ~= nil then
    return
  end
  local parent = self.selectitemScrollview_.Content
  self.selectedItems_[itemUuid] = {
    configId = configId,
    cancelToken = self.cancelSource:CreateToken()
  }
  local itemPath = self.prefabCache_:GetString("item")
  Z.CoroUtil.create_coro_xpcall(function()
    local unitName = "unit" .. itemUuid
    local unit = self:AsyncLoadUiUnit(itemPath, unitName, parent)
    if not unit then
      return
    end
    self.itemClassTab_[unitName] = itemClass.new(self)
    self.itemClassTab_[unitName]:Init({
      uiBinder = unit,
      configId = configId,
      uuid = itemUuid,
      isBind = true
    })
    self.selectedItems_[itemUuid].unit = unit
  end)()
end

function Equip_decomposeView:removeSelectedUnit(itemUuid)
  if self.selectedItems_[itemUuid] == nil then
    return
  end
  self:RemoveUiUnit("unit" .. itemUuid)
  self.selectedItems_[itemUuid] = nil
end

function Equip_decomposeView:getMaterialView(itemUuid, configId)
  local item
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip]
  if package then
    item = package.items[itemUuid]
  end
  if not item then
    return
  end
  local equipTableRow = self.equipTableMgr_.GetRow(configId)
  local equipDecomposeRows = Z.TableMgr.GetTable("EquipDecomposeTableMgr").GetDatas()
  if equipTableRow then
    for _, row in pairs(equipDecomposeRows) do
      if row.DecomposeId == equipTableRow.DecomposeId and item.equipAttr.perfectionValue >= row.RecastNum[1] and item.equipAttr.perfectionValue <= row.RecastNum[2] then
        self.curEquipEnchantInfo_ = Z.ContainerMgr.CharSerialize.equip.equipEnchant[itemUuid]
        local awardIds = {
          row.DecomposeAwardPackID
        }
        if self.curEquipEnchantInfo_ then
          local curEnchantRow = self.enchantVm_.GetEnchantItemByTypeAndLevel(self.curEquipEnchantInfo_.enchantItemTypeId, self.curEquipEnchantInfo_.enchantLevel)
          if curEnchantRow then
            for _, v in ipairs(row.EnchantAddAwardPackID) do
              if v[1] <= curEnchantRow.EnchantItemLevel and v[2] >= curEnchantRow.EnchantItemLevel then
                awardIds[2] = v[3]
                break
              end
            end
          end
        end
        for i = 1, item.equipAttr.totalRecastCount do
          awardIds[#awardIds + 1] = row.RecastAddAwardPackID
        end
        return self.awardPreviewVM_.GetAllAwardPreListByIds(awardIds)
      end
    end
  end
  logError("not find equip decompose material, please check decomposeId ")
  return nil
end

function Equip_decomposeView:addMaterial(materialInfo)
  if not self.materialUnitInfo_ then
    self.materialUnitInfo_ = {}
  end
  local configId = materialInfo.awardId
  if not self.materialUnitInfo_[configId] then
    self.materialUnitInfo_[configId] = {}
  end
  local materialItem = self.materialUnitInfo_[configId]
  if not materialItem.count then
    materialItem.count = materialInfo.awardNum
    materialItem.awardNumExtend = materialInfo.awardNumExtend or 0
  else
    materialItem.count = materialItem.count + materialInfo.awardNum
    materialItem.awardNumExtend = materialItem.awardNumExtend + (materialInfo.awardNumExtend or 0)
  end
  if self.materialUnitInfo_[configId].unit then
    local lab = materialItem.awardNumExtend == 0 or materialItem.count == materialItem.awardNumExtend and materialItem.count or materialItem.count .. "~" .. materialItem.awardNumExtend
    self.itemClassTab_["material" .. configId]:SetLab(lab)
    return
  end
  local parent = self.materialScrollview_.Content
  local itemPath = self.prefabCache_:GetString("material_item")
  Z.CoroUtil.create_coro_xpcall(function()
    local unitName = "material" .. configId
    if self.unitTokenDict_[unitName] then
      Z.CancelSource.ReleaseToken(self.unitTokenDict_[unitName])
    end
    local unitToken = self.cancelSource:CreateToken()
    self.unitTokenDict_[unitName] = unitToken
    local unit = self:AsyncLoadUiUnit(itemPath, unitName, parent, unitToken)
    self.unitTokenDict_[unitName] = nil
    if not unit then
      return
    end
    self.itemClassTab_[unitName] = itemClass.new(self)
    local lab = materialItem.awardNumExtend == 0 or materialItem.count == materialItem.awardNumExtend and materialItem.count or materialItem.count .. "~" .. materialItem.awardNumExtend
    self.itemClassTab_[unitName]:Init({
      uiBinder = unit,
      configId = configId,
      lab = lab,
      labType = E.ItemLabType.Str,
      isBind = true
    })
    self.materialUnitInfo_[configId].unit = unit
  end)()
end

function Equip_decomposeView:removeMaterial(materialInfo)
  local configId = materialInfo.awardId
  if not self.materialUnitInfo_ or not self.materialUnitInfo_[configId] then
    return
  end
  local materialItem = self.materialUnitInfo_[configId]
  materialItem.count = materialItem.count - materialInfo.awardNum
  materialItem.awardNumExtend = materialItem.awardNumExtend - (materialInfo.awardNumExtend or 0)
  local lab = materialItem.awardNumExtend == 0 and materialItem.count or materialItem.count .. "~" .. materialItem.awardNumExtend
  if materialItem.count < 1 then
    self:RemoveUiUnit("material" .. configId)
    self.materialUnitInfo_[configId] = nil
  else
    self.itemClassTab_["material" .. configId]:SetLab(lab)
  end
end

function Equip_decomposeView:onCancelBtnClick()
  self:clearAll()
end

function Equip_decomposeView:onConfirmBtnClick()
  if table.zcount(self.selectedItems_) < 1 then
    Z.TipsVM.ShowTipsLang(410004)
    return
  end
  local func = function()
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("EquipDecomposePrompt"), function()
      self:asyncDecompose()
    end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.Equip_Decompose_Prompt)
  end
  for uuid, value in pairs(self.selectedItems_) do
    if self.equipVm_.CheckIsFocusEquip(value.configId) then
      Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("EquipBreakDownExclusiveEquipTips"), function()
        func()
      end, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.Equip_Decompose_Prompt)
      return
    end
  end
  func()
end

function Equip_decomposeView:clearAll()
  self:ClearAllUnits()
  self.viewData = nil
  self.materialUnitInfo_ = {}
  self.selectedItems_ = {}
  self.equip_list_view_:ClearAllSelect()
  self:refreshBtns()
end

function Equip_decomposeView:asyncDecompose()
  local itemids = {}
  for key, value in pairs(self.selectedItems_) do
    table.insert(itemids, key)
  end
  local ret = self.equipVm_.AsyncEquipDecompose(itemids, self.cancelSource:CreateToken())
  if ret then
    self:clearAll()
    self.equip_list_view_:RefreshItemInfoDatas()
    self.equip_list_view_:Active({
      funcViewType = E.EquipFuncViewType.Decompose,
      showItemTips = true,
      partId = self.equip_list_view_:GetCurSelectPartId(),
      itemSelectedFunc = function(itemUuid, configId, isSelected)
        self:onItemSelected(itemUuid, configId, isSelected)
      end
    }, self.listParent_.transform)
  end
end

function Equip_decomposeView:startAnimatedShow()
  self.uiBinder.anim_decompose:Restart(Z.DOTweenAnimType.Open)
end

return Equip_decomposeView
