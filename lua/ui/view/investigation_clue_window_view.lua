local UI = Z.UI
local super = require("ui.ui_view_base")
local Investigation_clue_windowView = class("Investigation_clue_windowView", super)
local loop_list_view = require("ui.component.loop_list_view")
local investigation_clue_item = require("ui.component.investigation.investigation_clue_item")
local investigation_list_item = require("ui.component.investigation.investigation_list_item")
local animatorShow = "ui_anim_investigation_clue_window_fade_in_1"
local animatorStart = "ui_anim_investigation_clue_window_fade_in_start"
local IllationListMax = 3
local IllationClueListMax = 3
local InvestigationStepMax = 3
local ModelSizeCount = 3
E.InvestigationViewType = {EMainTitle = 1, EClue = 2}
E.InvestigationTipsType = {
  EErrorAnswer = 1,
  ECorrectAnswer = 2,
  ENotUnlockAllClue = 3,
  EUnlockClue = 4,
  ENewQuestion = 5,
  EReview = 6,
  ECompleteInvestigation = 7
}

function Investigation_clue_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "investigation_clue_window")
end

function Investigation_clue_windowView:OnActive()
  self:onInitComp()
  self:onInitData()
  self.investigationMainData_:InitInvestigationLocalData()
  self.investigationMainData_:UpdateInvestigationServerData()
  
  function self.onContainerChanged_(investigateList, dirtyKeys)
    self.investigationMainData_:UpdateInvestigationServerData()
    self:refreshShowInfo(true, false)
  end
  
  self:initInvestigationList()
  Z.ContainerMgr.CharSerialize.investigateList.Watcher:RegWatcher(self.onContainerChanged_)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
end

function Investigation_clue_windowView:OnDeActive()
  self.investigationScrollRect_:UnInit()
  self.clueScrollRect_:UnInit()
  Z.ContainerMgr.CharSerialize.investigateList.Watcher:UnregWatcher(self.onContainerChanged_)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.onContainerChanged_ = nil
end

function Investigation_clue_windowView:OnRefresh()
  self.uiBinder.anim:PlayOnce(animatorShow)
  self.timerMgr:StartTimer(function()
    self:refreshShowInfo(false, true)
  end, 0.6, 1)
end

function Investigation_clue_windowView:onInitComp()
  self.clueModel_ = nil
  self.clueModelTalkRoot_ = nil
  self.clueModelTalkLab_ = nil
end

function Investigation_clue_windowView:onInitData()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self.investigationScrollRect_ = loop_list_view.new(self, self.uiBinder.event_list, investigation_list_item, "investigation_list_tpl")
  self.investigationScrollRect_:Init({})
  self.clueScrollRect_ = loop_list_view.new(self, self.uiBinder.clue_list, investigation_clue_item, "investigation_clue_tpl")
  self.clueScrollRect_:Init({})
  self.investigationClueVm_ = Z.VMMgr.GetVM("investigationclue")
  self.investigationMainData_ = Z.DataMgr.Get("investigationclue_data")
  self:AddAsyncClick(self.uiBinder.btn_return, function()
    if self.showType_ == E.InvestigationViewType.EClue then
      self.showType_ = E.InvestigationViewType.EMainTitle
      self:refreshShowInfo(false, false)
    else
      Z.UIMgr:CloseView("investigation_clue_window")
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_open_clue, function()
    self.showType_ = E.InvestigationViewType.EClue
    self.investigationMainData_:RefreshStepIndex()
    self:refreshShowInfo(false, false)
    Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnGuideEvnet, string.zconcat(E.SteerGuideEventType.Investigation, "=", 1))
  end)
  self:AddAsyncClick(self.uiBinder.btn_review, function()
    self.showType_ = E.InvestigationViewType.EClue
    self.investigationMainData_:RefreshStepIndex()
    self:refreshShowInfo(false, false)
  end)
  self:AddClick(self.uiBinder.btn_help, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(30008)
  end)
  self.investigationDropDownLsit_ = {
    Lang("InvestigationSelectAll"),
    Lang("InvestigationSelectNotComplete"),
    Lang("InvestigationSelectComplete"),
    Lang("InvestigationSelectLock")
  }
  self.uiBinder.down_drop:ClearOptions()
  self.uiBinder.down_drop:AddOptions(self.investigationDropDownLsit_)
  self.uiBinder.down_drop:AddListener(function(index)
    if 0 <= index then
      self:refreshInvestigationByDownDrop(index)
    end
  end, true)
  self.selectListType_ = E.InvestigationListType.EAll
  self.showType_ = E.InvestigationViewType.EMainTitle
  self.tipsList_ = {}
  self.isShowTips_ = false
  self.clueErrorCount_ = 0
  self:AddAsyncClick(self.uiBinder.btn_left, function()
    self:onClickLeftStep()
  end)
  self:AddAsyncClick(self.uiBinder.btn_right, function()
    self:onClickRightStep()
  end)
  self:initPlayerModelBubble()
  self.uiBinder.anim:PlayOnce(animatorStart)
  self.uiBinder.Ref:SetVisible(self.uiBinder.anim_empty, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_event, true)
