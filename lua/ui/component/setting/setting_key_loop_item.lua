local SettingKeyLoopItem = class("SettingKeyLoopItem", super)

function SettingKeyLoopItem:ctor()
end

function SettingKeyLoopItem:Init(parentView, keyboardTableRow, unit)
  self.parentView_ = parentView
  self.uiBinder = unit
  self.keyboardTableRow_ = keyboardTableRow
  self.keyVM_ = Z.VMMgr.GetVM("setting_key")
  self:refresh()
end

function SettingKeyLoopItem:refresh()
  self.keyId_ = self.keyboardTableRow_.Id
  if self.keyboardTableRow_ then
    self.uiBinder.lab_desc.text = self.keyboardTableRow_.SetDes
  else
    self.uiBinder.lab_desc.text = ""
    return
  end
  self.isAllowChange_ = self:getKeyIsAllowSwitch()
  self.curSlotIdx_ = 0
  self:refreshKeyboardElements()
end

function SettingKeyLoopItem:refreshKeyboardElements()
  self:hideElementContainers()
  self:setActionElementMpas()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_tips, false)
  if self.showElements_ == nil then
    logError(self.keyboardTableRow_.SetDes .. " \230\156\170\233\133\141\231\189\174ActionElementMap")
    return
  end
  local keyNum = table.zcount(self.showElements_)
  for i = 1, 2 do
    local container = self.uiBinder["cont_key_custom" .. i]
    if i <= keyNum then
      self.uiBinder.Ref:SetVisible(container.Ref, true)
      container.lab_key.text = self.keyVM_.GetKeyDes(self.showElements_[i])
      container.Ref:SetVisible(container.img_key_bg, self.isAllowChange_)
      self:setKeyContainerState(container, false)
      container.btn_key:AddListener(function()
        self:onKeyStartListerner(container, i)
      end)
    end
  end
end

function SettingKeyLoopItem:setActionElementMpas()
  self.inputActions_ = self.keyVM_.GetActionsByKeyId(self.keyId_)
  if self.inputActions_ == nil or #self.inputActions_ < 1 then
    return
  end
  local allElements = {}
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  local row = keyTbl.GetRow(self.keyId_)
  if row == nil then
    return
  end
  local mapId = row.MapCategoryId
  for _, inputAction in ipairs(self.inputActions_) do
    local element = self.keyVM_.GetFirstElementMapWithActionId(inputAction.id, mapId)
    if element then
      table.insert(allElements, element)
    end
  end
  if allElements == nil then
    return
  end
  self.showElements_ = allElements
end

function SettingKeyLoopItem:hideElementContainers()
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_key_custom1.Ref, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_key_custom2.Ref, false)
end

function SettingKeyLoopItem:setKeyContainerState(container, isInput)
  container.Ref:SetVisible(container.node_normal, not isInput)
  container.Ref:SetVisible(container.img_input_frame, isInput)
end

function SettingKeyLoopItem:getKeyIsAllowSwitch()
  if self.keyboardTableRow_.ShowSwitch == 0 then
    return true
  end
  return false
end

function SettingKeyLoopItem:onKeyStartListerner(container, slotIdx)
  if not self.isAllowChange_ then
    Z.TipsVM.ShowTipsLang(1000204)
  else
    self.curSlotIdx_ = slotIdx
    self.uiBinder.node_inputcheck:StartCheck()
    self:setKeyContainerState(container, true)
    Z.InputMgr:StartMapListening(self.inputActions_[slotIdx].id, self.showElements_[slotIdx], function(data)
      local ret = self.keyVM_.IsPresetKey(data)
      return ret
    end, function(conflictActionIds)
      self.parentView_.ConflictActionIds = conflictActionIds
      local ret = self.keyVM_.HandleKeyConflict()
    end, function(actionElementMap)
      self:onInputMappedOverCallback(actionElementMap)
    end, function()
      self.parentView_.ConflictActionIds = nil
      self:refreshKeyboardElements()
    end)
  end
end

function SettingKeyLoopItem:onInputMappedOverCallback(actionElementMap)
  Z.TipsVM.ShowTipsLang(1000201)
  Z.InputMgr:ReBindActionByActionElementMap(actionElementMap)
  self.parentView_:RefreshAllItem()
  Z.EventMgr:Dispatch(Z.ConstValue.KeySettingReset, self.keyId_)
  Z.InputMgr:Save()
end

function SettingKeyLoopItem:UnInit()
  if self.uiBinder == nil then
    return
  end
  self.uiBinder.cont_key_custom1.btn_key:RemoveAllListeners()
  self.uiBinder.cont_key_custom2.btn_key:RemoveAllListeners()
  self.parentView_.ConflictActionIds = nil
  self.parentView_ = nil
end

return SettingKeyLoopItem
