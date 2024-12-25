local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")
local QuestGoalComp = require("ui.component.goal.quest_goal_comp")
local QuestLimitComp = require("ui.component.quest.quest_limit_comp")
local QuickUseComp = require("ui.component.mainui.quick_use_item_bar_comp")
local LimitEnum = {
  time = 1,
  itemCount = 2,
  date = 3,
  roleLv = 4,
  questStep = 5
}
local QuestTrackComp = class("QuestTrackComp")

function QuestTrackComp:ctor(parentView)
  self.parentView_ = parentView
  self.questVM_ = Z.VMMgr.GetVM("quest")
  self.questData_ = Z.DataMgr.Get("quest_data")
  self.questDetailVM_ = Z.VMMgr.GetVM("questdetail")
  self.questTimeLimitVM_ = Z.VMMgr.GetVM("quest_time_limit")
  self.goalList_ = {}
  for i = 1, 3 do
    self.goalList_[i] = QuestGoalComp.new(parentView, i, E.GoalUIType.TrackBar)
  end
  self.bShowLimit = 0
  self.limitComp_ = QuestLimitComp.new(parentView, {
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
      self:refreshQuestStep(idx, state, questId)
    end
  })
  self.quickUseItemComp_ = QuickUseComp.new(parentView)
  
  function self.onDungeonVarDataChange_()
    self:refreshLevelProgress()
  end
end

function QuestTrackComp:Init(uiBinder, questId)
  self.uiBinder_ = uiBinder
  self.timerMgr_ = self.parentView_.timerMgr
  self.trackingId_ = questId
  self.stateData_ = nil
  self.stateTimer_ = nil
  self.countDownTimer_ = nil
  self.stateQueue_ = {}
  self.bShowLimit = 0
  self:initUIComp()
  self.limitComp_:Init(self.trackingId_)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_explain, self:CheckLimitCompShow())
  self.quickUseItemComp_:Init(self.uiBinder_.cont_quest_item, E.ShortcutsItemType.Quest)
  for i = 1, #self.goalList_ do
    self.goalList_[i]:Init(self.uiBinder_["binder_goal_" .. i])
    self.goalList_[i]:SetQuestId(self.trackingId_)
  end
  self.uiBinder_.btn_bg:AddListener(function()
    self:onClickTrackBar()
  end)
  self.uiBinder_.btn_function:AddListener(function()
    self:onClickFunctionBtn()
  end)
  local dungeonVar = Z.ContainerMgr.DungeonSyncData.dungeonVar
  dungeonVar.Watcher:RegWatcher(self.onDungeonVarDataChange_)
  self:bindEvents()
  self:enterDefaultState()
end

function QuestTrackComp:initUIComp()
  self.group_task_progress_ = self.uiBinder_.group_task_event
  self.lab_task_progress_ = self.uiBinder_.lab_task_content
  self.slider_task_progress_ = self.uiBinder_.slider_task
  self.uiBinder_.Ref:SetVisible(self.group_task_progress_, false)
end

function QuestTrackComp:UnInit()
  self.uiBinder_.countdown_timelimit:EndTime()
  Z.EventMgr:RemoveObjAll(self)
  local dungeonVar = Z.ContainerMgr.DungeonSyncData.dungeonVar
  if dungeonVar ~= nil then
    dungeonVar.Watcher:UnregWatcher(self.onDungeonVarDataChange_)
  end
  for i = 1, #self.goalList_ do
    self.goalList_[i]:UnInit()
  end
  self.limitComp_:UnInit()
  self.quickUseItemComp_:UnInit()
  self.trackingId_ = nil
  self.viewState_ = nil
  self.stateData_ = nil
  self.stateQueue_ = nil
  self.stateTimer_ = nil
  self.countDownTimer_ = nil
  self.timerMgr_ = nil
  self.uiBinder_ = nil
end

