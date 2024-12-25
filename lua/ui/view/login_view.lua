local UI = Z.UI
local super = require("ui.ui_view_base")
local LoginView = class("LoginView", super)
local SDKHelper = require("common.sdk_helper")

function LoginView:ctor()
  self.panel = nil
  super.ctor(self, "login")
  self.loginVm_ = Z.VMMgr.GetVM("login")
  self.afficheVM_ = Z.VMMgr.GetVM("affiche")
  self.serverData_ = Z.DataMgr.Get("server_data")
  self.loginState_ = E.LoginState.Init
  self.waitLogin_ = false
  self.hideServerSelectOnDebug_ = false
end

function LoginView:OnActive()
  local cancelSourceToken = self.cancelSource:CreateToken()
  self:BindEvents()
  self:setVersion()
  self:initDatas()
  self:initComponents()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.AudioMgr:SetState(E.AudioState.Login, "Sys_Login")
  self.panel.Ref.ZUIDepth:AddChildDepth(self.panel.eff1.ZEff)
  self.panel.Ref.ZUIDepth:AddChildDepth(self.panel.eff2.ZEff)
  self.panel.Ref.ZUIDepth:AddChildDepth(self.panel.cont_login_sdk_cn.eff_root.ZEff)
  self.panel.Ref.ZUIDepth:AddChildDepth(self.panel.cont_enter_game.eff_root.ZEff)
  self.panel.Ref.ZUIDepth:AddChildDepth(self.panel.cont_login_id.eff_root.ZEff)
  self.panel.eff1.ZEff:SetEffectGoVisible(true)
  self.panel.eff2.ZEff:SetEffectGoVisible(true)
  local gmVM = Z.VMMgr.GetVM("gm")
  if gmVM then
    gmVM.OpenGmMainView()
  end
  self.panel.Ref.ZUIDepth:AddChildDepth(self.panel.cont_content_rating.Ref.ZUIDepth)
  self.panel.cont_btn_set.Go:SetActive(false)
  self.panel.cont_login_ip.Go:SetActive(false)
  self.panel.cont_enter_game.Go:SetActive(false)
  self.panel.node_login_btn.Go:SetActive(false)
  self.panel.cont_content_rating.Go:SetActive(false)
  self.panel.img_logo.Go:SetActive(false)
  self.panel.anim.anim:CoroPlayOnce("anim_login_main_open", cancelSourceToken, function()
    self.panel.cont_btn_set.Go:SetActive(true)
    self.panel.cont_login_ip.Go:SetActive(true)
    self.panel.cont_enter_game.Go:SetActive(true)
    self.panel.node_login_btn.Go:SetActive(true)
    self.panel.cont_content_rating.Go:SetActive(true)
    self.panel.img_logo.Go:SetActive(true)
    self:startAnimatedShow()
  end, function(err)
    if err == ZUtil.ZCancelSource.CancelException then
      return
    end
    logError(err)
  end)
end

function LoginView:OnRefresh()
  Z.AudioMgr:SetState(E.AudioState.Login, "Sys_Login")
  self:switchLoginState(E.LoginState.Init)
end

function LoginView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.LoginEvt.SwitchLoginState, self.switchLoginState, self)
  Z.EventMgr:Add(Z.ConstValue.LoginEvt.OnSDKAutoLogin, self.onSDKAutoLogin, self)
  Z.EventMgr:Add(Z.ConstValue.LoginEvt.OnSDKLogin, self.onSDKLogin, self)
  Z.EventMgr:Add(Z.ConstValue.LoginEvt.OnAgreement, self.setEffVisible, self)
  Z.EventMgr:Add(Z.ConstValue.LoginEvt.GMSwitchIdLogin, self.onGMSwichIdLogin, self)
end

function LoginView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.LoginEvt.SwitchLoginState, self.switchLoginState, self)
  Z.EventMgr:Remove(Z.ConstValue.LoginEvt.OnSDKAutoLogin, self.onSDKAutoLogin, self)
  Z.EventMgr:Remove(Z.ConstValue.LoginEvt.OnSDKLogin, self.onSDKLogin, self)
  Z.EventMgr:Remove(Z.ConstValue.LoginEvt.OnAgreement, self.setEffVisible, self)
  Z.EventMgr:Remove(Z.ConstValue.LoginEvt.GMSwitchIdLogin, self.onGMSwichIdLogin, self)
