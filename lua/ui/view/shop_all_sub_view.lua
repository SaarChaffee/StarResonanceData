local UI = Z.UI
local super = require("ui.ui_subview_base")
local Shop_all_subView = class("Shop_all_subView", super)
local loopListView = require("ui.component.loop_list_view")
local loopGridView = require("ui.component.loop_grid_view")
local shop_loop_item = require("ui.component.season.season_shop_loop_item")
local tog2_Item = require("ui.component.shop.shop_tog2_loop_item")

function Shop_all_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "shop_all_sub", "shop/shop_all_sub", UI.ECacheLv.None)
end

function Shop_all_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:onShowAnimShow()
  self.secondLoopListView_ = loopListView.new(self, self.uiBinder.loop_second, tog2_Item, "shop_tog2_tpl")
  self.secondLoopListView_:Init({})
  self.itemLoopGridView_ = loopGridView.new(self, self.uiBinder.loop_all, shop_loop_item, "season_shop_item_tpl")
  self.itemLoopGridView_:Init({})
  self:refreshData()
end

function Shop_all_subView:OnDeActive()
  self.secondLoopListView_:UnInit()
  self.itemLoopGridView_:UnInit()
end

function Shop_all_subView:refreshData(isNoRefresSelected)
  local isShowSecondTab = #self.viewData.shopTabData.secondaryTabList > 1
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab, isShowSecondTab)
  if isShowSecondTab then
    local index = 1
    if isNoRefresSelected and self.selectedIndex_ then
      index = self.selectedIndex_
    end
    if self.viewData.parentView.viewData and self.viewData.parentView.viewData.funcId2 then
      local funcId = tonumber(self.viewData.parentView.viewData.funcId2)
      for k, data in ipairs(self.viewData.shopTabData.secondaryTabList) do
        if data.FunctionId == funcId then
          index = k
          break
        end
      end
      self.viewData.parentView.viewData.funcId2 = nil
    end
    self.secondLoopListView_:RefreshListView(self.viewData.shopTabData.secondaryTabList, false)
    self.secondLoopListView_:ClearAllSelect()
    self.secondLoopListView_:SetSelected(index)
  else
    self:Tog2Click(self.viewData.shopTabData.secondaryTabList[1])
  end
end

function Shop_all_subView:Tog2Click(shopTabData, index)
  if index then
    self.selectedIndex_ = index
  else
    self.selectedIndex_ = 1
  end
  self.viewData.parentView:OpenCurrencyView(shopTabData.CurrencyDisplay)
  local showItemList = self:getShowData(shopTabData.Id)
  if showItemList == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_all, false)
  else
    self.itemLoopGridView_:RefreshListView(showItemList.items, false)
    self.itemLoopGridView_:MovePanelToItemIndex(1)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_all, true)
  end
end

function Shop_all_subView:getShowData(Id)
  for _, value in pairs(self.viewData.shopData) do
    if value.Id == Id then
      return value
    end
  end
end

function Shop_all_subView:OpenBuyPopup(data, index)
  local cfg = self.viewData.shopTabData.secondaryTabList[self.selectedIndex_]
  if cfg == nil then
    logError("[Shop] secondaryTabList[" .. index .. "] is nil")
    return
  end
  self.viewData.parentView:OpenBuyPopup(data, index, cfg.Id)
end

function Shop_all_subView:onShowAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Shop_all_subView
