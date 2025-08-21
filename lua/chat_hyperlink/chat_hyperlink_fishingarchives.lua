local super = require("chat_hyperlink.chat_hyperlink_base")
local ChatHyperLinkFishingRank = class("ChatHyperLinkFishingRank", super)

function ChatHyperLinkFishingRank:ctor()
  super.ctor(self, E.ChatHyperLinkType.FishingArchives)
end

function ChatHyperLinkFishingRank:RefreshShareData(text1, data, text2, playerName, charId)
  local showContent = text1
  local startIndex, endIndex = self:CheckShareData(text1)
  local isHaveItemShare = startIndex ~= false
  self.shareDataProto_ = data
  if not isHaveItemShare then
    self.shareData_.string1 = text1
    self.shareData_.string2 = text2
  else
    if startIndex and 1 < startIndex then
      self.shareData_.string1 = string.sub(showContent, 1, startIndex - 1)
    end
    if endIndex and startIndex < endIndex then
      self.shareData_.string2 = string.sub(showContent, endIndex + 1)
    end
  end
  local playerName = playerName and playerName or Z.ContainerMgr.CharSerialize.charBase.name
  self.shareData_.playerName = playerName
  local param = {}
  param.fishing = {playerName = playerName}
  param.string = {}
  if self.shareData_.string1 and self.shareData_.string1 ~= "" then
    param.string[1] = Z.RichTextHelper.RemoveTagsOtherThanEmojis(self.shareData_.string1)
  end
  if self.shareData_.string2 and self.shareData_.string2 ~= "" then
    param.string[2] = Z.RichTextHelper.RemoveTagsOtherThanEmojis(self.shareData_.string2)
  end
  self.shareShowContent_ = Z.Placeholder.Placeholder(self.shareContent_, param)
  if self.chatHyperLinkRow_ and self.chatHyperLinkRow_.FunctionButtonEscape ~= "" then
    self.mainChatShareContent_ = self.chatHyperLinkRow_.FunctionButtonEscape
  else
    self.mainChatShareContent_ = Z.Placeholder.Placeholder(Z.RichTextHelper.RemoveStyleTag(self.shareContent_), param)
  end
  if self.chatHyperLinkRow_ and self.chatHyperLinkRow_.HudEscape ~= "" then
    self.hudShareContent_ = Z.Placeholder.Placeholder(self.chatHyperLinkRow_.HudEscape, param)
  else
    self.hudShareContent_ = self.shareShowContent_
  end
end

function ChatHyperLinkFishingRank:CheckShareData(text)
  if not self.shareData_.playerName then
    return false
  end
  local param = {}
  param.fishing = {
    playerName = self.shareData_.playerName
  }
  local shareContent = Z.Placeholder.Placeholder(self.shareContent_, param)
  shareContent = string.gsub(shareContent, "<link=1>", "")
  shareContent = string.gsub(shareContent, "</link>", "")
  return string.find(text, shareContent, 1, true)
end

return ChatHyperLinkFishingRank