end

function Investigation_clue_windowView:refreshShowInfo(isUpdateData, isFirst)
  if self.showType_ == E.InvestigationViewType.EMainTitle then
    self:refreshMainView(isFirst)
  else
    self:refreshClueView(isUpdateData, false)
  end
end

function Investigation_clue_windowView:refreshMainView(isFirst)
  if self.uiBinder.group_clue.alpha == 1 and isFirst == false then
    self.uiBinder.anim_tween:Restart(Z.DOTweenAnimType.Tween_3)
    Z.Delay(0.2, ZUtil.ZCancelSource.NeverCancelToken)
  end
  if self.uiBinder.group_event.alpha == 0 and isFirst == false then
    self.uiBinder.anim_tween:Restart(Z.DOTweenAnimType.Tween_0)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_event, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_clue, false)
  self:refreshInvestigationList(isFirst)
end

function Investigation_clue_windowView:initInvestigationList()
  local list = self.investigationMainData_:GetInvestigationList(self.selectListType_)
  self.investigationScrollRect_:RefreshListView(list, false)
  if 0 < #list then
    self.investigationScrollRect_:SetSelected(1)
    self:OnSelectInvestigation(list[1].InvestigationId)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_event, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_clue, false)
end

function Investigation_clue_windowView:refreshInvestigationList(isFirst)
  local list = self.investigationMainData_:GetInvestigationList(self.selectListType_)
  if not isFirst then
    self.investigationScrollRect_:RefreshListView(list, false)
  end
  if 0 < #list then
    if not isFirst then
      self.investigationScrollRect_:SetSelected(1)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_empty, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.anim_empty, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_right, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_event, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.anim_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_right, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_event, false)
  end
end

function Investigation_clue_windowView:refreshInvestigationByDownDrop(idx)
  if 0 <= idx and idx < E.InvestigationListType.ELock then
    self.selectListType_ = idx + 1
    self:refreshInvestigationList()
  end
end

function Investigation_clue_windowView:refreshInvestigationRightShowData(investigationId)
  local investigationsTableRow = self.investigationMainData_:GetInvestigationTable(investigationId)
  if not investigationsTableRow then
    return
  end
  local state = self.investigationMainData_:GetInvestigationState(investigationId)
  if state == E.InvestigationState.ELock then
    self:refreshInvestigationRightImg(true, false, false, false, "")
    self:refreshInvestigationRightLab(true, investigationsTableRow.IockedTips, "", "")
    self:refreshInvestigationRightBtn(false, false)
  elseif state == E.InvestigationState.EUnLock or state == E.InvestigationState.EComplete then
    self:refreshInvestigationRightImg(false, false, true, true, investigationsTableRow.ThemePic)
    self:refreshInvestigationRightLab(false, "", investigationsTableRow.InvestigationTheme, investigationsTableRow.ThemeIntroduction)
    self:refreshInvestigationRightBtn(true, false)
  elseif state == E.InvestigationState.EFinish then
    self:refreshInvestigationRightImg(false, true, false, true, investigationsTableRow.ThemePic)
    self:refreshInvestigationRightLab(false, "", investigationsTableRow.InvestigationTheme, investigationsTableRow.ThemeIntroduction)
    self:refreshInvestigationRightBtn(false, true)
  end
