local UI = Z.UI
local super = require("ui.ui_view_base")
local PersonalzoneView = class("PersonalzoneView", super)

function PersonalzoneView:ctor()
  self.panel = nil
  super.ctor(self, "personalzone")
end

function PersonalzoneView:OnActive()
end

function PersonalzoneView:OnDeActive()
end

function PersonalzoneView:OnRefresh()
end

return PersonalzoneView
