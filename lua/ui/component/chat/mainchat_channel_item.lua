local super = require("ui.component.loop_list_view_item")
local MainChatChannelItem = class("MainChatChannelItem", super)

function MainChatChannelItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_name.text = Z.RichTextHelper.ApplyStyleTag(data.ChannelName, data.ChannelStyle)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function MainChatChannelItem:OnSelected(isSelected, isClick)
  if isSelected and isClick then
    self.parent.UIView:OnSelectChannel(self.data_)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

return MainChatChannelItem
