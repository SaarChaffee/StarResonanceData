local UI = Z.UI
local super = require("ui.ui_view_base")
local Login_affiche_popupView = class("Login_affiche_popupView", super)
local loopListView = require("ui/component/loop_list_view")
local affiche_frame_item = require("ui.component.login.affiche_frame_item")
local textureFixedWidth = 900

function Login_affiche_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "login_affiche_popup")
  self.afficheData_ = Z.DataMgr.Get("affiche_data")
end

function Login_affiche_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.curNoticeType_ = nil
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("login_affiche_popup")
  end)
  self.uiBinder.tog_item:AddListener(function(isOn)
    if isOn then
      self:switchNoticeType(E.NoticeType.Event)
    end
  end)
  self.uiBinder.tog_system:AddListener(function(isOn)
    if isOn then
      self:switchNoticeType(E.NoticeType.System)
    end
  end)
  self.list_ = loopListView.new(self, self.uiBinder.loop_item, affiche_frame_item, "login_tog_tpl")
  self.list_:Init({})
  self:BindEvents()
end

function Login_affiche_popupView:OnDeActive()
  self:UnBindEvents()
  if self.list_ then
    self.list_:UnInit()
    self.list_ = nil
  end
end

function Login_affiche_popupView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.AfficheRefresh, self.refreshInfo, self)
end

function Login_affiche_popupView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.AfficheRefresh, self.refreshInfo, self)
end

function Login_affiche_popupView:OnRefresh()
  if self.uiBinder.tog_system.isOn then
    self:switchNoticeType(E.NoticeType.System)
  else
    self.uiBinder.tog_system.isOn = true
  end
end

function Login_affiche_popupView:switchNoticeType(noticeType)
  if self.curNoticeType_ == noticeType then
    return
  end
  self.curNoticeType_ = noticeType
  self:refreshInfo()
end

function Login_affiche_popupView:refreshInfo()
  self:showAfficheList()
  self:showAffiche()
end

function Login_affiche_popupView:showAffiche()
  local afficheDataItem = self.afficheData_:GetShowAfficheData(self.curNoticeType_)
  if afficheDataItem == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_new, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_title_frame, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_group, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_subtitle, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_new, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_title_frame, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_subtitle, true)
    self.uiBinder.lab_title.text = afficheDataItem.titleName_
    self.uiBinder.lab_subtitle.text = afficheDataItem.afficheContent_
    Z.RichTextHelper.ClickLink(self.uiBinder.lab_subtitle)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_group, false)
    if afficheDataItem.afficheImage_ and afficheDataItem.afficheImage_ ~= "" then
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_subtitle, false)
      self.uiBinder.rimg_content:AsyncLoadUrlImage(afficheDataItem.afficheImage_, function()
        if afficheDataItem == nil then
          self.uiBinder.Ref:SetVisible(self.uiBinder.node_group, false)
          self.uiBinder.Ref:SetVisible(self.uiBinder.lab_subtitle, false)
        end
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_subtitle, true)
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_group, true)
        self:adjustImageHeight()
      end)
    end
  end
end

function Login_affiche_popupView:adjustImageHeight()
  if self.uiBinder.rimg_content.width == 0 then
    return
  end
  local adjustHeight = textureFixedWidth / self.uiBinder.rimg_content.width * self.uiBinder.rimg_content.height
  self.uiBinder.node_group_layout.minHeight = adjustHeight
end

function Login_affiche_popupView:showAfficheList()
  local datas = self.afficheData_:GetAfficheData(self.curNoticeType_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.empty_item, #datas == 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item, #datas ~= 0)
  self.list_:RefreshListView(datas)
end

return Login_affiche_popupView
