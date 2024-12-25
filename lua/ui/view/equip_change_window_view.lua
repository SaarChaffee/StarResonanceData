local UI = Z.UI
local super = require("ui.ui_view_base")
local Equip_change_subView = class("Equip_change_subView", super)
local equipRed = require("rednode.equip_red")
local item_operation_btnsView_ = require("ui.view.item_operation_btns_view")
local loopGridView_ = require("ui/component/loop_grid_view")
local itemFilter = require("ui.view.item_filters_view")
local keepActionState = {
  Z.PbEnum("EActorState", "ActorStateSkill"),
  Z.PbEnum("EActorState", "ActorStateJump"),
  Z.PbEnum("EActorState", "ActorStateClimb"),
  Z.PbEnum("EActorState", "ActorStateSwim"),
  Z.PbEnum("EActorState", "ActorStateInteraction"),
  Z.PbEnum("EActorState", "ActorStateSceneInteraction"),
  Z.PbEnum("EActorState", "ActorStateFlow"),
  Z.PbEnum("EActorState", "ActorStateGlide"),
  Z.PbEnum("EActorState", "ActorStateFall"),
  Z.PbEnum("EActorState", "ActorStateAction"),
  Z.PbEnum("EActorState", "ActorStateFishing"),
  Z.PbEnum("EActorState", "ActorStatePedalWall"),
  Z.PbEnum("EActorState", "ActorStateDead")
}
local default_equip_loop_list_item_ = require("ui.component.equip.new_default_equip_loop_list_item")

function Equip_change_subView:ctor()
  self.uiBinder = nil
  super.ctor(self, "equip_change_window")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.actionVM_ = Z.VMMgr.GetVM("action")
  self.item_operation_btnsView_ = item_operation_btnsView_.new()
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  self.equipData_ = Z.DataMgr.Get("equip_system_data")
  self.equipAttrParseVM_ = Z.VMMgr.GetVM("equip_attr_parse")
  local itemTypeTableRow = Z.TableMgr.GetTable("ItemTypeTableMgr").GetRow(E.EquipPart.Handguards)
  if itemTypeTableRow then
    self.packageId_ = itemTypeTableRow.Package
  end
  self.curPutOnEquipTipsId_ = nil
  
  function self.equipListChangeFunc_(container, dirtys)
    self:changeEquip(container, dirtys)
  end
  
  self.itemFilter_ = itemFilter.new(self)
end

function Equip_change_subView:inituiBinders()
  self.titleLab_ = self.uiBinder.lab_title
  self.goBtn_ = self.uiBinder.btn_goto
  self.tipsTrans_ = self.uiBinder.node_tips
  self.askBtn_ = self.uiBinder.btn_ask
  self.closeBtn_ = self.uiBinder.btn_close
  self.loopscroll_items = self.uiBinder.loopscroll_items
  self.sortBtn_ = self.uiBinder.btn_sort
  self.dpd_ = self.uiBinder.dpd
  self.empty = self.uiBinder.empty
  self.togGroup_ = self.uiBinder.layout_tab
  self.node_cur_tips = self.uiBinder.node_cur_tips
  self.operationBtnsTrans_ = self.uiBinder.cont_item_operation_btns
  self.anim_ = self.uiBinder.anim_change
  self.sortNode_ = self.uiBinder.node_sort_rule
  self.tipsRightNode_ = self.uiBinder.cont_right_info
  self.tabScrllView_ = self.uiBinder.tab_scrollview
  self.equipPartTabs_ = {}
  self.equipPartTabs_[E.EquipPart.Weapon] = self.uiBinder.cont_weapon
  self.equipPartTabs_[E.EquipPart.Helmet] = self.uiBinder.cont_helmet
  self.equipPartTabs_[E.EquipPart.Clothes] = self.uiBinder.cont_clothes
  self.equipPartTabs_[E.EquipPart.Handguards] = self.uiBinder.cont_handguards
  self.equipPartTabs_[E.EquipPart.Shoe] = self.uiBinder.cont_shoes
  self.equipPartTabs_[E.EquipPart.Necklace] = self.uiBinder.cont_necklace
  self.equipPartTabs_[E.EquipPart.Earring] = self.uiBinder.cont_earring
  self.equipPartTabs_[E.EquipPart.Ring] = self.uiBinder.cont_ring
  self.equipPartTabs_[E.EquipPart.LeftBracelet] = self.uiBinder.cont_left_bracelet
  self.equipPartTabs_[E.EquipPart.RightBracelet] = self.uiBinder.cont_right_bracelet
  self.equipPartTabs_[E.EquipPart.Amulet] = self.uiBinder.cont_amulet
