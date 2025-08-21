local super = require("ui.component.loop_list_view_item")
local ExpressSettingItem = class("ExpressSettingItem", super)

function ExpressSettingItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_on:SetImage(data.icon)
  self.uiBinder.img_off:SetImage(data.icon)
  self:refreshSelectState()
end

function ExpressSettingItem:OnSelected(isSelected, isClick)
  if isSelected then
    self.parent.UIView:OnSelectEmojiTab(self.data_)
  end
  self:refreshSelectState()
end

function ExpressSettingItem:refreshSelectState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not self.IsSelected)
end

return ExpressSettingItem
