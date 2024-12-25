local UI = Z.UI
local super = require("ui.ui_view_base")
local Name_windowView = class("Name_windowView", super)

function Name_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "name_window")
  self.playerVM_ = Z.VMMgr.GetVM("player")
  self.nameLimitNum_ = Z.Global.PlayerNameLimit
end

function Name_windowView:initBinder()
end

function Name_windowView:initComponents()
  self.uiBinder.input:AddListener(function(str)
    self:onInputChanged(str)
  end)
  self:AddAsyncClick(self.uiBinder.cont_btn_confirm, function()
    self:onConfirmBtnClick()
  end)
end

function Name_windowView:initData()
  self.inputName_ = ""
end

function Name_windowView:onInputChanged(str)
  self.inputName_ = str
  if string.zlen(self.inputName_) > self.nameLimitNum_ then
    self.uiBinder.lab_info.text = Lang("ErrNameSizeError")
    self:playErrorTipsAni(true)
  else
    self:playErrorTipsAni(false)
  end
end

function Name_windowView:onConfirmBtnClick()
  if self.inputName_ == "" then
    self.uiBinder.lab_info.text = Lang("ErrEmptyName")
    self:playErrorTipsAni(true)
  elseif string.zlen(self.inputName_) > self.nameLimitNum_ then
    self.uiBinder.lab_info.text = Lang("ErrNameSizeError")
    self:playErrorTipsAni(true)
  else
    self.playerVM_:AsyncSetCharName(self.inputName_, self.cancelSource:CreateToken())
    self:playErrorTipsAni(false)
  end
end

function Name_windowView:onChangeNameResultNtf(errCode)
  if errCode == 0 then
    Z.AudioMgr:Play("UI_Event_NameSuccess")
    Z.SDKReport.ReportEvent(Z.SDKReportEvent.NamedCharacter)
    local OnAniComplete = function()
      self.playerVM_:CloseNameWindow()
      Z.EPFlowBridge.OnLuaFunctionCallback("OPEN_NAME_WINDOW")
    end
    self.uiBinder.node_effect:SetEffectGoVisible(true)
    self.uiBinder.anim:CoroPlay(Z.DOTweenAnimType.Close, function()
      OnAniComplete()
    end, function(err)
      if err ~= nil then
        logError("CoroPlay err={0}", err)
      end
      OnAniComplete()
    end)
  else
    self.uiBinder.lab_info.text = Lang(Z.PbErrName(errCode))
    self:playErrorTipsAni(true)
  end
end

function Name_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:startAnimatedShow()
  self:initBinder()
  self:initComponents()
  self:BindEvents()
end

function Name_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:UnBindEvents()
end

function Name_windowView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
end

function Name_windowView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
end

function Name_windowView:OnRefresh()
  self:initData()
  self.uiBinder.input.text = self.inputName_
  self.uiBinder.input:ActivateInputField()
  self.isShowTip_ = false
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, false)
end

function Name_windowView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Name_windowView:playErrorTipsAni(isShow)
  if self.isShowTip_ == isShow then
    return
  end
  self.isShowTip_ = isShow
  self.uiBinder.anim:Pause()
  if isShow then
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
  else
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_1)
  end
end

return Name_windowView
