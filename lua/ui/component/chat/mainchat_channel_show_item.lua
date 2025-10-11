local super = require("ui.component.loop_list_view_item")
local MainChatChannelShowItem = class("MainChatChannelShowItem", super)

function MainChatChannelShowItem:OnRefresh(data)
  self.data_ = data
  local channelImg = Z.ChatMsgHelper.GetChatChannelIconByChannelId(data.Id)
  self.uiBinder.img_icon_on:SetImage(channelImg)
  self.uiBinder.img_icon_off:SetImage(channelImg)
  self:refreshSelect()
end

function MainChatChannelShowItem:OnSelected(isSelected, isClick)
  if isSelected and isClick then
    self.parent.UIView:OnSelectShowChannel(self.data_)
  end
  self:refreshSelect()
end

function MainChatChannelShowItem:refreshSelect()
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_off, not self.IsSelected)
end

return MainChatChannelShowItem
