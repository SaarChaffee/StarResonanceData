local UI = Z.UI
local super = require("ui.ui_subview_base")
local Handbook_dictionaries_list_item_tplView = class("Handbook_dictionaries_list_item_tplView", super)

function Handbook_dictionaries_list_item_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "handbook_dictionaries_list_item_tpl", "handbook/handbook_dictionaries_list_item_tpl", UI.ECacheLv.None)
end

function Handbook_dictionaries_list_item_tplView:OnActive()
end

function Handbook_dictionaries_list_item_tplView:OnDeActive()
end

function Handbook_dictionaries_list_item_tplView:OnRefresh()
end

return Handbook_dictionaries_list_item_tplView
