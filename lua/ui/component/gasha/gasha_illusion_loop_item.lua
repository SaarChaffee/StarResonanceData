local super = require("ui.component.loop_list_view_item")
local GashaIllusionLoopItem = class("GashaIllusionLoopItem", super)

function GashaIllusionLoopItem:ctor()
end

function GashaIllusionLoopItem:OnInit()
end

function GashaIllusionLoopItem:OnRefresh(data)
  self.data = data
  local itemVm = Z.VMMgr.GetVM("items")
  self.uiBinder.rimg_icon:SetImage(itemVm.GetItemIcon(data))
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
end

function GashaIllusionLoopItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  self.parent.UIView:OnSelectedPray(self.data)
end

function GashaIllusionLoopItem:OnUnInit()
end

return GashaIllusionLoopItem