function QuestTrackComp:AddTrackState(questId, viewState)
  local isNeedAdd = true
  for _, data in pairs(self.stateQueue_) do
    if data.questId == questId and data.viewState == viewState then
      isNeedAdd = false
    end
  end
  if not isNeedAdd then
    return
  end
  table.insert(self.stateQueue_, {questId = questId, viewState = viewState})
  self:refreshViewState()
end

function QuestTrackComp:ForceShowQuestTrackDetail()
  self.stateQueue_ = {}
  self:enterDefaultState()
end

function QuestTrackComp:SetTrackingId(id)
  self.trackingId_ = id or -1
  self:updateAllTargetView()
  self:refreshSelfVisible()
  self.timerMgr_:StopTimer(self.openTimer_)
  self.bShowLimit = 0
  self.limitComp_:Init(id)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_explain, self:CheckLimitCompShow())
  self:refreshViewState()
end

function QuestTrackComp:GetTrackingId()
  return self.trackingId_
end

function QuestTrackComp:RefreshCurrentTrackUI()
  if self.viewState_ ~= E.QuestTrackViewState.Detail then
    return
  end
  self:refreshCurrentTrackUI()
  local isShow = self:isCurrentTrack()
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.node_anim, isShow)
  if isShow then
    self.uiBinder_.anim:Restart(Z.DOTweenAnimType.Tween_1)
    self.uiBinder_.anim:Restart(Z.DOTweenAnimType.Open)
  end
end

function QuestTrackComp:refreshTimeLimitUIByState(state)
  if state == 0 then
    self:SetLimitCompShow(LimitEnum.time, false)
  elseif state == 1 then
    self:SetLimitCompShow(LimitEnum.time, true)
    self.uiBinder_.lab_special_explain.text = Lang("QuestTimeLimitStart")
  elseif state == 2 then
    self:SetLimitCompShow(LimitEnum.time, true)
    self.uiBinder_.lab_special_explain.text = Lang("QuestTimeLimitEnd")
  end
end

function QuestTrackComp:refreshItemCountLimitUIByState(idx, state)
  if state == 0 then
    self:SetLimitCompShow(LimitEnum.itemCount, false)
  elseif state == 1 then
    self:SetLimitCompShow(LimitEnum.itemCount, true)
    local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(self.trackingId_)
    if questRow then
      local limitData = questRow.ContinueLimit[1]
      local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(tonumber(limitData[2]))
      if itemRow then
        local itemName = itemRow.Name
        local minNum = tonumber(limitData[3])
        local param = {
          item = {name = itemName, num = minNum}
        }
        self.uiBinder_.lab_special_explain.text = Lang("QuestItemLimit", param)
      end
    end
  end
end

function QuestTrackComp:refreshDateLimit(idx, state, dateSce)
  if state == 1 then
    self:SetLimitCompShow(LimitEnum.date, true)
    self.uiBinder_.lab_special_explain.text = self:getDateLimitStr(dateSce)
    self.openTimer_ = self.timerMgr_:StartTimer(function()
      dateSce = dateSce - 1
      self.uiBinder_.lab_special_explain.text = self:getDateLimitStr(dateSce)
    end, 1, dateSce, true, function()
      self:SetLimitCompShow(LimitEnum.date, false)
      self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_explain, self:CheckLimitCompShow())
    end)
    self.uiBinder_.lab_special_explain.text = self:getDateLimitStr(dateSce)
  elseif state == 2 then
    self:SetLimitCompShow(LimitEnum.date, false)
  end
end

function QuestTrackComp:getDateLimitStr(dateSce)
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

function QuestTrackComp:refreshRoleLvLimit(idx, state, lv)
  if state == 1 then
    self:SetLimitCompShow(LimitEnum.roleLv, true)
    self.uiBinder_.lab_special_explain.text = Lang("NeedRoleLevel", {lv = lv})
  else
    self:SetLimitCompShow(LimitEnum.roleLv, false)
  end
end

