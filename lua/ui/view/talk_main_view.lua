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
  for _, data in ipairs(self.viewData.SpeakerList) do
    if data.SpeakerId == self.talkData_:GetTalkingNpcId() then
      Z.NpcBehaviourMgr:ChangeTalkingAction(data.ActionId)
      Z.NpcBehaviourMgr:ChangeTalkingEmote(data.NewEmotionId)
    end
  end
  self.talkVM_.OpenCommonTalkDialog(self.viewData.DialogData)
  if self.viewData.IsLast then
    self:openQuestOptionInNpcDefaultFlow()
  end
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
