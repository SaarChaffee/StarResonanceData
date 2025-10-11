local super = require("ui.ui_view_base")
local Quest_detailView = class("Quest_detailView", super)
local loop_list_view = require("ui/component/loop_list_view")
local quest_catalogue_type_item = require("ui/component/quest/quest_detail_catalogue_quest_type_item")
local quest_catalogue_quest_item = require("ui/component/quest/quest_detail_catalogue_quest_item")
local comRewardItem = require("ui.component.common_reward_grid_list_item")
local quest_detail_series_reward_item = require("ui/component/quest/quest_detail_series_reward_item")
local QuestGoalComp = require("ui.component.goal.quest_goal_comp")

function Quest_detailView:ctor()
  super.ctor(self, "quest_detail")
  self.uiBinder = nil
  self.goalList_ = {}
  for i = 1, 3 do
    self.goalList_[i] = QuestGoalComp.new(self, i, E.GoalUIType.DetailPanel)
  end
  self.limitComp_ = require("ui/component/quest/quest_limit_comp").new(self)
  self.questDetailVM_ = Z.VMMgr.GetVM("questdetail")
  self.questVM_ = Z.VMMgr.GetVM("quest")
  self.questGoalVM_ = Z.VMMgr.GetVM("quest_goal")
  self.questData_ = Z.DataMgr.Get("quest_data")
  self.limitItems_ = {}
end

function Quest_detailView:initComp()
  self.scenemask_ = self.uiBinder.scenemask
  self.cont_btn_return_ = self.uiBinder.cont_btn_return
  self.node_loop_catalogue_ = self.uiBinder.node_loop_catalogue
  self.btn_track_ = self.uiBinder.btn_track
  self.btn_cancel_track_ = self.uiBinder.btn_cancel_track
  self.btn_give_up_ = self.uiBinder.btn_give_up
  self.lab_title_ = self.uiBinder.lab_title
  self.btn_ask_ = self.uiBinder.btn_ask
  self.lab_empty_ = self.uiBinder.lab_empty
  self.node_right_ = self.uiBinder.node_right
  self.node_condition_explain_ = self.uiBinder.node_condition_explain
  self.group_detail_ = self.uiBinder.group_detail
  self.lab_quest_name_ = self.uiBinder.lab_quest_name
  self.lab_quest_desc_ = self.uiBinder.lab_quest_desc
  self.group_award_ = self.uiBinder.group_award
  self.layout_content_ = self.uiBinder.layout_content
  self.lab_location_ = self.uiBinder.lab_location
  self.img_quest_main_title_ = self.uiBinder.img_quest_main_title
  self.lab_quest_target_tips_desc_ = self.uiBinder.lab_quest_target_tips_desc
  self.layout_goal_ = self.uiBinder.layout_goal
  self.node_track_btn_ = self.uiBinder.node_track_btn
  self.layout_list_condition_ = self.uiBinder.layout_list_condition
  self.anim_ = self.uiBinder.anim
  self.btn_quest_book_ = self.uiBinder.btn_quest_book
  self.loop_quest_award_ = self.uiBinder.node_loop_item
  self.loop_quest_series_award_ = self.uiBinder.node_loop_item_reward
  self.node_reward_desc_ = self.uiBinder.node_reward_desc
  self.tran_layout_tab_ = self.uiBinder.tran_layout_tab
  self.tog_group_tab_ = self.uiBinder.tog_group_tab
  self.img_line_ = self.uiBinder.img_line
end

function Quest_detailView:OnActive()
  self:initComp()
  self:startAnimatedShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.selectQuest_ = 0
  for i = 1, #self.goalList_ do
    self.goalList_[i]:Init(self.uiBinder["binder_goal" .. i])
  end
  local commonVM = Z.VMMgr.GetVM("common")
  commonVM.SetLabText(self.lab_title_, E.FunctionID.Task)
  self:initBtns()
  self:initCatalogueListComp()
  self:initAwardLoopListComp()
  self:bindEvents()
  self:initQuestGroupTabUI()
end

function Quest_detailView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(false)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.RedCacheContainer:GetQuestRed().CloseAllQuestRed()
  for i = 1, #self.goalList_ do
    self.goalList_[i]:UnInit()
  end
  self.catalogueListView_:UnInit()
  self.questAwardsLoopList_:UnInit()
  self.questSeriesAwardLoopList_:UnInit()
  self.limitComp_:UnInit()
  self.curGroupId_ = nil
