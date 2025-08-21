local super = require("ui.model.data_base")
local MailData = class("MailData", super)
local mailReadState = Z.PbEnum("MailState", "MailStateRead")
local mailGetState = Z.PbEnum("MailState", "MailStateGet")

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
  self.LastGetMailListTime = 0
  self.serverNum_ = 0
  self.mailPage_ = 0
  self.mailPageList_ = {}
  self.unReadUuIdList_ = {}
  self.newUuidList_ = {}
  self.list_ = {}
end

function MailData:GetIsInit()
  return self.isInit_
end

function MailData:SetIsInit()
  self.isInit_ = true
end

function MailData:SetServerMailNum(num)
  self.serverNum_ = num
end

function MailData:GetServerMailNum()
  return self.serverNum_
end

function MailData:SetMailPage(page)
  self.mailPage_ = page
end

function MailData:GetMailPage()
  return self.mailPage_
end

function MailData:AddMailPageId(pageId)
  table.insert(self.mailPageList_, pageId)
end

function MailData:GetMailPageIdCount()
  return #self.mailPageList_
end

function MailData:SetMailUnReadList(list)
  self.unReadUuIdList_ = list
end

function MailData:GetMailUnReadList()
  return self.unReadUuIdList_
end

function MailData:AddMailUnRead(uuid)
  table.insert(self.unReadUuIdList_, uuid)
end

function MailData:RemoveUnRead(mailUuid)
  if #self.unReadUuIdList_ > 0 then
    for i = #self.unReadUuIdList_, 1, -1 do
      if self.unReadUuIdList_[i] == mailUuid then
        table.remove(self.unReadUuIdList_, i)
      end
    end
  end
end

function MailData:AddNewMailUuid(mailUuid)
  table.insert(self.newUuidList_, mailUuid)
end

function MailData:RemoveNewMailUuid(mailUuid)
  table.zremoveByValue(self.newUuidList_, mailUuid)
end

function MailData:GetNewMailList()
  return self.newUuidList_
end

function MailData:GetNewMailCount()
  return #self.newUuidList_
end

function MailData:CheckMailVaild()
  for i = #self.list_, 1, -1 do
    if self.list_[i].mailUuid == 0 or not self.list_[i].mailUuid then
      table.remove(self.list_, i)
    end
  end
end

function MailData:GetMailList()
  return self.list_
end

function MailData:ClearMailList()
  self.list_ = {}
end

function MailData:AddMailData(mail, isNew)
  if self.list_ and #self.list_ > 0 then
    for i = 1, #self.list_ do
      if self.list_[i].mailUuid == mail.mailUuid then
        return
      end
    end
  end
  mail.isHaveAward = mail.awardIds and 0 < #mail.awardIds
  mail.isHaveAppendix = mail.appendix and 0 < #mail.appendix
  if isNew then
    table.insert(self.list_, 1, mail)
  else
    self.list_[#self.list_ + 1] = mail
  end
end

function MailData:RemoveMailBaseByIndex(index)
  table.remove(self.list_, index)
end

function MailData:RemoveMailByUuid(uuid)
  if self.list_ and #self.list_ > 1 then
    for i = #self.list_, 1, -1 do
      if self.list_[i].mailUuid == uuid then
        table.remove(self.list_, i)
        break
      end
    end
  end
end

function MailData:IsHaveMaillByUuid(uuid)
  if self.list_ and #self.list_ > 1 then
    for i = #self.list_, 1, -1 do
      if self.list_[i].mailUuid == uuid then
        return true
      end
    end
  end
  return false
end

function MailData:GetMailNum()
  return #self.list_
end

local getSortValue = function(data)
  local sortValue = 0
  if data.isCollect then
    sortValue = 1
  end
  if data.isHaveAward or data.isHaveAppendix then
    if data.mailState ~= mailGetState then
      sortValue = sortValue + 10
    end
  elseif data.mailState ~= mailReadState then
    sortValue = sortValue + 10
  end
  return sortValue
end
local sortFunc = function(left, right)
  local leftSortValue = getSortValue(left)
  local rightSortValue = getSortValue(right)
  if leftSortValue == rightSortValue then
    return left.createTime > right.createTime
  else
    return leftSortValue > rightSortValue
  end
end

function MailData:SortMailData()
  if not self.list_ or #self.list_ == 0 then
    return
  end
  table.sort(self.list_, sortFunc)
end

return MailData