end

function Investigation_clue_windowView:refreshInvestigationRightImg(isLock, isComplete, isFrame, isUnlock, unlockImg)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_lock, isLock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_complete, isComplete)
  if isComplete then
    self.uiBinder.anim_tween:Restart(Z.DOTweenAnimType.Tween_6)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_frame, isFrame)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_unlock, isUnlock)
  if unlockImg and unlockImg ~= "" then
    self.uiBinder.rimg_unlock:SetImage(unlockImg)
  end
end

function Investigation_clue_windowView:refreshInvestigationRightLab(isLock, lockLab, unLockTheme, unLockDesc)
  self.uiBinder.Ref:SetVisible(self.uiBinder.look_tips, isLock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.unlock_tips, not isLock)
  self.uiBinder.look_tips_lab.text = lockLab
  self.uiBinder.unlock_tips_lab.text = unLockTheme
  self.uiBinder.unlock_tips_desc.text = unLockDesc
end

function Investigation_clue_windowView:refreshInvestigationRightBtn(isClue, isReview)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_open_clue, isClue)
  self.uiBinder.btn_open_clue.IsDisabled = not isClue
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_review, isReview)
  self.uiBinder.btn_review.IsDisabled = not isReview
end

function Investigation_clue_windowView:OnSelectInvestigation(investigationId)
  self.investigationMainData_:SetCurInvestigationId(investigationId)
  self:refreshInvestigationRightShowData(investigationId)
  self.clueErrorCount_ = 0
end

function Investigation_clue_windowView:refreshClueView(isUpdateData, isChangeStep)
  local isMainViewVisible = self.uiBinder.group_event.alpha == 1
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_event, false)
  if isMainViewVisible == true and isChangeStep == false then
    self.uiBinder.anim_tween:Restart(Z.DOTweenAnimType.Tween_1)
  end
  local isClueViewVisible = self.uiBinder.group_clue.alpha == 1
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_clue, true)
  if isChangeStep then
    self.uiBinder.anim_tween:Restart(Z.DOTweenAnimType.Tween_8)
    Z.Delay(0.2, ZUtil.ZCancelSource.NeverCancelToken)
  elseif isClueViewVisible == false then
    self.uiBinder.anim_tween:Restart(Z.DOTweenAnimType.Tween_2)
  end
  if isUpdateData == false then
    self:clearIllationEffect()
  end
  self:refreshStepBtnOnStepIndexChange()
  local investigationStepData = self.investigationMainData_:GetCurInvestigationStepData()
  if investigationStepData == nil then
    return
  end
  local investigationsTableRow = self.investigationMainData_:GetInvestigationTable(self.investigationMainData_:GetCurInvestigationId())
  if not investigationsTableRow then
    return
  end
  self.uiBinder.lab_clue_title.text = investigationsTableRow.InvestigationTheme
  self:refreshClueList(investigationStepData.ClueList)
  local unlockClueId = 0
  local isAllClueUnlock = true
  for i = 1, #investigationStepData.ClueList do
    if investigationStepData.ClueList[i].IsUnlock == false then
      isAllClueUnlock = false
    end
    if unlockClueId == 0 and investigationStepData.ClueList[i].IsShowUnlockTips == true then
      unlockClueId = investigationStepData.ClueList[i].ClueId
      investigationStepData.ClueList[i].IsShowUnlockTips = false
    end
    if unlockClueId ~= 0 then
      investigationStepData.ClueList[i].IsShowUnlockTips = false
    end
  end
  local showNewQuestionId = self:isShowNewQuestionTips(investigationStepData)
  if true == isAllClueUnlock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_illation, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
    self:refreshIllationList(investigationStepData.IllationList, investigationStepData.AnswerContentList, isUpdateData)
    self.isShowAnim_ = false
  else
    if self.uiBinder.node_empty.alpha == 0 then
      self.uiBinder.anim_tween:Restart(Z.DOTweenAnimType.Open)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_illation, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, true)
  end
  if investigationStepData.IsComplete and isUpdateData == false then
    self:showStepTips(investigationStepData.StepId, E.InvestigationTipsType.EReview)
  elseif showNewQuestionId ~= 0 and true == isAllClueUnlock then
    self:showInferenceStepTips(showNewQuestionId, E.InvestigationTipsType.ENewQuestion)
  elseif unlockClueId ~= 0 then
    self:showClueTips(unlockClueId, E.InvestigationTipsType.EUnlockClue)
  elseif isAllClueUnlock == false then
    self:showStepTips(investigationStepData.StepId, E.InvestigationTipsType.ENotUnlockAllClue)
  end
  self:refreshConclusion(isUpdateData)
  if isChangeStep then
    self.uiBinder.anim_tween:Restart(Z.DOTweenAnimType.Tween_7)
  end
