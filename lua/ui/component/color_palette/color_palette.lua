local ColorPalette = class("ColorPalette")

function ColorPalette:ctor(parentView, itemHandler)
  self.view_ = parentView
  self.itemHandler_ = itemHandler
end

function ColorPalette:Init(paletteUIBinder, isPCUI)
  self.uiBinder = paletteUIBinder
  self.colorConfigRow_ = nil
  self.defaultColor_ = {
    h = 0,
    s = 0,
    v = 0
  }
  self.serverColor_ = {
    h = 0,
    s = 0,
    v = 0
  }
  self.onColorStartChange_ = nil
  self.onColorEndChange_ = nil
  self.onColorChange_ = nil
  self.curItemIndex_ = 0
  self.curHSV_ = {
    h = 0,
    s = 0,
    v = 0
  }
  self.unitNameList_ = {}
  self.isInteractable_ = true
  self.isForceHideBrightness_ = false
  self.curHMin_ = nil
  self.curHMax_ = nil
  self.curHCostData_ = nil
  self.isHSVValue_ = false
  self.colorItemList_ = {}
  self.modelAttr_ = nil
  self.showResetBtn_ = false
  self.openColorCopy_ = true
  self.isPCUI_ = isPCUI
  self:SetResetColorState(false)
  if self.uiBinder then
    self.uiBinder.btn_reset:AddListener(function()
      if self.resetFunc_ then
        self.resetFunc_()
      end
    end)
    if self.uiBinder.btn_copy then
      self.uiBinder.btn_copy:AddListener(function()
        if not self.openColorCopy_ then
          return
        end
        local faceData = Z.DataMgr.Get("face_data")
        faceData:SetCopyColorHtml(self.uiBinder.input_color.text)
        self.uiBinder.btn_stick.IsDisabled = false
        self.uiBinder.btn_stick.interactable = true
      end)
    end
    if self.uiBinder.btn_stick then
      self.uiBinder.btn_stick:AddListener(function()
        if not self.openColorCopy_ then
          return
        end
        local faceData = Z.DataMgr.Get("face_data")
        local colorHtml = faceData:GetCopyColorHtml()
        if not colorHtml or colorHtml == self.uiBinder.input_color.text then
          return
        end
        local colorRgb = Z.ColorHelper.Hex2Rgba(colorHtml)
        local newColor = Color.New(colorRgb.r / 255, colorRgb.g / 255, colorRgb.b / 255, 1)
        local h, s, v = Color.RGBToHSV(newColor)
        local hsv = {
          h = h,
          s = s,
          v = v
        }
        if not self:isColorVaild(hsv) then
          Z.TipsVM.ShowTipsLang(120015)
          return
        end
        if self.onColorStartChange_ then
          self.onColorStartChange_()
        end
        self:SetCopyColorHSV(hsv, true)
        local curHsv = hsv
        if self.isHSVValue_ then
          curHsv = self:getIntColor(hsv)
        end
        self:setHSV(curHsv)
        self.uiBinder.img_color_board:SetSelectColor(h, s, v)
        self:refreshSliderWithoutNotify(self.uiBinder.silder_hue, 1 - h)
      end)
      local faceData = Z.DataMgr.Get("face_data")
      local showStick = self.openColorCopy_ and faceData:GetCopyColorHtml() ~= nil
      self.uiBinder.btn_stick.IsDisabled = not showStick
      self.uiBinder.btn_stick.interactable = showStick
    end
    if self.uiBinder.input_color then
      self.uiBinder.input_color:AddEndEditListener(function(string)
        self:OnInputColorContent(string)
      end)
    end
  end
  Z.EventMgr:Add(Z.ConstValue.FashionColorUnlock, self.onFashionColorUnlock, self)
end

