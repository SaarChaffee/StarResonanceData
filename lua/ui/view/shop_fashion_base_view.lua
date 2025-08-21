local UI = Z.UI
local super = require("ui.ui_subview_base")
local ShopFashionBaseView = class("ShopFashionBaseView", super)
local loopGridView = require("ui.component.loop_grid_view")
local shop_loop_item = require("ui.component.season.season_shop_loop_item")
local shop_wear_item = require("ui.component.season.season_shop_wear_item")
local shop_detail_item = require("ui.component.season.season_shop_detail_item")
local loopListView = require("ui.component.loop_list_view")
local tog3_Item = require("ui.component.shop.shop_tog3_loop_item")

function ShopFashionBaseView:subCtor(viewConfigKey, assetPath, cacheLv, isHavePCUI)
  self.uiBinder = nil
  self.viewData = nil
  super.ctor(self, viewConfigKey, assetPath, cacheLv, isHavePCUI)
end

function ShopFashionBaseView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initVMData()
  self:initFunc()
  self:initShopDetailWearList()
  self:refreshNodeVodieState()
  self:refreshSelectItemName()
  self:refreshDetailList()
  self:refreshWearList()
  self:refreshCouponsState()
  self:refreshShopBuyBtnState()
  self:refreshCondition()
  self:bindEvent()
  self:onStartAnimShow()
  Z.UnrealSceneMgr:SetCacheTextureName("sky", 0, "_MainTex", Z.ConstValue.UnrealSceneBgPath.ShopDefaultBg)
end

function ShopFashionBaseView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.detailsGridView_:UnInit()
  self.wearGridView_:UnInit()
  self:unBindEvent()
  self.vehicleBaseTableMap_ = nil
  Z.UnrealSceneMgr:TryResetTexture()
end

function ShopFashionBaseView:initVMData()
  self.IsFashionShop = true
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.shopVM_ = Z.VMMgr.GetVM("shop")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.itemVM_ = Z.VMMgr.GetVM("items")
  self.shopData_ = Z.DataMgr.Get("shop_data")
  self.curMallTableRow_ = self.viewData.mallTableRow
  self.curSelectData_ = nil
  self.curMallItemRow_ = nil
  self.curItemState_ = 0
end

function ShopFashionBaseView:initFunc()
  self:AddClick(self.uiBinder.btn_reset, function()
    self:onClickReset()
  end)
  self:AddClick(self.uiBinder.btn_fashion, function()
    self:onClickFashion()
  end)
  self:AddClick(self.uiBinder.node_buy.btn_coupons, function()
    if not self.curSelectData_ then
      return
    end
    Z.UIMgr:OpenView("shop_coupon_popup", {
      MailItemId = self.curSelectData_.mallItemRow.Id,
      data = self.curSelectData_.data
    })
  end)
  self:AddClick(self.uiBinder.node_buy.btn_buy_one, function()
    if self:checkShopExchangeTips() then
      return
    end
    self.shopVM_.OpenShopBuyPopup({
      shopType = E.EShopType.Shop
    })
  end)
  self:AddClick(self.uiBinder.node_buy.btn_buy_two, function()
    if self:checkShopExchangeTips() then
      return
    end
    self.shopVM_.OpenShopBuyPopup({
      shopType = E.EShopType.Shop
    })
  end)
  self:AddClick(self.uiBinder.node_list.btn_detail, function()
    self.shopData_.ShopIsShowDetail = not self.shopData_.ShopIsShowDetail
    self:refreshDetailList()
  end)
  self:AddClick(self.uiBinder.node_list.btn_wear, function()
    self.shopData_.ShopIsShowWear = not self.shopData_.ShopIsShowWear
    self:refreshWearList()
  end)
end

function ShopFashionBaseView:initShopDetailWearList()
  self.detailsGridView_ = loopGridView.new(self, self.uiBinder.node_list.loop_detail, shop_detail_item, "com_item_detail")
  self.detailsGridView_:Init({})
  self.wearGridView_ = loopGridView.new(self, self.uiBinder.node_list.loop_wear, shop_wear_item, "com_item_wear")
  self.wearGridView_:Init({})
end

function ShopFashionBaseView:refreshNodeVodieState(data)
  if not data then
    if self.uiBinder.btn_video then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_video, false)
    end
    self.viewData.parentView:HideVideo()
    return
  end
  local mallItemRow = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(data.itemId, true)
  if not mallItemRow then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_video, false)
    self.viewData.parentView:HideVideo()
    return
  end
  if mallItemRow.GoodsVideo ~= "" then
    self.viewData.parentView:ShowVideo(mallItemRow.GoodsVideo)
    if self.uiBinder.btn_video then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_video, true)
    end
  else
    self.viewData.parentView:HideVideo()
    if self.uiBinder.btn_video then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_video, false)
    end
  end
  self.viewData.parentView:RefreshPlayerModelAction(mallItemRow.ItemId)
end

function ShopFashionBaseView:refreshSelectItemName(data)
  if not data then
    self.uiBinder.lab_name.text = Lang("FashionGiftName")
    return
  end
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.cfg.ItemId)
  if not itemCfg then
    return
  end
  if data.cfg.Quantity > 1 then
    local param = {}
    param.val = data.cfg.Quantity
    self.uiBinder.lab_name.text = string.zconcat(itemCfg.Name, " ", Lang("x", param))
  else
    self.uiBinder.lab_name.text = itemCfg.Name
  end
end

