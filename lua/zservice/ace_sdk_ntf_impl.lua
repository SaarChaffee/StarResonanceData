local pb = require("pb2")
local AceSdkNtfStubImpl = {}

function AceSdkNtfStubImpl:OnCreateStub()
end

function AceSdkNtfStubImpl:NotifyLoginAntiData(call, vRequest)
  local ticketStr = tostring(vRequest.tssInfo.antiData)
  local accountData = Z.DataMgr.Get("account_data")
  local success = Z.SDKAntiCheating.Login(accountData.OpenID, accountData.LoginType, ticketStr)
  if not success then
    local loginVM = Z.VMMgr.GetVM("login")
    loginVM:KickOffByClient(E.KickOffClientErrCode.AntiCheating)
  end
end

return AceSdkNtfStubImpl
