local super = require("ui.component.loop_list_view_item")
local ChatBubbleSystemNotice = class("ChatBubbleSystemNotice", super)

function ChatBubbleSystemNotice:OnRefresh(data)
  if data == nil then
    return
  end
  local chatMainVm = Z.VMMgr.GetVM("chat_main")
  local showContent = chatMainVm.GetShowMsg(data, self.uiBinder.lab_tips, self.uiBinder.Trans)
  self.uiBinder.lab_tips.text = showContent
  local size = self.uiBinder.lab_tips:GetPreferredValues(showContent, self.uiBinder.Trans.rect.width, 40)
  local height = math.max(size.y + 3, 40)
  self.uiBinder.lab_tips_ref:SetHeight(height)
  self.uiBinder.Trans:SetHeight(height + 3)
  self.loopListView:OnItemSizeChanged(self.Index)
end

return ChatBubbleSystemNotice
