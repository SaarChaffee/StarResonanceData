local UI = Z.UI
local bulletPath = {
  [1] = "ui/prefabs/main/main_bullet_chat_item_pc_tpl",
  [2] = "ui/prefabs/main/main_bullet_chat_item_tpl"
}
local chatMiniBtnTplPath = "ui/prefabs/chat/chat_minichat_btn_tpl"
local mainchat_loopItem = require("ui.component.chat.mainchat_loopitem")
local chat_mini_sub_view = require("ui.view.chat_mini_sub_view")
local newKeyIconHelper = require("ui.component.mainui.new_key_icon_helper")
local loop_list_view = require("ui/component/loop_list_view")
local super = require("ui.ui_view_base")
local Main_chatView = class("Main_chatView", super)

function Main_chatView:ctor()
  self.uiBinder = nil
  if Z.IsPCUI then
    Z.UIConfig.main_chat.PrefabPath = "main/main_chat_pc_tpl"
  else
    Z.UIConfig.main_chat.PrefabPath = "main/main_chat_tpl"
  end
  super.ctor(self, "main_chat")
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputAction()
  end
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
  self:RegisterInputActions()
  self:updateMainUIMainChat()
  if Z.IsPCUI then
    self.uiBinder.anim_chat_content:Restart(Z.DOTweenAnimType.Open)
  end
  self.chatData_:SetChatDataFlg(E.ChatChannelType.EMain, E.ChatWindow.Main, true, false)
  self.checkDataListTimer_ = self.timerMgr:StartTimer(function()
    self:checkChatBullet()
    self:checkMainChatList()
  end, 1, -1)
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
  local isShowChatBtn = not Z.IsPCUI or self.deadVM_.CheckPlayerIsDead()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_chat, isShowChatBtn)
end

function Main_chatView:OnDeActive()
  self.chatLoopListView_:UnInit()
  self:UnRegisterInputActions()
  self:clearMiniChat()
  self:removeRedPoint()
  if self.checkDataListTimer_ then
    self.timerMgr:StopTimer(self.checkDataListTimer_)
  end
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
  local msgList = self.chatData_:GetChannelQueueByChannelId(E.ChatChannelType.EMain)
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
end

function Main_chatView:updateFishingMainChat()
  self.uiBinder.Ref:SetVisible(self.uiBinder.anim_chat_content, self.fishingData_.FishingStage == E.FishingStage.Quit and self.mainUIData_:GetIsShowMainChat())
end

