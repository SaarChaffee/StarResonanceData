local super = require("ui.component.loop_grid_view_item")
local ChatFuncItem = class("ChatFuncItem", super)

function ChatFuncItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_on:SetImage(self.data_.funcRow.Icon)
  self.uiBinder.img_off:SetImage(self.data_.funcRow.Icon)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not self.IsSelected)
end

function ChatFuncItem:OnSelected(isSelected)
  if isSelected then
    self.parent.UIView:OnSelectFuncTab(self.data_.funcType, self.data_.funcRow.Id)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not self.IsSelected)
end

return ChatFuncItem
