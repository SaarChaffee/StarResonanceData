local super = require("ui.component.loop_list_view_item")
local MainChatBubbleTipsItem = class("MainChatBubbleTipsItem", super)

function MainChatBubbleTipsItem:OnInit()
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
end

function MainChatBubbleTipsItem:OnRefresh(data)
  local content = self.chatMainVm_.GetShowMsg(data)
  local systemType = Z.ChatMsgHelper.GetSystemType(data)
  if systemType == E.ESystemTipInfoType.ItemInfo then
    content = string.zconcat(Lang("ChaBubbleGet"), content)
  end
  self.uiBinder.lab_info.text = content
  local size = self.uiBinder.lab_info:GetPreferredValues(content, 283, 16)
  local height = math.max(size.y, 16)
  self.uiBinder.img_pic_ref:SetHeight(height)
  self.uiBinder.Trans:SetHeight(height + 5)
  self.loopListView:OnItemSizeChanged(self.Index)
end

return MainChatBubbleTipsItem
