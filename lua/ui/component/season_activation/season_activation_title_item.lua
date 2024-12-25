local super = require("ui.component.loop_list_view_item")
local SeasonActivationTitleItem = class("SeasonActivationTitleItem", super)

function SeasonActivationTitleItem:OnInit()
end

function SeasonActivationTitleItem:OnRefresh(data)
  self.itemData_ = data
  self:resetItemState()
  if self.itemData_.Index == 1 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_title_1, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_title_2, true)
  end
end

function SeasonActivationTitleItem:resetItemState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_title_1, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_title_2, false)
end

function SeasonActivationTitleItem:OnUnInit()
end

return SeasonActivationTitleItem
