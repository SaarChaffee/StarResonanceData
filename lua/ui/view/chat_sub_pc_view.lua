local UI = Z.UI
local super = require("ui.ui_subview_base")
local Chat_sub_pcView = class("Chat_sub_pcView", super)
local loopListView = require("ui.component.loop_list_view")
local chat_channel_tab = require("ui.component.chat_pc.chat_channel_tab_pc")

function Chat_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "chat_sub_pc", "chat_pc/chat_sub_pc", UI.ECacheLv.None)
end

function Chat_sub_pcView:OnActive()
  self:initVMData()
  self:initFunc()
  self:initKeyPad()
  self:initDialogue()
  self:initChatInputBoxPC()
  self:initChannelTab()
  self:refreshWorldChannelState()
  self:refreshEmptyState()
  self:BindEvents()
end

function Chat_sub_pcView:OnDeActive()
  self.chat_dialogue_tpl_view_:DeActive()
  self.chat_input_box_tpl_pc_:DeActive()
  self.channelKeyPad_:DeActive()
  self.channelListView_:UnInit()
  self:UnBindEvents()
  Z.Voice.StopPlayback()
end

function Chat_sub_pcView:OnRefresh()
  local channelId = self.chatMainData_:GetChannelId()
  local channelIdx = self.chatMainData_:GetChannelIdxWithId(channelId)
  self.channelListView_:SetSelected(channelIdx + 1)
end

function Chat_sub_pcView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Chat.GetRecord, self.refreshEmptyState, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.RefreshChatViewEmptyState, self.refreshEmptyState, self)
end

function Chat_sub_pcView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Chat.GetRecord, self.refreshEmptyState, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.RefreshChatViewEmptyState, self.refreshEmptyState, self)
end

function Chat_sub_pcView:initVMData()
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
end

function Chat_sub_pcView:initFunc()
  self:AddClick(self.uiBinder.btn_edit, function()
    self.channelKeyPad_:Active({
      min = 1,
      max = 9999,
      scale = 0.7,
      onInputOk = function(num)
        self:InputNum(num)
        self:asyncChangeWorldChannel(num)
      end,
      onKeyPadClose = function()
        self:refreshWorldChannelState()
      end
    }, self.uiBinder.node_small_keyboard)
  end)
end

function Chat_sub_pcView:initKeyPad()
  local channel_key_pad = require("ui.view.cont_num_keyboard_view")
  self.channelKeyPad_ = channel_key_pad.new(self)
end

function Chat_sub_pcView:InputNum(num)
  self.uiBinder.input_channel.text = num
end

function Chat_sub_pcView:asyncChangeWorldChannel(num)
  self.chatMainVM_.AsyncChannelGroupSwitch(num, self.cancelSource:CreateToken())
  self:refreshWorldChannelState()
  self:refreshEmptyState()
end

function Chat_sub_pcView:initDialogue()
  local chat_dialogue_tpl_view = require("ui.view.chat_dialogue_tpl_view")
  self.chat_dialogue_tpl_view_ = chat_dialogue_tpl_view.new()
  self.chatDialogueViewData_ = {
    parentView = self,
    channelId = E.ChatChannelType.EComprehensive,
    windowType = E.ChatWindow.Main
  }
  self.chat_dialogue_tpl_view_:Active(self.chatDialogueViewData_, self.uiBinder.node_dialogue, self.uiBinder)
end

function Chat_sub_pcView:initChatInputBoxPC()
  local chat_input_box_tpl_pc = require("ui.view.chat_input_box_tpl_pc_view")
  self.chat_input_box_tpl_pc_ = chat_input_box_tpl_pc.new()
  self.inputViewData_ = {
    parentView = self,
    windowType = E.ChatWindow.Main,
    channelId = self.chatMainData_:GetChannelId(),
    isShowVoice = true
  }
  self.chat_input_box_tpl_pc_:Active(self.inputViewData_, self.uiBinder.node_input, self.uiBinder)
end

function Chat_sub_pcView:initChannelTab()
  self.channelListView_ = loopListView.new(self, self.uiBinder.loop_channel, chat_channel_tab, "chat_channel_tab_pc")
  self.channelListView_:Init(self.chatMainData_:GetChannelList())
  self.channelListView_:SetSelected(1)
end

function Chat_sub_pcView:OnSelectChannel(channelTable)
  self.chatMainData_:SetChannelId(channelTable.Id)
  self:refreshWorldChannelState()
  self:refreshEmptyState()
  if channelTable.Id == E.ChatChannelType.EChannelUnion then
    self.chatMainVM_.CheckChatChannelUnionTips()
  end
  self.chatDialogueViewData_.channelId = channelTable.Id
  self.chat_dialogue_tpl_view_:Active(self.chatDialogueViewData_, self.uiBinder.node_dialogue, self.uiBinder)
  self.inputViewData_.channelId = channelTable.Id
  self.chat_input_box_tpl_pc_:Active(self.inputViewData_, self.uiBinder.node_input, self.uiBinder)
end

function Chat_sub_pcView:refreshWorldChannelState()
  if self.chatMainData_:GetChannelId() ~= E.ChatChannelType.EChannelWorld then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_world_channel_state, false)
    return
  end
  local state = self.chatMainData_:GetWorldChannelState()
  if state <= E.EWorldChannelState.Low then
    self.uiBinder.img_world_channel_state:SetColorByHex("#74d782")
    self.uiBinder.lab_world_channel_state.text = Z.RichTextHelper.ApplyStyleTag(Lang("world_channel_state_green"), E.TextStyleTag.ChannelGuild)
  elseif state == E.EWorldChannelState.Hot then
    self.uiBinder.img_world_channel_state:SetColorByHex("#ffc777")
    self.uiBinder.lab_world_channel_state.text = Z.RichTextHelper.ApplyStyleTag(Lang("world_channel_state_orange"), E.TextStyleTag.ChannelFriend)
  else
    self.uiBinder.img_world_channel_state:SetColorByHex("#ff9777")
    self.uiBinder.lab_world_channel_state.text = Z.RichTextHelper.ApplyStyleTag(Lang("world_channel_state_red"), E.TextStyleTag.ChannelSystem)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_world_channel_state, true)
  self.uiBinder.input_channel.text = self.chatMainData_:GetWorldGroupId()
end

function Chat_sub_pcView:refreshEmptyState()
  local queue = self.chatMainData_:GetChannelQueueByChannelId(self.chatMainData_:GetChannelId(), nil, true)
  if not queue then
    return
  end
  local showEmpty = table.zcount(queue) == 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, showEmpty)
end

return Chat_sub_pcView
