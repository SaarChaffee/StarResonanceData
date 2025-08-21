local UI = Z.UI
local super = require("ui.ui_view_base")
local LoginView = class("LoginView", super)
local SDKHelper = require("common.sdk_helper")
local friendUrlRawImage = require("ui.component.login.friend_url_rawimage")
local logoImg = "ui/textures/login/login_logo"

function LoginView:ctor()
  self.uiBinder = nil
  super.ctor(self, "login")
  self.loginVm_ = Z.VMMgr.GetVM("login")
  self.afficheVM_ = Z.VMMgr.GetVM("affiche")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.userSupportVM_ = Z.VMMgr.GetVM("user_support")
  self.userCenterVM_ = Z.VMMgr.GetVM("user_center")
  self.serverData_ = Z.DataMgr.Get("server_data")
  self.loginData_ = Z.DataMgr.Get("login_data")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.faceVM_ = Z.VMMgr.GetVM("face")
  self.loginState_ = E.LoginState.Init
  self.waitLogin_ = false
  self.hideServerSelectOnDebug_ = false
end

function LoginView:OnActive()
  self:BindEvents()
  self:setVersion()
  self:initData()
  self:initComponents()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.AudioMgr:SetState(E.AudioState.Login, "Sys_Login")
  if self.currentPlatform_ == E.LoginPlatformType.TencentPlatform then
    self.uiBinder.lab_info.text = Lang("LoginViewInfo")
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info, true)
  elseif self.currentPlatform_ == E.LoginPlatformType.APJPlatform then
    self.uiBinder.lab_info.text = Lang("LoginViewInfoApj")
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info, false)
  end
  self.uiBinder.uibinder_friends.Ref.UIComp:SetVisible(false)
  local gmVM = Z.VMMgr.GetVM("gm")
  if gmVM then
    gmVM.OpenGmMainView()
  end
  Z.UIMgr:OpenView("mark_main")
  self.friendUrlRawImages_ = {}
  for i = 1, 4 do
    self.friendUrlRawImages_[i] = friendUrlRawImage.new(self, self.uiBinder.uibinder_friends, self.uiBinder.uibinder_friends["rimg_head_" .. i])
  end
end

function LoginView:OnRefresh()
  Z.AudioMgr:SetState(E.AudioState.Login, "Sys_Login")
  self:switchLoginState(E.LoginState.Init)
end

function LoginView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.LoginEvt.SwitchLoginState, self.switchLoginState, self)
  Z.EventMgr:Add(Z.ConstValue.LoginEvt.OnSDKAutoLogin, self.onSDKAutoLogin, self)
  Z.EventMgr:Add(Z.ConstValue.LoginEvt.OnSDKLogin, self.onSDKLogin, self)
  Z.EventMgr:Add(Z.ConstValue.LoginEvt.GMSwitchIdLogin, self.onGMSwitchIdLogin, self)
end

function LoginView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.LoginEvt.SwitchLoginState, self.switchLoginState, self)
  Z.EventMgr:Remove(Z.ConstValue.LoginEvt.OnSDKAutoLogin, self.onSDKAutoLogin, self)
  Z.EventMgr:Remove(Z.ConstValue.LoginEvt.OnSDKLogin, self.onSDKLogin, self)
  Z.EventMgr:Remove(Z.ConstValue.LoginEvt.GMSwitchIdLogin, self.onGMSwitchIdLogin, self)
end

function LoginView:OnDeActive()
  self:UnBindEvents()
  self:unInitEffectAndDepth()
  Z.AudioMgr:SetState(E.AudioState.Login, "Sys_Figure")
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  for i = 1, 4 do
    self.friendUrlRawImages_[i]:UnInit()
  end
  self.friendUrlRawImages_ = {}
end

function LoginView:onStartPlayAnim()
  self.uiBinder.comp_tween_main:Restart(Z.DOTweenAnimType.Open)
end

function LoginView:startAnimatedShow()
  self:onStartPlayAnim()
end

function LoginView:startAnimatedHide()
end

function LoginView:HasAfficheBtn()
  if self.currentPlatform_ == E.LoginPlatformType.InnerPlatform then
    return false
  elseif self.currentPlatform_ == E.LoginPlatformType.TencentPlatform then
    return true
  else
    local httpNoticeUrl = self.sdkVM_.GetHttpNoticeUrl()
    return httpNoticeUrl ~= ""
  end
