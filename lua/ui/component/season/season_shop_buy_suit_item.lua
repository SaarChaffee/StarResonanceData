local super = require("ui.component.loop_list_view_item")
local SeasonShopBuySuitItem = class("SeasonShopBuySuitItem", super)
local item = require("common.item_binder")
local loopGridView = require("ui.component.loop_grid_view")
local season_shop_buy_suit_single_item = require("ui.component.season.season_shop_buy_suit_single_item")

function SeasonShopBuySuitItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.loopList_ = loopGridView.new(self, self.uiBinder.loop_list, season_shop_buy_suit_single_item, "shop_buy_suit_one_item_tpl")
  self.loopList_:Init({})
end

function SeasonShopBuySuitItem:OnUnInit()
  self.itemClass_:UnInit()
  self.loopList_:UnInit()
end

function SeasonShopBuySuitItem:OnRefresh(data)
  self.data_ = data.data
  local itemData = {
    configId = self.data_.mallItemRow.ItemId,
    uiBinder = self.uiBinder.node_item,
    isShowZero = false,
    isShowOne = true,
    isSquareItem = true
  }
  self.itemClass_:Init(itemData)
  local itemVM = Z.VMMgr.GetVM("items")
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.data_.mallItemRow.ItemId)
  self.uiBinder.lab_name.text = itemRow.Name
  self.uiBinder.lab_have.text = ""
  self.uiBinder.lab_price.text = self.data_.CostValue
  self.uiBinder.lab_original.text = self.data_.OriginalValue
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_original, self.data_.OriginalValue > 0)
  for id, num in pairs(self.data_.mallItemRow.Cost) do
    local itemcfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id)
    if itemcfg then
      self.uiBinder.rimg_price:SetImage(itemVM.GetItemIcon(id))
    end
    break
  end
  local groupList = {}
  if self.data_.mallItemRow.GoodsGroup and 0 < #self.data_.mallItemRow.GoodsGroup then
    local shopVm = Z.VMMgr.GetVM("shop")
    for i = 1, #self.data_.mallItemRow.GoodsGroup do
      local row = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(self.data_.mallItemRow.GoodsGroup[i], true)
      if row and shopVm.CheckUnlockCondition(row.UnlockConditions) then
        groupList[#groupList + 1] = {
          row = row,
          parent = self.parent.UIView
        }
      end
    end
    self.loopList_:RefreshListView(groupList, false)
  end
  if 5 < #groupList then
    self.uiBinder.loop_ref:SetHeight(300)
    self.uiBinder.Trans:SetHeight(464)
  else
    self.uiBinder.loop_ref:SetHeight(170)
    self.uiBinder.Trans:SetHeight(334)
  end
  self.loopListView:OnItemSizeChanged(self.Index)
end

return SeasonShopBuySuitItem
