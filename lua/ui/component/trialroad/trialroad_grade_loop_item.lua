local super = require("ui.component.loop_list_view_item")
local TrialRoadGradeLoopItem = class("TrialRoadGradeLoopItem", super)
local loopListView = require("ui.component.loop_list_view")
local commonRewardItem = require("ui.component.explore_monster.explore_monster_reward_item")
local trialRoadRed_ = require("rednode.trialroad_red")

function TrialRoadGradeLoopItem:ctor()
end

function TrialRoadGradeLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.trialroadVM_ = Z.VMMgr.GetVM("trialroad")
  self.awardScrollRect_ = loopListView.new(self.parentUIView, self.uiBinder.loop_item, commonRewardItem, "com_item_square_8")
  self.awardScrollRect_:Init({})
end

function TrialRoadGradeLoopItem:OnRefresh(data)
  self.state_ = nil
  self.data = data
  if Z.ContainerMgr.CharSerialize.trialRoad.targetAward and Z.ContainerMgr.CharSerialize.trialRoad.targetAward.targetProgress[data[1]] then
    self.state_ = Z.ContainerMgr.CharSerialize.trialRoad.targetAward.targetProgress[data[1]].awardState
  end
  if self.state_ == nil then
    self.state_ = E.TrialRoadTargetState.UnFinished
  end
  local trialRoadTargetRow_ = Z.TableMgr.GetTable("TargetTableMgr").GetRow(data[1])
  if trialRoadTargetRow_ == nil then
    return
  end
  self.uiBinder.btn_get:RemoveAllListeners()
  self:AddAsyncListener(self.uiBinder.btn_get, function()
    if self.state_ == E.TrialRoadTargetState.UnGetReward then
      self.parentUIView:RequestGetTrialTargetReward(self.data[1])
    end
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, self.state_ == E.TrialRoadTargetState.UnGetReward)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_completed, self.state_ == E.TrialRoadTargetState.GetReward)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_underway, self.state_ == E.TrialRoadTargetState.UnFinished)
  local curProgress, targetProgress = self.trialroadVM_.GetGradeTargetProgress(data[1])
  self.uiBinder.lab_content.text = trialRoadTargetRow_.TargetDes
  self.uiBinder.lab_num.text = targetProgress
  self.uiBinder.lab_completeness_num_black.text = curProgress
  self.uiBinder.lab_completeness_num_blue.text = curProgress
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_black, self.state_ ~= E.TrialRoadTargetState.GetReward)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_blue, self.state_ == E.TrialRoadTargetState.GetReward)
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local awardList = awardPreviewVm.GetAllAwardPreListByIds(self.data[2])
  for k, v in pairs(awardList) do
    v.beGet = self.state_ == E.TrialRoadTargetState.GetReward
  end
  self.awardScrollRect_:RefreshListView(awardList)
  self.awardScrollRect_:ClearAllSelect()
  trialRoadRed_.LoadTrialRoadGradeTargetItem(self.data[1], self.parentUIView, self.uiBinder.btn_get_trans)
end

function TrialRoadGradeLoopItem:OnUnInit()
  self:unInitLoopListView()
end

function TrialRoadGradeLoopItem:unInitLoopListView()
  self.awardScrollRect_:UnInit()
  self.awardScrollRect_ = nil
end

return TrialRoadGradeLoopItem
