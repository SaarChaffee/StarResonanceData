local UI = Z.UI
local super = require("ui.ui_view_base")
local Rename_window_view = class("Rename_window_view", super)

function Rename_window_view:ctor()
  self.uiBinder = nil
  super.ctor(self, "rename_window")
  self.playerVM_ = Z.VMMgr.GetVM("player")
  self.screenWordVM_ = Z.VMMgr.GetVM("screenword")
  self.nameLimitNum_ = Z.Global.PlayerNameLimit
  self.isShowCertain_ = false
  self.renameCardConfig_ = Z.TableMgr.GetTable("ItemTableMgr").GetRow(Z.SystemItem.NameCard)
end

function Rename_window_view:initBinder()
end

function Rename_window_view:initComponents()
  self.uiBinder.input:AddListener(function(str)
    self:onInputChanged(str)
  end)
  self:AddAsyncClick(self.uiBinder.btn_square, function()
    self:onCheckNameBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_cancel, function()
    self:playCertainTipsAni(false)
  end)
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    self:onConfirmBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    self.playerVM_:CloseRenameWindow()
  end)
  self:AddAsyncClick(self.uiBinder.btn_icon, function()
    self:closeTip()
    self.tipId = Z.TipsVM.ShowItemTipsView(self.uiBinder.rect_icon, Z.SystemItem.NameCard)
  end)
end

function Rename_window_view:initData()
  self.inputName_ = ""
  self.isShowCertain_ = false
  self.uiBinder.btn_square.IsDisabled = true
end

function Rename_window_view:onInputChanged(str)
  self.inputName_ = str
  if string.zlen(self.inputName_) > self.nameLimitNum_ then
    self.uiBinder.lab_rule.text = string.format(Lang("ErrorCodeTipString"), Lang("ErrNameSizeError"))
    self:playErrorTipsAni(true)
  else
    self:playErrorTipsAni(false)
  end
  self.uiBinder.btn_square.IsDisabled = self.inputName_ == ""
end

function Rename_window_view:onCheckNameBtnClick()
  if self.isShowCertain_ then
    return
  end
  if self.inputName_ == "" then
    self.uiBinder.lab_rule.text = string.format(Lang("ErrorCodeTipString"), Lang("ErrEmptyName"))
    self:playErrorTipsAni(true)
  elseif string.zlen(self.inputName_) > self.nameLimitNum_ then
  elseif self.inputName_ == Z.ContainerMgr.CharSerialize.charBase.name then
    self.uiBinder.lab_rule.text = Z.TipsVM.GetMessageContent(Z.PbEnum("EErrorCode", "ErrChangeSameName"))
    self:playErrorTipsAni(true)
  else
    self:onPlayAnimatedClickConfirm()
    self:playErrorTipsAni(false)
    self:playCertainTipsAni(true)
  end
end

function Rename_window_view:onConfirmBtnClick()
  self:playCertainTipsAni(false)
  self:playErrorTipsAni(false)
  if self:checkItemEnough() then
    self.playerVM_:AsyncSetCharName(self.inputName_, self.cancelSource:CreateToken())
    self.uiBinder.eff_root:SetEffectGoVisible(true)
    self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.eff_root)
  else
    self.uiBinder.eff_root:SetEffectGoVisible(false)
    Z.TipsVM.ShowTipsLang(100002)
  end
end

function Rename_window_view:onChangeNameResultNtf(errCode)
  if errCode == 0 then
    self.playerVM_:CloseRenameWindow()
    Z.TipsVM.ShowTipsLang(1001801)
  else
    self.uiBinder.lab_rule.text = Lang(Z.PbErrName(errCode))
    self:playErrorTipsAni(true)
  end
end

function Rename_window_view:OnActive()
  self:startAnimatedShow()
  self:initBinder()
  self:initComponents()
  self:BindEvents()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  if self.renameCardConfig_ then
    self.uiBinder.rimg_icon:SetImage(self.renameCardConfig_.Icon)
  end
  self.tipId = nil
end

function Rename_window_view:OnDeActive()
  self:UnBindEvents()
  self:closeTip()
end

function Rename_window_view:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
end

function Rename_window_view:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
end

function Rename_window_view:OnRefresh()
  self:initData()
  self.uiBinder.input.text = self.inputName_
  self.uiBinder.input:ActivateInputField()
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_rule, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, false)
end

function Rename_window_view:playErrorTipsAni(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_rule, isShow)
end

function Rename_window_view:playCertainTipsAni(isShow)
  self.isShowCertain_ = isShow
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, isShow)
  if isShow then
    self:refreshCertainTips()
  end
end

function Rename_window_view:refreshCertainTips()
  self.uiBinder.lab_num_back.text = string.format(Lang("QuotationMarkString"), self.inputName_)
end

function Rename_window_view:checkItemEnough()
  local renameItemId = Z.SystemItem.NameCard
  local curNum = Z.VMMgr.GetVM("items").GetItemTotalCount(renameItemId)
  return 0 < curNum
end

function Rename_window_view:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Rename_window_view:onPlayAnimatedClickConfirm()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_1)
end

function Rename_window_view:closeTip()
  if self.tipId then
    Z.TipsVM.CloseItemTipsView(self.tipId)
    self.tipId = nil
  end
end

return Rename_window_view
