local super = require("ui.component.loop_list_view_item")
local loop_list_view = require("ui/component/loop_list_view")
local rewardItem_ = require("ui/component/explore_monster/explore_monster_reward_item")
local EWorldBossPresonAwardState = {
  None = 0,
  NotReach = 1,
  ReachNotReceive = 2,
  ReachAndReceive = 3
}
local WorldBossStageLoopItem = class("WorldBossStageLoopItem", super)

function WorldBossStageLoopItem:ctor()
  self.worldBossVM_ = Z.VMMgr.GetVM("world_boss")
  self.worldBossData_ = Z.DataMgr.Get("world_boss_data")
  
  function self.onContainerDataChange_(container, dirtyKeys)
    self:OnRefresh(self.data_)
  end
end

function WorldBossStageLoopItem:OnInit()
  self.parentUIView_ = self.parent.UIView
  self:AddAsyncListener(self.uiBinder.btn_get, function()
    local data = self:GetCurData()
    local ret = self.worldBossVM_:AsyncReceiveBossReward(data.Id, self.parentUIView_.cancelSource:CreateToken())
    if ret == 0 then
      self.parentUIView_:RefreshRewardList()
    end
  end)
  local dataList_ = {}
  self.rewardScrollRect_ = loop_list_view.new(self, self.uiBinder.loop_list, rewardItem_, "com_item_square_1_8")
  self.rewardScrollRect_:Init(dataList_)
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
  Z.ContainerMgr.CharSerialize.personalWorldBossInfo.Watcher:RegWatcher(self.onContainerDataChange_)
end

function WorldBossStageLoopItem:OnRefresh(data)
  self.data_ = data
  self.eStage_ = EWorldBossPresonAwardState.None
  self:refreshStage(self.data_)
  self:refreshContent(self.data_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_getred, Z.RedPointMgr.GetRedState(self.worldBossVM_:GetProgressItemRedName(self.Index)))
end

function WorldBossStageLoopItem:refreshStage(data)
  local serveData = self.worldBossData_:GetWorldBossInfoData()
  self.stage_ = serveData.bossStage
  local receiveData = Z.ContainerMgr.CharSerialize.personalWorldBossInfo.bossAwardInfo
  if self.Index == 1 then
    self.eStage_ = EWorldBossPresonAwardState.None
  elseif self.stage_ >= self.Index then
    self.eStage_ = EWorldBossPresonAwardState.ReachNotReceive
    if receiveData then
      local curData = receiveData[data.Id]
      if curData and curData.awardStatus == E.ReceiveRewardStatus.Received then
        self.eStage_ = EWorldBossPresonAwardState.ReachAndReceive
      end
    end
  else
    self.eStage_ = EWorldBossPresonAwardState.NotReach
  end
end

function WorldBossStageLoopItem:refreshContent(data)
  self.uiBinder.lab_grade.text = tostring(self.Index)
  self.uiBinder.lab_content.text = data.ExtraBuffContent
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_underway, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list, self.eStage_ ~= EWorldBossPresonAwardState.None)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_completed, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_get_base, false)
  self.uiBinder.group_root.alpha = 0.7
  if self.eStage_ == EWorldBossPresonAwardState.ReachAndReceive then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_completed, true)
    self:refreshAwards(true, data)
  elseif self.eStage_ == EWorldBossPresonAwardState.ReachNotReceive then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_get_base, true)
    self.uiBinder.group_root.alpha = 1
    self:refreshAwards(false, data)
  elseif self.eStage_ == EWorldBossPresonAwardState.NotReach then
    self.uiBinder.group_root.alpha = 0.3
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_underway, true)
    local needNum = data.LvUpKillNum
    self.uiBinder.lab_underway.text = Lang("NotReachKillNum", {val = needNum})
    self:refreshAwards(false, data)
  end
  if self.Index == self.stage_ then
    self.uiBinder.group_root.alpha = 1
  end
end

function WorldBossStageLoopItem:refreshAwards(hasReceive, data)
  local awardId = data.StageAward
  local awardList = {}
  if 0 < awardId then
    awardList = self.awardPreviewVm_.GetAllAwardPreListByIds(awardId)
  end
  for _, value in ipairs(awardList) do
    value.beGet = hasReceive
  end
  self.rewardScrollRect_:RefreshListView(awardList)
end

function WorldBossStageLoopItem:OnSelected(isSelected)
end

function WorldBossStageLoopItem:OnUnInit()
  Z.ContainerMgr.CharSerialize.personalWorldBossInfo.Watcher:UnregWatcher(self.onContainerDataChange_)
  self.rewardScrollRect_:UnInit()
  self.rewardScrollRect_ = nil
end

function WorldBossStageLoopItem:OnReset()
  self.isSelected_ = false
end

function WorldBossStageLoopItem:AddAsyncClick(comp, func)
  self.parentUIView_:AddAsyncClick(comp, func)
end

return WorldBossStageLoopItem
