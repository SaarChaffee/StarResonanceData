local TimerManager = class("TimerManager")

function TimerManager:ctor()
  self.timers = {}
  self.frameTimers = {}
  self.coroTimers = {}
end

function TimerManager:StartTimer(func, duration, loop, unscaled, finishFunc, immediate)
  unscaled = unscaled == nil and true or unscaled
  loop = tonumber(loop) == nil and 1 or loop
  local timer = Timer.New(func, duration, loop, unscaled, finishFunc)
  timer:Start()
  table.insert(self.timers, timer)
  if immediate then
    func()
  end
  return timer
end

function TimerManager:StopTimer(timer)
  if timer == nil then
    return
  end
  timer:Stop()
  table.zremoveByValue(self.timers, timer)
end

function TimerManager:Reset(timer, func, duration, loop, unscaled, finishFunc)
  if timer == nil then
    return
  end
  timer:Reset(func, duration, loop, unscaled, finishFunc)
end

function TimerManager:StartFrameTimer(func, count, loop, finishFunc, immediate)
  loop = tonumber(loop) == nil and 1 or loop
  local timer = FrameTimer.New(func, count, loop, finishFunc)
  timer:Start()
  table.insert(self.frameTimers, timer)
  if immediate then
    func()
  end
  return timer
end

function TimerManager:StopFrameTimer(timer)
  if timer == nil then
    return
  end
  timer:Stop()
  table.zremoveByValue(self.frameTimers, timer)
end

function TimerManager:Clear()
  for _, timer in ipairs(self.timers) do
    timer:Stop()
  end
  self.timers = {}
  for _, frameTimer in ipairs(self.frameTimers) do
    frameTimer:Stop()
  end
  self.frameTimers = {}
  for _, coroTimer in ipairs(self.coroTimers) do
    coroTimer:Stop()
  end
  self.coroTimers = {}
end

return TimerManager
