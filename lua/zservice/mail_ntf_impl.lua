local MailNtfStubImpl = {}

function MailNtfStubImpl:SyncMailInfo(call, request)
  local mailVM = Z.VMMgr.GetVM("mail")
  mailVM.RefreshMailState(request.mails)
end

function MailNtfStubImpl:SyncMailListNum(call, request)
end

function MailNtfStubImpl:SyncNewMail(call, request)
  local mainUIData = Z.DataMgr.Get("mainui_data")
  mainUIData.MainUIPCShowMail = true
  local mailVM = Z.VMMgr.GetVM("mail")
  mailVM.ReceiveNewMail(request.mailUuid)
end

return MailNtfStubImpl
