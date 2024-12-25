local super = require("ui.component.loop_grid_view_item")
local DungeonKeyLoopItem = class("DungeonKeyLoopItem", super)
local item = require("common.item_binder")

function DungeonKeyLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.parentView_ = self.parent.UIView
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function DungeonKeyLoopItem:OnRefresh(data)
  if data == nil then
    return
  end
  local itemData = {}
  local configID = self.itemsVM_.GetItemConfigId(data, E.BackPackItemPackageType.Item)
  itemData.configId = configID
  itemData.uiBinder = self.uiBinder
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isSquareItem = true
  local showSelect = self.parentView_.selectItemUuid == data
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, showSelect)
  
  function itemData.clickCallFunc()
    self.parentView_:OnClickItem(data)
  end
  
  self.itemClass_:RefreshByData(itemData)
  self.itemClass_:SetSelected(showSelect)
end

function DungeonKeyLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

return DungeonKeyLoopItem