function ColorPalette:UnInit()
  Z.EventMgr:RemoveObjAll(self)
  self:SetPaletteInteractable(true)
  self:clearColorItemUnit()
  self.uiBinder = nil
  self.colorConfigRow_ = nil
  self.defaultColor_ = nil
  self.serverColor_ = nil
  self.onColorStartChange_ = nil
  self.onColorChange_ = nil
  self.resetFunc_ = nil
  self.curItemIndex_ = nil
  self.curHSV_ = nil
  self.unitNameList_ = nil
  self.isInteractable_ = nil
  self.isForceHideBrightness_ = nil
  self.curHMin_ = nil
  self.curHMax_ = nil
  self.curHCostData_ = nil
  self.isHSVValue_ = nil
  self.colorItemList_ = nil
  self.modelAttr_ = nil
  self.isPCUI_ = nil
end

function ColorPalette:GetCurItemIndex()
  return self.curItemIndex_
end

function ColorPalette:GetCurColorIndex()
  return self.curItemIndex_ - 1
end

function ColorPalette:SetDefaultColor(hsv, isHSVValue)
  self.defaultColor_ = table.zclone(hsv)
  self.isHSVValue_ = isHSVValue
end

function ColorPalette:SetServerColor(hsv, isHSVValue)
  self.serverColor_ = table.zclone(hsv)
  self.isHSVValue_ = isHSVValue
end

function ColorPalette:SetColorChangeCB(func)
  self.onColorChange_ = func
end

function ColorPalette:SetColorStartChangeCB(func)
  self.onColorStartChange_ = func
end

function ColorPalette:SetColorEndChangeCB(func)
  self.onColorEndChange_ = func
end

function ColorPalette:SetColorResetCB(func)
  self.resetFunc_ = func
end

function ColorPalette:SetResetBtn(isShow)
  self.showResetBtn_ = isShow
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_reset, isShow)
end

function ColorPalette:RefreshPaletteByColorGroupId(groupId, hideCopyColor)
  self.curItemIndex_ = 0
  self.colorConfigRow_ = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(groupId)
  if self.colorConfigRow_ then
    self:refreshPalette(hideCopyColor)
  end
end

function ColorPalette:GetColorConfigRow()
  return self.colorConfigRow_
end

function ColorPalette:SetModelAttr(modelAttr)
  self.modelAttr_ = modelAttr
end

function ColorPalette:setColorCopy(hideCopyColor)
  self.openColorCopy_ = not hideCopyColor and self.colorConfigRow_.Type == E.EHueModifiedMode.Board
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_top, self.openColorCopy_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, self.openColorCopy_)
end

function ColorPalette:SelectItemByHSVWithoutNotify(hsv)
  local itemIndex = self:getItemIndexByHSV(hsv)
  self.curItemIndex_ = itemIndex
  self:setHSV(hsv, false)
  if not self.colorConfigRow_ then
    return
  end
  if self.colorConfigRow_.Type == E.EHueModifiedMode.Board then
    self:refreshColorBoardSelect(hsv)
  else
    self:refreshColorItemSelect()
  end
end

function ColorPalette:ResetSelectHSVWithoutNotify()
  self:setHSV(self.serverColor_, true)
  self:RefreshColor(self.serverColor_)
end

function ColorPalette:SetPaletteInteractable(isInteractable)
  self.isInteractable_ = isInteractable
  for _, name in ipairs(self.unitNameList_) do
    local unit = self.view_.units[name]
    self:refreshItemInteractable(unit)
  end
  self:refreshItemInteractable(self.uiBinder.cont_none)
  self.uiBinder.slider_brightness.interactable = self.isInteractable_
  self.uiBinder.silder_saturation.interactable = self.isInteractable_
  self.uiBinder.silder_hue.interactable = true
  if self.isInteractable_ then
    self.uiBinder.layout_color:SetAllTogglesOff()
  end
end

function ColorPalette:ForceHideBrightness(isHide)
  self.isForceHideBrightness_ = isHide
  if isHide then
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_brightness, false)
  end
