local UI = Z.UI
local super = require("ui.ui_subview_base")
local Monthly_reward_card_subView = class("Monthly_reward_card_subView", super)
local loopListView = require("ui.component.loop_list_view")
local monthly_sub_reward_item = require("ui.component.monthly_reward_card.monthly_reward_loop_list_sub_reward_item")
local monthly_sub_lab_item = require("ui.component.monthly_reward_card.monthly_reward_loop_list_sub_lab_item")

function Monthly_reward_card_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "monthly_reward_card_sub", "monthly_reward_card/monthly_reward_card_sub", UI.ECacheLv.None, true)
  self.monthlyCardVM_ = Z.VMMgr.GetVM("monthly_reward_card")
  self.monthlyCardData_ = Z.DataMgr.Get("monthly_reward_card_data")
  self.paymentVm_ = Z.VMMgr.GetVM("payment")
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.parent_ = parent
end

function Monthly_reward_card_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initParam()
  self:initView()
  self:initBtn()
  self:setRewardCardInfo()
  self:setLimitTime()
  self:refreshLoopList()
  self:bindEvents()
  self:bindWatcher()
  self:onStartAnimShow()
end

function Monthly_reward_card_subView:OnDeActive()
  self.isAllBuy_ = false
  Z.RedPointMgr.RemoveNodeItem(E.RedType.MonthlyCardGift)
  self:unBindWatcher()
  self:unBindEvents()
  self:stopTimer()
  if self.loopListView_ then
    self.loopListView_:UnInit()
    self.loopListView_ = nil
  end
  self.currentCardInfo_ = nil
  self.productId_ = nil
  self.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect_1)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect_2)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect_3)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_tipseffect)
end

function Monthly_reward_card_subView:OnRefresh()
end

function Monthly_reward_card_subView:RefreshData()
end

function Monthly_reward_card_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.MonthlyCard.RefreshGuideGift, self.refreshGiftData, self)
end

function Monthly_reward_card_subView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.MonthlyCard.RefreshGuideGift, self.refreshGiftData, self)
end

function Monthly_reward_card_subView:bindWatcher()
  function self.refreshMonthlyCardInfo_(container, dirtys)
    if dirtys and dirtys.monthlyCardInfo then
      self:refreshMonthlyNum()
      
      self:refreshLoopList()
    end
  end
  
  function self.counterListChanged_(container, dirtys)
    if dirtys then
      self:refreshGiftData()
    end
  end
  
  self.monthlyCardInfo_.Watcher:RegWatcher(self.refreshMonthlyCardInfo_)
  Z.ContainerMgr.CharSerialize.counterList.Watcher:RegWatcher(self.counterListChanged_)
end

function Monthly_reward_card_subView:unBindWatcher()
  self.monthlyCardInfo_.Watcher:UnregWatcher(self.refreshMonthlyCardInfo_)
  self.refreshMonthlyCardInfo_ = nil
  Z.ContainerMgr.CharSerialize.counterList.Watcher:UnregWatcher(self.counterListChanged_)
  self.counterListChanged_ = nil
end

function Monthly_reward_card_subView:initParam()
  local cardId = self.monthlyCardVM_:GetCurrentMonthlyCardKey()
  self.currentCardInfo_ = self.monthlyCardData_:AssemblyData(cardId)
  self.counterTableMgr_ = Z.TableMgr.GetTable("CounterTableMgr")
  self.monthlyCardInfo_ = Z.ContainerMgr.CharSerialize.monthlyCard
  self.isAllBuy_ = false
end

function Monthly_reward_card_subView:initView()
  local titleImgPaht = self.uiBinder.prefab_cache:GetString("title_img")
  self.uiBinder.rimg_title:SetImage(titleImgPaht)
  local labImgPath = self.uiBinder.prefab_cache:GetString("monthly_reward_card_lab")
  self.uiBinder.rimg_lab:SetImage(labImgPath)
  local serverProductId_
  self.productId_, serverProductId_ = self.monthlyCardVM_:GetMonthlyPaymentProductId()
  self.paymentVm_:GetProductionInfos({serverProductId_}, function(data)
    local paymentRow = Z.TableMgr.GetTable("PaymentTableMgr").GetRow(self.productId_)
    local currencySymbol = self.shopVm_.GetShopItemCurrencySymbol()
    self.showPrice_ = nil
    if data ~= nil then
      if data[1] == nil then
        self.monthlyPrice_ = paymentRow.Price
        self.showPrice_ = currencySymbol .. paymentRow.Price
      else
        self.monthlyPrice_ = data[1].Price
        self.showPrice_ = data[1].DisplayPrice
      end
    else
      self.monthlyPrice_ = paymentRow.Price
      self.showPrice_ = currencySymbol .. paymentRow.Price
    end
    self.uiBinder.lab_price.text = self.showPrice_
  end)
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item)
  self.loopListView_:SetGetPrefabNameFunc(function(data)
    if data.MonthCardPrivilegeConfig.Type == E.MonthlyAwardType.EReward or data.MonthCardPrivilegeConfig.Type == E.MonthlyAwardType.EFixedItem then
      if Z.IsPCUI then
        return "monthly_reward_card_item_tpl_pc"
      else
        return "monthly_reward_card_item_tpl"
      end
    elseif Z.IsPCUI then
      return "monthly_reward_card_lab_tpl_pc"
    else
      return "monthly_reward_card_lab_tpl"
    end
  end)
  self.loopListView_:SetGetItemClassFunc(function(data)
    if data.MonthCardPrivilegeConfig.Type == E.MonthlyAwardType.EReward or data.MonthCardPrivilegeConfig.Type == E.MonthlyAwardType.EFixedItem then
      return monthly_sub_reward_item
    else
      return monthly_sub_lab_item
    end
  end)
  self.loopListView_:Init({})
  self:refreshGiftData()
  self:refreshMonthlyNum()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.MonthlyCardGift, self, self.uiBinder.node_gift)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect_1)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect_2)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect_3)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_tipseffect)
