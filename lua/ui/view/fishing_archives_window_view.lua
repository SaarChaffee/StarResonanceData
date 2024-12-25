local UI = Z.UI
local super = require("ui.ui_view_base")
local Fishing_archives_windowView = class("Fishing_archives_windowView", super)
local fishingArchivesSubView = require("ui/view/fishing_archives_sub_view")

function Fishing_archives_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fishing_archives_window")
  self.subView_ = fishingArchivesSubView.new()
end

function Fishing_archives_windowView:OnActive()
  self.subView_:Active(self.viewData, self.uiBinder.sub_holder)
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
end

function Fishing_archives_windowView:OnDeActive()
  self.subView_:DeActive()
end

function Fishing_archives_windowView:OnRefresh()
end

return Fishing_archives_windowView
