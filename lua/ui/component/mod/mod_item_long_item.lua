local super = require("ui.component.loop_list_view_item")
local ModItemLongItem = class("ModItemLongItem", super)
local item = require("common.item_binder")
ModItemLongItem.Type = {
  LoopMods = 1,
  DecomposeItem = 2,
  ModResolve = 3,
  LoopDecomposeMods = 4
}

function ModItemLongItem:ctor()
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.modVm_ = Z.VMMgr.GetVM("mod")
end

function ModItemLongItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
end

function ModItemLongItem:OnRefresh(data)
  self.data_ = data
  self.type_ = data.type
  local itemInfo = self.itemVm_.GetItemInfobyItemId(data.uuid, data.configId)
  if self.type_ == ModItemLongItem.Type.LoopMods or self.type_ == ModItemLongItem.Type.LoopDecomposeMods then
    local itemData = {}
    itemData.uiBinder = self.uiBinder
    itemData.configId = data.configId
    itemData.uuid = data.uuid
    itemData.labType = E.ItemLabType.Str
    itemData.lab = ""
    itemData.itemInfo = itemInfo
    
    function itemData.clickCallFunc()
      if self.type_ == ModItemLongItem.Type.LoopMods or self.type_ == ModItemLongItem.Type.LoopDecomposeMods then
        self.parent.UIView:SetSelectUuid(self.data_.uuid)
      end
    end
    
    self.itemClass_:Init(itemData)
    if self.type_ == ModItemLongItem.Type.LoopMods then
      self.itemClass_:SetSelected(data.isSelected)
    elseif self.type_ == ModItemLongItem.Type.LoopDecomposeMods then
      self.itemClass_:SetNodeVisible(self.itemClass_.uiBinder.img_more_selected, data.isSelected)
    end
    local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemData.configId)
    self.itemClass_:RefreshItemFlags(itemInfo, itemTableRow)
    self.itemClass_:SetRedDot(data.isRed)
    self.uiBinder.Trans:SetScale(1, 1)
  elseif self.type_ == ModItemLongItem.Type.DecomposeItem then
    local itemData = {}
    itemData.uiBinder = self.uiBinder
    itemData.configId = data.configId
    itemData.isSquareItem = true
    itemData.labType = data.labType
    itemData.lab = data.lab
    itemData.PrevDropType = data.prevDropType
    itemData.itemInfo = itemInfo
    self.itemClass_:Init(itemData)
    self.uiBinder.Trans:SetScale(1, 1)
  elseif self.type_ == ModItemLongItem.Type.ModResolve then
    local itemData = {}
    itemData.uiBinder = self.uiBinder
    itemData.configId = data.configId
    itemData.uuid = data.uuid
    itemData.labType = E.ItemLabType.Str
    itemData.lab = ""
    itemData.itemInfo = itemInfo
    self.itemClass_:Init(itemData)
    local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemData.configId)
    self.itemClass_:RefreshItemFlags(itemInfo, itemTableRow)
    self.uiBinder.Trans:SetScale(0.7, 0.7)
  end
end

function ModItemLongItem:OnSelected(isSelected)
  if self.type_ == ModItemLongItem.Type.LoopMods then
    self.itemClass_:SetSelected(isSelected, isSelected)
  end
end

function ModItemLongItem:OnUnInit()
  self.itemClass_:UnInit()
end

return ModItemLongItem