end

function Investigation_clue_windowView:checkQuickReasoning(stepId)
  local investigationStepTableRow = self.investigationMainData_:GetInvestigationStepTable(stepId)
  if investigationStepTableRow and investigationStepTableRow.QuickReasoning then
    self:AddAsyncClick(self.uiBinder.btn_survey, function()
      self:quickReasoningClick()
    end)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_not, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_survey, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_not, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_survey, false)
  end
end

function Investigation_clue_windowView:playAnimated(callback)
  if self.clickQuickBtn_ then
    return
  end
  self.clickQuickBtn_ = true
  self.uiBinder.anim_tween:CoroPlay(Z.DOTweenAnimType.Tween_9, callback, function(err)
    if err ~= nil then
      logError("CoroPlay err={0}", err)
    end
    callback()
  end)
end

function Investigation_clue_windowView:quickReasoningClick()
  self:playAnimated(function()
    self.clickQuickBtn_ = false
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("QuickReasoning"), function()
      self.isShowAnim_ = true
      self:asyncQuickReasoningAllClue()
      Z.DialogViewDataMgr:CloseDialogView()
    end)
  end)
end

function Investigation_clue_windowView:asyncQuickReasoningAllClue()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_survey, false)
  local investigationId = self.investigationMainData_:GetCurInvestigationId()
  local stepData = self.investigationMainData_:GetCurInvestigationStepData()
  if stepData and not stepData.IsComplete then
    self.investigationClueVm_.AsyncSelectReasoning(investigationId, stepData.StepId, 0, 0, self.cancelSource:CreateToken())
  end
end

function Investigation_clue_windowView:isShowNewQuestionTips(investigationStepData)
  for i = 1, #investigationStepData.IllationList do
    if false == investigationStepData.IllationList[i].IsComplete then
      for j = 1, #investigationStepData.IllationList[i].AnswerList do
        if investigationStepData.IllationList[i].AnswerList[j].IsComplete then
          return 0
        end
      end
      return investigationStepData.IllationList[i].IllationId
    end
  end
  return 0
end

function Investigation_clue_windowView:showInferenceStepTips(inferenceStepId, type)
  local inferenceStepTable = self.investigationMainData_:GetInferenceStepTable(inferenceStepId)
  if inferenceStepTable == nil then
    return
  end
  if type == E.InvestigationTipsType.ENewQuestion then
    self:showModelActionTips(inferenceStepTable.QuestionBubbleAction, inferenceStepTable.QuestionBubble, E.InvestigationTipsType.ENewQuestion)
  elseif type == E.InvestigationTipsType.EErrorAnswer then
    self:randomShowModelActionTips(inferenceStepTable.WrongBubbleAction, inferenceStepTable.WrongBubble, E.InvestigationTipsType.EErrorAnswer)
  end
end

