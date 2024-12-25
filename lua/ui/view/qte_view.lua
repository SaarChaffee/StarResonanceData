local UI = Z.UI
local super = require("ui.ui_view_base")
local QteView = class("QteView", super)

function QteView:ctor()
  self.panel = nil
  super.ctor(self, "qte")
end

function QteView:OnActive()
end

function QteView:OnDeActive()
end

function QteView:OnRefresh()
end

return QteView
