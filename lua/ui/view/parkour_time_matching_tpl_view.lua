local Parkour_time_matching_tplView = class("Parkour_time_matching_tplView")

function Parkour_time_matching_tplView:ctor()
end

function Parkour_time_matching_tplView:Init(go)
  self.unit = UICompBindLua(go)
  self.unit.Ref:SetOffSetMin(0, 0)
  self.unit.Ref:SetOffSetMax(0, 0)
  self.lab_num = self.unit.lab_time_num
  self.lab_num_enter = self.unit.lab_num_enter
  self.lab_matching = self.unit.lab_matching
  self.btn_return = self.unit.cont_btn_return.btn
  self.btn_return.Btn:AddListener(function()
    self:OnCloseClick()
  end)
  self:SetData()
end

function Parkour_time_matching_tplView:DeActive()
  if self.timer then
    self.timerMgr:StopTimer(self.timer)
    self.timer = nil
  end
end

function Parkour_time_matching_tplView:CountDownFunc()
  if not self.viewData then
    return
  end
  if self.timer then
  end
  self.timer = self.timerMgr:StartTimer(function()
    self.lab_num = 10 * self.viewData.DurationTime
  end, 0.1, 10 * self.viewData.DurationTime, true, function()
  end)
end

function Parkour_time_matching_tplView:OnCloseClick()
end

function Parkour_time_matching_tplView:SetData()
  if not self.viewData then
    return
  end
end

return Parkour_time_matching_tplView