end

function LoginView:HasUserSupportBtn()
  if Z.GameContext.IsPreviewEnvironment() then
    return false
  end
  return self.userSupportVM_.GetUserSupportUrl(E.UserSupportType.Login) ~= ""
end

function LoginView:HasUserCenterBtn()
  if Z.GameContext.IsPreviewEnvironment() then
    return false
  end
  return self.userCenterVM_.GetUserCenterUrl(E.UserSupportType.Login) ~= ""
end

function LoginView:login()
  self.waitLogin_ = true
  if self.serverAddr_ == nil or self.serverAddr_ == "" then
    logError("\232\175\183\232\190\147\229\133\165\230\156\141\229\138\161\229\153\168\229\156\176\229\157\128")
    self:switchLoginState(E.LoginState.GetServerList)
    return
  end
  if self.loginVm_:CheckServerStatus(self.serverAddr_) then
    Z.CoroUtil.create_coro_xpcall(function()
      self:switchLoginState(E.LoginState.WaitingConnect)
      self.loginVm_:AsyncAuth(self.serverAddr_, self.accountName_)
    end, function(err)
      logError(err)
    end)()
  else
    Z.EventMgr:Dispatch(Z.ConstValue.LoginEvt.SwitchLoginState, E.LoginState.GetServerList)
  end
end

function LoginView:initData()
  self.accountName_ = self.loginVm_:LoadLocalAccountInfo()
  self.serverData_.LoginNameToIp[Lang("CustomServer")] = ""
  self.serverAddr_ = self.loginVm_:LoadLastLoginAddr()
  self.isShowQRCodeNode_ = false
  self.loginTypeList_ = Z.SDKLogin.GetSupportLoginTypes()
  self.currentSDKType_ = Z.SDKLogin.GetSDKType()
  self.currentPlatform_ = Z.SDKLogin.GetPlatform()
  self.hasSDKLogin_ = self.loginTypeList_ ~= nil and self.loginTypeList_.Length > 0
  self.CurLoginTypeDic_ = {}
  if self.hasSDKLogin_ then
    for i = 0, self.loginTypeList_.Length - 1 do
      self.CurLoginTypeDic_[self.loginTypeList_[i]] = true
    end
  end
end

