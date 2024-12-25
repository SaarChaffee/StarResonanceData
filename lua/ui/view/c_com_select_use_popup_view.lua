local UI = Z.UI
local super = require("ui.ui_view_base")
local C_com_select_use_popupView = class("C_com_select_use_popupView", super)
local item = require("common.item_binder")
local keyPad = require("ui.view.cont_num_keyboard_view")

function C_com_select_use_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "c_com_select_use_popup")
  self.vm_ = Z.VMMgr.GetVM("use_item_popup")
  self.useItemData_ = Z.DataMgr.Get("user_item_popup_data")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.itemClass_ = item.new(self)
end

function C_com_select_use_popupView:OnActive()
  self.isRefreshUseNum_ = false
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_cancel, function()
    self.vm_.CloseUsePopup()
  end)
  self.uiBinder.lab_title.text = self.viewData.title and Lang(self.viewData.title) or ""
  self.uiBinder.lab_second_title.text = self.viewData.secondTitle and Lang(self.viewData.secondTitle) or ""
  self:AddAsyncClick(self.uiBinder.btn_confirm, function()
    if self.viewData.isUse then
      local param = {}
      if self.viewData.itemUuid == nil then
        local itemsData = Z.DataMgr.Get("items_data")
        local ids = itemsData:GetItemUuidsByConfigId(self.viewData.configId)
        if 1 <= #ids then
          param.itemUuid = ids[1]
        end
      else
        param.itemUuid = self.viewData.itemUuid
      end
      param.useNum = self.useItemData_:GetUseCount()
      self.itemsVm_.AsyncUseItemByUuid(param, self.cancelSource:CreateToken())
    elseif self.viewData.isDiscard then
      self.itemsVm_.AsyncDeleteItem(self.viewData.itemUuid, self.useItemData_:GetUseCount(), self.cancelSource:CreateToken())
    end
    self.vm_.CloseUsePopup()
  end, nil, nil)
  self:AddClick(self.uiBinder.btn_add, function()
    self:setSliderValue(1)
  end)
  self:AddClick(self.uiBinder.btn_reduce, function()
    self:setSliderValue(-1)
  end)
  self:AddClick(self.uiBinder.btn_max, function()
    local maxCount = self.useItemData_:GetMaxUseCount()
    self.useItemData_:SetUseCount(maxCount)
    self.uiBinder.slider_progress.value = maxCount
  end)
  self:AddClick(self.uiBinder.slider_progress, function(value)
    if not self.isRefreshUseNum_ then
      self.useItemData_:SetUseCount(math.floor(value))
      self:RefreshUseNum()
    else
      self.isRefreshUseNum_ = false
    end
  end)
  self:AddClick(self.uiBinder.btn_num, function()
    self.keypad_:Active({}, self.uiBinder.node_pad)
  end)
  self.viewData_ = self.viewData
  self.keypad_ = keyPad.new(self)
  self:initItem()
end

function C_com_select_use_popupView:initItem()
  local maxCount = self.useItemData_:GetMaxUseCount()
  self.uiBinder.slider_progress.maxValue = maxCount
  self.uiBinder.slider_progress.minValue = 1
  self:setSliderValue(maxCount)
  self:RefreshUseNum()
  self.itemClass_:Init({
    uiBinder = self.uiBinder.com_item_square_1,
    configId = self.viewData_.configId,
    uuid = self.viewData_.itemUuid,
    lab = self.useItemData_:GetUseCount(),
    isSquareItem = true
  })
end

function C_com_select_use_popupView:AddPressListener(btn, func)
  btn:AddPressListener(func)
end

function C_com_select_use_popupView:OnDeActive()
  self.isRefreshUseNum_ = false
  self.itemClass_:UnInit()
  self.keypad_:DeActive()
end

function C_com_select_use_popupView:InputNum(num)
  if num == 0 then
    num = 1
  end
  self.useItemData_:SetUseCount(num)
  self:setSliderValue(0)
end

function C_com_select_use_popupView:setSliderValue(num)
  self.useItemData_:AddUseCount(num)
  local count = self.useItemData_:GetUseCount()
  self.uiBinder.slider_progress.value = count
end

function C_com_select_use_popupView:RefreshUseNum()
  local count = self.useItemData_:GetUseCount()
  local maxCount = self.useItemData_:GetMaxUseCount()
  self.uiBinder.btn_reduce.interactable = 1 < count
  self.uiBinder.btn_add.interactable = count < maxCount
  self.uiBinder.lab_num.text = count
end

return C_com_select_use_popupView
