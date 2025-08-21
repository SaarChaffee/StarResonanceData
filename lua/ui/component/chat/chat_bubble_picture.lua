local super = require("ui.component.chat.chat_bubble_base")
local ChatBubblePicture = class("ChatBubblePicture", super)

function ChatBubblePicture:OnRefresh(data)
  super.OnRefresh(self, data)
  self:refreshPicture(data)
end

function ChatBubblePicture:refreshPicture(data)
  local emojiName = self.chatMainVm_.GetEmojiName(Z.ChatMsgHelper.GetEmojiConfigId(data))
  if emojiName == "" or emojiName == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_pic, false)
  self.uiBinder.rimg_pic:SetImageWithCallback(emojiName, function()
    if not self.uiBinder then
      return
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_pic, true)
  end)
  if self.uiBinder.content_fitter then
    self.uiBinder.content_fitter:RefreshRectSize(self.channelHuntNameWidth_)
  end
end

return ChatBubblePicture
