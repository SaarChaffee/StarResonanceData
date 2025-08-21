local UI = Z.UI
local super = require("ui.ui_view_base")
local Chemistry_recipe_popupView = class("Chemistry_recipe_popupView", super)
local loopGridView = require("ui/component/loop_grid_view")
local chemistryRecipeLoopItem = require("ui.component.chemistry.chemistry_recipe_loop_item")

function Chemistry_recipe_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "chemistry_recipe_popup")
  self.lifeProfessionVM_ = Z.VMMgr.GetVM("life_profession")
  self.chemistryData_ = Z.DataMgr.Get("chemistry_data")
end

function Chemistry_recipe_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self.recipeNotAllUnlockGrid_ = loopGridView.new(self, self.uiBinder.node_recipe, chemistryRecipeLoopItem, "chemistry_item_tpl")
  self.recipeNotAllUnlockGrid_:Init({})
  self.recipeAllUnlockGrid_ = loopGridView.new(self, self.uiBinder.node_recipe_all, chemistryRecipeLoopItem, "chemistry_item_tpl")
  self.recipeAllUnlockGrid_:Init({})
  if self.viewData == nil then
    return
  end
  local materialProductions = self.chemistryData_:GetProductions(self.viewData)
  if materialProductions == nil then
    return
  end
  local materialProductionCount = #materialProductions
  local unlockProductionList = {}
  local unlockProductionListIndex = 0
  for _, config in ipairs(materialProductions) do
    if self.lifeProfessionVM_.CheckProductionIsUnlock(config.Id) then
      unlockProductionListIndex = unlockProductionListIndex + 1
      unlockProductionList[unlockProductionListIndex] = config
    end
  end
  local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.viewData)
  if itemConfig then
    self.uiBinder.lab_title.text = Lang("RecipeOfMaterialName", {
      val = itemConfig.Name
    })
  end
  if unlockProductionListIndex == materialProductionCount then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlocked, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_all, true)
    self.recipeAllUnlockGrid_:RefreshListView(unlockProductionList)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlocked, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_all, false)
    self.recipeNotAllUnlockGrid_:RefreshListView(unlockProductionList)
    self.uiBinder.lab_num.text = materialProductionCount - unlockProductionListIndex
  end
end

function Chemistry_recipe_popupView:OnDeActive()
  self.recipeNotAllUnlockGrid_:UnInit()
  self.recipeAllUnlockGrid_:UnInit()
end

function Chemistry_recipe_popupView:OnRefresh()
end

return Chemistry_recipe_popupView
