local UI = Z.UI
local super = require("ui.ui_view_base")
local House_check_signature_popupView = class("House_check_signature_popupView", super)

function House_check_signature_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_check_signature_popup")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.houseData_ = Z.DataMgr.Get("house_data")
end

function House_check_signature_popupView:initUiBinders()
  self.clickBtn_ = self.uiBinder.btn_click_signature
  self.signatureImg_ = self.uiBinder.img_signature_bg
  self.infoLab_ = self.uiBinder.lab_info
  self.labPlayerName_ = self.uiBinder.lab_player_name
  self.anim_ = self.uiBinder.anim
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_seal, false)
end

function House_check_signature_popupView:initUi()
  self.labPlayerName_.text = Z.ContainerMgr.CharSerialize.charBase.name
  self:asyncGetCheckInContent()
end

function House_check_signature_popupView:asyncGetCheckInContent()
  Z.CoroUtil.create_coro_xpcall(function()
    local checkInContent = self.houseVm_.AsyncGetHomelandCheckInContent(Z.ContainerMgr.CharSerialize.communityHomeInfo.communityId, Z.ContainerMgr.CharSerialize.communityHomeInfo.homelandId, self.cancelSource:CreateToken())
    self.infoLab_.text = checkInContent ~= "" and checkInContent or Lang("HouseMoveInWords")
  end)()
end

function House_check_signature_popupView:initBtns()
  self:AddClick(self.clickBtn_, function()
    Z.AudioMgr:Play("UI_Home_Check_Signature")
    self.uiBinder.Ref:SetVisible(self.signatureImg_, true)
    self.uiBinder.Ref:SetVisible(self.clickBtn_, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_seal, true)
    self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Open)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.houseVm_.CloseHouseSignatureView()
  end)
end

function House_check_signature_popupView:OnActive()
  self:initUiBinders()
  self.anim_:PlayOnce("anim_house_check_signature_popup_open")
  Z.AudioMgr:Play("UI_Home_Check_Popup")
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.rimg_pic)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self:initBtns()
  self:initUi()
end

function House_check_signature_popupView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.rimg_pic)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
end

function House_check_signature_popupView:OnRefresh()
end

return House_check_signature_popupView
