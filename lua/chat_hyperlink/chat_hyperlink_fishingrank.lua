local super = require("chat_hyperlink.chat_hyperlink_base")
local ChatHyperLinkFishingRank = class("ChatHyperLinkFishingRank", super)

function ChatHyperLinkFishingRank:ctor()
  super.ctor(self, E.ChatHyperLinkType.FishingRank)
end

function ChatHyperLinkFishingRank:RefreshShareData(text1, data, text2, playerName, charId)
  if data.FishId <= 0 then
    return
  end
  local fishCfg = Z.TableMgr.GetTable("FishingTableMgr").GetRow(data.FishId)
  if not fishCfg then
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
  local playerName = playerName and playerName or Z.ContainerMgr.CharSerialize.charBase.name
  self.shareData_.playerName = playerName
  self.shareData_.fishName = fishCfg.Name
  self.shareData_.rank = data.Rank
  local param = {}
  param.fishing = {
    playerName = playerName,
    fishName = fishCfg.Name,
    rank = data.Rank
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

function ChatHyperLinkFishingRank:CheckShareData(text)
  if not (self.shareData_.playerName and self.shareData_.fishName) or not self.shareData_.rank then
    return false
  end
  local param = {}
  param.fishing = {
    playerName = self.shareData_.playerName,
    fishName = self.shareData_.fishName,
    rank = self.shareData_.rank
  }
  local shareContent = Z.Placeholder.Placeholder(self.shareContent_, param)
  shareContent = string.gsub(shareContent, "<link=1>", "")
  shareContent = string.gsub(shareContent, "</link>", "")
  return string.find(text, shareContent, 1, true)
end

return ChatHyperLinkFishingRank
