local super = require("ui.component.loop_grid_view_item")
local HouseGuideLoopItem = class("HouseGuideLoopItem", super)

function HouseGuideLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function HouseGuideLoopItem:OnRefresh(data)
  self.data_ = data
  local item = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.Id)
  if item == nil then
    return ""
  end
  self.uiBinder.lab_content.text = item.Name
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  self.uiBinder.rimg_icon:SetImage(self.itemsVm_.GetItemIcon(data.Id))
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", data.Id)
  if itemRow then
    self.uiBinder.img_quality:SetImage("ui/atlas/chemistry/item_quality_sys_" .. itemRow.Quality)
  end
end

function HouseGuideLoopItem:OnSelected(OnSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, OnSelected)
  if OnSelected then
    self.uiView_:OnSelected(self.data_)
  end
end

function HouseGuideLoopItem:OnPointerClick(go, eventData)
  self.parent.UIView:OnItemStartAnimShow()
end

function HouseGuideLoopItem:OnUnInit()
end

return HouseGuideLoopItem
