local UI = Z.UI
local loop_list_view = require("ui/component/loop_list_view")
local chat_mini_bubble_item = require("ui.component.chat.chat_mini_bubble_item")
local chat_bubble_union_tips = require("ui.component.chat.chat_bubble_union_tips")
local chat_bubble_system_notice = require("ui.component.chat.chat_bubble_system_notice")
local chat_bubble_channel_notice = require("ui.component.chat.chat_bubble_channel_notice")
local chat_bubble_content = require("ui.component.chat.chat_bubble_content")
local chat_bubble_voice = require("ui.component.chat.chat_bubble_voice")
local chat_bubble_picture = require("ui.component.chat.chat_bubble_picture")
local chat_bubble_union = require("ui.component.chat.chat_bubble_union")
local chat_bubble_union_new = require("ui.component.chat.chat_bubble_union_new")
local super = require("ui.ui_subview_base")
local Chat_dialogue_tplView = class("Chat_dialogue_tplView", super)
E.ChatDialogueFuncType = {CopyType = 1, VoiceType = 2}

function Chat_dialogue_tplView:ctor()
  self.uiBinder = nil
  super.ctor(self, "chat_dialogue_tpl", "chat/chat_dialogue_tpl", UI.ECacheLv.None)
end

function Chat_dialogue_tplView:OnActive()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.unReadCount_ = 0
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
  self.chatData_ = Z.DataMgr.Get("chat_main_data")
  self:onInitData()
  if self.viewData.chatChannelId then
    self.chatChannelId_ = self.viewData.chatChannelId
  else
    self.chatChannelId_ = self.chatData_:GetChannelId()
  end
  self.uiBinder.node_list_event_trigger.onBeginDrag:AddListener(function(go, eventData)
    self.dragPos_ = eventData.position
    self.startDrag_ = true
  end)
  self.uiBinder.node_list_event_trigger.onDrag:AddListener(function(go, eventData)
    self:onDrag(eventData.position)
  end)
  self.uiBinder.node_list_event_trigger.onEndDrag:AddListener(function(go, eventData)
    self:onEndDrag()
  end)
  self:EventAddAsyncListener(self.uiBinder.presscheck_tipspress.ContainGoEvent, function(isContain)
    if not isContain then
      self:closeChatTips()
    end
  end, nil, nil)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unread, false)
  self:AddClick(self.uiBinder.btn_unread, function()
    self:RefreshMsgList(true)
  end)
  self.uiBinder.presscheck_tipspress:StopCheck()
  self:BindEvents()
  self:RefreshMsgList(true)
  self.checkDataListTimer_ = self.timerMgr:StartTimer(function()
    if not self.listIsInit_ then
      return
    end
    self:checkChatDataList()
  end, 0.1, -1)
end

function Chat_dialogue_tplView:OnDeActive()
  self:UnBindEvents()
  self:closeChatTips()
  self.msgScrollRect_:UnInit()
  self.msgScrollRect_ = nil
  self.listIsInit_ = false
  if self.checkDataListTimer_ then
    self.timerMgr:StopTimer(self.checkDataListTimer_)
  end
  if self.chatData_.ChatLinkTips and #self.chatData_.ChatLinkTips > 0 then
    for i = 1, #self.chatData_.ChatLinkTips do
      Z.TipsVM.CloseItemTipsView(self.chatData_.ChatLinkTips[i])
    end
  end
end

function Chat_dialogue_tplView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Chat.GetRecord, self.OnMsgRecord, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.Refresh, self.OnMsgRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.RefreshFromEnd, self.OnMsgRefreshFromEnd, self)
end

function Chat_dialogue_tplView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Chat.GetRecord, self.OnMsgRecord, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.Refresh, self.OnMsgRefresh, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.RefreshFromEnd, self.OnMsgRefreshFromEnd, self)
end

function Chat_dialogue_tplView:onDrag(position)
  if Mathf.Abs(self.dragPos_.y) - Mathf.Abs(position.y) >= 100 and not self.isDragEnd_ then
    local pos = self.uiBinder.node_content.localPosition
    if pos.y <= -10 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_loading, true)
      self.isDragEnd_ = true
      self:asyncGetRecord()
    end
  end
end

function Chat_dialogue_tplView:asyncGetRecord()
  if not self.viewData then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.chatMainVM_.AsyncGetRecord(self.chatChannelId_)
  end)()
end

function Chat_dialogue_tplView:onEndDrag()
  self.isDragEnd_ = false
  self.startDrag_ = false
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_loading, false)
  local isEnd = self:getIsEnd()
  if isEnd then
    self:UnReadMsg()
  end
end

