local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_info_quest_rightView = class("Map_info_quest_rightView", super)
local loop_list_view = require("ui/component/loop_list_view")
local quest_reward_item = require("ui/component/quest/map_quest_reward_item")
local questGoalComp = require("ui.component.goal.quest_goal_comp")
local questLimitComp = require("ui/component/quest/quest_limit_comp")

function Map_info_quest_rightView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "map_info_quest_right_sub", "map/map_info_quest_right_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.mapData_ = Z.DataMgr.Get("map_data")
  self.questDetailVM_ = Z.VMMgr.GetVM("questdetail")
  self.questVM_ = Z.VMMgr.GetVM("quest")
  self.questData_ = Z.DataMgr.Get("quest_data")
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
  self.gotofuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.bShowLimit_ = 0
  self.goalList_ = {}
  for i = 1, 3 do
    self.goalList_[i] = questGoalComp.new(self, i, E.GoalUIType.MapPanel)
  end
  self.limitComp_ = questLimitComp.new(self)
end

function Map_info_quest_rightView:OnActive()
  self:initComp()
  self:startAnimatedShow()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.closeByBtn_ = false
  self:AddClick(self.btn_return_, function()
    self.closeByBtn_ = true
    self.parent_:CloseRightSubView()
  end)
  self:AddClick(self.btn_cancel_track_, function()
    self:onClickCancelTrack()
  end)
  self:AddClick(self.btn_track_, function()
    self:trackQuest()
    self.parent_:CloseRightSubView()
  end)
  self:AddClick(self.uiBinder.btn_pathfinding, function()
    self:trackQuest()
    local pathFindingVM = Z.VMMgr.GetVM("path_finding")
    pathFindingVM:StartPathFindingByFlagData(self.parent_:GetCurSceneId(), self.flagData_)
    self.parent_:CloseRightSubView()
  end)
  self:AddClick(self.btn_reward_preview_, function()
    local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
    local questRow = questTbl.GetRow(self.questId_)
    if questRow then
      local awardList = self.awardPreviewVm_.GetAllAwardPreListByIds(questRow.AwardId)
      self.awardPreviewVm_.OpenRewardDetailViewByListData(awardList)
    end
  end)
  for i = 1, #self.goalList_ do
    self.goalList_[i]:Init(self.uiBinder["binder_goal" .. i])
  end
end

function Map_info_quest_rightView:initComp()
  self.btn_return_ = self.uiBinder.btn_return
  self.btn_track_ = self.uiBinder.btn_track
  self.btn_cancel_track_ = self.uiBinder.btn_cancel_track
  self.btn_reward_preview_ = self.uiBinder.btn_reward_preview
  self.lab_area_title_ = self.uiBinder.lab_area_title
  self.lab_title_ = self.uiBinder.lab_title
  self.lab_content_ = self.uiBinder.lab_content
  self.img_progress_title_ = self.uiBinder.img_progress_title
  self.lab_progress_title_ = self.uiBinder.lab_progress_title
  self.loopview_reward_list_ = self.uiBinder.loopscroll_reward_list
  self.layout_reward_ = self.uiBinder.layout_reward
  self.node_quest_cond_ = self.uiBinder.node_quest_cond
  self.anim_ = self.uiBinder.anim
  self.rewardloopView_ = loop_list_view.new(self, self.loopview_reward_list_, quest_reward_item, "com_item_square_8")
  self.rewardloopView_:Init({})
end

function Map_info_quest_rightView:OnRefresh()
  self.flagData_ = self.viewData.flagData
  self.questId_ = self.flagData_.QuestId
  self.isCanAcceptQuest_ = self.questData_:IsCanAcceptQuest(self.questId_)
  if self.isCanAcceptQuest_ then
    self:refreshAcceptQuest()
    return
  end
  local quest = self.questData_:GetQuestByQuestId(self.questId_)
  if not quest then
    return
  end
  self:refreshDescInfo()
  self:refreshProgressInfo()
  self:refreshRewardInfo()
  self:refreshBtnInfo()
end

function Map_info_quest_rightView:OnDeActive()
  if self.rewardloopView_ then
    self.rewardloopView_:UnInit()
  end
  for i = 1, #self.goalList_ do
    self.goalList_[i]:UnInit()
  end
  self.limitComp_:UnInit()
  self:startAnimatedHide()
end

function Map_info_quest_rightView:refreshAcceptQuest()
  self:refreshDescInfo()
  self:refreshProgressInfo()
  self:refreshRewardInfo()
  self:showTrackBtn()
end

