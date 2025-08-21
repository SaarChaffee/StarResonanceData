local UI = Z.UI
local super = require("ui.ui_subview_base")
local Shop_all_subView = class("Shop_all_subView", super)
local loopListView = require("ui.component.loop_list_view")
local loopGridView = require("ui.component.loop_grid_view")
local shop_loop_item = require("ui.component.season.season_shop_loop_item")
local tog2_Item = require("ui.component.shop.shop_tog2_loop_item")

function Shop_all_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "shop_all_sub", "shop/shop_all_sub", UI.ECacheLv.None, true)
  self.shopData_ = Z.DataMgr.Get("shop_data")
end

function Shop_all_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:onShowAnimShow()
  local togTplPath = Z.IsPCUI and "shop_tog2_tpl_pc" or "shop_tog2_tpl"
  self.secondLoopListView_ = loopListView.new(self, self.uiBinder.loop_second, tog2_Item, togTplPath)
  self.secondLoopListView_:Init({})
  local itemTplPath = Z.IsPCUI and "season_shop_item_tpl_pc" or "season_shop_item_tpl"
  self.itemLoopGridView_ = loopGridView.new(self, self.uiBinder.loop_all, shop_loop_item, itemTplPath)
  self.itemLoopGridView_:Init({})
  if self.viewData and self.viewData.secondIndex then
    self.selectedIndex_ = self.viewData.secondIndex
  else
    self.selectedIndex_ = 1
  end
  self:RefreshData()
end

function Shop_all_subView:OnDeActive()
  self.secondLoopListView_:UnInit()
  self.itemLoopGridView_:UnInit()
end

function Shop_all_subView:RefreshData(isNoRefresSelected)
  self.isNoRefresSelected_ = isNoRefresSelected
  local isShowSecondTab = #self.viewData.shopTabData.secondaryTabList > 1
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab, isShowSecondTab)
  if isShowSecondTab then
    self.secondLoopListView_:RefreshListView(self.viewData.shopTabData.secondaryTabList, false)
    self.secondLoopListView_:ClearAllSelect()
    self.secondLoopListView_:SetSelected(self.selectedIndex_)
  elseif #self.viewData.shopTabData.secondaryTabList > 0 then
    self:Tog2Click(self.viewData.shopTabData.secondaryTabList[1])
  else
    self.secondLoopListView_:RefreshListView({}, false)
    self:Tog2Click(self.viewData.shopTabData.fristLevelTabData, -1)
  end
end

function Shop_all_subView:Tog2Click(shopTabData, index)
  self.selectedIndex_ = index or 1
  self.viewData.parentView:OpenCurrencyView(shopTabData.CurrencyDisplay)
  local showItemList = self:getShowData(shopTabData.Id)
  if showItemList == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_all, false)
  else
    self.itemLoopGridView_:RefreshListView(showItemList.items, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_all, true)
    local isSelect = false
    if self.viewData.configId then
      for k, v in ipairs(showItemList.items) do
        local mallItemCfgData = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(v.itemId)
        if mallItemCfgData and mallItemCfgData.ItemId == self.viewData.configId and not self.isNoRefresSelected_ then
          self.itemLoopGridView_:MovePanelToItemIndex(k)
          self.itemLoopGridView_:SetSelected(k)
          isSelect = true
          break
        end
      end
      self.viewData.configId = nil
    end
    if not isSelect and not self.isNoRefresSelected_ then
      self.itemLoopGridView_:MovePanelToItemIndex(1)
    end
  end
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
  local top = Z.IsPCUI and -3 or 22
  local bottom = Z.IsPCUI and -7 or -9
  if shopTabData.RefreshIntervalType == 0 then
    self.uiBinder.loop_second_ref:SetOffsetMin(0, bottom)
    self.uiBinder.loop_second_ref:SetOffsetMax(0, top)
  elseif shopTabData.RefreshIntervalType == 15 then
    self.uiBinder.loop_second_ref:SetOffsetMin(0, bottom)
    self.uiBinder.loop_second_ref:SetOffsetMax(500, top)
  elseif shopTabData.RefreshIntervalType == 17 then
    self.uiBinder.loop_second_ref:SetOffsetMin(0, bottom)
    self.uiBinder.loop_second_ref:SetOffsetMax(500, top)
  end
  if shopTabData.ShowType == E.EShopType.CompensateShop then
    self.uiBinder.lab_reset_time.text = Lang("shopResetTime2")
  else
    self.uiBinder.lab_reset_time.text = ""
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
  local cfg
  if self.selectedIndex_ == -1 then
    cfg = self.viewData.shopTabData.fristLevelTabData
  else
    cfg = self.viewData.shopTabData.secondaryTabList[self.selectedIndex_]
  end
  if cfg == nil then
    logError("[Shop] secondaryTabList[" .. index .. "] is nil")
    return
  end
  self.viewData.parentView:OpenBuyPopup(data, index, cfg.Id)
end

function Shop_all_subView:onShowAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Shop_all_subView:RigestTimerCall(key, func)
  self.viewData.parentView:RigestTimerCall(key, func)
end

function Shop_all_subView:UnrigestTimerCall(key)
  self.viewData.parentView:UnrigestTimerCall(key)
end

function Shop_all_subView:UpdateProp()
  self.viewData.parentView:UpdateProp()
end

return Shop_all_subView
