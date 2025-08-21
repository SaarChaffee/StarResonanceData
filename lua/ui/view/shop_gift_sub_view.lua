local UI = Z.UI
local super = require("ui.ui_subview_base")
local Shop_gift_subView = class("Shop_gift_subView", super)
local rechargeActivityDefine = require("ui.model.recharge_activity_define")
local loopListScrollRect = require("ui.component.loop_list_view")
local loopGridScrollRect = require("ui.component.loop_grid_view")
local shopGiftLoopItem = require("ui.component.shop.shop_gift_loop_item")
local shopGiftPackageItemTplItem = require("ui.component.shop.shop_gift_package_item_tpl_item")

function Shop_gift_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "shop_gift_sub", "shop/shop_gift_new_sub", UI.ECacheLv.None, true)
  self.rechargeActivityData_ = Z.DataMgr.Get("recharge_activity_data")
  self.rechargeActivityVM_ = Z.VMMgr.GetVM("recharge_activity")
  self.paymentVM_ = Z.VMMgr.GetVM("payment")
  self.paymentData = Z.DataMgr.Get("payment_data")
  self.actionVM_ = Z.VMMgr.GetVM("action")
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.giftServerDatas_ = {}
  self.parent_ = parent
end

function Shop_gift_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.giftLoopList_ = loopListScrollRect.new(self, self.uiBinder.loop_gift, shopGiftLoopItem, "shop_fashion_gift2_item_tpl", true)
  self.giftLoopList_:Init({})
  self.packageLoopList_ = loopGridScrollRect.new(self, self.uiBinder.loop_item, shopGiftPackageItemTplItem, "com_item_square_8", true)
  self.packageLoopList_:Init({})
  self:AddAsyncClick(self.uiBinder.btn_buy, function()
    if self.selectGiftData_ == nil then
      return
    end
    self:BuyGift(self.selectGiftData_)
  end)
  self.uiBinder.rayimg_unrealscene_drag.onDrag:AddListener(function(go, eventData)
    self:OnPlayerModelDrag(eventData)
  end)
  local showPosX, showPosY, posX1, posY1 = self:OnGetTransPos()
  self:AddClick(self.uiBinder.btn_arrow, function()
    self.showPackageItems_ = not self.showPackageItems_
    if self.showPackageItems_ then
      self.uiBinder.node_title:SetAnchorPosition(showPosX, showPosY)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_buy, true)
      self.uiBinder.rect_arrow:SetScale(1, 1)
    else
      self.uiBinder.node_title:SetAnchorPosition(posX1, posY1)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_buy, false)
      self.uiBinder.rect_arrow:SetScale(1, -1)
    end
  end)
  self.functionId_ = self.viewData.shopTabData.fristLevelTabData.FunctionId
  self.selectGiftData_ = nil
  self.showPackageItems_ = true
  self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Open)
  self:initActionDict()
  self:refreshGridData()
  Z.EventMgr:Add(Z.ConstValue.RechargeActivity.ActivityRefresh, self.activityRefresh, self)
end

function Shop_gift_subView:OnGetTransPos()
  local showPosX, showPosY, posX1, posY1
  if Z.IsPCUI then
    showPosX, showPosY = 0, -40
    posX1, posY1 = 0, -695
  else
    showPosX, showPosY = 556, 312
    posX1, posY1 = 556, 312
  end
  return showPosX, showPosY, posX1, posY1
end

function Shop_gift_subView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.RechargeActivity.ActivityRefresh, self.activityRefresh, self)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect)
  self.uiBinder.node_effect:ReleseEffGo()
  self.actionDict_ = {}
  self.selectGiftData_ = nil
  self.giftLoopList_:UnInit()
  self.packageLoopList_:UnInit()
end

function Shop_gift_subView:OnRefresh()
end

function Shop_gift_subView:initActionDict()
  self.actionDict_ = {}
  self.actionVM_:InitModelActionInfo(self.actionDict_, Z.Global.FashionShowActionM, Z.Global.FashionShowActionF)
end

function Shop_gift_subView:RefreshData()
end

