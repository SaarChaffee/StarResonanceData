local UI = Z.UI
local super = require("ui.ui_view_base")
local Equip_choice_popupView = class("Equip_choice_popupView", super)
local loopGridView_ = require("ui/component/loop_grid_view")
local loopItem = require("ui/component/equip/equip_recast_popup_loop_item")

function Equip_choice_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "equip_choice_popup")
  self.equipRecastVm_ = Z.VMMgr.GetVM("equip_recast")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.tradeVM_ = Z.VMMgr.GetVM("trade")
end

function Equip_choice_popupView:initUiBinders()
  self.closeBtn_ = self.uiBinder.btn_close
  self.selectedBtn_ = self.uiBinder.btn_selected
  self.emptyNode_ = self.uiBinder.cont_empty
  self.loopGridView_ = self.uiBinder.scrollview_item
  self.tipsNode_ = self.uiBinder.node_tips
  self.gotoBtn_ = self.uiBinder.btn_goto
  self.scenemask_ = self.uiBinder.scenemask
  self.promptLab_ = self.uiBinder.lab_prompt
  self.scenemask_:SetSceneMaskByKey(self.SceneMaskKey)
end

function Equip_choice_popupView:initBtns()
  self:AddClick(self.closeBtn_, function()
    self.equipRecastVm_.ClostRecastChoiceView()
  end)
  self:AddClick(self.gotoBtn_, function()
    self.equipVm_.OpenEquipSearchTips(self.gotoBtn_.transform)
  end)
  self:AddClick(self.selectedBtn_, function()
    local onClickSelect = function()
      Z.EventMgr:Dispatch(Z.ConstValue.Equip.SelectedRecastItem, self.item_)
      self.equipRecastVm_.ClostRecastChoiceView()
    end
    if self.item_ then
      local canTrade = self.tradeVM_:CheckItemCanExchange(self.item_.configId, self.item_.uuid)
      if canTrade then
        self.equipVm_.OpenDayDialog(onClickSelect, Lang("EquipRecastCanTradeTips"), E.DlgPreferencesKeyType.EquipRecastCanTradeTips)
      else
        onClickSelect()
      end
    else
      onClickSelect()
    end
  end)
end

function Equip_choice_popupView:initUi()
  self.uiBinder.Ref:SetVisible(self.selectedBtn_, false)
  self.gridView_ = loopGridView_.new(self, self.loopGridView_, loopItem, "com_item_long_3")
  self.items_ = self.equipVm_.GetEquipsByConfigId(self.viewData.configId, self.viewData.uuid, true)
  self.uiBinder.Ref:SetVisible(self.promptLab_, #self.items_ > 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, #self.items_ > 0)
  self.uiBinder.Ref:SetVisible(self.emptyNode_, #self.items_ == 0)
  self.uiBinder.Ref:SetVisible(self.gotoBtn_, #self.items_ == 0)
  if #self.items_ > 0 then
    table.sort(self.items_, function(leftItem, rightItem)
      if leftItem.equipAttr.perfectionValue > rightItem.equipAttr.perfectionValue then
        return true
      elseif leftItem.equipAttr.perfectionValue < rightItem.equipAttr.perfectionValue then
        return false
      end
      if leftItem.equipAttr.totalRecastCount > rightItem.equipAttr.totalRecastCount then
        return true
      elseif leftItem.equipAttr.totalRecastCount < rightItem.equipAttr.totalRecastCount then
        return false
      end
      return false
    end)
    self.gridView_:Init(self.items_)
    self.gridView_:SelectIndex(0)
  end
end

function Equip_choice_popupView:OnActive()
  self:initUiBinders()
  self:onStartAnimShow()
  self:initBtns()
  self:initUi()
end

function Equip_choice_popupView:OnDeActive()
  self.gridView_:UnInit()
  if self.itemTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
    self.itemTipsId_ = nil
  end
  self.equipVm_.CloseApproach()
end

function Equip_choice_popupView:OnRefresh()
end

function Equip_choice_popupView:OnItemSelected(item)
  if item then
    if self.itemTipsId_ then
      Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
      self.itemTipsId_ = nil
    end
    self.uiBinder.Ref:SetVisible(self.selectedBtn_, true)
    self.item_ = item
    local itemTipsViewData = {}
    itemTipsViewData.configId = item.configId
    itemTipsViewData.itemUuid = item.uuid
    itemTipsViewData.isResident = true
    itemTipsViewData.posType = E.EItemTipsPopType.Parent
    itemTipsViewData.isShowBg = false
    itemTipsViewData.parentTrans = self.tipsNode_.transform
    itemTipsViewData.maxHeight = 220
    self.itemTipsId_ = Z.TipsVM.OpenItemTipsView(itemTipsViewData)
  end
end

function Equip_choice_popupView:onStartAnimShow()
  self.uiBinder.anim_choice:Restart(Z.DOTweenAnimType.Open)
end

return Equip_choice_popupView
