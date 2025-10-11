local InputActionItem = class("InputActionItem")

function InputActionItem:ctor()
  self.keyboardRow_ = nil
  self.switchVM_ = Z.VMMgr.GetVM("switch")
  self.mainUiVm_ = Z.VMMgr.GetVM("mainui")
  
  function self.onInputAction_(inputActionEventData)
    self:triggerAction(inputActionEventData)
  end
end

function InputActionItem:Init(keyboardRow)
  if keyboardRow == nil then
    logError("keyboardRow is nil")
    return
  end
  self.enable_ = true
  self.isRegister_ = false
  self.keyboardRow_ = keyboardRow
  self:registerAction()
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.onFunctionChange, self)
end

function InputActionItem:UnInit()
  Z.EventMgr:RemoveObjAll(self)
  self:unRegisterAction()
  self.keyboardRow_ = nil
  self.actionCallback_ = nil
  self.enable_ = true
  self.isRegister_ = false
  self.actionIds_ = nil
end

function InputActionItem:Enable(enable)
  self.enable_ = enable
end

function InputActionItem:SetActionCallback(func)
  self.actionCallback_ = func
end

function InputActionItem:onFunctionChange(funcTable)
  local funcId = self.keyboardRow_.FunctionId
  if funcId ~= nil and funcId ~= 0 then
    local isOpen = self.switchVM_.CheckFuncSwitch(funcId)
    if isOpen == false and self.isRegister_ then
      self:unRegisterAction()
      return
    end
    if isOpen and not self.isRegister_ then
      self:registerAction()
      return
    end
  end
end

function InputActionItem:registerAction()
  if self.isRegister_ then
    return
  end
  local funcId = self.keyboardRow_.FunctionId
  if funcId == nil or funcId == 0 then
    return
  end
  if not self.switchVM_.CheckFuncSwitch(funcId) then
    return
  end
  self.isRegister_ = true
  self.actionIds_ = self.keyboardRow_.ActionIds
  if self.actionIds_ == nil then
    return
  end
  for i = 1, #self.actionIds_ do
    local actionId = self.actionIds_[i][1]
    local inputType = Z.InputActionEventType.ButtonJustPressed
    if self.actionIds_[i][2] then
      inputType = Z.InputActionEventType.IntToEnum(self.actionIds_[i][2])
    end
    Z.InputLuaBridge:AddInputEventDelegateWithActionId(self.onInputAction_, inputType, actionId)
  end
end

function InputActionItem:unRegisterAction()
  if not self.isRegister_ then
    return
  end
  self.isRegister_ = false
  if self.actionIds_ == nil then
    return
  end
  for i = 1, #self.actionIds_ do
    local actionId = self.actionIds_[i][1]
    local inputType = Z.InputActionEventType.ButtonJustPressed
    if self.actionIds_[i][2] then
      inputType = Z.InputActionEventType.IntToEnum(self.actionIds_[i][2])
    end
    Z.InputLuaBridge:RemoveInputEventDelegateWithActionId(self.onInputAction_, inputType, actionId)
  end
end

function InputActionItem:triggerAction(inputActionEventData)
  if not self.enable_ then
    return
  end
  if self.actionCallback_ then
    self.actionCallback_()
    return
  end
  if self.keyboardRow_ then
    local funcId = self.keyboardRow_.FunctionId
    if funcId and funcId ~= 0 then
      self:triggerFunc(inputActionEventData.ActionId, funcId)
    end
  else
    logError("keyboardRow is nil ")
  end
end

function InputActionItem:triggerFunc(actionId, funcId)
  if not Z.UIMgr:CheckMainUIActionLimit(actionId) then
    return
  end
  self.mainUiVm_.GotoMainUIFunc(funcId)
end

return InputActionItem