function Chat_dialogue_tplView:SwitchChannelId(channelId)
  self.chatChannelId_ = channelId
  self:RefreshMsgList(true)
end

function Chat_dialogue_tplView:ResetListView()
  self.msgScrollRect_:ResetListView(false)
end

function Chat_dialogue_tplView:RefreshMsgList(isMoveToEnd)
  if not self.chatData_ then
    return
  end
  if self.startDrag_ then
    return
  end
  self:updateSelfMsgList()
  if not self.listIsInit_ then
    self.listIsInit_ = true
    self.msgScrollRect_:Init(self.msgList_, self)
    self.msgScrollRect_:MovePanelToItemIndex(#self.msgList_)
  else
    self.msgScrollRect_:RefreshListView(self.msgList_, false)
    if isMoveToEnd then
      self.msgScrollRect_:MovePanelToItemIndex(0)
      self.msgScrollRect_:MovePanelToItemIndex(#self.msgList_)
      self:UnReadMsg()
    end
  end
end

function Chat_dialogue_tplView:OnMsgRefresh()
  if not self.chatData_ then
    return
  end
  self:RefreshMsgList(false)
end

function Chat_dialogue_tplView:OnMsgRefreshFromEnd(chatChannelId)
  if chatChannelId and self.chatChannelId_ ~= chatChannelId then
    return
  end
  self:RefreshMsgList(true)
end

function Chat_dialogue_tplView:OnMsgRecord(chatChannelId)
  if self.viewData and self.chatChannelId_ ~= chatChannelId and self.chatChannelId_ ~= E.ChatChannelType.EComprehensive then
    return
  end
  self:OnMsgRefresh()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_loading, false)
end

function Chat_dialogue_tplView:checkChatBubble(isRecord)
  local isEnd = self:getIsEnd()
  self:RefreshMsgList(isEnd)
  self:newMsg(not isEnd and not isRecord)
end

function Chat_dialogue_tplView:getIsEnd()
  local _, y = self.uiBinder.node_content:GetAnchorPosition(nil, nil)
  local height = self.uiBinder.node_list.ViewPortHeight
  local _, allHeight = self.uiBinder.node_content:GetSizeDelta(nil, nil)
  if allHeight - (y + height) < height * 0.05 then
    return true
  else
    return false
  end
end

function Chat_dialogue_tplView:newMsg(isHaveNewMsg)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unread, isHaveNewMsg)
  self.unReadCount_ = isHaveNewMsg and self.unReadCount_ + 1 or 0
  if isHaveNewMsg then
    self.uiBinder.lab_unread.text = string.format("%s%s", Lang("chat_unRead"), self.unReadCount_)
  end
end

function Chat_dialogue_tplView:UnReadMsg()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unread, false)
  self.unReadCount_ = 0
end

function Chat_dialogue_tplView:checkChatDataList()
  local dataFlg = self.chatData_:GetChatDataFlg(self.chatChannelId_, self.viewData.windowType)
  if dataFlg and dataFlg.flg then
    self:checkChatBubble(dataFlg.isRecord)
    self.chatData_:SetChatDataFlg(self.chatChannelId_, self.viewData.windowType, false, false)
  end
end

