local super = require("ui.service.service_base")
local QuestionnaireService = class("QuestionnaireService", super)

function QuestionnaireService:OnInit()
end

function QuestionnaireService:OnUnInit()
end

function QuestionnaireService:OnLogin()
end

function QuestionnaireService:OnLogout()
end

function QuestionnaireService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    Z.CoroUtil.create_coro_xpcall(function()
      local questionnaireVM = Z.VMMgr.GetVM("questionnaire")
      questionnaireVM.AsyncGetQuestionnaireInfos()
    end)()
  end
end

return QuestionnaireService
