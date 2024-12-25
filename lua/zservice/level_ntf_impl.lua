local pb = require("pb2")
local LevelNtfStubImpl = {}

function LevelNtfStubImpl:OnCreateStub()
end

function LevelNtfStubImpl:DisplayBossOutOverdriveUI(call, isBreak, isWeak)
  Z.EventMgr:Dispatch("DisplayBossOutOverdriveUI", isBreak, isWeak)
  if isBreak then
    Z.AudioMgr:SetState(E.AudioState.Boss, "state_break")
  elseif isWeak then
    Z.AudioMgr:SetState(E.AudioState.Boss, "state_weak")
  end
end

return LevelNtfStubImpl
