local pb = require("pb2")
local CharactorNtfStubImpl = {}

function CharactorNtfStubImpl:OnCreateStub()
end

function CharactorNtfStubImpl:KickOff(call, errorCode)
  local vm = Z.VMMgr.GetVM("login")
  vm:KickOffByServer(errorCode)
end

return CharactorNtfStubImpl
