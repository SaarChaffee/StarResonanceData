local UI = Z.UI
local bulletPath = {
  [1] = "ui/prefabs/main/main_bullet_chat_item_tpl_pc",
  [2] = "ui/prefabs/main/main_bullet_chat_item_tpl"
}
local chatMiniBtnTplPath = "ui/prefabs/chat/chat_minichat_btn_tpl"
local mainchat_loopItem = require("ui.component.chat.mainchat_loopitem")
local chat_mini_sub_view = require("ui.view.chat_mini_sub_view")
local inputKeyDescComp = require("input.input_key_desc_comp")
local loop_list_view = require("ui/component/loop_list_view")
local super = require("ui.ui_view_base")
local Main_chatView = class("Main_chatView", super)

function Main_chatView:ctor()
  self.uiBinder = nil
  super.ctor(self, "main_chat")
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function Main_chatView:OnActive()
  self.chatSettingData_ = Z.DataMgr.Get("chat_setting_data")
  self.chatData_ = Z.DataMgr.Get("chat_main_data")
  self.chatVm_ = Z.VMMgr.GetVM("chat_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.mainUIData_ = Z.DataMgr.Get("mainui_data")
  self.deadVM_ = Z.VMMgr.GetVM("dead")
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self:onInitData()
  self:onInitProp()
  self:BindEvents()
  self:updateMainUIMainChat()
  if Z.IsPCUI then
    self.uiBinder.anim_chat_content:Restart(Z.DOTweenAnimType.Open)
    self.checkDataListTimer_ = self.timerMgr:StartTimer(function()
      self:checkChatBullet()
    end, 1, -1)
  else
    self.chatData_:SetChatDataFlg(E.ChatChannelType.EMain, E.ChatWindow.Main, true, false)
    self:checkMainChatList()
    self.checkDataListTimer_ = self.timerMgr:StartTimer(function()
      self:checkChatBullet()
      self:checkMainChatList()
    end, 1, -1)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_list, not Z.IsPCUI)
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncInitMiniChat()
  end)()
  self:initRedPoint()
end

function Main_chatView:initRedPoint()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.Socialcontact, self, self.uiBinder.node_chat_red)
end

function Main_chatView:removeRedPoint()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.Socialcontact)
end

function Main_chatView:OnRefresh()
  local isShowChatBtn = not Z.IsPCUI
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_chat, isShowChatBtn)
end

function Main_chatView:OnDeActive()
  self.inputKeyDescComp_:UnInit()
  self.chatLoopListView_:UnInit()
  self:clearMiniChat()
  self:removeRedPoint()
  self.timerMgr:StopTimer(self.checkDataListTimer_)
  self.checkDataListTimer_ = nil
  self.timerMgr:StopTimer(self.checkViewShowHideTimer_)
  self.checkViewShowHideTimer_ = nil
end

function Main_chatView:checkChatBullet()
  for _, data in pairs(self.chatData_.BulletList) do
    if data.isShow == false then
      data.isShow = true
      local channelId = Z.ChatMsgHelper.GetChannelId(data.chatMsgData)
      if channelId == E.ChatChannelType.EChannelPrivate then
        if self.friendMainData_:IsFriendByCharId(Z.ChatMsgHelper.GetCharId(data.chatMsgData)) then
          local friendData = self.friendMainData_:GetFriendDataByCharId(Z.ChatMsgHelper.GetCharId(data.chatMsgData))
          if friendData and friendData:GetIsRemind() then
            self:playBullet(data.chatMsgData)
          end
        end
      else
        local bullet = self.chatSettingData_:GetBullet(channelId)
        if bullet then
          self:playBullet(data.chatMsgData)
        end
      end
    end
  end
end

function Main_chatView:checkMainChatList()
  local dataFlg = self.chatData_:GetChatDataFlg(E.ChatChannelType.EMain, E.ChatWindow.Main)
  if dataFlg.flg then
    self.chatData_:SetChatDataFlg(E.ChatChannelType.EMain, E.ChatWindow.Main, false, false)
  else
    return
  end
  local msgList = self.chatData_:GetChannelQueueByChannelId(E.ChatChannelType.EMain, nil, true)
  self.chatLoopListView_:RefreshListView(msgList, false)
  self.chatLoopListView_:MovePanelToItemIndex(#msgList)
end

function Main_chatView:updateMainUIMainChat()
  if not self.mainUIData_:GetIsShowMainChat() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.anim_chat_content, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_mini_chat, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_mini_chat_btn, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.anim_chat_content, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_mini_chat, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_mini_chat_btn, true)
  end
  self:updateFishingMainChat()
