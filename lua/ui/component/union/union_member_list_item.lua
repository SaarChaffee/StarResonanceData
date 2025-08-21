local super = require("ui.component.loopscrollrectitem")
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local UnionMemberListItem = class("UnionMemberListItem", super)
local SDKDefine = require("ui.model.sdk_define")

function UnionMemberListItem:ctor()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function UnionMemberListItem:OnInit()
  self:Selected(false)
end

function UnionMemberListItem:OnReset()
end

function UnionMemberListItem:OnUnInit()
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
end

function UnionMemberListItem:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self:SetUI(self.data_)
end

function UnionMemberListItem:SetUI(data)
  local basicData = data.socialData.basicData
  local positionName = self.unionVM_:GetOfficialName(data.baseData.officialId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(basicData.isNewbie))
  self.uiBinder.lab_name_select.text = basicData.name
  self.uiBinder.lab_posts_select.text = positionName
  self.uiBinder.lab_grade_select.text = basicData.level
  self.uiBinder.lab_active_select.text = data.baseData.weekActivePoints .. "/" .. data.baseData.historyActivePoints
  self.uiBinder.lab_state_select.text = self.unionVM_:GetLastTimeDesignText(basicData.offlineTime)
  local personalzoneVm = Z.VMMgr.GetVM("personal_zone")
  personalzoneVm.SetPersonalInfoBgBySocialData(data.socialData, self.uiBinder.rimg_card)
  if basicData.offlineTime == 0 then
    self.uiBinder.img_icon_state:SetImage(Z.ConstValue.UnionRes.StateOnIcon)
  else
    self.uiBinder.img_icon_state:SetImage(Z.ConstValue.UnionRes.StateOffIcon)
  end
  if self.headItem_ then
    self.headItem_:UnInit()
  end
  self.headItem_ = playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.bind_head, data.socialData, function()
    self:onItemClick()
  end, self.parent.uiView.cancelSource:CreateToken())
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_wechatprivilege, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qqprivilege, false)
  if self:isSelf(basicData.charID) then
    local accountData = Z.DataMgr.Get("account_data")
    local isPrivilege = self.sdkVM_.IsShowPrivilege()
    if accountData.LoginType == E.LoginType.QQ and isPrivilege then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qqprivilege, true)
    elseif accountData.LoginType == E.LoginType.WeChat and isPrivilege then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_wechatprivilege, true)
    end
  else
    local privilegeData = data.socialData.privilegeData
    if privilegeData ~= nil then
      if privilegeData.launchPlatform == SDKDefine.LaunchPlatform.LaunchPlatformQq and self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentQQPrivilege) then
        self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qqprivilege, privilegeData.isPrivilege)
      elseif privilegeData.launchPlatform == SDKDefine.LaunchPlatform.LaunchPlatformWeXin and self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentWeChatPrivilege) then
        self.uiBinder.Ref:SetVisible(self.uiBinder.btn_wechatprivilege, privilegeData.isPrivilege)
      end
    end
  end
  self.uiBinder.btn_wechatprivilege:AddListener(function()
    self.sdkVM_.PrivilegeBtnClick(basicData.charID)
  end)
  self.uiBinder.btn_qqprivilege:AddListener(function()
    self.sdkVM_.PrivilegeBtnClick()
  end)
end

function UnionMemberListItem:Selected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

function UnionMemberListItem:OnPointerClick(go, eventData)
  self:onItemClick()
end

function UnionMemberListItem:onItemClick()
  Z.CoroUtil.create_coro_xpcall(function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(self.data_.socialData.basicData.charID, self.parent.uiView.cancelSource:CreateToken())
  end)()
end

function UnionMemberListItem:isSelf(charID)
  return charID == Z.EntityMgr.PlayerEnt.EntId
end

return UnionMemberListItem
