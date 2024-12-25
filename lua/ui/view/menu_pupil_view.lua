local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_pupilView = class("Menu_pupilView", super)
local eLR = {Left = 1, Right = 2}
local AREA_NUM = 4
local FULL_AREA_COLOR_GROUP = 7

function Menu_pupilView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_pupil_sub", "face/face_menu_pupil_sub", UI.ECacheLv.None)
  self.styleAttr_ = Z.ModelAttr.EModelHeadTexEye_d
  self.colorAttrList_ = {
    [1] = Z.ModelAttr.EModelLEyeArrColor,
    [2] = Z.ModelAttr.EModelREyeArrColor
  }
  self.isHideResetBtn_ = true
end

function Menu_pupilView:OnActive()
  super.OnActive(self)
  self.curLR_ = eLR.Left
  self.curArea_ = 1
  self.uiBinder.tog_left.group = self.uiBinder.togs_left_right
  self.uiBinder.tog_right.group = self.uiBinder.togs_left_right
  for i = 1, AREA_NUM do
    self.uiBinder["tog_area" .. i].group = self.uiBinder.togs_area
  end
  self.uiBinder.tog_open_diff:AddListener(function(isOn)
    self.faceVM_.RecordFaceEditorCommand(self.styleAttr_)
    self.faceData_:SetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilIsDiff"), isOn)
    self.faceVM_.SetAssociatedFaceOption(Z.PbEnum("EFaceDataType", "PupilIsDiff"), isOn, true)
    self.uiBinder.tog_left.interactable = isOn
    self.uiBinder.tog_right.interactable = isOn
    self.uiBinder.togs_left_right.AllowSwitchOff = not isOn
    if isOn then
      self.uiBinder.tog_left.isOn = true
    else
      self.uiBinder.togs_left_right:SetAllTogglesOff()
      self.curLR_ = eLR.Left
      self:refreshColorItemSelect()
    end
  end)
  self.uiBinder.tog_left:AddListener(function(isOn)
    if isOn then
      self.curLR_ = eLR.Left
      self.colorAttr_ = Z.ModelAttr.EModelLEyeArrColor
      self:refreshColorItemSelect()
    end
  end)
  self.uiBinder.tog_right:AddListener(function(isOn)
    if isOn then
      self.curLR_ = eLR.Right
      self.colorAttr_ = Z.ModelAttr.EModelREyeArrColor
      self:refreshColorItemSelect()
    end
  end)
  self.uiBinder.tog_open_area:AddListener(function(isOn)
    self.faceVM_.RecordFaceEditorListCommand({
      [1] = Z.ModelAttr.EModelLEyeArrColor,
      [2] = Z.ModelAttr.EModelREyeArrColor
    })
    self.faceData_:SetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilIsArea"), isOn)
    self.faceVM_.SetAssociatedFaceOption(Z.PbEnum("EFaceDataType", "PupilIsArea"), isOn, true)
    for i = 1, AREA_NUM do
      self.uiBinder["tog_area" .. i].interactable = isOn
    end
    self:switchColorPalette(isOn)
    self.uiBinder.togs_area.AllowSwitchOff = not isOn
    if isOn then
      self.uiBinder.tog_area1.isOn = true
    else
      self.uiBinder.togs_area:SetAllTogglesOff()
      self.curArea_ = 1
      self.colorAttrIndex_ = 1
      self:refreshColorItemSelect()
    end
  end)
  for i = 1, AREA_NUM do
    self.uiBinder["tog_area" .. i]:AddListener(function(isOn)
      if isOn then
        self.curArea_ = i
        self.colorAttrIndex_ = i
        self:refreshColorItemSelect()
      end
    end)
  end
  self:refreshPupilTog()
end

function Menu_pupilView:clearTog()
  self.uiBinder.tog_open_diff:RemoveAllListeners()
  self.uiBinder.tog_open_diff.isOn = false
  self.uiBinder.tog_left:RemoveAllListeners()
  self.uiBinder.tog_left.group = nil
  self.uiBinder.tog_left.isOn = false
  self.uiBinder.tog_right:RemoveAllListeners()
  self.uiBinder.tog_right.group = nil
  self.uiBinder.tog_right.isOn = false
  self.uiBinder.tog_open_area:RemoveAllListeners()
  self.uiBinder.tog_open_area.isOn = false
  for i = 1, AREA_NUM do
    self.uiBinder["tog_area" .. i]:RemoveAllListeners()
    self.uiBinder["tog_area" .. i].group = nil
    self.uiBinder["tog_area" .. i].isOn = false
  end
