local super = require("ui.service.service_base")
local QuestService = class("QuestService", super)

function QuestService:OnInit()
  Z.EventMgr:Add(Z.ConstValue.NpcTalk.NpcQuestTalkFlowChange, self.onNpcQuestTalkFlowChange, self)
end

function QuestService:OnUnInit()
  Z.EventMgr:RemoveObjAll(self)
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
  local questTrackVM = Z.VMMgr.GetVM("quest_track")
  questTrackVM.RefreshQuestGuideEffectVisible()
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
