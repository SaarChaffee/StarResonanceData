local super = require("ui.component.chat.chat_bubble_base")
local uiPath = "ui/atlas/chat/emoji/"
local ChatBubblePicture = class("ChatBubblePicture", super)

function ChatBubblePicture:OnRefresh(data)
  super.OnRefresh(self, data)
  self:refreshPicture()
end

function ChatBubblePicture:refreshPicture()
  local emojiName = self.chatMainVm_.GetEmojiName(Z.ChatMsgHelper.GetEmojiConfigId(self.data_))
  local path = string.format("%s%s", uiPath, emojiName)
  self.uiBinder.img_pic:SetImage(path)
end

return ChatBubblePicture