end

function Equip_change_subView:OnActive()
  self:inituiBinders()
  self:startAnimatedShow()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.filterTgas_ = nil
  self.commonVM_.SetLabText(self.titleLab_, {
    E.FunctionID.RoleInfo,
    E.FunctionID.EquipChange
  })
  self.playerModel_ = Z.EntityMgr.PlayerEnt.Model
  if self:checkCanPlayAction() then
    self.playerModel_:SetLuaAttr(Z.ModelAttr.EModelAnimBase, Z.AnimBaseData.Rent(Panda.ZAnim.EAnimBase.EIdle))
  end
  if self.viewData then
    self.selectedPartId_ = self.viewData.prtId or E.EquipPart.Weapon
    self.selectedItemUuid_ = self.viewData.itemUuid
  end
  self.btnData_ = {
    viewConfigKey = "equip_system"
  }
  self:AddClick(self.goBtn_, function()
    self.equipVm_.OpenEquipSearchTips(self.goBtn_.transform)
  end)
  self:AddClick(self.askBtn_, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(30013)
  end)
  self:AddClick(self.uiBinder.btn_screening, function()
    self:openItemFilter()
  end)
  Z.ContainerMgr.CharSerialize.equip.Watcher:RegWatcher(self.equipListChangeFunc_)
  self.allEquipInfos_ = self.itemsVm_.GetItemIds(E.BackPackItemPackageType.Equip, nil, nil)
  self:AddClick(self.closeBtn_, function()
    self.equipVm_.CloseChangeEquipView()
  end)
  local vLoopScrollRect = self.loopscroll_items
  self.loopGridViewRect_ = loopGridView_.new(self, vLoopScrollRect, default_equip_loop_list_item_, "com_item_long_3")
  self.loopGridViewRect_:Init({})
  self:initSortUi()
  self:initEquipPartTabUi()
  self.actionDict_ = {}
  local glb = Z.Global
  self.actionVM_:InitModelActionInfo(self.actionDict_, glb.EquipShowActionM, glb.EquipShowActionF)
  self:refreshEquipListView(self.selectedItemUuid_)
  self:BindEvents()
  local nowHeight = self.uiBinder.cont_weapon.Ref.transform.rect.height * (self.selectedPartId_ - E.EquipPart.Weapon + 1)
  local rectHeight = self.tabScrllView_.transform.rect.height
  local diff = nowHeight - rectHeight
  if 0 < diff then
    self.tabScrllView_.content:SetAnchorPosition(0, diff)
  else
    self.tabScrllView_.content:SetAnchorPosition(0, 0)
  end
  if Z.EntityMgr.PlayerEnt:GetLuaRidingId() == 0 then
    self.weaponVm_.SwitchEntityShow(false)
    Z.UICameraHelper.SetCameraFocus(true, Z.Global.CameraFocusMainView[1], Z.Global.CameraFocusMainView[2])
  else
    self.weaponVm_.SwitchEntityShow(true)
  end
end

function Equip_change_subView:initSortUi()
  self.isAscending_ = false
  self:AddClick(self.sortBtn_, function()
    self:refreshSort(self.equipSortTyp_, not self.isAscending_)
  end)
  local options_ = {}
  self.sortRuleTypeNames_ = {
    E.EquipItemSortType.Quality,
    E.EquipItemSortType.GS
  }
  self.equipSortTyp_ = E.EquipItemSortType.Quality
  options_ = {
    [1] = Lang("ColorOrder"),
    [2] = Lang("GsOrder")
  }
  self.dpd_:ClearAll()
  self.dpd_:AddListener(function(index)
    self:refreshSort(self.sortRuleTypeNames_[index + 1], self.isAscending_)
  end, true)
  self.dpd_:AddOptions(options_)
