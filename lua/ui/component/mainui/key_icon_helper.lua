local refreshKeyIconByKeyCode = function(keyContainer, keyCode)
  local contrastTbl = Z.TableMgr.GetTable("SetKeyboardContrastTableMgr")
  local row = contrastTbl.GetRow(keyCode)
  if row and keyContainer then
    if row.ShowType == 1 then
      if keyContainer.img_icon then
        keyContainer.img_icon:SetVisible(true)
        if keyContainer.img_icon.Img then
          keyContainer.img_icon.Img:SetImage(row.ImageWay)
        end
      end
      if keyContainer.img_text_bg then
        keyContainer.img_text_bg:SetVisible(false)
      end
    else
      if keyContainer.img_icon then
        keyContainer.img_icon:SetVisible(false)
      end
      if keyContainer.img_text_bg then
        keyContainer.img_text_bg:SetVisible(true)
      end
      if keyContainer.lab_key and keyContainer.lab_key.TMPLab then
        keyContainer.lab_key.TMPLab.text = row.Keyboard
      end
    end
  end
end
local refreshKeyIconByKeyId = function(keyContainer, keyId)
  local keyVM = Z.VMMgr.GetVM("setting_key")
  local keyCode = keyVM.GetKeyCodeListByKeyId(keyId)[1]
  if keyCode then
    refreshKeyIconByKeyCode(keyContainer, keyCode)
  end
end
local bindKeySettingResetEvent = function(obj, keyContainer, keyId)
  Z.EventMgr:Add(Z.ConstValue.KeySettingReset, function(self)
    refreshKeyIconByKeyId(keyContainer, keyId)
  end, obj)
end
local bindKeyHintOpenChangeEvent = function(obj, keyContainer)
  Z.EventMgr:Add(Z.ConstValue.KeyHintOpenChange, function(self, isOpen)
    if keyContainer then
      keyContainer:SetVisible(isOpen)
    end
  end, obj)
end
local initKeyIcon = function(parentView, keyContainer, id)
  if not keyContainer then
    return
  end
  if not Z.IsPCUI then
    keyContainer:SetVisible(false)
    return
  end
  local mainuiVM = Z.VMMgr.GetVM("mainui")
  keyContainer:SetVisible(mainuiVM.IsShowKeyHint())
  refreshKeyIconByKeyId(keyContainer, id)
  Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.KeyHintOpenChange, parentView)
  Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.KeySettingReset, parentView)
  bindKeyHintOpenChangeEvent(parentView, keyContainer)
  bindKeySettingResetEvent(parentView, keyContainer, id)
end
local unInitKeyIcon = function(keyContainer, id)
  Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.KeyHintOpenChange, keyContainer)
  Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.KeySettingReset, keyContainer)
end
local ret = {InitKeyIcon = initKeyIcon, UnInitKeyIcon = unInitKeyIcon}
return ret