function Map_info_quest_rightView:showTrackBtn()
  local isTracking = self.mapVM_.CheckIsTracingFlagByFlagData(self.parent_:GetCurSceneId(), self.viewData.flagData)
  self.uiBinder.Ref:SetVisible(self.btn_track_, not isTracking)
  self.uiBinder.Ref:SetVisible(self.btn_cancel_track_, isTracking)
  local isShow = self.gotofuncVM_.CheckFuncCanUse(E.FunctionID.PathFinding, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_pathfinding, isShow)
end

function Map_info_quest_rightView:onClickCancelTrack()
  if self.isCanAcceptQuest_ then
    self.mapVM_.ClearFlagDataTrackSource(self.parent_:GetCurSceneId(), self.flagData_)
    self.parent_:CloseRightSubView()
    return
  end
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(self.questId_)
  if questRow and questRow.QuestType == E.QuestType.Main then
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("MainQuestTrackCancelConfirm"), function()
      self:cancelTrack()
    end)
  else
    self:cancelTrack()
  end
end

function Map_info_quest_rightView:cancelTrack()
  local questTrackVM = Z.VMMgr.GetVM("quest_track")
  questTrackVM.CancelTrackingQuest(self.questId_)
  self.parent_:CloseRightSubView()
end

function Map_info_quest_rightView:refreshDescInfo()
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  local sceneTableRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(self.parent_:GetCurSceneId(), true)
  if sceneTableRow then
    self.lab_area_title_.text = sceneTableRow.Name
  end
  local questRow = questTbl.GetRow(self.questId_)
  if questRow then
    self.lab_title_.text = questRow.QuestName
    self.lab_content_.text = questRow.QuestDetail
  end
end

function Map_info_quest_rightView:refreshProgressInfo()
  local curQuestInfo = self.questData_:GetQuestByQuestId(self.questId_)
  if curQuestInfo then
    local stepConfig = self.questData_:GetStepConfigByStepId(curQuestInfo.stepId)
    if stepConfig then
      if stepConfig.StepMainTitle == "" then
        self.uiBinder.Ref:SetVisible(self.img_progress_title_, false)
      else
        self.uiBinder.Ref:SetVisible(self.img_progress_title_, true)
        local content = self.questVM_.PlaceholderTaskContent(stepConfig.StepMainTitle, nil)
        self.uiBinder.lab_progress_title.text = content
      end
    end
  else
    self.uiBinder.Ref:SetVisible(self.img_progress_title_, false)
  end
  for i = 1, #self.goalList_ do
    self.goalList_[i]:SetQuestId(self.questId_)
  end
  self.limitComp_:Init(self.questId_, self.node_quest_cond_)
end

function Map_info_quest_rightView:refreshRewardInfo()
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  local questRow = questTbl.GetRow(self.questId_)
  if questRow then
    if questRow.AwardId > 0 then
      local awardList = self.awardPreviewVm_.GetAllAwardPreListByIds(questRow.AwardId)
      self.rewardloopView_:RefreshListView(awardList)
      self.uiBinder.Ref:SetVisible(self.layout_reward_, 0 < #awardList)
    else
      self.uiBinder.Ref:SetVisible(self.layout_reward_, false)
    end
  end
end

function Map_info_quest_rightView:refreshBtnInfo()
  local trackId = self.questData_:GetQuestTrackingId()
  self.uiBinder.Ref:SetVisible(self.btn_cancel_track_, trackId == self.questId_)
  self.uiBinder.Ref:SetVisible(self.btn_track_, trackId ~= self.questId_)
end

function Map_info_quest_rightView:startAnimatedShow()
  self.anim_:Restart(Z.DOTweenAnimType.Open)
end

function Map_info_quest_rightView:startAnimatedHide()
  if self.closeByBtn_ then
    Z.CoroUtil.create_coro_xpcall(function()
      local coro = Z.CoroUtil.async_to_sync(self.anim_.CoroPlay)
      coro(self.anim_, Z.DOTweenAnimType.Close)
    end)()
  end
end

function Map_info_quest_rightView:trackQuest()
  if self.isCanAcceptQuest_ then
    local questGoalGuideVm = Z.VMMgr.GetVM("quest_goal_guide")
    local GoalGuideSourceType = questGoalGuideVm.CanAcceptquestToGoalGuideSourceType(self.questId_)
    self.mapVM_.SetMapTraceByFlagData(GoalGuideSourceType, self.parent_:GetCurSceneId(), self.flagData_)
  else
    local questTrackVM = Z.VMMgr.GetVM("quest_track")
    if questTrackVM.CheckIsAllowReplaceTrack(true) then
      questTrackVM.ReplaceAndTrackingQuest(self.questId_)
    end
  end
end

return Map_info_quest_rightView