function LoginView:initComponents()
  self:AddClick(self.uiBinder.btn_start_face, function()
    self.faceVM_.OpenFaceCreateView()
  end)
  if Z.IsPreFaceMode then
    logError("[AppScheme]" .. Z.LuaBridge.GetAppScheme())
    self:setCloudGamePrefabFace()
    return
  end
  self:AddClick(self.uiBinder.btn_close_rating, function()
    self:SetUIVisible(self.uiBinder.trans_rating_tips, false)
  end)
  self:AddClick(self.uiBinder.btn_rating, function()
    self:SetUIVisible(self.uiBinder.trans_rating_tips, true)
  end)
  self.uiBinder.input_platform:AddEndEditListener(function(str)
    local accountData = Z.DataMgr.Get("account_data")
    accountData.PlatformType = tonumber(str)
  end, true)
  self.uiBinder.input_webview:AddSubmitListener(function()
    Z.SDKWebView.OpenWebView(self.uiBinder.input_webview.text, true)
  end)
  self.uiBinder.tog_debug_close_sdk:SetIsOnWithoutCallBack(self.currentPlatform_ == E.LoginPlatformType.InnerPlatform)
  self.uiBinder.tog_debug_close_sdk:AddListener(function(isOn)
    self:onGMSwitchIdLogin(isOn)
  end)
  self.uiBinder.tog_debug_hidden_select:SetIsOnWithoutCallBack(self.hideServerSelectOnDebug_)
  self.uiBinder.tog_debug_hidden_select:AddListener(function()
    self.hideServerSelectOnDebug_ = self.uiBinder.tog_debug_hidden_select.isOn
    self:showSelectServer(not self.hideServerSelectOnDebug_)
  end)
  self.uiBinder.input_accountname:AddListener(function(str)
    self.accountName_ = str
  end, true)
  self.uiBinder.input_accountname.text = self.accountName_
  self.uiBinder.img_logo:SetImage(logoImg)
  self:SetUIVisible(self.uiBinder.btn_start_face, false)
  self:SetUIVisible(self.uiBinder.btn_login_qq, self:isHaveLoginType(E.LoginType.QQ))
  self:SetUIVisible(self.uiBinder.btn_login_wechat, self:isHaveLoginType(E.LoginType.WeChat))
  self:SetUIVisible(self.uiBinder.btn_login_intl, self:isHaveLoginType(E.LoginType.LevelInfinite))
  self:SetUIVisible(self.uiBinder.btn_login_haoplay, self:isHaveLoginType(E.LoginType.HaoPlay))
  self:SetUIVisible(self.uiBinder.btn_login_iosreview, self:isHaveLoginType(E.LoginType.Apple))
  self:SetUIVisible(self.uiBinder.trans_login_id, self.currentPlatform_ == E.LoginPlatformType.InnerPlatform)
  self:SetUIVisible(self.uiBinder.trans_login_sdk_cn, self.currentPlatform_ == E.LoginPlatformType.TencentPlatform)
  self:SetUIVisible(self.uiBinder.trans_login_sdk_intl, self.currentPlatform_ == E.LoginPlatformType.IntlPlatform)
  self:SetUIVisible(self.uiBinder.trans_login_sdk_haoplay, self.currentPlatform_ == E.LoginPlatformType.HaoPlayPlatForm)
  self:SetUIVisible(self.uiBinder.tog_agreement, self.currentPlatform_ == E.LoginPlatformType.TencentPlatform)
  self:AddClick(self.uiBinder.btn_login, function()
    self.loginVm_:SDKLogin(E.LoginType.None, false, self.accountName_)
  end)
  self:AddClick(self.uiBinder.btn_login_qq, function()
    if self:checkAgreement() then
      self.loginVm_:SDKLogin(E.LoginType.QQ, false)
    else
      Z.TipsVM.ShowTips(100014)
      self.uiBinder.comp_effect_agreement:SetEffectGoVisible(true)
    end
  end)
  self:AddClick(self.uiBinder.btn_login_wechat, function()
    if self:checkAgreement() then
      self.loginVm_:SDKLogin(E.LoginType.WeChat, false)
    else
      Z.TipsVM.ShowTips(100014)
      self.uiBinder.comp_effect_agreement:SetEffectGoVisible(true)
    end
  end)
  self:AddClick(self.uiBinder.btn_login_iosreview, function()
    if self:checkAgreement() then
      self.loginVm_:SDKLogin(E.LoginType.Apple, false)
    else
      Z.TipsVM.ShowTips(100014)
      self.uiBinder.comp_effect_agreement:SetEffectGoVisible(true)
    end
  end)
  self:AddClick(self.uiBinder.btn_login_intl, function()
    self.loginVm_:SDKLogin(E.LoginType.LevelInfinite, false)
  end)
  self:AddClick(self.uiBinder.btn_login_haoplay, function()
    self.loginVm_:SDKLogin(E.LoginType.HaoPlay, false)
  end)
  self:AddClick(self.uiBinder.binder_btn_set.btn_qrcode, function()
    self.isShowQRCodeNode_ = not self.isShowQRCodeNode_
    self.uiBinder.binder_btn_set.Ref:SetVisible(self.uiBinder.binder_btn_set.node_qrcode, self.isShowQRCodeNode_)
  end)
  self:AddClick(self.uiBinder.binder_btn_set.btn_wechat_qrcode, function()
    if self:checkAgreement() then
      self.loginVm_:SDKLogin(E.LoginType.WeChat, true)
    else
      Z.TipsVM.ShowTips(100014)
      self.uiBinder.comp_effect_agreement:SetEffectGoVisible(true)
    end
  end)
  self:AddClick(self.uiBinder.binder_btn_set.btn_qq_qrcode, function()
    if self:checkAgreement() then
      self.loginVm_:SDKLogin(E.LoginType.QQ, true)
    else
      Z.TipsVM.ShowTips(100014)
      self.uiBinder.comp_effect_agreement:SetEffectGoVisible(true)
    end
  end)
  self:AddAsyncClick(self.uiBinder.binder_btn_set.btn_switch, function()
    self.loginVm_:Logout(true)
  end)
  self:AddAsyncClick(self.uiBinder.binder_btn_set.btn_billboard, function()
    local httpNoticeUrl = self.sdkVM_.GetHttpNoticeUrl()
    if httpNoticeUrl ~= "" then
      self.afficheVM_.OpenHttpAfficheView()
    else
      self.afficheVM_.OpenAfficheView()
    end
  end)
  self:AddClick(self.uiBinder.binder_btn_set.btn_service, function()
    self.userSupportVM_.OpenUserSupportWebView(E.UserSupportType.Login)
  end)
  self:AddClick(self.uiBinder.binder_btn_set.btn_user_center, function()
    self.userCenterVM_.OpenUserCenter(E.UserSupportType.Login)
  end)
  self:AddAsyncClick(self.uiBinder.binder_btn_set.btn_setting, function()
    local settingVm = Z.VMMgr.GetVM("setting")
    settingVm.OpenSettingView({
      E.SetFuncId.SettingBasic,
      E.SetFuncId.SettingFrame
    }, E.SetFuncId.SettingFrame)
  end)
  self:AddAsyncClick(self.uiBinder.binder_btn_set.btn_repair, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("IsRepairDialogContent"), function()
      Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Device, Z.ConstValue.PlayerPrefsKey.FixResourcesFlag, 1)
      Z.LocalUserDataMgr.Save()
      Z.GameContext.QuitGame()
    end)
  end)
  self:AddClick(self.uiBinder.binder_btn_set.btn_close, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("IsQuitGame"), function()
      Z.GameContext.QuitGame()
    end)
  end)
  self:AddAsyncClick(self.uiBinder.btn_enter_game, function()
    if Z.SDKDevices.RuntimeOS == E.OS.iOS then
      xpcall(function()
        local operatingSystem = UnityEngine.SystemInfo.operatingSystem
        if operatingSystem and operatingSystem ~= "" then
          local versionStrArray = string.split(operatingSystem, " ")
          local version
          if versionStrArray[#versionStrArray] ~= nil then
            local versionStr = versionStrArray[#versionStrArray]
            local versionsArray = string.split(versionStr, ".")
            if versionsArray[1] ~= nil then
              version = tonumber(versionsArray[1])
            end
          end
          if version and version < 15 then
            Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameNormal, E.ESysDialogGameNormalOrder.Normal, nil, Lang("InterceptIOSUnder15"), function()
              Z.GameContext.QuitGame()
            end)
            return
          end
        end
        self:login()
      end, function(err)
        logError("LoginView btn_enter_game error : " .. err)
        self:login()
      end)
    else
      self:login()
    end
  end)
  self.uiBinder.drop_down_select_ip:AddListener(function(index)
    if 0 <= index then
      local serverAddr = self.serverData_.LoginNameToIp[self.serverData_.LoginOptions[index + 1]]
      self.serverAddr_ = serverAddr
      self.uiBinder.input_serveraddr.text = serverAddr
    end
  end, true)
  self.uiBinder.input_serveraddr:AddEndEditListener(function(str)
    self.serverAddr_ = str
    local index = self.loginVm_:InputMatchingOptions(self.serverAddr_, self.serverData_.LoginNameToIp, self.serverData_.LoginOptions)
    if index then
      self:setServerDropdownValue(index)
    else
      self.serverData_.LoginNameToIp[Lang("CustomServer")] = self.serverAddr_
      self:setServerDropdownValue(#self.serverData_.LoginOptions)
    end
  end, true)
  self:AddClick(self.uiBinder.uibinder_friends.btn_morefriends, function()
    Z.UIMgr:OpenView("friends_play_friends_popup", {isLogin = true})
  end)
  self.uiBinder.tog_agreement.isOn = false
  self.uiBinder.tog_agreement:AddListener(function(isOn)
    if isOn then
      self.uiBinder.comp_effect_agreement:SetEffectGoVisible(false)
    end
  end)
  self.uiBinder.lab_agreement:AddListener(function(link)
    Z.SDKWebView.OpenURL(link, false)
  end)
  self:initEffectAndDepth()
  self:initAnim()
end

function LoginView:initEffectAndDepth()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.comp_effect_1)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.comp_effect_2)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.comp_effect_enter_game)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.comp_effect_agreement)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.comp_effect_login_id)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.comp_effect_login_intl)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.comp_effect_login_haoplay)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.comp_depth_rating)
  self.uiBinder.comp_effect_1:SetEffectGoVisible(true)
  self.uiBinder.comp_effect_2:SetEffectGoVisible(true)
  self.uiBinder.comp_effect_agreement:SetEffectGoVisible(false)