end

function Main_chatView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Chat.OpenMiniChat, self.showMiniChatView, self)
  Z.EventMgr:Add(Z.ConstValue.MainUI.UpdateMainUIMainChat, self.updateMainUIMainChat, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingStateChange, self.updateFishingMainChat, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.UpdateFishingMainChat, self.updateFishingMainChat, self)
end

function Main_chatView:updateFishingMainChat()
  self.uiBinder.Ref:SetVisible(self.uiBinder.anim_chat_content, (self.fishingData_.FishingStage == E.FishingStage.Quit or self.fishingData_.FishingStage == E.FishingStage.EnterFishing) and self.mainUIData_:GetIsShowMainChat())
end

function Main_chatView:playBullet(chatMsgData)
  if not Z.ChatMsgHelper.CheckChatMsgCanShow(chatMsgData) then
    return
  end
  self.idx_ = self.idx_ + 1
  local fontSize = self.chatSettingData_:GetFontSize()
  local canvasGroup = self.chatSettingData_:GetAlpha()
  local showIndex = self:getBulletIndex()
  local parent = self.bulletPawnList_[showIndex]
  self.lastBulletIndex_ = showIndex
  local speedEnum = self.chatSettingData_:GetBulletSpeed()
  local speed = 0
  if speedEnum then
    if speedEnum == E.BulletSpeed.low then
      speed = 3
    elseif speedEnum == E.BulletSpeed.mid then
      speed = 5
    else
      speed = 8
    end
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local name = string.zconcat(Z.ChatMsgHelper.GetChannelId(chatMsgData), Z.ChatMsgHelper.GetCharId(chatMsgData), self.idx_)
    local path = Z.IsPCUI and bulletPath[1] or bulletPath[2]
    local item = self:AsyncLoadUiUnit(path, name, parent)
    local content = self:getBulletShowContext(chatMsgData)
    item.lab_content.text = content
    item.lab_content.fontSize = fontSize
    item.lab_content_canvasgroup.alpha = canvasGroup / 100
    local labSize = item.lab_content:GetPreferredValues(content)
    item.lab_move:PlayAnim(0, -labSize.x - Z.UIRoot.CurScreenSize.x, speed, function()
      self:RemoveUiUnit(name)
    end)
  end)()
end

function Main_chatView:getBulletIndex()
  local index = math.random(4)
  if self.lastBulletIndex_ and index == self.lastBulletIndex_ then
    index = index + 1
  end
  if 4 < index then
    index = 1
  end
  return index
end

