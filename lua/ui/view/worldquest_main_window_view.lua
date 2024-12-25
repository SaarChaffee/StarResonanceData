local UI = Z.UI
local super = require("ui.ui_view_base")
local Worldquest_main_windowView = class("Worldquest_main_windowView", super)

function Worldquest_main_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "worldquest_main_window")
  self.worldQuestInteractiveView = require("ui/view/worldquest_main_sub_view").new(self)
end

function Worldquest_main_windowView:OnActive()
  self.worldQuestInteractiveView:Active(self.viewData.subViewData, self.uiBinder.anim)
end

function Worldquest_main_windowView:OnDeActive()
  self.worldQuestInteractiveView:DeActive()
end

function Worldquest_main_windowView:OnRefresh()
end

return Worldquest_main_windowView