end

function Monthly_reward_card_subView:initBtn()
  self:AddAsyncClick(self.uiBinder.btn_buy, function()
    if self.isAllBuy_ then
      Z.TipsVM.ShowTipsLang(1600001)
      return
    end
    local productId = self.productId_ == nil and 0 or self.productId_
    local paymentVm = Z.VMMgr.GetVM("payment")
    paymentVm:AsyncPayment(paymentVm:GetPayType(), productId)
  end)
  self:AddClick(self.uiBinder.btn_tips, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(801200)
  end)
  self:AddAsyncClick(self.uiBinder.btn_gift, function()
    self:getGuideGift()
  end)
end

function Monthly_reward_card_subView:getGuideGift()
  self.monthlyCardVM_:AsyncGetMonthlyGuideReward(self.cancelSource:CreateToken())
end

function Monthly_reward_card_subView:setRewardCardInfo()
  if not self.currentCardInfo_ then
    return
  end
  self.uiBinder.rimg_card:SetImage(self.currentCardInfo_.CardInfo.NoteMonthCardConfig.Resources)
  self.uiBinder.rimg_icon:SetImage(self.currentCardInfo_.CardInfo.AwardIcon)
  self.uiBinder.lab_card_qualify.text = self.currentCardInfo_.CardInfo.ItemConfig.Name
end

function Monthly_reward_card_subView:refreshLoopList()
  if not self.currentCardInfo_ then
    return
  end
  self.loopListView_:RefreshListView(self.currentCardInfo_.RewardList)
end

function Monthly_reward_card_subView:setLimitTime()
  if self.monthlyCardInfo_ == nil or self.monthlyCardInfo_.expireTime == 0 then
    self:setLimitTimeIsShow(false)
    return
  end
  self:stopTimer()
  self:setLimitTimeIsShow(true)
  local detailTime = self.monthlyCardInfo_.expireTime - math.floor(Z.TimeTools.Now() / 1000)
  local difference = detailTime
  self.timer_ = self.timerMgr:StartTimer(function()
    difference = difference - 1
    if difference <= 0 then
      self:setLimitTimeIsShow(false)
      self.timerMgr:StopTimer(self.timer)
      return
    end
    self.uiBinder.lab_time.text = Lang("MonthlyRemainingTime", {
      time = Z.TimeFormatTools.FormatToDHMS(self.monthlyCardInfo_.expireTime - Z.TimeTools.Now() / 1000)
    })
  end, 1, detailTime)
end

function Monthly_reward_card_subView:stopTimer()
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
end

function Monthly_reward_card_subView:setLimitTimeIsShow(isVisible)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_time, isVisible)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, not isVisible)
end

function Monthly_reward_card_subView:refreshGiftData()
  local iconImg = self.uiBinder.prefab_cache:GetString("gift_icon_on")
  local bgImg = self.uiBinder.prefab_cache:GetString("gift_bg_on")
  local counterId = Z.Global.MonthCardAwardCount
  local counterCfgData = self.counterTableMgr_.GetRow(counterId)
  local normalAwardCount = 0
  local nowAwardCount = 0
  local maxLimitNum = 0
  if counterCfgData then
    maxLimitNum = counterCfgData.Limit
    if Z.ContainerMgr.CharSerialize.counterList.counterMap[counterId] then
      nowAwardCount = Z.ContainerMgr.CharSerialize.counterList.counterMap[counterId].counter
    end
  end
  normalAwardCount = maxLimitNum - nowAwardCount
  local hasGift = 0 < normalAwardCount
  if not hasGift then
    iconImg = self.uiBinder.prefab_cache:GetString("gift_icon_off")
    bgImg = self.uiBinder.prefab_cache:GetString("gift_bg_off")
  end
  self.uiBinder.img_gift_icon:SetImage(iconImg)
  self.uiBinder.img_gift_bg:SetImage(bgImg)
  self.uiBinder.btn_gift.interactable = hasGift
  self.uiBinder.node_tipseffect:SetEffectGoVisible(hasGift)
end

function Monthly_reward_card_subView:refreshMonthlyNum()
  local today = Z.TimeFormatTools.Tp2YMDHMS(math.floor(Z.TimeTools.Now() / 1000))
  local isVisible = false
  local isAllBuy = 0
  for i = 1, Z.Global.MonthCardBuyTime do
    local month = today.month + i - 1
    if 12 < month then
      month = month - 12
    end
    self.uiBinder["lab_month_" .. i].text = Lang(E.MonthShowLang[month])
    local monthCardKey = today.year * 100 + month
    if self.monthlyCardInfo_.monthlyCardInfo and 0 < table.zcount(self.monthlyCardInfo_.monthlyCardInfo) and self.monthlyCardInfo_.monthlyCardInfo[monthCardKey] then
      isVisible = true
      isAllBuy = isAllBuy + 1
    else
      isVisible = false
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder["node_month_finish_" .. i], isVisible)
  end
  self.isAllBuy_ = isAllBuy == Z.Global.MonthCardBuyTime
  self.uiBinder.btn_buy.IsDisabled = isAllBuy == Z.Global.MonthCardBuyTime
  self.uiBinder.btn_buy.interactable = isAllBuy ~= Z.Global.MonthCardBuyTime
end

function Monthly_reward_card_subView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Monthly_reward_card_subView