end

function Equip_change_subView:refreshSort(type, isAscending)
  self.equipSortTyp_ = type
  self.isAscending_ = isAscending
  self:refreshloopScrollView(1)
end

function Equip_change_subView:openItemFilter()
  local viewData = {
    parentView = self,
    filterType = E.ItemFilterType.ItemRare + E.ItemFilterType.ItemType + E.ItemFilterType.EquipGs + E.ItemFilterType.EquipRecast + E.ItemFilterType.EquipPerfect,
    existFilterTags = self.filterTgas_
  }
  self.itemFilter_:Active(viewData, self.uiBinder.node_screening.transform)
end

function Equip_change_subView:onSelectFilter(filterTgas)
  self.filterTgas_ = filterTgas
  self:refreshloopScrollView()
end

function Equip_change_subView:checkIsShowItem(item, equipTableRow)
  if self.filterTgas_ and next(self.filterTgas_) and equipTableRow then
    local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(item.configId)
    if self.filterTgas_[E.ItemFilterType.ItemRare] and itemTableRow then
      for k, v in pairs(self.filterTgas_[E.ItemFilterType.ItemRare]) do
        if itemTableRow.Quality == k then
          return true
        end
      end
    end
    local itemInfo = self.itemsVm_.GetItemInfobyItemId(item.itemUuid, item.configId)
    if not itemInfo then
      return false
    end
    if self.filterTgas_[E.ItemFilterType.EquipGs] then
      for k, v in pairs(self.filterTgas_[E.ItemFilterType.EquipGs]) do
        local minValue = tonumber(Z.Global.EquipScreenGS[k][1])
        local maxValue = tonumber(Z.Global.EquipScreenGS[k][2])
        if minValue <= equipTableRow.EquipGs and maxValue >= equipTableRow.EquipGs then
          return true
        end
      end
    end
    if self.filterTgas_[E.ItemFilterType.EquipPerfect] then
      for k, v in pairs(self.filterTgas_[E.ItemFilterType.EquipPerfect]) do
        local minValue = tonumber(Z.Global.EquipScreenPerfectVal[k][1])
        local maxValue = tonumber(Z.Global.EquipScreenPerfectVal[k][2])
        if self.equipVm_.CheckCanRecast(itemInfo.uuid, itemInfo.configId) and minValue <= itemInfo.equipAttr.perfectionValue and maxValue >= itemInfo.equipAttr.perfectionValue then
          return true
        end
      end
    end
    if self.filterTgas_[E.ItemFilterType.EquipRecast] then
      for k, v in pairs(self.filterTgas_[E.ItemFilterType.EquipRecast]) do
        local minValue = tonumber(Z.Global.EquipScreenType[k][1])
        local maxValue = tonumber(Z.Global.EquipScreenType[k][2])
        if minValue <= itemInfo.equipAttr.totalRecastCount and maxValue >= itemInfo.equipAttr.totalRecastCount then
          return true
        end
      end
    end
    if self.filterTgas_[E.ItemFilterType.EquipProfession] and self.equipVm_.CheckProfessionIsContainEquipAttr(itemInfo) then
      return true
    end
    return false
  end
  return true
end

