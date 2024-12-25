local UI = Z.UI
local super = require("ui.ui_view_base")
local Pub_mixology_recipe_mainView = class("Pub_mixology_recipe_mainView", super)
local loopListView = require("ui/component/loop_list_view")
local recipeLoopItem = require("ui.component.pub.recipe_loop_item")

function Pub_mixology_recipe_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "pub_mixology_recipe_main")
  self.vm_ = Z.VMMgr.GetVM("pub_mixology")
end

function Pub_mixology_recipe_mainView:OnActive()
  self:initWidgets()
  self.scenemask_:SetSceneMaskByKey(Z.UI.ESceneMaskKey.Default)
  self.allItems_ = {}
  self.dotween_:Restart(Z.DOTweenAnimType.Open)
  self:AddClick(self.closeBtn_, function()
    self.vm_.CloseRecipeView()
  end)
  self.recipScrollRect_ = loopListView.new(self, self.recipeVloop_, recipeLoopItem, "pub_mixology_item_tpl")
  self.recipScrollRect_:Init(self.vm_.GetCocktailRecipeData())
  self.recipScrollRect_:SetSelected(1)
end

function Pub_mixology_recipe_mainView:initWidgets()
  self.dotween_ = self.uiBinder.anim_mixology
  self.closeBtn_ = self.uiBinder.btn_close
  self.recipeVloop_ = self.uiBinder.loop_item
  self.titleLab_ = self.uiBinder.lab_title
  self.introduceLab_ = self.uiBinder.lab_info
  self.recipeItemTrans_ = self.uiBinder.node_icon
  self.scenemask_ = self.uiBinder.scenemask
  self.prefabCache_ = self.uiBinder.prefab_cache
end

function Pub_mixology_recipe_mainView:SelectLoopItem(data)
  self.introduceLab_.text = data.IntroductionText
  self.titleLab_.text = data.Name
  for name, item in pairs(self.allItems_) do
    self:RemoveUiUnit(name)
  end
  local path = self.prefabCache_:GetString("item")
  if path == "" or path == nil then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for key, value in pairs(data.Recipe) do
      local itemId = value[1]
      local itemCount = value[2]
      local name = string.format("Item_%s", key)
      local item = self:AsyncLoadUiUnit(path, name, self.recipeItemTrans_.transform)
      if item == nil then
        return
      end
      item.Ref:SetVisible(item.img_add, key ~= 1)
      self.allItems_[name] = item
      item.lab_num.text = itemCount
      local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId)
      if itemRow then
        local itemsVM = Z.VMMgr.GetVM("items")
        item.img_icon:SetImage(itemsVM.GetItemIcon(itemId))
      end
      self:AddClick(item.btn_icon, function()
        self.itemTipsId_ = Z.TipsVM.ShowItemTipsView(item.Trans, itemId)
      end)
    end
  end)()
end

function Pub_mixology_recipe_mainView:OnDeActive()
  if self.recipScrollRect_ then
    self.recipScrollRect_:UnInit()
  end
  self.dotween_:Play(Z.DOTweenAnimType.Close)
  if self.itemTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
  end
end

function Pub_mixology_recipe_mainView:OnRefresh()
end

return Pub_mixology_recipe_mainView