end

function LoginView:unInitEffectAndDepth()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.comp_effect_1)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.comp_effect_2)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.comp_effect_enter_game)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.comp_effect_login_id)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.comp_effect_agreement)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.comp_effect_login_intl)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.comp_effect_login_haoplay)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.comp_depth_rating)
end

function LoginView:initAnim()
  self:setAnimCompState(false)
  self.commonVM_.CommonPlayAnim(self.uiBinder.comp_anim_main, "anim_login_main_open", self.cancelSource:CreateToken(), function()
    self:setAnimCompState(true)
    self:startAnimatedShow()
  end)
end

function LoginView:setAnimCompState(activeState)
  self.uiBinder.trans_btn_set.gameObject:SetActive(activeState)
  self.uiBinder.trans_login_ip.gameObject:SetActive(activeState)
  self.uiBinder.trans_enter_game.gameObject:SetActive(activeState)
  self.uiBinder.trans_login_btn.gameObject:SetActive(activeState)
  self.uiBinder.trans_content_rating.gameObject:SetActive(activeState)
  self.uiBinder.img_logo.gameObject:SetActive(activeState)
end

function LoginView:isHaveLoginType(loginType)
  return self.CurLoginTypeDic_ and self.CurLoginTypeDic_[loginType] ~= nil
