local pb = require("pb2")
local FriendNtfStubImpl = {}

function FriendNtfStubImpl:OnCreateStub()
end

function FriendNtfStubImpl:NotifyUpdateData(call, vRequest)
  local vm = Z.VMMgr.GetVM("friends_main")
  if vRequest and vm then
    vm.AsyncFriend(vRequest.operationMap, vRequest.syncData)
  end
end

function FriendNtfStubImpl:NotifyFriendlinessExpLv(call, vRequest)
  local vm = Z.VMMgr.GetVM("friends_main")
  if vRequest and vm then
    vm.UpdateSelfFriendLinessData(vRequest.totalLevel, vRequest.totalExp, vRequest.todayTotalAddExps, vRequest.updateTimeStamp, vRequest.changeList)
  end
end

return FriendNtfStubImpl
