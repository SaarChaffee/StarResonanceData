local UI = Z.UI
local super = require("ui.ui_view_base")
local Socialize_mainView = class("Socialize_mainView", super)
local chat_mainView = require("ui.view.chat_sub_view")
local friend_mainView = require("ui.view.friends_main_sub_view")
local mail_mainView = require("ui/view/mail_window_view")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function Socialize_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "socialize_main")
  self.socialcontactData_ = Z.DataMgr.Get("socialcontact_data")
  self.mainUIData_ = Z.DataMgr.Get("mainui_data")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.mainUiVm_ = Z.VMMgr.GetVM("mainui")
end

function Socialize_mainView:OnActive()
  self.isFirstOpenSubView_ = true
  self:onInitProp()
  self:onInitComp()
  self:onInitRed()
  self:BindLuaAttrWatchers()
  self:BindEvents()
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI)
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.Left, self.viewConfigKey, true)
  self.mainUIData_:SetIsShowMainChat(false)
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.HideLeft, true)
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.UpdateMainUIMainChat)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Socialize_mainView:onInitProp()
  self.vm_ = Z.VMMgr.GetVM("socialcontact_main")
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendsMainData_ = Z.DataMgr.Get("friend_main_data")
  self.chat_mainView_ = nil
  self.mail_mainView_ = nil
  self.friend_mainView_ = nil
end

function Socialize_mainView:onInitComp()
  self.uiBinder.tog_chat.group = self.uiBinder.togs_tab
  self.uiBinder.tog_friend.group = self.uiBinder.togs_tab
  self.uiBinder.tog_mail.group = self.uiBinder.togs_tab
  self.uiBinder.tog_chat:AddListener(function(isOn)
    self.socialcontactData_:SetType(E.SocialType.Chat)
    self:onRefreshChat(isOn)
  end)
  self.uiBinder.tog_friend:AddListener(function(isOn)
    self.socialcontactData_:SetType(E.SocialType.Friends)
    self:onRefreshFriend(isOn)
  end)
  self.uiBinder.tog_mail:AddListener(function(isOn)
    self.socialcontactData_:SetType(E.SocialType.Mail)
    self:onRefreshMail(isOn)
  end)
  self.uiBinder.press_check:StartCheck()
  self:EventAddAsyncListener(self.uiBinder.press_check.PointGoEvent, function(isPointGo)
    if not isPointGo then
      self.uiBinder.press_check:StopCheck()
      self.vm_.CloseSocialContactView()
    end
  end, nil, nil)
end

function Socialize_mainView:onInitRed()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.SocialcontactFriendTab, self, self.uiBinder.node_red_friend)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.SocialcontactMailTab, self, self.uiBinder.node_red_mail)
end

function Socialize_mainView:onClickFriendRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.SocialcontactFriendTab)
end

function Socialize_mainView:onClickMailRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.SocialcontactMailTab)
end

function Socialize_mainView:clearRed()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.SocialcontactFriendTab, self)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.SocialcontactMailTab, self)
end

function Socialize_mainView:OnDeActive()
  self:onRefreshChat(false)
  self:onRefreshFriend(false)
  self:onRefreshMail(false)
  self.friendsMainData_:ClearAllRightSubViewList()
  self:clearRed()
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.Left, self.viewConfigKey, false)
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.HideLeft, false)
  local deadView = Z.UIMgr:GetView("dead")
  if deadView and deadView.IsActive then
    self.mainUIData_:SetIsShowMainChat(true)
    Z.EventMgr:Dispatch(Z.ConstValue.MainUI.UpdateMainUIMainChat)
  end
  if not Z.IsPCUI then
    Z.EventMgr:Dispatch(Z.ConstValue.MainUI.RefreshChatView)
  end
end

function Socialize_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendSelfPersonalStateRefresh, self.refreshSelfPersonalState, self)
end

