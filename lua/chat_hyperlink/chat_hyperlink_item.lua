local super = require("chat_hyperlink.chat_hyperlink_base")
local ChatHyperLinkItem = class("ChatHyperLinkItem", super)

function ChatHyperLinkItem:ctor()
  super.ctor(self, E.ChatHyperLinkType.ItemShare)
  self.ItemShareColorTag = "item_share_quality_"
end

function ChatHyperLinkItem:RefreshShareData(text1, data, text2, playerName, charId)
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.configId)
  if not itemRow then
    return
  end
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
  local colorTag = string.zconcat(self.ItemShareColorTag, itemRow.Quality)
  local itemName = Z.RichTextHelper.ApplyStyleTag(itemRow.Name, colorTag)
  self.shareData_.itemName = itemName
  local param = {}
  param.item = {
    name = self.shareData_.itemName
  }
  param.string = {}
  if self.shareData_.string1 and self.shareData_.string1 ~= "" then
    param.string[1] = self.shareData_.string1
  end
  if self.shareData_.string2 and self.shareData_.string2 ~= "" then
    param.string[2] = self.shareData_.string2
  end
  self.shareShowContent_ = Z.Placeholder.Placeholder(self.shareContent_, param)
end

function ChatHyperLinkItem:CheckShareData(text)
  if not self.shareData_.itemName then
    return false
  end
  local itemShareName = string.zconcat(self.shareBeforeTag_, self.shareData_.itemName, self.shareAfterTag_)
  return string.find(text, itemShareName, 1, true)
end

return ChatHyperLinkItem
