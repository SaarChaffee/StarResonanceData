local UI = Z.UI
local super = require("ui.ui_view_base")
local Talk_mainView = class("Talk_mainView", super)

function Talk_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "talk_main")
  self.talkVM_ = Z.VMMgr.GetVM("talk")
  self.talkData_ = Z.DataMgr.Get("talk_data")
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self.talkOptionVM_ = Z.VMMgr.GetVM("talk_option")
end

function Talk_mainView:OnActive()
end

function Talk_mainView:OnRefresh()
  self:handleEntTalking()
  self.talkVM_.OpenCommonTalkDialog(self.viewData.DialogData)
  if self.viewData.IsLast then
    self:openQuestOptionInNpcDefaultFlow()
  end
end

function Talk_mainView:handleEntTalking()
  for _, data in ipairs(self.viewData.SpeakerList) do
    self:handleNpcTalking(data)
    self:handlePlayerTalking(data)
  end
end

function Talk_mainView:handleNpcTalking(data)
  if data.SpeakerId ~= self.talkData_:GetTalkingNpcId() then
    return
  end
  if data.AnimList ~= nil and #data.AnimList > 0 then
    Z.NpcBehaviourMgr:TalkingNpcPlayAnims(data.AnimList)
  else
    Z.NpcBehaviourMgr:ChangeTalkingAction(data.ActionId)
  end
  Z.NpcBehaviourMgr:ChangeTalkingEmote(data.NewEmotionId)
end

function Talk_mainView:handlePlayerTalking(data)
  if data.SpeakerId ~= 0 then
    return
  end
  if data.AnimList ~= nil and 0 < #data.AnimList then
    Z.ZAnimActionPlayMgr:ResetAction()
    if not Z.QuestMgr:CheckPlayerCanPlayTalkingAnims() then
      return
    end
    Z.QuestMgr:PlayerPlayAnims(data.AnimList)
  else
    Z.ZAnimActionPlayMgr:PlayAction(data.ActionId)
  end
  Z.ZAnimActionPlayMgr:PlayEmote(data.NewEmotionId)
end

function Talk_mainView:OnDeActive()
  self.talkVM_.CloseCommonTalkDialog()
end

function Talk_mainView:openQuestOptionInNpcDefaultFlow()
  if not self.talkVM_.IsCurFlowDefaultFlow() then
    return
  end
  local npcId = self.talkData_:GetTalkingNpcId()
  local curFlow = self.talkData_:GetTalkCurFlow()
  local row = Z.TableMgr.GetTable("PresentationEPFlowTableMgr").GetRow(curFlow)
  if row and not row.GetOption then
    local talkOptionVM = Z.VMMgr.GetVM("talk_option")
    local dataList = talkOptionVM.CreateNpcQuestOptionsForFlow(npcId)
    if 0 < #dataList then
      local leaveOption = self.talkOptionVM_.CreateLeaveOption()
      table.insert(dataList, leaveOption)
      talkOptionVM.OpenOptionView(dataList)
    end
  end
end

return Talk_mainView