end

function ColorPalette:SetCopyColorHSV(hsv, lowValue)
  local color = self:GetRGBColor(hsv, lowValue)
  if self.uiBinder and self.uiBinder.img_colour then
    self.uiBinder.img_colour:SetColor(color)
  end
  if self.uiBinder and self.uiBinder.input_color then
    local html = Z.LuaBridge.ColorToHtmlStringRGB(color)
    self.uiBinder.input_color:SetTextWithoutNotify(html)
  end
end

function ColorPalette:GetRGBColor(hsv, lowValue)
  if hsv == nil then
    hsv = self.curHSV_
  end
  if self.isHSVValue_ and not lowValue then
    hsv = {
      h = hsv.h / 360,
      s = hsv.s / 100,
      v = hsv.v / 100
    }
  end
  local color = Color.HSVToRGB(hsv.h, hsv.s, hsv.v)
  return color
end

function ColorPalette:refreshPalette(hideCopyColor)
  if self.colorConfigRow_.Type == E.EHueModifiedMode.Board then
    self:refreshPaletteBoard()
  else
    self:refreshPaletteOption()
  end
  self:setColorCopy(hideCopyColor)
end

function ColorPalette:refreshPaletteOption()
  self:initSlider(self.uiBinder.slider_brightness, 100, 0)
  self:initSlider(self.uiBinder.silder_saturation, 100, 0)
  self:initSlider(self.uiBinder.silder_hue, 360, 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_color, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_saturation, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_brightness, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_hue, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_colour, false)
  if self.colorConfigRow_.IfValue == 1 then
    self:InitSliderFunc(self.uiBinder.slider_brightness, function(value)
      local curV = self:convertSliderValueToRealValue(value, self.colorConfigRow_.Value)
      self:setHSV({v = curV})
      self:refreshSliderValueText(self.uiBinder.lab_brightness, value)
    end, self.brightness_)
  end
  if self.colorConfigRow_.IfSaturation == 1 then
    self:InitSliderFunc(self.uiBinder.silder_saturation, function(value)
      local curS = self:convertSliderValueToRealValue(value, self.colorConfigRow_.Saturation)
      self:setHSV({s = curS})
      self:refreshSliderValueText(self.uiBinder.lab_saturation, value)
    end, self.saturation_)
  end
  if self.colorConfigRow_.Type == E.EHueModifiedMode.Slider then
    self:InitSliderFunc(self.uiBinder.silder_hue, function(value)
      self.uiBinder.layout_color:SetAllTogglesOff()
      self:setHSV({
        h = value / 360
      })
    end, self.hue_)
  end
  self.uiBinder.layout_color.AllowSwitchOff = true
  self:initNoneItem()
  self:clearColorItemUnit()
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncCreateColorItem()
  end)()
end

function ColorPalette:refreshPaletteBoard()
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_color, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_saturation, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_brightness, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_colour, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_hue, true)
  self.uiBinder.img_color_board:AddListener(function(colorS, colorV)
    local curS = colorS
    local curV = colorV
    if self.isHSVValue_ then
      curS = math.floor(colorS * 100 + 0.5)
      curV = math.floor(colorV * 100 + 0.5)
    end
    self:setHSV({s = curS, v = curV})
    self:SetCopyColorHSV()
  end)
  self.uiBinder.img_color_board:AddValueStartChangeListener(function()
    if self.onColorStartChange_ then
      self.onColorStartChange_()
    end
  end)
  self.uiBinder.img_color_board:AddValueEndChangeListener(function()
    if self.onColorEndChange_ then
      self.onColorEndChange_()
    end
  end)
  self:initSlider(self.uiBinder.silder_hue, 1, 0)
  self:InitSliderFunc(self.uiBinder.silder_hue, function(colorH)
    colorH = 1 - colorH
    local curH = colorH
    if self.isHSVValue_ then
      curH = math.floor(colorH * 360 + 0.5)
    end
    if self.resetState_ then
      local curS = self.defaultColor_.s
      local curV = self.defaultColor_.v
      if self.isHSVValue_ then
        curS = curS / 100
        curV = curV / 100
      end
      self.uiBinder.img_color_board:SetSelectColor(colorH, curS, curV)
      self:setHSV({
        h = curH,
        s = self.defaultColor_.s,
        v = self.defaultColor_.v
      })
    else
      self.uiBinder.img_color_board:SetSelectColorHValue(colorH)
      self:setHSV({h = curH})
    end
    self:SetCopyColorHSV()
  end, self.hue_)