function ShopFashionBaseView:refreshDetailList()
  local detailList = {}
  if self.curMallItemRow_ then
    local list = self.curMallItemRow_.FashionList
    if list and table.zcount(list) > 0 then
      local tagDict = {}
      local SubItemLabel = self.curMallItemRow_.SubItemLabel
      if SubItemLabel and table.zcount(SubItemLabel) > 0 then
        for i = 1, #SubItemLabel do
          local itemId = tonumber(SubItemLabel[i][1])
          local tagType = tonumber(SubItemLabel[i][2])
          local tagParame = SubItemLabel[i][3]
          tagDict[itemId] = {type = tagType, param = tagParame}
        end
      end
      local awardList = self:GetPreviewAwardList(self.curMallItemRow_.ItemId)
      if awardList then
        for i = 1, #awardList do
          detailList[i] = awardList[i]
          detailList[i].tagData = tagDict[awardList[i].awardId]
        end
      end
    else
      detailList = {
        [1] = {
          awardId = self.curMallItemRow_.ItemId
        }
      }
    end
  end
  if self.shopData_.ShopIsShowDetail and 0 < #detailList then
    self.uiBinder.node_list.Ref:SetVisible(self.uiBinder.node_list.loop_detail, true)
    self.detailsGridView_:RefreshListView(detailList, false)
  else
    self.uiBinder.node_list.Ref:SetVisible(self.uiBinder.node_list.loop_detail, false)
  end
  self.uiBinder.node_list.Ref:SetVisible(self.uiBinder.node_list.img_detail_down, self.shopData_.ShopIsShowDetail)
  self.uiBinder.node_list.Ref:SetVisible(self.uiBinder.node_list.img_detail_up, not self.shopData_.ShopIsShowDetail)
end

function ShopFashionBaseView:refreshWearList()
  local wearList = {}
  for _, mallData in pairs(self.shopData_.ShopBuyItemInfoList) do
    for _, shopItemSelectData in pairs(mallData) do
      wearList[#wearList + 1] = shopItemSelectData
    end
  end
  if self.shopData_.ShopIsShowWear and 0 < #wearList then
    self.uiBinder.node_list.Ref:SetVisible(self.uiBinder.node_list.loop_wear, true)
    self.wearGridView_:RefreshListView(wearList, false)
  else
    self.uiBinder.node_list.Ref:SetVisible(self.uiBinder.node_list.loop_wear, false)
  end
  self.uiBinder.node_list.lab_wear.text = Lang("FashionWearList", {
    val = #wearList
  })
  self.uiBinder.node_list.Ref:SetVisible(self.uiBinder.node_list.img_wear_down, self.shopData_.ShopIsShowWear)
  self.uiBinder.node_list.Ref:SetVisible(self.uiBinder.node_list.img_wear_up, not self.shopData_.ShopIsShowWear)
end

function ShopFashionBaseView:refreshCouponsState()
  local node_buy = self.uiBinder.node_buy
  node_buy.Ref:SetVisible(node_buy.btn_coupons, false)
end

function ShopFashionBaseView:refreshShopBuyBtnState()
  local node_buy = self.uiBinder.node_buy
  node_buy.Ref:SetVisible(node_buy.btn_buy_one, false)
  node_buy.Ref:SetVisible(node_buy.btn_buy_two, false)
  node_buy.Ref:SetVisible(node_buy.node_disable_buy, false)
  if self.curItemState_ ~= 0 then
    return
  end
  local shopCostList = self.shopData_.ShopCostList
  local costCount = 0
  for i = 1, #shopCostList do
    if 0 < shopCostList[i].costId then
      costCount = costCount + 1
    end
  end
  if costCount == 1 then
    node_buy.Ref:SetVisible(node_buy.btn_buy_one, true)
    self:refreshBuyOneState()
  elseif costCount == 2 then
    node_buy.Ref:SetVisible(node_buy.btn_buy_two, true)
    self:refreshBuyTwoState()
  else
    node_buy.Ref:SetVisible(node_buy.node_disable_buy, true)
  end
end

function ShopFashionBaseView:refreshBuyOneState()
  local costData = self.shopData_.ShopCostList
  for i = 1, #costData do
    if costData[i].costValue >= 0 then
      self:refreshCostIconValue(self.uiBinder.node_buy, self.uiBinder.node_buy.btn_buy_one, self.uiBinder.node_buy.rimg_gold_one, costData[i].costId, self.uiBinder.node_buy.lab_gold_one, costData[i].costValue, self.uiBinder.node_buy.lab_old_gold_one, costData[i].originalValue)
      break
    end
  end
end

function ShopFashionBaseView:refreshBuyTwoState()
  local costData = self.shopData_.ShopCostList
  self:refreshCostIconValue(self.uiBinder.node_buy, self.uiBinder.node_buy.node_gold1, self.uiBinder.node_buy.rimg_gold1, costData[1].costId, self.uiBinder.node_buy.lab_gold1, costData[1].costValue, self.uiBinder.node_buy.lab_old_gold1, costData[1].originalValue)
  self:refreshCostIconValue(self.uiBinder.node_buy, self.uiBinder.node_buy.node_gold2, self.uiBinder.node_buy.rimg_gold2, costData[2].costId, self.uiBinder.node_buy.lab_gold2, costData[2].costValue, self.uiBinder.node_buy.lab_old_gold2, costData[2].originalValue)
end

function ShopFashionBaseView:refreshCostIconValue(parentNode, nodeCost, imgIcon, costId, labCost, costValue, labOriginal, originalValue)
  if costValue < 0 or originalValue < 0 or costValue == 0 and originalValue == 0 then
    parentNode.Ref:SetVisible(nodeCost, false)
    return
  end
  parentNode.Ref:SetVisible(nodeCost, true)
  self:setCostIcon(imgIcon, costId)
  local have = self.itemVM_.GetItemTotalCount(costId)
  if costValue > have then
    labCost.text = Z.RichTextHelper.ApplyStyleTag(costValue, E.TextStyleTag.FashionCostRedTips)
  else
    labCost.text = costValue
  end
  if originalValue <= 0 then
    parentNode.Ref:SetVisible(labOriginal, false)
    return
  end
  parentNode.Ref:SetVisible(labOriginal, false)
  labOriginal.text = originalValue
end

function ShopFashionBaseView:setCostIcon(costIcon, id)
  local itemcfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id, true)
  if not itemcfg then
    return
  end
  costIcon:SetImage(self.itemVM_.GetItemIcon(id))
