local super = require("ui.component.loop_grid_view_item")
local BagItemsLoopItem = class("BagItemsLoopItem", super)
local item = require("common.item_binder")
local bagRed = require("rednode.bag_red")

function BagItemsLoopItem:ctor()
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.backpackData_ = Z.DataMgr.Get("backpack_data")
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  
  function self.itemWatcherFun_(container, dirtyKeys)
    if self.backpackData_.SortState then
      return
    end
    self:OnRefresh(self:GetCurData())
  end
  
  function self.packageWatcherFun(container, dirtyKeys)
    self.package_ = container
  end
end

function BagItemsLoopItem:OnInit()
  self.timerMgr_ = Z.TimerMgr.new()
  self.itemClass_ = item.new(self.parent.UIView)
end

function BagItemsLoopItem:OnRefresh(data)
  self:OnReset()
  if self.Index > #self.parent.DataList then
    self.loopGridViewItem.CanSelected = false
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, false)
    return
  end
  self.loopGridViewItem.CanSelected = true
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, true)
  local itemsVm = Z.VMMgr.GetVM("items")
  self.itemUuid_ = data.itemUuid
  self.configId_ = data.configId
  self.package_ = itemsVm.GetPackageInfobyItemId(self.configId_)
  if self.package_ == nil then
    return
  end
  self.itemData_ = self.package_.items[self.itemUuid_]
  self.package_.Watcher:RegWatcher(self.packageWatcherFun)
  self.itemData_.Watcher:RegWatcher(self.itemWatcherFun_)
  local itemData = {}
  itemData.uiBinder = self.uiBinder
  itemData.configId = self.configId_
  itemData.uuid = self.itemUuid_
  itemData.itemInfo = self.itemData_
  itemData.isClickOpenTips = false
  self.itemClass_:Init(itemData)
  self:setui()
  self.updateTimer_ = self.timerMgr_:StartFrameTimer(function()
    self:update()
  end, 1, -1)
end

function BagItemsLoopItem:setui()
  local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.itemData_.configId)
  if itemTableRow == nil then
    return
  end
  self.itemClass_:RefreshItemFlags(self.itemData_, itemTableRow)
  self.itemClass_:SetSelected(self.IsSelected)
  self:refreshRedDot()
end

function BagItemsLoopItem:refreshRedDot()
  local newItemNodeId = bagRed.GetNewItemRedId(self.package_.type, self.itemUuid_)
  local resonanceNodeId = bagRed.GetResonanceItemRedId(self.configId_)
  local isShowRedDot = Z.RedPointMgr.GetRedState(newItemNodeId) or Z.RedPointMgr.GetRedState(resonanceNodeId)
  self.itemClass_:SetRedDot(isShowRedDot)
  if not isShowRedDot then
    self.itemClass_:SetNewRedDot(self.backpackData_.NewItems[self.itemUuid_] ~= nil)
  end
end

function BagItemsLoopItem:update()
  if self.itemData_ == nil or self.package_ == nil then
    return
  end
  self:setCdUi()
end

function BagItemsLoopItem:setCdUi()
  local cdTime, useCd = self.itemVm_.GetItemCd(self.package_, self.itemData_.configId)
  if cdTime == nil or useCd == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_cd, false)
    return
  end
  self.itemClass_:RefreshItemCdUi(cdTime, useCd)
end

function BagItemsLoopItem:OnReset()
  if self.itemData_ and self.itemWatcherFun_ then
    self.itemData_.Watcher:UnregWatcher(self.itemWatcherFun_)
  end
  if self.package_ and self.packageWatcherFun then
    self.package_.Watcher:UnregWatcher(self.packageWatcherFun)
  end
  self.itemData_ = nil
  self.package_ = nil
  self.configId_ = -1
  self.itemUuid_ = -1
  self.timerMgr_:Clear()
end

function BagItemsLoopItem:OnSelected(isSelected, isClick)
  self.itemClass_:SetSelected(isSelected, isSelected)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("sys_general_frame")
    end
    local backpackView = self.parent.UIView
    backpackView:OnItemSelected(self.itemUuid_)
    local newItemNodeId = bagRed.GetNewItemRedId(self.package_.type, self.itemUuid_)
    if Z.RedPointMgr.GetRedState(newItemNodeId) then
      bagRed.RemoveRed(self.itemUuid_)
    end
    self:refreshRedDot()
  end
end

function BagItemsLoopItem:OnUnInit()
  self:OnReset()
  self.itemClass_:UnInit()
  self.updateTimer_ = nil
  self.timerMgr_ = nil
end

function BagItemsLoopItem:OnBeforePlayAnim()
  self.uiBinder.anim_dotween.OnPlay:AddListener(function()
    self.uiBinder.Ref.UIComp:SetVisible(true)
  end)
  local groupAnimComp = self.parent:GetContainerGroupAnimComp()
  if groupAnimComp then
    groupAnimComp:AddTweenContainer(self.uiBinder.anim_dotween)
    self.uiBinder.Ref.UIComp:SetVisible(false)
  end
end

return BagItemsLoopItem
