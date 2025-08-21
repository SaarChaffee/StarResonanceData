local UI = Z.UI
local super = require("ui.ui_subview_base")
local House_shop_sell_subView = class("House_shop_sell_subView", super)
local keyPad = require("ui.view.cont_num_keyboard_view")
local bgImgStr_ = "ui/atlas/season/seasonshop_item_quality_%d"

function House_shop_sell_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "house_shop_sell_sub", "house/house_shop_sell_sub", UI.ECacheLv.None)
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.currencyVm_ = Z.VMMgr.GetVM("currency")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.parentView = parent
  self.homeData_ = Z.DataMgr.Get("home_editor_data")
end

function House_shop_sell_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  local currencyIds = Z.SystemItem.HomeShopCurrencyDisplay
  self.parentView:RefreshCurrency(currencyIds)
  self:initwidgets()
  self:bindBtnClick()
  self.highUnitNames = {}
  self.unitTokenDict = {}
  self.normalUnitNames = {}
  self.lowUnitNames = {}
  self:refreshSellList()
  Z.EventMgr:Add(Z.ConstValue.House.HouseSellInfoChanged, self.onHouseSellInfoChanged, self)
  Z.EventMgr:Add(Z.ConstValue.Home.CommunityItemUpdate, self.onCommunityItemUpdateChanged, self)
end

function House_shop_sell_subView:initwidgets()
  self.keypadRootTrans_ = self.uiBinder.binder_num_module_tpl_lab.group_keypadroot
  self.buy_num_label_ = self.uiBinder.binder_num_module_tpl_lab.lab_num
  self.slider_ = self.uiBinder.binder_num_module_tpl_lab.slider_temp
  self.btn_add_ = self.uiBinder.binder_num_module_tpl_lab.btn_add
  self.btn_max_ = self.uiBinder.binder_num_module_tpl_lab.btn_max
  self.btn_reduce_ = self.uiBinder.binder_num_module_tpl_lab.btn_reduce
  self.lab_num_ = self.uiBinder.binder_num_module_tpl_lab.lab_num
  self.btn_num = self.uiBinder.binder_num_module_tpl_lab.btn_num
end

function House_shop_sell_subView:OnDeActive()
  self:ClearAllUnits()
  if self.keypad_ then
    self.keypad_:DeActive()
  end
  Z.EventMgr:Remove(Z.ConstValue.House.HouseSellInfoChanged, self.onHouseSellInfoChanged, self)
  Z.EventMgr:Remove(Z.ConstValue.Home.CommunityItemUpdate, self.onCommunityItemUpdateChanged, self)
  self.slider_:RemoveAllListeners()
end

function House_shop_sell_subView:onHouseSellInfoChanged()
  self:refreshSellList()
end

function House_shop_sell_subView:onCommunityItemUpdateChanged()
  self:refreshSellList()
end

function House_shop_sell_subView:OnRefresh()
end

function House_shop_sell_subView:bindBtnClick()
  self.keypad_ = keyPad.new(self)
  self:AddClick(self.btn_num, function()
    self.keypad_:Active({
      max = self.maxCanBuyCount_
    }, self.keypadRootTrans_)
  end)
  self:AddClick(self.btn_add_, function()
    self:add()
  end)
  self:AddClick(self.btn_max_, function()
    self:onMax()
  end)
  self:AddClick(self.btn_reduce_, function()
    self:reduce()
  end)
  if self.slider_ then
    self.slider_.value = 1
    self.slider_:AddListener(function()
      self.curNum_ = self.slider_.value
      self:updateNumData()
    end)
  end
  self:AddPressListener(self.btn_add_, function()
    self:add()
  end)
  self:AddPressListener(self.btn_reduce_, function()
    self:reduce()
  end)
  self:AddAsyncClick(self.uiBinder.btn_sell, function()
    if self.curNum_ == 0 then
      return
    end
    self.houseVm_.AsyncSellItem(self.curSellData_, self.curNum_, self.cancelSource:CreateToken())
  end)
end

function House_shop_sell_subView:AddPressListener(btn, func)
  btn:AddPressListener(func)
end

function House_shop_sell_subView:add()
  self:InputNum(self.curNum_ + 1)
end

function House_shop_sell_subView:reduce()
  self:InputNum(self.curNum_ - 1, nil, true)
end

function House_shop_sell_subView:onMax()
  self:InputNum(self.max_)
end

function House_shop_sell_subView:InputNum(num)
  self.curNum_ = num
  if num < self.min_ then
    self.curNum_ = self.min_
  end
  if num < 1 then
    self.curNum_ = 1
  end
  if num > self.max_ then
    self.curNum_ = self.max_
  end
  self:updateNumData()