function Main_chatView:playBullet(chatMsgData)
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
      speed = 15
    elseif speedEnum == E.BulletSpeed.mid then
      speed = 10
    else
      speed = 5
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
    item.lab_move:PlayAnim(0, -Z.UIRoot.CurScreenSize.x, speed, function()
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
    local channelName = Z.RichTextHelper.ApplyStyleTag(string.format("[%s]", config.ChannelName), colorTag)
    if msgType == E.ChitChatMsgType.EChatMsgTextMessage or msgType == E.ChitChatMsgType.EChatMsgTextNotice then
      if channelId == E.ChatChannelType.ESystem then
        content = string.format("%s%s", channelName, msg)
      else
        content = string.format("%s%s:%s", channelName, playerName, msg)
      end
    elseif msgType == E.ChitChatMsgType.EChatMsgPictureEmoji then
      content = string.format("%s%s:[%s]", channelName, playerName, Lang("chat_pic"))
    elseif msgType == E.ChitChatMsgType.EChatMsgVoice then
      content = string.format("%s%s:[%s]", channelName, playerName, Lang("chatMiniVoice"))
    end
  else
    local friendName = Z.RichTextHelper.ApplyStyleTag(string.format("[%s]", Lang("Friend")), E.TextStyleTag.ChannelFriend)
    if msgType == E.ChitChatMsgType.EChatMsgTextMessage or msgType == E.ChitChatMsgType.EChatMsgTextNotice then
      content = string.format("%s%s:%s", friendName, playerName, msg)
    elseif msgType == E.ChitChatMsgType.EChatMsgPictureEmoji then
      content = string.format("%s%s:[%s]", friendName, playerName, Lang("chat_pic"))
    elseif msgType == E.ChitChatMsgType.EChatMsgVoice then
      content = string.format("%s%s:[%s]", friendName, playerName, Lang("chatMiniVoice"))
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
      newKeyIconHelper.InitKeyIcon(self, binderChat.cont_key_icon_uiBinder, keyId)
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
  for _, channelData in pairs(miniChatList) do
    if channelData.type == E.MiniChatType.EChatView then
      self:showMiniChatView(channelData.channelId, true)
    else
      self:asyncShowMiniChatBtn(channelData.channelId)
    end
  end
  self:SelectMiniChat(self.chatData_:GetSelectMiniChatChannelId())
end

function Main_chatView:showMiniChatView(channelId, ignoreSelect)
  if not channelId or channelId == E.ChatChannelType.EComprehensive or channelId == E.ChatChannelType.EMain or channelId == E.ChatChannelType.ESystem then
    return
  end
  if not self.chat_mini_sub_view_list_[channelId] then
    local viewData = {}
    viewData.channelId = channelId
    viewData.parentView = self
    self.chat_mini_sub_view_list_[channelId] = chat_mini_sub_view.new()
    self.chat_mini_sub_view_list_[channelId]:Active(viewData, self.uiBinder.node_mini_chat, self.uiBinder)
  else
    self:hideMiniChatBtn(channelId)
    self.chat_mini_sub_view_list_[channelId]:Show()
    self.chat_mini_sub_view_list_[channelId]:OnShow()
  end
  if not ignoreSelect then
    self:SelectMiniChat(channelId)
  end
end

function Main_chatView:SelectMiniChat(channelId)
  if channelId == nil or channelId == 0 then
    return
  end
  self.chatData_:SetSelectMiniChatChannelId(channelId)
  if self.chat_mini_sub_view_list_[channelId] and self.chat_mini_sub_view_list_[channelId].Trans then
    local rootIndex = self.uiBinder.node_mini_chat:GetSiblingIndex()
    self.chat_mini_sub_view_list_[channelId].Trans:SetSiblingIndex(rootIndex + 1)
  end
end

function Main_chatView:AsyncHideMiniChat(channelId)
  if self.chat_mini_sub_view_list_[channelId] then
    self.chat_mini_sub_view_list_[channelId]:Hide()
  end
  self.chatData_:UpdateMiniChatType(channelId, E.MiniChatType.EChatBtn)
  self:asyncShowMiniChatBtn(channelId)
end

function Main_chatView:CloseMiniChat(channelId)
  self.chatData_:RemoveMiniChat(channelId)
  if self.chat_mini_sub_view_list_[channelId] then
    self.chat_mini_sub_view_list_[channelId]:DeActive()
    self.chat_mini_sub_view_list_[channelId] = nil
  end
end

function Main_chatView:clearMiniChat()
  for _, miniView in pairs(self.chat_mini_sub_view_list_) do
    miniView:DeActive()
  end
end

function Main_chatView:asyncShowMiniChatBtn(channelId)
  local miniChatData = self.chatData_:GetMiniChatData(channelId)
  if not miniChatData then
    return
  end
  local channelName = Z.RichTextHelper.ApplyStyleTag(miniChatData.channelName, miniChatData.colorTag)
  if not self.chat_mini_btn_list_[channelId] then
    local item = self:AsyncLoadUiUnit(chatMiniBtnTplPath, tostring(channelId), self.uiBinder.node_mini_chat_btn)
    if not item then
      return
    end
    item.chat_minichat_btn_tpl:SetAnchorPosition(miniChatData.x, miniChatData.y)
    item.lab_channel.text = channelName
    item.Ref:SetVisible(item.chat_minichat_btn_tpl, true)
    self.chat_mini_btn_list_[channelId] = item
    self:AddClick(item.btn_minichat, function()
      if not self.isDrag_ then
        self:hideMiniChatBtn(channelId)
        self.chatData_:UpdateMiniChatType(channelId, E.MiniChatType.EChatView)
        self:showMiniChatView(channelId)
      end
    end)
    item.btn_minichat_trigger.onDrag:AddListener(function(go, eventData)
      self.isDrag_ = true
      local x, y = item.chat_minichat_btn_tpl:GetAnchorPosition()
      item.chat_minichat_btn_tpl:SetAnchorPosition(eventData.delta.x + x, eventData.delta.y + y)
      self.chatData_:UpdateMiniChatPosition(channelId, eventData.delta.x + x, eventData.delta.y + y)
    end)
    item.btn_minichat_trigger.onEndDrag:AddListener(function(go, eventData)
      self.isDrag_ = false
    end)
  else
    local miniChatData = self.chatData_:GetMiniChatData(channelId)
    if not miniChatData then
      return
    end
    local channelName = Z.RichTextHelper.ApplyStyleTag(miniChatData.channelName, miniChatData.colorTag)
    self.chat_mini_btn_list_[channelId].chat_minichat_btn_tpl:SetAnchorPosition(miniChatData.x, miniChatData.y)
    self.chat_mini_btn_list_[channelId].lab_channel.text = channelName
    self.chat_mini_btn_list_[channelId].Ref:SetVisible(self.chat_mini_btn_list_[channelId].chat_minichat_btn_tpl, true)
  end
end

function Main_chatView:hideMiniChatBtn(channelId)
  if self.chat_mini_btn_list_[channelId] then
    self.chat_mini_btn_list_[channelId].Ref:SetVisible(self.chat_mini_btn_list_[channelId].chat_minichat_btn_tpl, false)
  end
end

function Main_chatView:OnInputAction()
  Z.VMMgr.GetVM("gotofunc").GoToFunc(E.FunctionID.MainChat)
end

function Main_chatView:RegisterInputActions()
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Chat)
end

function Main_chatView:UnRegisterInputActions()
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Chat)
end

return Main_chatView
