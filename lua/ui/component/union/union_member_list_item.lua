local super = require("ui.component.loop_list_view_item")
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local UnionMemberListItem = class("UnionMemberListItem", super)
local SDKDefine = require("ui.model.sdk_define")

function UnionMemberListItem:ctor()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function UnionMemberListItem:OnInit()
  self.uiBinder.btn_wechatprivilege:AddListener(function()
    local data = self:GetCurData()
    if data == nil then
      return
    end
    self.sdkVM_.PrivilegeBtnClick(data.socialData.basicData.charID)
  end)
  self.uiBinder.btn_qqprivilege:AddListener(function()
    self.sdkVM_.PrivilegeBtnClick()
  end)
end

function UnionMemberListItem:OnUnInit()
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
end

function UnionMemberListItem:OnRefresh(data)
  local token = self:getParentViewToken()
  if token == nil then
    return
  end
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
  end, token)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_wechatprivilege, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qqprivilege, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  if basicData.charID == Z.EntityMgr.PlayerEnt.CharId then
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
end

function UnionMemberListItem:OnSelected()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function UnionMemberListItem:OnPointerClick(go, eventData)
  self:onItemClick()
end

function UnionMemberListItem:onItemClick()
  Z.CoroUtil.create_coro_xpcall(function()
    local curData = self:GetCurData()
    if curData == nil then
      return
    end
    local token = self:getParentViewToken()
    if token == nil then
      return
    end
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(curData.socialData.basicData.charID, token)
  end)()
end

function UnionMemberListItem:getParentViewToken()
  if self.parent and self.parent.UIView and self.parent.UIView.cancelSource then
    return self.parent.UIView.cancelSource:CreateToken()
  end
  return nil
end

return UnionMemberListItem