function Investigation_clue_windowView:showClueTips(clueId, type, bubble)
  local investigationClueTableRow = self.investigationMainData_:GetClueTable(clueId)
  if investigationClueTableRow == nil then
    return
  end
  if type == E.InvestigationTipsType.EUnlockClue then
    self:showModelActionTips(investigationClueTableRow.UnlockedBubbleAction, investigationClueTableRow.UnlockedBubble, E.InvestigationTipsType.EUnlockClue)
  elseif type == E.InvestigationTipsType.ECorrectAnswer then
    local action = self:getRandomInfo(investigationClueTableRow.TapBubbleAction)
    self:showModelActionTips(action, bubble, E.InvestigationTipsType.ECorrectAnswer)
  end
end

function Investigation_clue_windowView:showStepTips(stepId, type)
  local investigationStepTableRow = self.investigationMainData_:GetInvestigationStepTable(stepId)
  if not investigationStepTableRow then
    return
  end
  if type == E.InvestigationTipsType.ECompleteInvestigation then
    self:showModelActionTips(investigationStepTableRow.ConclusionAction, investigationStepTableRow.ConclusionBubble, E.InvestigationTipsType.ECompleteInvestigation)
  elseif type == E.InvestigationTipsType.EReview then
    self:randomShowModelActionTips(investigationStepTableRow.ReviewBubbleAction, investigationStepTableRow.ReviewBubble, E.InvestigationTipsType.EReview)
  elseif type == E.InvestigationTipsType.ENotUnlockAllClue then
    self:randomShowModelActionTips(investigationStepTableRow.IockedBubbleAction, investigationStepTableRow.IockedBubble, E.InvestigationTipsType.ENotUnlockAllClue)
  end
end

function Investigation_clue_windowView:OnSelectClueAnswer(clueId, answerId, bubble)
  local stepData = self.investigationMainData_:GetCurInvestigationStepData()
  if not stepData then
    return
  end
  local illation
  for i = 1, #stepData.IllationList do
    if stepData.IllationList[i].IsComplete == false then
      illation = stepData.IllationList[i]
      break
    end
  end
  if illation == nil then
    return
  end
  local selectAnswerId = tonumber(answerId)
  local isNeedAnswer = false
  local needAnswerCount = 0
  local needSelectAnswerId = 0
  local needSelectIndex = 0
  for i = 1, #illation.AnswerList do
    local answerData = illation.AnswerList[i]
    if selectAnswerId == answerData.AnswerId then
      if true == answerData.IsComplete then
        return
      end
      isNeedAnswer = true
    end
    if false == answerData.IsComplete then
      needAnswerCount = needAnswerCount + 1
      if needSelectAnswerId == 0 then
        needSelectAnswerId = answerData.AnswerId
        needSelectIndex = i
      end
    end
  end
  if true == isNeedAnswer then
    self:showClueTips(clueId, E.InvestigationTipsType.ECorrectAnswer, bubble)
    Z.CoroUtil.create_coro_xpcall(function()
      self.clueErrorCount_ = 0
      self:asyncSelectReasion(stepData, illation.IllationId, selectAnswerId)
    end)()
  elseif 0 < needSelectAnswerId and self:checkErrorCount() then
    local needSelectClueId, needSelectBubble = self:getNeedSelectInfo(stepData, needSelectAnswerId)
    self:showClueTips(needSelectClueId, E.InvestigationTipsType.ECorrectAnswer, needSelectBubble)
    Z.CoroUtil.create_coro_xpcall(function()
      self.clueErrorCount_ = 0
      self:asyncSelectReasion(stepData, illation.IllationId, needSelectAnswerId)
    end)()
  else
    self.clueErrorCount_ = self.clueErrorCount_ + 1
    self:showInferenceStepTips(illation.IllationId, E.InvestigationTipsType.EErrorAnswer)
  end
end

function Investigation_clue_windowView:onPlayAudio()
  self.uiBinder.group_audio:Play()
end