end

function ShopFashionBaseView:refreshCondition(itemId, buyCount)
  self.uiBinder.node_buy.lab_prompt.text = ""
  local mallItemRow
  if itemId then
    mallItemRow = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(itemId, true)
  elseif self.curMallItemRow_ then
    mallItemRow = self.curMallItemRow_
  end
  if not mallItemRow then
    return
  end
  local showCondition = false
  if table.zcount(mallItemRow.UnlockConditions) > 0 then
    local descList = Z.ConditionHelper.GetConditionDescList(mallItemRow.UnlockConditions)
    for _, value in ipairs(descList) do
      if value.IsUnlock == false then
        if value.showLock then
          self.uiBinder.node_buy.lab_prompt.text = value.showPurview
        else
          self.uiBinder.node_buy.lab_prompt.text = value.Desc
        end
        showCondition = true
        break
      end
    end
  end
  if not showCondition and buyCount then
    for id, countData in pairs(buyCount) do
      if id ~= E.ESeasonShopRefreshType.None and countData.canBuyCount == 0 then
        self.uiBinder.node_buy.lab_prompt.text = Lang("ShopLimitHasBeenReached")
        break
      end
    end
  end
end

function ShopFashionBaseView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Shop.FashionSelectItemDataChange, self.RefreshViewData, self)
  Z.EventMgr:Add(Z.ConstValue.FashionShopChangeCoupon, self.RefreshViewData, self)
end

function ShopFashionBaseView:unBindEvent()
  Z.EventMgr:Remove(Z.ConstValue.Shop.FashionSelectItemDataChange, self.RefreshViewData, self)
  Z.EventMgr:Remove(Z.ConstValue.FashionShopChangeCoupon, self.RefreshViewData, self)
end

function ShopFashionBaseView:InitThreeList()
  local curMallRow = self.viewData.mallTableRow
  if not curMallRow then
    return
  end
  local threeList = self.viewData.threeTabList[curMallRow.Id]
  if not threeList then
    return
  end
  local wearData = self.shopData_.ShopBuyItemInfoList[curMallRow.Id]
  self.showThreeList_ = {}
  for i = 1, #threeList do
    if wearData and wearData[threeList[i].Id] then
      self.showThreeList_[#self.showThreeList_ + 1] = {
        mallPagetabTableRow = threeList[i],
        shopItem = wearData[threeList[i].Id].data,
        mallTableRow = curMallRow
      }
    elseif self:GetShopIsHaveItem(curMallRow.Id, threeList[i]) then
      self.showThreeList_[#self.showThreeList_ + 1] = {
        mallPagetabTableRow = threeList[i],
        mallTableRow = curMallRow
      }
    end
  end
  self.threeListView_ = loopListView.new(self, self.uiBinder.loop_three, tog3_Item, "shop_fashion_tog_three_small_tpl")
  self.threeListView_:Init({})
  self.threeListView_:RefreshListView(self.showThreeList_, false)
  self.threeListView_:ClearAllSelect()
  if self.viewData.configId then
    local index = 1
    for i = 1, #self.showThreeList_ do
      local dataList = self:GetShopItemList(self.curMallTableRow_.Id, self.showThreeList_[i].mallPagetabTableRow)
      for j = 1, #dataList do
        if dataList[j].cfg and dataList[j].cfg.ItemId == self.viewData.configId then
          index = i
          break
        end
      end
    end
    self.threeListView_:MovePanelToItemIndex(index)
    self.threeListView_:SetSelected(index)
  elseif self.viewData.threeIndex then
    self.threeListView_:MovePanelToItemIndex(self.viewData.threeIndex)
    self.threeListView_:SetSelected(self.viewData.threeIndex)
  else
    self.threeListView_:SetSelected(1)
  end
end

function ShopFashionBaseView:RefreshThreeList()
  if not self.threeListView_ then
    return
  end
  local wearData = self.shopData_.ShopBuyItemInfoList[self.curMallTableRow_.Id]
  for i = 1, #self.showThreeList_ do
    self.showThreeList_[i].shopItem = nil
    if wearData then
      local data = wearData[self.showThreeList_[i].mallPagetabTableRow.Id]
      if data then
        self.showThreeList_[i].shopItem = data.data
      end
    end
  end
  self.threeListView_:RefreshListView(self.showThreeList_, false)
end

function ShopFashionBaseView:ClearThreeList()
  if not self.threeListView_ then
    return
  end
  self.threeListView_:UnInit()