end

function Quest_detailView:initBtns()
  self:AddClick(self.cont_btn_return_, function()
    self.questDetailVM_.CloseDetailView()
  end)
  self:AddClick(self.btn_track_, function()
    self:onTrackBtnClick()
  end)
  self:AddClick(self.btn_cancel_track_, function()
    self:onCancelTrackBtnClick()
  end)
  self:AddAsyncClick(self.btn_give_up_, function()
    self:onGiveQuestBtnClick()
  end)
  self:AddClick(self.btn_ask_, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(30050)
  end)
  self:AddClick(self.btn_quest_book_, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.QuestBook)
  end)
end

function Quest_detailView:initQuestGroupTabUI()
  self.groupIds_ = self.questDetailVM_.GetQuestTypeGroupIds()
  Z.CoroUtil.create_coro_xpcall(function()
    local path
    if Z.IsPCUI then
      path = GetLoadAssetPath("ComTabTogItem_PC")
    else
      path = GetLoadAssetPath("ComTabTogItem")
    end
    local firstUnit
    for i, groupId in ipairs(self.groupIds_) do
      local unit = self:AsyncLoadUiUnit(path, "QuestTab" .. groupId, self.tran_layout_tab_)
      if unit then
        if Z.IsPCUI then
          self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(unit.node_eff)
          unit.node_eff:SetEffectGoVisible(false)
        end
        self:refreshGroupTabItem(groupId, unit)
        if firstUnit == nil then
          firstUnit = unit
        end
      end
    end
    if firstUnit then
      local isOn = firstUnit.tog_tab_select.isOn
      if isOn then
        self:refreshQuestGroupTab(-1)
      else
        firstUnit.tog_tab_select.isOn = true
      end
    end
  end)()
end

function Quest_detailView:refreshGroupTabItem(groupId, unit)
  local imgPath, name
  if groupId == -1 then
    imgPath = "ui/atlas/item/c_tab_icon/com_icon_tab_67"
    name = Lang("Overview")
  else
    local typeGroupTbl = Z.TableMgr.GetTable("QuestTypeGroupTableMgr")
    local row = typeGroupTbl.GetRow(groupId)
    if row then
      imgPath = "ui/atlas/quest/icon/quest_icon_type_" .. row.TypeGroupUI
      name = row.GroupName
    end
  end
  unit.img_on:SetImage(imgPath)
  unit.img_off:SetImage(imgPath)
  if Z.IsPCUI then
    unit.lab_name_on.text = name
    unit.lab_name_off.text = name
  end
  unit.tog_tab_select.group = self.tog_group_tab_
  unit.tog_tab_select:AddListener(function(isOn)
    if Z.IsPCUI then
      if isOn then
        unit.anim_do:Restart(Z.DOTweenAnimType.Open)
        unit.node_eff:SetEffectGoVisible(true)
        self.anim_:Restart(Z.DOTweenAnimType.Tween_0)
      else
        unit.node_eff:SetEffectGoVisible(false)
      end
    end
    if isOn then
      self:refreshQuestGroupTab(groupId)
    end
  end)
end

function Quest_detailView:refreshQuestGroupTab(groupId)
  if self.curGroupId_ == groupId then
    return
  end
  self.curGroupId_ = groupId
  self.catalogueListView_:ClearAllSelect()
  if Z.IsPCUI then
    self:setLineHeight(groupId)
  end
  self:refreshWithDefaultQuest()
end

function Quest_detailView:initCatalogueListComp()
  self.catalogueListView_ = loop_list_view.new(self, self.node_loop_catalogue_)
  self.catalogueListView_:SetGetItemClassFunc(function(data)
    if data.isQuestType then
      return quest_catalogue_type_item
    else
      return quest_catalogue_quest_item
    end
  end)
  self.catalogueListView_:SetGetPrefabNameFunc(function(data)
    if data.isQuestType then
      if Z.IsPCUI then
        return "quest_detail_catalogue_type_item_tpl_pc"
      end
      return "quest_detail_catalogue_type_item_tpl"
    else
      if Z.IsPCUI then
        return "quest_detail_catalogue_item_tpl_pc"
      end
      return "quest_detail_catalogue_item_tpl"
    end
  end)
  self.catalogueListView_:Init({})
