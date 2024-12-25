local super = require("ui.component.loop_list_view_item")
local RecipeLoopItem = class("RecipeLoopItem", super)

function RecipeLoopItem:ctor()
end

function RecipeLoopItem:OnInit()
  self.uiView = self.parent.UIView
end

function RecipeLoopItem:OnUnInit()
end

function RecipeLoopItem:Refresh(data)
  self.data_ = data
  self.uiBinder.lab_on_name.text = self.data_.Name
  self.uiBinder.lab_off_name2.text = self.data_.Name
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
end

function RecipeLoopItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  if isSelected then
    self.uiView:SelectLoopItem(self.data_)
  end
end

return RecipeLoopItem
