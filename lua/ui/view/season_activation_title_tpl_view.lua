local UI = Z.UI
local super = require("ui.ui_subview_base")
local Season_activation_title_tplView = class("Season_activation_title_tplView", super)

function Season_activation_title_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "season_activation_title_tpl", "season_activation/season_activation_title_tpl", UI.ECacheLv.None)
end

function Season_activation_title_tplView:OnActive()
end

function Season_activation_title_tplView:OnDeActive()
end

function Season_activation_title_tplView:OnRefresh()
end

return Season_activation_title_tplView
