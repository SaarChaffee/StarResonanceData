local refreshKeyIconByKeyCode = function(keyUiBinder, keyCode)
  local contrastTbl = Z.TableMgr.GetTable("SetKeyboardContrastTableMgr")
  local row = contrastTbl.GetRow(keyCode)
  if row and keyUiBinder then
    if row.ShowType == 1 then
      keyUiBinder.Ref:SetVisible(keyUiBinder.img_icon, true)
      keyUiBinder.img_icon:SetImage(row.ImageWay)
      keyUiBinder.Ref:SetVisible(keyUiBinder.img_text_bg, false)
    else
      keyUiBinder.Ref:SetVisible(keyUiBinder.img_icon, false)
      keyUiBinder.Ref:SetVisible(keyUiBinder.img_text_bg, true)
      keyUiBinder.lab_key.text = row.Keyboard
    end
  end
end
local refreshKeyIconByKeyId = function(keyUiBinder, keyId)
  local keyVM = Z.VMMgr.GetVM("setting_key")
  local keyCode = keyVM.GetKeyCodeListByKeyId(keyId)[1]
  if keyCode then
    refreshKeyIconByKeyCode(keyUiBinder, keyCode)
  end
end
local bindKeySettingResetEvent = function(obj, keyUiBinder, keyId)
  Z.EventMgr:Add(Z.ConstValue.KeySettingReset, function(self)
    refreshKeyIconByKeyId(keyUiBinder, keyId)
  end, obj)
end
local bindKeyHintOpenChangeEvent = function(obj, keyContainer)
  Z.EventMgr:Add(Z.ConstValue.KeyHintOpenChange, function(self, isOpen)
    if keyContainer then
      keyContainer.Ref.UIComp:SetVisible(isOpen)
    end
  end, obj)
end
local initKeyIcon = function(obj, keyUiBinder, id)
  if not keyUiBinder then
    return
  end
  if not Z.IsPCUI then
    keyUiBinder.Ref.UIComp:SetVisible(false)
    return
  end
  local mainuiVM = Z.VMMgr.GetVM("mainui")
  keyUiBinder.Ref.UIComp:SetVisible(mainuiVM.IsShowKeyHint())
  refreshKeyIconByKeyId(keyUiBinder, id)
  Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.KeyHintOpenChange, obj)
  Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.KeySettingReset, obj)
  bindKeyHintOpenChangeEvent(obj, keyUiBinder)
  bindKeySettingResetEvent(obj, keyUiBinder, id)
end
local unInitKeyIcon = function(keyContainer, id)
  Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.KeyHintOpenChange, keyContainer)
  Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.KeySettingReset, keyContainer)
end
local ret = {InitKeyIcon = initKeyIcon, UnInitKeyIcon = unInitKeyIcon}
return ret