end

function ColorPalette:refreshColorBoardSelect(hsv)
  if self.colorConfigRow_ then
    self.uiBinder.img_color_board:SetSelectColorGroupID(self.colorConfigRow_.Id)
  end
  if not hsv then
    return
  end
  local h = hsv.h
  local s = hsv.s
  local v = hsv.v
  if self.isHSVValue_ then
    h = hsv.h / 360
    s = hsv.s / 100
    v = hsv.v / 100
  end
  self:refreshSliderWithoutNotify(self.uiBinder.silder_hue, 1 - h)
  self.uiBinder.img_color_board:SetSelectColor(h, s, v)
  self:SetCopyColorHSV(hsv)
end

function ColorPalette:initSlider(sliderContainer, max, min)
  sliderContainer:ClearAll()
  sliderContainer.maxValue = max
  sliderContainer.minValue = min
  sliderContainer.value = min
end

function ColorPalette:initNoneItem()
  local container = self.uiBinder.cont_none
  if not container then
    return
  end
  container.tog_color:SetIsOnWithoutNotify(false)
  self.itemHandler_:SetColorItemIsOnWithoutNotify(container, 1, false)
  container.tog_color.interactable = self.isInteractable_
  container.tog_color.group = self.uiBinder.layout_color
  container.tog_color:AddListener(function(isOn)
    if isOn then
      self.curItemIndex_ = 1
      local faceVm = Z.VMMgr.GetVM("face")
      faceVm.RecordFaceEditorCommand(self.modelAttr_)
      self:setHSV(self.defaultColor_)
      faceVm.CacheFaceData()
    else
      self.curItemIndex_ = 0
    end
    self:refreshPaletteUIByColorItemIsOn(1, isOn)
  end)
  self.colorItemList_[1] = container.tog_color
end

function ColorPalette:asyncCreateColorItem()
  local itemAddress = self.itemHandler_:GetItemAddress()
  for configIndex = 1, #self.colorConfigRow_.Hue do
    local itemIndex = configIndex + 1
    local unitName = "color" .. itemIndex
    local unit = self.view_:AsyncLoadUiUnit(itemAddress, unitName, self.uiBinder.layout_color_ref)
    if not unit then
      return
    end
    table.insert(self.unitNameList_, unitName)
    local iconColor = self.colorConfigRow_.UiColor[configIndex]
    self.itemHandler_:SetColor(unit, Color.HSVToRGB(iconColor[2] / 360, iconColor[3] / 100, iconColor[4] / 100))
    self.itemHandler_:SetColorItemIsOnWithoutNotify(unit, itemIndex, false)
    local isUnlocked = self.itemHandler_:GetColorItemIsUnlocked(itemIndex)
    self.itemHandler_:SetColorItemIsUnlocked(unit, isUnlocked)
    local widget = self.itemHandler_:GetToggleWidget(unit)
    widget.interactable = self.isInteractable_
    widget.group = self.uiBinder.layout_color
    local configHSV = self:getConfigHSVByConfigIndex(configIndex)
    widget:AddListener(function(isOn)
      if isOn then
        self.curItemIndex_ = itemIndex
        local faceVm = Z.VMMgr.GetVM("face")
        faceVm.RecordFaceEditorCommand(self.modelAttr_)
        self:setHSV(configHSV)
        faceVm.CacheFaceData()
      else
        self.curItemIndex_ = 0
      end
      self:refreshPaletteUIByColorItemIsOn(itemIndex, isOn)
    end)
    self.colorItemList_[itemIndex] = widget
  end
  local isAllowOff = self.uiBinder.cont_none == nil or self.colorConfigRow_.Type == E.EHueModifiedMode.Slider
  self.uiBinder.layout_color.AllowSwitchOff = isAllowOff
  self:refreshColorItemSelect()