end

function Quest_detailView:initAwardLoopListComp()
  local name = "com_item_square_3_8"
  if Z.IsPCUI then
    name = "com_item_square_3_8_pc"
  end
  self.questAwardsLoopList_ = loop_list_view.new(self, self.loop_quest_award_, comRewardItem, name)
  self.questAwardsLoopList_:Init({})
  self.questSeriesAwardLoopList_ = loop_list_view.new(self, self.loop_quest_series_award_, quest_detail_series_reward_item, name)
  self.questSeriesAwardLoopList_:Init({})
end

function Quest_detailView:onTrackBtnClick()
  if self.selectQuest_ <= 0 then
    return
  end
  local questTrackVM = Z.VMMgr.GetVM("quest_track")
  if questTrackVM.CheckIsAllowReplaceTrack(true) then
    self.questDetailVM_.CloseDetailView()
    local questId = self.selectQuest_
    questTrackVM.OnTrackBtnClick(questId)
  end
end

function Quest_detailView:onCancelTrackBtnClick()
  local questTrackVM = Z.VMMgr.GetVM("quest_track")
  questTrackVM.CancelTrackingQuest(self.selectQuest_)
  self:refreshTrackBtnByQuestId(self.selectQuest_)
end

function Quest_detailView:onGiveQuestBtnClick()
  if self.selectQuest_ <= 0 then
    return
  end
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(self.selectQuest_)
  if not questRow or not questRow.GiveUp then
    return
  end
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("QuestCancelPrompt"), function()
    local ret = self.questVM_.AsyncGiveUpQuest(self.selectQuest_, self.cancelSource:CreateToken())
    if ret then
      self:refreshWithDefaultQuest()
    end
  end)
end

function Quest_detailView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Quest.TrackingIdChange, self.onTrackingIdChange, self)
end

function Quest_detailView:setLineHeight(groupId)
  local index = 0
  for i, v in ipairs(self.groupIds_) do
    if v == groupId then
      index = i - 1
      break
    end
  end
  local height = 154 + 78 * index
  self.img_line_:SetHeight(height)
end

function Quest_detailView:onTrackingIdChange()
  self.questtypeGroupList_ = self.questDetailVM_.GetQuestTypeGroupList(self.curGroupId_)
  self.catalogueDatas_ = self.questDetailVM_.GetQuestDetailCatalogueDatas(self.questtypeGroupList_, self.curGroupId_)
  self.catalogueListView_:RefreshListView(self.catalogueDatas_)
end

function Quest_detailView:refreshWithDefaultQuest()
  self:onTrackingIdChange()
  local selectIndex = self:getDefaultSelectIndex()
  self.catalogueListView_:SetSelected(selectIndex)
  self.catalogueListView_:MovePanelToItemIndex(selectIndex, 0)
  local isEmpty = #self.catalogueDatas_ == 0
  self.uiBinder.Ref:SetVisible(self.lab_empty_, isEmpty)
  self.uiBinder.Ref:SetVisible(self.node_right_, not isEmpty)
  if selectIndex == nil or selectIndex <= 0 then
    self.uiBinder.Ref:SetVisible(self.group_detail_, false)
    self.uiBinder.Ref:SetVisible(self.node_track_btn_, false)
  end
end

function Quest_detailView:getDefaultSelectIndex()
  local selectQuestId = self.questData_:GetQuestTrackingId()
  local defaultIndex = -1
  for i, data in ipairs(self.catalogueDatas_) do
    if not data.isQuestType then
      if defaultIndex == -1 then
        defaultIndex = i
      end
      if selectQuestId == nil or selectQuestId <= 0 or data.questId == selectQuestId then
        return i
      end
    end
  end
  return defaultIndex
end

function Quest_detailView:GetSelectedQuest()
  return self.selectQuest_
end

function Quest_detailView:SelectQuest(questId)
  self.questData_.GMSelectQuestId = questId
  self.selectQuest_ = questId
  self:refreshDetailById(self.selectQuest_)
  for i = 1, #self.goalList_ do
    self.goalList_[i]:SetQuestId(self.selectQuest_)
  end
  self:refreshLimit()
end

