local worldProxy = require("zproxy.world_proxy")
local MonthlyRewardCardVM = {}

function MonthlyRewardCardVM:GetIsBuyCurrentMonthCard()
  local monthlyCardData = Z.ContainerMgr.CharSerialize.monthlyCard
  if not monthlyCardData.monthlyCardInfo or table.zcount(monthlyCardData.monthlyCardInfo) == 0 then
    return false
  end
  local monthlyCardKey = self:GetActiveMonthlyCardKey()
  if monthlyCardData.monthlyCardInfo[monthlyCardKey] and Z.TimeTools.Now() / 1000 < monthlyCardData.expireTime then
    return true
  end
  return false
end

function MonthlyRewardCardVM:GetActiveMonthlyCardKey()
  local monthlyCardKey = 0
  local monthlyCardData = Z.ContainerMgr.CharSerialize.monthlyCard
  if monthlyCardData ~= nil and monthlyCardData.monthlyCardInfo ~= nil then
    local tempTable = {}
    local curKey
    local curTime = Z.TimeTools.Now() / 1000
    for k, v in pairs(monthlyCardData.monthlyCardInfo) do
      if curTime >= v.beginTime and curTime < v.endTime and (curKey == nil or k < curKey) then
        curKey = k
      end
    end
    monthlyCardKey = curKey or 0
  end
  return monthlyCardKey
end

function MonthlyRewardCardVM:GetTodayDate()
  local delayTime = Z.Global.MonthCardRefreshMonthlyOffset * 1000
  local today = Z.TimeFormatTools.Tp2YMDHMS(math.floor((Z.TimeTools.Now() - delayTime) / 1000))
  return today
end

function MonthlyRewardCardVM:GetCurrentMonthlyCardKey()
  local today = self:GetTodayDate()
  local monthlyCardKey = today.year * 100 + today.month
  return monthlyCardKey
end

function MonthlyRewardCardVM:AsyncGetMonthlyGuideReward(cancelToken)
  local errorCode = worldProxy.GetMonthlyGuideReward(cancelToken)
  if errorCode ~= 0 then
    Z.TipsVM.ShowTips(errorCode)
  end
  return errorCode
end

function MonthlyRewardCardVM:AsyncClickMonthlyCardTips(cancelToken, ignoreError)
  local errorCode = worldProxy.ClickMonthlyCardTips(cancelToken)
  if errorCode ~= 0 and not ignoreError then
    Z.TipsVM.ShowTips(errorCode)
  end
  return errorCode
end

function MonthlyRewardCardVM:CheckEveryDayRewardPopupCanShow()
  Z.CoroUtil.create_coro_xpcall(function()
    local monthlyCardData = Z.ContainerMgr.CharSerialize.monthlyCard
    local canShow = monthlyCardData.tipsClicked == E.MonthlyCardTipsClicked.CanShow
    local monthlyRewardCardData = Z.DataMgr.Get("monthly_reward_card_data")
    if not canShow or monthlyRewardCardData.IsOpenedTipsCardView then
      return
    end
    if self:GetActiveMonthlyCardKey() == 0 then
      local cancelSource = Z.CancelSource.Rent()
      self:AsyncClickMonthlyCardTips(cancelSource:CreateToken())
      cancelSource:Recycle()
      return
    end
    monthlyRewardCardData.IsOpenedTipsCardView = true
    Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.Activities, "monthly_reward_card_window")
  end)()
end

function MonthlyRewardCardVM:MonthCardPrivilegeDesTableRow(labType)
  local MonthCardPrivilegeDesTableMgr = Z.TableMgr.GetTable("MonthCardPrivilegeDesTableMgr")
  local monthCardPrivilegeDesTableRow = MonthCardPrivilegeDesTableMgr.GetRow(labType)
  if not monthCardPrivilegeDesTableRow then
    return
  end
  return monthCardPrivilegeDesTableRow
end

function MonthlyRewardCardVM:GetLoopLabShowText()
  local tempData = {}
  local monthCardPrivilegeTableRow = Z.TableMgr.GetTable("MonthCardPrivilegeTableMgr").GetDatas()
  for k, v in pairs(monthCardPrivilegeTableRow) do
    tempData[k] = v.MonthCardConventionalDes
  end
  return tempData
end

function MonthlyRewardCardVM:GetMonthlyPaymentProductId()
  local paymentVm = Z.VMMgr.GetVM("payment")
  local paymentData = Z.DataMgr.Get("payment_data")
  local payType = E.ProductType.MonthlyCard
  if Z.SDKLogin.GetPlatform() == E.LoginPlatformType.TencentPlatform then
    payType = E.ProductType.MonthlyCardTencent
  end
  local productRow = paymentVm:GetPaymentRow(Z.SDKLogin.GetPlatform(), payType)
  if table.zcount(productRow) > 0 then
    for k, v in pairs(productRow) do
      return v.Id, paymentData:GetProdctsName(v.Id)
    end
  end
  return nil, nil
end

return MonthlyRewardCardVM
