local super = require("ui.component.loop_list_view_item")
local BuffItem = class("BuffTipsItem", super)

function BuffItem:OnInit()
end

function BuffItem:OnUnInit()
end

function BuffItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_icon:SetImage(data.Icon)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, true)
  if data.Layer > 1 then
    self.uiBinder.lab_digit.text = data.Layer
  else
    self.uiBinder.lab_digit.text = ""
  end
  if data.DurationTime and data.DurationTime > 0 then
    local nowTime = Z.NumTools.GetPreciseDecimal(Z.ServerTime:GetServerTime() / 1000, 1)
    local nowValue = nowTime - data.CreateTime
    local begin
    if data.BuffTime and 0 < data.BuffTime and data.DurationTime > data.BuffTime then
      begin = 1 - (nowValue - (data.DurationTime - data.BuffTime)) / data.BuffTime
    else
      begin = 1 - nowValue / data.DurationTime
    end
    self.uiBinder.img_progress:Play(begin, 0, data.DurationTime - nowValue, nil, data.BuffTime)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_progress, true)
  else
    self.uiBinder.img_progress:Stop()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_progress, false)
  end
end

function BuffItem:OnPointerClick(go, eventData)
  self.parent.UIView:OnClickBuff(self.data_)
end

return BuffItem
