local UI = Z.UI
local super = require("ui.ui_subview_base")
local Shop_mysterious_subView = class("Shop_mysterious_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local shop_loop_item = require("ui.component.season.season_shop_loop_item")

function Shop_mysterious_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "shop_mysterious_sub", "shop/shop_mysterious_sub", UI.ECacheLv.None)
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.seasonVm_ = Z.VMMgr.GetVM("season_shop")
end

function Shop_mysterious_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:onStartAnimShow()
  self.itemLoopGridView_ = loopGridView.new(self, self.uiBinder.node_loop, shop_loop_item, "season_shop_item_tpl")
  self.itemLoopGridView_:Init({})
  self.uiBinder.lab_reset_time.text = Lang("shopResetTime")
  self:AddAsyncClick(self.uiBinder.btn_square_icon, function()
    if self.curRefreshCount_ >= self.maxRefreshCount_ then
      Z.TipsVM.ShowTipsLang(4806)
      return
    end
    if self.costItemCount_ == 0 then
      self:asyncRefreshTime(false)
    else
      Z.DialogViewDataMgr:OpenNormalItemsDialog(Lang("CertainRefreshShopMysterious"), function()
        local itemCount = self.itemsVm_.GetItemTotalCount(self.costItemId_)
        if itemCount < self.costItemCount_ then
          local costItemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.costItemId_)
          if costItemRow then
            Z.TipsVM.ShowTips(100010, {
              item = {
                name = costItemRow.Name
              }
            })
          else
            Z.TipsVM.ShowTips(4801)
          end
          return
        end
        self:asyncRefreshTime(false)
        Z.DialogViewDataMgr:CloseDialogView()
        Z.TipsVM.ShowTips(1000747, {
          val = self.maxRefreshCount_ - self.curRefreshCount_
        })
      end, nil, {
        {
          ItemId = self.costItemId_,
          ItemNum = self.costItemCount_,
          LabType = E.ItemLabType.Expend
        }
      })
    end
  end)
  self:refreshCost()
end

function Shop_mysterious_subView:OnDeActive()
  self.itemLoopGridView_:UnInit()
end

function Shop_mysterious_subView:OnRefresh()
  self:refreshData()
end

function Shop_mysterious_subView:refreshCost()
  if not self.viewData.shopTabData then
    return
  end
  self:refreshTime()
  if self.viewData.shopTabData.fristLevelTabData.MallManualRefresh == 0 then
    self:SetUIVisible(self.uiBinder.node_cost, false)
    return
  end
  self:SetUIVisible(self.uiBinder.node_cost, true)
  local refreshItem = self.viewData.shopTabData.fristLevelTabData.RefreshCostItem
  local refreshItemCount = #refreshItem
  self.maxRefreshCount_ = refreshItem[refreshItemCount][2]
  if self.curRefreshCount_ >= self.maxRefreshCount_ then
    local costItemId = refreshItem[refreshItemCount][3]
    local costItemCount = refreshItem[refreshItemCount][4]
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(costItemId)
    self.uiBinder.rimg_icon:SetImage(itemRow.Icon)
    self.costItemId_ = costItemId
    self.costItemCount_ = costItemCount
    if costItemCount == 0 then
      self.uiBinder.lab_cost_count.text = Lang("Free")
      self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_reset, true)
    else
      self.uiBinder.lab_cost_count.text = "x" .. self.costItemCount_
      self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_reset, false)
    end
  else
    for i = 1, #refreshItem do
      local startIndex = refreshItem[i][1]
      local endIndex = refreshItem[i][2]
      local costItemId = refreshItem[i][3]
      local costItemCount = refreshItem[i][4]
      if startIndex <= self.curRefreshCount_ + 1 and endIndex >= self.curRefreshCount_ + 1 then
        self.costItemId_ = costItemId
        self.costItemCount_ = costItemCount
        if costItemCount == 0 then
          self.uiBinder.lab_cost_count.text = Lang("Free")
          self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, false)
          self.uiBinder.Ref:SetVisible(self.uiBinder.img_reset, true)
          break
        end
        self.uiBinder.lab_cost_count.text = "x" .. self.costItemCount_
        self.uiBinder.rimg_icon:SetImage(self.itemsVm_.GetItemIcon(costItemId))
        self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, true)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_reset, false)
        break
      end
    end
  end
  local param = {
    val1 = self.maxRefreshCount_ - self.curRefreshCount_,
    val2 = self.maxRefreshCount_
  }
  self.uiBinder.lab_reset_count.text = Lang("shopResetCount", param)
end

function Shop_mysterious_subView:refreshTime()
  local refreshCount = 0
  local lastRefreshTime = 0
  for shopId, refreshList in pairs(Z.ContainerMgr.CharSerialize.shopData.refreshList) do
    if shopId == self.viewData.shopTabData.fristLevelTabData.Id then
      refreshCount = table.zcount(refreshList.timestamp)
      if 0 < refreshCount then
        lastRefreshTime = refreshList.timestamp[refreshCount]
      end
      break
    end
  end
  self.curRefreshCount_ = refreshCount - 1
  self:checkRefresh(lastRefreshTime)
end

function Shop_mysterious_subView:refreshData()
  local itemList = {}
  for _, value in pairs(self.viewData.shopData) do
    if value.Id == self.viewData.shopTabData.fristLevelTabData.Id then
      itemList = value.items
      break
    end
  end
  self.itemLoopGridView_:RefreshListView(itemList, false)
end

function Shop_mysterious_subView:checkRefresh(lastRefreshTime)
  local isNeedRefresh = false
  if lastRefreshTime == 0 then
    isNeedRefresh = true
  else
    local startTime = Z.TimeTools.GetStartTimeByTimerId(self.viewData.shopTabData.fristLevelTabData.RefreshIntervalType)
    if lastRefreshTime < startTime / 1000 and Z.TimeTools.Now() / 1000 >= startTime / 1000 then
      isNeedRefresh = true
    end
  end
  if isNeedRefresh then
    Z.CoroUtil.create_coro_xpcall(function()
      self:asyncRefreshTime(true)
    end)()
  end
end

function Shop_mysterious_subView:asyncRefreshTime(auto)
  local reply = self.shopVm_.AsyncRefreshShop(self.viewData.shopTabData.fristLevelTabData.Id, auto, self.cancelSource:CreateToken())
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  else
    self.viewData.parentView.shopData_ = self.seasonVm_.AsyncGetShopData(self.cancelSource, 0)
    local shopTabDataList = self.shopVm_.GetShopTabTable(self.viewData.parentView.shopData_)
    self.viewData.parentView.shopTabDataList_ = shopTabDataList
    for _, shopData in ipairs(shopTabDataList) do
      if shopData.fristLevelTabData.FunctionId == self.viewData.shopTabData.fristLevelTabData.FunctionId then
        self.viewData.shopTabData = shopData
        self.viewData.shopData = self.viewData.parentView.shopData_
      end
    end
    self:refreshCost()
    self:refreshData()
  end
end

function Shop_mysterious_subView:OpenBuyPopup(data, index)
  self.viewData.parentView:OpenBuyPopup(data, index, self.viewData.shopTabData.fristLevelTabData.Id)
end

function Shop_mysterious_subView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Shop_mysterious_subView
