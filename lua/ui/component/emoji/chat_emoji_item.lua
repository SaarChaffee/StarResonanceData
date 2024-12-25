local super = require("ui.component.loop_grid_view_item")
local ChatEmojiItem = class("ChatEmojiItem", super)
local emojiPath = "ui/atlas/chat/emoji/"

function ChatEmojiItem:OnRefresh(data)
  self.res_ = data.Res
  self.id_ = data.Id
  local path = string.zconcat(emojiPath, self.res_)
  self.uiBinder.img_icon:SetImage(path)
end

function ChatEmojiItem:OnPointerClick(go, eventData)
  local msg = string.zconcat("emojiPic=%s=%s", self.res_, self.id_)
  self.parent.UIView:SendMessage(msg, E.ChitChatMsgType.EChatMsgPictureEmoji, self.id_)
end

return ChatEmojiItem