function QuestTrackComp:refreshQuestStep(idx, state, questId)
  if state == 1 then
    self:SetLimitCompShow(LimitEnum.questStep, true)
    local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
    if questRow then
      self.uiBinder_.lab_special_explain.text = Lang("NeedAdvanceTaskStart", {
        str = questRow.QuestName
      })
    end
  else
    self:SetLimitCompShow(LimitEnum.questStep, false)
  end
end

function QuestTrackComp:refreshViewState()
  if #self.stateQueue_ == 0 then
    self:enterDefaultState()
  else
    self:setTrackViewState(self.stateQueue_[1])
  end
end

function QuestTrackComp:enterDefaultState()
  self:refreshSelfVisible()
  self:setTrackViewState({
    questId = self.trackingId_,
    viewState = E.QuestTrackViewState.Detail
  })
end

function QuestTrackComp:setTrackViewState(stateData)
  if self.stateData_ and self.stateData_.questId == stateData.questId and self.stateData_.viewState == stateData.viewState then
    return
  end
  self.stateData_ = stateData
  local viewState = stateData.viewState
  self.viewState_ = viewState
  self:resetStateUI()
  if viewState == E.QuestTrackViewState.Detail then
    self:enterTrackDetailState()
  elseif viewState == E.QuestTrackViewState.StepChange then
    self:enterStepChangeState()
  elseif viewState == E.QuestTrackViewState.Finish then
    self:enterQuestFinishState()
  elseif viewState == E.QuestTrackViewState.Fail then
    self:enterQuestFailState()
  end
  self:refreshQuestName(stateData.questId)
  self:refreshQuestItemBar()
  self:refreshFunctionIcon()
end

function QuestTrackComp:refreshSelfVisible()
  local isVisible = false
  if self.stateQueue_ and #self.stateQueue_ > 0 then
    isVisible = true
  elseif self.viewState_ ~= E.QuestTrackViewState.Detail then
    isVisible = true
  else
    local trackVM = Z.VMMgr.GetVM("quest_track")
    if trackVM.IsQuestShowTrackBar(self.trackingId_) then
      isVisible = true
    end
  end
  self.uiBinder_.Ref.UIComp:SetVisible(isVisible)
end

function QuestTrackComp:refreshQuestName(questId)
  local name = ""
  if 0 < questId then
    local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
    if questRow then
      name = questRow.QuestName
    end
  end
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_quest_name, name ~= "")
  self.uiBinder_.lab_quest_name.text = name
end

function QuestTrackComp:isCurrentTrack()
  return self.trackingId_ == self.questData_:GetQuestTrackingId()
end

function QuestTrackComp:refreshCurrentTrackUI()
  local isShow = self:isCurrentTrack()
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_line_1, isShow)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_trace_bg, isShow)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.layout_goal, isShow)
end

function QuestTrackComp:refreshLevelProgress()
  if self.trackingId_ == nil or self.trackingId_ == 0 then
    return
  end
  local stepRow = self:getStepConfig()
  if not stepRow then
    return nil
  end
  local progressBarInfos = stepRow:GetStepProgressBarsInfo()
  if not progressBarInfos or #progressBarInfos == 0 then
    self.uiBinder_.Ref:SetVisible(self.group_task_progress_, false)
    return
  end
  self:updateProgressBars(progressBarInfos)
end

function QuestTrackComp:getStepConfig()
  local quest = self.questData_:GetQuestByQuestId(self.trackingId_)
  if not quest then
    return nil
  end
  local stepConfig = self.questData_:GetStepConfigByStepId(quest.stepId)
  if not stepConfig then
    return nil
  end
  return stepConfig
end

