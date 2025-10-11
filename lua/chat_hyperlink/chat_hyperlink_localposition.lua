local super = require("chat_hyperlink.chat_hyperlink_base")
local ChatHyperLinkLocalPosition = class("ChatHyperLinkLocalPosition", super)

function ChatHyperLinkLocalPosition:ctor()
  super.ctor(self, E.ChatHyperLinkType.LocalPosition)
end

function ChatHyperLinkLocalPosition:RefreshShareData(text1, data, text2)
  local showContent = text1
  local startIndex, endIndex = self:CheckShareData(text1)
  local isHaveItemShare = startIndex ~= false
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
  local param = {}
  param.string = {}
  if self.shareData_.string1 and self.shareData_.string1 ~= "" then
    param.string[1] = Z.RichTextHelper.RemoveTagsOtherThanEmojis(self.shareData_.string1)
  else
    param.string[1] = ""
  end
  if self.shareData_.string2 and self.shareData_.string2 ~= "" then
    param.string[2] = Z.RichTextHelper.RemoveTagsOtherThanEmojis(self.shareData_.string2)
  else
    param.string[2] = ""
  end
  if data then
    local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(data.SceneId)
    if not sceneRow or not Z.EntityMgr.PlayerEnt then
      return
    end
    self.shareData_.position = string.zconcat(sceneRow.Name, " ", Lang("Line", {
      val = data.LineId
    }), "\239\188\136", data.PositionX, "\239\188\140", data.PositionY, "\239\188\140", data.PositionZ, "\239\188\137")
    self.paramList_ = {
      data.SceneId,
      data.LineId,
      data.PositionX,
      data.PositionY,
      data.PositionZ
    }
    param.scence = {
      name = sceneRow.Name
    }
    param.val1 = data.LineId
    param.val2 = data.PositionX
    param.val3 = data.PositionY
    param.val4 = data.PositionZ
  else
    local sceneId = Z.StageMgr.GetCurrentSceneId()
    local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
    if not sceneRow or not Z.EntityMgr.PlayerEnt then
      return
    end
    local sceneLineData = Z.DataMgr.Get("sceneline_data")
    local lineName = ""
    local lineId = 0
    if sceneLineData.PlayerLineId then
      local param = {
        val = sceneLineData.PlayerLineId
      }
      lineId = sceneLineData.PlayerLineId
      lineName = Lang("Line", param)
    end
    local playerServerPos = Z.EntityMgr.PlayerEnt:GetLuaAttrPos()
    local x = math.ceil(playerServerPos.x)
    local y = math.ceil(playerServerPos.y)
    local z = math.ceil(playerServerPos.z)
    self.shareData_.position = string.zconcat(sceneRow.Name, " ", lineName, "\239\188\136", x, "\239\188\140", y, "\239\188\140", z, "\239\188\137")
    self.paramList_ = {
      sceneId,
      lineId,
      x,
      y,
      z
    }
    param.scence = {
      name = sceneRow.Name
    }
    param.val1 = lineId
    param.val2 = x
    param.val3 = y
    param.val4 = z
  end
  self.shareShowContent_ = Z.Placeholder.Placeholder(self.shareContent_, param)
  if self.chatHyperLinkRow_ and self.chatHyperLinkRow_.HudEscape ~= "" then
    self.hudShareContent_ = Z.Placeholder.Placeholder(self.chatHyperLinkRow_.HudEscape, param)
  else
    self.hudShareContent_ = self.shareShowContent_
  end
  self.mainChatShareContent_ = Z.Placeholder.Placeholder(self.shareContent_, param)
end

function ChatHyperLinkLocalPosition:CheckShareData(text)
  if not self.shareData_.position then
    return false
  end
  local positionContent = string.zconcat(self.shareBeforeTag_, self.shareData_.position, self.shareAfterTag_)
  return string.find(text, positionContent, 1, true)
end

return ChatHyperLinkLocalPosition
