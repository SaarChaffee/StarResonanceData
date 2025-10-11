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
end

function C_com_select_use_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_cancel, function()
    self.vm_.CloseUsePopup()
  end)
  self:AddAsyncClick(self.uiBinder.btn_confirm, function()
    local useCount = self.useItemData_:GetUseCount()
    if self.viewData.isUse then
      local param = self.itemsVm_.AssembleUseItemParam(self.viewData.configId, self.viewData.itemUuid, useCount)
      self.itemsVm_.AsyncUseItemByUuid(param, self.cancelSource:CreateToken())
    elseif self.viewData.isDiscard then
      self.itemsVm_.AsyncDeleteItem(self.viewData.itemUuid, useCount, self.cancelSource:CreateToken())
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
  self.keypad_ = keyPad.new(self)
end

function C_com_select_use_popupView:OnRefresh()
  self.isRefreshUseNum_ = false
  self.uiBinder.lab_title.text = self.viewData.title and Lang(self.viewData.title) or ""
  self.uiBinder.lab_second_title.text = self.viewData.secondTitle and Lang(self.viewData.secondTitle) or ""
  self:refreshLimitLab()
  self:initItem()
end

function C_com_select_use_popupView:refreshLimitLab()
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_box_limit, false)
  if self.viewData.configId then
    local itemFunctionTableRow = Z.TableMgr.GetRow("ItemFunctionTableMgr", self.viewData.configId, true)
    if itemFunctionTableRow and itemFunctionTableRow.CounterId ~= 0 then
      local counterRow = Z.TableMgr.GetRow("CounterTableMgr", itemFunctionTableRow.CounterId)
      if counterRow then
        local timerConfigItem = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerItem(counterRow.TimeTableId)
        local timeType = timerConfigItem and timerConfigItem.TimerType or 0
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_box_limit, true)
        local limit = Z.CounterHelper.GetCounterLimitCount(itemFunctionTableRow.CounterId)
        local residueCount = Z.CounterHelper.GetCounterResidueLimitCount(itemFunctionTableRow.CounterId, limit)
        self.uiBinder.lab_box_limit.text = Lang("RestrictedUseOfItemsThe" .. timeType, {val1 = residueCount, val2 = limit})
      end
    end
  end
end

function C_com_select_use_popupView:initItem()
  local maxCount = self.useItemData_:GetMaxUseCount()
  self.uiBinder.slider_progress.maxValue = maxCount
  self.uiBinder.slider_progress.minValue = 1
  self:setSliderValue(maxCount)
  self:RefreshUseNum()
  local itemData = {
    uiBinder = self.uiBinder.com_item_square_1,
    configId = self.viewData.configId,
    uuid = self.viewData.itemUuid,
    lab = self.useItemData_:GetUseCount(),
    isSquareItem = true
  }
  if self.itemClass_ then
    self.itemClass_:RefreshByData(itemData)
  else
    self.itemClass_ = item.new(self)
    self.itemClass_:Init(itemData)
  end
end

function C_com_select_use_popupView:AddPressListener(btn, func)
  btn:AddPressListener(func)
end

function C_com_select_use_popupView:OnDeActive()
  self.isRefreshUseNum_ = false
  self.itemClass_:UnInit()
  self.itemClass_ = nil
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
