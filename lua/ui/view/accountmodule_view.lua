local UI = Z.UI
local super = require("ui.ui_subview_base")
local AccountmoduleView = class("AccountmoduleView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local PERSONALZONEDEFINE = require("ui.model.personalzone_define")
local SDKHelper = require("common.sdk_helper")

function AccountmoduleView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "set_account_sub", "set/set_account_sub", UI.ECacheLv.None)
end

function AccountmoduleView:OnActive()
  self.uiBinder.set_account_sub:SetOffsetMin(0, 0)
  self.uiBinder.set_account_sub:SetOffsetMax(0, 0)
  self.settingsTbl_ = Z.TableMgr.GetTable("SettingsTableMgr")
  self.settingsTypeTbl_ = Z.TableMgr.GetTable("SettingsTypeTableMgr")
  self.vm = Z.VMMgr.GetVM("accountmodule")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self.roleLevelData_ = Z.DataMgr.Get("role_level_data")
  self.personalzoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.playerVM_ = Z.VMMgr.GetVM("player")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.userCenterVM_ = Z.VMMgr.GetVM("user_center")
  self.isHudSettingChange_ = false
  self:setPlayerInfo()
  self:HUDSetting()
  Z.EventMgr:Add(Z.ConstValue.SDK.TencentPrivilegeRefresh, self.privilegeRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
end

function AccountmoduleView:setPlayerInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrIsNewbie")).Value))
  if self.playerVM_:IsNamed() then
    self.uiBinder.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  else
    self.uiBinder.lab_name.text = Lang("EmptyRoleName")
  end
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isRenameFuncUnloack = gotoFuncVM.CheckFuncCanUse(E.FunctionID.Rename, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_rename, self.playerVM_:IsNamed() and isRenameFuncUnloack)
  local isDetachStuckFuncOpen = gotoFuncVM.CheckFuncCanUse(E.FunctionID.DetachStuck, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_function_break, isDetachStuckFuncOpen)
  self.uiBinder.lab_uid.text = Lang("UID") .. Z.ContainerMgr.CharSerialize.charBase.showId
  self.uiBinder.lab_level.text = Lang("RoleLevel", {
    val = self.roleLevelData_:GetRoleLevel()
  })
  local iconstr = Z.ContainerMgr.CharSerialize.charBase.gender == 1 and "manicon" or "womanicon"
  local path = self:GetPrefabCacheDataNew(self.uiBinder.prefabCacheData, iconstr)
  self.uiBinder.img_gender:SetImage(path)
  Z.CoroUtil.create_coro_xpcall(function()
    if Z.EntityMgr.PlayerEnt == nil then
      logError("PlayerEnt is nil")
      return
    end
    self.socialData_ = self.socialVm_.AsyncGetSocialData(0, Z.EntityMgr.PlayerEnt.EntId, self.cancelSource:CreateToken())
    local viewData = {}
    viewData.id = self.socialData_.avatarInfo.avatarId
    viewData.modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
    viewData.charId = Z.EntityMgr.PlayerEnt.EntId
    viewData.headFrameId = nil
    viewData.token = self.cancelSource:CreateToken()
    if self.socialData_.avatarInfo and self.socialData_.avatarInfo.avatarFrameId then
      viewData.headFrameId = self.socialData_.avatarInfo.avatarFrameId
    end
    
    function viewData.func()
      local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
      personalzoneVM.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneHead)
    end
    
    playerPortraitHgr.InsertNewPortrait(self.uiBinder.cont_portrait, viewData)
    local cardConfig
    if self.socialData_.avatarInfo and 0 < self.socialData_.avatarInfo.businessCardStyleId then
      cardConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.socialData_.avatarInfo.businessCardStyleId)
    else
      cardConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.personalzoneData_:GetDefaultProfileImageConfigByType(PERSONALZONEDEFINE.ProfileImageType.Card))
    end
    if cardConfig then
      self.uiBinder.rimg_bg:SetImage(Z.ConstValue.PersonalZone.PersonalCardBgLong .. cardConfig.Image)
      self.uiBinder.img_line_left:SetColorByHex(cardConfig.Color)
      self.uiBinder.img_bg:SetColorByHex(cardConfig.Color2)
    end
  end)()
  local settingData = self.settingsTbl_.GetRow(6)
  if settingData then
    self.uiBinder.lab_function_out.text = settingData.Name
  end
  self:AddAsyncClick(self.uiBinder.btn_copy, function()
    Z.LuaBridge.SystemCopy(tostring(Z.ContainerMgr.CharSerialize.charBase.showId))
    Z.TipsVM.ShowTipsLang(100110)
  end)
  self:AddAsyncClick(self.uiBinder.btn_function_break, function()
    self.playerVM_:OpenUnstuckTip()
  end)
  self:AddAsyncClick(self.uiBinder.btn_function_out, function()
    self.vm.Logout()
  end)
  self:AddAsyncClick(self.uiBinder.btn_rename, function()
    self.playerVM_:OpenRenameWindow()
  end)
  self.uiBinder.lab_gasa:AddListener(function(linkName)
    self:OnLinkClick(linkName)
  end)
  self.uiBinder.lab_gpcp:AddListener(function(linkName)
    self:OnLinkClick(linkName)
  end)
  self.uiBinder.lab_ppg:AddListener(function(linkName)
    self:OnLinkClick(linkName)
  end)
  self.uiBinder.lab_record_number:AddListener(function(linkName)
    self:OnLinkClick(linkName)
  end)
  self.uiBinder.lab_info_share:AddListener(function(linkName)
    self:OnLinkClick(linkName)
  end)
  self.uiBinder.lab_collected_list:AddListener(function(linkName)
    self:OnLinkClick(linkName)
  end)
  self.uiBinder.lab_delete_account:AddListener(function(linkName)
    Z.SDKLogin.DeleteAccount()
  end)
  local accountData = Z.DataMgr.Get("account_data")
  local isTencentPlat = accountData.PlatformType == E.LoginPlatformType.TencentPlatform
  self:SetUIVisible(self.uiBinder.node_bottom, isTencentPlat)
  self:SetUIVisible(self.uiBinder.lab_record_number, Z.GameContext.IsPlayInMobile)
  self:AddAsyncClick(self.uiBinder.btn_wechatprivilege, function()
    self.sdkVM_.PrivilegeBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.uibinder_qqprivilege.btn, function()
    self.sdkVM_.PrivilegeBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_privilege, function()
    self.sdkVM_.PrivilegeBtnClick()
  end)
  self:SetUIVisible(self.uiBinder.btn_user_center, self.userCenterVM_.CheckValid(E.UserSupportType.Setting))
  self:AddAsyncClick(self.uiBinder.btn_user_center, function()
    self.userCenterVM_.OpenUserCenter(E.UserSupportType.Setting)
  end)
  local currentPlatform = Z.SDKLogin.GetPlatform()
  local isAPJPlat = currentPlatform == E.LoginPlatformType.APJPlatform
  self:SetUIVisible(self.uiBinder.btn_pay_set, not Z.GameContext.IsPlayInMobile and isAPJPlat)
  self:AddAsyncClick(self.uiBinder.btn_pay_set, function()
    Z.SDKPay.OpenPaymentSetting()
  end)
  self:privilegeRefresh()
