local pb = require("pb2")
local GrpcCharactorNtfStubImpl = {}

function GrpcCharactorNtfStubImpl:OnCreateStub()
end

function GrpcCharactorNtfStubImpl:GetFaceUpTokenNtf(call, vRequest)
  if vRequest.errCode == 0 then
    local faceVm = Z.VMMgr.GetVM("face")
    faceVm.OnUploadFaceDataGetTmpToken(vRequest.result, vRequest.shortGuid)
  else
    Z.TipsVM.ShowTips(vRequest.errCode)
  end
end

return GrpcCharactorNtfStubImpl
