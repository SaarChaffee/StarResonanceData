local UI = Z.UI
local super = require("ui.ui_view_base")
local Common_privilege_popupView = class("Common_privilege_popupView", super)

function Common_privilege_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "common_privilege_popup")
end

function Common_privilege_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
end

function Common_privilege_popupView:OnDeActive()
end

function Common_privilege_popupView:OnRefresh()
end

return Common_privilege_popupView
