local super = require("ui.model.data_base")
local QuestSeasonData = class("QuestSeasonData", super)
E.SevenDayStargetType = {TitlePage = 1, Manual = 2}
E.SevenDayFuncType = {
  TitlePage = 1,
  Manual = 2,
  FuncPreview = 3
}

function QuestSeasonData:ctor()
  super.ctor(self)
end

function QuestSeasonData:Init()
  self.taskCfgs = nil
  self:Clear()
end

function QuestSeasonData:Clear()
  self.taskTable_ = {}
  self.taskDayTable_ = nil
  self.taskDayArray_ = nil
  self.curShowDay_ = 0
  self.taskCfgs = nil
  if self.dayTimeMgr then
    self.dayTimeMgr:Clear()
  end
  self.dayTimeMgr = Z.TimerMgr.new()
end

function QuestSeasonData:UnInit()
end

function QuestSeasonData:GetAllTaskCfg()
  if not self.taskCfgs then
    self.taskCfgs = Z.TableMgr.GetTable("SeasonTaskTableMgr").GetDatas()
  end
  return self.taskCfgs
end

function QuestSeasonData:OnLanguageChange()
  self.taskCfgs = nil
end

function QuestSeasonData:CreateTaskData(cfg, taskInfo, haveGet, notOpen)
  local data = {}
  data.id = cfg.TargetId
  data.targetNum = taskInfo.targetNum
  if haveGet then
    data.award = E.SevenDayTargetAwardState.hasGet
  elseif notOpen then
    data.award = E.SevenDayTargetAwardState.notOpen
  else
    local targetCfg = Z.TableMgr.GetTable("SeasonTaskTargetTableMgr").GetRow(cfg.Target)
    if targetCfg then
      data.award = taskInfo.targetNum >= targetCfg.Num and E.SevenDayTargetAwardState.canGet or E.SevenDayTargetAwardState.notFinish
    else
      logError("\228\187\187\229\138\161\231\154\132Target\229\173\151\230\174\181\230\137\190\228\184\141\229\136\176\230\149\176\230\141\174,Task: " .. cfg.TargetId .. "Target: " .. cfg.Target)
      data.award = nil
    end
  end
  if data.award and self.taskTable_ and self.taskTable_[cfg.OpenDay] then
    self.taskTable_[cfg.OpenDay][data.id] = data
  end
end

function QuestSeasonData:SetDayTable(tab)
  self.taskDayArray_ = tab
  self.taskDayTable_ = {}
  self.taskTable_ = {}
  for index, day in ipairs(tab) do
    self.taskDayTable_[day] = index
    self.taskTable_[#self.taskTable_ + 1] = {}
  end
end

function QuestSeasonData:getContainerTaskData()
  local dictTaskData = {}
  local data = Z.ContainerMgr.CharSerialize.seasonQuestList.seasonMap
  for _, v in pairs(data) do
    dictTaskData[v.id] = v
  end
  return dictTaskData
end

function QuestSeasonData:setTaskList(dictTask)
  local seasontaskdataList_ = Z.TableMgr.GetTable("SeasonTaskTableMgr").GetDatas()
  for _, cfg_ in pairs(seasontaskdataList_) do
    local taskinfo
    local haveGet = false
    local notOpen = false
    taskinfo = dictTask[cfg_.TargetId]
    if taskinfo == nil then
      local deepCount = 0
      taskinfo = self:getPreTaskInfo(cfg_, dictTask, deepCount)
    else
      haveGet = taskinfo.award == E.SevenDayTargetAwardState.hasGet
      notOpen = taskinfo.award == E.SevenDayTargetAwardState.notOpen
    end
    if taskinfo == nil then
      logError("\229\189\147\229\137\141\228\187\187\229\138\161\230\149\176\230\141\174\228\184\186\231\169\186\228\184\148\229\137\141\231\189\174\228\187\187\229\138\161\228\185\159\228\184\186\231\169\186,id: " .. cfg_.TargetId)
    else
      self:CreateTaskData(cfg_, taskinfo, haveGet, notOpen)
    end
  end
end

function QuestSeasonData:getPreTaskInfo(taskcfg, dictTask, deepCount)
  deepCount = deepCount + 1
  if taskcfg ~= nil and taskcfg.PreTargetId > 0 and deepCount < 20 then
    local preTask = dictTask[taskcfg.PreTargetId]
    local preCfg = Z.TableMgr.GetTable("SeasonTaskTableMgr").GetRow(taskcfg.PreTargetId)
    if preTask == nil then
      return self:getPreTaskInfo(preCfg, dictTask, deepCount)
    end
    return preTask
  end
  return nil
end

function QuestSeasonData:clearTaskData()
  for index = 1, #self.taskTable_ do
    self.taskTable_[index] = {}
  end
end

function QuestSeasonData:updateTaskData()
  self:clearTaskData()
  local dictTask = self:getContainerTaskData()
  self:setTaskList(dictTask)
end

function QuestSeasonData:GetDayTable()
  return self.taskDayTable_
end

function QuestSeasonData:GetDayArray()
  return self.taskDayArray_
end

function QuestSeasonData:GetTaskList(rebuild)
  local switchVM = Z.VMMgr.GetVM("switch")
  if not switchVM.CheckFuncSwitch(E.FunctionID.SeasonHandbook) then
    return {}
  end
  if rebuild then
    self:updateTaskData()
  end
  return self.taskTable_
end

function QuestSeasonData:GetStartServerTime()
  return Z.ContainerMgr.CharSerialize.charBase.createTime
end

function QuestSeasonData:SetShowDay(day)
  self.curShowDay_ = day
end

function QuestSeasonData:GetShowDay()
  return self.curShowDay_
end

function QuestSeasonData:OpenDayTimer(sec, call)
  self.dayTimeMgr:Clear()
  self.dayTimeMgr:StartTimer(call, sec, 1)
end

return QuestSeasonData
