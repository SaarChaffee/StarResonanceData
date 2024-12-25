local super = require("ui.component.loop_list_view_item")
local ExchangeMaterialsLoopItem = class("ExchangeMaterialsLoopItem", super)
local item = require("common.item_binder")
local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")

function ExchangeMaterialsLoopItem:ctor()
end

function ExchangeMaterialsLoopItem:OnInit()
  self.exchangeView_ = self.parent.UIView
  self.itemClass_ = item.new(self.exchangeView_)
end

function ExchangeMaterialsLoopItem:Refresh()
  self.isSelected_ = false
  self.materialsInfo_ = self:GetCurData()
  local needNum = self.materialsInfo_.consumeNum * self.exchangeView_.curNum_
  if needNum > self.materialsInfo_.ownNum then
    self.isConsumeItemEnough_ = false
  end
  local itemRow = itemTbl.GetRow(self.materialsInfo_.id)
  if itemRow == nil then
    return
  end
  local itemVm = Z.VMMgr.GetVM("items")
  local itemIcon = itemVm.GetItemIcon(self.materialsInfo_.id)
  local itemData = {
    uiBinder = self.uiBinder,
    configId = itemRow.Id,
    iconPath = itemIcon,
    qualityPath = Z.ConstValue.Item.SquareItemQualityPath .. itemRow.Quality,
    isClickOpenTips = false,
    isSquareItem = true,
    labType = E.ItemLabType.Expend,
    lab = self.materialsInfo_.ownNum,
    expendCount = needNum,
    colorKey = E.TextStyleTag.ItemNotEnough
  }
  self.itemClass_:Init(itemData)
  self.itemClass_:SetExchangeComplete(false)
end

function ExchangeMaterialsLoopItem:OnPointerClick(go, eventData)
  self.exchangeView_:showItemInfoTips(self.materialsInfo_.id)
end

function ExchangeMaterialsLoopItem:Selected(isSelected)
  if self.isSelected_ == isSelected then
    return
  end
  self.isSelected_ = isSelected
end

function ExchangeMaterialsLoopItem:OnUnInit()
  self.itemClass_:UnInit()
  self.isSelected_ = false
end

function ExchangeMaterialsLoopItem:OnReset()
  self.isSelected_ = false
end

return ExchangeMaterialsLoopItem
