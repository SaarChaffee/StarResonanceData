local super = require("ui.component.loop_list_view_item")
local ChatChannelTabPC = class("ChatChannelTabPC", super)

function ChatChannelTabPC:OnRefresh(data)
  self:refreshState()
  self.data_ = data
  self.uiBinder.lab_on.text = data.ChannelName
  self.uiBinder.lab_off.text = data.ChannelName
end

function ChatChannelTabPC:OnSelected(isSelected, isClick)
  self:refreshState()
  self.parent.UIView:OnSelectChannel(self.data_)
end

function ChatChannelTabPC:refreshState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_off, not self.IsSelected)
end

return ChatChannelTabPC
