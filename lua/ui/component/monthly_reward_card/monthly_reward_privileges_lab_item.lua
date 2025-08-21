local super = require("ui.component.loop_list_view_item")
local MonthlyRewardPrivilegesLabItem = class("MonthlyRewardPrivilegesLabItem", super)

function MonthlyRewardPrivilegesLabItem:OnInit()
end

function MonthlyRewardPrivilegesLabItem:OnRefresh(data)
  if not data then
    return
  end
  self.uiBinder.lab_content.text = data
  local size = self.uiBinder.lab_content:GetPreferredValues(data, self.uiBinder.lab_content_ref.rect.width, 0)
  self.uiBinder.Trans:SetHeight(size.y + 5)
  self.loopListView:OnItemSizeChanged(self.Index)
end

function MonthlyRewardPrivilegesLabItem:OnUnInit()
end

return MonthlyRewardPrivilegesLabItem
