local UI = Z.UI
local super = require("ui.ui_view_base")
local House_get_popupView = class("House_get_popupView", super)

function House_get_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_get_popup")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.houseData_ = Z.DataMgr.Get("house_data")
end

function House_get_popupView:initBinders()
  self.infoLab_ = self.uiBinder.lab_info
  self.promptLab_ = self.uiBinder.lab_prompt
  self.gotoBtn_ = self.uiBinder.btn_square_new.btn
end

function House_get_popupView:initData()
  self.isFirstGet_ = self.houseData_.GetHomeBuyCount() == 1
end

function House_get_popupView:initUi()
  self.uiBinder.Ref:SetVisible(self.promptLab_, not self.isFirstGet_)
  self.promptLab_.text = Lang("HouseGetPrompt")
  self.infoLab_.text = self.isFirstGet_ and Lang("HouseGetInfoFirst") or Lang("HouseGetInfo")
end

function House_get_popupView:initBtns()
  self:AddClick(self.gotoBtn_, function()
    self.houseVm_.CloseHouseGetView()
    self.houseVm_.OpenHouseMainView()
  end)
end

function House_get_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:onStartAnimShow()
  self:initBinders()
  self:initBtns()
  self:initData()
  self:initUi()
end

function House_get_popupView:OnDeActive()
end

function House_get_popupView:OnRefresh()
end

function House_get_popupView:onStartAnimShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  self.uiBinder.anim:PlayOnce("anim_house_get_popup_open")
end

return House_get_popupView
