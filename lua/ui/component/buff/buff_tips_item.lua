local super = require("ui.component.loop_list_view_item")
local BuffTipsItem = class("BuffTipsItem", super)

function BuffTipsItem:OnInit()
end

function BuffTipsItem:OnUnInit()
end

function BuffTipsItem:OnRefresh(data)
  self.uiBinder.img_icon:SetImage(data.Icon)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_digit, data.Layer > 1)
  self.uiBinder.lab_digit.text = data.Layer
  self.uiBinder.lab_name.text = data.Name
  self.uiBinder.lab_level.text = Lang("Level", {
    val = data.Level
  })
  local size = self.uiBinder.lab_info:GetPreferredValues(data.Desc, 402, 31)
  self.uiBinder.lab_info.text = data.Desc
  if not data.DurationTime or data.DurationTime <= 0 then
    self.uiBinder.lab_time.text = ""
    self.uiBinder.img_progress:Stop()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_progress, false)
  else
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
  end
  local offset = 0
  if self.Index == #self.parent.DataList then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, true)
    offset = 23
  end
  self.uiBinder.Trans:SetHeight(72 + size.y + offset)
  self.uiBinder.img_line:SetAnchorPosition(0, 10)
  self.uiBinder.img_line:SetAnchors(0.5, 0.5, 0, 0)
  self.loopListView:OnItemSizeChanged(self.Index)
end

return BuffTipsItem