function Quest_detailView:refreshDetailById(id)
  if not self.questDetailVM_.IsValidQuest(id) then
    self.uiBinder.Ref:SetVisible(self.group_detail_, false)
    return
  end
  for i = 1, #self.goalList_ do
    self.goalList_[i]:SetQuestId(id)
  end
  self:refreshLimit()
  self.uiBinder.Ref:SetVisible(self.group_detail_, true)
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(id)
  if questRow == nil then
    return
  end
  local quest = self.questData_:GetQuestByQuestId(id)
  self.lab_quest_name_.text = self.questVM_.GetQuestName(quest.id)
  local param = Z.Placeholder.SetPlayerSelfPronoun()
  self.lab_quest_desc_.text = Z.Placeholder.Placeholder(questRow.QuestDetail, param)
  self.uiBinder.Ref:SetVisible(self.btn_give_up_, questRow.GiveUp)
  self:refreshQuestSeriesAwards(id)
  self:refreshQuestAwards(id)
  self:refreshTrackBtnByQuestId(quest.id)
  self:refreshQuestTitleAndDes(quest.id, quest.stepId)
  self:refreshTrackUi(quest)
end

function Quest_detailView:refreshQuestAwards(questId)
  local awardList = self.questDetailVM_.GetQuestRewardById(questId)
  self.questAwardsLoopList_:RefreshListView(awardList)
end

function Quest_detailView:refreshQuestSeriesAwards(questId)
  local awardList = self.questDetailVM_.GetQuestSeriesRewardById(questId)
  if awardList == nil or #awardList < 1 then
    self.uiBinder.Ref:SetVisible(self.node_reward_desc_, false)
    self.questSeriesAwardLoopList_:RefreshListView({})
    return
  end
  self.uiBinder.Ref:SetVisible(self.node_reward_desc_, true)
  self.questSeriesAwardLoopList_:RefreshListView(awardList)
end

function Quest_detailView:refreshTrackUi(questContainerData)
  local goalIdx = self.questGoalVM_.GetUncompletedGoalIndex(questContainerData.id)
  local trackData = self.questData_:GetGoalTrackData(questContainerData.stepId, goalIdx)
  if trackData then
    local toSceneId = trackData.toSceneId
    self.uiBinder.Ref:SetVisible(self.layout_content_, 0 < toSceneId)
    if 0 < toSceneId then
      local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(toSceneId)
      local sceneName = sceneRow and sceneRow.Name or ""
      self.lab_location_.text = sceneName
    end
  else
    self.uiBinder.Ref:SetVisible(self.layout_content_, false)
  end
end

function Quest_detailView:refreshQuestTitleAndDes(questId, setpId)
  local stepRow = self.questData_:GetStepConfigByStepId(setpId)
  if stepRow then
    if stepRow.StepMainTitle == "" then
      self.uiBinder.Ref:SetVisible(self.img_quest_main_title_, false)
    else
      self.uiBinder.Ref:SetVisible(self.img_quest_main_title_, true)
      local content = self.questVM_.PlaceholderTaskContent(stepRow.StepMainTitle, nil)
      self.lab_quest_target_tips_desc_.text = content
    end
    self.uiBinder.Ref:SetVisible(self.layout_goal_, true)
  end
end

function Quest_detailView:refreshTrackBtnByQuestId(questId)
  local trackVM = Z.VMMgr.GetVM("quest_track")
  local isVisible = false
  if not self.questData_:IsForceTrackQuest(questId) and trackVM.IsQuestShowTrackBar(questId) then
    isVisible = true
  end
  self.uiBinder.Ref:SetVisible(self.node_track_btn_, isVisible)
  if self.questData_:IsShowInTrackBar(questId) then
    self:setBtnTrackState(false)
  else
    self:setBtnTrackState(true)
  end
end

function Quest_detailView:setBtnTrackState(isShowTrack)
  self.uiBinder.Ref:SetVisible(self.btn_track_, isShowTrack)
  self.uiBinder.Ref:SetVisible(self.btn_cancel_track_, not isShowTrack)
end

function Quest_detailView:refreshLimit()
  self.limitComp_:Init(self.selectQuest_, self.node_condition_explain_)
end

function Quest_detailView:startAnimatedShow()
  self.anim_:Restart(Z.DOTweenAnimType.Open)
end

function Quest_detailView:startAnimatedHide()
end

function Quest_detailView:OnClickBtnAnimShow()
  self.anim_:Restart(Z.DOTweenAnimType.Tween_1)
end

return Quest_detailView