function Shop_gift_subView:refreshGridData()
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  local endTime = 0
  local nowTime = Z.TimeTools.Now() / 1000
  local payRechargePackageMgr = Z.TableMgr.GetTable("PayRechargePackageTableMgr")
  local paymentData = Z.TableMgr.GetTable("PaymentTableMgr"):GetDatas()
  local paymentDict = {}
  local currentPlatform = Z.SDKLogin.GetPlatform()
  for id, paymentRow in pairs(paymentData) do
    if table.zcontains(paymentRow.Platform, currentPlatform) and paymentRow.PaymentId and paymentRow.PaymentId ~= 0 then
      if paymentDict[paymentRow.PaymentId] then
        logError("currentPlatform has same paymentId")
      else
        paymentDict[paymentRow.PaymentId] = paymentRow
      end
    end
  end
  self.ProductionInfos = {}
  self.giftServerDatas_ = {}
  local giftServerDataIndex = 0
  local productIds = {}
  local activityDatas = self.rechargeActivityData_:GetActivityDatas(self.functionId_)
  for _, activityData in ipairs(activityDatas) do
    if activityData.status == rechargeActivityDefine.EActivityStatus.ActivityStatusOnline then
      for _, v in pairs(activityData.awardList) do
        local activityAward = v
        if (activityAward.reward_show_begintime == 0 or nowTime >= activityAward.reward_show_begintime) and (activityAward.reward_show_endtime == 0 or nowTime <= activityAward.reward_show_endtime) then
          local payRechargeConfig = payRechargePackageMgr.GetRow(activityAward.awardId)
          if payRechargeConfig ~= nil then
            local paymentConfig
            if payRechargeConfig.ProductId and payRechargeConfig.ProductId[1] and payRechargeConfig.ProductId[1] == rechargeActivityDefine.ProductIdType.Payment and payRechargeConfig.ProductId[2] then
              paymentConfig = paymentDict[payRechargeConfig.ProductId[2]]
              table.insert(productIds, self.paymentData:GetProdctsName(paymentConfig.Id))
            end
            giftServerDataIndex = giftServerDataIndex + 1
            self.giftServerDatas_[giftServerDataIndex] = {
              uuid = activityData.activityUuid,
              activityId = activityData.activityConfigId,
              id = activityAward.awardId,
              limitTimes = activityAward.rewardInfo.limitTimes,
              payProductId = activityAward.rewardInfo.payProductId,
              payServerProductId = self.paymentData:GetProdctsName(paymentConfig.Id),
              rewardShowBeginTime = activityAward.reward_show_begintime,
              rewardShowEndTime = activityAward.reward_show_endtime,
              rewardBeginTime = activityAward.reward_begintime,
              rewardEndTime = activityAward.reward_endtime,
              payRechargeConfig = payRechargeConfig,
              paymentConfig = paymentConfig
            }
            endTime = math.max(endTime, activityAward.reward_show_endtime, activityAward.reward_begintime, activityAward.reward_endtime)
          end
        end
      end
    end
  end
  table.sort(self.giftServerDatas_, function(a, b)
    return self:rewardSort(a, b)
  end)
  self.paymentVM_:GetProductionInfos(productIds, function(productInfos)
    if productInfos then
      for _, value in pairs(productInfos) do
        self.ProductionInfos[value.ID] = value
      end
    end
    self.giftLoopList_:RefreshListView(self.giftServerDatas_)
    self.giftLoopList_:ClearAllSelect()
    self.giftLoopList_:SetSelected(1)
    if endTime ~= 0 then
      self.timer_ = self.timerMgr:StartTimer(function()
        self:refreshUnitTime()
      end, 1, endTime)
    end
  end)
end

function Shop_gift_subView:SelectGift(data)
  self.selectGiftData_ = data
  self:refreshRightInfo()
  self:onStartAnimShow()
end

