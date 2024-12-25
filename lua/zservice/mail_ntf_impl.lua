local MailNtfStubImpl = {}

function MailNtfStubImpl:SyncMailInfo(call, request)
  local mailVM = Z.VMMgr.GetVM("mail")
  mailVM.RefreshMailState(request.mails)
end

function MailNtfStubImpl:SyncMailListNum(call, request)
  local mailData = Z.DataMgr.Get("mail_data")
  mailData:SetNormalMailNum(request.normalNum)
  mailData:SetNormalUnReadList(request.normalUnReadList)
  mailData:SetImportantMailNum(request.importantNum)
  mailData:SetImportantUnReadList(request.importantUnReadList)
  local mailVM = Z.VMMgr.GetVM("mail")
  mailVM.UpdateMailRedNum()
end

function MailNtfStubImpl:SyncNewMail(call, request)
  local mailVM = Z.VMMgr.GetVM("mail")
  mailVM.ReceiveNewMail(request.mailUuid, request.importance > 0)
end

return MailNtfStubImpl
