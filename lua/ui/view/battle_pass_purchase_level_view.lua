local super = require("ui.ui_view_base")
local BattlePass_purchase_levelView = class("BattlePass_purchase_levelView", super)
local loopScrollRect_ = require("ui.component.loop_list_view")
local awardPopupLoopItem = require("ui/component/season/season_buy_popup_loop_item")

function BattlePass_purchase_levelView:ctor()
  self.uiBinder = nil
  self.curNum_ = 1
  self.maxNum_ = 1
  self.amountSpent_ = 0
  super.ctor(self, "battle_pass_purchase_level")
end

function BattlePass_purchase_levelView:initWidgets()
  self.btn_cancel = self.uiBinder.btn_cancel
  self.btn_buy = self.uiBinder.btn_buy
  self.btn_max = self.uiBinder.btn_max
  self.btn_reduce = self.uiBinder.btn_reduce
  self.btn_add = self.uiBinder.btn_add
  self.lab_num = self.uiBinder.lab_num
  self.slider_temp = self.uiBinder.slider_temp
  self.lab_purchase = self.uiBinder.lab_purchase
  self.loopscroll_item = self.uiBinder.loopscroll_item
  self.sceneMask = self.uiBinder.scenemask
  self.node_loop_content_ = self.uiBinder.node_loop_content
  self.awardLoopScroll_ = loopScrollRect_.new(self, self.loopscroll_item, awardPopupLoopItem, "com_item_square")
  self.lab_digit = self.uiBinder.lab_digit
  self.rimg_gold = self.uiBinder.rimg_gold
end

function BattlePass_purchase_levelView:initClickEvents()
  self:AddClick(self.btn_max, function()
    self.slider_temp.value = self.maxNum_
  end)
  self:AddClick(self.btn_add, function()
    local num = self.curNum_ + 1 > self.maxNum_ and self.maxNum_ or self.curNum_ + 1
    self.slider_temp.value = num
  end)
  self:AddClick(self.btn_reduce, function()
    local num = self.curNum_ - 1 <= 1 and 1 or self.curNum_ - 1
    self.slider_temp.value = num
  end)
  self:AddClick(self.btn_cancel, function()
    Z.UIMgr:CloseView("battle_pass_purchase_level")
  end)
  self:AddAsyncClick(self.btn_buy, function()
    if not self.bpCardGlobalInfo_ then
      return
    end
    local itemCount = self.itemVM_.GetItemTotalCount(self.bpCardGlobalInfo_.LevelCost[1])
    if itemCount == 0 or itemCount < self.amountSpent_ then
      local shopVm = Z.VMMgr.GetVM("shop")
      shopVm.OpenShopView(E.FunctionID.PayFunction)
    else
      local ret = self.battlePassVM_.AsyncBuyBattlePassLevel(self.curNum_, self.cancelSource:CreateToken())
      if ret == 0 then
        Z.UIMgr:CloseView("battle_pass_purchase_level")
      else
        Z.TipsVM.ShowTips(ret)
      end
    end
  end)
end

function BattlePass_purchase_levelView:initParam()
  self.battlePassContainer_ = self.battlePassVM_.GetBattlePassContainer()
  if self.battlePassContainer_ then
    self.bpCardGlobalInfo_ = self.battlePassVM_.GetBattlePassGlobalTableInfo(self.battlePassContainer_.id)
    self.amountSpent_ = self.bpCardGlobalInfo_.LevelCost[2] * self.curNum_
    local itemCount = self.itemVM_.GetItemTotalCount(self.bpCardGlobalInfo_.LevelCost[1])
    self.battlePassLevelMaxNum_ = self.battlePassVM_.GetMaxLevel(self.battlePassContainer_.id)
    self.maxNum_ = math.floor(itemCount / self.bpCardGlobalInfo_.LevelCost[2])
  end
end

function BattlePass_purchase_levelView:OnActive()
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
  self.itemVM_ = Z.VMMgr.GetVM("items")
  self.awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  self:initParam()
  self:initWidgets()
  self:initClickEvents()
  self.sceneMask:SetSceneMaskByKey(self.SceneMaskKey)
  self:setViewInfo()
end

function BattlePass_purchase_levelView:setViewInfo()
  if not self.battlePassContainer_ then
    return
  end
  self.lab_num.text = self.curNum_
  if self.maxNum_ + self.battlePassContainer_.level > self.battlePassLevelMaxNum_ then
    self.maxNum_ = self.battlePassLevelMaxNum_ - self.battlePassContainer_.level
  end
  local maxNum = self.maxNum_
  self.slider_temp.maxValue = maxNum
  self.slider_temp.minValue = 1
  self.slider_temp.value = self.curNum_
  if maxNum < self.slider_temp.minValue then
    self:setBtnState(true)
  else
    self:setBtnState(false)
  end
  self:setAmountLabelText()
  self.rimg_gold:SetImage(self.itemVM_.GetItemIcon(self.bpCardGlobalInfo_.LevelCost[1]))
  self.lab_purchase.text = Lang("PassBuyExpTips", {
    val = self.battlePassContainer_.level + self.curNum_
  })
  self:setLoopScroll(true)
  self.awardLoopScroll_:SetIsCenter(true)
  self.slider_temp:RemoveAllListeners()
  self.slider_temp:AddListener(function(value)
    local num = math.floor(value)
    self.curNum_ = num
    self.lab_num.text = self.curNum_
    self.lab_purchase.text = Lang("PassBuyExpTips", {
      val = self.battlePassContainer_.level + self.curNum_
    })
    self.amountSpent_ = self.bpCardGlobalInfo_.LevelCost[2] * self.curNum_
    self:setAmountLabelText()
    self:setLoopScroll()
  end)
end

function BattlePass_purchase_levelView:setBtnState(isDisable)
  self.btn_max.IsDisabled = isDisable
  self.btn_max.interactable = not isDisable
  self.btn_reduce.IsDisabled = isDisable
  self.btn_reduce.interactable = not isDisable
  self.btn_add.IsDisabled = isDisable
  self.btn_add.interactable = not isDisable
  self.slider_temp.interactable = not isDisable
end

function BattlePass_purchase_levelView:setAmountLabelText()
  local str = Z.RichTextHelper.ApplyStyleTag(self.amountSpent_, E.TextStyleTag.Lab_num_black)
  local itemCount = self.itemVM_.GetItemTotalCount(self.bpCardGlobalInfo_.LevelCost[1])
  if itemCount < self.amountSpent_ then
    str = Z.RichTextHelper.ApplyStyleTag(self.amountSpent_, E.TextStyleTag.Lab_num_red)
  end
  self.lab_digit.text = str
end

function BattlePass_purchase_levelView:OnRefresh()
end

function BattlePass_purchase_levelView:setLoopScroll(isInit)
  local awardData = self.battlePassVM_.GetBuyLevelAwards(self.curNum_)
  self.awardList_ = self.awardPreviewVm.GetAllAwardPreListByIds(awardData)
  if not self.awardList_ then
    return
  end
  if isInit then
    self.awardLoopScroll_:Init(self.awardList_)
  else
    self.awardLoopScroll_:RefreshListView(self.awardList_)
  end
end

function BattlePass_purchase_levelView:OnDeActive()
  self.slider_temp:RemoveAllListeners()
  self.awardLoopScroll_:UnInit()
  self.awardLoopScroll_ = nil
  self.curNum_ = 1
  self.maxNum_ = 1
  self.amountSpent_ = 0
  self.awardList_ = nil
end

function BattlePass_purchase_levelView:GetAwardItemData(index)
  return self.awardList_[index]
end

return BattlePass_purchase_levelView