function Shop_gift_subView:refreshRightInfo()
  if self.selectGiftData_ == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, false)
    return
  end
  self.parent_:HideBanner()
  self:clearPlayerModel()
  local payRechargeConfig = self.selectGiftData_.payRechargeConfig
  if payRechargeConfig.ShowType == rechargeActivityDefine.GiftShowType.Icon then
    self.parent_:ShowBanner(payRechargeConfig.PackageIconBase, payRechargeConfig.ShowIconRoute)
  elseif payRechargeConfig.ShowType == rechargeActivityDefine.GiftShowType.Model then
    self:initPlayerModel()
    Z.CoroUtil.create_coro_xpcall(function()
      local path = payRechargeConfig.UnrealSceneBg
      if string.zisEmpty(path) then
        path = Z.ConstValue.UnrealSceneBgPath.ShopDefaultBg
      end
      Z.UnrealSceneMgr:ChangeBinderGOTexture("sky", 0, "_MainTex", path, self.cancelSource:CreateToken())
    end)()
  end
  local showPosX, showPosY, posX1, posY1 = self:OnGetTransPos()
  self.uiBinder.lab_name.text = payRechargeConfig.Name
  if self.showPackageItems_ then
    self.uiBinder.node_title:SetAnchorPosition(showPosX, showPosY)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_buy, true)
    self.uiBinder.rect_arrow:SetScale(1, 1)
  else
    self.uiBinder.node_title:SetAnchorPosition(posX1, posY1)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_buy, false)
    self.uiBinder.rect_arrow:SetScale(1, -1)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_weekly, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_day, false)
  for _, value in ipairs(self.selectGiftData_.limitTimes) do
    if value.timesType == rechargeActivityDefine.EActivityRewardTimesType.ActivityRewardTimesTypeDay then
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_day, true)
      self.uiBinder.lab_day_num.text = string.format(Lang("SeasonShopDayLimit"), value.maxTimes - value.times, value.maxTimes)
    elseif value.timesType == rechargeActivityDefine.EActivityRewardTimesType.ActivityRewardTimesTypeWeek then
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_weekly, true)
      self.uiBinder.lab_weekly_num.text = string.format(Lang("SeasonShopWeekLimit"), value.maxTimes - value.times, value.maxTimes)
    elseif value.timesType == rechargeActivityDefine.EActivityRewardTimesType.ActivityRewardTimesTypeOnce then
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_weekly, true)
      self.uiBinder.lab_weekly_num.text = Lang("SeasonRemainingNum", {
        val1 = value.maxTimes - value.times,
        val2 = value.maxTimes
      })
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_old_digit, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_old_gold, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_digit, false)
  local isReceived = false
  local nowTime = Z.TimeTools.Now() / 1000
  if nowTime <= self.selectGiftData_.rewardBeginTime then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_buy, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_leftTime, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_purchase, false)
    local tempTime = self.selectGiftData_.rewardBeginTime - nowTime
    self.uiBinder.lab_leftTime.text = string.zconcat(Z.TimeFormatTools.Tp2YMDHMS(tempTime), Lang("OnTheShelf"))
  elseif (self.selectGiftData_.rewardBeginTime == 0 or nowTime >= self.selectGiftData_.rewardBeginTime) and (self.selectGiftData_.rewardEndTime == 0 or nowTime <= self.selectGiftData_.rewardEndTime) then
    for _, value in ipairs(self.selectGiftData_.limitTimes) do
      if value.times == value.maxTimes then
        isReceived = true
        break
      end
    end
    if isReceived then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_buy, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_leftTime, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_purchase, true)
      self.uiBinder.lab_leftTime.text = Lang("SeasonShopSellDone")
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_buy, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_leftTime, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_purchase, false)
      if payRechargeConfig and payRechargeConfig.ProductId and payRechargeConfig.ProductId[1] == rechargeActivityDefine.ProductIdType.Free then
        self.uiBinder.lab_symbol.text = Lang("Free")
      else
        local price = 0
        local currencySymbol = ""
        local currencySymbolCode = ""
        local productInfo = self.ProductionInfos[self.selectGiftData_.payServerProductId]
        self.uiBinder.lab_old_digit.text = ""
        self.uiBinder.lab_digit.text = ""
        if productInfo and self.selectGiftData_.paymentConfig then
          if productInfo.DisplayPrice ~= nil then
            self.uiBinder.lab_symbol.text = productInfo.DisplayPrice
            price = productInfo.Price
            currencySymbol = productInfo.CurrencySymbol
            currencySymbolCode = productInfo.CurrencyCode
          else
            currencySymbol = productInfo.CurrencySymbol or self.shopVm_.GetShopItemCurrencySymbol()
            self.uiBinder.lab_symbol.text = currencySymbol .. self.selectGiftData_.paymentConfig.Price
            price = self.selectGiftData_.paymentConfig.Price
          end
        elseif self.selectGiftData_.paymentConfig then
          currencySymbol = self.shopVm_.GetShopItemCurrencySymbol()
          self.uiBinder.lab_symbol.text = currencySymbol .. self.selectGiftData_.paymentConfig.Price
          price = self.selectGiftData_.paymentConfig.Price
        else
          self.uiBinder.lab_symbol.text = ""
        end
        local curPlatform = Z.SDKLogin.GetPlatform()
        local isShowOldPrice = curPlatform == E.LoginPlatformType.TencentPlatform or curPlatform == E.LoginPlatformType.InnerPlatform
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_old_gold, isShowOldPrice)
        if isShowOldPrice and price ~= nil and payRechargeConfig and payRechargeConfig.ShowOriginalPrice and payRechargeConfig.ShowOriginalPrice ~= 0 then
          local old_price = self.paymentVM_:GetBeforeDiscountPrice(tonumber(price), payRechargeConfig.ShowOriginalPrice, currencySymbol, currencySymbolCode)
          self.uiBinder.lab_old_gold.text = old_price
        else
          self.uiBinder.lab_old_gold.text = ""
        end
      end
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_buy, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_leftTime, true)
    self.uiBinder.lab_leftTime.text = Lang("EnvSkillStateExpired")
  end
  local previewItemList = {}
  if self.selectGiftData_.paymentConfig then
    previewItemList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(self.selectGiftData_.paymentConfig.AwardId)
  elseif payRechargeConfig and payRechargeConfig.ProductId and payRechargeConfig.ProductId[2] then
    previewItemList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(payRechargeConfig.ProductId[2])
  end
  self.packageLoopList_:RefreshListView(previewItemList)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect)
  self.uiBinder.node_effect:ReleseEffGo()
  self.uiBinder.node_effect:CreatEFFGO(payRechargeConfig.ShowEffect, Vector3.zero)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect)
