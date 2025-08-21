local WorldProxy = require("zproxy.world_proxy")
local MailProxy = require("zproxy.mail_proxy")
local mailData = Z.DataMgr.Get("mail_data")
local itemShowVm = Z.VMMgr.GetVM("item_show")
local openMailView = function()
  Z.UIMgr:OpenView("mail")
end
local closeMailView = function()
  Z.UIMgr:CloseView("mail")
end
local mailAddRed = function(mailUuid)
  Z.RedPointMgr.AddChildNodeData(E.RedType.MailNormal, E.RedType.MailNormalItem, E.RedType.MailNormal .. E.RedType.MailNormalItem .. mailUuid)
  Z.RedPointMgr.UpdateNodeCount(E.RedType.MailNormal .. E.RedType.MailNormalItem .. mailUuid, 1)
end
local removeMailRed = function(mailUuid)
  mailData:RemoveUnRead(mailUuid)
  Z.RedPointMgr.UpdateNodeCount(E.RedType.MailNormal .. E.RedType.MailNormalItem .. mailUuid, 0)
end
local clearMailRed = function()
  local unReadList = mailData:GetMailUnReadList()
  for i = #unReadList, 1, -1 do
    removeMailRed(unReadList[i])
  end
end
local updateMailRedNum = function()
  local normalMailList = mailData:GetMailUnReadList()
  for i = 1, #normalMailList do
    mailAddRed(normalMailList[i])
  end
end
local saveMailDataList = function(mailDatas)
  for Uuid, data in pairs(mailDatas) do
    if mailData:GetMailNum() > Z.Global.MailQuantityMax then
      break
    end
    data.mailUuid = Uuid
    mailData:AddMailData(data)
  end
end
local reqMailList = function(vPage, cancelToken)
  local request = {page = vPage, isCollect = false}
  local ret = WorldProxy.GetMailList(request, cancelToken)
  if ret.errCode == 0 then
    saveMailDataList(ret.mailList)
  else
    Z.TipsVM.ShowTips(ret.errCode)
  end
  mailData:AddMailPageId(vPage)
  if mailData:GetMailPage() == mailData:GetMailPageIdCount() then
    mailData:SortMailData()
    mailData:SetIsInit()
    Z.EventMgr:Dispatch(Z.ConstValue.Mail.InitMailList)
  end
end
local asyncInitMailList = function(cancelSource)
  mailData:ClearMailList()
  local mailNum = mailData:GetServerMailNum()
  if 0 < mailNum then
    local pageNum = math.ceil(mailNum / Z.Global.MailListRefreshNum)
    if 1 <= pageNum then
      mailData:SetMailPage(pageNum)
      for i = 0, pageNum - 1 do
        Z.CoroUtil.create_coro_xpcall(function()
          reqMailList(i, cancelSource:CreateToken())
        end)()
      end
    end
  end
end
local deleteMail = function(vMailIds, cancelToken)
  local request = {}
  request.mailIds = vMailIds
  local ret = MailProxy.DeleteMail(request, cancelToken)
  return ret
end
local deleteAllReadMail = function(cancelToken)
  local vMailIds = {}
  for _, value in pairs(mailData:GetMailList()) do
    if not value.isCollect then
      if value.mailState == Z.PbEnum("MailState", "MailStateGet") then
        table.insert(vMailIds, value.mailUuid)
      elseif value.mailState == Z.PbEnum("MailState", "MailStateRead") and not value.isHaveAppendix and not value.isHaveAward then
        table.insert(vMailIds, value.mailUuid)
      end
    end
  end
  if 0 < #vMailIds then
    local ret = deleteMail(vMailIds, cancelToken)
    if ret.errCode == 0 then
      Z.TipsVM.ShowTipsLang(130029)
      Z.EventMgr:Dispatch(Z.ConstValue.Mail.RefreshMailBtn)
    else
      Z.TipsVM.ShowTips(ret.errCode)
    end
  else
    Z.TipsVM.ShowTipsLang(130030)
  end
