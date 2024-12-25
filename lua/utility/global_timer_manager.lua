local GlobalTimerManager = class("GlobalTimerManager")

function GlobalTimerManager:ctor()
  self.globalTimerDict_ = {}
  self.globalFrameTimerDict_ = {}
  self.timerMgr = Z.TimerMgr.new()
end

function GlobalTimerManager:StartTimer(key, func, duration, loop, unscaled, finishFunc)
  if not key then
    logError("globalTimer tag is nil")
    return
  end
  local keyStatus = key .. "_status"
  local keyTimer = key .. "_timer"
  if self.globalTimerDict_[keyStatus] then
    self:StopTimer(key)
  end
  self.globalTimerDict_[keyStatus] = true
  local timer = self.timerMgr:StartTimer(func, duration, loop, unscaled, function()
    if not self.globalTimerDict_[keyStatus] then
      return
    end
    if finishFunc then
      finishFunc()
    end
    self.globalTimerDict_[keyStatus] = nil
    self.timerMgr:StopTimer(self.globalTimerDict_[keyTimer])
    self.globalTimerDict_[keyTimer] = nil
  end)
  self.globalTimerDict_[keyTimer] = timer
end

function GlobalTimerManager:StopTimer(key)
  if not key then
    logError("globalTimer tag is nil")
    return
  end
  local keyTimer = key .. "_timer"
  self.timerMgr:StopTimer(self.globalTimerDict_[keyTimer])
end

function GlobalTimerManager:StartFrameTimer(key, func, count, loop)
  if not key then
    logError("globalTimer tag is nil")
    return
  end
  local keyStatus = key .. "_status"
  local keyTimer = key .. "_timer"
  if self.globalFrameTimerDict_[keyStatus] then
    self:StopFrameTimer(key)
  end
  self.globalFrameTimerDict_[keyStatus] = true
  local frameTimer = self.timerMgr:StartFrameTimer(func, count, loop, function()
    self:StopFrameTimer(key)
  end)
  self.globalFrameTimerDict_[keyTimer] = frameTimer
end

function GlobalTimerManager:StopFrameTimer(key)
  if not key then
    logError("globalTimer tag is nil")
    return
  end
  local keyStatus = key .. "_status"
  local keyTimer = key .. "_timer"
  if not self.globalFrameTimerDict_[keyStatus] then
    return
  end
  self.globalFrameTimerDict_[keyStatus] = nil
  self.timerMgr:StopFrameTimer(self.globalFrameTimerDict_[keyTimer])
  self.globalFrameTimerDict_[keyTimer] = nil
end

function GlobalTimerManager:Clear()
  self.timerMgr:Clear()
  self.globalTimerDict_ = {}
  self.globalFrameTimerDict_ = {}
end

function GlobalTimerManager:IsHaveTimer(key)
  local keyStatus = key .. "_status"
  return self.globalTimerDict_[keyStatus]
end

return GlobalTimerManager
