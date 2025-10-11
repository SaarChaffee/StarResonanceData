local super = require("ui.component.loop_grid_view_item")
local ChatQuickMessageItem = class("ChatQuickMessageItem", super)

function ChatQuickMessageItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_content.text = data.Text
end

function ChatQuickMessageItem:OnPointerClick(go, eventData)
  self.parent.UIView:SendMessage("", E.ChitChatMsgType.EChatMsgPictureEmoji, self.data_.Id)
end

return ChatQuickMessageItem
