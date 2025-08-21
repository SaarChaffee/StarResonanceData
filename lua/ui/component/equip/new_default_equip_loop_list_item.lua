local super = require("ui.component.loop_grid_view_item")
local EquipItemsLoopItem = class("EquipItemsLoopItem", super)
local item = require("common.item_binder")

function EquipItemsLoopItem:ctor()
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.refineVm_ = Z.VMMgr.GetVM("equip_refine")
end

function EquipItemsLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
  
  function self.itemWatcherFun_(container, dirtyKeys)
    local backpackData = Z.DataMgr.Get("backpack_data")
    if backpackData.SortState then
      return
    end
    if not self.parent then
      return
    end
  end
  
  function self.packageWatcherFun(container, dirtyKeys)
    self.package_ = container
  end
end

function EquipItemsLoopItem:OnRefresh(data)
  if not data then
    logError("EquipItemsLoopItem data is nil,index is ")
    return
  end
  self.data_ = data
  if data.IsEmpty then
    self.itemClass_:RefreshByData({
      uiBinder = self.uiBinder,
      isClickOpenTips = false,
      isShowLattice = true
    })
    self:SetCanSelect(false)
    return
  end
  self:SetCanSelect(true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, true)
  self.uuid_ = data.itemUuid
  self.configId = data.configId
  local itemsVm = Z.VMMgr.GetVM("items")
  self.package_ = itemsVm.GetPackageInfobyItemId(self.configId)
  self.itemData_ = self.package_.items[self.uuid_]
  if not self.itemData_ then
    self:refreshNoItemUi()
    return
  end
  self:setui(data)
  self.package_.Watcher:RegWatcher(self.packageWatcherFun)
  self.itemData_.Watcher:RegWatcher(self.itemWatcherFun_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function EquipItemsLoopItem:refreshNoItemUi()
  self:SetCanSelect(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_info, false)
end

function EquipItemsLoopItem:setui(data)
  local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.itemData_.configId)
  if not itemTableRow then
    return
  end
  self.itemClass_:RefreshByData({
    uiBinder = self.uiBinder,
    configId = self.configId,
    uuid = self.uuid_,
    isBind = true,
    isClickOpenTips = false
  })
  if data.isShowRed then
    local RedNodeId = string.zconcat(self.equipVm_.GetEquipPartTabRed(self.equipVm_.GetEquipPartIdByConfigId(data.configId)), data.itemUuid)
    local redState = Z.RedPointMgr.GetRedState(RedNodeId) or Z.RedPointMgr.GetRedState(self.refineVm_.GetRefineItemRedName(data.itemUuid))
    self.itemClass_:SetRedDot(redState)
  end
  self.itemClass_:RefreshItemFlags(self.itemData_, itemTableRow)
  if Z.UIMgr:IsActive("equip_change_window") then
    Z.GuideMgr:SetSteerIdByComp(self.uiBinder.uisteer, E.DynamicSteerType.EquipSlotIndex, self.Index)
    local equipWeaponRow = Z.TableMgr.GetTable("EquipWeaponTableMgr").GetRow(self.itemData_.configId, true)
    if equipWeaponRow then
      local curProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
      self.itemClass_:SetForbiddenState(curProfessionId ~= equipWeaponRow.ProfessionId)
    end
  end
end

function EquipItemsLoopItem:OnReset()
  if self.itemData_ and self.itemWatcherFun_ then
    self.itemData_.Watcher:UnregWatcher(self.itemWatcherFun_)
  end
  if self.package_ and self.packageWatcherFun then
    self.package_.Watcher:UnregWatcher(self.packageWatcherFun)
  end
  self.itemData_ = nil
  self.package_ = nil
  self.configId = -1
  self.uuid_ = -1
end

function EquipItemsLoopItem:OnPointerClick(go, eventData)
  if not self.itemData_ then
    return
  end
  local view = self.parent.UIView
  if view:NeedShowItemTips() then
    local trans = view:GetEquipItemTipsParent()
    local extraParams = {
      posType = trans and E.EItemTipsPopType.Parent or E.EItemTipsPopType.WorldPosition
    }
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(view:GetEquipItemTipsParent(), self.configId, self.uuid_, extraParams)
  end
end

function EquipItemsLoopItem:OnSelected(isSelected, isClick)
  if self.data_.IsEmpty then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("sys_general_frame")
    end
    local uiView = self.parent.UIView
    self.itemClass_:SetSelected(isSelected)
    uiView:ItemSelected(self.uuid_, self.configId, isSelected)
  end
end

function EquipItemsLoopItem:OnUnInit()
  self.itemClass_:UnInit()
  if self.tipsId_ ~= nil then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
  self.tipsId_ = nil
  if self.itemData_ and self.itemWatcherFun_ then
    self.itemData_.Watcher:UnregWatcher(self.itemWatcherFun_)
  end
  if self.package_ and self.packageWatcherFun then
    self.package_.Watcher:UnregWatcher(self.packageWatcherFun)
  end
  self.updateTimer_ = nil
  self.timerMgr_ = nil
  self.itemWatcherFun_ = nil
end

return EquipItemsLoopItem
