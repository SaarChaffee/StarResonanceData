local QuestionnaireNtfStubImpl = {}

function QuestionnaireNtfStubImpl:NotifyQuestionnaireFinish(call, request)
  local questionnaireVM = Z.VMMgr.GetVM("questionnaire")
  questionnaireVM.FinishQuestionnaire(request.questionnaireId)
end

return QuestionnaireNtfStubImpl