end
local getMailAppendix = function(mailAppend, token)
  local request = {}
  request.mailIds = mailAppend
  local ret = WorldProxy.GetMailAppendix(request, token)
  if #ret.rewards > 0 then
    itemShowVm.OpenItemShowViewByItems(ret.rewards)
  end
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end
local getAllMailAppendix = function(cancelSource)
  local readMailTab = {}
  local mailTab = {}
  for _, value in pairs(mailData:GetMailList()) do
    if value.isHaveAppendix or value.isHaveAward then
      if value.mailState ~= Z.PbEnum("MailState", "MailStateGet") then
        table.insert(mailTab, value.mailUuid)
      end
    elseif value.mailState ~= Z.PbEnum("MailState", "MailStateRead") then
      table.insert(readMailTab, value.mailUuid)
    end
  end
  if 0 < #mailTab + #readMailTab then
    if 0 < #readMailTab then
      local request = {}
      request.mailIds = readMailTab
      local ret = MailProxy.ReadMail(request, cancelSource:CreateToken())
      if ret.errCode ~= 0 then
        Z.TipsVM.ShowTips(ret.errCode)
      end
    end
    if 0 < #mailTab then
      local request = {}
      request.mailIds = mailTab
      local ret = WorldProxy.GetMailAppendix(request, cancelSource:CreateToken())
      if 0 < #ret.rewards then
        itemShowVm.OpenItemShowViewByItems(ret.rewards)
      end
      if ret.errCode ~= 0 then
        Z.TipsVM.ShowTips(ret.errCode)
      end
    end
  else
    Z.TipsVM.ShowTipsLang(130031)
  end
end
local getDateNum = function(start_time, end_time)
  local t1 = os.date("%Y%m%d%H%M%S", start_time)
  local t2 = os.date("%Y%m%d%H%M%S", end_time)
  local day1 = {}
  local day2 = {}
  day1.year, day1.month, day1.day, day1.hour, day1.min, day1.sec = string.match(t1, "(%d%d%d%d)(%d%d)(%d%d)(%d%d)(%d%d)(%d%d)")
  day2.year, day2.month, day2.day, day2.hour, day2.min, day2.sec = string.match(t2, "(%d%d%d%d)(%d%d)(%d%d)(%d%d)(%d%d)(%d%d)")
  local numDay1 = os.time(day1)
  local numDay2 = os.time(day2)
  local diffTime = (numDay2 - numDay1) / 86400
  local param = {val = 1}
  if diffTime < 1 and 0 < diffTime then
    local h = math.floor(diffTime * 24)
    if 1 < h then
      param.val = h
    end
    return Lang("Hour", param)
  end
  param.val = math.floor(diffTime)
  return Lang("Day", param)
end
local receiveNewMail = function(mailUuid)
  mailData:AddMailUnRead(mailUuid)
  mailData:AddNewMailUuid(mailUuid)
  mailAddRed(mailUuid)
  Z.EventMgr:Dispatch(Z.ConstValue.Mail.ReceiveNewMal, mailUuid)
end
local getMailList = function(uuid, mailList)
  local data, index
  for i = 1, #mailList do
    if mailList[i].mailUuid == uuid then
      data = mailList[i]
      index = i
      break
    end
  end
  return data, index
end
local setMailState = function(uuid, mailState, configId, mailMgr)
  local mailTab = mailMgr.GetRow(configId)
  if not mailTab then
    return
  end
  local mailList = mailData:GetMailList()
  local data, index = getMailList(uuid, mailList)
  if not data then
    return
  end
  data.mailState = mailState
  if mailState == Z.PbEnum("MailState", "MailStateDelete") then
    removeMailRed(uuid)
    if mailList then
      table.remove(mailList, index)
    end
  elseif mailState == Z.PbEnum("MailState", "MailStateGet") then
    removeMailRed(uuid)
  elseif mailState == Z.PbEnum("MailState", "MailStateRead") and not data.isHaveAppendix and not data.isHaveAward then
    removeMailRed(data.mailUuid)
  end