end

function AccountmoduleView:OnLinkClick(linkName)
  local currentPlatform = Z.SDKLogin.GetPlatform()
  if linkName and linkName == "contract" then
    Z.SDKWebView.OpenWebView(SDKHelper.GetContractUrlPath(currentPlatform), false)
  elseif linkName and linkName == "privacy_guide" then
    Z.SDKWebView.OpenWebView(SDKHelper.GetPrivacyGuideUrlPath(currentPlatform), false)
  elseif linkName and linkName == "children_privacy" then
    Z.SDKWebView.OpenWebView(SDKHelper.GetChildrenPrivacyUrlPath(currentPlatform), false)
  elseif linkName and linkName == "third_info_share" then
    Z.SDKWebView.OpenWebView(SDKHelper.GetThirdInfoShareUrlPath(currentPlatform), false)
  elseif linkName and linkName == "collected_info_list" then
    Z.SDKWebView.OpenWebView(SDKHelper.GetCollectedInfoListUrlPath(currentPlatform), false)
  elseif linkName and linkName == "beian" then
    Z.SDKWebView.OpenURL("https://beian.miit.gov.cn", false)
  end
end

function AccountmoduleView:OnDeActive()
  if self.isHudSettingChange_ then
    Z.LuaBridge.RefreshHudSetting()
  end
  playerPortraitHgr.ClearAllActiveItems()
  Z.EventMgr:Remove(Z.ConstValue.SDK.TencentPrivilegeRefresh, self.privilegeRefresh, self)
  Z.EventMgr:Remove(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
end

function AccountmoduleView:WeaponDisplaySetting()
  local switch = self.uiBinder.cont_battle.binder_display_weapon.cont_switch.switch
  local weaponDisplay = self.settingVM_.Get(E.SettingID.WeaponDisplay)
  switch:SetIsOnWithoutNotify(weaponDisplay)
  switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.WeaponDisplay, isOn)
  end)