end

function LoginView:checkAgreement()
  return self.uiBinder.tog_agreement.isOn
end

function LoginView:setServerDropdownValue(optionIdx)
  if self.uiBinder.drop_down_select_ip.value == optionIdx - 1 then
    local key = self.serverData_.LoginOptions[optionIdx]
    if key and self.serverData_.LoginNameToIp[key] then
      self.serverAddr_ = self.serverData_.LoginNameToIp[key]
      self.uiBinder.input_serveraddr:SetTextWithoutNotify(self.serverAddr_)
    else
      logError("\230\156\141\229\138\161\229\153\168\229\136\151\232\161\168\230\178\161\230\156\137\230\149\176\230\141\174, optionIdx=" .. tostring(optionIdx))
    end
  else
    self.uiBinder.drop_down_select_ip.value = optionIdx - 1
  end
end

function LoginView:showDebugBtn(value)
  self:SetUIVisible(self.uiBinder.trans_debug, value)
  self:SetUIVisible(self.uiBinder.trans_debug_platform, false)
end

function LoginView:showBtnSet(value)
  local binderSet = self.uiBinder.binder_btn_set
  binderSet.Ref:SetVisible(binderSet.btn_close, Z.IsPCUI)
  binderSet.Ref:SetVisible(binderSet.btn_switch, value and self.currentSDKType_ ~= E.LoginSDKType.WeGame)
  binderSet.Ref:SetVisible(binderSet.btn_billboard, self:HasAfficheBtn())
  binderSet.Ref:SetVisible(binderSet.btn_repair, value and Z.GameContext.IsPC == false)
  binderSet.Ref:SetVisible(binderSet.btn_service, self:HasUserSupportBtn())
  binderSet.Ref:SetVisible(binderSet.btn_user_center, self:HasUserCenterBtn())
  binderSet.Ref:SetVisible(binderSet.btn_qrcode, false)
  binderSet.Ref:SetVisible(binderSet.node_qrcode, false)
  binderSet.Ref:SetVisible(binderSet.btn_animation, false)
  binderSet.Ref:SetVisible(binderSet.btn_setting, true)
  local serviceIcon = self.userSupportVM_.GetUserSupportIcon(E.UserSupportType.Login)
  if serviceIcon and serviceIcon ~= "" then
    binderSet.img_service:SetImage(serviceIcon)
  end
end

function LoginView:showEnterGame(value)
  self:SetUIVisible(self.uiBinder.trans_enter_game, value)
  if value then
    self.uiBinder.comp_tween_main:Restart(Z.DOTweenAnimType.Tween_0)
  end
  self.uiBinder.comp_effect_enter_game:SetEffectGoVisible(value)
