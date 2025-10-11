local super = require("ui.service.service_base")
local ChatService = class("ChatService", super)
local ChatStickersTableMap = require("table.ChatStickersTableMap")
local onEmojiUnlock = function(data, dirtyKeys)
  for emoji, isUnlock in pairs(dirtyKeys.unlockMap) do
    if isUnlock then
      local red = string.zconcat(Z.ConstValue.Chat.ChatEmojiItem, emoji)
      Z.RedPointMgr.UpdateNodeCount(red, 0)
      Z.RedPointMgr.RefreshRedNodeState(red)
      Z.TipsVM.ShowTips(1000109)
    end
  end
end

function ChatService:OnInit()
  Z.EventMgr:Add(Z.ConstValue.Chat.CreatePrivateChat, self.createPrivateChat, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.DeletePrivateChat, self.deletePrivateChat, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.checkChatEmojiUnlockRedByItem, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.checkChatEmojiUnlockRedByItem, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.checkChatEmojiUnlockRedByItem, self)
end

function ChatService:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.Chat.CreatePrivateChat, self.createPrivateChat, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.DeletePrivateChat, self.deletePrivateChat, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, self.checkChatEmojiUnlockRedByItem, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, self.checkChatEmojiUnlockRedByItem, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.checkChatEmojiUnlockRedByItem, self)
end

function ChatService:OnLogin()
  Z.ContainerMgr.CharSerialize.unlockEmojiData.Watcher:RegWatcher(onEmojiUnlock)
  Z.ChatTimmingMark.BinderEvent()
end

function ChatService:OnLogout()
  Z.ContainerMgr.CharSerialize.unlockEmojiData.Watcher:UnregWatcher(onEmojiUnlock)
  Z.ChatTimmingMark.UnBinderEvent()
end

function ChatService:OnReconnect()
  local accountData = Z.DataMgr.Get("account_data")
  Z.Voice.Init(accountData.OpenID)
  local chatMainData = Z.DataMgr.Get("chat_main_data")
  chatMainData:ResetData()
  self:asyncInitChat()
end

function ChatService:OnEnterScene()
  if Z.StageMgr.GetIsInGameScene() then
    self:asyncInitChat()
    local chatSettingData = Z.DataMgr.Get("chat_setting_data")
    chatSettingData:InitChatSetting()
  end
end

function ChatService:asyncInitChat()
  Z.CoroUtil.create_coro_xpcall(function()
    local chatMainVM = Z.VMMgr.GetVM("chat_main")
    chatMainVM.AsyncInitChatData()
  end)()
end

function ChatService:createPrivateChat(charId, receiveMsg)
  Z.CoroUtil.create_coro_xpcall(function()
    local chatMainVM = Z.VMMgr.GetVM("chat_main")
    local chatMainData = Z.DataMgr.Get("chat_main_data")
    chatMainVM.AsyncCreatePrivateChat(charId, chatMainData.CancelSource:CreateToken())
    chatMainVM.AsyncUpdatePrivateChatCharInfo()
    chatMainVM.AsyncGetPrivateChatRecord(charId, 0, true)
    chatMainVM.AsyncUpdatePrivateChatLastMsg(charId, receiveMsg, chatMainData.CancelSource:CreateToken())
    chatMainVM.CheckMainUIFriendNewMessage()
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.PrivateChatRefresh)
  end)()
end

function ChatService:deletePrivateChat(charId)
  Z.CoroUtil.create_coro_xpcall(function()
    local chatMainVM = Z.VMMgr.GetVM("chat_main")
    local chatMainData = Z.DataMgr.Get("chat_main_data")
    chatMainVM.AsyncDeletePrivateChat(charId, chatMainData.CancelSource:CreateToken())
    Z.RedPointMgr.UpdateNodeCount(E.RedType.FriendChatTab, chatMainData:GetPrivateChatUnReadCount())
    chatMainVM.CheckMainUIFriendNewMessage()
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.PrivateChatRefresh)
  end)()
end

function ChatService:OnSyncAllContainerData()
  self:checkChatEmojiUnlockRed()
end

function ChatService:checkChatEmojiUnlockRed()
  local itemsVM = Z.VMMgr.GetVM("items")
  local unlockMap = ChatStickersTableMap.UnlockItemMap
  for itemId, emojiList in pairs(unlockMap) do
    if itemsVM.GetItemTotalCount(itemId) > 0 then
      for i = 1, #emojiList do
        self:checkChatEmojiUnlockRedByEmojiId(emojiList[i])
      end
    end
  end
end

function ChatService:checkChatEmojiUnlockRedByItem(item)
  local unlockMap = ChatStickersTableMap.UnlockItemMap
  if not unlockMap[item.configId] then
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.GetItemTotalCount(item.configId) == 0 then
    return
  end
  for i = 1, #unlockMap[item.configId] do
    self:checkChatEmojiUnlockRedByEmojiId(unlockMap[item.configId][i])
  end
end

function ChatService:checkChatEmojiUnlockRedByEmojiId(emojId)
  local chatMainVM = Z.VMMgr.GetVM("chat_main")
  if chatMainVM.GetChatEmojiUnlock(emojId) then
    return
  end
  local row = Z.TableMgr.GetTable("ChatStickersTableMgr").GetRow(emojId, true)
  if not row then
    return
  end
  if row.IsDefUnlock == 0 then
    return
  end
  local parentRed = string.zconcat(Z.ConstValue.Chat.ChatEmojiTab, row.GroupId)
  Z.RedPointMgr.AddChildNodeData(E.RedType.ChatInputBoxEmojiFunctionBtn, E.RedType.ChatInputBoxEmojiFunctionBtn, parentRed)
  local itemRed = string.zconcat(Z.ConstValue.Chat.ChatEmojiItem, row.Id)
  Z.RedPointMgr.AddChildNodeData(parentRed, E.RedType.ChatInputBoxEmojiFunctionBtn, itemRed)
  Z.RedPointMgr.UpdateNodeCount(itemRed, 1)
  Z.RedPointMgr.RefreshRedNodeState(itemRed)
end

return ChatService