end

function ColorPalette:RefreshColor(color)
  if not self.colorConfigRow_ then
    return
  end
  if self.colorConfigRow_.Type == E.EHueModifiedMode.Option then
    self:refreshColorIndex(color)
  elseif self.colorConfigRow_.Type == E.EHueModifiedMode.Slider then
    self:refreshColorSlider(color)
  else
    self:refreshColorBoardSelect(color)
  end
end

function ColorPalette:refreshColorIndex(color)
  if not self.colorItemList_ or #self.colorItemList_ == 0 then
    return
  end
  local index = self:getItemIndexByHSV(color)
  if index == 0 then
    index = 1
  end
  if self.colorItemList_ then
    self.colorItemList_[index]:SetIsOnWithoutCallBack(true)
    self:refreshPaletteUIByColorItemIsOn(index, true)
  end
end

function ColorPalette:refreshColorSlider(color)
  if not self.colorConfigRow_ then
    return
  end
  if self.colorConfigRow_.IfValue == 1 then
    local showV = self:convertRealValueToSliderValue(color.v, self.colorConfigRow_.Value)
    self:refreshSliderWithoutNotify(self.uiBinder.slider_brightness, showV)
    self:refreshSliderValueText(self.uiBinder.lab_brightness, showV)
  end
  if self.colorConfigRow_.IfSaturation == 1 then
    local showS = self:convertRealValueToSliderValue(color.s, self.colorConfigRow_.Saturation)
    self:refreshSliderWithoutNotify(self.uiBinder.silder_saturation, showS)
    self:refreshSliderValueText(self.uiBinder.lab_saturation, showS)
  end
end

function ColorPalette:refreshColorItemSelect()
  local index = self.curItemIndex_
  self.uiBinder.layout_color:SetAllTogglesOff()
  self.curItemIndex_ = index
  self:refreshPaletteUIByColorItemIsOn(index, true)
end

function ColorPalette:refreshPaletteUIByColorItemIsOn(itemIndex, isOn)
  local container = self:getColorItemByItemIndex(itemIndex)
  if container then
    self.itemHandler_:SetColorItemIsOnWithoutNotify(container, itemIndex, isOn and self.isInteractable_)
  end
  if itemIndex ~= 1 and self.colorConfigRow_ then
    if self.colorConfigRow_.IfSaturation == 1 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.cont_saturation, true)
    end
    if self.colorConfigRow_.IfValue == 1 and not self.isForceHideBrightness_ then
      self.uiBinder.Ref:SetVisible(self.uiBinder.cont_brightness, true)
    end
    if self.colorConfigRow_.Type == E.EHueModifiedMode.Slider then
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_hue, true)
    end
    if isOn then
      self:refreshSliderWithoutNotify(self.uiBinder.silder_hue, self.curHSV_.h * 360)
      local showS = self:convertRealValueToSliderValue(self.curHSV_.s, self.colorConfigRow_.Saturation)
      self:refreshSliderWithoutNotify(self.uiBinder.silder_saturation, showS)
      self:refreshSliderValueText(self.uiBinder.lab_saturation, showS)
      local minS, maxS = self:getConfigMinAndMaxValueByItemIndex(self.colorConfigRow_.Saturation, itemIndex)
      self.uiBinder.silder_saturation.interactable = self.isInteractable_ and minS < maxS
      local showV = self:convertRealValueToSliderValue(self.curHSV_.v, self.colorConfigRow_.Value)
      self:refreshSliderWithoutNotify(self.uiBinder.slider_brightness, showV)
      self:refreshSliderValueText(self.uiBinder.lab_brightness, showV)
      local minV, maxV = self:getConfigMinAndMaxValueByItemIndex(self.colorConfigRow_.Value, itemIndex)
      self.uiBinder.slider_brightness.interactable = self.isInteractable_ and minV < maxV
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_saturation, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_brightness, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_hue, false)
  end
