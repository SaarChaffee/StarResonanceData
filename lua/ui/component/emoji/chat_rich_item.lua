local super = require("ui.component.loop_grid_view_item")
local ChatRichItem = class("ChatRichItem", super)

function ChatRichItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_img.text = data
end

function ChatRichItem:OnPointerClick(go, eventData)
  self.parent.UIView:InputEmoji(self.data_)
end

return ChatRichItem
