local WorldProxy = require("zproxy.world_proxy")
local MailProxy = require("zproxy.mail_proxy")
local mailData = Z.DataMgr.Get("mail_data")
local mailQuantityMax = Z.Global.MailQuantityMax
local mailRefreshNum = Z.Global.MailListRefreshNum
local itemShowVm = Z.VMMgr.GetVM("item_show")
local openMailView = function()
  Z.UIMgr:OpenView("mail")
end
local closeMailView = function()
  Z.UIMgr:CloseView("mail")
end
local mailAddUnRead = function(mailUuid, importance)
  if importance then
    mailData:AddImportantUnRead(mailUuid)
  else
    mailData:AddNormalUnRead(mailUuid)
  end
end
local mailAddRed = function(mailUuid, importance)
  if importance then
    Z.RedPointMgr.AddChildNodeData(E.RedType.MailImport, E.RedType.MailImportItem, E.RedType.MailImport .. E.RedType.MailImportItem .. mailUuid)
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.MailImport .. E.RedType.MailImportItem .. mailUuid, 1)
  else
    Z.RedPointMgr.AddChildNodeData(E.RedType.MailNormal, E.RedType.MailNormalItem, E.RedType.MailNormal .. E.RedType.MailNormalItem .. mailUuid)
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.MailNormal .. E.RedType.MailNormalItem .. mailUuid, 1)
  end
end
local removeMailRed = function(mailUuid, isImportant)
  mailData:RemoveUnRead(mailUuid, isImportant)
  if isImportant then
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.MailImport .. E.RedType.MailImportItem .. mailUuid, 0)
  else
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.MailNormal .. E.RedType.MailNormalItem .. mailUuid, 0)
  end
end
local clearMailRed = function(isImportant)
  local unReadList
  if isImportant then
    unReadList = mailData:GetImportantUnReadList()
  else
    unReadList = mailData:GetNormalUnReadList()
  end
  for i = #unReadList, 1, -1 do
    removeMailRed(unReadList[i], isImportant)
  end
end
local updateMailRedNum = function()
  local importantMailList = mailData:GetImportantUnReadList()
  for i = 1, #importantMailList do
    mailAddRed(importantMailList[i], true)
  end
  local normalMailList = mailData:GetNormalUnReadList()
  for i = 1, #normalMailList do
    mailAddRed(normalMailList[i], false)
  end
end
local saveMailDataList = function(mailTable, mailDatas)
  for Uuid, data in pairs(mailDatas) do
    if table.zcount(mailTable) >= mailQuantityMax then
      break
    end
    data.mailUuid = Uuid
    mailTable[#mailTable + 1] = data
  end
end
local reqMailList = function(vPage, vIsImportant, cancelToken)
  local request = {}
  request.page = vPage
  request.importance = vIsImportant and 1 or 0
  local ret = MailProxy.GetMailList(request, cancelToken)
  if ret.errCode == 0 then
    if vIsImportant then
      saveMailDataList(mailData:GetImportantMailList(), ret.mailList)
    else
      saveMailDataList(mailData:GetNormalMailList(), ret.mailList)
    end
  else
    Z.TipsVM.ShowTips(ret.errCode)
  end
end
local asyncGetMailList = function(cancelSource)
  mailData:ClearImportantMailList()
  if mailData:GetImportantMailNum() > 0 then
    local pageNum = math.ceil(mailData:GetImportantMailNum() / mailRefreshNum)
    if 1 <= pageNum then
      for i = 0, pageNum - 1 do
        reqMailList(i, true, cancelSource:CreateToken())
      end
    end
    mailData:SortMailData(true)
  end
  mailData:ClearNormalMailList()
  if 0 < mailData:GetNormalMailNum() then
    local pageNum = math.ceil(mailData:GetNormalMailNum() / mailRefreshNum)
    if 1 <= pageNum then
      for i = 0, pageNum - 1 do
        reqMailList(i, false, cancelSource:CreateToken())
      end
    end
    mailData:SortMailData(false)
  end
  mailData:SetIsInit()
  Z.EventMgr:Dispatch(Z.ConstValue.Mail.RefreshMailLoopData)
end
local deleteMail = function(vMailIds, cancelToken)
  local request = {}
  request.mailIds = vMailIds
  local ret = MailProxy.DeleteMail(request, cancelToken)
  return ret
end
local deleteAllReadMail = function(cancelToken)
  local vMailIds = {}
  for _, value in pairs(mailData:GetNormalMailList()) do
    if value.mailState == Z.PbEnum("MailState", "MailStateGet") then
      table.insert(vMailIds, value.mailUuid)
    elseif value.mailState == Z.PbEnum("MailState", "MailStateRead") and table.zcount(value.appendix) == 0 then
      table.insert(vMailIds, value.mailUuid)
    end
  end
  if table.zcount(vMailIds) > 0 then
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
local getMailAppendix = function(mailAppend)
  local request = {}
  request.mailIds = mailAppend
  WorldProxy.GetMailAppendix(request)
end
local getAllMailAppendix = function(cancelToken)
  local readMailTab = {}
  local mailTab = {}
  for _, value in pairs(mailData:GetNormalMailList()) do
    if table.zcount(value.appendix) == 0 then
      if value.mailState ~= Z.PbEnum("MailState", "MailStateRead") then
        table.insert(readMailTab, value.mailUuid)
      end
    elseif value.mailState ~= Z.PbEnum("MailState", "MailStateGet") then
      table.insert(mailTab, value.mailUuid)
    end
  end
  if table.zcount(mailTab) + table.zcount(readMailTab) > 0 then
    if table.zcount(readMailTab) > 0 then
      local request = {}
      request.mailIds = readMailTab
      MailProxy.ReadMail(request, cancelToken)
    end
    if table.zcount(mailTab) > 0 then
      local request = {}
      request.mailIds = mailTab
      WorldProxy.GetMailAppendix(request)
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
local receiveNewMail = function(mailUuid, importance)
  mailData:AddNewMailUuid(mailUuid)
  mailAddUnRead(mailUuid, importance)
  mailAddRed(mailUuid, importance)
  mailData:SetSort(importance)
  Z.EventMgr:Dispatch(Z.ConstValue.Mail.ReceiveNewMal, mailUuid)
end
local setMailState = function(uuid, mailState, configId, materials, mailMgr)
  local mailTab = mailMgr.GetRow(configId)
  if not mailTab then
    return
  end
  local mailList = mailTab.Important > 0 and mailData:GetImportantMailList() or mailData:GetNormalMailList()
  local data, index
  for i = 1, #mailList do
    if mailList[i].mailUuid == uuid then
      data = mailList[i]
      index = i
      break
    end
  end
  if data then
    data.mailState = mailState
  end
  if mailState == Z.PbEnum("MailState", "MailStateDelete") then
    removeMailRed(uuid, mailTab.Important > 0)
    if mailTab.Important > 0 then
      mailData:ChangeImportantMailNum(-1)
    else
      mailData:ChangeNormalMailNum(-1)
    end
    if mailList then
      table.remove(mailList, index)
    end
  elseif mailState == Z.PbEnum("MailState", "MailStateGet") then
    if materials and data and 0 < table.zcount(data.appendix) then
      table.zmerge(materials, data.appendix)
    end
    removeMailRed(uuid, mailTab.Important > 0)
    mailData:SetSort(mailTab.Important > 0)
  elseif mailState == Z.PbEnum("MailState", "MailStateRead") then
    if data and table.zcount(data.appendix) == 0 then
      removeMailRed(data.mailUuid, 0 < data.importance)
    end
    mailData:SetSort(mailTab.Important > 0)
  end
end
local refreshMailState = function(mails)
  local materials = {}
  local mailMgr = Z.TableMgr.GetTable("MailTableMgr")
  for uuid, mailStateInfo in pairs(mails) do
    setMailState(uuid, mailStateInfo.mailState, mailStateInfo.mailConfigId, materials, mailMgr)
  end
  if table.zcount(materials) > 0 then
    itemShowVm.OpenEquipAcquireViewByItems(materials)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Mail.RefreshMailLoopData)