function Investigation_clue_windowView:asyncSelectReasion(stepData, illationId, answerId)
  local investigationId = self.investigationMainData_:GetCurInvestigationId()
  local ret = self.investigationClueVm_.AsyncSelectReasoning(investigationId, stepData.StepId, illationId, answerId, self.cancelSource:CreateToken())
  if ret == 0 then
    self:onPlayAudio()
    self.clueErrorCount_ = 0
    if true == stepData.IsComplete then
      self:showStepTips(stepData.StepId, E.InvestigationTipsType.ECompleteInvestigation)
    end
  else
    Z.TipsVM.ShowTips(ret)
  end
end

function Investigation_clue_windowView:getNeedSelectInfo(stepData, needSelectAnswerId)
  for i = 1, #stepData.ClueList do
    local clueData = stepData.ClueList[i]
    for j = 1, #clueData.ClueAnswerList do
      local keyData = clueData.ClueAnswerList[j]
      if keyData.AnswerId == needSelectAnswerId then
        return clueData.ClueId, keyData.TapBubble
      end
    end
  end
end

function Investigation_clue_windowView:onClickLeftStep()
  local stepIndex = self.investigationMainData_:GetCurStepIndex()
  self:changeStepIndex(stepIndex - 1)
end

function Investigation_clue_windowView:onClickRightStep()
  local stepIndex = self.investigationMainData_:GetCurStepIndex()
  self:changeStepIndex(stepIndex + 1)
end

function Investigation_clue_windowView:changeStepIndex(index)
  local stepMax = self.investigationMainData_:GetCurStepIndexMax()
  if index <= 0 or index > stepMax then
    return
  end
  self.investigationMainData_:SetCurStepIndex(index)
  self:refreshClueView(false, true)
end

function Investigation_clue_windowView:refreshClueList(clueList)
  self.clueScrollRect_:RefreshListView(clueList, false)
  self.clueScrollRect_:ClearAllSelect()
end

function Investigation_clue_windowView:refreshIllationList(illationList, answerContentList, isUpdateData)
  local isShowNextIllation = true
  for i = 1, IllationListMax do
    if i > #illationList or false == isShowNextIllation then
      self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("group_illation_0", i)], false)
    else
      if false == illationList[i].IsComplete then
        isShowNextIllation = false
        if true == isUpdateData and self.uiBinder[string.zconcat("group_illation_0", i)].alpha == 0 then
          if i == 1 then
            self.uiBinder.illation_tween:Restart(Z.DOTweenAnimType.Tween_1)
          elseif i == 2 then
            self.uiBinder.illation_tween:Restart(Z.DOTweenAnimType.Tween_2)
          else
            self.uiBinder.illation_tween:Restart(Z.DOTweenAnimType.Tween_3)
          end
        end
      end
      self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("group_illation_0", i)], true)
      self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("group_illation", i)], true)
      self:refreshIllationByIndex(i, illationList[i], answerContentList, isUpdateData)
    end
  end
end

function Investigation_clue_windowView:refreshIllationByIndex(index, illation, answerContentList, isUpdateData)
  local inferenceStepTable = self.investigationMainData_:GetInferenceStepTable(illation.IllationId)
  if inferenceStepTable == nil then
    return
  end
  self.uiBinder[string.zconcat("lab_illation_content", index)].text = inferenceStepTable.Question
  for i = 1, IllationClueListMax do
    self.uiBinder[string.zconcat("effect_", index, i)]:SetEffectGoVisible(false)
    if i > #inferenceStepTable.Answer then
      self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("group_investigation_illation_", index, i)], false)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("group_investigation_illation_", index, i)], true)
      if i <= #illation.AnswerList and illation.AnswerList[i].IsComplete == true then
        local isUnlock = self.uiBinder[string.zconcat("img_lab_bg_", index, i)].alpha == 1
        self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("img_ask_", index, i)], false)
        self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("img_lab_bg_", index, i)], true)
        if answerContentList[inferenceStepTable.Answer[i]] then
          self.uiBinder[string.zconcat("lab_answer_", index, i)].text = answerContentList[inferenceStepTable.Answer[i]].answerContext
        end
        if isUnlock == false and isUpdateData == true or self.isShowAnim_ then
          self.uiBinder[string.zconcat("group_investigation_illation_", index, i)]:Restart(Z.DOTweenAnimType.Open)
          self.uiBinder[string.zconcat("effect_", index, i)]:SetEffectGoVisible(true)
        else
          self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("lab_answer_", index, i)], true)
        end
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("img_ask_", index, i)], true)
        self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("img_lab_bg_", index, i)], false)
        self.uiBinder[string.zconcat("lab_answer_", index, i)].text = ""
      end
    end
  end
