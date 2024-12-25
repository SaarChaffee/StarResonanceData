local super = require("ui.service.service_base")
local ChatService = class("ChatService", super)

function ChatService:OnInit()
  Z.EventMgr:Add(Z.ConstValue.Chat.CreatePrivateChat, self.createPrivateChat, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.DeletePrivateChat, self.deletePrivateChat, self)
end

function ChatService:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.Chat.CreatePrivateChat, self.createPrivateChat, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.DeletePrivateChat, self.deletePrivateChat, self)
end

function ChatService:OnLogin()
  Z.ChatTimmingMark.BinderEvent()
end

function ChatService:OnLogout()
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

function ChatService:createPrivateChat(charId)
  Z.CoroUtil.create_coro_xpcall(function()
    local chatMainVM = Z.VMMgr.GetVM("chat_main")
    local chatMainData = Z.DataMgr.Get("chat_main_data")
    chatMainVM.AsyncCreatePrivateChat(charId, chatMainData.CancelSource:CreateToken())
    chatMainVM.AsyncUpdatePrivateChatCharInfo()
    chatMainVM.UpdatePrivateChatLastMsg(charId)
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.PrivateChatRefresh, true)
  end)()
end

function ChatService:deletePrivateChat(charId)
  Z.CoroUtil.create_coro_xpcall(function()
    local chatMainVM = Z.VMMgr.GetVM("chat_main")
    local chatMainData = Z.DataMgr.Get("chat_main_data")
    chatMainVM.AsyncDeletePrivateChat(charId, chatMainData.CancelSource:CreateToken())
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.PrivateChatRefresh)
  end)()
end

return ChatService
