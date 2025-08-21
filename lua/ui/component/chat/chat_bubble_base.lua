local super = require("ui.component.loop_list_view_item")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local ChatBubbleBase = class("ChatBubbleBase", super)

function ChatBubbleBase:OnInit()
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.friendMainVm_ = Z.VMMgr.GetVM("friends_main")
  self:AddAsyncListener(self.uiBinder.img_bg, function()
    local charId = Z.ChatMsgHelper.GetCharId(self.data_)
    if charId and type(charId) == "number" and 0 < charId then
      Z.VMMgr.GetVM("idcard").AsyncGetCardData(charId, self.parent.UIView.cancelSource:CreateToken())
    end
  end)
end

function ChatBubbleBase:OnRefresh(data)
  if data == nil then
    return
  end
  self.data_ = data
  self.channelHuntNameWidth_ = 0
  self:refreshChannelName()
  self:refreshChannelImage()
  self:refreshHuntTitle()
  self:refreshPlayerNewbie()
  self:refreshPlayerlName()
  self:refreshSendTime()
  self:refreshSelfHead()
end

function ChatBubbleBase:OnUnInit()
  if not self.uiBinder.lab_channel then
    return
  end
  self.uiBinder.lab_channel.text = ""
end

function ChatBubbleBase:refreshSelfHead()
  local charId = Z.ChatMsgHelper.GetCharId(self.data_)
  if 0 < charId then
    playerPortraitHgr.LoadSocialDataByCharId(Z.ChatMsgHelper.GetCharId(self.data_), function(charId, socialData)
      if Z.ChatMsgHelper.GetCharId(self.data_) ~= charId or not self.uiBinder then
        return
      end
      playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.node_player_head, socialData, nil, self.parent.UIView.cancelSource:CreateToken())
    end)
  else
    local chatHyperLink = Z.ChatMsgHelper.GetChatHyperlink(self.data_)
    if chatHyperLink and chatHyperLink.ResourceRoute ~= "" then
      playerPortraitHgr.InsertNewPortraitByHeadPath(self.uiBinder.node_player_head, chatHyperLink.ResourceRoute)
    end
  end
end

function ChatBubbleBase:refreshChannelName()
  if not self.uiBinder.lab_channel then
    return
  end
  self.isShowChannelOrName_ = false
  if self.parent.UIView:IsComprehensive() then
    local channelId = Z.ChatMsgHelper.GetChannelId(self.data_)
    local config = self.chatMainData_:GetConfigData(channelId)
    if config then
      local channelName = Z.RichTextHelper.ApplyStyleTag(string.format("[%s]", config.ChannelName), config.ChannelStyle)
      self.uiBinder.lab_channel.text = channelName
      local size = self.uiBinder.lab_channel:GetPreferredValues(channelName, 65, 30)
      self.uiBinder.lab_channel_ref:SetWidth(size.x)
      self.isShowChannelOrName_ = true
    else
      self.uiBinder.lab_channel.text = ""
      self.uiBinder.lab_channel_ref:SetWidth(0)
    end
  else
    self.uiBinder.lab_channel.text = ""
    self.uiBinder.lab_channel_ref:SetWidth(0)
  end
end

function ChatBubbleBase:refreshChannelImage()
  if not self.uiBinder.img_channel then
    return
  end
  if not Z.IsPCUI then
    return
  end
  local channelId = Z.ChatMsgHelper.GetChannelId(self.data_)
  self.uiBinder.img_channel:SetImage(Z.ChatMsgHelper.GetChatChannelIconByChannelId(channelId))
  self.channelHuntNameWidth_ = self.channelHuntNameWidth_ + 50
end

function ChatBubbleBase:refreshPlayerNewbie()
  if not self.uiBinder.img_newbie then
    return
  end
  if Z.VMMgr.GetVM("player"):IsShowNewbie(Z.ChatMsgHelper.GetPlayerIsNewbie(self.data_)) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, true)
    if self.uiBinder.lab_name_ref then
      local width = Z.IsPCUI and 28 or 36
      local offest = Z.ChatMsgHelper.GetIsSelfMessage(self.data_) and -1 or 1
      self.uiBinder.lab_name_ref:SetAnchorPosition(width * offest, 0)
      self.channelHuntNameWidth_ = self.channelHuntNameWidth_ + width
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, false)
    if self.uiBinder.lab_name_ref then
      self.uiBinder.lab_name_ref:SetAnchorPosition(0, 0)
    end
  end
end

function ChatBubbleBase:refreshPlayerlName()
  local showName = self.friendMainVm_.GetPlayerShowName(Z.ChatMsgHelper.GetCharId(self.data_), Z.ChatMsgHelper.GetPlayerName(self.data_))
  self.uiBinder.lab_name.text = showName
  if showName ~= "" then
    self.isShowChannelOrName_ = true
  end
  local size = self.uiBinder.lab_name:GetPreferredValues(showName)
  self.channelHuntNameWidth_ = self.channelHuntNameWidth_ + size.x + 10
end

function ChatBubbleBase:refreshHuntTitle()
  if self.uiBinder.lab_hunt == nil then
    return
  end
  local channelId = Z.ChatMsgHelper.GetChannelId(self.data_)
  local isInChannelGuild_ = channelId == E.ChatChannelType.EChannelUnion
  local isHuntStar = false
  if isInChannelGuild_ == true then
    isHuntStar = Z.ChatMsgHelper.GetIsUnionHuntStar(self.data_)
  end
  local sizeX = 0
  local str = ""
  if isHuntStar == true then
    str = Lang("HuntListAward")
    local offestY = Z.IsPCUI and 16 or 30
    local size = self.uiBinder.lab_hunt:GetPreferredValues(str, 300, offestY)
    sizeX = size.x
  end
  self.uiBinder.lab_hunt.text = str
  self.uiBinder.node_hunt:SetWidth(sizeX)
  self.channelHuntNameWidth_ = self.channelHuntNameWidth_ + sizeX
end

function ChatBubbleBase:refreshSendTime()
  local timeContent
  if Z.ChatMsgHelper.GetSendTime(self.data_) == "" then
    timeContent = ""
  else
    local timeData = Z.TimeFormatTools.Tp2YMDHMS(Z.ChatMsgHelper.GetSendTime(self.data_))
    timeContent = string.format("%02d:%02d", timeData.hour, timeData.min)
  end
  self.uiBinder.lab_time.text = timeContent
end

return ChatBubbleBase