end
local asyncReadMail = function(mailUuid, cancelToken)
  local request = {}
  request.mailIds = {mailUuid}
  MailProxy.ReadMail(request, cancelToken)
end
local getMailShowContext = function(context, params)
  if 0 < #params and context ~= "" then
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
  if mail.mailState == Z.PbEnum("MailState", "MailStateRead") and table.zcount(mail.appendix) > 0 then
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
  mailAddUnRead(mailInfo.mailUuid, mailInfo.importance > 0)
  mailAddRed(mailInfo.mailUuid, mailInfo.importance > 0)
end
local asyncCheckMailList = function()
  if not mailData:GetIsInit() then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local mailList = {}
    local normalList = mailData:GetNormalMailList()
    for i = 1, #normalList do
      mailList[normalList[i].mailUuid] = {isImportant = false}
    end
    local importantList = mailData:GetImportantMailList()
    for i = 1, #importantList do
      mailList[importantList[i].mailUuid] = {isImportant = true}
    end
    local newMailList = mailData:GetNewMailList()
    for i = 1, #newMailList do
      mailList[newMailList[i]] = {isImportant = true}
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
      if 0 < table.zcount(mailList) then
        for mailUuid, data in pairs(mailList) do
          mailData:DelMailData(data.isImportant, mailUuid)
        end
        refreshLoop = true
      end
      if 0 < #needGetNewMailList then
        for i = 1, #needGetNewMailList do
          local request = {}
          request.mailId = needGetNewMailList[i]
          local mailInfo = MailProxy.GetMailInfo(request, mailData.CancelSource:CreateToken())
          if mailInfo.errCode == 0 then
            saveMailData(mailInfo.mail)
          end
        end
        refreshLoop = true
      end
    elseif 0 < table.zcount(mailList) then
      mailData:ClearNormalMailList()
      mailData:ClearImportantMailList()
      clearMailRed(true)
      clearMailRed(false)
      refreshLoop = true
    end
    if refreshLoop then
      Z.EventMgr:Dispatch(Z.ConstValue.Mail.RefreshMailLoopData)
    end
  end)()
end
local asyncGetNewMailByUuid = function(mailUuid, cancelToken)
  local request = {}
  request.mailUuid = mailUuid
  local mailInfo = MailProxy.GetMailInfo(request, cancelToken)
  if mailInfo.errCode == 0 then
    mailData:RemoveNewMailUuid(mailUuid)
    mailData:AddMailData(mailInfo.mail)
    Z.EventMgr:Dispatch(Z.ConstValue.Mail.RefreshMailLoopData)
  end
end
local asyncCheckNewMailList = function(cancelSource)
  local newMailList = mailData:GetNewMailList()
  for i = #newMailList, 1, -1 do
    asyncGetNewMailByUuid(newMailList[i], cancelSource:CreateToken())
  end
  mailData:SortAllMailData()
  Z.EventMgr:Dispatch(Z.ConstValue.Mail.RefreshMailLoopData)
end
local ret = {
  OpenMailView = openMailView,
  CloseMailView = closeMailView,
  AsyncGetMailList = asyncGetMailList,
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
  AsyncCheckNewMailList = asyncCheckNewMailList
}
return ret