end

function Investigation_clue_windowView:clearIllationEffect()
  for i = 1, IllationListMax do
    for j = 1, IllationClueListMax do
      self.uiBinder[string.zconcat("effect_", i, j)]:SetEffectGoVisible(false)
    end
  end
end

function Investigation_clue_windowView:refreshConclusion(isUpdateData)
  local investigationStepData = self.investigationMainData_:GetCurInvestigationStepData()
  if investigationStepData == nil then
    return
  end
  local isCompleteIllation = true
  for i = 1, #investigationStepData.IllationList do
    if investigationStepData.IllationList[i].IsComplete == false then
      isCompleteIllation = false
      break
    end
  end
  local investigationStepTableRow = self.investigationMainData_:GetInvestigationStepTable(investigationStepData.StepId)
  if not investigationStepTableRow then
    return
  end
  if isCompleteIllation == false then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_complete, false)
    if investigationStepTableRow and investigationStepTableRow.QuickReasoning then
      self:AddAsyncClick(self.uiBinder.btn_survey, function()
        self:quickReasoningClick()
      end)
      local isAllUnlock = true
      for i = 1, #investigationStepData.ClueList do
        if investigationStepData.ClueList[i].IsUnlock == false then
          isAllUnlock = false
          break
        end
      end
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_not, not isAllUnlock)
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_survey, isAllUnlock)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_not, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_survey, false)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_survey, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_not, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, true)
    self.uiBinder.lab_content.text = investigationStepTableRow.Conclusion
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_complete, true)
    self.uiBinder.lab_tips.text = investigationStepTableRow.ConclusionTips
    if isUpdateData then
      self.uiBinder.group_panel:Restart(Z.DOTweenAnimType.Open)
    end
  end
end

function Investigation_clue_windowView:refreshStepBtnOnStepIndexChange()
  local stepIndex = self.investigationMainData_:GetCurStepIndex()
  self.investigationMainData_:RefreshStepMax()
  local stepMax = self.investigationMainData_:GetCurStepIndexMax()
  for i = 1, InvestigationStepMax do
    if i > stepMax then
      self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("btn_dot", i)], false)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("btn_dot", i)], true)
      if i == stepIndex then
        self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("img_on", i)], true)
        self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("img_off", i)], false)
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("img_on", i)], false)
        self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("img_off", i)], true)
      end
    end
  end
  if stepIndex == 1 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_left, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_left, true)
  end
  if stepIndex == stepMax then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_right, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_right, true)
  end
end

function Investigation_clue_windowView:initPlayerModelBubble()
  local modelSize = Z.ContainerMgr.CharSerialize.charBase.bodySize
  for i = 1, ModelSizeCount do
    local isSizeOk = i == modelSize
    self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("node_model_talk", i)], isSizeOk)
    if isSizeOk then
      self.clueModel_ = self.uiBinder[string.zconcat("clue_model", i)]
      self.clueModelTalkRoot_ = self.uiBinder[string.zconcat("group_talk", i)]
      self.clueModelTalkLab_ = self.uiBinder[string.zconcat("lab_talk", i)]
    end
  end
  self.uiBinder.Ref:SetVisible(self.clueModelTalkRoot_, false)
  Z.CoroUtil.create_coro_xpcall(function()
    local charId = Z.ContainerMgr.CharSerialize.charBase.charId
    local socialVM = Z.VMMgr.GetVM("social")
    local socialData = socialVM.AsyncGetSocialData(0, charId, self.cancelSource:CreateToken())
    self.model_ = Z.ModelManager:GenModelByLuaSocialData(socialData)
    if self.model_ then
      self.clueModel_:SetModel(self.model_)
    end
  end)()