end

function Shop_gift_subView:activityRefresh(activityId)
  local needRefresh = false
  local activityDatas = self.rechargeActivityData_:GetActivityDatas(self.functionId_)
  for _, activityData in ipairs(activityDatas) do
    if activityData.activityConfigId == activityId then
      needRefresh = true
    end
  end
  if needRefresh then
    self:refreshGridData()
  end
end

function Shop_gift_subView:refreshUnitTime()
  local needSortUnit = false
  local nowTime = Z.TimeTools.Now() / 1000
  for _, giftData in ipairs(self.giftServerDatas_) do
    if nowTime <= giftData.rewardBeginTime then
      local tempTime = giftData.rewardBeginTime - nowTime
      if tempTime == 0 then
        needSortUnit = true
      end
    elseif nowTime > giftData.rewardEndTime then
      local tempTime = giftData.rewardEndTime - nowTime
      if 0 < tempTime and tempTime <= 1 then
        needSortUnit = true
      end
    elseif nowTime > giftData.rewardShowEndTime then
      local tempTime = giftData.rewardShowEndTime - nowTime
      if 0 < tempTime and tempTime <= 1 then
        needSortUnit = true
      end
    end
  end
  if self.selectGiftData_ and nowTime <= self.selectGiftData_.rewardBeginTime then
    local tempTime = self.selectGiftData_.rewardBeginTime - nowTime
    self.uiBinder.lab_leftTime.text = string.zconcat(Z.TimeFormatTools.Tp2YMDHMS(tempTime), Lang("OnTheShelf"))
  end
  local allItems = self.giftLoopList_:GetAllItem()
  for _, item in pairs(allItems) do
    item:RefreshTime(nowTime)
  end
  if needSortUnit then
    self:refreshGridData()
  end
end

function Shop_gift_subView:BuyGift(data)
  if data.payRechargeConfig and data.payRechargeConfig.ProductId[1] and data.payRechargeConfig.ProductId[1] == rechargeActivityDefine.ProductIdType.Free then
    self.rechargeActivityVM_.AsyncGetActivityReward(data.uuid, data.id, self.cancelSource:CreateToken())
  else
    self.paymentVM_:AsyncActivityAction(data.uuid, data.id, data.paymentConfig.Id)
  end
