local super = require("ui.component.loop_list_view_item")
local UnionTaskLoopListItem = class("UnionTaskLoopListItem", super)
local colorTexts_ = {
  [1] = "  <color=#FF6300>%s</color>",
  [3] = "  <color=#EE983D>%s</color>"
}

function UnionTaskLoopListItem:OnInit()
  self.parentUIView_ = self.parent.UIView
end

function UnionTaskLoopListItem:OnRefresh(data)
  local offsetNum = self.parentUIView_:GetPriceOffsetNum(data.OffsetType)
  local result = (offsetNum - 1) * 100
  local offsetType = data.OffsetType
  local resultStr = ""
  if offsetType ~= 2 then
    local s = 0 < result and "+" or ""
    resultStr = string.format(colorTexts_[offsetType], s .. string.format("%.0f", result) .. "%")
  end
  local str_ = self.parentUIView_:GetTitleStr(data.OffsetType) .. resultStr
  self.uiBinder.lab_title.text = str_
end

function UnionTaskLoopListItem:OnUnInit()
end

return UnionTaskLoopListItem
