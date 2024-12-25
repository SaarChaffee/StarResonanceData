local pb = require("pb2")
local ChitChatNtfStubImpl = {}

function ChitChatNtfStubImpl:OnCreateStub()
end

function ChitChatNtfStubImpl:NotifyNewestChitChatMsgs(call, vRequest)
  local chatVm = Z.VMMgr.GetVM("chat_main")
  chatVm.ReceiveMsg(vRequest)
end

function ChitChatNtfStubImpl:NotifyBeMuted(call, vRequest)
  local chatVm = Z.VMMgr.GetVM("chat_main")
  chatVm.UpdatePersonalBanInfo(vRequest)
end

function ChitChatNtfStubImpl:NotifyAddPrivateChatSession(call, vRequest)
  Z.CoroUtil.create_coro_xpcall(function()
    local chatVm = Z.VMMgr.GetVM("chat_main")
    chatVm.AsyncUpdatePrivateChatList(vRequest)
  end)()
end

return ChitChatNtfStubImpl