end

function House_shop_sell_subView:refreshSellList()
  local sellItemTable = self.houseData_:GetHouseSellDataMap()
  self.uiBinder.Ref:SetVisible(self.uiBinder.high_price_sell.Trans, #sellItemTable.highList > 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.normal_price_sell.Trans, 0 < #sellItemTable.normalList)
  self.uiBinder.Ref:SetVisible(self.uiBinder.low_price_sell.Trans, 0 < #sellItemTable.lowList)
  local isEmpty = #sellItemTable.highList <= 0 and 0 >= #sellItemTable.normalList and 0 >= #sellItemTable.lowList
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, not isEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.com_empty_new, isEmpty)
  self:refreshSellItems(self.uiBinder.high_price_sell, sellItemTable.highList, "high", self.highUnitNames)
  self:refreshSellItems(self.uiBinder.normal_price_sell, sellItemTable.normalList, "normal", self.normalUnitNames)
  self:refreshSellItems(self.uiBinder.low_price_sell, sellItemTable.lowList, "low", self.lowUnitNames)
end

function House_shop_sell_subView:refreshSellItems(binder, itemList, discountLevel, nameList)
  table.sort(itemList, function(a, b)
    local aItemId = a.itemId
    local bItemId = b.itemId
    local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
    local aItemConfig = itemsTableMgr.GetRow(aItemId)
    local bItemConfig = itemsTableMgr.GetRow(bItemId)
    if aItemConfig.Quality == bItemConfig.Quality then
      if aItemConfig.SortID == bItemConfig.SortID then
        return aItemConfig.Id < bItemConfig.Id
      else
        return aItemConfig.SortID < bItemConfig.SortID
      end
    else
      return aItemConfig.Quality > bItemConfig.Quality
    end
  end)
  local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "house_shop_item_tpl")
  Z.CoroUtil.create_coro_xpcall(function()
    binder.lab_title.text = Lang("sell_price_" .. discountLevel)
    for k, v in ipairs(itemList) do
      local unitName = discountLevel .. v.itemId
      local uiUnit
      if nameList[k] == unitName then
        uiUnit = self.units[unitName]
      else
        if self.unitTokenDict[nameList[k]] ~= nil then
          Z.CancelSource.ReleaseToken(self.unitTokenDict[nameList[k]])
        end
        self:RemoveUiUnit(nameList[k])
        local unitToken = self.cancelSource:CreateToken()
        self.unitTokenDict[unitName] = unitToken
        uiUnit = self:AsyncLoadUiUnit(path, unitName, binder.node_layout, unitToken)
      end
      if uiUnit == nil then
        return
      end
      nameList[k] = unitName
      uiUnit.unitName = unitName
      self:refreshShopItem(uiUnit, v)
      if not self.firstUnit then
        self.firstUnit = uiUnit
        self.firstData = v
      end
      if self.curSeletUintName and self.curSeletUintName == unitName then
        self:SetSelected(uiUnit, v)
      end
    end
    if self.curSeletUintName == nil and self.firstUnit then
      self:SetSelected(self.firstUnit, self.firstData)
    end
  end)()
end

function House_shop_sell_subView:refreshShopItem(uiUnit, data)
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.itemId)
  if itemCfg then
    uiUnit.lab_item_name.text = itemCfg.Name
    uiUnit.rimg_item_icon:SetImage(self.itemsVm_.GetItemIcon(data.itemId))
    uiUnit.img_quality_bg:SetImage(string.format(bgImgStr_, itemCfg.Quality))
  end
  local homeLandSellTableRow = Z.TableMgr.GetTable("HomeLandSellTableMgr").GetRow(data.key)
  if not homeLandSellTableRow then
    return
  end
  local remainTime = -1
  if data.IsHigh then
    remainTime = homeLandSellTableRow.MaxNumber - data.collectedNum
  end
  uiUnit.lab_num.text = remainTime == -1 and Lang("HomeSellNoLimit") or Lang("HomeSellRemainTimes", {val = remainTime})
  local haveCount = 0
  if self.homeData_:GetItemIsHouseWarehouseItem(data.itemId) then
    haveCount = self.homeData_:GetSelfFurnitureWarehouseItemCount(data.itemId)
  else
    haveCount = self.itemsVm_.GetItemTotalCount(data.itemId)
  end
  uiUnit.lab_cur_have.text = Lang("Already:") .. haveCount
  uiUnit.rimg_price_icon:SetImage(self.itemsVm_.GetItemIcon(homeLandSellTableRow.Currency))
  uiUnit.lab_price_num.text = Z.NumTools.FormatNumberWithCommas(data.collectPrice)
  uiUnit.Ref:SetVisible(uiUnit.img_select, false)
  uiUnit.btn_quality_bg:AddListener(function()
    self:SetSelected(uiUnit, data)
    self.curSeletUintName = uiUnit.unitName
  end)
