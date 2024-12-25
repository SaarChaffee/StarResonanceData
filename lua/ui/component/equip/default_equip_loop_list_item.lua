local super = require("ui.component.loopscrollrectitem")
local equipRed = require("rednode.equip_red")
local EquipItemsLoopItem = class("EquipItemsLoopItem", super)
local item = require("common.item_binder")

function EquipItemsLoopItem:ctor()
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
end

function EquipItemsLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.uiView)
  
  function self.itemWatcherFun_(container, dirtyKeys)
    local backpackData = Z.DataMgr.Get("backpack_data")
    if backpackData.SortState then
      return
    end
    if not self.parent then
      logError("Default equip loop " .. self.component.Index)
    end
    self.parent:RefreshDataByIndex(self.component.Index, {
      itemUuid = container.uuid,
      configId = container.configId
    })
  end
  
  function self.packageWatcherFun(container, dirtyKeys)
    self.package_ = container
  end
  
  self.lastRedId_ = nil
end

function EquipItemsLoopItem:Refresh()
  local index = self.component.Index + 1
  if index > self.parent:GetCount() then
    self:refreshNoItemUi()
    return
  end
  local data = self.parent:GetDataByIndex(index)
  if not data then
    logError("EquipItemsLoopItem data is nil,index is " .. index)
    return
  end
  if data.isShowRed then
    local newRed = string.zconcat(self.equipVm_.GetEquipPartTabRed(self.equipVm_.GetEquipPartIdByConfigId(data.configId)), data.itemUuid)
    equipRed.LoadItemRed(newRed, self.parent.uiView, self.uiBinder.trans_main.transform)
  end
  self.component.CanSelected = true
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
  self:setui()
  self.package_.Watcher:RegWatcher(self.packageWatcherFun)
  self.itemData_.Watcher:RegWatcher(self.itemWatcherFun_)
end

function EquipItemsLoopItem:refreshNoItemUi()
  self.component.CanSelected = false
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_info, false)
end

function EquipItemsLoopItem:setui()
  local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.itemData_.configId)
  self.itemClass_:Init({
    uiBinder = self.uiBinder,
    configId = self.configId,
    uuid = self.uuid_,
    isClickOpenTips = false
  })
  if itemTableRow then
    self.itemClass_:RefreshItemFlags(self.itemData_, itemTableRow)
  end
end

function EquipItemsLoopItem:OnReset()
  if self.itemData_ and self.itemWatcherFun_ then
    self.itemData_.Watcher:UnregWatcher(self.itemWatcherFun_)
  end
  if self.package_ and self.packageWatcherFun then
    self.package_.Watcher:UnregWatcher(self.packageWatcherFun)
  end
  if self.tipsId_ ~= nil then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
  self.tipsId_ = nil
  self.itemData_ = nil
  self.package_ = nil
  self.configId = -1
  self.uuid_ = -1
end

function EquipItemsLoopItem:OnPointerClick(go, eventData)
  if not self.itemData_ then
    return
  end
  local view = self.parent.uiView
  if view:NeedShowItemTips() then
    local extraParams = {
      posType = E.EItemTipsPopType.WorldPosition
    }
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(view:GetEquipItemTipsParent(), self.configId, self.uuid_, extraParams)
  end
end

function EquipItemsLoopItem:Selected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  if isSelected then
    local uiView = self.parent.uiView
    self.itemClass_:SetSelected(isSelected)
    uiView:ItemSelected(self.uuid_, self.configId, isSelected)
  end
end

function EquipItemsLoopItem:OnUnInit()
  self.itemClass_:UnInit()
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
