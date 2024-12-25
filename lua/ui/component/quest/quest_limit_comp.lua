local LimitType = {
  roleLv = 1,
  itmeNum = 11,
  date = 80,
  questStep = 21
}
local QuestLimitComp = class("QuestLimitComp")

function QuestLimitComp:ctor(parentView, funcDict)
  self.parent_ = parentView
  self.funcDict_ = funcDict
  self.questVM_ = Z.VMMgr.GetVM("quest")
  self.limitGroup = {}
  self.datetimer = {}
end

function QuestLimitComp:Init(questId)
  if not questId or questId <= 0 then
    self:UnInit()
    return
  end
  self.questTableRow_ = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if self.questTableRow_ == nil then
    return
  end
  self.questId_ = questId
  self.isActive_ = true
  self.limitGroup = {}
  self:classificationType()
  self:initTimer()
  self:CheckItemCountLimit()
  self:checkDateTime()
  self:CheckRoleLv()
  self:checkQuestStep()
end

function QuestLimitComp:UnInit()
  self.questId_ = nil
  self.isActive_ = false
  self.parent_.timerMgr:StopTimer(self.timeLimitTimer_)
  self.timeLimitTimer_ = nil
  for _, timer in pairs(self.datetimer) do
    self.parent_.timerMgr:StopTimer(timer)
  end
  self.datetimer = {}
end

function QuestLimitComp:classificationType()
  local countLimit = self.questTableRow_.ContinueLimit
  if #countLimit ~= 0 then
    for i = 1, #countLimit do
      local limitData = countLimit[i]
      if self.limitGroup[tonumber(limitData[1])] == nil then
        self.limitGroup[tonumber(limitData[1])] = {}
      end
      table.insert(self.limitGroup[tonumber(limitData[1])], limitData)
    end
  end
end

function QuestLimitComp:CheckItemCountLimit()
  if not self.isActive_ then
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  local countLimit = self.limitGroup[LimitType.itmeNum]
  if countLimit ~= nil then
    for i = 1, #countLimit do
      local limitData = countLimit[i]
      local configId = tonumber(limitData[2])
      local minNum = tonumber(limitData[3])
      local ownNum = itemsVM.GetItemTotalCount(configId)
      if minNum > ownNum then
        self.funcDict_.itemCount(i, 1)
      else
        self.funcDict_.itemCount(i, 2)
      end
    end
  end
end

function QuestLimitComp:initTimer()
  self.parent_.timerMgr:StopTimer(self.timeLimitTimer_)
  self.timeLimitTimer_ = nil
  self.startTime_ = nil
  self.endTime_ = nil
  local timeLimit = self.questTableRow_.TimeLimit
  if timeLimit[1] then
    self.startTime_ = Z.TimeTools.Format2Tp(timeLimit[1])
  end
  if timeLimit[2] then
    self.endTime_ = Z.TimeTools.Format2Tp(timeLimit[2])
  end
  if self.startTime_ or self.endTime_ then
    self.timeLimitTimer_ = self.parent_.timerMgr:StartTimer(function()
      self:checkTimeLimit()
    end, 1, -1)
  end
end

function QuestLimitComp:checkTimeLimit()
  local serverTime = Z.ServerTime:GetServerTime()
  if self.startTime_ and serverTime < self.startTime_ then
    self.funcDict_.time(1)
    return
  end
  if self.endTime_ and serverTime > self.endTime_ then
    self.funcDict_.time(2)
    return
  end
  self.funcDict_.time(0)
end

function QuestLimitComp:checkDateTime()
  local serverTime = Z.ServerTime:GetServerTime() / 1000
  local countLimit = self.limitGroup[LimitType.date]
  if countLimit ~= nil then
    for i = 1, #countLimit do
      local limitData = countLimit[i]
      local dateStr = limitData[2]
      local configTime = Z.TimeTools.Format2Tp(dateStr) / 1000
      local dateSce = math.floor(configTime - serverTime)
      if 0 < dateSce then
        self.funcDict_.date(i, 1, dateSce)
      else
        self.funcDict_.date(i, 2, dateSce)
      end
    end
  end
end

function QuestLimitComp:CheckRoleLv()
  local countLimit = self.limitGroup[LimitType.roleLv]
  if countLimit ~= nil then
    for i = 1, #countLimit do
      local limitData = countLimit[i]
      local lvLimit = tonumber(limitData[2])
      local pLv = Z.ContainerMgr.CharSerialize.roleLevel.level
      if lvLimit > pLv then
        self.funcDict_.roleLv(i, 1, lvLimit)
      else
        self.funcDict_.roleLv(i, 2, 0)
      end
    end
  end
end

function QuestLimitComp:checkQuestStep()
  local countLimit = self.limitGroup[LimitType.questStep]
  if countLimit ~= nil then
    for i = 1, #countLimit do
      local limitData = countLimit[i]
      local questId = tonumber(limitData[2])
      local questStep = tonumber(limitData[3])
      local isFinish = self.questVM_.IsQuestStepFinish(questId, questStep)
      if not isFinish then
        self.funcDict_.questStep(i, 1, questId)
      else
        self.funcDict_.questStep(i, 2, questId)
      end
    end
  end
end

return QuestLimitComp
