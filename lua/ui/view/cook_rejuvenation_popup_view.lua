local UI = Z.UI
local super = require("ui.ui_view_base")
local Cook_rejuvenation_popupView = class("Cook_rejuvenation_popupView", super)
local keyPad = require("ui.view.cont_num_keyboard_view")
local itemClass = require("common.item_binder")

function Cook_rejuvenation_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "cook_rejuvenation_popup")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.cookVM_ = Z.VMMgr.GetVM("cook")
end

function Cook_rejuvenation_popupView:initBinders()
  self.cancelBinder_ = self.uiBinder.btn_cancel
  self.affirmBinder_ = self.uiBinder.btn_affirm
  self.addBtn_ = self.uiBinder.btn_add
  self.minusBtn_ = self.uiBinder.btn_minus
  self.maxBtn_ = self.uiBinder.btn_max
  self.numBtn_ = self.uiBinder.btn_num
  self.numLab_ = self.uiBinder.lab_num
  self.slider_ = self.uiBinder.slider_progress
  self.icon_ = self.uiBinder.rimg_icon_front
  self.item_ = self.uiBinder.group_item_square
  self.lab_before_ = self.uiBinder.lab_before
  self.lab_after_ = self.uiBinder.lab_after
  self.SceneMask_ = self.uiBinder.scenemask
  self.SceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
end

function Cook_rejuvenation_popupView:initBtns()
  self:AddClick(self.cancelBinder_.btn, function()
    self.cookVM_:CloseCookRejuvenationPopup()
  end)
  self:AddAsyncClick(self.affirmBinder_.btn, function()
    self.itemsVM_.AsyncUseItemByConfigId(self.recoverConfigId_, self.cancelSource:CreateToken(), self.curNum_)
    self.cookVM_:CloseCookRejuvenationPopup()
  end)
  self:AddClick(self.addBtn_, function()
    if self.isMax_ then
      Z.TipsVM.ShowTips(1002006)
      return
    end
    self:add()
  end)
  self:AddClick(self.minusBtn_, function()
    if self.isMin_ then
      return
    end
    self:minus()
  end)
  self:AddClick(self.maxBtn_, function()
    if self.isMax_ then
      Z.TipsVM.ShowTips(1002006)
      return
    end
    self:max()
  end)
  self:AddClick(self.numBtn_, function()
    self:num()
  end)
  self:AddClick(self.slider_, function()
    self:slierValueChanged()
  end)
end

function Cook_rejuvenation_popupView:OnActive()
  self:initBinders()
  self:initBtns()
  self.keypad_ = keyPad.new(self)
  self.itemClass_ = itemClass.new(self)
  self.recoverCount_ = 0
  self.upLimit_ = 0
  local craftEnergyTableRow = Z.TableMgr.GetRow("CraftEnergyTableMgr", E.CurrencyType.Vitality)
  if craftEnergyTableRow then
    self.curCount_ = self.itemsVM_.GetItemTotalCount(E.CurrencyType.Vitality)
    self.recoverConfigId_ = craftEnergyTableRow.RecoverItemId[1]
    local userCount = self.itemsVM_.GetItemTotalCount(self.recoverConfigId_)
    self.upLimit_ = craftEnergyTableRow.UpLimit
    self.recoverCount_ = craftEnergyTableRow.RecoverItemId[2]
    self.lab_before_.text = self.curCount_ .. " / " .. self.upLimit_
    self.itemClass_:Init({
      uiBinder = self.item_,
      configId = self.recoverConfigId_,
      labType = E.ItemLabType.Str,
      isSquareItem = true
    })
    local itemRow = Z.TableMgr.GetRow("ItemTableMgr", self.recoverConfigId_)
    if itemRow then
      self.icon_:SetImage(itemRow.Icon)
    end
    self.maxCount_ = math.floor((self.upLimit_ - self.curCount_) / self.recoverCount_)
    if userCount < self.maxCount_ then
      self.maxCount_ = userCount
    end
    self.minCount_ = 0
    self.slider_.minValue = self.minCount_
    self.slider_.maxValue = self.maxCount_
    self.isMax_ = 0 == self.maxCount_
    self.isMin_ = 0 == self.minCount_
    self.slider_.value = 0
  end
end

function Cook_rejuvenation_popupView:updateNumData(num)
  if self.slider_.value ~= num then
    self.slider_.value = num
    return
  end
  self.isMax_ = num == self.maxCount_
  self.isMin_ = num == self.minCount_
  self.numLab_.text = num
  self.curNum_ = num
  self.lab_after_.text = Z.RichTextHelper.ApplyColorTag(self.curNum_ * self.recoverCount_ + self.curCount_, "#DBFF00") .. " / " .. self.upLimit_
  self.itemClass_:SetLab(self.curNum_)
end

function Cook_rejuvenation_popupView:add()
  self.slider_.value = self.curNum_ + 1
end

function Cook_rejuvenation_popupView:minus()
  self.slider_.value = self.curNum_ - 1
end

function Cook_rejuvenation_popupView:slierValueChanged()
  self:updateNumData(math.floor(self.slider_.value))
end

function Cook_rejuvenation_popupView:max()
  self.slider_.value = self.maxCount_
end

function Cook_rejuvenation_popupView:InputNum(num)
  self.slider_.value = num
end

function Cook_rejuvenation_popupView:num()
  self.keypad_:Active({
    max = self.maxCount_
  }, self.uiBinder.group_num.transform)
end

function Cook_rejuvenation_popupView:OnDeActive()
  self.itemClass_:UnInit()
  if self.keypad_ then
    self.keypad_:DeActive()
  end
end

function Cook_rejuvenation_popupView:OnRefresh()
end

return Cook_rejuvenation_popupView
