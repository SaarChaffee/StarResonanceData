local UI = Z.UI
local super = require("ui.ui_subview_base")
local Season_shop_subView = class("Season_shop_subView", super)
local loopScrollRect_ = require("ui/component/loop_grid_view")
local shop_loop_item_ = require("ui/component/season/season_shop_loop_item")
local currency_item_list = require("ui.component.currency.currency_item_list")

function Season_shop_subView:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_shop_sub", "season/season_shop_sub", UI.ECacheLv.None, true)
end

function Season_shop_subView:OnActive()
  self.data_ = Z.DataMgr.Get("season_data")
  self.shopVM_ = Z.VMMgr.GetVM("shop")
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {})
  self.allRedNodeTab_ = {}
  self.togItemDict_ = {}
  self:startAnimatedShow()
  self:initwidgets()
  Z.CoroUtil.create_coro_xpcall(function()
    self:initProps()
    self:initPages()
  end)()
  Z.EventMgr:Add(Z.ConstValue.Shop.NotifyBuyShopResult, self.buyCallFunc, self)
end

function Season_shop_subView:OnDeActive()
  self.propLoopScrollRect_:UnInit()
  self.propLoopScrollRect_ = nil
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
  self:clearAllLoadItem()
  self:startAnimatedHide()
  self.curChoosePage = -1
  self.timerCallTable_ = nil
  for _, nodeId in pairs(self.allRedNodeTab_) do
    Z.RedPointMgr.RemoveNodeItem(nodeId)
  end
end

function Season_shop_subView:initwidgets()
  self.pageItemParent_ = self.uiBinder.cont_info.layout
  self.pageToggleGroup_ = self.uiBinder.cont_info.togs_layout
  self.emptyGo_ = self.uiBinder.cont_info.cont_empty
  self.season_time_label_ = self.uiBinder.cont_info.lab_table_name
  self.propLoopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.cont_info.loopscroll, shop_loop_item_, "season_shop_item_tpl", true)
  self.propLoopScrollRect_:Init({})
end

function Season_shop_subView:initPages()
  self.curChoosePage = -1
  local path = self:GetPrefabCacheData("pageitem")
  local showFunction = self.data_:GetSubPageId()
  local showIndex = 1
  for index, value in ipairs(self.shopData_) do
    if showFunction == value.cfg.FunctionId then
      showIndex = index
      break
    end
  end
  local clickItem_
  for i = 1, #self.shopData_ do
    local itemName = "season_shop_page_" .. i
    local itemUnit = self:AsyncLoadUiUnit(path, itemName, self.pageItemParent_)
    local cfg = self.shopData_[i].cfg
    local index = i
    local clickFunc_ = function(ison)
      if ison then
        if self.curChoosePage ~= -1 then
          self:onSelectTabAnimShow()
        end
        self:onPageToggleIsOn(index)
        self:startClickAnimatedShow(itemUnit)
      end
    end
    self.togItemDict_[itemName] = itemUnit
    itemUnit.tog_item.group = self.pageToggleGroup_
    itemUnit.tog_item:AddListener(clickFunc_)
    itemUnit.lab_name_1.text = cfg.Name
    itemUnit.lab_name_2.text = cfg.Name
    if cfg.Icon == "" or not cfg.Icon then
      itemUnit.Ref:SetVisible(itemUnit.img_icon, false)
      itemUnit.Ref:SetVisible(itemUnit.img_icon2, false)
    else
      itemUnit.Ref:SetVisible(itemUnit.img_icon, true)
      itemUnit.Ref:SetVisible(itemUnit.img_icon2, true)
      itemUnit.img_icon:SetImage(cfg.Icon)
      itemUnit.img_icon2:SetImage(cfg.Icon)
    end
    local redNodeId = E.RedType.SeasonShop .. E.RedType.SeasonShopOneTab .. cfg.Id
    Z.RedPointMgr.LoadRedDotItem(redNodeId, self, itemUnit.Trans)
    table.insert(self.allRedNodeTab_, redNodeId)
    if clickItem_ == nil then
      clickItem_ = itemUnit
    end
    local isFirst = index == showIndex
    if isFirst then
      clickItem_ = itemUnit
    end
  end
  if not clickItem_ then
    return
  end
  if clickItem_.tog_item.isOn then
    clickItem_.tog_item.isOn = false
  end
  clickItem_.tog_item.isOn = true
end

function Season_shop_subView:clearAllLoadItem()
  for itemName, item in pairs(self.togItemDict_) do
    item.tog_item:RemoveAllListeners()
    item.tog_item.group = nil
    item.tog_item.isOn = false
    self:RemoveUiUnit(itemName)
  end
  self.togItemDict_ = {}
end

