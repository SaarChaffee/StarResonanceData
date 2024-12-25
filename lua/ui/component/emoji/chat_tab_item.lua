local super = require("ui.component.loop_list_view_item")
local ChatTabItem = class("ChatTabItem", super)

function ChatTabItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_off_icon:SetImage(data.icon)
  self.uiBinder.img_on_icon:SetImage(data.icon)
  self.uiBinder.lab_name.text = ""
  self:refreshWidth()
  self:setSelect(self.IsSelected)
end

function ChatTabItem:OnSelected(isSelected)
  if isSelected then
    self.parent.UIView:OnSelectSecondTab(self.data_.id, self.data_.tag)
  end
  self:setSelect(isSelected)
end

function ChatTabItem:setSelect(isSelect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, isSelect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not isSelect)
end

function ChatTabItem:refreshWidth()
  self.onWidth_ = 100
end

return ChatTabItem
