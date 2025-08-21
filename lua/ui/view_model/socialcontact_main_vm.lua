local openSocialContactView = function()
  if Z.IsPCUI then
    Z.UIMgr:OpenView("socialize_main_pc")
  else
    Z.UIMgr:OpenView("socialize_main")
  end
end
local closeSocialContactView = function()
  if Z.IsPCUI then
    Z.UIMgr:CloseView("socialize_main_pc")
  else
    Z.UIMgr:CloseView("socialize_main")
  end
end
local openChatView = function(gotoMainView, channelId, firstOpenExpressionIndex)
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
  if Z.IsPCUI then
    if firstOpenExpressionIndex == nil then
      Z.UIMgr:OpenView("socialize_main_pc")
    else
      Z.UIMgr:OpenView("socialize_main_pc", {firstOpenIndex = firstOpenExpressionIndex})
    end
  else
    Z.UIMgr:OpenView("socialize_main")
  end
end
local openMailView = function(gotoMainView)
  if gotoMainView ~= nil and gotoMainView ~= false and gotoMainView ~= 0 then
    Z.UIMgr:GotoMainView()
  end
  local socialcontactData = Z.DataMgr.Get("socialcontact_data")
  socialcontactData:SetType(E.SocialType.Mail)
  if Z.IsPCUI then
    Z.UIMgr:OpenView("socialize_main_pc")
  else
    Z.UIMgr:OpenView("socialize_main")
  end
end
local openFriendView = function(gotoMainView)
  if gotoMainView ~= nil and gotoMainView ~= false and gotoMainView ~= 0 then
    Z.UIMgr:GotoMainView()
  end
  local socialcontactData = Z.DataMgr.Get("socialcontact_data")
  socialcontactData:SetType(E.SocialType.Friends)
  if Z.IsPCUI then
    Z.UIMgr:OpenView("socialize_main_pc")
  else
    Z.UIMgr:OpenView("socialize_main")
  end
end
local ret = {
  OpenChatView = openChatView,
  OpenMailView = openMailView,
  OpenFriendView = openFriendView,
  OpenSocialContactView = openSocialContactView,
  CloseSocialContactView = closeSocialContactView
}
return ret
