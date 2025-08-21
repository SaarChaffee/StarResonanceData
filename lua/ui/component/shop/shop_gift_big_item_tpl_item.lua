local ShopGiftBigItemTplItem = {}
local rechargeActivityDefine = require("ui.model.recharge_activity_define")
local loopScrollRect_ = require("ui.component.loop_list_view")
local commonPreviewLoopItem = require("ui.component.common_recharge.common_preview_loop_item")

function ShopGiftBigItemTplItem.RefreshTpl(uibinder, data, productInfo, view, isFirst)
  if isFirst then
    uibinder.anim:Restart(Z.DOTweenAnimType.Open)
  end
  uibinder.lab_item_name.text = data.payRechargeConfig.Name
  uibinder.Ref:SetVisible(uibinder.img_time, false)
  uibinder.Ref:SetVisible(uibinder.img_discount, false)
  local nowTime = Z.TimeTools.Now() / 1000
  if data.payRechargeConfig.Label then
    for _, lab in ipairs(data.payRechargeConfig.Label) do
      if tonumber(lab[1]) == rechargeActivityDefine.DiscountType.Discount then
        uibinder.Ref:SetVisible(uibinder.img_discount, true)
        if data.payRechargeConfig and data.paymentConfig then
          local discount = data.paymentConfig.Price / data.payRechargeConfig.ShowOriginalPrice * 100
          uibinder.lab_discount.text = string.format("%.2f%%", discount)
        else
          uibinder.lab_discount.text = ""
        end
      elseif tonumber(lab[1]) == rechargeActivityDefine.DiscountType.Text then
        uibinder.Ref:SetVisible(uibinder.img_discount, true)
        uibinder.lab_discount.text = Lang(lab[2])
      elseif tonumber(lab[1]) == rechargeActivityDefine.DiscountType.Time and nowTime <= data.rewardEndTime then
        uibinder.Ref:SetVisible(uibinder.img_time, true)
        uibinder.lab_week_num.text = Z.TimeFormatTools.FormatToDHMS(data.rewardEndTime - nowTime)
      end
    end
  end
  if data.payRechargeConfig.ShowIconRoute and data.payRechargeConfig.ShowIconRoute ~= "" then
    uibinder.rimg_icon:SetImage(data.payRechargeConfig.ShowIconRoute)
  end
  local isShowDayBg = false
  uibinder.Ref:SetVisible(uibinder.lab_weekly_num, false)
  uibinder.Ref:SetVisible(uibinder.lab_day_num, false)
  for _, value in ipairs(data.limitTimes) do
    uibinder.Ref:SetVisible(uibinder.img_day_bg, true)
    if value.timesType == rechargeActivityDefine.EActivityRewardTimesType.ActivityRewardTimesTypeDay then
      isShowDayBg = true
      uibinder.Ref:SetVisible(uibinder.lab_day_num, true)
      uibinder.lab_day_num.text = string.format(Lang("SeasonShopDayLimit"), value.maxTimes - value.times, value.maxTimes)
    elseif value.timesType == rechargeActivityDefine.EActivityRewardTimesType.ActivityRewardTimesTypeWeek then
      isShowDayBg = true
      uibinder.Ref:SetVisible(uibinder.lab_weekly_num, true)
      uibinder.lab_weekly_num.text = string.format(Lang("SeasonShopWeekLimit"), value.maxTimes - value.times, value.maxTimes)
    elseif value.timesType == rechargeActivityDefine.EActivityRewardTimesType.ActivityRewardTimesTypeOnce then
      isShowDayBg = true
      uibinder.Ref:SetVisible(uibinder.lab_weekly_num, true)
      uibinder.lab_weekly_num.text = Lang("RemainingNum", {
        val1 = value.maxTimes - value.times,
        val2 = value.maxTimes
      })
    end
  end
  uibinder.Ref:SetVisible(uibinder.img_day_bg, isShowDayBg)
  uibinder.Ref:SetVisible(uibinder.img_reddot, false)
  local isReceived = false
  if nowTime < data.rewardBeginTime then
    uibinder.Ref:SetVisible(uibinder.btn_buy, false)
    uibinder.Ref:SetVisible(uibinder.lab_starttime, true)
    uibinder.Ref:SetVisible(uibinder.lab_sell_out, false)
    uibinder.lab_starttime.text = string.zconcat(Z.TimeFormatTools.Tp2YMDHMS(data.rewardBeginTime - nowTime), Lang("OnTheShelf"))
  elseif (data.rewardBeginTime == 0 or nowTime >= data.rewardBeginTime) and (data.rewardEndTime == 0 or nowTime <= data.rewardEndTime) then
    uibinder.Ref:SetVisible(uibinder.lab_starttime, false)
    for _, value in ipairs(data.limitTimes) do
      if value.times == value.maxTimes then
        isReceived = true
        break
      end
    end
    if isReceived then
      uibinder.Ref:SetVisible(uibinder.btn_buy, false)
      uibinder.Ref:SetVisible(uibinder.lab_sell_out, true)
      uibinder.lab_sell_out.text = Lang("SeasonShopSellDone")
    else
      uibinder.Ref:SetVisible(uibinder.btn_buy, true)
      uibinder.Ref:SetVisible(uibinder.lab_sell_out, false)
      uibinder.Ref:SetVisible(uibinder.lab_symbol, false)
      if data.payRechargeConfig and data.payRechargeConfig.ProductId and data.payRechargeConfig.ProductId[1] == rechargeActivityDefine.ProductIdType.Free then
        uibinder.Ref:SetVisible(uibinder.lab_old_price, false)
        uibinder.lab_price_num.text = Lang("Free")
        uibinder.Ref:SetVisible(uibinder.img_reddot, true)
      else
        if data.payRechargeConfig and data.payRechargeConfig.ShowOriginalPrice and data.payRechargeConfig.ShowOriginalPrice ~= 0 then
          uibinder.Ref:SetVisible(uibinder.lab_old_price, true)
          uibinder.lab_old_price.text = data.payRechargeConfig.ShowOriginalPrice
        else
          uibinder.Ref:SetVisible(uibinder.lab_old_price, false)
        end
        if productInfo and data.paymentConfig then
          uibinder.Ref:SetVisible(uibinder.lab_symbol, true)
          uibinder.lab_symbol.text = productInfo.CurrencySymbol
          if productInfo.Price ~= "" then
            uibinder.lab_price_num.text = productInfo.Price
          else
            uibinder.lab_price_num.text = data.paymentConfig.Price
          end
        elseif data.paymentConfig then
          uibinder.lab_price_num.text = data.paymentConfig.Price
        else
          uibinder.lab_price_num.text = ""
        end
      end
    end
  else
    uibinder.Ref:SetVisible(uibinder.btn_buy, false)
    uibinder.Ref:SetVisible(uibinder.lab_starttime, false)
    uibinder.Ref:SetVisible(uibinder.lab_sell_out, true)
    uibinder.lab_sell_out.text = Lang("EnvSkillStateExpired")
  end
  local rewardItemList = loopScrollRect_.new(view, uibinder.loop_item, commonPreviewLoopItem, "com_item_square_8")
  local previewItemList = {}
  if data.paymentConfig then
    previewItemList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(data.paymentConfig.AwardId)
  elseif data.payRechargeConfig and data.payRechargeConfig.ProductId and data.payRechargeConfig.ProductId[2] then
    previewItemList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(data.payRechargeConfig.ProductId[2])
  end
  rewardItemList:Init(previewItemList)
  return rewardItemList
end

return ShopGiftBigItemTplItem