end

function ColorPalette:setHSV(value, isNotify)
  for k, v in pairs(value) do
    self.curHSV_[k] = v
  end
  if isNotify == nil then
    isNotify = true
  end
  if self.onColorChange_ and isNotify then
    self.onColorChange_({
      h = self.curHSV_.h,
      s = self.curHSV_.s,
      v = self.curHSV_.v
    })
  end
end

function ColorPalette:convertSliderValueToRealValue(value, configArray)
  if self.curItemIndex_ == 1 then
    return 0
  end
  local ratio = value / 100
  local min, max = self:getConfigMinAndMaxValueByItemIndex(configArray, self.curItemIndex_)
  return (min + (max - min) * ratio) / 100
end

function ColorPalette:convertRealValueToSliderValue(value, configArray)
  if self.curItemIndex_ == 1 then
    return 0
  end
  local min, max = self:getConfigMinAndMaxValueByItemIndex(configArray, self.curItemIndex_)
  local ratio = max ~= min and (value * 100 - min) / (max - min) or 0
  return ratio * 100
end

function ColorPalette:getConfigMinAndMaxValueByItemIndex(configArray, itemIndex)
  local min, max
  if self.colorConfigRow_.Type == E.EHueModifiedMode.Slider then
    min = configArray[1][2]
    max = configArray[1][3]
  else
    local configIndex = itemIndex - 1
    if 0 < configIndex then
      min = configArray[configIndex][3]
      max = configArray[configIndex][4]
    else
      min = 0
      max = 100
    end
  end
  return min, max
end

function ColorPalette:getConfigHSVByConfigIndex(configIndex)
  local h = self.colorConfigRow_.Hue[configIndex][2] / 360
  local s, v
  if self.colorConfigRow_.Type == E.EHueModifiedMode.Slider then
    s = nil
    v = nil
  else
    s = self.colorConfigRow_.Saturation[configIndex][2] / 100
    v = self.colorConfigRow_.Value[configIndex][2] / 100
  end
  return {
    h = h,
    s = s,
    v = v
  }
end

function ColorPalette:refreshSliderWithoutNotify(sliderContainer, value)
  sliderContainer:SetValueWithoutNotify(value)
end

function ColorPalette:refreshSliderValueText(sliderLab, value)
  sliderLab.text = string.format("%d", math.floor(value + 0.5))
end

function ColorPalette:getItemIndexByHSV(hsv)
  if math.abs(self.defaultColor_.h - hsv.h) < 1.0E-4 and 1.0E-4 > math.abs(self.defaultColor_.s - hsv.s) and 1.0E-4 > math.abs(self.defaultColor_.v - hsv.v) then
    return 1
  else
    if self.colorConfigRow_.Type == E.EHueModifiedMode.Board then
      return 1
    end
    for configIndex, hData in pairs(self.colorConfigRow_.Hue) do
      local h = hData[2] / 360
      if math.abs(h - hsv.h) < 1.0E-4 then
        return configIndex + 1
      end
    end
    return 0
  end
end

function ColorPalette:refreshItemInteractable(colorItem)
  if not colorItem then
    return
  end
  colorItem.tog_color.interactable = self.isInteractable_
end

function ColorPalette:clearColorItemUnit()
  for _, name in ipairs(self.unitNameList_) do
    self.view_:RemoveUiUnit(name)
  end
  self.unitNameList_ = {}
