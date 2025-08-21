local super = require("ui.model.data_base")
local QuestionnaireData = class("QuestionnaireData", super)

function QuestionnaireData:ctor()
  super.ctor(self)
  self:ResetData()
end

function QuestionnaireData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function QuestionnaireData:UnInit()
  self.CancelSource:Recycle()
end

function QuestionnaireData:Clear()
end

function QuestionnaireData:OnReconnect()
end

function QuestionnaireData:ResetData()
  self.questionnaireInfos_ = {}
end

function QuestionnaireData:SyncContainerData(containerData)
  self.questionnaireInfos_ = containerData
end

function QuestionnaireData:GetAllQuestionnaireInfos()
  return self.questionnaireInfos_
end

return QuestionnaireData
