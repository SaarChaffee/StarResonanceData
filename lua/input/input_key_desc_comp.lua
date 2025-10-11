local InputKeyDescComp = class("InputKeyDescComp")

function InputKeyDescComp:ctor(...)
end

function InputKeyDescComp:Init(keyId, keyUIBinder, labDesc, hideWhenNoKeyDesc, onlyShowFirstDesc)
  self:UnInit()
  self.keyId_ = keyId
  self.keyUIBinder_ = keyUIBinder
  self.labDesc_ = labDesc
  if hideWhenNoKeyDesc == nil then
    self.hideWhenNoKeyDesc_ = false
  else
    self.hideWhenNoKeyDesc_ = hideWhenNoKeyDesc
  end
  self.canVisible_ = true
  self.hasKeyDesc_ = false
  if onlyShowFirstDesc == nil then
    self.onlyShowFirstDesc_ = false
  else
    self.onlyShowFirstDesc_ = onlyShowFirstDesc
  end
  self:bindEvent()
  self:Refresh()
end

function InputKeyDescComp:SetOnRefreshCb(onRefreshCb)
  self.onRefreshCb = onRefreshCb
end

function InputKeyDescComp:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.KeyHintOpenChange, self.Refresh, self)
  Z.EventMgr:Add(Z.ConstValue.Device.DeviceTypeChange, self.Refresh, self)
  Z.EventMgr:Add(Z.ConstValue.KeySettingReset, self.Refresh, self)
end

function InputKeyDescComp:UnInit()
  Z.EventMgr:RemoveObjAll(self)
  self.keyId_ = nil
  self.keyUIBinder_ = nil
  self.labDesc_ = nil
  self.hideWhenNoKeyDesc_ = nil
  self.canVisible_ = nil
  self.hasKeyDesc_ = nil
  self.init_ = false
end

function InputKeyDescComp:SetVisible(visible)
  self.canVisible_ = visible ~= false
  if not self.keyUIBinder_ then
    return
  end
  if Z.ObjectIsNullOrEmpty(self.keyUIBinder_.Ref) or Z.ObjectIsNullOrEmpty(self.keyUIBinder_.Ref.UIComp) then
    logError("InputKeyDescComp: keyUIBinder_ Ref or UIComp is nil  keyId: " .. tostring(self.keyId_))
    return
  end
  if not Z.IsPCUI then
    self.keyUIBinder_.Ref.UIComp:SetVisible(false)
    return
  end
  local show = not self.canVisible_ or self.hasKeyDesc_ or not self.hideWhenNoKeyDesc_
  self.keyUIBinder_.Ref.UIComp:SetVisible(show)
end

function InputKeyDescComp:Refresh()
  local keyVM = Z.VMMgr.GetVM("setting_key")
  local keyCodeDesc = keyVM.GetKeyCodeDescListByKeyId(self.keyId_)
  if keyCodeDesc and 0 < #keyCodeDesc and keyCodeDesc[1] ~= "" then
    self.hasKeyDesc_ = true
  else
    self.hasKeyDesc_ = false
  end
  if self.keyUIBinder_ == nil then
    return
  end
  self:SetVisible(self.canVisible_)
  if not self.hasKeyDesc_ then
    self.keyUIBinder_.lab_key.text = self.labDesc_
    return
  end
  local mainuiVM = Z.VMMgr.GetVM("mainui")
  local keyCodeDescs = ""
  for i = 1, #keyCodeDesc do
    local keyCodeDesc = keyCodeDesc[i]
    if self.onlyShowFirstDesc_ and 1 < i then
      break
    end
    if 1 < i then
      keyCodeDescs = string.zconcat(keyCodeDescs, "|[", keyCodeDesc, "] ")
    else
      keyCodeDescs = string.zconcat(keyCodeDescs, "[", keyCodeDesc, "] ")
    end
  end
  if mainuiVM.IsShowKeyHint() or self.labDesc_ ~= "" then
    self.keyUIBinder_.lab_key.text = string.zconcat(keyCodeDescs, self.labDesc_)
  else
    self.keyUIBinder_.lab_key.text = self.labDesc_
  end
  if self.onRefreshCb then
    self.onRefreshCb()
  end
end

return InputKeyDescComp