end

function House_shop_sell_subView:SetSelected(uiUnit, data)
  self.curSellData_ = data
  for k, v in pairs(self.units) do
    v.Ref:SetVisible(v.img_select, v == uiUnit)
  end
  self:showItem()
  self.canSellCount = self:getCanSellCount()
  self.minSellCount = self.canSellCount > 0 and 1 or 0
  self:reSetValue(self.minSellCount, self.canSellCount)
end

function House_shop_sell_subView:reSetValue(min, max)
  self.max_ = max
  self.min_ = min
  self.curNum_ = min
  if self.curNum_ > self.max_ then
    self.curNum_ = self.max_
  end
  if self.curNum_ < self.min_ then
    self.curNum_ = self.min_
  end
  self.hide_ = self.min_ == self.max_ and self.max_ == 0
  self.btn_add_.IsDisabled = self.hide_
  self.btn_max_.IsDisabled = self.hide_
  self.btn_reduce_.IsDisabled = self.hide_
  self.btn_add_.interactable = not self.hide_
  self.btn_max_.interactable = not self.hide_
  self.btn_reduce_.interactable = not self.hide_
  self.slider_.enabled = not self.hide_
  self.uiBinder.btn_sell.IsDisabled = self.hide_
  if self.hide_ then
    self.min_ = 0
    self.curNum_ = 0
  end
  self.slider_.minValue = self.min_
  self.slider_.maxValue = self.max_
  self:updateNumData()
end

function House_shop_sell_subView:updateNumData()
  local numStr = string.format("%d", self.curNum_)
  self.buy_num_label_.text = numStr
  self.slider_:SetValueWithoutNotify(self.curNum_)
  self:updateNum(self.curNum_)
end

function House_shop_sell_subView:updateNum(num)
  self.allPrice_ = math.floor(num * self.curSellData_.collectPrice)
  local price = Z.NumTools.FormatNumberWithCommas(self.allPrice_)
  local str = Z.RichTextHelper.ApplyStyleTag(price, E.TextStyleTag.Lab_num_black)
  self.uiBinder.lab_price_num.text = str
  self.curNum_ = num
end

function House_shop_sell_subView:getCanSellCount()
  local homeLandSellTableRow = Z.TableMgr.GetTable("HomeLandSellTableMgr").GetRow(self.curSellData_.key)
  if not homeLandSellTableRow then
    return 0
  end
  local remainTime = -1
  if self.curSellData_.IsHigh then
    remainTime = homeLandSellTableRow.MaxNumber - self.curSellData_.collectedNum
  end
  local haveCount = 0
  if self.homeData_:GetItemIsHouseWarehouseItem(self.curSellData_.itemId) then
    haveCount = self.homeData_:GetSelfFurnitureWarehouseItemCount(self.curSellData_.itemId)
  else
    haveCount = self.itemsVm_.GetItemTotalCount(self.curSellData_.itemId)
  end
  if remainTime == -1 then
    return haveCount
  end
  return math.min(remainTime, haveCount)
end

function House_shop_sell_subView:showItem()
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.curSellData_.itemId)
  if not itemCfg then
    return
  end
  self.uiBinder.lab_name.text = itemCfg.Name
  self.uiBinder.rimg_icon:SetImage(self.itemsVm_.GetItemIcon(self.curSellData_.itemId))
  local homeLandSellTableRow = Z.TableMgr.GetTable("HomeLandSellTableMgr").GetRow(self.curSellData_.key)
  if not homeLandSellTableRow then
    return
  end
  local remainTime = -1
  if self.curSellData_.IsHigh then
    remainTime = homeLandSellTableRow.MaxNumber - self.curSellData_.collectedNum
  end
  self.uiBinder.lab_num.text = remainTime == -1 and Lang("HomeSellNoLimit") or Lang("HomeSellRemainTimes", {val = remainTime})
  local haveCount = 0
  if self.homeData_:GetItemIsHouseWarehouseItem(self.curSellData_.itemId) then
    haveCount = self.homeData_:GetSelfFurnitureWarehouseItemCount(self.curSellData_.itemId)
  else
    haveCount = self.itemsVm_.GetItemTotalCount(self.curSellData_.itemId)
  end
  self.uiBinder.lab_current_num.text = string.format(Lang("SeasonShopOwn"), haveCount)
  self.uiBinder.rimg_price_icon:SetImage(homeLandSellTableRow.Currency)
end

return House_shop_sell_subView
