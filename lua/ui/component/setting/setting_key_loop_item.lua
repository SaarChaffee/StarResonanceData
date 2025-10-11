local SettingKeyLoopItem = class("SettingKeyLoopItem", super)

function SettingKeyLoopItem:ctor()
end

function SettingKeyLoopItem:Init(parentView, settingKeyCtx, unit)
  self.parentView_ = parentView
  self.uiBinder = unit
  self.settingKeyCtx = settingKeyCtx
  self.keyVM_ = Z.VMMgr.GetVM("setting_key")
  self.settingKeyData_ = Z.DataMgr.Get("setting_key_data")
  self:refresh()
  Z.EventMgr:Add(Z.ConstValue.Device.DeviceTypeChange, self.onDeviceChange, self)
end

function SettingKeyLoopItem:onDeviceChange()
  self:refreshGamePadElements()
end

function SettingKeyLoopItem:refresh()
  self.keyboardTableRow_ = self.settingKeyCtx.setKeyboardTableRow
  self.uiBinder.lab_desc.text = self.settingKeyData_:GetSettingKeyDescName(self.settingKeyCtx)
  self.isKeyboardAllowChange_ = self.keyboardTableRow_.CanChange[1] == nil or self.keyboardTableRow_.CanChange[1] == 1
  self.isPadAllowChange = self.keyboardTableRow_.CanChange[2] == nil or self.keyboardTableRow_.CanChange[2] == 1
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_tips, false)
  self:refreshKeyboardElements()
  self:refreshGamePadElements()
end

function SettingKeyLoopItem:refreshKeyboardElements()
  local keyBoardBindings = self.settingKeyCtx.keyBoardBindings
  local keyBoardBinder = self.uiBinder.binder_keyboard
  self:setBindingElement(keyBoardBinder, keyBoardBindings, self.isKeyboardAllowChange_)
end

function SettingKeyLoopItem:refreshGamePadElements()
  local gamePadBindings = self.settingKeyCtx.gamePadBindings
  local gamePadBinder = self.uiBinder.binder_handle
  self:setBindingElement(gamePadBinder, gamePadBindings, self.isPadAllowChange)
end

function SettingKeyLoopItem:setBindingElement(elementContainer, elementList, isAllowChange)
  self:setKeyContainerState(elementContainer.btn_key_binder_1, elementList[1])
  self:setKeyContainerState(elementContainer.btn_key_binder_2, elementList[2])
  local elementCnt = table.zcount(elementList)
  if elementCnt == 0 then
    elementContainer.Ref:SetVisible(elementContainer.btn_key_input_2, false)
    elementContainer.Ref:SetVisible(elementContainer.node_and, false)
    elementContainer.btn_key_binder_1.btn_key.IsDisabled = true
    elementContainer.btn_key_binder_1.lab_cur_key.text = Lang("NotSettable")
    elementContainer.btn_key_binder_1.btn_key:AddListener(function()
    end, true)
  elseif elementCnt == 1 then
    elementContainer.Ref:SetVisible(elementContainer.btn_key_input_2, false)
    elementContainer.Ref:SetVisible(elementContainer.node_and, false)
    elementContainer.btn_key_binder_1.btn_key.IsDisabled = not isAllowChange
    elementContainer.btn_key_binder_1.lab_cur_key.text = self.keyVM_.GetKeyDes(elementList[1])
    elementContainer.btn_key_binder_1.btn_key:AddListener(function()
      self:onKeyStartListerner(isAllowChange, elementContainer.btn_key_binder_1, elementList[1])
    end, true)
  elseif elementCnt == 2 then
    elementContainer.Ref:SetVisible(elementContainer.btn_key_input_2, true)
    elementContainer.Ref:SetVisible(elementContainer.node_and, true)
    elementContainer.btn_key_binder_1.btn_key.IsDisabled = not isAllowChange
    elementContainer.btn_key_binder_2.btn_key.IsDisabled = not isAllowChange
    elementContainer.btn_key_binder_1.lab_cur_key.text = self.keyVM_.GetKeyDes(elementList[1])
    elementContainer.btn_key_binder_2.lab_cur_key.text = self.keyVM_.GetKeyDes(elementList[2])
    elementContainer.btn_key_binder_1.btn_key:AddListener(function()
      self:onKeyStartListerner(isAllowChange, elementContainer.btn_key_binder_1, elementList[1])
    end, true)
    elementContainer.btn_key_binder_2.btn_key:AddListener(function()
      self:onKeyStartListerner(isAllowChange, elementContainer.btn_key_binder_2, elementList[2])
    end, true)
  else
    logError("[SettingKey] too many bindings " .. self.settingKeyCtx.setKeyboardTableRow.Id)
  end
end

function SettingKeyLoopItem:onKeyStartListerner(isAllowChange, btn_key_binder, element)
  if not isAllowChange then
    Z.TipsVM.ShowTipsLang(1000204)
    Z.InputMgr:StopListening()
    return
  else
    btn_key_binder.Ref:SetVisible(btn_key_binder.lab_cur_key, false)
    btn_key_binder.Ref:SetVisible(btn_key_binder.lab_input, true)
    local isListening = Z.InputMgr:IsListening(self.settingKeyCtx.setKeyboardTableRow.SchemeId, element.actionId, element.groupIndex, element.bindingIndex)
    if isListening then
      Z.InputMgr:StopListening()
      return
    end
    Z.InputMgr:StartListening(self.settingKeyCtx.setKeyboardTableRow.SchemeId, element.actionId, element.groupIndex, element.bindingIndex, function(detectedInputData)
      return not self.keyVM_.IsPresetKey(detectedInputData)
    end, function(conflictInfo)
      self.keyVM_.HandleKeyConflict(conflictInfo)
    end, function()
      self:onInputMappedOverCallback()
    end, function()
      btn_key_binder.Ref:SetVisible(btn_key_binder.lab_cur_key, true)
      btn_key_binder.Ref:SetVisible(btn_key_binder.lab_input, false)
    end, true)
    self:refreshKeyboardElements()
    self:refreshGamePadElements()
  end
end

function SettingKeyLoopItem:onInputMappedOverCallback()
  Z.TipsVM.ShowTipsLang(1000201)
  self.parentView_:RefreshAllItem()
  Z.EventMgr:Dispatch(Z.ConstValue.KeyHintOpenChange)
end

function SettingKeyLoopItem:setKeyContainerState(container, element)
  local isListening = false
  if element ~= nil then
    isListening = Z.InputMgr:IsListening(self.settingKeyCtx.setKeyboardTableRow.SchemeId, element.actionId, element.groupIndex, element.bindingIndex)
  end
  container.Ref:SetVisible(container.lab_cur_key, not isListening)
  container.Ref:SetVisible(container.lab_input, isListening)
end

function SettingKeyLoopItem:UnInit()
  Z.EventMgr:Remove(Z.ConstValue.Device.DeviceTypeChange, self.onDeviceChange, self)
end

return SettingKeyLoopItem