end

function Shop_gift_subView:getAwardSortId(award, curServerTime)
  local aTempSort = 0
  if award.rewardBeginTime ~= 0 and curServerTime < award.rewardBeginTime then
    aTempSort = 1
  elseif (award.rewardBeginTime == 0 or curServerTime >= award.rewardBeginTime) and (award.rewardEndTime == 0 or curServerTime < award.rewardEndTime) then
    local canBuy = true
    for _, limit in ipairs(award.limitTimes) do
      if limit.times == limit.maxTimes then
        canBuy = false
      end
    end
    if canBuy then
      aTempSort = 0
    else
      aTempSort = 2
    end
  elseif award.rewardEndTime ~= 0 and curServerTime > award.rewardEndTime then
    aTempSort = 3
  end
  return aTempSort
end

function Shop_gift_subView:rewardSort(a, b)
  local curServerTime = Z.TimeTools.Now() / 1000
  local aTempSort = self:getAwardSortId(a, curServerTime)
  local bTempSort = self:getAwardSortId(b, curServerTime)
  if aTempSort == bTempSort then
    return a.id < b.id
  else
    return aTempSort < bTempSort
  end
end

function Shop_gift_subView:initPlayerModel()
  local pos = Z.UnrealSceneMgr:GetTransPos("pos")
  local worldPosition = Vector3.New(pos.x + 0.64, pos.y + 0.06, pos.z + 0.13)
  self.playerModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
    local faceData = Z.DataMgr.Get("face_data")
    local gender = faceData:GetPlayerGender()
    local curRotation = Z.ConstValue.FaceGenderRotation[gender]
    model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, curRotation, 0)))
    model:SetAttrGoPosition(worldPosition)
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
    model:SetLuaAttrLookAtEnable(true)
    if self.selectGiftData_ and self.selectGiftData_.payRechargeConfig then
      local dataList = {}
      local showAvater = self.selectGiftData_.payRechargeConfig.ShowAvatar[gender]
      if showAvater then
        for _, fashionId in ipairs(showAvater) do
          table.insert(dataList, {FashionId = fashionId})
        end
        local fashionVM = Z.VMMgr.GetVM("fashion")
        local fashionZlist = fashionVM.WearDataListToZList(dataList)
        model:SetLuaAttr(Z.LocalAttr.EWearFashion, table.unpack({fashionZlist}))
        fashionZlist:Recycle()
        fashionZlist = nil
      end
      if showAvater and showAvater[1] then
        self:refreshPlayerModelAction(showAvater[1])
      else
        local faceVM = Z.VMMgr.GetVM("face")
        local actionData = faceVM.GetDefaultActionData()
        self.actionVM_:PlayAction(model, actionData)
      end
    end
  end, function(model)
    local fashionVm = Z.VMMgr.GetVM("fashion")
    fashionVm.SetModelAutoLookatCamera(model)
  end)
end

function Shop_gift_subView:OnPlayerModelDrag(eventData)
  if not self.playerModel_ then
    return
  end
  local rotation = self.playerModel_:GetAttrGoRotation()
  if not rotation then
    return
  end
  local curShowModelRotation = rotation.eulerAngles
  curShowModelRotation.y = curShowModelRotation.y - eventData.delta.x * Z.ConstValue.ModelRotationScaleValue
  self.playerModel_:SetAttrGoRotation(Quaternion.Euler(curShowModelRotation))
end

function Shop_gift_subView:clearPlayerModel()
  if not self.playerModel_ then
    return
  end
  Z.UnrealSceneMgr:ClearModel(self.playerModel_)
  self.playerModel_ = nil
end

function Shop_gift_subView:refreshPlayerModelAction(fashionId)
  if not self.playerModel_ then
    return
  end
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(fashionId, true)
  if not fashionRow then
    return
  end
  local actionInfo = self.actionDict_[fashionRow.Type] or 0
  if actionInfo and 0 < actionInfo.actionId then
    self.actionVM_:PlayAction(self.playerModel_, actionInfo)
  end
end

function Shop_gift_subView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Shop_gift_subView
