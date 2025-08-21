local UI = Z.UI
local super = require("ui.ui_subview_base")
local Shop_mysterious_subView = class("Shop_mysterious_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local shop_loop_item = require("ui.component.season.season_shop_loop_item")

function Shop_mysterious_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "shop_mysterious_sub", "shop/shop_mysterious_sub", UI.ECacheLv.None, true)
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.privilegesData_ = Z.DataMgr.Get("privileges_data")
end

function Shop_mysterious_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:onStartAnimShow()
  self.itemLoopGridView_ = loopGridView.new(self, self.uiBinder.node_loop, shop_loop_item, "season_shop_item_tpl", true)
  self.itemLoopGridView_:Init({})
  self.uiBinder.lab_reset_time.text = Lang("shopResetTime")
  self.curRefreshCount_ = 0
  self.maxRefreshCount_ = 0
  self:AddAsyncClick(self.uiBinder.btn_square_icon, function()
    if self.curRefreshCount_ >= self.maxRefreshCount_ then
      Z.TipsVM.ShowTipsLang(4806)
      return
    end
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("CertainRefreshShopMysterious"), function()
      self:asyncRefreshTime()
      Z.TipsVM.ShowTips(1000747, {
        val = self.maxRefreshCount_ - self.curRefreshCount_
      })
    end)
  end)
  self:refreshCost()
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncGetShopData()
  end)()
  self:startTimer()
end

function Shop_mysterious_subView:OnDeActive()
  self.timerMgr:Clear()
  self.itemLoopGridView_:UnInit()
end

function Shop_mysterious_subView:OnRefresh()
  self:RefreshData()
end

function Shop_mysterious_subView:refreshCost()
  self.maxRefreshCount_ = 0
  local privilegeData = self.privilegesData_:GetPrivilegesDataByFunction(E.PrivilegeSourceType.BattlePass, E.PrivilegeEffectType.ShopRefreshTimesBonus)
  if privilegeData then
    self.maxRefreshCount_ = privilegeData.value
  else
    self:SetUIVisible(self.uiBinder.node_cost, false)
    return
  end
  self.curRefreshCount_ = 0
  for shopId, refreshList in pairs(Z.ContainerMgr.CharSerialize.shopData.refreshList) do
    if shopId == self.viewData.shopTabData.fristLevelTabData.Id then
      self.curRefreshCount_ = refreshList.refreshCount
      break
    end
  end
  local param = {
    val1 = self.maxRefreshCount_ - self.curRefreshCount_,
    val2 = self.maxRefreshCount_
  }
  self.uiBinder.lab_reset_count.text = Lang("shopResetCount", param)
end

function Shop_mysterious_subView:RefreshData()
  local itemList = {}
  for _, value in pairs(self.viewData.shopData) do
    if value.Id == self.viewData.shopTabData.fristLevelTabData.Id then
      itemList = value.items
      break
    end
  end
  self.itemLoopGridView_:RefreshListView(itemList, false)
end

function Shop_mysterious_subView:startTimer()
  self.timerMgr:Clear()
  local startTime = Z.TimeTools.GetStartEndTimeByTimerId(self.viewData.shopTabData.fristLevelTabData.RefreshIntervalType) * 1000
  local curTime = Z.TimeTools.Now()
  local surpluseTime = -1
  if startTime > curTime then
    surpluseTime = (startTime - curTime) / 1000
  else
    surpluseTime = (startTime - curTime) / 1000 + 86400
  end
  if surpluseTime == -1 then
    return
  end
  self.timerMgr:StartTimer(function()
    Z.CoroUtil.create_coro_xpcall(function()
      self:asyncGetShopData()
    end)()
  end, surpluseTime, 1)
end

function Shop_mysterious_subView:asyncRefreshTime()
  local reply = self.shopVm_.AsyncRefreshShop(self.viewData.shopTabData.fristLevelTabData.Id, self.cancelSource:CreateToken())
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  else
    self:asyncGetShopData()
  end
end

function Shop_mysterious_subView:asyncGetShopData()
  self.viewData.parentView.shopData_ = self.shopVm_.AsyncGetShopDataByShopType(E.EShopType.Shop, self.cancelSource:CreateToken())
  self.viewData.shopData = self.viewData.parentView.shopData_
  self:refreshCost()
  self:RefreshData()
end

function Shop_mysterious_subView:OpenBuyPopup(data, index)
  self.viewData.parentView:OpenBuyPopup(data, index, self.viewData.shopTabData.fristLevelTabData.Id)
end

function Shop_mysterious_subView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Shop_mysterious_subView:RigestTimerCall(key, func)
  self.viewData.parentView:RigestTimerCall(key, func)
end

function Shop_mysterious_subView:UnrigestTimerCall(key)
  self.viewData.parentView:UnrigestTimerCall(key)
end

function Shop_mysterious_subView:UpdateProp()
  self.viewData.parentView:UpdateProp()
end

return Shop_mysterious_subView