end

function ColorPalette:getColorItemByItemIndex(itemIndex)
  local container
  if 1 < itemIndex then
    container = self.view_.units["color" .. itemIndex]
  elseif itemIndex == 1 then
    container = self.uiBinder.cont_none
  end
  return container
end

function ColorPalette:onFashionColorUnlock(fashionId, colorIndex)
  local container = self:getColorItemByItemIndex(colorIndex + 1)
  if container then
    self.itemHandler_:SetColorItemIsUnlocked(container, true)
  end
end

function ColorPalette:InitSliderFunc(slider, clickFunc, isDrag)
  slider:AddListener(function(value)
    if not isDrag then
      if self.onColorStartChange_ then
        self.onColorStartChange_()
      end
      isDrag = true
    end
    clickFunc(value)
  end)
  slider:AddDragEndListener(function(value)
    isDrag = false
    if self.onColorEndChange_ then
      self.onColorEndChange_()
    end
  end)
end

function ColorPalette:isColorVaild(hsv)
  if not self.colorConfigRow_ or self.colorConfigRow_.Type ~= E.EHueModifiedMode.Board then
    return
  end
  local s = math.floor(hsv.s * 100 + 0.5)
  local v = math.floor(hsv.v * 100 + 0.5)
  return self.uiBinder.img_color_board:IsColorVaild(s, v)
end

function ColorPalette:getIntColor(hsv)
  local h = math.floor(hsv.h * 360 + 0.5)
  local s = math.floor(hsv.s * 100 + 0.5)
  local v = math.floor(hsv.v * 100 + 0.5)
  return {
    h = h,
    s = s,
    v = v
  }
end

function ColorPalette:SetResetColorState(isReset)
  self.resetState_ = isReset
  if self.uiBinder.btn_copy then
    self.uiBinder.btn_copy.IsDisabled = isReset
    self.uiBinder.btn_copy.interactable = not isReset
  end
  if self.uiBinder.btn_stick then
    local faceData = Z.DataMgr.Get("face_data")
    local colorHtml = faceData:GetCopyColorHtml()
    if colorHtml then
      self.uiBinder.btn_stick.IsDisabled = false
      self.uiBinder.btn_stick.interactable = true
    else
      self.uiBinder.btn_stick.IsDisabled = isReset
      self.uiBinder.btn_stick.interactable = not isReset
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_input, not isReset)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_input_empty, isReset)
  if isReset then
    local h = 0
    if self.defaultColor_ then
      h = self.defaultColor_.h / 360
    end
    self:refreshSliderWithoutNotify(self.uiBinder.silder_hue, 1 - h)
    self.uiBinder.img_color_board:SetSelectColor(h, 0, 0)
    self.uiBinder.img_dot:SetGray()
  else
    self.uiBinder.img_dot:ClearGray()
  end
end

function ColorPalette:OnInputColorContent(string)
  local colorRgb = Z.ColorHelper.Hex2Rgba(string)
  if not colorRgb then
    return
  end
  local newColor = Color.New(colorRgb.r / 255, colorRgb.g / 255, colorRgb.b / 255, 1)
  local h, s, v = Color.RGBToHSV(newColor)
  local hsv = {
    h = h,
    s = s,
    v = v
  }
  if not self:isColorVaild(hsv) then
    Z.TipsVM.ShowTipsLang(120015)
    return
  end
  local curHsv = hsv
  if self.isHSVValue_ then
    curHsv = self:getIntColor(hsv)
  end
  self:setHSV(curHsv)
  if self.uiBinder and self.uiBinder.img_colour then
    self.uiBinder.img_colour:SetColor(newColor)
  end
  self.uiBinder.img_color_board:SetSelectColor(h, s, v)
  self:refreshSliderWithoutNotify(self.uiBinder.silder_hue, 1 - h)
end

return ColorPalette
