local super = require("chat_hyperlink.chat_hyperlink_base")
local ChatHyperLinkPersonalzoneData = class("ChatHyperLinkPersonalzoneData", super)

function ChatHyperLinkPersonalzoneData:ctor()
  super.ctor(self, E.ChatHyperLinkType.PersonalZone)
end

function ChatHyperLinkPersonalzoneData:RefreshShareData(text1, data, text2, playerName, charId)
  if data then
    self.shareData_.playerName = data.name
    self.shareData_.charId = data.charId
    self.shareData_.string1 = text1
    self.shareData_.string2 = text2
  else
    local showContent = text1
    self.shareData_.playerName = Z.ContainerMgr.CharSerialize.charBase.name or ""
    local nameParam = {
      player = {
        names = self.shareData_.playerName
      },
      string = {
        [1] = "",
        [2] = ""
      }
    }
    local playerShareName = Z.Placeholder.Placeholder(self.shareContent_, nameParam)
    playerShareName = string.gsub(playerShareName, "<link=1>", "", 1)
    playerShareName = "%" .. string.gsub(playerShareName, "</link>", "", 1)
    local isHaveItemShare = string.find(showContent, playerShareName)
    if not isHaveItemShare then
      self.shareData_.string1 = text1
      self.shareData_.string2 = text2
    else
      local startIndex, endIndex = string.find(showContent, playerShareName)
      if startIndex and 1 < startIndex then
        self.shareData_.string1 = string.sub(showContent, 1, startIndex - 1)
      else
        self.shareData_.string1 = ""
      end
      if endIndex and startIndex < endIndex then
        self.shareData_.string2 = string.sub(showContent, endIndex + 1)
      end
    end
  end
  local param = {
    player = {
      names = self.shareData_.playerName
    }
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

function ChatHyperLinkPersonalzoneData:CheckShareData(text)
  local param = {
    player = {
      names = self.shareData_.playerName
    },
    string = {
      [1] = "",
      [2] = ""
    }
  }
  local itemShareName = Z.Placeholder.Placeholder(self.shareContent_, param)
  return string.find(text, itemShareName)
end

return ChatHyperLinkPersonalzoneData
