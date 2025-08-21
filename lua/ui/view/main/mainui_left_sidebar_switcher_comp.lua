local MainUILeftSidebarSwitcherComp = class("MainUILeftSidebarSwitcherComp")

function MainUILeftSidebarSwitcherComp:ctor(view)
  self.view_ = view
end

function MainUILeftSidebarSwitcherComp:Init()
  self.uiBinder = self.view_.uiBinder
  self:bindEvents()
end

function MainUILeftSidebarSwitcherComp:bindEvents(...)
  Z.EventMgr:Add(Z.ConstValue.Device.DeviceTypeChange, self.onDeviceChange, self)
end

function MainUILeftSidebarSwitcherComp:UnInit()
  self:unBindEvents()
  self.uiBinder = nil
  self.view_ = nil
end

function MainUILeftSidebarSwitcherComp:unBindEvents(...)
  Z.EventMgr:Remove(Z.ConstValue.Device.DeviceTypeChange, self.onDeviceChange, self)
end

function MainUILeftSidebarSwitcherComp:OnRefresh(...)
  self:onDeviceChange()
end

function MainUILeftSidebarSwitcherComp:OnTriggerInputAction(inputActionEventData)
end

function MainUILeftSidebarSwitcherComp:onDeviceChange()
  if not Z.IsPCUI then
    return
  end
  if Z.InputMgr.InputDeviceType == Panda.ZInput.EInputDeviceType.Joystick then
    self:setGamePadPos()
  else
    self:setKeyboardPos()
  end
end

function MainUILeftSidebarSwitcherComp:setKeyboardPos()
  self.uiBinder.node_btn_left:SetAnchorPosition(self.view_.pcPosX, 0)
end

function MainUILeftSidebarSwitcherComp:setGamePadPos()
  self.uiBinder.node_btn_left:SetAnchorPosition(self.view_.handPosX, 0)
end

return MainUILeftSidebarSwitcherComp
