local UI = Z.UI
local super = require("ui.ui_subview_base")
local Chat_mini_subView = class("Chat_mini_subView", super)
local chat_input_box_view = require("ui.view.chat_input_box_view")
local chat_dialogue_tpl_view = require("ui.view.chat_dialogue_tpl_view")

function Chat_mini_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "chat_mini_sub", "chat/chat_mini_sub", UI.ECacheLv.None)
end

function Chat_mini_subView:OnActive()
  self:startAnimatedShow()
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.viewData_ = self.viewData
  self.miniChatData_ = self.chatMainData_:GetMiniChatData(self.viewData.channelId)
  self:onInitData()
  self:onInitProp()
  Z.UIMgr:AddShowMouseView("chat_mini_sub")
end

function Chat_mini_subView:OnDeActive()
  self:setInputBox(false)
  self:setMsg(false)
  Z.UIMgr:RemoveShowMouseView("chat_mini_sub")
end

function Chat_mini_subView:OnRefresh()
  self:OnShow()
end

function Chat_mini_subView:startAnimatedShow()
  self.uiBinder.anim_parent:Restart(Z.DOTweenAnimType.Open)
end

function Chat_mini_subView:OnShow()
  if self.uiBinder.anim_parent_ref then
    self.uiBinder.anim_parent_ref:SetAnchorPosition(self.miniChatData_.x, self.miniChatData_.y)
  end
end

function Chat_mini_subView:onInitData()
  self.chat_dialogue_tpl_view_ = chat_dialogue_tpl_view.new()
  self.chat_input_boxView_ = chat_input_box_view.new()
  self:setInputBox(true)
  self:setMsg(true)
end

function Chat_mini_subView:onInitProp()
  self.uiBinder.anim_parent_ref:SetAnchorPosition(self.miniChatData_.x, self.miniChatData_.y)
  self.uiBinder.lab_name.text = self.miniChatData_.channelName
  self:AddAsyncClick(self.uiBinder.btn_shrink, function()
    self.viewData_.parentView:AsyncHideMiniChat(self.viewData_.channelId)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.viewData_.parentView:CloseMiniChat(self.viewData_.channelId)
  end)
  self.uiBinder.anim_parent_trigger.onDrag:AddListener(function(go, eventData)
    self:onDrag(eventData)
  end)
  self.uiBinder.anim_parent_trigger.onDown:AddListener(function(go, eventData)
    self.viewData_.parentView:SelectMiniChat(self.viewData_.channelId)
  end)
end

function Chat_mini_subView:onDrag(eventData)
  local x, y = self.uiBinder.anim_parent_ref:GetAnchorPosition(nil, nil)
  self.uiBinder.anim_parent_ref:SetAnchorPosition(eventData.delta.x + x, eventData.delta.y + y)
  self.chatMainData_:UpdateMiniChatPosition(self.viewData_.channelId, eventData.delta.x + x, eventData.delta.y + y)
end

function Chat_mini_subView:setInputBox(isShow)
  if isShow then
    local inputViewData = {}
    inputViewData.parentView = self
    inputViewData.windowType = E.ChatWindow.Mini
    inputViewData.channelId = self.viewData_.channelId
    inputViewData.showInputBg = false
    self.chat_input_boxView_:Active(inputViewData, self.uiBinder.node_bottom_container, self.uiBinder)
  elseif self.chat_input_boxView_ then
    self.chat_input_boxView_:DeActive()
    self.chat_input_boxView_ = nil
  end
end

function Chat_mini_subView:setMsg(isShow)
  if isShow then
    local chatDialogueViewData = {}
    chatDialogueViewData.parentView = self
    chatDialogueViewData.chatChannelId = self.viewData_.channelId
    chatDialogueViewData.windowType = E.ChatWindow.Mini
    self.chat_dialogue_tpl_view_:Active(chatDialogueViewData, self.uiBinder.node_center_contaniner)
  elseif self.chat_dialogue_tpl_view_ then
    self.chat_dialogue_tpl_view_:DeActive()
    self.chat_dialogue_tpl_view_ = nil
  end
end

return Chat_mini_subView
