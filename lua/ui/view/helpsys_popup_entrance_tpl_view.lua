local UI = Z.UI
local super = require("ui.ui_view_base")
local Helpsys_popup_entrance_tplView = class("Helpsys_popup_entrance_tplView", super)

function Helpsys_popup_entrance_tplView:ctor()
  self.uiBinder = nil
  super.ctor(self, "helpsys_popup_entrance_tpl")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.helpsysData_ = Z.DataMgr.Get("helpsys_data")
  self.helpSysId_ = 0
end

function Helpsys_popup_entrance_tplView:OnActive()
  self.askBtn_ = self.uiBinder.btn_ask
  self.barImg_ = self.uiBinder.img_bar
  self.contentLab_ = self.uiBinder.lab_content
  self:BindEvents()
  self:startAnimatedShow()
end

function Helpsys_popup_entrance_tplView:OnDeActive()
  self:closeAnimatedShow()
end

function Helpsys_popup_entrance_tplView:startAnimatedShow()
  self.uiBinder.anim:PlayOnce("anim_helpsys_popup_entrance_tpl_enter")
  self.uiBinder.effect:Play()
end

function Helpsys_popup_entrance_tplView:closeAnimatedShow()
  self.uiBinder.anim:PlayOnce("anim_helpsys_popup_entrance_tpl_close")
end

function Helpsys_popup_entrance_tplView:gotoFunc()
  self.timerMgr:StopTimer(self.timer)
  self.helpsysVM_.OpenSteerHelpsyView(self.helpSysId_)
  self.helpsysVM_.CheckTipsView(true, false)
end

function Helpsys_popup_entrance_tplView:BindEvents()
  self:AddClick(self.askBtn_, function()
    self:gotoFunc()
  end)
end

function Helpsys_popup_entrance_tplView:OnRefresh()
  local data = self.helpsysData_:GetOtherDataById(self.viewData.id)
  if data == nil then
    return
  end
  self.helpSysId_ = data.Id
  self.contentLab_.text = data.Title
  self.barImg_.fillAmount = 1
  if self.timer then
  end
  if Z.IsPCUI then
    local keyVM = Z.VMMgr.GetVM("setting_key")
    local keyCodeDesc = keyVM.GetKeyCodeDescListByKeyId(136)[1]
    if keyCodeDesc then
      self.uiBinder.lab_shortcut.text = keyCodeDesc
    end
  end
  self.timer = self.timerMgr:StartTimer(function()
    self.barImg_.fillAmount = self.barImg_.fillAmount - 1 / (10 * data.DurationTime)
  end, 0.1, 10 * data.DurationTime, true, function()
    if math.abs(self.barImg_.fillAmount) < 1.0E-5 then
      self.helpsysVM_.CheckTipsView(false, true)
    end
  end)
  Z.CoroUtil.create_coro_xpcall(function()
    self.helpsysVM_.AsyncSaveById(self.viewData.id, self.cancelSource:CreateToken())
  end)()
end

function Helpsys_popup_entrance_tplView:OnTriggerInputAction(inputActionEventData)
  self:gotoFunc()
end

return Helpsys_popup_entrance_tplView
