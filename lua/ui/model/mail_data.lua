local super = require("ui.model.data_base")
local MailData = class("MailData", super)

function MailData:ctor()
  super.ctor(self)
  self:ResetData()
end

function MailData:Init()
  self:ResetData()
  self.CancelSource = Z.CancelSource.Rent()
end

function MailData:OnReconnect()
end

function MailData:Clear()
  self:ResetData()
end

function MailData:UnInit()
  self.CancelSource:Recycle()
end

function MailData:ResetData()
  self.isInit_ = false
  self.isImportant_ = true
  self.normalMailNum_ = 0
  self.normalUnReadList_ = {}
  self.normalMailList_ = {}
  self.normalSort_ = false
  self.importantMailNum_ = 0
  self.importUnReadList_ = {}
  self.importantMaiList_ = {}
  self.importantSort_ = false
  self.newMailList_ = {}
end

function MailData:GetIsInit()
  return self.isInit_
end

function MailData:SetIsInit()
  self.isInit_ = true
end

function MailData:GetIsImportant()
  return self.isImportant_
end

function MailData:SetIsImportant(isImportant)
  self.isImportant_ = isImportant
end

function MailData:GetNormalMailNum()
  return self.normalMailNum_
end

function MailData:SetNormalMailNum(num)
  self.normalMailNum_ = num
end

function MailData:ChangeNormalMailNum(num)
  self.normalMailNum_ = self.normalMailNum_ + num
end

function MailData:GetNormalUnReadList()
  return self.normalUnReadList_
end

function MailData:ClearNormalUnReadList()
  self.normalUnReadList_ = {}
end

function MailData:SetNormalUnReadList(list)
  self.normalUnReadList_ = list
end

function MailData:AddNormalUnRead(mailId)
  self.normalUnReadList_[#self.normalUnReadList_ + 1] = mailId
  self.normalMailNum_ = self.normalMailNum_ + 1
end

function MailData:ClearNormalMailList()
  self.normalMailList_ = {}
end

function MailData:GetNormalMailList()
  return self.normalMailList_
end

function MailData:GetImportantMailNum()
  return self.importantMailNum_
end

function MailData:SetImportantMailNum(num)
  self.importantMailNum_ = num
end

function MailData:ChangeImportantMailNum(num)
  self.importantMailNum_ = self.importantMailNum_ + num
end

function MailData:GetImportantUnReadList()
  return self.importUnReadList_
end

function MailData:ClearImportantUnReadList()
  self.importUnReadList_ = {}
end

function MailData:SetImportantUnReadList(list)
  self.importUnReadList_ = list
end

function MailData:AddImportantUnRead(mailId)
  self.importUnReadList_[#self.importUnReadList_ + 1] = mailId
  self.importantMailNum_ = self.importantMailNum_ + 1
end

function MailData:ClearImportantMailList()
  self.importantMaiList_ = {}
end

function MailData:GetImportantMailList()
  return self.importantMaiList_
end

function MailData:AddImportantMail(mail)
  self.importantMaiList_[#self.importantMaiList_ + 1] = mail
end

function MailData:SetSort(isImport)
  if isImport then
    self.importantSort_ = false
  else
    self.normalSort_ = false
  end
end

local isHaveRead = function(data)
  if table.zcount(data.awardIds) > 0 or 0 < table.zcount(data.appendix) then
    if data.mailState == Z.PbEnum("MailState", "MailStateGet") then
      return true
    else
      return false
    end
  else
    return data.mailState == Z.PbEnum("MailState", "MailStateRead")
  end
end
local sortFunc = function(left, right)
  if isHaveRead(left) then
    if isHaveRead(right) then
      return left.createTime > right.createTime
    else
      return false
    end
  elseif isHaveRead(right) then
    return true
  else
    return left.createTime > right.createTime
  end
end

function MailData:SortAllMailData()
  table.sort(self.importantMaiList_, sortFunc)
  table.sort(self.normalMailList_, sortFunc)
end

function MailData:SortMailData(Important)
  if Important then
    if self.importantSort_ == true or #self.importantMaiList_ == 0 then
      return
    end
  elseif self.normalSort_ == true or #self.normalMailList_ == 0 then
    return
  end
  if Important then
    self.importantSort_ = true
    table.sort(self.importantMaiList_, sortFunc)
  else
    self.normalSort_ = true
    table.sort(self.normalMailList_, sortFunc)
  end
end

function MailData:DelMailData(isImportant, uuid)
  local list
  if isImportant then
    list = self.importantMaiList_
  else
    list = self.normalMailList_
  end
  if list and 1 < #list then
    for i = #list, 1 do
      if list[i].mailUuid == uuid then
        table.remove(list, i)
        break
      end
    end
  end
end

function MailData:AddMailData(mail)
  local list
  if mail.importance > 0 then
    list = self.importantMaiList_
  else
    list = self.normalMailList_
  end
  if list and 0 < #list then
    for i = 1, #list do
      if list[i].mailUuid == mail.mailUuid then
        list[i] = mail
        return
      end
    end
  end
  list[#list + 1] = mail
end

function MailData:RemoveUnRead(mailUuid, isImportant)
  local list
  if isImportant then
    list = self.importUnReadList_
  else
    list = self.normalUnReadList_
  end
  if 0 < #list then
    for i = #list, 1, -1 do
      if list[i] == mailUuid then
        table.remove(list, i)
      end
    end
  end
end

function MailData:AddNewMailUuid(mailUuid)
  self.newMailList_[#self.newMailList_ + 1] = mailUuid
end

function MailData:RemoveNewMailUuid(mailUuid)
  for i = #self.newMailList_, 1, -1 do
    if self.newMailList_[i] == mailUuid then
      table.remove(self.newMailList_, i)
    end
  end
end

function MailData:GetNewMailList()
  return self.newMailList_
end

return MailData
