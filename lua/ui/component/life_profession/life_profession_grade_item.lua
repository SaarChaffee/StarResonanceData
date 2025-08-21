local super = require("ui.component.loop_list_view_item")
local LifeProfessionGradeLoopItem = class("LifeProfessionGradeLoopItem", super)
local loopListView = require("ui.component.loop_list_view")
local commonRewardItem = require("ui.component.explore_monster.explore_monster_reward_item")

function LifeProfessionGradeLoopItem:ctor()
end

function LifeProfessionGradeLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
  if Z.IsPCUI then
    self.awardScrollRect_ = loopListView.new(self.parentUIView, self.uiBinder.loop_item, commonRewardItem, "com_item_square_8_pc")
  else
    self.awardScrollRect_ = loopListView.new(self.parentUIView, self.uiBinder.loop_item, commonRewardItem, "com_item_square_8")
  end
  self.awardScrollRect_:Init({})
  self.lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionTargetLevelChanged, self.lifeProfessionTargetLevelChanged, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionTargetStateChanged, self.lifeProfessionTargetStateChanged, self)
end

function LifeProfessionGradeLoopItem:lifeProfessionTargetLevelChanged(targetID)
  if targetID == self.data.TargetGroupId then
    self:refreshUI(self.data)
  end
end

function LifeProfessionGradeLoopItem:lifeProfessionTargetStateChanged(targetID)
  if targetID == self.data.TargetGroupId then
    self:refreshUI(self.data)
  end
end

function LifeProfessionGradeLoopItem:OnRefresh(data)
  self:refreshUI(data)
end

function LifeProfessionGradeLoopItem:refreshUI(data)
  self.data = data
  self.state_ = self.lifeProfessionVM.GetAwardState(self.parent.UIView.curProID, data.Id)
  local lifeAwardTargetTableRow_ = data
  if lifeAwardTargetTableRow_ == nil then
    return
  end
  self.uiBinder.btn_get:RemoveAllListeners()
  self:AddAsyncListener(self.uiBinder.btn_get, function()
    if self.state_ == E.LifeProfessionRewardState.UnGetReward then
      self.lifeProfessionVM.AsyncRequestGetReward(data.Id)
    end
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, self.state_ == E.LifeProfessionRewardState.UnGetReward)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_completed, self.state_ == E.LifeProfessionRewardState.GetReward)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_underway, self.state_ == E.LifeProfessionRewardState.UnFinished)
  local curProgress, targetProgress = self.lifeProfessionVM.GetGradeTargetProgress(self.parent.UIView.curProID, data.Id)
  self.uiBinder.lab_content.text = lifeAwardTargetTableRow_.TargetDes
  self.uiBinder.lab_num.text = targetProgress
  self.uiBinder.lab_completeness_num_black.text = curProgress
  self.uiBinder.lab_completeness_num_blue.text = curProgress
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_black, self.state_ ~= E.LifeProfessionRewardState.GetReward)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_blue, self.state_ == E.LifeProfessionRewardState.GetReward)
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local awardList = awardPreviewVm.GetAllAwardPreListByIds(self.data.AwardId)
  for k, v in pairs(awardList) do
    v.beGet = self.state_ == E.LifeProfessionRewardState.GetReward
  end
  self.awardScrollRect_:RefreshListView(awardList)
  self.awardScrollRect_:ClearAllSelect()
end

function LifeProfessionGradeLoopItem:OnUnInit()
  self:unInitLoopListView()
  Z.EventMgr:RemoveObjAll(self)
end

function LifeProfessionGradeLoopItem:unInitLoopListView()
  self.awardScrollRect_:UnInit()
  self.awardScrollRect_ = nil
end

return LifeProfessionGradeLoopItem