function QuestTrackComp:updateProgressBars(progressBarInfos)
  local dungeonVm = Z.VMMgr.GetVM("dungeon")
  for _, progressBarInfo in ipairs(progressBarInfos) do
    if progressBarInfo.showBar then
      local curtValue = dungeonVm.GetDungeonValValue(progressBarInfo.initValue)
      if curtValue == "" or curtValue == nil then
        curtValue = 0
      else
        if type(curtValue) == "string" then
          curtValue = tonumber(curtValue)
        else
        end
      end
      local maxValue = tonumber(progressBarInfo.maxValue)
      if maxValue == nil or maxValue == 0 then
        logError("maxValue is nil or 0")
        return
      end
      curtValue = math.min(curtValue, maxValue)
      local progress = curtValue / maxValue
      self:updateLevelProgressBarUI(progressBarInfo, curtValue, maxValue, progress)
    else
      self.uiBinder_.Ref:SetVisible(self.group_task_progress_, false)
    end
  end
end

function QuestTrackComp:updateLevelProgressBarUI(progressBarInfo, curtValue, maxValue, progress)
  self.uiBinder_.Ref:SetVisible(self.group_task_progress_, true)
  self.lab_task_progress_.text = progressBarInfo.barName .. "( " .. curtValue .. "/" .. maxValue .. " )"
  self.slider_task_progress_.value = progress
end

function QuestTrackComp:switchStateAfterTime(sec)
  self.stateTimer_ = self.timerMgr_:StartTimer(function()
  end, sec, 1, nil, function()
    self.stateTimer_ = nil
    local data = table.remove(self.stateQueue_, 1)
    if data then
    end
    self:refreshViewState()
  end)
end

function QuestTrackComp:resetStateUI()
  self.timerMgr_:StopTimer(self.countDownTimer_)
  self.timerMgr_:StopTimer(self.stateTimer_)
  self:refreshSelfVisible()
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_detail, false)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_flow_tips, false)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_quest_result, false)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_quest_state, false)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_quest_update, false)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_quest_check, false)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_quest_fork, false)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_quest_time, false)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.node_anim, false)
  self.uiBinder_.Ref:SetVisible(self.group_task_progress_, false)
  self.uiBinder_.effect_flow:SetEffectGoVisible(false)
  self.uiBinder_.effect_complete:SetEffectGoVisible(false)
  self.uiBinder_.anim:Complete(Z.DOTweenAnimType.Tween_0)
  self.uiBinder_.anim:Complete(Z.DOTweenAnimType.Tween_1)
  self.uiBinder_.anim:Complete(Z.DOTweenAnimType.Tween_2)
  self.uiBinder_.effect_transform_2:SetEffectGoVisible(false)
end

function QuestTrackComp:enterTrackDetailState()
  self:showTrackDetail()
end

function QuestTrackComp:enterStepChangeState()
  self:showTrackDetail()
  self:switchStateAfterTime(1.5)
end

function QuestTrackComp:showTrackDetail()
  local quest = self.questData_:GetQuestByQuestId(self.trackingId_)
  if not quest then
    return
  end
  local questStepRow = self.questData_:GetStepConfigByStepId(quest.stepId)
  if questStepRow then
    if questStepRow.StepMainTitle == "" then
      self.uiBinder_.Ref:SetVisible(self.uiBinder_.layout_step_main_title, false)
    else
      self.uiBinder_.Ref:SetVisible(self.uiBinder_.layout_step_main_title, true)
    end
    self.uiBinder_.lab_step_main_title.text = questStepRow.StepMainTitle
  end
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_detail, true)
  self:refreshCurrentTrackUI()
  self:refreshLevelProgress()
  local questTimeLimitVM = Z.VMMgr.GetVM("quest_time_limit")
  if questTimeLimitVM.IsTimeLimitStepByStepId(quest.stepId) and self:isShowTimeCountDown() then
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_flow_tips, true)
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_quest_time, true)
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.node_anim, true)
    self.uiBinder_.anim:Restart(Z.DOTweenAnimType.Open)
    self:initCountDown()
  elseif self.viewState_ == E.QuestTrackViewState.StepChange then
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_quest_update, true)
    self.uiBinder_.anim:Restart(Z.DOTweenAnimType.Tween_0)
    self.uiBinder_.anim:Restart(Z.DOTweenAnimType.Tween_1)
    self.uiBinder_.audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.commonAudio_2)
  else
    local iconPath = self.questDetailVM_.GetStateIconByQuestId(self.trackingId_)
    if iconPath ~= "" then
      self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_quest_state, true)
      self.uiBinder_.img_quest_state:SetImage(iconPath)
      self.uiBinder_.anim:Restart(Z.DOTweenAnimType.Tween_2)
      self.uiBinder_.Ref:SetVisible(self.uiBinder_.node_anim, self:isCurrentTrack())
      if self:isCurrentTrack() then
        self.uiBinder_.anim:Restart(Z.DOTweenAnimType.Open)
      end
    end
  end