end

function LoginView:showQueueUp(value)
  self:SetUIVisible(self.uiBinder.trans_queue_up, value)
end

function LoginView:showTips(value)
  self:SetUIVisible(self.uiBinder.trans_tips, value)
end

function LoginView:showSelectServer(value)
  self:SetUIVisible(self.uiBinder.trans_login_ip, value)
end

function LoginView:showLoginAccount(value)
  self:SetUIVisible(self.uiBinder.trans_login_btn, value)
  if value then
    self:onStartPlayAnim()
  end
end

function LoginView:showAgreementDialog()
  if not SDKHelper.IsShowTipsView(self.currentPlatform_) then
    self:autoShowAffichePopup()
    return
  end
  local viewData = {
    PlatformType = self.currentPlatform_,
    CloseCallback = function()
      self:autoShowAffichePopup()
    end
  }
  Z.UIMgr:OpenView("login_agreement_popup", viewData)
end

function LoginView:autoShowAffichePopup()
  if self.currentSDKType_ == E.LoginSDKType.GLauncher then
    return
  end
  self.afficheVM_.CheckAfficheAutoShow()
end

function LoginView:showContentRating(value)
  self:SetUIVisible(self.uiBinder.trans_content_rating, value)
  self:SetUIVisible(self.uiBinder.trans_rating_tips, false)
end

function LoginView:setTipsContent(content)
  if content == nil then
    self.uiBinder.lab_tips.text = ""
  else
    self.uiBinder.lab_tips.text = content
  end
end

function LoginView:setVersion()
  self.uiBinder.lab_version.text = string.format("%s_C%s_R%s", Z.GameContext.Version, Z.GameContext.CurrentClientBuildNumber, Z.GameContext.CurrentResourcesBuildNumber)
end

function LoginView:setDefaultServerAddr()
  self.serverAddr_ = self.loginVm_:LoadLastLoginAddr()
  if self.serverAddr_ == nil or self.serverAddr_ == "" then
    local defaultIndex = 1
    self:setServerDropdownValue(defaultIndex)
  else
    local index = self.loginVm_:InputMatchingOptions(self.serverAddr_, self.serverData_.LoginNameToIp, self.serverData_.LoginOptions)
    if index then
      self:setServerDropdownValue(index)
    else
      self.serverData_.LoginNameToIp[Lang("CustomServer")] = self.serverAddr_
      self:setServerDropdownValue(#self.serverData_.LoginOptions)
    end
  end
end

function LoginView:onSDKAutoLogin(data)
  if data == nil then
    Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameImportant, E.ESysDialogGameImportantOrder.Normal, nil, Lang("LoginError"))
    return
  end
  if data.ErrorCode == 0 then
    self:switchLoginState(E.LoginState.GetServerList)
    self:autoShowAffichePopup()
  elseif self.currentSDKType_ == E.LoginSDKType.WeGame then
    local param = {
      errorCode = data.ErrorCode
    }
    Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameImportant, E.ESysDialogGameImportantOrder.Important, nil, Lang("LauncherError", param), function()
      Z.GameContext.QuitGame()
    end)
  else
    self:switchLoginState(E.LoginState.LoginAccount)
    self.uiBinder.tog_agreement.isOn = false
  end
end

function LoginView:onSDKLogin(data)
  if data == nil then
    Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameImportant, E.ESysDialogGameImportantOrder.Important, nil, Lang("LoginError"))
    return
  end
  if data.ErrorCode == 0 then
    self:switchLoginState(E.LoginState.GetServerList)
    self:autoShowAffichePopup()
  else
    local param = {
      errorCode = data.ErrorCode
    }
    if self.currentSDKType_ == E.LoginSDKType.WeGame then
      Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameImportant, E.ESysDialogGameImportantOrder.Important, nil, Lang("LauncherError", param), function()
        Z.GameContext.QuitGame()
      end)
    else
      Z.TipsVM.ShowTipsLang(100008, param)
      self.loginVm_:Logout(true)
    end
  end
end

function LoginView:showDialogOK(desc)
  Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameImportant, E.ESysDialogGameImportantOrder.Important, nil, desc, function()
    self.loginVm_:Logout()
  end)
