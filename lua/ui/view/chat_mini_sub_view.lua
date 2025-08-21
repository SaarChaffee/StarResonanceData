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
  self.mainUIData_ = Z.DataMgr.Get("mainui_data")
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
  self:onInitData()
  self:onInitProp()
  Z.UIMgr:AddShowMouseView("chat_mini_sub")
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendNewMessage, self.refreshFriendNewMessage, self)
end

function Chat_mini_subView:OnDeActive()
  self:setInputBox(false)
  self:setMsg(false)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendNewMessage, self.refreshFriendNewMessage, self)
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
    self.uiBinder.anim_parent_ref:SetAnchorPosition(self.viewData.data.x, self.viewData.data.y)
  end
end

function Chat_mini_subView:onInitData()
  self.chat_dialogue_tpl_view_ = chat_dialogue_tpl_view.new()
  self.chat_input_boxView_ = chat_input_box_view.new()
  self:setInputBox(true)
  self:setMsg(true)
end

function Chat_mini_subView:onInitProp()
  self.uiBinder.anim_parent_ref:SetAnchorPosition(self.viewData.data.x, self.viewData.data.y)
  self.uiBinder.lab_name.text = self.viewData.data.channelName
  self:AddAsyncClick(self.uiBinder.btn_shrink, function()
    self.viewData.parentView:AsyncHideMiniChat(self.viewData.data)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.viewData.parentView:CloseMiniChat(self.viewData.data.index)
  end)
  self.uiBinder.anim_parent_trigger.onDrag:AddListener(function(go, eventData)
    self:onDrag(eventData)
  end)
  self.uiBinder.anim_parent_trigger.onDown:AddListener(function(go, eventData)
    self.viewData.parentView:SelectMiniChat(self.viewData.data.index)
  end)
end

function Chat_mini_subView:onDrag(eventData)
  local x, y = self.uiBinder.anim_parent_ref:GetAnchorPosition(nil, nil)
  self.uiBinder.anim_parent_ref:SetAnchorPosition(eventData.delta.x + x, eventData.delta.y + y)
  self.viewData.data.x = eventData.delta.x + x
  self.viewData.data.y = eventData.delta.y + y
end

function Chat_mini_subView:setInputBox(isShow)
  if isShow then
    local inputViewData = {
      parentView = self,
      windowType = E.ChatWindow.Mini,
      channelId = self.viewData.data.channelId,
      charId = self.viewData.data.charId,
      showInputBg = false
    }
    self.chat_input_boxView_:Active(inputViewData, self.uiBinder.node_bottom_container, self.uiBinder)
  elseif self.chat_input_boxView_ then
    self.chat_input_boxView_:DeActive()
    self.chat_input_boxView_ = nil
  end
end

function Chat_mini_subView:setMsg(isShow)
  if isShow then
    local chatDialogueViewData = {
      parentView = self,
      channelId = self.viewData.data.channelId,
      charId = self.viewData.data.charId,
      windowType = E.ChatWindow.Mini
    }
    self.chat_dialogue_tpl_view_:Active(chatDialogueViewData, self.uiBinder.node_center_contaniner)
  elseif self.chat_dialogue_tpl_view_ then
    self.chat_dialogue_tpl_view_:DeActive()
    self.chat_dialogue_tpl_view_ = nil
  end
end

function Chat_mini_subView:refreshFriendNewMessage(sendCharId)
  if not (sendCharId and self.viewData and self.viewData.data and self.viewData.data.charId) or sendCharId ~= self.viewData.data.charId then
    return
  end
  self.mainUIData_.MainUIPCShowFriendMessage = false
  Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendMainChatNum)
  local chatItem = self.chatMainData_:GetPrivateChatItemByCharId(sendCharId)
  if not chatItem then
    return
  end
  local maxRead = chatItem.maxReadMsgId or 0
  if chatItem.latestMsg and chatItem.latestMsg.msgId and maxRead < chatItem.latestMsg.msgId then
    Z.CoroUtil.create_coro_xpcall(function()
      local isSuccess = self.chatMainVM_.AsyncSetPrivateChatHasRead(sendCharId, chatItem.latestMsg.msgId, self.viewData.parentView.cancelSource:CreateToken())
      if isSuccess then
        Z.RedPointMgr.UpdateNodeCount(E.RedType.FriendChatTab, self.chatMainData_:GetPrivateChatUnReadCount(), true)
      end
    end)()
  else
    Z.RedPointMgr.UpdateNodeCount(E.RedType.FriendChatTab, self.chatMainData_:GetPrivateChatUnReadCount(), true)
  end
end

return Chat_mini_subView
