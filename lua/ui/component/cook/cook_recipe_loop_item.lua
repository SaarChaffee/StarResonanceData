local super = require("ui.component.loop_grid_view_item")
local CookRecipeItem = class("CookRecipeItem", super)
local itemClass = require("common.item_binder")

function CookRecipeItem:ctor()
end

function CookRecipeItem:OnInit()
end

function CookRecipeItem:OnRefresh(data)
  self.uiView_ = self.parent.UIView
  self.data_ = data
  self.itemClass_ = itemClass.new(self.uiView_)
  local itemPreviewData = {
    uiBinder = self.uiBinder,
    configId = self.data_.Level00CuisineId,
    iconPath = self.data_.Icon,
    qualityPath = Z.ConstValue.Item.SquareItemQualityPath .. self.data_.Quality,
    isSquareItem = true,
    isClickOpenTips = false
  }
  self.itemClass_:Init(itemPreviewData)
  self.uiBinder.lab_content.text = self.data_.RecipeName
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lab_bg, true)
end

function CookRecipeItem:OnBeforePlayAnim()
end

function CookRecipeItem:OnSelected(isSelected)
  self.itemClass_:SetSelected(isSelected)
  if isSelected then
    self.uiView_:OnSelectedRecipe(self.data_, self.Index)
  end
end

function CookRecipeItem:OnUnInit()
  self.itemClass_:UnInit()
end

return CookRecipeItem
