local UI = Z.UI
local super = require("ui.ui_subview_base")
local Node_schedule_subView = class("Node_schedule_subView", super)

function Node_schedule_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "node_schedule_sub", "life_profession/node_schedule_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "node_schedule_sub", "life_profession/node_schedule_sub", UI.ECacheLv.None)
  end
end

function Node_schedule_subView:InitBinders()
  self.ingLab_ = self.uiBinder.lab_ing
  self.numLab_ = self.uiBinder.lab_num
  self.timeLab_ = self.uiBinder.lab_seconds
  self.ingImg_ = self.uiBinder.img_ing
  self.stopBtn_ = self.uiBinder.btn_stop
  self.btnLab_ = self.uiBinder.lab_btn
end

function Node_schedule_subView:InitUI()
  self:AddClick(self.stopBtn_, function()
    self:StopTime()
    if self.scheduleInfo_.stopFunc then
      self.scheduleInfo_.stopFunc()
    end
  end)
end

function Node_schedule_subView:StartTime()
  if self.castingTimer then
    self.timerMgr:StopTimer(self.castingTimer)
  end
  local castCount = self.scheduleInfo_.num or 0
  self.numLab_.text = math.ceil(castCount)
  local configTime = self.scheduleInfo_.time or Z.Global.CastingConfirmTime
  local castingTime = configTime
  local totalTime = configTime
  self.castingTimer = self.timerMgr:StartTimer(function()
    castingTime = castingTime - 0.05
    if 0 < castingTime then
      self.timeLab_.text = Lang("Second", {
        val = string.format("%0.1f", castingTime)
      })
      self.ingImg_.fillAmount = castingTime / totalTime
    elseif 1 < castCount then
      castCount = castCount - 1
      self.numLab_.text = math.ceil(castCount)
      castingTime = configTime
      if self.scheduleInfo_.everyTimeFinishFunc then
        self.scheduleInfo_.everyTimeFinishFunc()
      end
    else
      if self.castingTimer then
        self.timerMgr:StopTimer(self.castingTimer)
        self.castingTimer = nil
      end
      if self.scheduleInfo_.finishFunc then
        self.scheduleInfo_.finishFunc()
      end
      self.isCasting = false
    end
  end, 0.05, -1, nil, function()
    self.castingTimer = nil
  end, true)
end

function Node_schedule_subView:StopTime()
  if self.castingTimer then
    self.timerMgr:StopTimer(self.castingTimer)
    self.castingTimer = nil
  end
end

function Node_schedule_subView:OnActive()
  self:InitBinders()
  self:InitUI()
end

function Node_schedule_subView:OnDeActive()
end

function Node_schedule_subView:OnRefresh()
  self.scheduleInfo_ = self.viewData or {}
  self.ingLab_.text = self.scheduleInfo_.des or ""
  self.btnLab_.text = self.scheduleInfo_.stopLabContent or Lang("Stop")
  self:StartTime()
end

return Node_schedule_subView