end

function ShopFashionBaseView:InitShopList()
  self.shopGridView_ = loopGridView.new(self, self.uiBinder.loop_shop, shop_loop_item, "shop_item_8_tpl", true)
  self.shopGridView_:Init({})
end

function ShopFashionBaseView:ClearShopList()
  self.shopGridView_:UnInit()
end

function ShopFashionBaseView:RefreshPlayerWear(shopBuyList, shopWear)
  self.fashionVM_.RevertAllFashionWear()
  shopBuyList = shopBuyList or self.shopData_.ShopBuyItemInfoList
  shopWear = shopWear or self.shopData_.ShopWearDict
  if not shopBuyList then
    return
  end
  local curWear = self.fashionData_:GetWears()
  local removeWear = {}
  for region, data in pairs(curWear) do
    if shopWear[region] and shopWear[region].showWearData then
      removeWear[#removeWear + 1] = region
    else
      local _, hideRegionList = self:getItemRegionList(data.wearFashionId)
      if hideRegionList then
        for i = 1, #hideRegionList do
          if shopWear[hideRegionList[i]] and shopWear[hideRegionList[i]].showWearData then
            removeWear[#removeWear + 1] = region
            break
          end
        end
      end
    end
  end
  for i = 1, #removeWear do
    self.fashionData_:SetWear(removeWear[i], nil)
  end
  for _, mallData in pairs(shopBuyList) do
    for _, wearData in pairs(mallData) do
      self:refreshWearByFunctionId(wearData)
    end
  end
end

function ShopFashionBaseView:refreshWearByFunctionId(data)
  if not data or not data.mallItemRow then
    return
  end
  if not self.shopVM_.CheckUnlockCondition(data.mallItemRow.ShowLimitType) then
    return
  end
  if data.mallItemRow.GoodsType == E.EShopGoodsType.EFashion then
    if not data.mallItemRow.GoodsGroup or #data.mallItemRow.GoodsGroup == 0 then
      if data.mallItemRow.FashionList and 0 < table.zcount(data.mallItemRow.FashionList) then
        for i = 1, #data.mallItemRow.FashionList do
          if self.fashionVM_.CheckIsFashion(data.mallItemRow.FashionList[i]) then
            self.fashionVM_.SetFashionWearByFashionId(data.mallItemRow.FashionList[i])
          end
        end
      elseif self.fashionVM_.CheckIsFashion(data.mallItemRow.ItemId) then
        self.fashionVM_.SetFashionWearByFashionId(data.mallItemRow.ItemId)
      end
    else
      for i = 1, #data.mallItemRow.GoodsGroup do
        local row = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(data.mallItemRow.GoodsGroup[i], true)
        self:setFashionWearByMallItemRow(row)
      end
    end
  elseif data.mallItemRow.GoodsType == E.EShopGoodsType.ENormal then
    local fashionAdvanceData = self:getFashionAdvanceIdByFashionUnlockItemId(data.mallItemRow)
    if table.zcount(fashionAdvanceData) == 0 then
      return
    end
    for _, data in pairs(fashionAdvanceData) do
      self.fashionVM_.SetFashionWearByFashionId(data.fashionAdvanceId, data.fashionId)
    end
  end
end

function ShopFashionBaseView:setFashionWearByMallItemRow(row)
  if not row then
    return
  end
  if not self.shopVM_.CheckUnlockCondition(row.ShowLimitType) then
    return
  end
  if not self.fashionVM_.CheckIsFashion(row.ItemId) then
    return
  end
  self.fashionVM_.SetFashionWearByFashionId(row.ItemId)
end

function ShopFashionBaseView:checkMallItemVaild(mallPagetabTableRow, mallItemCfgData, itemTableRow, shopItem)
  if not (mallItemCfgData and mallPagetabTableRow) or table.zcount(mallPagetabTableRow.ShopItemType) == 0 then
    return true
  end
  local shopItemType = mallPagetabTableRow.ShopItemType[1]
  local shopItemParam = mallPagetabTableRow.ShopItemType[2]
  if shopItemType == E.EShopItemType.ItemType then
    if itemTableRow and itemTableRow.Type == shopItemParam then
      return true
    end
  elseif shopItemType == E.EShopItemType.WeaponProfession then
    if mallItemCfgData.GoodsType ~= E.EShopGoodsType.EWeapon then
      return false
    end
    if mallItemCfgData.FashionList and 0 < table.zcount(mallItemCfgData.FashionList) then
      for i = 1, #mallItemCfgData.FashionList do
        if self:isVaildWeapon(mallItemCfgData.FashionList[i], shopItemParam) then
          shopItem.weaponSkinId = mallItemCfgData.FashionList[i]
          return true
        end
      end
    else
      shopItem.weaponSkinId = mallItemCfgData.ItemId
      return self:isVaildWeapon(mallItemCfgData.ItemId, shopItemParam)
    end
  end
  return false
end

function ShopFashionBaseView:GetPreviewAwardList(itemId)
  local row = Z.TableMgr.GetTable("ItemFunctionTableMgr").GetRow(itemId, true)
  if not row then
    return
  end
  local awardList = self.awardPreviewVM_.GetAllAwardPreListByIds(tonumber(row.Parameter[1]))
  if not awardList or table.zcount(awardList) == 0 then
    return
  end
  return awardList
end

function ShopFashionBaseView:isVaildWeapon(itemId, needWeapon)
  local row = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetRow(itemId, true)
  if row and row.ProfessionId == needWeapon then
    return true
  end
  return false
end

local sortFunc = function(left, right)
  local leftCanBuyCount = 0
  local rightCanBuyCount = 0
  for id, data in pairs(left.buyCount) do
    if id ~= E.ESeasonShopRefreshType.None then
      leftCanBuyCount = data.canBuyCount
    end
  end
  for id, data in pairs(right.buyCount) do
    if id ~= E.ESeasonShopRefreshType.None then
      rightCanBuyCount = data.canBuyCount
    end
  end
  if left.IsFashoin and left.IsFashoinUnlock then
    leftCanBuyCount = 0
  end
  if right.IsFashoin and right.IsFashoinUnlock then
    rightCanBuyCount = 0
  end
  if left.cfg.GoodsType == E.EShopGoodsType.EMount and 0 < left.ItemTotalCount then
    leftCanBuyCount = 0
  end
  if right.cfg.GoodsType == E.EShopGoodsType.EMount and 0 < right.ItemTotalCount then
    rightCanBuyCount = 0
  end
  if 0 < leftCanBuyCount then
    if 0 < rightCanBuyCount then
      return left.cfg.Sort < right.cfg.Sort
    else
      return true
    end
  elseif 0 < rightCanBuyCount then
    return false
  else
    return left.cfg.Sort < right.cfg.Sort
  end
end

function ShopFashionBaseView:GetShopItemList(mallId, mallPagetabTableRow)
  if not self.viewData.shopData then
    return {}
  end
  local items
  for _, value in pairs(self.viewData.shopData) do
    if value.Id == mallId then
      items = value.items
      break
    end
  end
  if not items then
    return {}
  end
  local fashionVM = Z.VMMgr.GetVM("fashion")
  local itemsVM = Z.VMMgr.GetVM("items")
  local showItems = {}
  for i = 1, #items do
    local mallItemCfgData = items[i].cfg
    if mallItemCfgData then
      local itemCfgData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(mallItemCfgData.ItemId, true)
      if itemCfgData and self:checkMallItemVaild(mallPagetabTableRow, mallItemCfgData, itemCfgData, items[i]) then
        items[i].IsFashoin = fashionVM.CheckIsFashion(mallItemCfgData.ItemId)
        items[i].IsFashoinUnlock = fashionVM.GetFashionIsUnlock(mallItemCfgData.ItemId)
        items[i].ItemTotalCount = itemsVM.GetItemTotalCount(mallItemCfgData.ItemId)
        items[i].MallItemCfgData = mallItemCfgData
        showItems[#showItems + 1] = items[i]
      end
    end
  end
  table.sort(showItems, sortFunc)
  return showItems
end

function ShopFashionBaseView:GetShopIsHaveItem(mallId, mallPagetabTableRow)
  if not self.viewData.shopData then
    return false
  end
  local items
  for _, value in pairs(self.viewData.shopData) do
    if value.Id == mallId then
      items = value.items
      break
    end
  end
  if not items then
    return false
  end
  for i = 1, #items do
    local mallItemCfgData = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(items[i].itemId, true)
    if mallItemCfgData then
      local itemCfgData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(mallItemCfgData.ItemId, true)
      if itemCfgData and self:checkMallItemVaild(mallPagetabTableRow, mallItemCfgData, itemCfgData, items[i]) then
        return true
      end
    end
  end
  return false
end

function ShopFashionBaseView:Tog3Click(data, index, isClick)
  self.curMallPagetabTableRow_ = data.mallPagetabTableRow
  self:clearSelectData()
  self:RefreshData()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
  if isClick then
    self.viewData.parentView.viewData.parentView:SetThreeIndex(index)
  end
end

function ShopFashionBaseView:RefreshData(data)
  local isMoveItemIndex = true
  if data then
    self.viewData.shopData = data
    isMoveItemIndex = false
  end
  local dataList = self:GetShopItemList(self.curMallTableRow_.Id, self.curMallPagetabTableRow_)
  self.shopGridView_:RefreshListView(dataList, false)
  self.shopGridView_:ClearAllSelect()
  if self.viewData.configId then
    local index = 1
    for i = 1, #dataList do
      if dataList[i].cfg and dataList[i].cfg.ItemId == self.viewData.configId then
        index = i
        break
      end
    end
    if isMoveItemIndex then
      self.shopGridView_:MovePanelToItemIndex(index)
      self.shopGridView_:SetSelected(index)
    end
    self.viewData.configId = nil
  elseif self.viewData.shopItemIndex then
    local index = self.viewData.shopItemIndex
    self:clearShopItemIndex()
    if isMoveItemIndex then
      self.shopGridView_:MovePanelToItemIndex(index)
      self.shopGridView_:SetSelected(index)
    end
  end
  self:refreshShopBuyBtnState()
end

function ShopFashionBaseView:ClearSelectItemList()
  self.shopData_:ClearShopBuyItemInfoList()
  self:clearSelectData()
  self:RefreshViewData()
end

function ShopFashionBaseView:clearSelectData(data, ignoreDetailRefresh)
  self.curSelectData_ = nil
  if not ignoreDetailRefresh then
    self.curMallItemRow_ = nil
    self.curItemState_ = 0
    self:refreshSelectItemName()
    self:refreshDetailList()
  end
  local itemId, buyCount
  if data then
    itemId = data.itemId
    buyCount = data.buyCount
  end
  self:refreshCondition(itemId, buyCount)
  self:refreshShopBuyBtnState()
  self:refreshNodeVodieState(data)
end

function ShopFashionBaseView:checkShopExchangeTips()
  if #self.shopData_.ShopCostList == 0 then
    return
  end
  for i = 1, #self.shopData_.ShopCostList do
    if self.shopVM_.CheckItemExchangeCount(self.shopData_.ShopCostList[i].costId, self.shopData_.ShopCostList[i].costValue, self.cancelSource:CreateToken()) then
      return true
    end
  end
  return false
end

function ShopFashionBaseView:SetSelected(data, Index)
  self.shopGridView_:SetSelected(Index)
end

function ShopFashionBaseView:RefreshViewData(removeData)
  self:refreshShopListSelect(removeData)
  self:refreshWearList()
  self:refreshCouponsState()
  self:refreshShopBuyBtnState()
  self:refreshCondition()
  self:RefreshThreeList()
  self:RefreshPlayerWear()
end

function ShopFashionBaseView:refreshShopListSelect(removeData)
  if not removeData or not self.curSelectData_ then
    return
  end
  if self.curSelectData_.data.itemId ~= removeData.data.itemId then
    return
  end
  self:clearSelectData()
  self:refreshSelectItemName()
  self.shopGridView_:ClearAllSelect()
  self:refreshCouponsState()
end

function ShopFashionBaseView:OpenBuyPopup(data, index, state)
  self:refreshSelectItemName(data)
  self:onSelectDisableShopItem(data, state)
  self.viewData.parentView.viewData.parentView:SetShopItemIndex(index)
  self.curItemState_ = state
  if state ~= 0 then
    self:clearSelectData(data, true)
    return
  end
  self:refreshNodeVodieState(data)
  self:addMallItem(data)
  self:OnAddMallItem(data)
  self:onSelectAnimShow()
end

function ShopFashionBaseView:onSelectDisableShopItem(data, state)
  self.curMallItemRow_ = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(data.itemId, true)
  if not self.curMallItemRow_ then
    return
  end
  self:AsyncRefreshUnrealSceneBG(self.curMallItemRow_.UnrealSceneBg)
  local fashionAdvanceData = self:getFashionAdvanceIdByFashionUnlockItemId(self.curMallItemRow_)
  if (self.curMallItemRow_.GoodsType == E.EShopGoodsType.EFashion or table.zcount(fashionAdvanceData) > 0) and 0 < state then
    local curShopList = table.zdeepCopy(self.shopData_.ShopBuyItemInfoList)
    local curWearDict = table.zdeepCopy(self.shopData_.ShopWearDict)
    self:RefreshGroupMallItemList(data, curShopList, curWearDict)
    self:RefreshPlayerWear(curShopList, curWearDict)
    self.viewData.parentView:CheckModelChange(E.EShopModelType.EPlayer)
  elseif self.curMallItemRow_.GoodsType == E.EShopGoodsType.EMount then
    self:OnSelectMount(self.curMallItemRow_)
  elseif self.curMallItemRow_.GoodsType == E.EShopGoodsType.EWeapon then
    local weaponId = self.curMallItemRow_.ItemId
    if self.curMallItemRow_.FashionList[1] and 0 < self.curMallItemRow_.FashionList[1] then
      weaponId = self.curMallItemRow_.FashionList[1]
    end
    self.viewData.parentView:CheckModelChange(E.EShopModelType.EPlayerWeapon)
    self.viewData.parentView:ShowPlayerWeaponModel(weaponId)
  else
    self:CheckNormalShopItemPreview(self.curMallItemRow_)
  end
  self:checkMallItemRepeat(state)
  self:refreshSelectItemName(data)
  self:refreshDetailList()
end

function ShopFashionBaseView:AsyncRefreshUnrealSceneBG(sceneBG)
  Z.CoroUtil.create_coro_xpcall(function()
    if string.zisEmpty(sceneBG) then
      sceneBG = Z.ConstValue.UnrealSceneBgPath.ShopDefaultBg
    end
    Z.UnrealSceneMgr:ChangeBinderGOTexture("sky", 0, "_MainTex", sceneBG, self.cancelSource:CreateToken())
  end)()
end

function ShopFashionBaseView:OnSelectMount(mallItemRow)
  local mountId = mallItemRow.ItemId
  if mallItemRow.FashionList[1] and mallItemRow.FashionList[1] > 0 then
    mountId = mallItemRow.FashionList[1]
  end
  self.viewData.parentView:CheckModelChange(E.EShopModelType.EMount)
  self.viewData.parentView:RefreshMountModel(mountId)
end

function ShopFashionBaseView:CheckNormalShopItemPreview(mallItemRow)
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(mallItemRow.ItemId, true)
  if not itemRow then
    return
  end
  if itemRow.Type == E.ItemType.VehicleUnlockItem then
    if not self.vehicleBaseTableMap_ then
      self.vehicleBaseTableMap_ = require("table.VehicleBaseTableMap")
    end
    local vehicleList = self.vehicleBaseTableMap_.VehicleSkinUnlock[mallItemRow.ItemId]
    if not vehicleList or not vehicleList[1] then
      return
    end
    self.viewData.parentView:CheckModelChange(E.EShopModelType.EMount)
    self.viewData.parentView:RefreshMountModel(vehicleList[1])
  end
end

function ShopFashionBaseView:checkMallItemRepeat(state)
  if state ~= 0 or not self.curMallItemRow_ then
    return
  end
  local curItemId = self.curMallItemRow_.ItemId
  local curFashionId = self.curMallItemRow_.FashionList[1]
  if (not curItemId or curItemId == 0) and (not curFashionId or curFashionId == 0) then
    return
  end
  local removeData = {}
  for mallId, mallData in pairs(self.shopData_.ShopBuyItemInfoList) do
    for mallPagetabId, shopItemSelectData in pairs(mallData) do
      local shopFashonId = shopItemSelectData.mallItemRow.FashionList[1] or -1
      local shopItemId = shopItemSelectData.mallItemRow.ItemId
      if curItemId == shopFashonId or curItemId == shopItemId or curFashionId == shopFashonId or curFashionId == shopItemId then
        removeData[#removeData + 1] = {mallId = mallId, mallPagetabId = mallPagetabId}
      end
    end
  end
  for i = 1, #removeData do
    self.shopData_:RemoveShopBuyItemByMallId(removeData[i].mallId, removeData[i].mallPagetabId)
  end
end

function ShopFashionBaseView:addMallItem(data)
  local pageTabId = 1
  if self.curMallPagetabTableRow_ then
    pageTabId = self.curMallPagetabTableRow_.Id
  end
  self.curSelectData_ = self:RefreshGroupMallItemList(data, self.shopData_.ShopBuyItemInfoList, self.shopData_.ShopWearDict)
  if not self.curSelectData_ then
    return
  end
  self.shopVM_.RefreshCost()
  self:refreshWearList()
  self:refreshCouponsState()
  self:refreshShopBuyBtnState()
  self:refreshCondition()
end

function ShopFashionBaseView:RefreshGroupMallItemList(data, shopList, wearDict)
  if not self.curMallTableRow_ then
    return
  end
  local pageTabId = 1
  if self.curMallPagetabTableRow_ then
    pageTabId = self.curMallPagetabTableRow_.Id
  end
  local mallItemRow = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(data.itemId, true)
  if not mallItemRow then
    return
  end
  local showRegionData, hideRegionData, fashoinId = self:getMallItemRegionList(mallItemRow)
  if hideRegionData and 0 < #hideRegionData then
    for i = #hideRegionData, 1, -1 do
      local wear = wearDict[hideRegionData[i]]
      if wear and wear.showWearData then
        self:removeShopListData(wear.showWearData, shopList)
      end
      wearDict[hideRegionData[i]] = nil
    end
  end
  if showRegionData and 0 < #showRegionData then
    for i = #showRegionData, 1, -1 do
      local wear = wearDict[showRegionData[i]]
      if wear and wear.showWearData then
        self:removeShopListData(wear.showWearData, shopList)
      end
      wearDict[showRegionData[i]] = nil
    end
  end
  if showRegionData and 0 < #showRegionData then
    local removeRegionList = {}
    for region, wearData in pairs(wearDict) do
      if wearData.hideRegionList then
        for i = 1, #wearData.hideRegionList do
          if table.zcontains(showRegionData, wearData.hideRegionList[i]) then
            removeRegionList[#removeRegionList + 1] = region
            break
          end
        end
      end
      if wearData.showRegionList then
        for i = 1, #wearData.showRegionList do
          if table.zcontains(showRegionData, wearData.showRegionList[i]) then
            removeRegionList[#removeRegionList + 1] = region
            break
          end
        end
      end
    end
    for i = 1, #removeRegionList do
      if wearDict[removeRegionList[i]] and wearDict[removeRegionList[i]].showWearData then
        self:removeShopListData(wearDict[removeRegionList[i]].showWearData, shopList)
      end
      wearDict[removeRegionList[i]] = nil
    end
  end
  local shopItemData = {
    data = data,
    mallTaleRow = self.curMallTableRow_,
    mallItemRow = mallItemRow,
    mallPagetabTableRow = self.curMallPagetabTableRow_,
    fashoinId = fashoinId
  }
  if not shopList[self.curMallTableRow_.Id] then
    shopList[self.curMallTableRow_.Id] = {}
  end
  shopList[self.curMallTableRow_.Id][pageTabId] = shopItemData
  if showRegionData and 0 < #showRegionData then
    local fashionShopWearMallData = {
      data = data,
      mallId = self.curMallTableRow_.Id,
      pageId = pageTabId
    }
    local wearData = {
      showWearData = fashionShopWearMallData,
      showRegionList = showRegionData,
      hideRegionList = hideRegionData
    }
    for i = 1, #showRegionData do
      wearDict[showRegionData[i]] = wearData
    end
    self.viewData.parentView:CheckModelChange(E.EShopModelType.EPlayer)
  end
  return shopItemData
end

function ShopFashionBaseView:getMallItemRegionList(row)
  if row.GoodsType ~= E.EShopGoodsType.ENormal and row.GoodsType ~= E.EShopGoodsType.EFashion then
    return
  end
  local showRegionData = {}
  local hideRegionData = {}
  local fashionId
  local fashionAdvanceData = self:getFashionAdvanceIdByFashionUnlockItemId(row)
  if table.zcount(fashionAdvanceData) > 0 then
    for _, data in pairs(fashionAdvanceData) do
      local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(data.fashionAdvanceId, true)
      if fashionRow then
        fashionId = fashionId or data.fashionAdvanceId
        local showRegion = fashionRow.Type
        local hideRegionList = fashionRow.HidePart
        showRegionData[#showRegionData + 1] = showRegion
        if hideRegionList and table.zcount(hideRegionList) > 0 then
          for i = 1, #hideRegionList do
            hideRegionData[#hideRegionData + 1] = hideRegionList[i]
          end
        end
      end
    end
  elseif not row.FashionList or table.zcount(row.FashionList) == 0 then
    fashionId = row.ItemId
    local showRegion, hideRegionList = self:getItemRegionList(fashionId)
    showRegionData[#showRegionData + 1] = showRegion
    if hideRegionList and table.zcount(hideRegionList) > 0 then
      for i = 1, #hideRegionList do
        hideRegionData[#hideRegionData + 1] = hideRegionList[i]
      end
    end
  else
    for i = 1, #row.FashionList do
      if self.fashionVM_.CheckIsFashion(row.FashionList[i]) then
        fashionId = fashionId or row.FashionList[i]
        local showRegion, hideRegionList = self:getItemRegionList(row.FashionList[i])
        showRegionData[#showRegionData + 1] = showRegion
        if hideRegionList and table.zcount(hideRegionList) > 0 then
          for i = 1, #hideRegionList do
            hideRegionData[#hideRegionData + 1] = hideRegionList[i]
          end
        end
      end
    end
    for i = 1, #showRegionData do
      if table.zcontains(hideRegionData, showRegionData[i]) then
        logError("shop_fashion_base_view MallItemTable fashionlist Error mallItemId:" .. row.Id)
        return
      end
    end
  end
  return showRegionData, hideRegionData, fashionId
end

function ShopFashionBaseView:getFashionAdvanceIdByFashionUnlockItemId(mallItemRow)
  local fashionAdvanceData = {}
  if mallItemRow.GoodsType ~= E.EShopGoodsType.ENormal then
    return fashionAdvanceData
  end
  if mallItemRow.FashionList and #mallItemRow.FashionList > 0 then
    for i = 1, #mallItemRow.FashionList do
      self:refreshFashionAdvanceData(fashionAdvanceData, mallItemRow.FashionList[i])
    end
  else
    self:refreshFashionAdvanceData(fashionAdvanceData, mallItemRow.ItemId)
  end
  return fashionAdvanceData
end

function ShopFashionBaseView:refreshFashionAdvanceData(data, itemId)
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId, true)
  if not itemRow then
    return
  end
  if itemRow.Type ~= E.ItemType.FashinUnlockItem then
    if self.fashionVM_.CheckIsFashion(itemId) then
      table.insert(data, {fashionAdvanceId = itemId, fashionId = itemId})
    end
    return
  end
  if not self.fashionAdvancedTableMap_ then
    self.fashionAdvancedTableMap_ = require("table.FashionAdvancedTableMap")
  end
  local fashionIdList = self.fashionAdvancedTableMap_.FashionAdvancedUnlock[itemId]
  if not fashionIdList then
    return
  end
  for i = 1, #fashionIdList do
    local row = Z.TableMgr.GetTable("FashionAdvancedTableMgr").GetRow(fashionIdList[i], true)
    if row and self.fashionVM_.CheckIsFashion(row.FashionId) then
      table.insert(data, {
        fashionAdvanceId = fashionIdList[i],
        fashionId = row.FashionId
      })
    end
  end
end

function ShopFashionBaseView:getItemRegionList(itemId)
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(itemId, true)
  if not fashionRow then
    return
  end
  if not self.fashionVM_.CheckStyleVisible(fashionRow) then
    return
  end
  return fashionRow.Type, fashionRow.HidePart
end

function ShopFashionBaseView:removeShopListData(data, shopList)
  local tabId = data.pageId or 1
  shopList[data.mallId][tabId] = nil
end

function ShopFashionBaseView:RemoveWear(removeData)
  local tabId = 1
  if removeData.mallPagetabTableRow then
    tabId = removeData.mallPagetabTableRow.Id
  end
  self.shopData_:RemoveShopBuyItemByMallId(removeData.mallTaleRow.Id, tabId)
  self.shopData_:RemoveShopWearItem(removeData.data.itemId)
  self.shopVM_.RefreshCost()
  self:RefreshViewData(removeData)
  if self.curSelectData_ and self.curSelectData_.mallItemRow and self.curSelectData_.mallItemRow.Id == removeData.mallTaleRow.Id then
    self:clearShopItemIndex()
  end
end

function ShopFashionBaseView:clearShopItemIndex()
  self.viewData.shopItemIndex = nil
  self.viewData.parentView.viewData.shopItemIndex = nil
  self.viewData.parentView.viewData.parentView:SetShopItemIndex(nil)
end

function ShopFashionBaseView:RigestTimerCall(key, func)
  self.viewData.parentView:RigestTimerCall(key, func)
end

function ShopFashionBaseView:UnrigestTimerCall(key)
  self.viewData.parentView:UnrigestTimerCall(key)
end

function ShopFashionBaseView:UpdateProp()
  self.viewData.parentView:UpdateProp()
end

function ShopFashionBaseView:onClickReset()
  self:clearSelectData()
  self.shopData_:ClearShopBuyItemInfoList()
  self.shopGridView_:ClearAllSelect()
  self.viewData.parentView:ResetPlayer()
  self:RefreshViewData()
  self:clearShopItemIndex()
end

function ShopFashionBaseView:onClickFashion()
end

function ShopFashionBaseView:OnAddMallItem(data)
end

function ShopFashionBaseView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function ShopFashionBaseView:onSelectAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_1)
end

return ShopFashionBaseView