function Equip_change_subView:refreshloopScrollView(selectIndex)
  local data = {}
  local equipTabMgr = Z.TableMgr.GetTable("EquipTableMgr")
  for _, value in pairs(self.allEquipInfos_) do
    local equipTableData = equipTabMgr.GetRow(value.configId)
    if equipTableData and equipTableData.EquipPart == self.selectedPartId_ and self:checkIsShowItem(value, equipTableData) then
      table.insert(data, {
        configId = value.configId,
        itemUuid = value.itemUuid,
        isShowRed = true
      })
    end
  end
  if self.selectedPartId_ == E.EquipPart.Weapon then
    data = self.equipVm_.SortWeapon(data, self.isAscending_)
  else
    table.sort(data, self:getSortFunc())
  end
  local index = 1
  if selectIndex then
    index = selectIndex or 1
  else
    index = self:getSelectItemIndex(data) or 1
  end
  local isNotEmpty = 0 < #data
  self.uiBinder.Ref:SetVisible(self.loopscroll_items, isNotEmpty)
  self.uiBinder.Ref:SetVisible(self.empty, not isNotEmpty)
  self.uiBinder.Ref:SetVisible(self.sortNode_, isNotEmpty)
  self.uiBinder.Ref:SetVisible(self.tipsRightNode_, isNotEmpty)
  self:clearItemRed()
  self.loopGridViewRect_:ClearAllSelect()
  self.loopGridViewRect_:RefreshListView(data)
  self.loopGridViewRect_:SetSelected(index)
  self.loopGridViewRect_:MovePanelToItemIndex(index)
end

function Equip_change_subView:clearItemRed()
  equipRed.RemoveAllItemRed(self)
end

function Equip_change_subView:getSortFunc()
  return self.itemSortFactoryVm_.GetItemSortFunc(E.BackPackItemPackageType.Equip, {
    equipSortType = self.equipSortTyp_,
    isAscending = self.isAscending_
  })
end

function Equip_change_subView:getSelectItemIndex(data)
  if data == nil then
    return
  end
  self.curItemDatas_ = data
  if self.selectedItemUuid_ then
    for index, value in ipairs(data) do
      if value.itemUuid == self.selectedItemUuid_ then
        self:ItemSelected(value.itemUuid, value.configId)
        return index
      end
    end
  end
  local equipInfo = Z.ContainerMgr.CharSerialize.equip.equipList[self.selectedPartId_]
  if not equipInfo then
    return 1
  end
  for index, value in ipairs(data) do
    if value.itemUuid == equipInfo.itemUuid then
      self:ItemSelected(value.itemUuid, value.configId)
      return index
    end
  end
end

function Equip_change_subView:initEquipPartTabUi()
  for k, v in pairs(self.equipPartTabs_) do
    local partId = k
    Z.RedPointMgr.LoadRedDotItem(self.equipVm_.GetEquipPartTabRed(partId), self, v.tog_tab_select.transform)
    v.tog_tab_select.group = self.togGroup_
    if k == partId then
      v.tog_tab_select.isOn = true
    end
    local equipPartRow = Z.TableMgr.GetTable("EquipPartTableMgr").GetRow(partId)
    if equipPartRow then
      v.Ref:SetVisible(v.img_lock, not Z.ConditionHelper.CheckCondition(equipPartRow.UnlockCondition))
      v.tog_tab_select:AddListener(function(isOn)
        if isOn then
          if Z.ConditionHelper.CheckCondition(equipPartRow.UnlockCondition, true) then
            self:refreshEquipListByPartId(partId, false, v)
          else
            self.equipPartTabs_[self.selectedPartId_].tog_tab_select.isOn = true
          end
        end
      end, nil)
    end
  end
end

function Equip_change_subView:refreshEquipListByPartId(partId, force, animUiBinder)
  if partId == self.selectedPartId_ and not force then
    return
  end
  self.commonVM_.CommonPlayTogAnim(animUiBinder.anim_tog, self.cancelSource:CreateToken())
  Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnGuideEvnet, string.zconcat(E.SteerGuideEventType.PutOnEquip, "=", partId))
  self.item_operation_btnsView_:DeActive()
  Z.TipsVM.CloseItemTipsView(self.selectItemTipsId_)
  Z.TipsVM.CloseItemTipsView(self.acquisitionTipId_)
  for k, v in pairs(self.equipPartTabs_) do
    if k == partId then
      v.tog_tab_select.isOn = true
      break
    end
  end
  self.selectedPartId_ = partId
  self:onEquipListViewPartChanged(partId)
  self:refreshModelAction()
  self:refreshloopScrollView()
