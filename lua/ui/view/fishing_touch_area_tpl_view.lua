local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fishing_touch_area_tplView = class("Fishing_touch_area_tplView", super)

function Fishing_touch_area_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "fishing_touch_area_tpl", "fishing/fishing_touch_area_tpl", UI.ECacheLv.None)
end

function Fishing_touch_area_tplView:OnActive()
  self:BindEvents()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
end

function Fishing_touch_area_tplView:OnDeActive()
  self:UnBindEvents()
end

function Fishing_touch_area_tplView:OnRefresh()
end

function Fishing_touch_area_tplView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.IgnoreFlagChanged, self.CloseJoyStick, self)
end

function Fishing_touch_area_tplView:UnBindEvents()
  Z.EventMgr:RemoveObjAll(self)
end

function Fishing_touch_area_tplView:CloseJoyStick()
  self.uiBinder.Ref.UIComp:SetVisible(false)
  self.uiBinder.joystick:ResetJoystick()
end

function Fishing_touch_area_tplView:OpenJouStick()
  self.uiBinder.Ref.UIComp:SetVisible(true)
end

return Fishing_touch_area_tplView
