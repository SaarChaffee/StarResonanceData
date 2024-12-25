local UI = Z.UI
local super = require("ui.ui_view_base")
local Explore_monster_deplete_popupView = class("Explore_monster_deplete_popupView", super)
local itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")

function Explore_monster_deplete_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "explore_monster_deplete_popup")
  self.exploreMonsterVM_ = Z.VMMgr.GetVM("explore_monster")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function Explore_monster_deplete_popupView:OnActive()
  local d_ = self.viewData
  self.uuid_ = d_.uuid
  self.templateId_ = d_.templateId
  self.itemId_ = d_.itemId
  self:initBinders()
  local itemTableBase = itemTableMgr_.GetRow(self.itemId_)
  if itemTableBase == nil then
    return
  end
  local iconPath_ = self.itemsVM_.GetItemIcon(self.itemId_)
  self.icon1_rimg_:SetImage(iconPath_)
  self.icon2_rimg_:SetImage(iconPath_)
  local needNum_ = 1
  local itemCount_ = self.itemsVM_.GetItemTotalCount(self.itemId_)
  self.itemIsEnough_ = needNum_ <= itemCount_
  local colorTag = self.itemIsEnough_ and E.TextStyleTag.White or E.TextStyleTag.Red
  self.count_lab_.text = Z.RichTextHelper.ApplyStyleTag(itemCount_ .. "/" .. needNum_, colorTag)
end

function Explore_monster_deplete_popupView:OnDeActive()
  self.uuid_ = nil
  self.templateId_ = nil
end

function Explore_monster_deplete_popupView:OnRefresh()
end

function Explore_monster_deplete_popupView:initBinders()
  self.confirm_btn_ = self.uiBinder.btn_confirm
  self.cancel_btn_ = self.uiBinder.btn_cancel
  self.item_btn_ = self.uiBinder.btn_icon
  self.info_lab_ = self.uiBinder.lab_content01
  self.num_lab_ = self.uiBinder.lab_content02
  self.count_lab_ = self.uiBinder.lab_digit
  self.icon1_rimg_ = self.uiBinder.rimg_icon1
  self.icon2_rimg_ = self.uiBinder.rimg_icon2
  local closeFunc_ = function()
    self.exploreMonsterVM_:CloseExploreMonsterDepleteWindow()
  end
  self:AddClick(self.confirm_btn_, function()
    if self.itemIsEnough_ == false then
      Z.TipsVM.ShowTips(2306)
      return
    end
    if self.uuid_ and self.templateId_ then
      Z.InteractionMgr:SendInteractionInfo(self.uuid_, self.templateId_)
    end
    self.exploreMonsterVM_:CloseExploreMonsterDepleteWindow()
  end)
  self:AddClick(self.item_btn_, function()
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.item_btn_.transform, self.itemId_)
  end)
  self:AddClick(self.cancel_btn_, closeFunc_)
  self.uiBinder.scenemask:SetSceneMaskByKey(Z.UI.ESceneMaskKey.Default)
end

return Explore_monster_deplete_popupView
