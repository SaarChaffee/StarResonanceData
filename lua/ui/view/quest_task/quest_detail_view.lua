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
  self.limitComp_ = require("ui/component/quest/quest_limit_comp").new(self, {
    time = function(state)
      self:refreshTimeLimitUIByState(state)
    end,
    itemCount = function(idx, state)
      self:refreshItemCountLimitUIByState(idx, state)
    end,
    date = function(idx, state, time)
      self:refreshDateLimit(idx, state, time)
    end,
    roleLv = function(idx, state, lv)
      self:refreshRoleLvLimit(idx, state, lv)
    end,
    questStep = function(idx, state, questId)
      self:refreshQuestStepLimit(idx, state, questId)
    end
  })
  self.questDetailVM_ = Z.VMMgr.GetVM("questdetail")
  self.questVM_ = Z.VMMgr.GetVM("quest")
  self.questData_ = Z.DataMgr.Get("quest_data")
  self.limitItems_ = {}
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
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
  self.group_condition_explain_ = self.uiBinder.group_condition_explain
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
end

function Quest_detailView:OnActive()
  self:initComp()
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
  self:RegisterInputActions()
  self:refreshWithDefaultQuest()
end

function Quest_detailView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(false)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:UnRegisterInputActions()
  self.questVM_.CloseAllQuestRed()
  for i = 1, #self.goalList_ do
    self.goalList_[i]:UnInit()
  end
  self.catalogueListView_:UnInit()
  self.questAwardsLoopList_:UnInit()
  self.questSeriesAwardLoopList_:UnInit()
  self.limitComp_:UnInit()
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
      return "quest_detail_catalogue_type_item_tpl"
    else
      return "quest_detail_catalogue_item_tpl"
    end
  end)
  self.catalogueListView_:Init({})
end

function Quest_detailView:initAwardLoopListComp()
  self.questAwardsLoopList_ = loop_list_view.new(self, self.loop_quest_award_, comRewardItem, "com_item_square_3_8")
  self.questAwardsLoopList_:Init({})
  self.questSeriesAwardLoopList_ = loop_list_view.new(self, self.loop_quest_series_award_, quest_detail_series_reward_item, "com_item_square_3_8")
  self.questSeriesAwardLoopList_:Init({})
end

function Quest_detailView:onTrackBtnClick()
  if self.selectQuest_ <= 0 then
    return
  end
  local questTrackVM = Z.VMMgr.GetVM("quest_track")
  if questTrackVM.CheckIsAllowReplaceTrack(true) then
    questTrackVM.ReplaceAndTrackingQuest(self.selectQuest_)
    self.questDetailVM_.CloseDetailView()
    questTrackVM.AfterSelectTrackQuestInView()
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
    Z.DialogViewDataMgr:CloseDialogView()
  end)
end

function Quest_detailView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onOwnItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onOwnItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onOwnItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.TrackingIdChange, self.onTrackingIdChange, self)
  Z.EventMgr:Add(Z.ConstValue.RoleLevelUp, self.onRoleLevelChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.StepFinish, self.onStepFinish, self)
end

