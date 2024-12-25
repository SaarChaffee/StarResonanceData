local UI = Z.UI
local super = require("ui.ui_subview_base")
local Desc_content_itemView = class("Desc_content_itemView", super)

function Desc_content_itemView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "desc_content_item", "gm/desc_content_item", UI.ECacheLv.None)
end

function Desc_content_itemView:OnActive()
end

function Desc_content_itemView:OnDeActive()
end

function Desc_content_itemView:OnRefresh()
end

return Desc_content_itemView