function Socialize_mainView:BindLuaAttrWatchers()
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendSelfPersonalStateRefresh, self.refreshSelfPersonalState, self)
end

function Socialize_mainView:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncRefreshSelfHead()
  end)()
  self:refreshSelfPersonalState()
  self:refreshViewShow()
end

function Socialize_mainView:asyncRefreshSelfHead()
  local socialData = self.socialVm_.AsyncGetHeadAndHeadFrameInfo(Z.ContainerMgr.CharSerialize.charBase.charId, self.cancelSource:CreateToken())
  playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.com_player_portrait_item, socialData, nil, self.cancelSource:CreateToken())
end

function Socialize_mainView:refreshSelfPersonalState()
  local persData = self.friendsMainVm_.GetFriendsStatus(0, self.friendsMainData_:GetPlayerPersonalState())
  if persData == nil then
    return
  end
  self.uiBinder.img_icon:SetImage(Z.ConstValue.Friend.FriendIconPath .. persData.Res)
end

function Socialize_mainView:refreshViewShow()
  if self.socialcontactData_.Type == E.SocialType.Chat then
    if self.uiBinder.tog_chat.isOn then
      self:onRefreshChat(true)
    else
      self.uiBinder.tog_chat.isOn = true
    end
  elseif self.socialcontactData_.Type == E.SocialType.Friends then
    if self.uiBinder.tog_friend.isOn then
      self:onRefreshFriend(true)
    else
      self.uiBinder.tog_friend.isOn = true
    end
  elseif self.socialcontactData_.Type == E.SocialType.Mail then
    if self.uiBinder.tog_mail.isOn then
      self:onRefreshMail(true)
    else
      self.uiBinder.tog_mail.isOn = true
    end
  end
end

function Socialize_mainView:onRefreshChat(isShow)
  if isShow then
    if self.chat_mainView_ == nil then
      self.chat_mainView_ = chat_mainView.new()
      self.chat_mainView_:Active({
        isFirstOpen = self.isFirstOpenSubView_
      }, self.uiBinder.node_sub, self.uiBinder)
      self.isFirstOpenSubView_ = false
    elseif self.chat_mainView_.IsActive and self.chat_mainView_.IsLoaded then
      self.chat_mainView_:OnRefresh()
    end
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_1)
  else
    if self.chat_mainView_ ~= nil then
      self.chat_mainView_:DeActive()
    end
    self.chat_mainView_ = nil
  end
end

function Socialize_mainView:onRefreshFriend(isShow)
  if isShow then
    if self.friend_mainView_ == nil then
      self.friend_mainView_ = friend_mainView.new()
      self.friend_mainView_:Active({
        isFirstOpen = self.isFirstOpenSubView_
      }, self.uiBinder.node_sub, self.uiBinder)
      self.isFirstOpenSubView_ = false
    elseif self.friend_mainView_.IsActive and self.friend_mainView_.IsLoaded then
      self.friend_mainView_:OnRefresh()
    end
    self:onClickFriendRed()
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_2)
  else
    if self.friend_mainView_ ~= nil then
      self.friend_mainView_:DeActive()
    end
    self.friend_mainView_ = nil
  end
end

function Socialize_mainView:onRefreshMail(isShow)
  if isShow then
    if self.mail_mainView_ == nil then
      self.mail_mainView_ = mail_mainView.new()
      self.mail_mainView_:Active({
        isFirstOpen = self.isFirstOpenSubView_
      }, self.uiBinder.node_sub, self.uiBinder)
      self.isFirstOpenSubView_ = false
    elseif self.mail_mainView_.IsActive and self.mail_mainView_.IsLoaded then
      self.mail_mainView_:OnRefresh()
    end
    self:onClickMailRed()
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_3)
  else
    if self.mail_mainView_ then
      self.mail_mainView_:DeActive()
    end
    self.mail_mainView_ = nil
  end
end

function Socialize_mainView:GetCacheData()
  return self.viewData
end

return Socialize_mainView