end

function LoginView:onGMSwitchIdLogin(isOn)
  if type(isOn) ~= "boolean" then
    if type(isOn) == "number" then
      isOn = isOn == 1
    else
      return
    end
  end
  self:switchLoginState(E.LoginState.LoginAccount)
  if isOn then
    self.currentPlatform_ = E.LoginPlatformType.InnerPlatform
    self.currentSDKType_ = E.LoginSDKType.None
    self.hasSDKLogin_ = false
  else
    self.currentPlatform_ = Z.SDKLogin.GetPlatform()
    self.currentSDKType_ = Z.SDKLogin.GetSDKType()
    self.hasSDKLogin_ = self.loginTypeList_ ~= nil and self.loginTypeList_.Length > 0
  end
  self:SetUIVisible(self.uiBinder.trans_login_id, isOn)
  self:SetUIVisible(self.uiBinder.trans_login_sdk_cn, not isOn and self.currentPlatform_ == E.LoginPlatformType.TencentPlatform)
  self:SetUIVisible(self.uiBinder.trans_login_sdk_intl, not isOn and self.currentPlatform_ == E.LoginPlatformType.IntlPlatform)
  self:SetUIVisible(self.uiBinder.tog_agreement, not isOn and self.currentPlatform_ == E.LoginPlatformType.TencentPlatform)
  self:showContentRating(not isOn and self.currentPlatform_ == E.LoginPlatformType.TencentPlatform)
end

function LoginView:switchLoginState(state)
  if state == nil or Z.IsPreFaceMode then
    return
  end
  if self.loginState_ ~= nil then
    local funcName = "on" .. self.loginState_ .. "StateExit"
    local exitFunc = self[funcName]
    if exitFunc then
      exitFunc(self)
    end
  end
  self.loginState_ = state
  local funcName = "on" .. self.loginState_ .. "StateEnter"
  local enterFunc = self[funcName]
  if enterFunc then
    enterFunc(self)
  end
end

function LoginView:onInitStateEnter()
  self.waitLogin_ = false
  self:showLoginAccount(false)
  self:showDebugBtn(Z.GameContext.IsDevelopment)
  self:showBtnSet(false)
  self:showEnterGame(false)
  self:showTips(false)
  self:showSelectServer(false)
  self:showContentRating(self.currentPlatform_ == E.LoginPlatformType.TencentPlatform)
  self.uiBinder.uibinder_friends.Ref.UIComp:SetVisible(false)
  if Z.ScreenMark then
    local deviceId = Z.SDKReport.GetReportInfo("DeviceID")
    if deviceId == nil or deviceId == "" or deviceId == "0" then
      if not Z.GameContext.IsEditor then
        logError("DeviceId is Invalid")
      end
    else
      Z.UIMgr:OpenView("mark_main", {key = deviceId})
    end
  end
  self:switchLoginState(E.LoginState.AutoLoginAccount)
end

function LoginView:onInitStateExit()
end

function LoginView:onAutoLoginAccountStateEnter()
  self.uiBinder.uibinder_friends.Ref.UIComp:SetVisible(false)
  self.loginVm_:SDKAutoLogin()
end

function LoginView:onAutoLoginAccountStateExit()
end

function LoginView:onLoginAccountStateEnter()
  self:showLoginAccount(true)
  self.isShowQRCodeNode_ = false
  self.uiBinder.binder_btn_set.Ref:SetVisible(self.uiBinder.binder_btn_set.btn_qrcode, self.currentSDKType_ == E.LoginSDKType.MSDK)
  self.uiBinder.binder_btn_set.Ref:SetVisible(self.uiBinder.binder_btn_set.node_qrcode, false)
  self.uiBinder.uibinder_friends.Ref.UIComp:SetVisible(false)
  if self.loginData_.AutoLogin then
    self.loginVm_:SDKLogin(self.loginData_.LastAccountData.LoginType, self.loginData_.LastAccountData.OpenID)
  end
end

function LoginView:onLoginAccountStateExit()
  self:showLoginAccount(false)
  self.isShowQRCodeNode_ = false
  self.uiBinder.binder_btn_set.Ref:SetVisible(self.uiBinder.binder_btn_set.btn_qrcode, false)
  self.uiBinder.binder_btn_set.Ref:SetVisible(self.uiBinder.binder_btn_set.node_qrcode, false)