end
local refreshMailState = function(mails)
  local mailMgr = Z.TableMgr.GetTable("MailTableMgr")
  for uuid, mailStateInfo in pairs(mails) do
    setMailState(uuid, mailStateInfo.mailState, mailStateInfo.mailConfigId, mailMgr)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Mail.RefreshMailLoopData)
end
local asyncReadMail = function(mailUuid, cancelToken)
  local request = {}
  request.mailIds = {mailUuid}
  local ret = MailProxy.ReadMail(request, cancelToken)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end
local getMailShowContext = function(context, params)
  if params and 0 < #params and context ~= "" then
    local param = {}
    param.str = {}
    for i = 1, #params do
      param.str[i] = params[i]
    end
    context = Z.Placeholder.Placeholder(context, param)
  end
  return context
end
local isShowRed = function(mail)
  if mail.mailState == Z.PbEnum("MailState", "MailStateSend") then
    return true
  end
  if mail.mailState == Z.PbEnum("MailState", "MailStateRead") and (mail.isHaveAppendix or mail.isHaveAward) then
    return true
  end
  return false
end
local saveMailData = function(mailInfo)
  mailData:AddMailData(mailInfo)
  local isShowRed = isShowRed(mailInfo)
  if not isShowRed then
    return
  end
  mailAddRed(mailInfo.mailUuid)
  mailData:AddMailUnRead(mailInfo.mailUuid)