end

function AccountmoduleView:HUDSetting()
  self:PlayerInfoHUDSetting()
  self:OtherPlayerInfoHUDSetting()
  self:NPCInfoHUDSetting()
end

function AccountmoduleView:PlayerInfoHUDSetting()
  local togTitle = self.uiBinder.cont_battle.binder_player_info.tog_title
  local togName = self.uiBinder.cont_battle.binder_player_info.tog_name
  local data = self.settingVM_.Get(E.SettingID.PlayerHeadInformation)
  local settings = string.zsplit(data, ",")
  local settingDict = {}
  for _, v in ipairs(settings) do
    local setting = string.zsplit(v, "=")
    settingDict[tonumber(setting[1])] = setting[2]
  end
  local titleOn = settingDict[E.SettingHUDType.Title] == nil or settingDict[E.SettingHUDType.Title] == "1"
  local nameOn = settingDict[E.SettingHUDType.Name] == nil or settingDict[E.SettingHUDType.Name] == "1"
  togTitle:SetIsOnWithoutCallBack(titleOn)
  togName:SetIsOnWithoutCallBack(nameOn)
  togTitle:AddListener(function(isOn)
    local nameIsOn = togName.isOn and 1 or 0
    local titleIsOn = isOn and 1 or 0
    local data = string.zconcat(E.SettingHUDType.Name, "=", nameIsOn, ",", E.SettingHUDType.Title, "=", titleIsOn)
    self.settingVM_.Set(E.SettingID.PlayerHeadInformation, data)
    self.isHudSettingChange_ = true
  end)
  togName:AddListener(function(isOn)
    local nameIsOn = isOn and 1 or 0
    local titleIsOn = togTitle.isOn and 1 or 0
    local data = string.zconcat(E.SettingHUDType.Name, "=", nameIsOn, ",", E.SettingHUDType.Title, "=", titleIsOn)
    self.settingVM_.Set(E.SettingID.PlayerHeadInformation, data)
    self.isHudSettingChange_ = true
  end)
end

function AccountmoduleView:OtherPlayerInfoHUDSetting()
  local togTitle = self.uiBinder.cont_battle.binder_other_player_info.tog_title
  local togName = self.uiBinder.cont_battle.binder_other_player_info.tog_name
  local data = self.settingVM_.Get(E.SettingID.OtherPlayerHeadInformation)
  local settings = string.zsplit(data, ",")
  local settingDict = {}
  for _, v in ipairs(settings) do
    local setting = string.zsplit(v, "=")
    settingDict[tonumber(setting[1])] = setting[2]
  end
  local titleOn = settingDict[E.SettingHUDType.Title] == nil or settingDict[E.SettingHUDType.Title] == "1"
  local nameOn = settingDict[E.SettingHUDType.Name] == nil or settingDict[E.SettingHUDType.Name] == "1"
  togTitle:SetIsOnWithoutCallBack(titleOn)
  togName:SetIsOnWithoutCallBack(nameOn)
  togTitle:AddListener(function(isOn)
    local nameIsOn = togName.isOn and 1 or 0
    local titleIsOn = isOn and 1 or 0
    local data = string.zconcat(E.SettingHUDType.Name, "=", nameIsOn, ",", E.SettingHUDType.Title, "=", titleIsOn)
    self.settingVM_.Set(E.SettingID.OtherPlayerHeadInformation, data)
    self.isHudSettingChange_ = true
  end)
  togName:AddListener(function(isOn)
    local nameIsOn = isOn and 1 or 0
    local titleIsOn = togTitle.isOn and 1 or 0
    local data = string.zconcat(E.SettingHUDType.Name, "=", nameIsOn, ",", E.SettingHUDType.Title, "=", titleIsOn)
    self.settingVM_.Set(E.SettingID.OtherPlayerHeadInformation, data)
    self.isHudSettingChange_ = true
  end)
