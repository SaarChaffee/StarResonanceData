local super = require("ui.component.loop_list_view_item")
local ChatRecordItem = class("ChatRecordItem", super)

function ChatRecordItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_content.text = data.content
  local size = self.uiBinder.lab_content:GetPreferredValues(data.content, data.width, 31)
  local offest = Z.IsPCUI and 10 or 20
  self.uiBinder.Trans:SetWidth(size.x + offest)
  self.uiBinder.Trans:SetHeight(size.y + offest)
  self.loopListView:OnItemSizeChanged(self.Index)
end

function ChatRecordItem:OnPointerClick(go, eventData)
  self.parent.UIView:InputEmoji(self.data_.content)
end

return ChatRecordItem