function Season_shop_subView:initProps()
  self.timerMgr:Clear()
  self.shopData_ = self.shopVM_.AsyncGetShopDataByShopType(E.EShopType.SeasonShop, self.cancelSource:CreateToken())
  self.timerMgr:StartTimer(function()
    self:UpdateProp()
  end, Z.TimeTools.GetCurDayEndTime(), 1)
  self.timerMgr:StartTimer(function()
    if self.timerCallTable_ then
      for _, func in pairs(self.timerCallTable_) do
        if func then
          func()
        end
      end
    end
  end, 1, -1)
  local t = 0
  local curT = Z.TimeTools.Now()
  for _, page in ipairs(self.shopData_) do
    for _, item in ipairs(page.items) do
      if 0 < item.endTime and curT < item.endTime and (t == 0 or t > item.endTime - curT) then
        t = item.endTime - curT
      end
    end
  end
  if 0 < t then
    t = math.floor(t / 1000)
    if t == 0 then
      t = 1
    end
    self.timerMgr:StartTimer(function()
      self:UpdateProp()
    end, t, 1)
  end
end

function Season_shop_subView:onPageToggleIsOn(index)
  if self.curChoosePage == index then
    return
  end
  self.curChoosePage = index
  self.currencyIds_ = self.shopData_[index].cfg.CurrencyDisplay
  self.currencyItemList_:Init(self.uiBinder.currency_info, self.currencyIds_)
  self:showProp(index)
  self:showSeasonTime()
end

function Season_shop_subView:showProp(index)
  local props = self.shopData_[index]
  self.propLoopScrollRect_:RefreshListView(props.items)
  self.emptyGo_.Ref.UIComp:SetVisible(#props.items <= 0)
  if self.data_:GetCurSelectItem() then
    for k, v in ipairs(props.items) do
      local mallItemCfgData = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(v.itemId)
      if mallItemCfgData and mallItemCfgData.ItemId == self.data_:GetCurSelectItem() then
        self.propLoopScrollRect_:MovePanelToItemIndex(k)
        self.propLoopScrollRect_:SetSelected(k)
        break
      end
    end
    self.data_:SetCurSelectItem(nil)
  end
end

function Season_shop_subView:showSeasonTime()
  local cfg = self.shopData_[self.curChoosePage].cfg
  self.season_time_label_.text = Z.TimeTools.GetTimeDescByTimerId(cfg.TimerId)
end

function Season_shop_subView:UpdateProp()
  self.timerCallTable_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    self:initProps()
    self:showProp(self.curChoosePage)
  end)()
end

function Season_shop_subView:GetPropData(index)
  return self.shopData_[self.curChoosePage].items[index]
end

function Season_shop_subView:OpenBuyPopup(data)
  self.shopVM_.OpenBuyPopup(data, function(data_, num)
    self.shopVM_.AsyncShopBuyItemList({
      [data.itemId] = {buyNum = num}
    }, self.cancelSource:CreateToken())
  end, self.currencyIds_)
end

function Season_shop_subView:buyCallFunc(buyShopItemInfo)
  if buyShopItemInfo then
    local isSuccess = false
    local updataShopId, updataShopItemId
    for _, data in pairs(buyShopItemInfo) do
      if data.errCode == 0 then
        isSuccess = true
        updataShopId = data.shopId
        updataShopItemId = data.itemId
        local mallCfg = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(data.itemId)
        if mallCfg then
          for id, num in pairs(mallCfg.Cost) do
            if num == 0 then
              self.shopVM_.SetShopItemRed(data.itemId, E.EShopType.SeasonShop)
              break
            end
          end
        end
        self.shopVM_.ShowBuyResultTips(mallCfg.DeliverWay)
      else
        Z.TipsVM.ShowTips(data.errCode)
      end
    end
    if isSuccess and updataShopId and updataShopItemId then
      self.shopVM_.CloseBuyPopup()
      Z.CoroUtil.create_coro_xpcall(function()
        local shopData = self.shopVM_.AsyncGetShopData({updataShopId}, self.cancelSource:CreateToken())
        for i = 1, #self.shopData_ do
          if updataShopId == self.shopData_[i].Id then
            self.shopVM_.UpdataShopItemData(self.shopData_[i].items, shopData, updataShopId, updataShopItemId)
            break
          end
        end
        local props = self.shopData_[self.curChoosePage]
        self.propLoopScrollRect_:RefreshListView(props.items)
      end)()
    end
  end
end

function Season_shop_subView:RigestTimerCall(key, func)
  if not self.timerCallTable_ then
    self.timerCallTable_ = {}
  end
  self.timerCallTable_[key] = func
end

function Season_shop_subView:UnrigestTimerCall(key)
  if self.timerCallTable_ then
    self.timerCallTable_[key] = nil
  end
end

function Season_shop_subView:onSelectTabAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_1)
end

function Season_shop_subView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Season_shop_subView:startClickAnimatedShow(item)
  item.uianim_select:PlayOnce("anim_season_tab_select_open")
end

function Season_shop_subView:startAnimatedHide()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Close)
end

function Season_shop_subView:GetPrefabCacheData(key)
  local prefabCache = self.uiBinder.prefabcache_root
  if prefabCache == nil then
    return nil
  end
  return prefabCache:GetString(key)
end

return Season_shop_subView
