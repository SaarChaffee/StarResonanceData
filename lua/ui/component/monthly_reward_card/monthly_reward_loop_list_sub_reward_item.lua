local super = require("ui.component.loop_list_view_item")
local MonthlyRewardLoopListRewardItem = class("MonthlyRewardLoopListRewardItem", super)
local monthly_reward_loop_list_item = require("ui.component.monthly_reward_card.monthly_reward_loop_list_reward_loop_item")
local loopListView = require("ui.component.loop_list_view")

function MonthlyRewardLoopListRewardItem:OnInit()
  self.data_ = nil
  self.loopListView_ = loopListView.new(self.parent.UIView, self.uiBinder.loop_item, monthly_reward_loop_list_item, "monthly_reward_card_item_award_tpl", true)
  self.loopListView_:Init({})
  self.monthlyCardVM_ = Z.VMMgr.GetVM("monthly_reward_card")
end

function MonthlyRewardLoopListRewardItem:OnRefresh(data)
  if not data then
    return
  end
  self.data_ = data
  self.uiBinder.lab_figure.text = data.MonthCardPrivilegeConfig.SortId
  self.uiBinder.lab_name.text = data.MonthCardPrivilegeConfig.DesTitle
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_tips, false)
  local pathName = data.MonthCardPrivilegeConfig.SortId < 2 and "title_img_1" or "title_img_2"
  local path = self.parent.UIView.uiBinder.prefab_cache:GetString(pathName)
  if not string.zisEmpty(path) then
    self.uiBinder.rimg_title:SetImage(path)
  end
  local curKey = self.monthlyCardVM_:GetCurrentMonthlyCardKey()
  local isShowReceive = false
  local monthlyCardData = Z.ContainerMgr.CharSerialize.monthlyCard
  local monthlyCardInfo = monthlyCardData.monthlyCardInfo[curKey]
  if monthlyCardInfo then
    if data.AwardType == E.MonthlyAwardItemType.MonthLimitAwardId then
      isShowReceive = monthlyCardInfo.limitAwardStatus == E.ReceiveRewardStatus.Received
    elseif data.AwardType == E.MonthlyAwardItemType.MonthAward then
      isShowReceive = monthlyCardInfo.awardStatus == E.ReceiveRewardStatus.Received
    end
  end
  local dataList_ = {}
  dataList_ = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(data.AwardId)
  if data.MonthCardPrivilegeConfig.Type == E.MonthlyAwardType.EReward then
    for k, v in pairs(dataList_) do
      v.IsShowReceive = isShowReceive
    end
    self.uiBinder.node_continuous.Ref.UIComp:SetVisible(false)
    self.uiBinder.node_once.Ref.UIComp:SetVisible(false)
    self.uiBinder.Trans:SetHeight(172)
  elseif data.MonthCardPrivilegeConfig.Type == E.MonthlyAwardType.EFixedItem then
    if #dataList_ ~= 0 then
      if 1 < #dataList_ then
        self.uiBinder.node_once.Ref.UIComp:SetVisible(false)
        self.uiBinder.node_continuous.Ref.UIComp:SetVisible(true)
        self.uiBinder.node_continuous.lab_num_01.text = dataList_[1].awardNum
        self.uiBinder.node_continuous.lab_num_02.text = dataList_[2].awardNum
      else
        self.uiBinder.node_continuous.Ref.UIComp:SetVisible(false)
        self.uiBinder.node_once.Ref.UIComp:SetVisible(true)
        self.uiBinder.node_once.lab_num.text = dataList_[1].awardNum
      end
    end
    dataList_ = {}
    self.uiBinder.Trans:SetHeight(125)
  end
  self.parent:OnItemSizeChanged(self.Index)
  self.loopListView_:RefreshListView(dataList_, false)
  if monthlyCardData.lastAwardMonthlyCardTime ~= 0 and Z.TimeTools.CheckIsSameDay(math.floor(Z.TimeTools.Now() / 1000), monthlyCardData.lastAwardMonthlyCardTime) and data.AwardType == E.MonthlyAwardItemType.DayAward then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_tips, true)
  end
end

function MonthlyRewardLoopListRewardItem:OnUnInit()
  self.data_ = nil
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

return MonthlyRewardLoopListRewardItem