end

function QuestTrackComp:enterQuestFinishState()
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_quest_result, true)
  self.uiBinder_.lab_quest_result.text = string.format("<color=#%s>%s</color>", "D6F460", Lang("QuestEnd"))
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_quest_check, true)
  self.uiBinder_.effect_complete:SetEffectGoVisible(true)
  self.uiBinder_.audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.commonAudio_3)
  self:switchStateAfterTime(1.5)
end

function QuestTrackComp:enterQuestFailState()
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_quest_result, true)
  self.uiBinder_.lab_quest_result.text = string.format("<color=#%s>%s</color>", "FF7051", Lang("QuestFail"))
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_quest_fork, true)
  local isShow = self:isCurrentTrack()
  if isShow then
    self.uiBinder_.anim:Restart(Z.DOTweenAnimType.Tween_1)
  end
  self:switchStateAfterTime(1.5)
end

function QuestTrackComp:refreshQuestItemBar()
  if self.viewState_ ~= E.QuestTrackViewState.Detail then
    self.uiBinder_.cont_quest_item.Ref.UIComp:SetVisible(false)
    return
  end
  local itemConfigId = self.questData_:GetItemConfigIdByQuestId(self.trackingId_)
  self.quickUseItemComp_:SetItemConfigId(itemConfigId)
  if 0 < itemConfigId then
    self.uiBinder_.cont_quest_item.Ref.UIComp:SetVisible(true)
    Z.EventMgr:Add("InputUseQuestItem", self.onInputQuickUse, self)
  else
    self.uiBinder_.cont_quest_item.Ref.UIComp:SetVisible(false)
  end
  keyIconHelper.InitKeyIcon(self, self.uiBinder_.cont_quest_item.cont_key_icon, 28)
end

function QuestTrackComp:isShowTimeCountDown()
  local quest = self.questData_:GetQuestByQuestId(self.trackingId_)
  if not quest then
    return false
  end
  local stepTimeLimitInfo = self.questTimeLimitVM_.GetQuestStepTimeLimitInfo(quest)
  if stepTimeLimitInfo == nil or not stepTimeLimitInfo.IsShowUI then
    return false
  end
  return true
end

function QuestTrackComp:initCountDown()
  local quest = self.questData_:GetQuestByQuestId(self.trackingId_)
  if not quest then
    return
  end
  local endTime = quest.stepLimitTime
  local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local remainingSec = endTime - nowTime
  if remainingSec <= 0 then
    self.uiBinder_.countdown_timelimit:EndTime()
    return
  end
  local param = {
    time = {cd = "{0}"}
  }
  self.uiBinder_.countdown_timelimit:StartTime(remainingSec, Lang("QuestTimeLimitedStep", param))
end

function QuestTrackComp:onInputQuickUse()
  self.quickUseItemComp_:QuickUseItem()
end

function QuestTrackComp:refreshFunctionIcon()
  if self.viewState_ ~= E.QuestTrackViewState.Detail then
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.btn_function, false)
    return
  end
  local isVisible = false
  local quest = self.questData_:GetQuestByQuestId(self.trackingId_)
  if quest then
    local stepRow = self.questData_:GetStepConfigByStepId(quest.stepId)
    if stepRow then
      local funcId = stepRow.QuestClickJump
      if 0 < funcId then
        isVisible = true
        local functionRow = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(funcId)
        if functionRow then
          self.uiBinder_.img_icon_function:SetImage(functionRow.Icon)
        end
      end
    end
  end
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.btn_function, isVisible)
end

