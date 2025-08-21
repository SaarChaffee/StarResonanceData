local UI = Z.UI
local super = require("ui.ui_view_base")
local Socialize_main_pcView = class("Socialize_main_pcView", super)

function Socialize_main_pcView:ctor()
  self.uiBinder = nil
  super.ctor(self, "socialize_main_pc")
  self.chatView_ = require("ui.view.chat_sub_pc_view").new(self)
  self.friendView_ = require("ui.view.friends_main_sub_pc_view").new(self)
  self.mailView_ = require("ui.view.mail_window_view").new(self)
  self.expressionView_ = require("ui.view.expression_window_pc_view").new(self)
end

function Socialize_main_pcView:OnActive()
  self:onStartAnimShow()
  self:initVMData()
  self:initFunc()
  self:initRed()
end

function Socialize_main_pcView:OnDeActive()
  Z.AudioMgr:Play("UI_Menu_QuickInstruction_Close")
  self:clearTog()
  self:clearRed()
  if self.curSubView_ then
    self.curSubView_:DeActive()
    self.curSubView_ = nil
  end
  self.expressionView_:DeActive()
end

function Socialize_main_pcView:initVMData()
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.socialVM_ = Z.VMMgr.GetVM("socialcontact_main")
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
  self.socialcontactData_ = Z.DataMgr.Get("socialcontact_data")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
end

function Socialize_main_pcView:initFunc()
  self:AddClick(self.uiBinder.btn_close, function()
    self.socialVM_.CloseSocialContactView()
  end)
  self:AddClick(self.uiBinder.btn_setting, function()
    self.chatMainVM_.OpenChatSettingPopupView()
  end)
  self:AddClick(self.uiBinder.btn_mail_tips, function()
    self.helpsysVM_.OpenFullScreenTipsView(30002)
  end)
  self.uiBinder.tog_chat.isOn = false
  self.uiBinder.tog_friend.isOn = false
  self.uiBinder.tog_mail.isOn = false
  self.uiBinder.tog_chat.group = self.uiBinder.togs_group
  self.uiBinder.tog_friend.group = self.uiBinder.togs_group
  self.uiBinder.tog_mail.group = self.uiBinder.togs_group
  self.uiBinder.tog_chat:AddListener(function(isOn)
    if not isOn then
      return
    end
    self.socialcontactData_:SetType(E.SocialType.Chat)
    self:showSubView(self.chatView_)
    self:refreshBtnState(true, false)
  end)
  self.uiBinder.tog_friend:AddListener(function(isOn)
    if not isOn then
      return
    end
    self:onClickFriendRed()
    self.socialcontactData_:SetType(E.SocialType.Friends)
    self:showSubView(self.friendView_)
    self:refreshBtnState(true, false)
  end)
  self.uiBinder.tog_mail:AddListener(function(isOn)
    if not isOn then
      return
    end
    self:onClickMailRed()
    self.socialcontactData_:SetType(E.SocialType.Mail)
    self:showSubView(self.mailView_)
    self:refreshBtnState(false, true)
  end)
  if self.socialcontactData_:GetType() == E.SocialType.Chat then
    self.uiBinder.tog_chat.isOn = true
  elseif self.socialcontactData_:GetType() == E.SocialType.Friends then
    self.uiBinder.tog_friend.isOn = true
  else
    self.uiBinder.tog_mail.isOn = true
  end
  if self.viewData and self.viewData.firstOpenIndex then
    self.expressionView_:Active({
      firstOpenIndex = self.viewData.firstOpenIndex
    }, self.uiBinder.node_right_bottom)
  else
    self.expressionView_:Active(nil, self.uiBinder.node_right_bottom)
  end
end

function Socialize_main_pcView:clearTog()
  self.uiBinder.tog_chat.group = nil
  self.uiBinder.tog_friend.group = nil
  self.uiBinder.tog_mail.group = nil
  self.uiBinder.tog_chat:RemoveAllListeners()
  self.uiBinder.tog_friend:RemoveAllListeners()
  self.uiBinder.tog_mail:RemoveAllListeners()
  self.uiBinder.tog_chat.isOn = false
  self.uiBinder.tog_friend.isOn = false
  self.uiBinder.tog_mail.isOn = false
end

function Socialize_main_pcView:showSubView(subView)
  if not subView then
    return
  end
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Tween_0)
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  self.curSubView_ = subView
  self.curSubView_:Active(nil, self.uiBinder.node_middel, self.uiBinder)
end

function Socialize_main_pcView:refreshBtnState(showChatSetting, showMailTips)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_setting, showChatSetting)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_mail_tips, showMailTips)
end

function Socialize_main_pcView:initRed()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.SocialcontactFriendTab, self, self.uiBinder.node_red_friend)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.SocialcontactMailTab, self, self.uiBinder.node_red_mail)
end

function Socialize_main_pcView:onClickFriendRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.SocialcontactFriendTab)
end

function Socialize_main_pcView:onClickMailRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.SocialcontactMailTab)
end

function Socialize_main_pcView:clearRed()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.SocialcontactFriendTab, self)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.SocialcontactMailTab, self)
end

function Socialize_main_pcView:ShowChatEmojiContainerPopup()
  local viewData = {
    parentView = self,
    channelId = self.chatMainData_:GetComprehensiveId(),
    windowType = E.ChatWindow.Main,
    isHideChatInputBox = true
  }
  Z.UIMgr:OpenView("chat_emoji_container_popup", viewData)
end

function Socialize_main_pcView:onStartAnimShow()
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Open)
end

return Socialize_main_pcView
