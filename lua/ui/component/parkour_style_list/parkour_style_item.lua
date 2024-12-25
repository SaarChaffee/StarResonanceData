local ParkourStyleItem = class("ParkourStyleItem")
local LevelToScore = {
  [0] = "normal",
  [1] = "b",
  [2] = "a",
  [3] = "s"
}
local WhiteColor = Color.New(1, 1, 1, 1)
local LevelToColor = {
  [0] = Color.New(0.7333333333333333, 0.7333333333333333, 0.7333333333333333, 1),
  [1] = Color.New(0.3607843137254902, 0.6980392156862745, 0.8941176470588236, 1),
  [2] = Color.New(0.8862745098039215, 0.7254901960784313, 1.0, 1),
  [3] = Color.New(1.0, 0.8745098039215686, 0.615686274509804, 1)
}
local ParkourListItemPath = {
  [1] = "ui/prefabs/parkour/parkour_list_item_tpl_pc",
  [2] = "ui/prefabs/parkour/parkour_list_item_tpl"
}

function ParkourStyleItem:ctor(panel, key, id)
  self.panel_ = panel
  self.parent_ = panel.panel.parkour_list_pos
  self.curState_ = E.ParkourStyleItemLifeCycle.None
  self.nextState_ = E.ParkourStyleItemLifeCycle.None
  self.configId_ = id
  self.liveDuration_ = 0
  self.liveTime = 0.2
  self.liveTimerIsStop = false
  self.entranceTime = 0.3
  self.exitTime = 0.2
  self.key_ = key
  self.timerMgr = Z.TimerMgr.new()
  self.liveTimer = nil
  self.TimerStep = 0.05
  self:createUIUnit()
end

function ParkourStyleItem:createUIUnit()
  Z.CoroUtil.create_coro_xpcall(function()
    local cancelSource = self.panel_.cancelSource:CreateToken()
    if not self.uiUnit_ then
      local path = Z.IsPCUI and ParkourListItemPath[1] or ParkourListItemPath[2]
      self.uiUnit_ = self.panel_:AsyncLoadUiUnit(path, self.key_, self.parent_.Trans)
      if Z.CancelSource.IsCanceled(cancelSource) or not self.uiUnit_ then
        return
      end
      self:OnActive()
    end
  end)()
end

function ParkourStyleItem:OnActive()
  local row = Z.TableMgr.GetTable("ParkourStyleActionTableMgr").GetRow(self.configId_)
  if row == nil then
    return
  end
  self.liveTime = row.WaitTime
  self.uiUnit_.lab_name.TMPLab.text = row.Name
  if row.Level >= 0 then
    self.uiUnit_.layout_bg:SetVisible(true)
    self.uiUnit_.layout_bg.Img:SetImage("ui/atlas/world_parkour/parkour_list_" .. LevelToScore[row.Level])
    self.uiUnit_.lab_name.TMPLab:SetGradientColor(WhiteColor, LevelToColor[row.Level])
  else
    self.uiUnit_.layout_bg:SetVisible(false)
  end
  self.uiUnit_.node_root.Ref.CanvasGroup.alpha = 1
  self:DoEntrance()
  if self.configId_ then
    Z.EventMgr:Dispatch(Z.ConstValue.Parkour.QteRecovery, self.configId_)
  end
end

function ParkourStyleItem:GetState()
  return self.curState_
end

function ParkourStyleItem:SetState(state)
  self.nextState_ = state
end

function ParkourStyleItem:DoEntrance()
  if self.curState_ == E.ParkourStyleItemLifeCycle.Entrance then
    return
  end
  self.uiUnit_.node_root.TweenContainer:Restart(Z.DOTweenAnimType.Open)
  self.curState_ = E.ParkourStyleItemLifeCycle.Entrance
  self.nextState_ = E.ParkourStyleItemLifeCycle.Stay
  self.timerMgr:StartTimer(function()
    self:SwitchState()
  end, self.entranceTime)
end

function ParkourStyleItem:DoLive()
  if self.curState_ == E.ParkourStyleItemLifeCycle.Stay then
    return
  end
  self.curState_ = E.ParkourStyleItemLifeCycle.Stay
  self.timerMgr:StartTimer(function()
    self.liveDuration_ = self.liveDuration_ + self.TimerStep
    if self.curState_ ~= self.nextState_ then
      self:SwitchState()
    end
    if self.liveDuration_ >= self.liveTime - self.TimerStep and self.nextState_ <= E.ParkourStyleItemLifeCycle.Exit then
      self.nextState_ = E.ParkourStyleItemLifeCycle.Exit
    end
  end, self.TimerStep, math.floor(self.liveTime / self.TimerStep) + 1)
end

function ParkourStyleItem:DoExit()
  if self.curState_ == E.ParkourStyleItemLifeCycle.Exit then
    return
  end
  self.curState_ = E.ParkourStyleItemLifeCycle.Exit
  self.nextState_ = E.ParkourStyleItemLifeCycle.Death
  self.uiUnit_.node_root.TweenContainer:Restart(Z.DOTweenAnimType.Close)
  self.timerMgr:StartTimer(function()
    self.curState_ = self.nextState_
    Z.EventMgr:Dispatch("ShowNextParkourItem")
  end, self.exitTime)
end

function ParkourStyleItem:SwitchState()
  if self.nextState_ == E.ParkourStyleItemLifeCycle.Entrance then
    self:DoEntrance()
  elseif self.nextState_ == E.ParkourStyleItemLifeCycle.Stay then
    self:DoLive()
  elseif self.nextState_ == E.ParkourStyleItemLifeCycle.Exit then
    self:DoExit()
  end
end

function ParkourStyleItem:Destroy()
  self.curState_ = E.ParkourStyleItemLifeCycle.Death
  if self.timerMgr ~= nil then
    self.timerMgr:Clear()
  end
  self.timerMgr = nil
  if self.panel_ ~= nil then
    self.panel_:RemoveUiUnit(self.key_)
  end
  self.uiUnit_ = nil
end

return ParkourStyleItem
