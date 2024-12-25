local super = require("ui.component.loop_list_view_item")
local ChatRecordItem = class("ChatRecordItem", super)

function ChatRecordItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_content.text = data.content
  local size = self.uiBinder.lab_content:GetPreferredValues(data.content, data.width, 31)
  self.uiBinder.lab_content_ref:SetWidth(size.x)
  self.uiBinder.lab_content_ref:SetHeight(size.y)
  self.uiBinder.Trans:SetWidth(size.x + 20)
  self.uiBinder.Trans:SetHeight(size.y + 20)
  self.loopListView:OnItemSizeChanged(self.Index)
end

function ChatRecordItem:OnSelected(isSelected)
end

function ChatRecordItem:OnPointerClick(go, eventData)
  self.parent.UIView:InputEmoji(self.data_.content)
end

return ChatRecordItem
