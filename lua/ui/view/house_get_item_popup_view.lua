local UI = Z.UI
local super = require("ui.ui_view_base")
local House_get_item_popupView = class("House_get_item_popupView", super)
local item = require("common.item_binder")
local keyPad = require("ui.view.cont_num_keyboard_view")

function House_get_item_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_get_item_popup")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.itemClass_ = item.new(self)
  self.houseVm_ = Z.VMMgr.GetVM("house")
end

function House_get_item_popupView:OnActive()
  self.curCount_ = 0
  self.maxCount_ = self.viewData.furnitureCount - self.viewData.accelerateCount
  local path = self.itemsVm_.GetItemIcon(Z.GlobalHome.BuildAccelerateItem[1])
  self.uiBinder.rimg_gold:SetImage(path)
  self.isRefreshUseNum_ = false
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_cancel, function()
    self.houseVm_.CloseHoseGetItemView()
  end)
  self:AddClick(self.uiBinder.btn_gold, function()
    if self.tipsId_ then
      Z.TipsVM.CloseItemTipsView(self.tipsId_)
    end
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.btn_gold.transform, Z.GlobalHome.BuildAccelerateItem[1])
  end)
  self:AddAsyncClick(self.uiBinder.btn_confirm, function()
    self.houseVm_.AsyncBuildFurnitureAccelerate(self.viewData.buildUuid, self.viewData.furnitureId, self.curCount_, self.cancelSource)
    self.houseVm_.CloseHoseGetItemView()
  end, nil, nil)
  self:AddClick(self.uiBinder.btn_add, function()
    local count = self.curCount_ + 1
    if count <= self.maxCount_ then
      self:setSliderValue(count)
    end
  end)
  self:AddClick(self.uiBinder.btn_reduce, function()
    local count = self.curCount_ - 1
    if -1 < count then
      self:setSliderValue(count)
    end
  end)
  self:AddClick(self.uiBinder.btn_max, function()
    self.curCount_ = self.maxCount_
    self.uiBinder.slider_progress.value = self.maxCount_
  end)
  self:AddClick(self.uiBinder.slider_progress, function(value)
    if not self.isRefreshUseNum_ then
      self.curCount_ = math.floor(value)
      self:RefreshUseNum()
    else
      self.isRefreshUseNum_ = false
    end
  end)
  self:AddClick(self.uiBinder.btn_num, function()
    self.keypad_:Active({
      min = 1,
      max = self.maxCount_
    }, self.uiBinder.node_pad)
  end)
  self.viewData_ = self.viewData
  self.keypad_ = keyPad.new(self)
  self:initItem()
end

function House_get_item_popupView:initItem()
  self.uiBinder.slider_progress.maxValue = self.maxCount_
  self.uiBinder.slider_progress.minValue = 1
  self:setSliderValue(self.maxCount_)
  self:RefreshUseNum()
  self.itemClass_:Init({
    uiBinder = self.uiBinder.com_item_square_1,
    configId = self.viewData.furnitureId,
    lab = self.viewData.furnitureCount - self.viewData.accelerateCount,
    isSquareItem = true
  })
end

function House_get_item_popupView:AddPressListener(btn, func)
  btn:AddPressListener(func)
end

function House_get_item_popupView:OnDeActive()
  self.isRefreshUseNum_ = false
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
  self.itemClass_:UnInit()
  self.keypad_:DeActive()
end

function House_get_item_popupView:InputNum(num)
  if num == 0 then
    num = 1
  end
  self.curCount_ = num
  self:setSliderValue(self.curCount_)
end

function House_get_item_popupView:setSliderValue(num)
  self.curCount_ = num
  self.uiBinder.slider_progress.value = num
end

function House_get_item_popupView:RefreshUseNum()
  local count = self.curCount_
  local maxCount = self.maxCount_
  self.uiBinder.btn_reduce.interactable = 1 < count
  self.uiBinder.btn_add.interactable = count < maxCount
  self.uiBinder.lab_num.text = count
  local totalCount = self.itemsVm_.GetItemTotalCount(Z.GlobalHome.BuildAccelerateItem[1])
  local expendCount = Z.GlobalHome.BuildAccelerateItem[2] * count
  self.uiBinder.lab_digit.text = totalCount < expendCount and Z.RichTextHelper.ApplyStyleTag(expendCount, E.TextStyleTag.TipsRed) or expendCount
end

return House_get_item_popupView
