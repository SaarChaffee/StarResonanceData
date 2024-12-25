local UI = Z.UI
local super = require("ui.ui_view_base")
local Runtime_editor_uiView = class("Runtime_editor_uiView", super)

function Runtime_editor_uiView:ctor()
  self.panel = nil
  super.ctor(self, "runtime_editor_ui")
  self.joystickView = require("ui/view/zjoystick_view").new()
end

function Runtime_editor_uiView:OnActive()
  self.joystickView:Active(nil, self.panel.joystickContainer.Trans)
  self:AddClick(self.panel.container_rt.btn_client_reload.Btn, function()
    Z.LuaBridge.OnClientHotReload()
  end)
  self:AddClick(self.panel.container_rt.btn_server_reload.Btn, function()
    Z.LuaBridge.OnServerHotReload()
  end)
  self:AddClick(self.panel.container_rt.btn_playskill.Btn, function()
    Z.LuaBridge.OnPlaySkill()
  end)
end

function Runtime_editor_uiView:OnDeActive()
  self.joystickView:DeActive()
end

function Runtime_editor_uiView:OnRefresh()
end

return Runtime_editor_uiView