end

function LoginView:OnDeActive()
  self:UnBindEvents()
  self.panel.Ref.ZUIDepth:RemoveChildDepth(self.panel.cont_content_rating.Ref.ZUIDepth)
  Z.AudioMgr:SetState(E.AudioState.Login, "Sys_Figure")
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function LoginView:onStartPlayAnim()
  self.panel.anim.TweenContainer:Restart(Z.DOTweenAnimType.Open)
end

function LoginView:startAnimatedShow()
  self:onStartPlayAnim()
end

function LoginView:startAnimatedHide()
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

function LoginView:initDatas()
  self.accountName_ = self.loginVm_:LoadLocalAccountInfo()
  self.serverData_.LoginNameToIp[Lang("CustomServer")] = ""
  self.serverAddr_ = self.loginVm_:LoadLastLoginAddr()
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
  self:AddClick(self.panel.cont_content_rating.btn_close.Btn, function()
    self.panel.cont_content_rating.group_rating_tips:SetVisible(false)
  end)
  self:AddClick(self.panel.cont_content_rating.btn_rating.Btn, function()
    self.panel.cont_content_rating.group_rating_tips:SetVisible(true)
  end)
  self.panel.cont_debug.input_platform.TMPInput:AddEndEditListener(function(str)
    local accountData = Z.DataMgr.Get("account_data")
    accountData.PlatformType = tonumber(str)
  end, true)
  self.panel.cont_debug.input_webview.TMPInput:AddSubmitListener(function()
    Z.SDKWebView.OpenWebView(self.panel.cont_debug.input_webview.TMPInput.text, true)
  end)
  self.panel.cont_debug.tog_close_sdk.Tog.isOn = self.currentPlatform_ == E.LoginPlatformType.InnerPlatform
  self.panel.cont_debug.tog_close_sdk.Tog:AddListener(function(isOn)
    self:onGMSwichIdLogin(isOn)
  end)
  self.panel.cont_debug.tog_hidden_select.Tog.isOn = self.hideServerSelectOnDebug_
  self.panel.cont_debug.tog_hidden_select.Tog:AddListener(function()
    self.hideServerSelectOnDebug_ = self.panel.cont_debug.tog_hidden_select.Tog.isOn
    self:showSelectServer(not self.hideServerSelectOnDebug_)
  end)
  self.panel.cont_debug.tog_edit.Tog.isOn = Z.GameContext.IsInRuntimeEditor
  self.panel.cont_debug.tog_edit.Tog:AddListener(function()
    Z.GameContext.IsInRuntimeEditor = self.panel.cont_debug.tog_edit.Tog.isOn
    if Z.GameContext.IsInRuntimeEditor then
      self.panel.cont_login_ip.input_serveraddr.TMPInput.text = "127.0.0.1:9999"
    end
  end)
  self.panel.cont_login_id.input_accountname.TMPInput.text = self.accountName_
  self.panel.cont_login_id.input_accountname.TMPInput:AddListener(function(str)
    self.accountName_ = str
  end, true)
  self.panel.cont_login_sdk_cn.btn_login_qq:SetVisible(self:isHaveLoginType(E.LoginType.QQ))
  self.panel.cont_login_sdk_cn.btn_login_wechat:SetVisible(self:isHaveLoginType(E.LoginType.WeChat))
  self.panel.cont_login_sdk_intl.btn_login_intl:SetVisible(self:isHaveLoginType(E.LoginType.LevelInfinite))
  self.panel.cont_login_sdk_haoplay.btn_login_haoplay:SetVisible(self:isHaveLoginType(E.LoginType.HaoPlay))
  self.panel.cont_login_id:SetVisible(self.currentPlatform_ == E.LoginPlatformType.InnerPlatform)
  self.panel.cont_login_sdk_cn:SetVisible(self.currentPlatform_ == E.LoginPlatformType.TencentPlatform)
  self.panel.cont_login_sdk_intl:SetVisible(self.currentPlatform_ == E.LoginPlatformType.IntlPlatform)
  self.panel.cont_login_sdk_haoplay:SetVisible(self.currentPlatform_ == E.LoginPlatformType.HaoPlayPlatForm)
  self:AddClick(self.panel.cont_login_id.btn_login.Btn, function()
    self.loginVm_:SDKLogin(E.LoginType.None, self.accountName_)
  end)
  self:AddClick(self.panel.cont_login_sdk_cn.btn_login_qq.Btn, function()
    self.loginVm_:SDKLogin(E.LoginType.QQ)
  end)
  self:AddClick(self.panel.cont_login_sdk_cn.btn_login_wechat.Btn, function()
    self.loginVm_:SDKLogin(E.LoginType.WeChat)
  end)
  self:AddClick(self.panel.cont_login_sdk_intl.btn_login_intl.Btn, function()
    self.loginVm_:SDKLogin(E.LoginType.LevelInfinite)
  end)
  self:AddClick(self.panel.cont_login_sdk_haoplay.btn_login_haoplay.Btn, function()
    self.loginVm_:SDKLogin(E.LoginType.HaoPlay)
  end)
  self:AddAsyncClick(self.panel.cont_btn_set.btn_switch.Btn, function()
    self.loginVm_:Logout(true)
  end)
  self:AddAsyncClick(self.panel.cont_btn_set.btn_billboard.Btn, function()
    self.afficheVM_.OpenAfficheView()
  end)
  self:AddAsyncClick(self.panel.cont_btn_set.btn_setting.Btn, function()
    Z.VMMgr.GetVM("setting").OpenSettingView()
  end)
  self:AddAsyncClick(self.panel.cont_btn_set.btn_repair.Btn, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("IsRepairDialogContent"), function()
      Z.LocalUserDataMgr.SetInt(Z.ConstValue.PlayerPrefsKey.FixResourcesFlag, 1, 0, true)
      Z.GameContext.QuitGame()
    end)
  end)
  self:AddAsyncClick(self.panel.cont_enter_game.btn_rayimg.Btn, function()
    if Z.GameContext.EnableHotUpdate then
      self:switchLoginState(E.LoginState.CheckVersion)
      Z.SDKHotUpdate.CheckUpdate(function(isSuccess, needUpdate, version, size, isForce, isUpgradeViaAppStore)
        if self.waitLogin_ then
          return
        end
        if isSuccess == false then
          Z.DialogViewDataMgr:OpenOKDialog(Lang("CheckVersionFailedTips"), function()
            self:switchLoginState(E.LoginState.GetServerList)
            Z.DialogViewDataMgr:CloseDialogView()
          end, E.EDialogViewDataType.System)
          return
        end
        if needUpdate == false then
          local accountData = Z.DataMgr.Get("account_data")
          local curTime = Z.TimeTools.Now() / 1000
          if accountData.Expire and accountData.Expire ~= 0 and curTime > accountData.Expire then
            self:showDialogOK(Lang("EnterGameExpired"))
            return
          end
          self:login()
        elseif version == nil or version == "" then
          if isForce then
            Z.DialogViewDataMgr:OpenOKDialog(Lang("NewVersionForceTips2"), function()
              Z.GameContext.QuitGame()
            end, E.EDialogViewDataType.System)
          else
            Z.DialogViewDataMgr:OpenNormalDialog(Lang("NewVersionTips2"), function()
              Z.GameContext.QuitGame()
            end, function()
              self:login()
              Z.DialogViewDataMgr:CloseDialogView()
            end)
          end
        else
          local param = {ver = version}
          if isForce then
            Z.DialogViewDataMgr:OpenOKDialog(Lang("NewVersionForceTips", param), function()
              Z.GameContext.QuitGame()
            end, E.EDialogViewDataType.System)
          else
            Z.DialogViewDataMgr:OpenNormalDialog(Lang("NewVersionTips", param), function()
              Z.GameContext.QuitGame()
            end, function()
              self:login()
              Z.DialogViewDataMgr:CloseDialogView()
            end)
          end
        end
      end)
    else
      self:login()
    end
  end)
  self:AddClick(self.panel.cont_btn_set.btn_close.Btn, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("IsQuitGame"), function()
      Z.GameContext.QuitGame()
    end)
  end)
  self.panel.cont_login_ip.dpd_select_ip.TMPDropdown:AddListener(function(index)
    if 0 <= index then
      local serverAddr = self.serverData_.LoginNameToIp[self.serverData_.LoginOptions[index + 1]]
      self.serverAddr_ = serverAddr
      self.panel.cont_login_ip.input_serveraddr.TMPInput.text = serverAddr
    end
  end, true)
  self.panel.cont_login_ip.input_serveraddr.TMPInput:AddEndEditListener(function(str)
    self.serverAddr_ = str
    local index = self.loginVm_:InputMatchingOptions(self.serverAddr_, self.serverData_.LoginNameToIp, self.serverData_.LoginOptions)
    if index then
      self:setServerDropdownValue(index)
    else
      self.serverData_.LoginNameToIp[Lang("CustomServer")] = self.serverAddr_
      self:setServerDropdownValue(#self.serverData_.LoginOptions)
    end
  end, true)
  self.panel.cont_login_sdk_cn.eff_root.ZEff:SetEffectGoVisible(false)
end

function LoginView:setEffVisible()
  self.panel.cont_login_sdk_cn.eff_root.ZEff:SetEffectGoVisible(true)
end

function LoginView:isHaveLoginType(loginType)
  return self.CurLoginTypeDic_ and self.CurLoginTypeDic_[loginType] ~= nil
end

function LoginView:setServerDropdownValue(optionIdx)
  if self.panel.cont_login_ip.dpd_select_ip.TMPDropdown.value == optionIdx - 1 then
    local key = self.serverData_.LoginOptions[optionIdx]
    if key and self.serverData_.LoginNameToIp[key] then
      self.serverAddr_ = self.serverData_.LoginNameToIp[key]
      self.panel.cont_login_ip.input_serveraddr.TMPInput:SetTextWithoutNotify(self.serverAddr_)
    else
      logError("\230\156\141\229\138\161\229\153\168\229\136\151\232\161\168\230\178\161\230\156\137\230\149\176\230\141\174, optionIdx=" .. tostring(optionIdx))
    end
  else
    self.panel.cont_login_ip.dpd_select_ip.TMPDropdown.value = optionIdx - 1
  end
end

function LoginView:showDebugBtn(value)
  self.panel.cont_debug:SetVisible(value)
  self.panel.cont_debug.node_platform:SetVisible(false)
end

function LoginView:showBtnSet(value)
  self.panel.cont_btn_set.btn_close:SetVisible(Z.IsPCUI)
  self.panel.cont_btn_set.btn_switch:SetVisible(value and (Z.GameContext.IsPC == false or Z.GameContext.IsEditor == true or self.currentSDKType_ == E.LoginSDKType.None))
  self.panel.cont_btn_set.btn_billboard:SetVisible(self.currentSDKType_ ~= E.LoginSDKType.GLauncher)
  self.panel.cont_btn_set.btn_repair:SetVisible(value and Z.GameContext.IsPC == false)
  self.panel.cont_btn_set.btn_wechat:SetVisible(false)
  self.panel.cont_btn_set.btn_animation:SetVisible(false)
  self.panel.cont_btn_set.btn_service:SetVisible(false)
  self.panel.cont_btn_set.btn_setting:SetVisible(false)
end

function LoginView:showEnterGame(value)
  self.panel.cont_enter_game:SetVisible(value)
  if value then
    self.panel.anim.TweenContainer:Restart(Z.DOTweenAnimType.Tween_0)
  end
  self.panel.cont_enter_game.eff_root.ZEff:SetEffectGoVisible(value)
end

function LoginView:showQueueUp(value)
  self.panel.cont_queue_up:SetVisible(value)
end

function LoginView:showTips(value)
  self.panel.cont_tips:SetVisible(value)
end

function LoginView:showSelectServer(value)
  self.panel.cont_login_ip:SetVisible(value)
end

function LoginView:showLoginAccount(value)
  self.panel.node_login_btn:SetVisible(value)
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
  self.panel.cont_content_rating:SetVisible(value)
  self.panel.cont_content_rating.group_rating_tips:SetVisible(false)
end

function LoginView:setTipsContent(content)
  if content == nil then
    self.panel.cont_tips.lab_tips.TMPLab.text = ""
  else
    self.panel.cont_tips.lab_tips.TMPLab.text = content
  end
end

function LoginView:setVersion()
  local param = {
    Version = Z.GameContext.Version,
    ResVersion = Z.GameContext.ResVersion
  }
  local str = Lang("version", param)
  self.panel.lab_version.TMPLab.text = str
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
    Z.DialogViewDataMgr:OpenOKDialog(Lang("LoginError"), nil, E.EDialogViewDataType.System)
    return
  end
  if data.ErrorCode == 0 then
    self:switchLoginState(E.LoginState.GetServerList)
    self:autoShowAffichePopup()
  elseif self.currentSDKType_ == E.LoginSDKType.WeGame or self.currentSDKType_ == E.LoginSDKType.GLauncher then
    local param = {
      errorCode = data.ErrorCode
    }
    Z.DialogViewDataMgr:OpenOKDialog(Lang("LauncherError", param), function()
      Z.GameContext.QuitGame()
    end, E.EDialogViewDataType.System)
  else
    self:switchLoginState(E.LoginState.LoginAccount)
    self:showAgreementDialog()
  end
end

function LoginView:onSDKLogin(data)
  if data == nil then
    Z.DialogViewDataMgr:OpenOKDialog(Lang("LoginError"), nil, E.EDialogViewDataType.System)
    return
  end
  if data.ErrorCode == 0 then
    self:switchLoginState(E.LoginState.GetServerList)
  else
    local param = {
      errorCode = data.ErrorCode
    }
    if self.currentSDKType_ == E.LoginSDKType.WeGame or self.currentSDKType_ == E.LoginSDKType.GLauncher then
      Z.DialogViewDataMgr:OpenOKDialog(Lang("LauncherError", param), function()
        Z.GameContext.QuitGame()
      end, E.EDialogViewDataType.System)
    else
      Z.TipsVM.ShowTipsLang(100008, param)
      self.loginVm_:Logout(true)
    end
  end
end

function LoginView:showDialogOK(desc)
  Z.DialogViewDataMgr:OpenOKDialog(desc, function()
    Z.DialogViewDataMgr:CloseDialogView()
    self.loginVm_:Logout()
  end, E.EDialogViewDataType.System, true)
end

function LoginView:onGMSwichIdLogin(isOn)
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
  self.panel.cont_login_id:SetVisible(isOn)
  self.panel.cont_login_sdk_cn:SetVisible(not isOn and self.currentPlatform_ == E.LoginPlatformType.TencentPlatform)
  self.panel.cont_login_sdk_intl:SetVisible(not isOn and self.currentPlatform_ == E.LoginPlatformType.IntlPlatform)
  self:showContentRating(not isOn and self.currentPlatform_ == E.LoginPlatformType.TencentPlatform)
end

function LoginView:switchLoginState(state)
  if state == nil then
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
  self:switchLoginState(E.LoginState.AutoLoginAccount)
end

function LoginView:onInitStateExit()
end

function LoginView:onAutoLoginAccountStateEnter()
  self.loginVm_:SDKAutoLogin()
end

function LoginView:onAutoLoginAccountStateExit()
end

function LoginView:onLoginAccountStateEnter()
  self:showLoginAccount(true)
end

function LoginView:onLoginAccountStateExit()
  self:showLoginAccount(false)
end

function LoginView:onGetServerListStateEnter()
  self.waitLogin_ = false
  self:showTips(false)
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
  self.panel.cont_login_ip.dpd_select_ip.TMPDropdown:ClearOptions()
  self.panel.cont_login_ip.dpd_select_ip.TMPDropdown:AddOptions(self.serverData_.LoginOptions)
  self:setDefaultServerAddr()
  local serverCount = #self.serverData_.ServerList
  self:showSelectServer(1 < serverCount)
  if Z.GameContext.IsDevelopment then
    self:showSelectServer(not self.hideServerSelectOnDebug_)
    local accountData = Z.DataMgr.Get("account_data")
    self.panel.cont_debug.input_platform.TMPInput.text = tostring(accountData.PlatformType)
    self.panel.cont_debug.node_platform:SetVisible(true)
  end
end

function LoginView:onEnterGameStateExit()
  self:showEnterGame(false)
  self:showBtnSet(false)
  self:showSelectServer(false)
end

function LoginView:onCheckVersionStateEnter()
  self:setTipsContent(Lang("CheckVersionTips"))
  self:showTips(true)
end

function LoginView:onCheckVersionStateExit()
end

function LoginView:onWaitingConnectStateEnter()
  self:setTipsContent(Lang("ConnectionTips"))
  self:showTips(true)
end

function LoginView:onWaitingConnectStateExit()
end

return LoginView
