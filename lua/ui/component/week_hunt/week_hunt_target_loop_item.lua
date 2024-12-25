local super = require("ui.component.loop_list_view_item")
local WeekHuntTragetLoopItem = class("WeekHuntTragetLoopItem", super)
local loopListView = require("ui.component.loop_list_view")
local rewardLoopItem = require("ui.component.week_hunt.week_hunt_reward_loop_item")

function WeekHuntTragetLoopItem:ctor()
  self.uiBinder = nil
  self.awardprevVm_ = Z.VMMgr.GetVM("awardpreview")
  self.weeklyHuntData_ = Z.DataMgr.Get("weekly_hunt_data")
  self.weeklyHuntVm_ = Z.VMMgr.GetVM("weekly_hunt")
end

function WeekHuntTragetLoopItem:OnInit()
  function self.weeklyTowerChange_()
    self:weeklyTowerChange()
  end
  
  Z.ContainerMgr.CharSerialize.weeklyTower.Watcher:RegWatcher(self.weeklyTowerChange_)
  self.awardClimbUpIds_ = Z.ContainerMgr.CharSerialize.weeklyTower.awardClimbUpIds
  self.maxClimbUpId_ = Z.ContainerMgr.CharSerialize.weeklyTower.maxClimbUpId
  self.iconImg_ = self.uiBinder.img_layer_bg
  self.layerLab_ = self.uiBinder.lab_layer
  self.targetLab_ = self.uiBinder.lab_target
  self.btnNode_ = self.uiBinder.btn_goto
  self.haveNode_ = self.uiBinder.img_have
  self.awardNode_ = self.uiBinder.node_loop_item
  self.progressLab_ = self.uiBinder.lab_profressing
  self.mask_ = self.uiBinder.img_mask
  self.awardListView_ = loopListView.new(self.parent.UIView, self.awardNode_, rewardLoopItem, "com_item_square_8")
  self.awardListView_:Init({})
  self.parent.UIView:AddAsyncClick(self.btnNode_.btn, function()
    self.weeklyHuntVm_.AsyncGetWeeklyTowerProcessAward(self.data_, false, self.parent.UIView.cancelSource:CreateToken())
  end)
end

function WeekHuntTragetLoopItem:weeklyTowerChange()
  self.awardClimbUpIds_ = Z.ContainerMgr.CharSerialize.weeklyTower.awardClimbUpIds
  self.maxClimbUpId_ = Z.ContainerMgr.CharSerialize.weeklyTower.maxClimbUpId
  self:setUi()
end

function WeekHuntTragetLoopItem:OnRefresh(data)
  self.data_ = data
  local ruleRow = self.weeklyHuntData_.ClimbUpRuleTableRow
  if ruleRow and ruleRow.ProcessAward[self.Index] then
    local awardList = self.awardprevVm_.GetAllAwardPreListByIds(ruleRow.ProcessAward[self.Index])
    self.awardListView_:RefreshListView(awardList)
  end
  self.layerLab_.text = self.data_
  self.targetLab_.text = Lang("WeeklyHuntTargetPassLayer", {
    val = self.data_
  })
  self:setUi()
end

function WeekHuntTragetLoopItem:setUi()
  local isHave = false
  for index, layer in ipairs(self.awardClimbUpIds_) do
    if layer == self.data_ then
      isHave = true
      break
    end
  end
  self.uiBinder.Ref:SetVisible(self.mask_, isHave)
  self.uiBinder.Ref:SetVisible(self.haveNode_, isHave)
  self.btnNode_.Ref.UIComp:SetVisible(not isHave)
  self.uiBinder.Ref:SetVisible(self.progressLab_, false)
  self.redName_ = self.weeklyHuntVm_.GetTargetAwardRedName(self.data_)
  Z.RedPointMgr.LoadRedDotItem(self.redName_, self.parent.UIView, self.btnNode_.btn.transform)
  if not isHave and self.maxClimbUpId_ < self.data_ then
    self.btnNode_.Ref.UIComp:SetVisible(false)
    local rot = self.weeklyHuntData_.ClimbUpRuleTableRow
    if self.Index == 1 or rot and rot.ProcessId[self.Index - 1] and self.maxClimbUpId_ >= rot.ProcessId[self.Index - 1] then
      self.uiBinder.Ref:SetVisible(self.progressLab_, true)
    end
  end
end

function WeekHuntTragetLoopItem:OnRecycle(...)
  Z.RedPointMgr.RemoveNodeItem(self.redName_)
end

function WeekHuntTragetLoopItem:OnPointerClick()
end

function WeekHuntTragetLoopItem:OnUnInit()
  if self.awardListView_ then
    self.awardListView_:UnInit()
  end
  if self.weeklyTowerChange_ then
    Z.ContainerMgr.CharSerialize.weeklyTower.Watcher:UnregWatcher(self.weeklyTowerChange_)
    self.weeklyTowerChange_ = nil
  end
  Z.RedPointMgr.RemoveNodeItem(self.redName_, self.btnNode_.btn.transform)
end

return WeekHuntTragetLoopItem
