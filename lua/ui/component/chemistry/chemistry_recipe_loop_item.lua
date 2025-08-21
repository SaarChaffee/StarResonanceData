local super = require("ui.component.loop_grid_view_item")
local ChemistryRecipeLoopItem = class("ChemistryRecipeLoopItem", super)
local chemistryItemTpl = require("ui.component.chemistry.chemistry_item_tpl")

function ChemistryRecipeLoopItem:ctor()
end

function ChemistryRecipeLoopItem:OnInit()
end

function ChemistryRecipeLoopItem:OnRefresh(data)
  self.data = data
  chemistryItemTpl.RefreshTpl(self.uiBinder, data.Id, data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
end

function ChemistryRecipeLoopItem:OnUnInit()
end

return ChemistryRecipeLoopItem