function Chat_dialogue_tplView:onInitData()
  self.msgScrollRect_ = loop_list_view.new(self, self.uiBinder.node_list)
  self.msgScrollRect_:SetGetItemClassFunc(function(data)
    if self.viewData.windowType == E.ChatWindow.Mini then
      return chat_mini_bubble_item
    elseif Z.ChatMsgHelper.GetChannelId(data) == E.ChatChannelType.ESystem then
      return chat_bubble_channel_notice
    else
      local msgType = Z.ChatMsgHelper.GetMsgType(data)
      if msgType == E.ChitChatMsgType.EChatMsgTextMessage or msgType == E.ChitChatMsgType.EChatMsgTextNotice then
        return chat_bubble_content
      elseif msgType == E.ChitChatMsgType.EChatMsgVoice then
        return chat_bubble_voice
      elseif msgType == E.ChitChatMsgType.EChatMsgPictureEmoji then
        return chat_bubble_picture
      elseif msgType == E.ChitChatMsgType.EChatMsgMultiLangNotice then
        return chat_bubble_system_notice
      else
        local linkType = Z.ChatMsgHelper.GetChatHyperLinkShowType(data)
        if linkType == E.ChatHyperLinkShowType.SystemTips then
          return chat_bubble_system_notice
        elseif linkType == E.ChatHyperLinkShowType.UnionTips then
          return chat_bubble_channel_notice
        elseif linkType == E.ChatHyperLinkShowType.NpcHeadTips then
          return chat_bubble_union_tips
        elseif linkType == E.ChatHyperLinkShowType.PictureBtnTips then
          return chat_bubble_union
        elseif linkType == E.ChatHyperLinkShowType.PictureBtnTipsNew then
          return chat_bubble_union_new
        else
          return chat_bubble_content
        end
      end
    end
  end)
  self.msgScrollRect_:SetGetPrefabNameFunc(function(data)
    if self.viewData.windowType == E.ChatWindow.Mini then
      return "chat_mini_lab_bubble_tpl"
    elseif Z.ChatMsgHelper.GetChannelId(data) == E.ChatChannelType.ESystem then
      return "chat_bubble_channel_notice"
    else
      local msgType = Z.ChatMsgHelper.GetMsgType(data)
      local isSelfMessage = Z.ChatMsgHelper.GetIsSelfMessage(data)
      if msgType == E.ChitChatMsgType.EChatMsgTextMessage or msgType == E.ChitChatMsgType.EChatMsgTextNotice then
        if isSelfMessage then
          return "chat_bubble_self_content"
        else
          return "chat_bubble_other_content"
        end
      elseif msgType == E.ChitChatMsgType.EChatMsgVoice then
        if isSelfMessage then
          return "chat_bubble_self_voice"
        else
          return "chat_bubble_other_voice"
        end
      elseif msgType == E.ChitChatMsgType.EChatMsgPictureEmoji then
        if isSelfMessage then
          return "chat_bubble_self_picture"
        else
          return "chat_bubble_other_picture"
        end
      elseif msgType == E.ChitChatMsgType.EChatMsgMultiLangNotice then
        return "chat_bubble_system_notice"
      else
        local linkType = Z.ChatMsgHelper.GetChatHyperLinkShowType(data)
        if linkType == E.ChatHyperLinkShowType.SystemTips then
          return "chat_bubble_system_notice"
        elseif linkType == E.ChatHyperLinkShowType.UnionTips then
          return "chat_bubble_channel_notice"
        elseif linkType == E.ChatHyperLinkShowType.NpcHeadTips then
          return "chat_bubble_other_union_01"
        elseif linkType == E.ChatHyperLinkShowType.PictureBtnTips then
          if isSelfMessage then
            return "chat_bubble_self_union"
          else
            return "chat_bubble_other_union"
          end
        elseif linkType == E.ChatHyperLinkShowType.PictureBtnTipsNew then
          if isSelfMessage then
            return "chat_bubble_self_union_crowdfunding"
          else
            return "chat_bubble_union_crowdfunding"
          end
        elseif isSelfMessage then
          return "chat_bubble_self_content"
        else
          return "chat_bubble_other_content"
        end
      end
    end
  end)
  self:UnReadMsg()
  self.isDragEnd_ = false
  self.dragPos_ = Vector2.zero
end

function Chat_dialogue_tplView:IsComprehensive()
  return self.chatChannelId_ == E.ChatChannelType.EComprehensive
end

function Chat_dialogue_tplView:updateSelfMsgList()
  self.msgList_ = self.chatData_:GetChannelQueueByChannelId(self.chatChannelId_, nil, true, self.viewData.windowType == E.ChatWindow.Mini)
  if not self.msgList_ then
    self.msgList_ = {}
  end
end

function Chat_dialogue_tplView:OpenChatTips(parent, funcType, copyFunc)
  self:closeChatTips()
  Z.CoroUtil.create_coro_xpcall(function()
    local item = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Chat.PressItem), "chatTips", self.uiBinder.node_chat_tips)
    self:AddClick(item.btn_copy, function()
      copyFunc()
      self:closeChatTips()
    end)
    self.uiBinder.node_chat_tips:SetPos(parent.position)
    self.chatTips_ = item
    self.uiBinder.presscheck_tipspress:AddGameObject(item.btn_copy.gameObject)
    self.uiBinder.presscheck_tipspress:StartCheck()
    item.img_bg:Restart(Z.DOTweenAnimType.Open)
    item.Ref:SetVisible(item.img_copy_icon, funcType == E.ChatDialogueFuncType.CopyType)
    item.Ref:SetVisible(item.img_voice_icon, funcType == E.ChatDialogueFuncType.VoiceType)
  end)()
end

function Chat_dialogue_tplView:closeChatTips()
  if self.chatTips_ then
    self.uiBinder.presscheck_tipspress:RemoveGameObject(self.chatTips_.btn_copy.gameObject)
    self:RemoveUiUnit("chatTips")
    self.chatTips_ = nil
    self.uiBinder.presscheck_tipspress:StopCheck()
  end
end

return Chat_dialogue_tplView
