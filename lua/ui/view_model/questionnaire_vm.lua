local QuestionnaireVM = {}
local worldProxy = require("zproxy.world_proxy")
local UrlHelper = require("common.url_helper")

function QuestionnaireVM.OpenQuestionnaireView()
  Z.UIMgr:OpenView("questionnaire_banner_popup")
end

function QuestionnaireVM.OpenQuestionnaireUrl(url)
  if url == nil or url == "" then
    return
  end
  local accountData = Z.DataMgr.Get("account_data")
  if accountData.PlatformType == E.LoginPlatformType.TencentPlatform then
    logGreen("OpenQuestionnaire URL :" .. url)
    Z.SDKWebView.OpenWebView(url, true)
  elseif accountData.PlatformType == E.LoginPlatformType.APJPlatform then
    local c = UrlHelper.GetUrlMontageQueryStart(url)
    local userId = "userId=" .. Z.ContainerMgr.CharSerialize.charBase.charId
    url = string.zconcat(url, c, userId)
    logGreen("OpenQuestionnaire URL :" .. url)
    Z.SDKWebView.OpenWebView(url, false)
  end
end

function QuestionnaireVM.CheckQuestionnaireIsOpen(info, levelLimit, dayLimit)
  if not info.canAnswer then
    return false
  end
  if levelLimit == nil then
    levelLimit = Z.ContainerMgr.CharSerialize.roleLevel.level
  end
  if dayLimit == nil then
    local loginDayCounter = Z.Global.LoginDayCounter
    dayLimit = Z.ContainerMgr.CharSerialize.counterList.counterMap[loginDayCounter] and Z.ContainerMgr.CharSerialize.counterList.counterMap[loginDayCounter].counter or 0
  end
  if info and levelLimit and dayLimit and levelLimit >= info.levelLimit and dayLimit >= info.dayLimit then
    return true
  end
  return false
end

function QuestionnaireVM.FinishQuestionnaire(id)
  local tempStatus = Z.PbEnum("QuestionnaireStatus", "QuestionnaireAnswered")
  local questionnaireData = Z.DataMgr.Get("questionnaire_data")
  local infos = questionnaireData:GetAllQuestionnaireInfos()
  for _, value in ipairs(infos) do
    if value.id == id then
      value.status = tempStatus
      break
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.QuestionnaireInfosRefresh)
end

function QuestionnaireVM.GetAllOpenedQuestionnaireInfos()
  local infos = {}
  local level = Z.ContainerMgr.CharSerialize.roleLevel.level
  local loginDayCounter = Z.Global.LoginDayCounter
  local loginDays = Z.ContainerMgr.CharSerialize.counterList.counterMap[loginDayCounter] and Z.ContainerMgr.CharSerialize.counterList.counterMap[loginDayCounter].counter or 0
  local questionnaireData = Z.DataMgr.Get("questionnaire_data")
  local questionnaireInfos = questionnaireData:GetAllQuestionnaireInfos()
  for _, value in ipairs(questionnaireInfos) do
    if QuestionnaireVM.CheckQuestionnaireIsOpen(value, level, loginDays) then
      table.insert(infos, value)
    end
  end
  return infos
end

function QuestionnaireVM.GetQuestionnaireInfoById(id)
  local questionnaireData = Z.DataMgr.Get("questionnaire_data")
  local questionnaireInfos = questionnaireData:GetAllQuestionnaireInfos()
  for _, value in ipairs(questionnaireInfos) do
    if value.id == id then
      return value
    end
  end
  return nil
end

function QuestionnaireVM.GetNotAnsweredQuestionnaireInfos()
  local tempStatus = Z.PbEnum("QuestionnaireStatus", "QuestionnaireNotAnswered")
  local infos = {}
  local level = Z.ContainerMgr.CharSerialize.roleLevel.level
  local loginDayCounter = Z.Global.LoginDayCounter
  local loginDays = Z.ContainerMgr.CharSerialize.counterList.counterMap[loginDayCounter] and Z.ContainerMgr.CharSerialize.counterList.counterMap[loginDayCounter].counter or 0
  local questionnaireData = Z.DataMgr.Get("questionnaire_data")
  local questionnaireInfos = questionnaireData:GetAllQuestionnaireInfos()
  for _, value in ipairs(questionnaireInfos) do
    if QuestionnaireVM.CheckQuestionnaireIsOpen(value, level, loginDays) and value.status == tempStatus then
      table.insert(infos, value)
    end
  end
  return infos
end

function QuestionnaireVM.IsAllQuestionnaireEmailed()
  local tempStatus = Z.PbEnum("QuestionnaireStatus", "QuestionnaireEmailed")
  local isAllEmailed = true
  local level = Z.ContainerMgr.CharSerialize.roleLevel.level
  local loginDayCounter = Z.Global.LoginDayCounter
  local loginDays = Z.ContainerMgr.CharSerialize.counterList.counterMap[loginDayCounter] and Z.ContainerMgr.CharSerialize.counterList.counterMap[loginDayCounter].counter or 0
  local questionnaireData = Z.DataMgr.Get("questionnaire_data")
  local questionnaireInfos = questionnaireData:GetAllQuestionnaireInfos()
  for _, value in ipairs(questionnaireInfos) do
    if QuestionnaireVM.CheckQuestionnaireIsOpen(value, level, loginDays) and value.status ~= tempStatus then
      isAllEmailed = false
    end
  end
  return isAllEmailed
end

function QuestionnaireVM.IsHaveMainIconAndRedDot()
  local notAnsweredInfos = QuestionnaireVM.GetNotAnsweredQuestionnaireInfos()
  if 0 < #notAnsweredInfos then
    return true
  end
  return false
end

function QuestionnaireVM.CheckReply(reply)
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  else
    return true
  end
end

function QuestionnaireVM.AsyncGetQuestionnaireInfos()
  local questionnaireData = Z.DataMgr.Get("questionnaire_data")
  local request = {
    languageId = Z.LocalizationMgr:GetCurrentLanguage()
  }
  local reply = worldProxy.GetQuestionnaireList(request, questionnaireData.CancelSource:CreateToken())
  local result = QuestionnaireVM.CheckReply(reply.errCode)
  if result then
    questionnaireData:SyncContainerData(reply.questionnaires)
    Z.EventMgr:Dispatch(Z.ConstValue.QuestionnaireInfosRefresh)
  end
  return result
end

return QuestionnaireVM
