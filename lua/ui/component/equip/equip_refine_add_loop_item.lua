local super = require("ui.component.loop_list_view_item")
local EquipRefineAddLoopItem = class("EquipRefineAddLoopItem", super)

function EquipRefineAddLoopItem:ctor()
  super:ctor()
end

function EquipRefineAddLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.parent.UIView:AddClick(self.uiBinder.btn_add, function()
    self.uiView_:OpenBlessingSubView()
  end)
end

function EquipRefineAddLoopItem:OnRefresh(data)
end

function EquipRefineAddLoopItem:OnUnInit()
end

return EquipRefineAddLoopItem
