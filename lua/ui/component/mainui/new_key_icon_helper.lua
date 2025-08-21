local refreshKeyIconByKeyCode = function(keyUiBinder, keyCodeDesc, labDesc, hideWhenNoKeyDesc)
  if keyUiBinder == nil then
    return
  end
  labDesc = labDesc or ""
  local mainuiVM = Z.VMMgr.GetVM("mainui")
  keyUiBinder.Ref.UIComp:SetVisible(true)
  if keyCodeDesc == nil or keyCodeDesc == "" then
    keyUiBinder.lab_key.text = labDesc
    if hideWhenNoKeyDesc then
      keyUiBinder.Ref.UIComp:SetVisible(false)
      return
    end
  elseif mainuiVM.IsShowKeyHint() or labDesc ~= "" then
    keyUiBinder.lab_key.text = string.zconcat("[", keyCodeDesc, "] ", labDesc)
  else
    keyUiBinder.lab_key.text = labDesc
  end
  keyUiBinder.Trans:SetWidth(keyUiBinder.lab_key.preferredWidth)
end
local refreshKeyIconByKeyId = function(keyUiBinder, keyId, labDesc, hideWhenNoKeyDesc)
  local keyVM = Z.VMMgr.GetVM("setting_key")
  keyUiBinder.Ref.UIComp:SetVisible(true)
  local keyCodeDesc = keyVM.GetKeyCodeDescListByKeyId(keyId)[1]
  refreshKeyIconByKeyCode(keyUiBinder, keyCodeDesc, labDesc, hideWhenNoKeyDesc)
end
local bindChangeEvent = function(obj, keyUiBinder, keyId, labDesc, hideWhenNoKeyDesc)
  Z.EventMgr:Add(Z.ConstValue.KeyHintOpenChange, function(self, isOpen)
    refreshKeyIconByKeyId(keyUiBinder, keyId, labDesc, hideWhenNoKeyDesc)
  end, obj)
  Z.EventMgr:Add(Z.ConstValue.Device.DeviceTypeChange, function(self, isOpen)
    refreshKeyIconByKeyId(keyUiBinder, keyId, labDesc, hideWhenNoKeyDesc)
  end, obj)
  Z.EventMgr:Add(Z.ConstValue.KeySettingReset, function(self)
    refreshKeyIconByKeyId(keyUiBinder, keyId, labDesc, hideWhenNoKeyDesc)
  end, obj)
end
local unInitKeyIcon = function(keyContainer)
  Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.KeyHintOpenChange, keyContainer)
  Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.KeySettingReset, keyContainer)
  Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.Device.DeviceTypeChange, keyContainer)
end
local initKeyIcon = function(obj, keyUiBinder, id, labDesc, hideWhenNoKeyDesc)
  if keyUiBinder == nil then
    return
  end
  if not Z.IsPCUI then
    keyUiBinder.Ref.UIComp:SetVisible(false)
    return
  end
  keyUiBinder.Ref.UIComp:SetVisible(true)
  refreshKeyIconByKeyId(keyUiBinder, id, labDesc, hideWhenNoKeyDesc)
  unInitKeyIcon(keyUiBinder)
  bindChangeEvent(obj, keyUiBinder, id, labDesc, hideWhenNoKeyDesc)
end
local ret = {
  InitKeyIcon = initKeyIcon,
  UnInitKeyIcon = unInitKeyIcon,
  RefreshKeyIconByKeyId = refreshKeyIconByKeyId
}
return ret
