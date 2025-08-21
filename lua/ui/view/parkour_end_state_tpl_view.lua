local Parkour_end_state_tplView = class("Parkour_end_state_tplView")

function Parkour_end_state_tplView:ctor()
  self.isSuccess = false
  self.isNewRecord = false
end

function Parkour_end_state_tplView:Init(go, name, closeFunciton, closeTime)
  self.unit = UICompBindLua(go)
  self.unit.Ref:SetOffSetMin(0, 0)
  self.unit.Ref:SetOffSetMax(0, 0)
  self.unit.Ref:SetVisible(true)
  self.name = name
  self.timerMgr = Z.TimerMgr.new()
  self.lab_time_num = self.unit.lab_num
  self.node_lab = self.unit.node_lab
  self.lab_new_record = self.unit.lab_new_record
  self.node_new_record = self.unit.node_new_record
  self.lab_result = self.unit.cont_end_state.lab_name
  self.anim_parkour = self.unit.anim
  self.closeFunciton = closeFunciton
  self.closeTime = closeTime
  self.node_succeed = self.unit.cont_end_state.node_succeed
  self.node_fail = self.unit.cont_end_state.node_fail
  self.node_audio = self.unit.cont_end_state.anim_empty
  self:initData()
  self:initView()
end

function Parkour_end_state_tplView:initView()
  self.node_fail:SetVisible(false)
  self.node_succeed:SetVisible(false)
end

function Parkour_end_state_tplView:initData()
  self.lab_new_record.TMPLab.text = ""
  self.lab_time_num.TMPLab.text = ""
  self.unit.lab_num_2.TMPLab.text = ""
  for _, v in pairs(self.lab_result) do
    if v then
      v.TMPLab.text = ""
    end
  end
end

function Parkour_end_state_tplView:DeActive()
  self:TimeMgrClear()
end

function Parkour_end_state_tplView:TimeMgrClear()
  self.timerMgr:Clear()
end

function Parkour_end_state_tplView:SetData(result, recordData)
  if not recordData then
    return
  end
  local isShowNodeLabel = false
  if result == Z.PbEnum("EParkourResult", "EParkourResult_Success") then
    self.node_succeed:SetVisible(true)
    self.node_fail:SetVisible(false)
    isShowNodeLabel = true
    self.lab_time_num.TMPLab.text = Z.TimeFormatTools.FormatToDHMS(recordData.time, true)
    self.unit.lab_num_2.TMPLab.text = Z.TimeFormatTools.FormatToDHMS(recordData.perfectTime, true)
    self.lab_result[2].TMPLab.text = Lang("MultiParkour_successTips")
    self.node_audio.Audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.commonAudio_1)
    self:startPlaySuccessAnim()
  elseif result == Z.PbEnum("EParkourResult", "EParkourResult_Fail") then
    self.node_fail:SetVisible(true)
    self.node_succeed:SetVisible(false)
    isShowNodeLabel = false
    self.lab_result[1].TMPLab.text = Lang("MultiParkour_failTips")
    self.node_audio.Audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.commonAudio_2)
    self:startPlayFailAnim()
  end
  local newRecordText
  if recordData.state ~= Z.PbEnum("ERecordState", "ERecordState_None") then
    newRecordText = Lang("MultiParkour_newScore")
  end
  if newRecordText then
    self.lab_new_record.TMPLab.text = newRecordText
  end
  self.node_lab:SetVisible(isShowNodeLabel)
  self.node_new_record:SetVisible(newRecordText ~= nil)
  self:SetCloseTimer()
end

function Parkour_end_state_tplView:SetCloseTimer()
  self:TimeMgrClear()
  local time = 5
  if self.closeTime then
    time = self.closeTime
  end
  self.timerMgr:StartTimer(function()
    if self.closeFunciton then
      self:startPlayCloseAnim()
      self.closeFunciton()
    end
  end, time)
end

function Parkour_end_state_tplView:startPlaySuccessAnim()
  self.anim_parkour.TweenContainer:Restart(Z.DOTweenAnimType.Tween_0)
end

function Parkour_end_state_tplView:startPlayFailAnim()
  self.anim_parkour.TweenContainer:Restart(Z.DOTweenAnimType.Tween_1)
end

function Parkour_end_state_tplView:startPlayCloseAnim()
  self.anim_parkour.TweenContainer:Restart(Z.DOTweenAnimType.Close)
end

return Parkour_end_state_tplView