end
local reqMailDataByUuidList = function(list)
  local count = #list
  if count > Z.Global.MailListRefreshNum then
    local requestMailList = {}
    for i = 1, count do
      requestMailList[#requestMailList + 1] = list[i]
      if #requestMailList == Z.Global.MailListRefreshNum or i == count then
        local mailInfo = WorldProxy.GetMailInfo({mailUuidList = requestMailList}, mailData.CancelSource:CreateToken())
        if mailInfo.errCode == 0 then
          for j = 1, #mailInfo.mails do
            saveMailData(mailInfo.mails[j])
          end
        end
        requestMailList = {}
      end
    end
  else
    local mailInfo = WorldProxy.GetMailInfo({mailUuidList = list}, mailData.CancelSource:CreateToken())
    if mailInfo.errCode == 0 then
      for j = 1, #mailInfo.mails do
        saveMailData(mailInfo.mails[j])
      end
    end
  end
end
local asyncCheckMailList = function()
  if not mailData:GetIsInit() then
    return
  end
  local mailList = {}
  local list = mailData:GetMailList()
  for i = 1, #list do
    mailList[list[i].mailUuid] = true
  end
  local newMailList = mailData:GetNewMailList()
  for i = 1, #newMailList do
    mailList[newMailList[i]] = true
  end
  local refreshLoop = false
  local serverMailInfo = MailProxy.GetMailUuidList({}, mailData.CancelSource:CreateToken())
  if #serverMailInfo.mailUuidList > 0 then
    local needGetNewMailList = {}
    for i = 1, #serverMailInfo.mailUuidList do
      local serverUuid = serverMailInfo.mailUuidList[i]
      if not mailList[serverUuid] then
        needGetNewMailList[#needGetNewMailList + 1] = serverUuid
      else
        mailList[serverUuid] = nil
      end
    end
    if 0 < #mailList then
      for mailUuid, data in pairs(mailList) do
        mailData:RemoveMailByUuid(mailUuid)
      end
      refreshLoop = true
    end
    if 0 < #needGetNewMailList then
      reqMailDataByUuidList(needGetNewMailList)
      refreshLoop = true
    end
  elseif 0 < #mailList then
    mailData:ClearMailList()
    clearMailRed()
    refreshLoop = true
  end
  if refreshLoop then
    Z.EventMgr:Dispatch(Z.ConstValue.Mail.RefreshMailLoopData)
  end
end
local asyncGetNewMailByUuid = function(mailUuid, cancelToken)
  local request = {}
  request.mailUuid = mailUuid
  local mailInfo = WorldProxy.GetMailInfo(request, cancelToken)
  if mailInfo.errCode == 0 then
    mailData:RemoveNewMailUuid(mailUuid)
    mailData:AddMailData(mailInfo.mail, true)
    Z.EventMgr:Dispatch(Z.ConstValue.Mail.RefreshMailLoopData)
  else
    Z.TipsVM.ShowTips(mailInfo.errCode)
  end
end
local asyncCheckNewMailList = function(cancelSource)
  local newMailList = mailData:GetNewMailList()
  for i = #newMailList, 1, -1 do
    if mailData:IsHaveMaillByUuid(newMailList[i]) then
      mailData:RemoveNewMailUuid(newMailList[i])
    else
      asyncGetNewMailByUuid(newMailList[i], cancelSource:CreateToken())
    end
  end
end
local isMailTimeOut = function(mailBase, nowTime)
  if not mailBase.timeoutMs or mailBase.timeoutMs <= 0 then
    return false
  end
  local endTime = math.floor(tonumber(mailBase.timeoutMs) / 1000)
  return nowTime > endTime
end
local checkMailTimeOut = function()
  local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local mailList = mailData:GetMailList()
  for i = #mailList, 1, -1 do
    if isMailTimeOut(mailList[i], nowTime) then
      Z.RedPointMgr.UpdateNodeCount(E.RedType.MailNormal .. E.RedType.MailNormalItem .. mailList[i].mailUuid, 0)
      Z.RedPointMgr.RefreshRedNodeState(E.RedType.MailNormalItem)
      Z.RedPointMgr.RefreshRedNodeState(E.RedType.MailNormal)
      mailData:RemoveMailBaseByIndex(i)
    end
  end
end
local asyncAddMailCollect = function(uuid, token)
  local request = {
    mails = {uuid}
  }
  local ret = WorldProxy.AddCollectMail(request, token)
  return ret
end
local asyncCancelMailCollect = function(uuid, token)
  local request = {
    mails = {uuid}
  }
  local ret = WorldProxy.CancelCollectMail(request, token)
  return ret
end
local asyncGetMailNum = function()
  local ret = WorldProxy.GetMailManager({}, mailData.CancelSource:CreateToken())
  if ret.errCode == 0 then
    mailData:SetServerMailNum(ret.normalNum)
    mailData:SetMailUnReadList(ret.normalUnReadList)
  end
end
local ret = {
  OpenMailView = openMailView,
  CloseMailView = closeMailView,
  AsyncInitMailList = asyncInitMailList,
  DeleteMail = deleteMail,
  AsyncReadMail = asyncReadMail,
  GetDateNum = getDateNum,
  GetAllMailAppendix = getAllMailAppendix,
  GetMailAppendix = getMailAppendix,
  DeleteAllReadMail = deleteAllReadMail,
  RefreshMailState = refreshMailState,
  ReceiveNewMail = receiveNewMail,
  UpdateMailRedNum = updateMailRedNum,
  GetMailShowContext = getMailShowContext,
  ClearMailRed = clearMailRed,
  AsyncCheckMailList = asyncCheckMailList,
  AsyncGetNewMailByUuid = asyncGetNewMailByUuid,
  AsyncCheckNewMailList = asyncCheckNewMailList,
  CheckMailTimeOut = checkMailTimeOut,
  AsyncAddMailCollect = asyncAddMailCollect,
  AsyncCancelMailCollect = asyncCancelMailCollect,
  AsyncGetMailNum = asyncGetMailNum
}
return ret
