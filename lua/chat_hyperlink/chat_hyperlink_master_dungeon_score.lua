local super = require("chat_hyperlink.chat_hyperlink_base")
local ChatHyperLinkMasterDungeonScore = class("ChatHyperLinkMasterDungeonScore", super)

function ChatHyperLinkMasterDungeonScore:ctor()
  super.ctor(self, E.ChatHyperLinkType.MasterDungeonScore)
end

function ChatHyperLinkMasterDungeonScore:RefreshShareData(text1, data, text2, playerName, charId)
  if data then
    self.shareData_.userName = data.userName
    self.shareData_.masterModeInfo = data.masterModeInfo
    self.shareData_.seasonId = data.seasonId
    self.shareData_.string1 = text1
    self.shareData_.string2 = text2
  else
    local showContent = text1
    self.shareData_.userName = Z.ContainerMgr.CharSerialize.charBase.name or ""
    local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
    self.shareData_.seasonId = seasonId
    self.shareData_.masterModeInfo = {}
    if Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.masterModeDungeonInfo[seasonId] then
      self.shareData_.masterModeInfo = Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.masterModeDungeonInfo[seasonId].masterModeDiffInfo
    end
    local nameParam = {
      player = {
        names = self.shareData_.userName
      },
      string = {
        [1] = "",
        [2] = ""
      }
    }
    local playerShareName = Z.Placeholder.Placeholder(self.shareContent_, nameParam)
    playerShareName = string.gsub(playerShareName, "<link=1>", "", 1)
    playerShareName = "%" .. string.gsub(playerShareName, "</link>", "", 1)
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
  local param = {
    player = {
      names = self.shareData_.userName
    }
  }
  param.string = {}
  if self.shareData_.string1 and self.shareData_.string1 ~= "" then
    param.string[1] = Z.RichTextHelper.RemoveAllTag(self.shareData_.string1)
  end
  if self.shareData_.string2 and self.shareData_.string2 ~= "" then
    param.string[2] = Z.RichTextHelper.RemoveAllTag(self.shareData_.string2)
  end
  self.shareShowContent_ = Z.Placeholder.Placeholder(self.shareContent_, param)
  self.noColorShareContent_ = Z.Placeholder.Placeholder(Z.RichTextHelper.RemoveStyleTag(self.shareContent_), param)
end

function ChatHyperLinkMasterDungeonScore:CheckShareData(text)
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

return ChatHyperLinkMasterDungeonScore
