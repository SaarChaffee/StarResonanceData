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
  self:refreshChannelName()
  self:refreshSendTime()
  self:refreshHuntTitle()
  self:refreshSelfHead()
end

function ChatBubbleBase:OnUnInit()
  self.uiBinder.lab_channel.text = ""
end

function ChatBubbleBase:refreshSelfHead()
  local charId = Z.ChatMsgHelper.GetCharId(self.data_)
  if 0 < charId then
    playerPortraitHgr.LoadSocialDataByCharId(Z.ChatMsgHelper.GetCharId(self.data_), function(charId, socialData)
      if Z.ChatMsgHelper.GetCharId(self.data_) ~= charId or not self.uiBinder then
        return
      end
      playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.node_player_head, socialData)
    end)
  else
    local chatHyperLink = Z.ChatMsgHelper.GetChatHyperlink(self.data_)
    if chatHyperLink and chatHyperLink.ResourceRoute ~= "" then
      playerPortraitHgr.InsertNewPortraitByHeadPath(self.uiBinder.node_player_head, chatHyperLink.ResourceRoute)
    end
  end
end

function ChatBubbleBase:refreshChannelName()
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
  local showName = self.friendMainVm_.GetPlayerShowName(Z.ChatMsgHelper.GetCharId(self.data_), Z.ChatMsgHelper.GetPlayerName(self.data_))
  self.uiBinder.lab_name.text = showName
  if showName ~= "" then
    self.isShowChannelOrName_ = true
  end
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
    local size = self.uiBinder.lab_channel:GetPreferredValues(str, 300, 30)
    sizeX = size.x
  end
  self.uiBinder.lab_hunt.text = str
  self.uiBinder.node_hunt:SetWidth(sizeX)
end

function ChatBubbleBase:refreshSendTime()
  if Z.ChatMsgHelper.GetSendTime(self.data_) == "" then
    self.uiBinder.lab_time.text = ""
  else
    local timeData = Z.TimeTools.Tp2YMDHMS(Z.ChatMsgHelper.GetSendTime(self.data_))
    self.uiBinder.lab_time.text = string.format("%02d:%02d", timeData.hour, timeData.min)
  end
end

return ChatBubbleBase