end

function Equip_change_subView:refreshModelAction()
  if not self:checkCanPlayAction() then
    return
  end
  local actionInfo = self.actionDict_[self.selectedPartId_]
  if actionInfo and actionInfo.actionId > 0 then
    if self.curPartActionId_ and self.curPartActionId_ == actionInfo.actionId then
      return
    end
    self.curPartActionId_ = actionInfo.actionId
    if self.playerModel_ then
      self.actionVM_:PlayAction(self.playerModel_, actionInfo)
    end
  end
end

function Equip_change_subView:checkCanPlayAction()
  if Z.EntityMgr.PlayerEnt:GetLuaRidingId() ~= 0 then
    return false
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  for _, value in ipairs(keepActionState) do
    if value == stateId then
      return false
    end
  end
  Z.EntityMgr.PlayerEnt:SetLuaLocalAttrInBattleShow(false)
  return true
end

function Equip_change_subView:NeedShowItemTips()
  return false
end

function Equip_change_subView:ItemSelected(itemUuid, configId)
  self:onEquipItemSelected(itemUuid, configId)
end

function Equip_change_subView:onEquipItemSelected(itemUuid, configId)
  self.selectedItemUuid_ = itemUuid
  self.selectItemConfigId_ = configId
  local equipInfo = self.equipVm_.GetSamePartEquipAttr(configId)
  local putonEquipConfigId
  if equipInfo and equipInfo.itemUuid ~= 0 and equipInfo.itemUuid ~= itemUuid then
    putonEquipConfigId = self.itemsVm_.GetItemConfigId(equipInfo.itemUuid, self.packageId_)
    local curPutItemTipsData = {}
    curPutItemTipsData.tipsId = self.curPutOnEquipTipsId_
    curPutItemTipsData.configId = putonEquipConfigId
    curPutItemTipsData.itemUuid = equipInfo.itemUuid
    curPutItemTipsData.isResident = true
    curPutItemTipsData.posType = E.EItemTipsPopType.Parent
    curPutItemTipsData.isShowBg = true
    curPutItemTipsData.parentTrans = self.node_cur_tips.transform
    self.curPutOnEquipTipsId_ = Z.TipsVM.OpenItemTipsView(curPutItemTipsData)
  else
    Z.TipsVM.CloseItemTipsView(self.curPutOnEquipTipsId_)
    self.curPutOnEquipTipsId_ = nil
  end
  local selectItemTipsData = {}
  selectItemTipsData.tipsId = self.selectItemTipsId_
  selectItemTipsData.configId = configId
  selectItemTipsData.itemUuid = itemUuid
  selectItemTipsData.isResident = true
  selectItemTipsData.isShowBg = true
  selectItemTipsData.isShowFixBg = true
  selectItemTipsData.posType = E.EItemTipsPopType.Parent
  selectItemTipsData.parentTrans = self.tipsTrans_.transform
  local curEquipAttr
  if putonEquipConfigId then
    curEquipAttr = self.equipVm_.GetEquipAttr(putonEquipConfigId, equipInfo.itemUuid)
    if curEquipAttr then
      selectItemTipsData.data = {
        BasicAttrEffectDatas = self.equipAttrParseVM_.GetEquipAttrEffectByAttrDic(curEquipAttr.basicAttr),
        AdvanceAttrEffectDatas = self.equipAttrParseVM_.GetEquipAttrEffectByAttrDic(curEquipAttr.advanceAttr),
        RecastAttrEffectDatas = self.equipAttrParseVM_.GetEquipAttrEffectByAttrDic(curEquipAttr.recastAttr)
      }
    end
  end
  Z.TipsVM.CloseItemTipsView(self.selectItemTipsId_)
  self.selectItemTipsId_ = nil
  self.selectItemTipsId_ = Z.TipsVM.OpenItemTipsView(selectItemTipsData)
  self.item_operation_btnsView_:Active({
    itemId = itemUuid,
    configId = configId,
    btnData = self.btnData_
  }, self.operationBtnsTrans_.transform)