function Quest_detailView:onOwnItemCountChange()
  self.limitComp_:CheckItemCountLimit()
  self.uiBinder.Ref:SetVisible(self.group_condition_explain_, #self.limitItems_ ~= 0)
end

function Quest_detailView:onRoleLevelChange()
  self.limitComp_:CheckRoleLv()
  self.uiBinder.Ref:SetVisible(self.group_condition_explain_, #self.limitItems_ ~= 0)
end

function Quest_detailView:onStepFinish()
  self.limitComp_:checkQuestStep()
  self.uiBinder.Ref:SetVisible(self.group_condition_explain_, #self.limitItems_ ~= 0)
end

function Quest_detailView:onTrackingIdChange()
  self.questtypeGroupList_ = self.questDetailVM_.GetQuestTypeGroupList()
  self.catalogueDatas_ = self.questDetailVM_.GetQuestDetailCatalogueDatas(self.questtypeGroupList_)
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
  self.lab_quest_name_.text = questRow.QuestName
  self.lab_quest_desc_.text = questRow.QuestDetail
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
  local goalIdx = self.questVM_.GetUncompletedGoalIndex(questContainerData.id)
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
    end
    self.lab_quest_target_tips_desc_.text = stepRow.StepMainTitle
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

function Quest_detailView:refreshTimeLimitUIByState(state)
  local questId = self.selectQuest_
  if questId == -1 then
    return
  end
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if questRow == nil then
    return
  end
  local questName = questRow.QuestName
  local content = questName
  if state == 0 then
    content = questName
  elseif state == 1 then
    content = Z.RichTextHelper.ApplyStyleTag(string.format("%s\227\128\144%s\227\128\145", questName, Lang("QuestTimeLimitStart")), E.TextStyleTag.Red)
  elseif state == 2 then
    content = Z.RichTextHelper.ApplyStyleTag(string.format("%s\227\128\144%s\227\128\145", questName, Lang("QuestTimeLimitEnd")), E.TextStyleTag.Red)
  end
  table.insert(self.limitItems_, {
    name = "TimeLimit",
    refreshUnitFunc = function(unit)
      unit.lab_special_explain.text = content
    end
  })
end

function Quest_detailView:refreshItemCountLimitUIByState(idx, state)
  local questId = self.selectQuest_
  if questId == -1 then
    return
  end
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if questRow then
    local unitStr = idx .. "ItemLimit"
    if state == 1 then
      local limitData = questRow.ContinueLimit[idx]
      local itemData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(tonumber(limitData[2]))
      if itemData == nil then
        return
      end
      local itemName = itemData.Name
      local minNum = tonumber(limitData[3])
      local param = {
        item = {name = itemName, num = minNum}
      }
      local desc = Lang("QuestItemLimit", param)
      table.insert(self.limitItems_, {
        name = unitStr,
        refreshUnitFunc = function(unit)
          unit.lab_special_explain.text = desc
        end
      })
    elseif state == 2 then
      self:clearLimitUnitByStr(unitStr)
    end
  end
end

function Quest_detailView:refreshDateLimit(idx, state, dateSce)
  if state == 1 then
    local unitStr = idx .. "date"
    table.insert(self.limitItems_, {
      name = unitStr,
      refreshUnitFunc = function(unit)
        unit.lab_special_explain.text = self:getDateLimitStr(dateSce)
        local timer = self.timerMgr:StartTimer(function()
          dateSce = dateSce - 1
          unit.lab_special_explain.text = self:getDateLimitStr(dateSce)
        end, 1, dateSce, true, function()
          if self.IsActive then
            self:clearLimitUnitByStr(unitStr)
            self.uiBinder.Ref:SetVisible(self.group_condition_explain_, #self.limitItems_ ~= 0)
          end
        end)
      end
    })
  end
end

function Quest_detailView:getDateLimitStr(dateSce)
  local hour, min, sec = Z.TimeTools.S2HMS(dateSce)
  local timestr
  if 0 < hour then
    timestr = Lang("Hour", {val = hour})
  elseif 0 < min then
    timestr = min .. Lang("Minute")
  else
    timestr = sec .. Lang("EquipSecondsText")
  end
  return Lang("remainderLimit", {str = timestr})
end

function Quest_detailView:refreshRoleLvLimit(idx, state, lv)
  if state == 1 then
    local unitStr = idx .. "LvLimit"
    table.insert(self.limitItems_, {
      name = unitStr,
      refreshUnitFunc = function(unit)
        unit.lab_special_explain.text = Lang("NeedRoleLevel", {lv = lv})
      end
    })
  end
end

function Quest_detailView:refreshQuestStepLimit(idx, state, questId)
  if state == 1 then
    local unitStr = idx .. "questStep"
    table.insert(self.limitItems_, {
      name = unitStr,
      refreshUnitFunc = function(unit)
        local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
        if questRow then
          unit.lab_special_explain.text = Lang("NeedAdvanceTaskStart", {
            str = questRow.QuestName
          })
        end
      end
    })
  end
end

function Quest_detailView:refreshLimit()
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearLimitUnit()
    self.timerMgr:Clear()
    self.limitComp_:Init(self.selectQuest_)
    for index, value in ipairs(self.limitItems_) do
      local name = value.name
      if name ~= nil then
        local unit = self:AsyncLoadUiUnit("ui/prefabs/quest/quest_target_condition_tpl", name, self.layout_list_condition_)
        if unit ~= nil and value.refreshUnitFunc ~= nil then
          value.refreshUnitFunc(unit)
        end
      end
    end
    self.uiBinder.Ref:SetVisible(self.group_condition_explain_, #self.limitItems_ ~= 0)
  end)()
end

function Quest_detailView:clearLimitUnit()
  for _, value in pairs(self.limitItems_) do
    self:RemoveUiUnit(value.name)
  end
  self.limitItems_ = {}
end

function Quest_detailView:clearLimitUnitByStr(unitStr)
  for i, value in pairs(self.limitItems_) do
    if unitStr == value.name then
      self:RemoveUiUnit(unitStr)
      table.remove(self.limitItems_, i)
      return
    end
  end
end

function Quest_detailView:startAnimatedShow()
  self.anim_:Restart(Z.DOTweenAnimType.Open)
end

function Quest_detailView:startAnimatedHide()
end

function Quest_detailView:RegisterInputActions()
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Quest)
end

function Quest_detailView:UnRegisterInputActions()
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Quest)
end

return Quest_detailView