end

function Menu_pupilView:OnDeActive()
  self:clearTog()
  super.OnDeActive(self)
end

function Menu_pupilView:OnColorChange(hsv)
  local isDiff = self.faceData_:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilIsDiff"))
  local isArea = self.faceData_:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilIsArea"))
  if not isArea then
    local offset = hsv.v
    if isDiff then
      if self.curLR_ == eLR.Left then
        self.faceVM_.SetPupilOffsetV(Z.ModelAttr.EModelLEyeArrColor, offset)
      else
        self.faceVM_.SetPupilOffsetV(Z.ModelAttr.EModelREyeArrColor, offset)
      end
    else
      self.faceVM_.SetPupilOffsetV(Z.ModelAttr.EModelLEyeArrColor, offset)
      self.faceVM_.SetPupilOffsetV(Z.ModelAttr.EModelREyeArrColor, offset)
    end
    hsv.v = nil
  end
  if self.curLR_ == eLR.Left then
    self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelLEyeArrColor, hsv, self.curArea_)
  else
    self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelREyeArrColor, hsv, self.curArea_)
  end
end

function Menu_pupilView:refreshColorItemSelect()
  local hsv = self:getCurHSVByLRAndArea()
  hsv.v = hsv.v - self.initHSV_.v
  self.colorPalette_:SelectItemByHSVWithoutNotify(hsv)
end

function Menu_pupilView:getCurHSVByLRAndArea()
  local hsv
  if self.curLR_ == eLR.Left then
    hsv = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelLEyeArrColor, self.curArea_)
  else
    hsv = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelREyeArrColor, self.curArea_)
  end
  return hsv
end

function Menu_pupilView:switchColorPalette(isArea)
  if not isArea then
    self.colorPalette_:RefreshPaletteByColorGroupId(FULL_AREA_COLOR_GROUP, true)
    self.colorPalette_:SetDefaultColor({
      h = self.initHSV_.h,
      s = self.initHSV_.s,
      v = 0
    })
  else
    self.colorPalette_:RefreshPaletteByColorGroupId(self.areaColorGroupId_, true)
    self.colorPalette_:SetDefaultColor(self.initHSV_)
  end
end

function Menu_pupilView:refreshFaceMenuView()
  super.refreshFaceMenuView(self)
  self:refreshPupilTog()
end

function Menu_pupilView:refreshPupilTog()
  local isDiff = self.faceData_:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilIsDiff"))
  local isArea = self.faceData_:GetFaceOptionValue(Z.PbEnum("EFaceDataType", "PupilIsArea"))
  self.uiBinder.togs_left_right.AllowSwitchOff = not isDiff
  self.uiBinder.togs_area.AllowSwitchOff = not isArea
  local colorData = self.faceMenuVM_.GetFaceColorDataByOptionEnum(Z.PbEnum("EFaceDataType", "PupilLeftColor0"))
  self.areaColorGroupId_ = colorData.GroupId
  self.initHSV_ = colorData.HSV
  self:switchColorPalette(isArea)
  self:refreshColorItemSelect()
  self.uiBinder.tog_open_diff.isOn = isDiff
  self.uiBinder.tog_open_area.isOn = isArea
  self.uiBinder.tog_left.interactable = isDiff
  self.uiBinder.tog_right.interactable = isDiff
  for i = 1, AREA_NUM do
    self.uiBinder["tog_area" .. i].interactable = isArea
  end
  if isDiff then
    self.uiBinder.tog_left.isOn = true
    self.colorAttr_ = Z.ModelAttr.EModelLEyeArrColor
  else
    self.uiBinder.tog_left.isOn = false
    self.uiBinder.tog_right.isOn = false
    self.colorAttr_ = nil
  end
  if isArea then
    self.uiBinder.tog_area1.isOn = true
  else
    self.colorAttrIndex_ = 1
  end
end

function Menu_pupilView:IsAllowColorCopy()
  return false
end

return Menu_pupilView
