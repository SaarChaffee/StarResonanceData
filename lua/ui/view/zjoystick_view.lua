local UI = Z.UI
local dataMgr = require("ui.model.data_manager")
local super = require("ui.ui_subview_base")
local ZJoystickView = class("ZJoystickView", super)

function ZJoystickView:ctor()
  super.ctor(self, "main_touch_area_tpl", "main/main_touch_area_tpl", UI.ECacheLv.High)
end

function ZJoystickView:OnActive()
  self:BindEvents()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
end

function ZJoystickView:OnDeActive()
  self:UnBindEvents()
end

function ZJoystickView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.IgnoreFlagChanged, self.CloseJoyStick, self)
end

function ZJoystickView:UnBindEvents()
  Z.EventMgr:RemoveObjAll(self)
end

function ZJoystickView:CloseJoyStick()
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Walk) and Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Run) then
    self:SetVisible(false)
  else
    self:SetVisible(true)
  end
end

return ZJoystickView