function Main_chatView:getBulletShowContext(chatMsgData)
  local content = ""
  local playerName = Z.ChatMsgHelper.GetPlayerName(chatMsgData)
  local msgType = Z.ChatMsgHelper.GetMsgType(chatMsgData)
  local msg = Z.ChatMsgHelper.GetMsg(chatMsgData)
  if Z.ChatMsgHelper.GetChannelId(chatMsgData) ~= E.ChatChannelType.EChannelPrivate then
    local channelId = Z.ChatMsgHelper.GetChannelId(chatMsgData)
    local config = self.chatData_:GetConfigData(channelId)
    local colorTag = config.ChannelStyle
    local channelName = Z.RichTextHelper.ApplyStyleTag(string.zconcat("[", config.ChannelName, "]"), colorTag)
    if msgType == E.ChitChatMsgType.EChatMsgTextMessage or msgType == E.ChitChatMsgType.EChatMsgTextNotice then
      if channelId == E.ChatChannelType.ESystem then
        content = string.zconcat(channelName, msg)
      else
        content = string.zconcat(channelName, playerName, ":", msg)
      end
    elseif msgType == E.ChitChatMsgType.EChatMsgPictureEmoji then
      local showContent = Z.ChatMsgHelper.GetEmojiText(chatMsgData)
      if showContent ~= "" then
        content = string.zconcat(channelName, playerName, ":[", showContent, "]")
      else
        content = string.zconcat(channelName, playerName, ":", Lang("chat_pic"))
      end
    elseif msgType == E.ChitChatMsgType.EChatMsgVoice then
      content = string.zconcat(channelName, playerName, ":", Lang("chatMiniVoice"))
    end
  else
    local friendName = Z.RichTextHelper.ApplyStyleTag(Lang("FriendChannel"), E.TextStyleTag.ChannelFriend)
    if msgType == E.ChitChatMsgType.EChatMsgTextMessage or msgType == E.ChitChatMsgType.EChatMsgTextNotice then
      content = string.zconcat(friendName, playerName, ":", msg)
    elseif msgType == E.ChitChatMsgType.EChatMsgPictureEmoji then
      local showContent = Z.ChatMsgHelper.GetEmojiText(chatMsgData)
      if showContent ~= "" then
        content = string.zconcat(friendName, playerName, ":[", showContent, "]")
      else
        content = string.zconcat(friendName, playerName, ":", Lang("chat_pic"))
      end
    elseif msgType == E.ChitChatMsgType.EChatMsgVoice then
      content = string.zconcat(friendName, playerName, ":", Lang("chatMiniVoice"))
    end
  end
  return content
end

function Main_chatView:onInitProp()
  self.bulletPawnList_ = {
    self.uiBinder.node_chat_pawn1,
    self.uiBinder.node_chat_pawn2,
    self.uiBinder.node_chat_pawn3,
    self.uiBinder.node_chat_pawn4
  }
  self:AddClick(self.uiBinder.btn_chat, function()
    Z.VMMgr.GetVM("gotofunc").GoToFunc(E.FunctionID.MainChat)
  end)
  if Z.IsPCUI then
    local mainIconTableRow = Z.TableMgr.GetRow("MainIconTableMgr", E.FunctionID.MainChat)
    if mainIconTableRow == nil then
      return
    end
    local binderChat = self.uiBinder.binder_chat
    binderChat.func_btn_audio:AddAudioEvent(mainIconTableRow.Path, 3)
    binderChat.func_btn_img:SetImage(mainIconTableRow.Icon)
    local keyId = self:getKeyIdByFuncId(mainIconTableRow.Id)
    if keyId then
      self.inputKeyDescComp_:Init(keyId, binderChat.cont_key_icon_uiBinder)
    end
  end
end

function Main_chatView:getKeyIdByFuncId(funcId)
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  for keyId, row in pairs(keyTbl.GetDatas()) do
    if row.KeyboardDes == 2 and row.FunctionId == funcId then
      return keyId
    end
  end
end

function Main_chatView:onInitData()
  local itemName = Z.IsPCUI and "main_chat_loopitem_tpl_pc" or "main_chat_loopitem_tpl"
  self.chatLoopListView_ = loop_list_view.new(self, self.uiBinder.node_list, mainchat_loopItem, itemName)
  self.chatLoopListView_:Init({})
  self.isDrag_ = false
  self.mainTimer_ = nil
  self.bulletTimer_ = nil
  self.idx_ = 0
  self.isShowMainChat_ = false
  self.chat_mini_sub_view_list_ = {}
  self.chat_mini_btn_list_ = {}
end

function Main_chatView:asyncInitMiniChat()
  local miniChatList = self.chatData_:GetMiniChatList()
  for _, data in pairs(miniChatList) do
    if data.type == E.MiniChatType.EChatView then
      self:showMiniChatView(data, true)
    else
      self:asyncShowMiniChatBtn(data)
    end
  end
  self:SelectMiniChat(self.chatData_:GetSelectMiniChatIndex())
end