end

function LoginView:onGetServerListStateEnter()
  self.waitLogin_ = false
  self:showTips(false)
  self.uiBinder.uibinder_friends.Ref.UIComp:SetVisible(false)
  Z.CoroUtil.create_coro_xpcall(function()
    local result = self.loginVm_:AsyncGetServerList()
    if result == true then
      self:switchLoginState(E.LoginState.EnterGame)
    else
      self:showDialogOK(Lang("GetServerListError"))
    end
  end, function(err)
    logError(err)
    self:showDialogOK(Lang("GetServerListError"))
  end)()
end

function LoginView:onGetServerListStateExit()
end

function LoginView:onEnterGameStateEnter()
  self:showEnterGame(true)
  self:showBtnSet(true)
  self.uiBinder.uibinder_friends.Ref.UIComp:SetVisible(false)
  self.uiBinder.drop_down_select_ip:ClearOptions()
  self.uiBinder.drop_down_select_ip:AddOptions(self.serverData_.LoginOptions)
  self:setDefaultServerAddr()
  local serverCount = #self.serverData_.ServerList
  self:showSelectServer(1 < serverCount)
  Z.DataMgr.Get("sdk_data").SDKFriends = {}
  if self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentFriends) and not Z.GameContext.IsPreviewEnvironment() then
    self.sdkVM_.HttpGetTencentFriends(self.cancelSource:CreateToken(), function()
      local data = Z.DataMgr.Get("sdk_data").SDKFriends
      for i = 1, 4 do
        local rimgHead = self.uiBinder.uibinder_friends["rimg_head_" .. i]
        if i <= #data then
          self.friendUrlRawImages_[i]:Init(self.sdkVM_.GetFriendPicURLSuffix(data[i].pictureUrl))
          self.uiBinder.uibinder_friends.Ref.UIComp:SetVisible(true)
        else
          self.uiBinder.uibinder_friends.Ref:SetVisible(rimgHead, false)
        end
      end
    end)
  end
  if Z.GameContext.IsDevelopment then
    self:showSelectServer(not self.hideServerSelectOnDebug_)
    local accountData = Z.DataMgr.Get("account_data")
    self.uiBinder.input_platform.text = tostring(accountData.PlatformType)
    self:SetUIVisible(self.uiBinder.trans_debug_platform, true)
  end
  if self.loginData_.AutoLogin then
    self.loginData_.AutoLogin = false
    self:login()
  end
end

function LoginView:onEnterGameStateExit()
  self:showEnterGame(false)
  self:showBtnSet(false)
  self:showSelectServer(false)
end

function LoginView:onWaitingConnectStateEnter()
  self:setTipsContent(Lang("ConnectionTips"))
  self:showTips(true)
  self.uiBinder.uibinder_friends.Ref.UIComp:SetVisible(false)
end

function LoginView:onWaitingConnectStateExit()
end

function LoginView:setCloudGamePrefabFace()
  self:SetUIVisible(self.uiBinder.btn_start_face, true)
  self:SetUIVisible(self.uiBinder.btn_login, false)
  self:SetUIVisible(self.uiBinder.btn_login_qq, false)
  self:SetUIVisible(self.uiBinder.btn_login_wechat, false)
  self:SetUIVisible(self.uiBinder.btn_login_intl, false)
  self:SetUIVisible(self.uiBinder.btn_login_haoplay, false)
  self:SetUIVisible(self.uiBinder.btn_login_iosreview, false)
  self:SetUIVisible(self.uiBinder.trans_login_id, false)
  self:SetUIVisible(self.uiBinder.trans_login_sdk_cn, false)
  self:SetUIVisible(self.uiBinder.trans_login_sdk_intl, false)
  self:SetUIVisible(self.uiBinder.trans_login_sdk_haoplay, false)
  self:SetUIVisible(self.uiBinder.trans_btn_set, false)
  self:SetUIVisible(self.uiBinder.trans_enter_game, false)
  self:SetUIVisible(self.uiBinder.trans_login_btn, false)
  self:SetUIVisible(self.uiBinder.trans_login_ip, false)
  self:showDebugBtn(false)
end

return LoginView
