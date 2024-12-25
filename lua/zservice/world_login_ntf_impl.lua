local pb = require("pb2")
local WorldLoginNtfStubImpl = {}

function WorldLoginNtfStubImpl:OnCreateStub()
end

function WorldLoginNtfStubImpl:NotifyKickOutOff(call, vRequest)
  local loginVM = Z.VMMgr.GetVM("login")
  loginVM:KickOffByServer(vRequest.errcode)
end

function WorldLoginNtfStubImpl:NotifyEnterWorld(call, vRequest)
end

return WorldLoginNtfStubImpl