function Main_chatView:showMiniChatView(data, ignoreSelect)
  if not data then
    local miniChatList = self.chatData_:GetMiniChatList()
    if miniChatList and 0 < #miniChatList then
      data = miniChatList[#miniChatList]
    else
      return
    end
  end
  if not self.chat_mini_sub_view_list_[data.index] then
    local viewData = {data = data, parentView = self}
    self.chat_mini_sub_view_list_[data.index] = chat_mini_sub_view.new()
    self.chat_mini_sub_view_list_[data.index]:Active(viewData, self.uiBinder.node_mini_chat, self.uiBinder)
  else
    self:hideMiniChatBtn(data.index)
    self.chat_mini_sub_view_list_[data.index]:Show()
    self.chat_mini_sub_view_list_[data.index]:OnShow()
  end
  if not ignoreSelect then
    self:SelectMiniChat(data.index)
  end
end

function Main_chatView:SelectMiniChat(index)
  local curIndex = self.chatData_:GetSelectMiniChatIndex()
  self.chatData_:SetSelectMiniChatIndex(index)
  local rootIndex = self.uiBinder.node_mini_chat:GetSiblingIndex()
  if self.chat_mini_sub_view_list_[curIndex] and self.chat_mini_sub_view_list_[curIndex].uiBinder then
    self.chat_mini_sub_view_list_[curIndex].uiBinder.Trans:SetSiblingIndex(rootIndex)
  end
  if self.chat_mini_sub_view_list_[index] and self.chat_mini_sub_view_list_[index].uiBinder then
    self.chat_mini_sub_view_list_[index].uiBinder.Trans:SetSiblingIndex(rootIndex + 1)
  end
end

function Main_chatView:AsyncHideMiniChat(data)
  if self.chat_mini_sub_view_list_[data.index] then
    self.chat_mini_sub_view_list_[data.index]:Hide()
  end
  self.chatData_:UpdateMiniChatType(data.index, E.MiniChatType.EChatBtn)
  self:asyncShowMiniChatBtn(data)
end

function Main_chatView:CloseMiniChat(index)
  self.chatData_:RemoveMiniChat(index)
  if self.chat_mini_sub_view_list_[index] then
    self.chat_mini_sub_view_list_[index]:DeActive()
    self.chat_mini_sub_view_list_[index] = nil
  end
end

function Main_chatView:clearMiniChat()
  for _, miniView in pairs(self.chat_mini_sub_view_list_) do
    miniView:DeActive()
  end
end

function Main_chatView:asyncShowMiniChatBtn(data)
  local channelName = Z.RichTextHelper.ApplyStyleTag(data.channelName, data.colorTag)
  if not self.chat_mini_btn_list_[data.index] then
    local item = self:AsyncLoadUiUnit(chatMiniBtnTplPath, tostring(data.index), self.uiBinder.node_mini_chat_btn)
    if not item then
      return
    end
    item.chat_minichat_btn_tpl:SetAnchorPosition(data.x, data.y)
    item.lab_channel.text = channelName
    item.Ref:SetVisible(item.chat_minichat_btn_tpl, true)
    self.chat_mini_btn_list_[data.index] = item
    self:AddClick(item.btn_minichat, function()
      if not self.isDrag_ then
        self:hideMiniChatBtn(data.index)
        self.chatData_:UpdateMiniChatType(data.channelId, data.charId, E.MiniChatType.EChatView)
        self:showMiniChatView(data)
      end
    end)
    item.btn_minichat_trigger.onDrag:AddListener(function(go, eventData)
      self.isDrag_ = true
      local x, y = item.chat_minichat_btn_tpl:GetAnchorPosition(nil, nil)
      item.chat_minichat_btn_tpl:SetAnchorPosition(eventData.delta.x + x, eventData.delta.y + y)
      data.x = eventData.delta.x + x
      data.y = eventData.delta.y + y
    end)
    item.btn_minichat_trigger.onEndDrag:AddListener(function(go, eventData)
      self.isDrag_ = false
    end)
  else
    self.chat_mini_btn_list_[data.index].chat_minichat_btn_tpl:SetAnchorPosition(data.x, data.y)
    self.chat_mini_btn_list_[data.index].lab_channel.text = channelName
    self.chat_mini_btn_list_[data.index].Ref:SetVisible(self.chat_mini_btn_list_[data.index].chat_minichat_btn_tpl, true)
  end
end

function Main_chatView:hideMiniChatBtn(index)
  if self.chat_mini_btn_list_[index] then
    self.chat_mini_btn_list_[index].Ref:SetVisible(self.chat_mini_btn_list_[index].chat_minichat_btn_tpl, false)
  end
end

return Main_chatView
