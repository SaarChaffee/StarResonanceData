local TrialRoadChallengeLoopItem = class("TrialRoadChallengeLoopItem")
local loopListView = require("ui.component.loop_list_view")
local commonRewardItem = require("ui.component.explore_monster.explore_monster_reward_item")
local trialRoadRed_ = require("rednode.trialroad_red")

function TrialRoadChallengeLoopItem:ctor(parentView)
  self.parentUIView = parentView
end

function TrialRoadChallengeLoopItem:Init(data, uiBinder)
  self.data = data
  self.uiBinder = uiBinder
  self.trialroadVM_ = Z.VMMgr.GetVM("trialroad")
  self.awardScrollRect_ = loopListView.new(self.parentUIView, self.uiBinder.loop_item, commonRewardItem, "com_item_square_8")
  self.awardScrollRect_:Init({})
  self:refresh(self.data)
end

function TrialRoadChallengeLoopItem:refresh(data)
  local trialRoadTargetRow_ = Z.TableMgr.GetTable("TargetTableMgr").GetRow(data.TargetId)
  if trialRoadTargetRow_ == nil then
    return
  end
  self.uiBinder.lab_describe.text = trialRoadTargetRow_.TargetDes
  self.uiBinder.btn_receive:RemoveAllListeners()
  self.parentUIView:AddAsyncListener(self.uiBinder.btn_receive, function()
    if data.TargetState == E.TrialRoadTargetState.UnGetReward then
      self.parentUIView:RequestGetTargetReward(self.data.TargetId)
    end
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_finish, data.TargetState == E.TrialRoadTargetState.GetReward)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_getreward, data.TargetState == E.TrialRoadTargetState.UnGetReward)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_unfinished, data.TargetState == E.TrialRoadTargetState.UnFinished)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_star_on, data.TargetState ~= E.TrialRoadTargetState.UnFinished)
  local curProgress, targetProgress = self.trialroadVM_.GetRoomTargetProgress(data.RoomId, data.TargetId)
  self.uiBinder.lab_progress.text = "( " .. curProgress .. "/" .. targetProgress .. " )"
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local awardList = awardPreviewVm.GetAllAwardPreListByIds(self.data.AwardId)
  for k, v in ipairs(awardList) do
    v.beGet = data.TargetState == E.TrialRoadTargetState.GetReward
  end
  self.awardScrollRect_:RefreshListView(awardList)
  self.awardScrollRect_:ClearAllSelect()
  trialRoadRed_.LoadTrialRoadRoomTargetItem(data.RoomId, data.TargetId, self.parentUIView, self.uiBinder.Trans, self.Index)
end

function TrialRoadChallengeLoopItem:AddAsyncClick(comp, func)
  self.parentUIView_:AddAsyncClick(comp, func)
end

function TrialRoadChallengeLoopItem:UnInit()
  self:unInitLoopListView()
end

function TrialRoadChallengeLoopItem:unInitLoopListView()
  Z.RedPointMgr.RemoveChildernNodeItem(self.uiBinder.Trans, self.parentUIView)
  self.awardScrollRect_:UnInit()
  self.awardScrollRect_ = nil
end

function TrialRoadChallengeLoopItem:Recycle()
  Z.RedPointMgr.RemoveChildernNodeItem(self.uiBinder.Trans, self.parentUIView)
  if self.awardScrollRect_ then
    self.awardScrollRect_:UnInit()
    self.awardScrollRect_ = nil
  end
end

return TrialRoadChallengeLoopItem