end

function Investigation_clue_windowView:randomShowModelActionTips(actionArray, bubbleArray, type)
  local action
  if actionArray then
    action = self:getRandomInfo(actionArray)
  end
  local bubble
  if bubbleArray then
    bubble = self:getRandomInfo(bubbleArray)
  end
  self:showModelActionTips(action, bubble, type)
end

function Investigation_clue_windowView:getRandomInfo(dataArray)
  if not dataArray or #dataArray == 0 then
    return
  end
  local randomIndex = 1
  if 1 < #dataArray then
    randomIndex = math.random(1, #dataArray)
  end
  return dataArray[randomIndex]
end

function Investigation_clue_windowView:showModelActionTips(action, bubble, type)
  if type == E.InvestigationTipsType.ECompleteInvestigation then
    if self.timer_ then
      self.timer_:Stop()
      self.timer_ = nil
    end
    local tipsInfo = {}
    tipsInfo.Action = action
    tipsInfo.Bubble = bubble
    tipsInfo.Type = type
    self.tipsList_ = {tipsInfo}
    self:startShowTips()
    return
  end
  if #self.tipsList_ > 0 then
    local lastData = self.tipsList_[1]
    if lastData.Type == E.InvestigationTipsType.ECompleteInvestigation then
      return
    end
    lastData = self.tipsList_[#self.tipsList_]
    if lastData.Type == type then
      lastData.Bubble = bubble
      if #self.tipsList_ == 1 then
        self:setShowTipsContext(bubble)
      end
    else
      local tipsInfo = {}
      tipsInfo.Action = action
      tipsInfo.Bubble = bubble
      tipsInfo.Type = type
      self.tipsList_[#self.tipsList_ + 1] = tipsInfo
    end
  else
    local tipsInfo = {}
    tipsInfo.Action = action
    tipsInfo.Bubble = bubble
    tipsInfo.Type = type
    self.tipsList_[1] = tipsInfo
    self:startShowTips()
  end
end

function Investigation_clue_windowView:startShowTips()
  self:checkShowTips()
  local cdTime = 2
  local funcFinish = function()
    self.timer_ = nil
    table.remove(self.tipsList_, 1)
    if #self.tipsList_ > 0 then
      self:startShowTips()
    else
      self.uiBinder.Ref:SetVisible(self.clueModelTalkRoot_, false)
    end
  end
  self.timer_ = self.timerMgr:StartTimer(function()
  end, cdTime, nil, nil, funcFinish)
end

function Investigation_clue_windowView:checkShowTips()
  if #self.tipsList_ == 0 then
    self.uiBinder.Ref:SetVisible(self.clueModelTalkRoot_, false)
    return
  end
  if self.tipsList_[1].Bubble and self.tipsList_[1].Bubble ~= "" then
    self:setShowTipsContext(self.tipsList_[1].Bubble)
    self.uiBinder.Ref:SetVisible(self.clueModelTalkRoot_, true)
  end
  if self.tipsList_[1].Action and 0 < self.tipsList_[1].Action then
    local actionId = tonumber(self.tipsList_[1].Action)
    local actionRow = Z.TableMgr.GetTable("ActionTableMgr").GetRow(actionId)
    if self.model_ and actionRow then
      local actionData = Z.AnimBaseData.Rent(actionRow.ActionEffect)
      self.model_:SetLuaAttr(Z.ModelAttr.EModelAnimBase, actionData)
    end
  end
end

function Investigation_clue_windowView:setShowTipsContext(context)
  if context then
    self.clueModelTalkLab_.text = context
  else
    self.clueModelTalkLab_.text = ""
  end
end

function Investigation_clue_windowView:checkErrorCount()
  local curData = self.investigationMainData_:GetCurInvestigationData()
  if curData.Guarantee and self.clueErrorCount_ >= curData.Guarantee then
    return true
  else
    return false
  end
end

return Investigation_clue_windowView
