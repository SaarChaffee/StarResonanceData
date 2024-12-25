local super = require("ui.component.loop_list_view_item")
local TrialRoadRoomLoopItem = class("TrialRoadRoomLoopItem", super)

function TrialRoadRoomLoopItem:ctor()
  self.restTimer = nil
  self.trialroadVM = Z.VMMgr.GetVM("trialroad")
end

function TrialRoadRoomLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.lab_time = self.uiBinder.group_off.lab_time
  self:AddAsyncListener(self.uiBinder.group_off.btn_box, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(3100, self.uiBinder.group_off.img_box)
  end)
  self:AddAsyncListener(self.uiBinder.group_on.btn_box, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(3100, self.uiBinder.group_on.img_box)
  end)
end

function TrialRoadRoomLoopItem:OnRefresh(data)
  self.data = data
  self.showUnLockTime_ = not self.data.IsUnLockTime and self.data.TrialRoadInfo.RoomId == self.parentUIView.ShowUnLockTime_
  self:SetCanSelect(self.data.IsUnLockTime)
  self:SelectState()
end

function TrialRoadRoomLoopItem:OnUnInit()
  if self.restTimer then
    self.parentUIView:StopTrialroadTimer(self.restTimer)
    self.restTimer = nil
  end
  self.uiBinder.group_off.btn_box:RemoveAllListeners()
  self.uiBinder.group_on.btn_box:RemoveAllListeners()
end

function TrialRoadRoomLoopItem:Selected(isSelected, isClick)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("UI_Tab_Special")
    end
    self.parentUIView:OnSelectRoom(self:GetCurData())
  end
  self:SelectState()
end

function TrialRoadRoomLoopItem:SelectState()
  if self.IsSelected then
    self:refreshSelect()
  else
    self:refreshNormal()
  end
end

function TrialRoadRoomLoopItem:OnSelected(isSelected, isClick)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.data = curData
  self:Selected(isSelected, isClick)
end

function TrialRoadRoomLoopItem:refreshSelect()
  self.uiBinder.group_on.Ref.UIComp:SetVisible(true)
  self.uiBinder.group_off.Ref.UIComp:SetVisible(false)
  self:refreshBaseUI(self.uiBinder.group_on)
  self.uiBinder.Trans:SetHeight(310)
  self.parent:OnItemSizeChanged(self.Index)
end

function TrialRoadRoomLoopItem:refreshNormal()
  self.uiBinder.group_on.Ref.UIComp:SetVisible(false)
  self.uiBinder.group_off.Ref.UIComp:SetVisible(true)
  self:refreshBaseUI(self.uiBinder.group_off)
  self:refreshUnLock()
  self.uiBinder.Trans:SetHeight(216)
  self.parent:OnItemSizeChanged(self.Index)
end

function TrialRoadRoomLoopItem:refreshBaseUI(group)
  if self.data.IsLastFinish and self.data.IsUnLockTime or self.IsSelected then
    group.canvas_group.alpha = 1
  else
    group.canvas_group.alpha = 0.5
  end
  self:setStar(group)
  if self.Index < 10 then
    group.lab_num.text = Z.RichTextHelper.ApplyColorTag("0", "#FFFFFF20") .. self.Index
  else
    group.lab_num.text = self.Index
  end
  group.rimg_picture:SetImage(self.data.TrialRoadInfo.LabelPic)
  local showDot = false
  for _, v in ipairs(self.data.ListRoomTarget) do
    if v.TargetState == E.TrialRoadTargetState.UnGetReward then
      showDot = true
      break
    end
  end
  group.Ref:SetVisible(group.img_box, self.data.TrialRoadInfo.BonusRoom)
  group.Ref:SetVisible(group.img_dot, showDot)
end

function TrialRoadRoomLoopItem:refreshUnLock()
  self.uiBinder.group_off.Ref:SetVisible(self.uiBinder.group_off.img_star, not self.showUnLockTime_)
  self.uiBinder.group_off.Ref:SetVisible(self.uiBinder.group_off.lab_open, self.showUnLockTime_)
  self.uiBinder.group_off.Ref:SetVisible(self.uiBinder.group_off.lab_time, self.showUnLockTime_)
  self.uiBinder.group_off.Ref:SetVisible(self.uiBinder.group_off.img_lock, not self.data.IsUnLockTime)
  if self.showUnLockTime_ then
    if self.restTimer then
      self.parentUIView:StopTrialroadTimer(self.restTimer)
      self.restTimer = nil
    end
    self:refreshTimeLab()
    self.restTimer = self.parentUIView:StartTrialroadTimer(function()
      self:refreshTimeUILoop()
    end, 1, -1)
  elseif self.restTimer then
    self.parentUIView:StopTrialroadTimer(self.restTimer)
    self.restTimer = nil
  end
end

function TrialRoadRoomLoopItem:refreshTimeUILoop()
  local isFinished_ = self:refreshTimeLab()
  if isFinished_ then
    self:timerUILoopEnd()
  end
end

function TrialRoadRoomLoopItem:refreshTimeLab()
  local restTime = self.trialroadVM.RefreshRoomRestOpenTime(self.data)
  if restTime then
    self.lab_time.text = restTime
  end
  return restTime == nil
end

function TrialRoadRoomLoopItem:timerUILoopEnd()
  self.showUnLockTime_ = false
  self:refreshUnLock()
  if self.restTimer then
    self.parentUIView:StopTrialroadTimer(self.restTimer)
    self.restTimer = nil
  end
end

function TrialRoadRoomLoopItem:setStar(group)
  if not self.data.IsUnLockTime then
    return
  end
  local targetCount = #self.data.ListRoomTarget
  group.node_star1.Ref.UIComp:SetVisible(1 <= targetCount)
  group.node_star2.Ref.UIComp:SetVisible(2 <= targetCount)
  group.node_star3.Ref.UIComp:SetVisible(3 <= targetCount)
  group.node_star1.Ref:SetVisible(group.node_star1.img_on, self.data.ListRoomTarget[1] and self.data.ListRoomTarget[1].TargetState ~= E.TrialRoadTargetState.UnFinished)
  group.node_star2.Ref:SetVisible(group.node_star2.img_on, self.data.ListRoomTarget[2] and self.data.ListRoomTarget[2].TargetState ~= E.TrialRoadTargetState.UnFinished)
  group.node_star3.Ref:SetVisible(group.node_star3.img_on, self.data.ListRoomTarget[3] and self.data.ListRoomTarget[3].TargetState ~= E.TrialRoadTargetState.UnFinished)
end

return TrialRoadRoomLoopItem
