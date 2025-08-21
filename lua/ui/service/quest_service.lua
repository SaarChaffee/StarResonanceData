local super = require("ui.service.service_base")
local QuestService = class("QuestService", super)

function QuestService:OnInit()
  function self.onDeactiveAll_()
    local talkData = Z.DataMgr.Get("talk_data")
    
    talkData:ClearPlayFlowInfo()
  end
  
  Z.EventMgr:Add(Z.ConstValue.NpcTalk.NpcQuestTalkFlowChange, self.onNpcQuestTalkFlowChange, self)
  Z.EventMgr:Add(Z.ConstValue.BeforeDeactiveAll, self.onDeactiveAll_, self)
  Z.EventMgr:Add(Z.ConstValue.UILoadFail, self.onUILoadFail, self)
end

function QuestService:OnUnInit()
  Z.EventMgr:RemoveObjAll(self)
end

function QuestService:OnEnterScene(sceneId)
  local questVM = Z.VMMgr.GetVM("quest")
  questVM.UpdateQuestDataOnEnterScene(sceneId)
end

function QuestService:OnLogin()
  function self.onChangeLanguagee()
    local questData = Z.DataMgr.Get("quest_data")
    
    questData:ClearStepConfigCache()
  end
  
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.onChangeLanguagee)
end

function QuestService:OnLogout()
  Z.EventMgr:Remove(Z.ConstValue.LanguageChange, self.onChangeLanguagee)
end

function QuestService:OnLeaveScene()
  local talkData = Z.DataMgr.Get("talk_data")
  talkData:Clear()
  local questVM = Z.VMMgr.GetVM("quest")
  questVM.ClearQuestDataOnLeaveScene()
end

function QuestService:OnVisualLayerChange()
  logGreen("[quest] OnVisualLayerChange")
  self:recoverTask()
end

function QuestService:onUILoadFail(uiName, expression)
  if uiName == "talk_dialog_window" or uiName == "talk_main" or uiName == "talk_model_window" or uiName == "talk_option_window" then
    local talkData = Z.DataMgr.Get("talk_data")
    local flowId = talkData:GetTalkCurFlow()
    if flowId ~= nil then
      logError("OnUILoadFail flowId is not nil, flowId: " .. flowId)
    end
    talkData:ClearPlayFlowInfo()
  end
end

function QuestService:OnResurrectionEnd()
  self:recoverTask()
end

function QuestService:recoverTask()
  local questGoalGuideVm = Z.VMMgr.GetVM("quest_goal_guide")
  questGoalGuideVm.RefreshQuestGuideEffectVisible()
  local talkData = Z.DataMgr.Get("talk_data")
  talkData:ClearPlayFlowInfo()
  local goalVM = Z.VMMgr.GetVM("quest_goal")
  goalVM.HandleAllQuestAutoGoal()
  local questTalkVM = Z.VMMgr.GetVM("quest_talk")
  questTalkVM.OpenAutoFlowTalk()
end

function QuestService:onNpcQuestTalkFlowChange(npcId)
  local talkVM = Z.VMMgr.GetVM("talk")
  talkVM.NotifyNpcQuestTalkFlowChange(npcId)
end

return QuestService
