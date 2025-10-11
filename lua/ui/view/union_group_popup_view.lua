local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_group_popupView = class("Union_group_popupView", super)
local TENCENT_DEFINE = require("ui.model.tencent_define")
local QQ_ICON_PATH = "ui/atlas/new_com/com_icon_qq"
local WECHAT_ICON_PATH = "ui/atlas/new_com/com_icon_wechat"

function Union_group_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_group_popup")
end

function Union_group_popupView:OnActive()
  self:initData()
  self:initComponent()
end

function Union_group_popupView:OnDeActive()
  self.uiBinder.input_content.text = ""
end

function Union_group_popupView:OnRefresh()
end

function Union_group_popupView:initData()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.accountData_ = Z.DataMgr.Get("account_data")
  self.unionInfo_ = self.unionVM_:GetPlayerUnionInfo()
  self.inputLimit_ = Z.Global.UnionGroupInviteLimit
end

function Union_group_popupView:initComponent()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_send, function()
    self:onSendBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_unbind, function()
    self:onUnbindBtnClick()
  end)
  self.uiBinder.input_content:AddListener(function()
    self:onInputContentChanged()
  end)
  if self.viewData.GroupName ~= "" then
    self.uiBinder.lab_name.text = self.viewData.GroupName
  else
    self.uiBinder.lab_name.text = self.unionInfo_.baseInfo.Name
  end
  if self.viewData.GroupType == TENCENT_DEFINE.GROUP_CHANNEL.QQ then
    self.uiBinder.img_icon:SetImage(QQ_ICON_PATH)
  elseif self.viewData.GroupType == TENCENT_DEFINE.GROUP_CHANNEL.WeChat then
    self.uiBinder.img_icon:SetImage(WECHAT_ICON_PATH)
  else
    self.uiBinder.img_icon.enabled = false
  end
  self.uiBinder.input_content.text = Lang("AddGroupReminders")
end

function Union_group_popupView:onSendBtnClick()
  local content = self.uiBinder.input_content.text
  if content == "" then
    Z.TipsVM.ShowTipsLang(100004)
    return
  end
  local length = string.zlenNormalize(content)
  if length > self.inputLimit_ then
    content = string.zcutNormalize(content, self.inputLimit_)
  end
  local errCode = self.unionVM_:AsyncInviteJoinGroupWithTencent(content, self.cancelSource:CreateToken())
  if errCode and errCode == 0 then
    Z.TipsVM.ShowTips(1000585)
  end
end

function Union_group_popupView:onUnbindBtnClick()
  if not Z.GameContext.IsPlayInMobile then
    Z.TipsVM.ShowTips(1000587)
    return
  end
  local data = {
    tipDesc = Lang("UnionUnbindLabel"),
    verifyLabel = Lang("UnbindLabel"),
    isCanInputEmpty = true,
    onConfirm = function()
      if self.viewData.UnbindCallback then
        self.viewData.UnbindCallback()
      end
      Z.UIMgr:CloseView(self.viewConfigKey)
    end
  }
  Z.TipsVM.OpenCommonPopupInput(data)
end

function Union_group_popupView:onInputContentChanged()
  local content = self.uiBinder.input_content.text
  local length = string.zlenNormalize(content)
  if length > self.inputLimit_ then
    self.uiBinder.input_content.text = string.zcutNormalize(content, self.inputLimit_)
  else
    self.uiBinder.lab_digit.text = string.zconcat(length, "/", self.inputLimit_)
  end
end

return Union_group_popupView
