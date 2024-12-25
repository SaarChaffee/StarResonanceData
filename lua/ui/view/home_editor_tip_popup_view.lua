local UI = Z.UI
local super = require("ui.ui_subview_base")
local Home_editor_tip_popupView = class("Home_editor_tip_popupView", super)

function Home_editor_tip_popupView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "home_editor_tip_popup", "home_editor/home_editor_tip_popup", UI.ECacheLv.None)
end

function Home_editor_tip_popupView:OnActive()
end

function Home_editor_tip_popupView:OnDeActive()
end

function Home_editor_tip_popupView:OnRefresh()
end

return Home_editor_tip_popupView
