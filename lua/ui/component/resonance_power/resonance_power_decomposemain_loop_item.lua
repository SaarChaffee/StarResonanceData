local super = require("ui.component.loop_grid_view_item")
local ResonancePowerDecomposeMainLoopItem = class("ResonancePowerDecomposeMainLoopItem", super)
local item = require("common.item_binder")

function ResonancePowerDecomposeMainLoopItem:ctor()
end

function ResonancePowerDecomposeMainLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.itemClass_ = item.new(self.parent.uiView)
  
  function self.itemWatcherFun_(container, dirtyKeys)
    local backpackData = Z.DataMgr.Get("backpack_data")
    if backpackData.SortState then
      return
    end
    if not self.parent then
      logError("Default equip loop " .. self.Index)
    end
    self.parent:RefreshDataByIndex(self.Index, {
      itemUuid = container.uuid,
      configId = container.configId
    })
  end
  
  function self.packageWatcherFun(container, dirtyKeys)
    self.package_ = container
  end
end

function ResonancePowerDecomposeMainLoopItem:OnRefresh(data)
  self.data = data
  local index = self.Index + 1
  if not data then
    logError("EquipItemsLoopItem data is nil,index is " .. index)
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
  self.package_.Watcher:RegWatcher(self.packageWatcherFun)
  self.itemData_.Watcher:RegWatcher(self.itemWatcherFun_)
  self:setui()
  self:SelectState()
end

function ResonancePowerDecomposeMainLoopItem:refreshNoItemUi()
  self:SetCanSelect(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_info, false)
end

function ResonancePowerDecomposeMainLoopItem:setui()
  local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.configId)
  self.itemClass_:Init({
    uiBinder = self.uiBinder,
    configId = self.configId,
    uuid = self.uuid_,
    isClickOpenTips = false,
    isShowOne = false
  })
  if itemTableRow and self.uuid_ then
    self.itemClass_:RefreshItemFlags(self.itemData_, itemTableRow)
  end
end

function ResonancePowerDecomposeMainLoopItem:Selected(isSelected)
  self.itemClass_:SetSelected(isSelected)
  self.parentUIView:OnSelectResonancePowerItemDecompose(self:GetCurData())
  self:SelectState()
end

function ResonancePowerDecomposeMainLoopItem:SelectState()
  local isSelected = self.IsSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

function ResonancePowerDecomposeMainLoopItem:OnPointerClick(go, eventData)
  self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.Trans, self.configId, self.uuid_)
end

function ResonancePowerDecomposeMainLoopItem:OnSelected(isSelected)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.data = curData
  self:Selected(isSelected)
end

function ResonancePowerDecomposeMainLoopItem:OnUnInit()
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
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
end

return ResonancePowerDecomposeMainLoopItem