end

function Equip_change_subView:onEquipListViewPartChanged(partId)
  Z.TipsVM.CloseItemTipsView(self.selectItemTipsId_)
  Z.TipsVM.CloseItemTipsView(self.curPutOnEquipTipsId_)
end

function Equip_change_subView:refreshEquipListView(selectedItemUuid)
  if selectedItemUuid then
    self.selectedItemUuid_ = selectedItemUuid
    return
  end
  self.selectedItemUuid_ = self:getSelectItemId(selectedItemUuid)
end

function Equip_change_subView:getSelectItemId(selectedItemUuid)
  if selectedItemUuid ~= nil then
    local itemData = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip].items[selectedItemUuid]
    if itemData ~= nil then
      local equipTableMgr = Z.TableMgr.GetTable("EquipTableMgr")
      local equipTable = equipTableMgr.GetRow(itemData.configId, false)
      if equipTable ~= nil then
        self.selectedPartId_ = equipTable.EquipPart
        return selectedItemUuid
      end
    end
  end
  local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
  if not self.selectedPartId_ then
    self.selectedPartId_ = E.EquipPart.Weapon
  end
  local equipInfo = equipList[self.selectedPartId_]
  local itemUuid
  if equipInfo then
    itemUuid = equipInfo.itemUuid
  end
  return itemUuid
end

function Equip_change_subView:OnDeActive()
  if self.loopGridViewRect_ then
    self.loopGridViewRect_:UnInit()
  end
  for k, v in pairs(self.equipPartTabs_) do
    v.tog_tab_select:RemoveAllListeners()
  end
  if self.itemFilter_ then
    self.itemFilter_:DeActive()
  end
  self.selectedPartId_ = 0
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.equipVm_.CloseApproach()
  Z.TipsVM.CloseItemTipsView(self.selectItemTipsId_)
  Z.TipsVM.CloseItemTipsView(self.curPutOnEquipTipsId_)
  self.item_operation_btnsView_:DeActive()
  Z.ContainerMgr.CharSerialize.equip.Watcher:UnregWatcher(self.equipListChangeFunc_)
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.weaponVm_.SwitchEntityShow(true)
  if self:checkCanPlayAction() then
    self.playerModel_:SetLuaAttr(Z.ModelAttr.EModelAnimBase, Z.AnimBaseData.Rent(Panda.ZAnim.EAnimBase.EIdle))
  end
  Z.UICameraHelper.SetCameraFocus(false)
end

function Equip_change_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.FashionAttrChange, self.onFashionAttrChange, self)
  Z.EventMgr:Add(Z.ConstValue.ItemFilterConfirm, self.onSelectFilter, self)
end

function Equip_change_subView:changeEquip(container, dirtys)
  if container.equipList then
    self.equipVm_.UpdateEquipFashion()
  end
  self:refreshEquipListView()
  self:refreshloopScrollView()
end

function Equip_change_subView:onFashionAttrChange(attrType, ...)
  if not self.playerModel_ then
    return
  end
  local arg = {
    ...
  }
  self.playerModel_:SetLuaAttr(attrType, table.unpack(arg))
end

function Equip_change_subView:OnRefresh()
  self.curPartActionId_ = 0
  if self.selectedPartId_ == nil or self.selectedPartId_ == 0 then
    self.selectedPartId_ = E.EquipPart.Weapon
  end
  self:refreshEquipListByPartId(self.selectedPartId_, true, self.equipPartTabs_[self.selectedPartId_])
end

function Equip_change_subView:startAnimatedShow()
  self.anim_:Play(Z.DOTweenAnimType.Open)
  self.anim_:Restart(Z.DOTweenAnimType.Open)
end

function Equip_change_subView:CustomClose()
end

function Equip_change_subView:GetCacheData()
  return {
    prtId = self.selectedPartId_,
    itemUuid = self.selectedItemUuid_
  }
end

return Equip_change_subView
