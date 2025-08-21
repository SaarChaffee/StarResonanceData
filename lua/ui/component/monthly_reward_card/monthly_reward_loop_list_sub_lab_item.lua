local super = require("ui.component.loop_list_view_item")
local MonthlyRewardLoopListLabItem = class("MonthlyRewardLoopListLabItem", super)

function MonthlyRewardLoopListLabItem:OnInit()
end

function MonthlyRewardLoopListLabItem:OnRefresh(data)
  if not data then
    return
  end
  self.uiBinder.lab_figure.text = data.MonthCardPrivilegeConfig.SortId
  self.uiBinder.lab_name.text = data.MonthCardPrivilegeConfig.DesTitle
  local showText = data.MonthCardPrivilegeConfig.MonthCardDes
  self.uiBinder.lab_content.text = showText
  local size = self.uiBinder.lab_content:GetPreferredValues(showText, self.uiBinder.lab_content_ref.rect.width, 0)
  self.uiBinder.Trans:SetHeight(size.y + 70)
  self.loopListView:OnItemSizeChanged(self.Index)
end

function MonthlyRewardLoopListLabItem:OnUnInit()
end

return MonthlyRewardLoopListLabItem
