local super = require("ui.component.loop_list_view_item")
local HomeWarehouseTabTypeLoopItem = class("HomeWarehouseTabTypeLoopItem", super)

function HomeWarehouseTabTypeLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
end

function HomeWarehouseTabTypeLoopItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  self:refreshLab()
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer, E.DynamicSteerType.HomeEditorTogId, self.data_.typeId)
end

function HomeWarehouseTabTypeLoopItem:refreshLab()
  if self.data_ then
    if self.IsSelected then
      self.uiBinder.lab_components.text = Z.RichTextHelper.ApplyColorTag(self.data_.typeName, "#333333")
    else
      self.uiBinder.lab_components.text = Z.RichTextHelper.ApplyColorTag(self.data_.typeName, "#6c6c6c")
    end
  end
end

function HomeWarehouseTabTypeLoopItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  if isSelected then
    self.uiView_:SetWareHouseData(self.data_.typeId, self.Index)
  end
  self:refreshLab()
end

function HomeWarehouseTabTypeLoopItem:OnUnInit()
  self.uiBinder.steer:ClearSteerList()
end

return HomeWarehouseTabTypeLoopItem
