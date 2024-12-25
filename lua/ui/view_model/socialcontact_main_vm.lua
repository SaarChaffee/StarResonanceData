local openSocialContactView = function()
  Z.UIMgr:OpenView("socialcontact_main")
end
local closeSocialContactView = function()
  Z.UIMgr:CloseView("socialcontact_main")
end
local openChatView = function(gotoMainView, channelId)
  if gotoMainView ~= nil and gotoMainView ~= false and gotoMainView ~= 0 then
    Z.UIMgr:GotoMainView()
  end
  if channelId ~= nil then
    local chatData = Z.DataMgr.Get("chat_main_data")
    if type(channelId) == "string" then
      channelId = tonumber(channelId)
    end
    chatData:SetChannelId(channelId)
  end
  local socialcontactData = Z.DataMgr.Get("socialcontact_data")
  socialcontactData:SetType(E.SocialType.Chat)
  Z.UIMgr:OpenView("socialcontact_main")
end
local openMailView = function(gotoMainView)
  if gotoMainView ~= nil and gotoMainView ~= false and gotoMainView ~= 0 then
    Z.UIMgr:GotoMainView()
  end
  local socialcontactData = Z.DataMgr.Get("socialcontact_data")
  socialcontactData:SetType(E.SocialType.Mail)
  Z.UIMgr:OpenView("socialcontact_main")
end
local openFriendView = function(gotoMainView)
  if gotoMainView ~= nil and gotoMainView ~= false and gotoMainView ~= 0 then
    Z.UIMgr:GotoMainView()
  end
  local socialcontactData = Z.DataMgr.Get("socialcontact_data")
  socialcontactData:SetType(E.SocialType.Friends)
  Z.UIMgr:OpenView("socialcontact_main")
end
local ret = {
  OpenChatView = openChatView,
  OpenMailView = openMailView,
  OpenFriendView = openFriendView,
  OpenSocialContactView = openSocialContactView,
  CloseSocialContactView = closeSocialContactView
}
return ret