end

function AccountmoduleView:NPCInfoHUDSetting()
  local togFunc = self.uiBinder.cont_battle.binder_npc_info.tog_func
  local togName = self.uiBinder.cont_battle.binder_npc_info.tog_name
  local data = self.settingVM_.Get(E.SettingID.NPCPlayerHeadInformation)
  local settings = string.zsplit(data, ",")
  local settingDict = {}
  for _, v in ipairs(settings) do
    local setting = string.zsplit(v, "=")
    settingDict[tonumber(setting[1])] = setting[2]
  end
  local nameOn = settingDict[E.SettingHUDType.Name] == nil or settingDict[E.SettingHUDType.Name] == "1"
  local funcOn = settingDict[E.SettingHUDType.Func] == nil or settingDict[E.SettingHUDType.Func] == "1"
  togFunc:SetIsOnWithoutCallBack(funcOn)
  togName:SetIsOnWithoutCallBack(nameOn)
  togFunc:AddListener(function(isOn)
    local nameIsOn = togName.isOn and 1 or 0
    local funcIsOn = isOn and 1 or 0
    local data = string.zconcat(E.SettingHUDType.Name, "=", nameIsOn, ",", E.SettingHUDType.Func, "=", funcIsOn)
    self.settingVM_.Set(E.SettingID.NPCPlayerHeadInformation, data)
    self.isHudSettingChange_ = true
  end)
  togName:AddListener(function(isOn)
    local nameIsOn = isOn and 1 or 0
    local funcIsOn = togFunc.isOn and 1 or 0
    local data = string.zconcat(E.SettingHUDType.Name, "=", nameIsOn, ",", E.SettingHUDType.Func, "=", funcIsOn)
    self.settingVM_.Set(E.SettingID.NPCPlayerHeadInformation, data)
    self.isHudSettingChange_ = true
  end)
  local showTaskEffect = self.settingVM_.Get(E.SettingID.ShowTaskEffect)
  self.uiBinder.cont_battle.cont_task_effect.cont_switch.switch.IsOn = showTaskEffect
  self.uiBinder.cont_battle.cont_task_effect.cont_switch.switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.ShowTaskEffect, isOn)
  end)
  self:AddClick(self.uiBinder.cont_battle.cont_task_effect.btn_tips, function()
    self:OpenMinTips(20021, self.uiBinder.cont_battle.cont_task_effect.btn_tips_trans)
  end)
end

function AccountmoduleView:OpenMinTips(id, parent)
  local helpsysData = Z.DataMgr.Get("helpsys_data")
  if helpsysData == nil then
    return
  end
  local helpLibraryData = helpsysData:GetOtherDataById(id)
  if helpLibraryData == nil then
    return
  end
  local descContent = Z.TableMgr.DecodeLineBreak(table.concat(helpLibraryData.Content, "="))
  self:showTip(parent, descContent)
end

function AccountmoduleView:showTip(trans, content)
  Z.CommonTipsVM.ShowTipsTitleContent(trans, Lang("DialogDefaultTitle"), content, true)
end

function AccountmoduleView:privilegeRefresh(isPrivilege)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_wechatprivilege, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_privilege, false)
  self.uiBinder.uibinder_qqprivilege.Ref.UIComp:SetVisible(false)
  if isPrivilege == nil then
    isPrivilege = self.sdkVM_.IsShowPrivilege()
  end
  if self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentQQPrivilege) then
    self.uiBinder.uibinder_qqprivilege.Ref.UIComp:SetVisible(true)
    self.uiBinder.uibinder_qqprivilege.Ref:SetVisible(self.uiBinder.uibinder_qqprivilege.img_mask, not isPrivilege)
  elseif self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentWeChatPrivilege) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_wechatprivilege, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_privilege, isPrivilege)
  end
end

function AccountmoduleView:onChangeNameResultNtf(errCode)
  if errCode == 0 then
    self.uiBinder.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  end
end

return AccountmoduleView
