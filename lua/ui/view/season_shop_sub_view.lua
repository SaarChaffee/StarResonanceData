local UI = Z.UI
local super = require("ui.ui_subview_base")
local Season_shop_subView = class("Season_shop_subView", super)
local loopScrollRect_ = require("ui/component/loop_grid_view")
local shop_loop_item_ = require("ui/component/season/season_shop_loop_item")

function Season_shop_subView:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_shop_sub", "season/season_shop_sub", UI.ECacheLv.None)
  self.vm = Z.VMMgr.GetVM("season_shop")
  self.data_ = Z.DataMgr.Get("season_data")
end

function Season_shop_subView:OnActive()
  self.allRedNodeTab_ = {}
  self.togItemDict_ = {}
  self:startAnimatedShow()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:initwidgets()
  Z.CoroUtil.create_coro_xpcall(function()
    self:initProps()
    self:initPages()
  end)()
end

function Season_shop_subView:OnDeActive()
  self.propLoopScrollRect_:UnInit()
  self.propLoopScrollRect_ = nil
  self:clearAllLoadItem()
  self:startAnimatedHide()
  self.curChoosePage = -1
  self.timerCallTable_ = nil
  Z.VMMgr.GetVM("currency").CloseCurrencyView(self)
  for key, nodeId in pairs(self.allRedNodeTab_) do
    Z.RedPointMgr.RemoveNodeItem(nodeId)
  end
end

function Season_shop_subView:OnRefresh()
end

function Season_shop_subView:initwidgets()
  self.pageItemParent_ = self.uiBinder.cont_info.layout
  self.pageToggleGroup_ = self.uiBinder.cont_info.togs_layout
  self.propLoopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.cont_info.loopscroll, shop_loop_item_, "season_shop_item_tpl")
  local dataList_ = {}
  self.propLoopScrollRect_:Init(dataList_)
  self.emptyGo_ = self.uiBinder.cont_info.cont_empty
  self.currency_root_ = self.uiBinder.Trans
  self.season_time_label_ = self.uiBinder.cont_info.lab_table_name
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
  self.shopData_ = self.vm.AsyncGetShopData(self.cancelSource, E.EShopType.SeasonShop)
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
  Z.VMMgr.GetVM("currency").OpenCurrencyView(self.currencyIds_, self.currency_root_, self)
  self:showProp(index)
  self:showSeasonTime()
end

function Season_shop_subView:showProp(index)
  local props = self.shopData_[index]
  self.propLoopScrollRect_:RefreshListView(props.items)
  self.emptyGo_.Ref.UIComp:SetVisible(#props.items <= 0)
end

function Season_shop_subView:showSeasonTime()
  local cfg = self.shopData_[self.curChoosePage].cfg
  local timerCfg = Z.TableMgr.GetTable("TimerTableMgr").GetRow(cfg.TimerId)
  if timerCfg then
    self.season_time_label_.text = timerCfg.starttime .. "-" .. timerCfg.endtime
  end
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
  self.vm.OpenBuyPopup(data, function(data_, num)
    self.vm.AsyncBuyShopItem(1, data_, num, function(req)
      if req.errorCode == 0 then
        self.vm.CloseBuyPopup()
        self:UpdateProp()
        local mallCfg = Z.TableMgr.GetTable("SeasonShopItemTableMgr").GetRow(req.itemId)
        if mallCfg then
          Z.CoroUtil.create_coro_xpcall(function()
            for id, num in pairs(mallCfg.Cost) do
              if num == 0 then
                Z.VMMgr.GetVM("shop").AsyncSetShopItemRed(req.itemId, E.EShopType.SeasonShop)
                break
              end
            end
          end)()
        end
        if mallCfg.DeliverWay and mallCfg.DeliverWay[1] and mallCfg.DeliverWay[1][1] == 1 then
          Z.TipsVM.ShowTipsLang(1000732)
        elseif mallCfg.DeliverWay and mallCfg.DeliverWay[1] and mallCfg.DeliverWay[1][1] == 0 then
          Z.TipsVM.ShowTipsLang(1000733)
        end
      end
    end, self.cancelSource, self.shopData_[self.curChoosePage].Id)
  end, self.currencyIds_)
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
