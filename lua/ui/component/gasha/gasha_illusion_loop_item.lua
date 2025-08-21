local super = require("ui.component.loop_list_view_item")
local GashaIllusionLoopItem = class("GashaIllusionLoopItem", super)

function GashaIllusionLoopItem:ctor()
end

function GashaIllusionLoopItem:OnInit()
end

function GashaIllusionLoopItem:OnRefresh(data)
  self.data = data
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data)
  if itemRow == nil then
    return
  end
  self.uiBinder.rimg_icon:SetImage(itemRow.Icon)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
end

function GashaIllusionLoopItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  self.parent.UIView:OnSelectedPray(self.data)
end

function GashaIllusionLoopItem:OnUnInit()
end

return GashaIllusionLoopItem