function QuestTrackComp:onClickFunctionBtn()
  local quest = self.questData_:GetQuestByQuestId(self.trackingId_)
  if quest then
    local stepRow = self.questData_:GetStepConfigByStepId(quest.stepId)
    if stepRow then
      local funcId = stepRow.QuestClickJump
      if 0 < funcId then
        local gotoVM = Z.VMMgr.GetVM("gotofunc")
        gotoVM.GoToFunc(funcId)
      end
    end
  end
end

function QuestTrackComp:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.UpdateAllTargetView, self.updateAllTargetView, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.TrackBarWidthChange, self.onTrackBarWidthChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.StepLimitTimeChange, self.onStepLimitTimeChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onOwnItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onOwnItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onOwnItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.RoleLevelUp, self.onRoleLevelChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.StepFinish, self.onStepFinish, self)
end

function QuestTrackComp:updateAllTargetView()
  self:refreshSelfVisible()
  for i = 1, #self.goalList_ do
    self.goalList_[i]:SetQuestId(self.trackingId_)
  end
end

function QuestTrackComp:onTrackBarWidthChange(questId)
  if self.stateData_.questId == questId then
    self:refreshQuestItemBar()
  end
end

function QuestTrackComp:OnInputTrackQuestKeyPressed()
  local questId = self.stateData_.questId
  if self.questData_:GetQuestTrackingId() ~= questId then
    return
  end
  self:onClickTrackBar()
end

function QuestTrackComp:onClickTrackBar()
  if self.stateData_.viewState ~= E.QuestTrackViewState.Detail then
    return
  end
  local questId = self.stateData_.questId
  if self.questData_:GetQuestTrackingId() ~= questId then
    local questTrackVM = Z.VMMgr.GetVM("quest_track")
    questTrackVM.ReplaceAndTrackingQuest(questId)
    return
  end
  local quest = self.questData_:GetQuestByQuestId(questId)
  if quest then
    local stepRow = self.questData_:GetStepConfigByStepId(quest.stepId)
    if stepRow then
      if stepRow.StepTips ~= "" then
        Z.TipsVM.OpenMessageViewByContext(stepRow.StepTips, E.TipsType.MiddleTips)
      end
      local funcId = stepRow.QuestClickJump
      if 0 < funcId then
        local gotoVM = Z.VMMgr.GetVM("gotofunc")
        gotoVM.GoToFunc(funcId)
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Quest.ClickTrackBar)
  Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnClickChangeGuideQuestId, questId)
end

function QuestTrackComp:onStepLimitTimeChange(quest)
  if quest.id == self.trackingId_ and self:isShowTimeCountDown() then
    self:initCountDown()
  end
end

function QuestTrackComp:onOwnItemCountChange(item)
  self.limitComp_:CheckItemCountLimit()
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_explain, self:CheckLimitCompShow())
end

function QuestTrackComp:onRoleLevelChange()
  self.limitComp_:CheckRoleLv()
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_explain, self:CheckLimitCompShow())
end

function QuestTrackComp:onStepFinish()
  self.limitComp_:checkQuestStep()
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_explain, self:CheckLimitCompShow())
end

function QuestTrackComp:onLanguageChange()
  self:refreshQuestName(self.stateData_.questId)
end

function QuestTrackComp:SetLimitCompShow(limitType, bShow)
  if bShow then
    self.bShowLimit = self.bShowLimit | 1 << limitType
  else
    self.bShowLimit = self.bShowLimit & ~(1 << limitType)
  end
end

function QuestTrackComp:CheckLimitCompShow()
  return self.bShowLimit ~= 0
end

return QuestTrackComp
