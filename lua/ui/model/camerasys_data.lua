local super = require("ui.model.data_base")
local CamerasysData = class("CamerasysData", super)

function CamerasysData:ctor()
  super.ctor(self)
  self.TopTagIndex = 1
  self.ActionTagIndex = 1
  self.DecorateTagIndex = 1
  self.SettingTagIndex = 1
  self.DecorateFrameCfg = {}
  self.DecorateStickerCfg = {}
  self.DecorateTextCfg = {}
  self.FilterCfg = {}
  self.UnionBgCfg = {}
  self.ColorPaletteColor = Color.New(1, 1, 1, 1)
  self.MenuContainerActionDirty = false
  self.MenuContainerFilterDirty = false
  self.MenuContainerFrameDirty = false
  self.MenuContainerMoviescreenDirty = false
  self.MenuContainerSchemeDirty = false
  self.MenuContainerShowDirty = false
  self.MenuContainerStickerDirty = false
  self.MenuContainerShotsetDirty = false
  self.MenuContainerTextDirty = false
  self.SecondEditMoviescreenDirty = false
  self.DOFApertureFactorRange = {}
  self.NearBlendRange = {}
  self.FarBlendRange = {}
  self.DOFFocalLengthRange = {}
  self.ScreenBrightnessRange = {}
  self.ScreenContrastRange = {}
  self.ScreenSaturationRange = {}
  self.CameraAngleRange = {}
  self.CameraFontSizeRange = {}
  self.CameraDecorateScaleRange = {}
  self.CameraFOVRange = {}
  self.CameraFOVSelfRange = {}
  self.CameraFOVARRange = {}
  self.CameraVerticalRange = {}
  self.CameraHorizontalRange = {}
  self.CameraSelfVerticalRange = {}
  self.CameraSelfHorizontalRange = {}
  self.DepthData = {}
  self.FocusData = {}
  self.ShowEntityAllCfg = {}
  self.ShowEntityCfg = {}
  self.ShowEntitySelfPhotoCfg = {}
  self.ShowEntityARCfg = {}
  self.ShowEntityData = {}
  self.ShowEntitySelfPhotoData = {}
  self.ShowEntityARData = {}
  self.ShowUITCfg = {}
  self.ShowUIData = {}
  self.FilterIndex = 1
  self.FilterPath = ""
  self.FrameIndex = 1
  self.ActiveItem = nil
  self.IsDepthTag = false
  self.IsFocusTag = false
  self.WorldTime = -1
  self.IsHeadFollow = false
  self.IsEyeFollow = false
  self.IsFreeFollow = false
  self.DecoreateNum = 0
  self.DecoreateTextMaxLength = -1
  self.decoreteTextFontSize = -1
  self.decoreteMaxNum = -1
  self.decorativeText = -1
  self.CameraPatternType = E.CameraState.Default
  self.CameraSchemeInfo = {}
  self.CameraSchemeTempInfo = {}
  self.CameraSchemeSelectInfo = {}
  self.CameraSchemeReplaceInfo = {}
  self.CameraSchemeSelectId = -1
  self.CameraSchemeSelectIndex = 0
  self.IsInitSchemeState = true
  self.IsOfficialPhotoTask = false
  self.PhotoTaskId = 0
  self.secondEditTagPressIndex = nil
  self.mainCameraPhoto = {}
  self.isSchemeParamUpdated = false
  self.IsDecorateAddViewSliderShow = false
  self.UnrealSceneModeSubType = E.UnionCameraSubType.Body
  self.HeadImgOriSize = nil
  self.BodyImgOriSize = nil
  self.HeadImgOriPos = nil
  self.BodyImgOriPos = nil
  self.IsHideSelfModel = false
  self.CameraEntityVisible = {}
  self.IsBlockTakePhotoAction = false
  self.funcTbDefault = {
    {
      E.CamerasysFuncType.CommonAction,
      E.CamerasysFuncType.LoopAction,
      E.CamerasysFuncType.Emote,
      E.CamerasysFuncType.LookAt
    },
    {
      E.CamerasysFuncType.Frame,
      E.CamerasysFuncType.Sticker,
      E.CamerasysFuncType.Text
    },
    {
      E.CamerasysFuncType.Moviescreen,
      E.CamerasysFuncType.Filter,
      E.CamerasysFuncType.Shotset,
      E.CamerasysFuncType.Show,
      E.CamerasysFuncType.Scheme
    }
  }
  self.funcTbSelfPhoto = {
    {
      E.CamerasysFuncType.Emote
    },
    {
      E.CamerasysFuncType.Frame,
      E.CamerasysFuncType.Sticker,
      E.CamerasysFuncType.Text
    },
    {
      E.CamerasysFuncType.Moviescreen,
      E.CamerasysFuncType.Filter,
      E.CamerasysFuncType.Shotset,
      E.CamerasysFuncType.Show,
      E.CamerasysFuncType.Scheme
    }
  }
  self.funcTbAR = {
    {},
    {
      E.CamerasysFuncType.Frame,
      E.CamerasysFuncType.Sticker,
      E.CamerasysFuncType.Text
    },
    {
      E.CamerasysFuncType.Moviescreen,
      E.CamerasysFuncType.Filter,
      E.CamerasysFuncType.Shotset,
      E.CamerasysFuncType.Show,
      E.CamerasysFuncType.Scheme
    }
  }
  self.funcTbUnrealScene = {
    {
      E.CamerasysFuncType.CommonAction,
      E.CamerasysFuncType.LoopAction,
      E.CamerasysFuncType.Emote
    },
    {},
    {
      E.CamerasysFuncType.Moviescreen,
      E.CamerasysFuncType.Filter,
      E.CamerasysFuncType.Shotset,
      E.CamerasysFuncType.UnionBg
    }
  }
  self.funcTbSecondEdit = {
    E.CamerasysFuncType.Frame,
    E.CamerasysFuncType.Sticker,
    E.CamerasysFuncType.Text,
    E.CamerasysFuncType.Filter,
    E.CamerasysFuncType.Shotset
  }
  self.funcIdList_ = {
    [E.CamerasysFuncType.CommonAction] = E.CamerasysFuncIdType.Action,
    [E.CamerasysFuncType.LoopAction] = E.CamerasysFuncIdType.Action,
    [E.CamerasysFuncType.Emote] = E.CamerasysFuncIdType.Emote,
    [E.CamerasysFuncType.Frame] = E.CamerasysFuncIdType.Frame,
    [E.CamerasysFuncType.Sticker] = E.CamerasysFuncIdType.Sticker,
    [E.CamerasysFuncType.Text] = E.CamerasysFuncIdType.Text,
    [E.CamerasysFuncType.Moviescreen] = E.CamerasysFuncIdType.Moviescreen,
    [E.CamerasysFuncType.Filter] = E.CamerasysFuncIdType.Filter,
    [E.CamerasysFuncType.Shotset] = E.CamerasysFuncIdType.Shotset,
    [E.CamerasysFuncType.Show] = E.CamerasysFuncIdType.Show,
    [E.CamerasysFuncType.Scheme] = E.CamerasysFuncIdType.Scheme
  }
end

function CamerasysData:InitShowCfg()
  self.ShowEntityAllCfg = {
    {
      name = "stranger",
      type = E.CamerasysShowEntityType.Stranger,
      txt = Lang("Stranger"),
      state = not self.IsOfficialPhotoTask
    },
    {
      name = "npc",
      type = E.CamerasysShowEntityType.FriendlyNPCS,
      txt = Lang("Photograph_Display_NPC"),
      state = not self.IsOfficialPhotoTask
    },
    {
      name = "monster",
      type = E.CamerasysShowEntityType.Enemy,
      txt = Lang("Enemy"),
      state = not self.IsOfficialPhotoTask
    },
    {
      name = "weapons",
      type = E.CamerasysShowEntityType.WeaponsAppearance,
      txt = Lang("WeaponsAppearance"),
      state = true
    },
    {
      name = "self",
      type = E.CamerasysShowEntityType.Oneself,
      txt = Lang("Self"),
      state = true
    },
    {
      name = "friend",
      type = E.CamerasysShowEntityType.Chum,
      txt = Lang("Friend"),
      state = true
    },
    {
      name = "team",
      type = E.CamerasysShowEntityType.Team,
      txt = Lang("Team"),
      state = true
    },
    {
      name = "union",
      type = E.CamerasysShowEntityType.Union,
      txt = Lang("Union"),
      state = true
    }
  }
  self.ShowEntitySelfPhotoCfg = {
    {
      name = "stranger",
      type = E.CamerasysShowEntityType.Stranger,
      txt = Lang("Stranger"),
      state = not self.IsOfficialPhotoTask
    },
    {
      name = "npc",
      type = E.CamerasysShowEntityType.FriendlyNPCS,
      txt = Lang("Photograph_Display_NPC"),
      state = not self.IsOfficialPhotoTask
    },
    {
      name = "monster",
      type = E.CamerasysShowEntityType.Enemy,
      txt = Lang("Enemy"),
      state = not self.IsOfficialPhotoTask
    },
    {
      name = "weapons",
      type = E.CamerasysShowEntityType.WeaponsAppearance,
      txt = Lang("WeaponsAppearance"),
      state = true
    },
    {
      name = "friend",
      type = E.CamerasysShowEntityType.Chum,
      txt = Lang("Friend"),
      state = true
    },
    {
      name = "team",
      type = E.CamerasysShowEntityType.Team,
      txt = Lang("Team"),
      state = true
    },
    {
      name = "union",
      type = E.CamerasysShowEntityType.Union,
      txt = Lang("Union"),
      state = true
    }
  }
  self.ShowEntityARCfg = {
    {
      name = "stranger",
      type = E.CamerasysShowEntityType.Stranger,
      txt = Lang("Stranger"),
      state = not self.IsOfficialPhotoTask
    },
    {
      name = "npc",
      type = E.CamerasysShowEntityType.FriendlyNPCS,
      txt = Lang("Photograph_Display_NPC"),
      state = not self.IsOfficialPhotoTask
    },
    {
      name = "monster",
      type = E.CamerasysShowEntityType.Enemy,
      txt = Lang("Enemy"),
      state = not self.IsOfficialPhotoTask
    },
    {
      name = "friend",
      type = E.CamerasysShowEntityType.Chum,
      txt = Lang("Friend"),
      state = true
    },
    {
      name = "team",
      type = E.CamerasysShowEntityType.Team,
      txt = Lang("Team"),
      state = true
    },
    {
      name = "union",
      type = E.CamerasysShowEntityType.Union,
      txt = Lang("Union"),
      state = true
    }
  }
  self.ShowEntityCfg = {
    {
      name = "self",
      type = E.CamerasysShowEntityType.Oneself,
      txt = Lang("Self"),
      state = true
    },
    {
      name = "stranger",
      type = E.CamerasysShowEntityType.Stranger,
      txt = Lang("Stranger"),
      state = not self.IsOfficialPhotoTask
    },
    {
      name = "npc",
      type = E.CamerasysShowEntityType.FriendlyNPCS,
      txt = Lang("Photograph_Display_NPC"),
      state = not self.IsOfficialPhotoTask
    },
    {
      name = "monster",
      type = E.CamerasysShowEntityType.Enemy,
      txt = Lang("Enemy"),
      state = not self.IsOfficialPhotoTask
    },
    {
      name = "weapons",
      type = E.CamerasysShowEntityType.WeaponsAppearance,
      txt = Lang("WeaponsAppearance"),
      state = not self.IsOfficialPhotoTask
    },
    {
      name = "friend",
      type = E.CamerasysShowEntityType.Chum,
      txt = Lang("Friend"),
      state = true
    },
    {
      name = "team",
      type = E.CamerasysShowEntityType.Team,
      txt = Lang("Team"),
      state = true
    },
    {
      name = "union",
      type = E.CamerasysShowEntityType.Union,
      txt = Lang("Union"),
      state = true
    }
  }
  self.ShowUITCfg = {
    {
      name = "name",
      type = E.CamerasysShowUIType.Name,
      txt = Lang("Name"),
      state = not self.IsOfficialPhotoTask
    }
  }
end

function CamerasysData:InitDirty()
  self.MenuContainerActionDirty = true
  self.MenuContainerFilterDirty = true
  self.MenuContainerFrameDirty = true
  self.MenuContainerMoviescreenDirty = true
  self.MenuContainerSchemeDirty = true
  self.MenuContainerShowDirty = true
  self.MenuContainerStickerDirty = true
  self.MenuContainerShotsetDirty = true
  self.MenuContainerTextDirty = true
  self.FilterIndex = 1
  self.FilterPath = ""
  self.ActionTagIndex = 1
  self.DecorateTagIndex = 1
  self.SettingTagIndex = 1
  self.TopTagIndex = -1
  self.FrameIndex = 1
  self.CameraSchemeInfo = {}
  self.CameraSchemeTempInfo = {}
  self.CameraSchemeSelectInfo = {}
  self.CameraSchemeReplaceInfo = {}
  self.CameraFOVRange = {}
  self.CameraFOVSelfRange = {}
  self.CameraFOVARRange = {}
  self.CameraVerticalRange = {}
  self.CameraHorizontalRange = {}
  self.CameraSelfVerticalRange = {}
  self.CameraSelfHorizontalRange = {}
  self.CameraSchemeSelectIndex = 0
end

function CamerasysData:SetTopTagIndex(index)
  self.TopTagIndex = index
end

function CamerasysData:InitTagIndex()
  self.ActionTagIndex = 1
  self.DecorateTagIndex = 1
  self.SettingTagIndex = 1
  if self.IsOfficialPhotoTask then
    self.SettingTagIndex = 2
  end
end

function CamerasysData:SetNodeTagIndex(index)
  if E.CamerasysTopType.Action == self.TopTagIndex then
    self.ActionTagIndex = index
  elseif E.CamerasysTopType.Decorate == self.TopTagIndex then
    self.DecorateTagIndex = index
  elseif E.CamerasysTopType.Setting == self.TopTagIndex then
    self.SettingTagIndex = index
  end
end

function CamerasysData:GetTagIndex()
  local temp = {}
  temp.TopTagIndex = self.TopTagIndex
  if E.CamerasysTopType.Action == self.TopTagIndex then
    temp.NodeTagIndex = self.ActionTagIndex
  elseif E.CamerasysTopType.Decorate == self.TopTagIndex then
    temp.NodeTagIndex = self.DecorateTagIndex
  elseif E.CamerasysTopType.Setting == self.TopTagIndex then
    temp.NodeTagIndex = self.SettingTagIndex
  end
  return temp
end

function CamerasysData:GetFilterCfg()
  if next(self.FilterCfg) ~= nil then
    return self.FilterCfg
  end
  local tempTab = Z.TableMgr.GetTable("PhotoDecorationsTableMgr").GetDatas()
  for _, v in pairs(tempTab) do
    if E.PhotoDecorationsType.Filter == v.Type and v.Hide ~= 1 then
      self.FilterCfg[#self.FilterCfg + 1] = v
    end
  end
  table.sort(self.FilterCfg, function(left, right)
    if left.Sequence < right.Sequence then
      return true
    end
    return false
  end)
  return self.FilterCfg
end

function CamerasysData:GetUnionBgCfg()
  self.UnionBgCfg = {}
  if next(self.UnionBgCfg) ~= nil then
    return self.UnionBgCfg
  end
  local tempTab = Z.TableMgr.GetTable("PhotoDecorationsTableMgr").GetDatas()
  for _, v in pairs(tempTab) do
    if (E.PhotoDecorationsType.UnionHeadBg == v.Type or E.PhotoDecorationsType.UnionIdCardBg == v.Type) and v.Hide ~= 1 then
      self.UnionBgCfg[#self.UnionBgCfg + 1] = v
    end
  end
  table.sort(self.UnionBgCfg, function(left, right)
    if left.Sequence < right.Sequence then
      return true
    end
    return false
  end)
  return self.UnionBgCfg
end

function CamerasysData:GetDecorateFrameCfg()
  if next(self.DecorateFrameCfg) ~= nil then
    return self.DecorateFrameCfg
  end
  local tempTab = Z.TableMgr.GetTable("PhotoDecorationsTableMgr").GetDatas()
  for _, v in pairs(tempTab) do
    if E.PhotoDecorationsType.Frame == v.Type then
      self.DecorateFrameCfg[#self.DecorateFrameCfg + 1] = v
    end
  end
  table.sort(self.DecorateFrameCfg, function(left, right)
    if left.Sequence < right.Sequence then
      return true
    end
    return false
  end)
  return self.DecorateFrameCfg
end

function CamerasysData:GetDecorateStickerCfg()
  if next(self.DecorateStickerCfg) ~= nil then
    return self.DecorateStickerCfg
  end
  local tempTab = Z.TableMgr.GetTable("PhotoDecorationsTableMgr").GetDatas()
  for _, v in pairs(tempTab) do
    if E.PhotoDecorationsType.Sticker == v.Type then
      self.DecorateStickerCfg[#self.DecorateStickerCfg + 1] = v
    end
  end
  table.sort(self.DecorateStickerCfg, function(left, right)
    if left.Sequence < right.Sequence then
      return true
    end
    return false
  end)
  return self.DecorateStickerCfg
end

function CamerasysData:GetDecorateTextCfg()
  if next(self.DecorateTextCfg) ~= nil then
    return self.DecorateTextCfg
  end
  local tempTab = Z.TableMgr.GetTable("PhotoDecorationsTableMgr").GetDatas()
  for _, v in pairs(tempTab) do
    if E.PhotoDecorationsType.Color == v.Type then
      self.DecorateTextCfg[#self.DecorateTextCfg + 1] = v
    end
  end
  table.sort(self.DecorateTextCfg, function(left, right)
    if left.Sequence < right.Sequence then
      return true
    end
    return false
  end)
  return self.DecorateTextCfg
end

function CamerasysData:GetDOFApertureFactorRange()
  if self.DOFApertureFactorRange ~= nil and table.zcount(self.DOFApertureFactorRange) > 1 then
    return self.DOFApertureFactorRange
  end
  local groupStr = Z.Global.Photograph_DOFApertureFactorRange
  self:initCameraSettingParamRange(groupStr, self.DOFApertureFactorRange)
  self.DOFApertureFactorRange.isOpen = false
  if not self.DOFApertureFactorRange.value then
    self.DOFApertureFactorRange.value = self.DOFApertureFactorRange.define
  end
  return self.DOFApertureFactorRange
end

function CamerasysData:GetNearBlendRange()
  if self.NearBlendRange ~= nil and table.zcount(self.NearBlendRange) > 1 then
    return self.NearBlendRange
  end
  local groupStr = Z.Global.Photograph_DOFNearAmbiguityRange
  self:initCameraSettingParamRange(groupStr, self.NearBlendRange)
  if not self.NearBlendRange.value then
    self.NearBlendRange.value = self.NearBlendRange.define
  end
  return self.NearBlendRange
end

function CamerasysData:GetFarBlendRange()
  if self.FarBlendRange ~= nil and table.zcount(self.FarBlendRange) > 1 then
    return self.FarBlendRange
  end
  local groupStr = Z.Global.Photograph_DOFFarAmbiguityRange
  self:initCameraSettingParamRange(groupStr, self.FarBlendRange)
  if not self.FarBlendRange.value then
    self.FarBlendRange.value = self.FarBlendRange.define
  end
  return self.FarBlendRange
end

function CamerasysData:GetDOFFocalLengthRange()
  if self.DOFFocalLengthRange ~= nil and table.zcount(self.DOFFocalLengthRange) > 1 then
    return self.DOFFocalLengthRange
  end
  local groupStr = Z.Global.Photograph_DOFFocalLengthRange
  self:initCameraSettingParamRange(groupStr, self.DOFFocalLengthRange)
  self.DOFFocalLengthRange.isOpen = false
  if not self.DOFFocalLengthRange.value then
    self.DOFFocalLengthRange.value = self.DOFFocalLengthRange.define
  end
  return self.DOFFocalLengthRange
end

function CamerasysData:GetTempRange(data)
  local temp = {}
  temp.min = data.min
  temp.max = data.max
  temp.define = data.define
  temp.value = 0
  return temp
end

function CamerasysData:GetScreenBrightnessRange()
  if self.ScreenBrightnessRange ~= nil and table.zcount(self.ScreenBrightnessRange) > 1 then
    return self.ScreenBrightnessRange
  end
  local groupStr = Z.Global.Photograph_ScreenBrightnessRange
  self:initCameraSettingParamRange(groupStr, self.ScreenBrightnessRange)
  if not self.ScreenBrightnessRange.value then
    self.ScreenBrightnessRange.value = self.ScreenBrightnessRange.define
  end
  return self.ScreenBrightnessRange
end

function CamerasysData:GetScreenContrastRange()
  if self.ScreenContrastRange ~= nil and table.zcount(self.ScreenContrastRange) > 1 then
    return self.ScreenContrastRange
  end
  local groupStr = Z.Global.Photograph_ScreenContrastRange
  self:initCameraSettingParamRange(groupStr, self.ScreenContrastRange)
  if not self.ScreenContrastRange.value then
    self.ScreenContrastRange.value = self.ScreenContrastRange.define
  end
  return self.ScreenContrastRange
end

function CamerasysData:initCameraSettingParamRange(globalValueTable, refTable)
  if not globalValueTable or not next(globalValueTable) then
    return
  end
  local Tbl = globalValueTable[1]
  local showValue = globalValueTable[2]
  if #Tbl < 3 or #showValue < 2 then
    return
  end
  refTable = refTable or {}
  refTable.min = Tbl[1]
  refTable.max = Tbl[2]
  refTable.define = Tbl[3]
  refTable.showValueMin = showValue[1]
  refTable.showValueMax = showValue[2]
end

function CamerasysData:GetScreenSaturationRange()
  if self.ScreenSaturationRange ~= nil and table.zcount(self.ScreenSaturationRange) > 1 then
    return self.ScreenSaturationRange
  end
  local groupStr = Z.Global.Photograph_ScreenSaturationRange
  self:initCameraSettingParamRange(groupStr, self.ScreenSaturationRange)
  if not self.ScreenSaturationRange.value then
    self.ScreenSaturationRange.value = self.ScreenSaturationRange.define
  end
  return self.ScreenSaturationRange
end

function CamerasysData:GetCameraVerticalRange()
  if self.CameraVerticalRange ~= nil and table.zcount(self.CameraVerticalRange) > 1 then
    return self.CameraVerticalRange
  end
  local groupStr = Z.Global.Photograph_CameraVerticalRange
  self:initCameraSettingParamRange(groupStr, self.CameraVerticalRange)
  if not self.CameraVerticalRange.value then
    self.CameraVerticalRange.value = self.CameraVerticalRange.define
  end
  return self.CameraVerticalRange
end

function CamerasysData:GetCameraHorizontalRange()
  if self.CameraHorizontalRange ~= nil and table.zcount(self.CameraHorizontalRange) > 1 then
    return self.CameraHorizontalRange
  end
  local groupStr = Z.Global.Photograph_CameraHorizontalRange
  self:initCameraSettingParamRange(groupStr, self.CameraHorizontalRange)
  if not self.CameraHorizontalRange.value then
    self.CameraHorizontalRange.value = self.CameraHorizontalRange.define
  end
  return self.CameraHorizontalRange
end

function CamerasysData:GetCameraSelfVerticalRange()
  if self.CameraSelfVerticalRange ~= nil and table.zcount(self.CameraSelfVerticalRange) > 1 then
    return self.CameraSelfVerticalRange
  end
  local groupStr = Z.Global.Photograph_SelfCameraVerticalRange
  self:initCameraSettingParamRange(groupStr, self.CameraSelfVerticalRange)
  if not self.CameraSelfVerticalRange.value then
    self.CameraSelfVerticalRange.value = self.CameraSelfVerticalRange.define
  end
  return self.CameraSelfVerticalRange
end

function CamerasysData:GetCameraSelfHorizontalRange()
  if self.CameraSelfHorizontalRange ~= nil and table.zcount(self.CameraSelfHorizontalRange) > 1 then
    return self.CameraSelfHorizontalRange
  end
  local groupStr = Z.Global.Photograph_SelfCameraHorizontalRange
  self:initCameraSettingParamRange(groupStr, self.CameraSelfHorizontalRange)
  if not self.CameraSelfHorizontalRange.value then
    self.CameraSelfHorizontalRange.value = self.CameraSelfHorizontalRange.define
  end
  return self.CameraSelfHorizontalRange
end

function CamerasysData:GetCameraFOVRange()
  if self.CameraFOVRange ~= nil and table.zcount(self.CameraFOVRange) > 1 then
    return self.CameraFOVRange
  end
  local groupStr = Z.Global.Photograph_CameraVFOVRange
  self:initCameraSettingParamRange(groupStr, self.CameraFOVRange)
  self.CameraFOVRange.define = Z.CameraFrameCtrl:GetDefineFov()
  self.CameraFOVRange.type = "GetCameraFOVRange"
  if not self.CameraFOVRange.value then
    self.CameraFOVRange.value = self.CameraFOVRange.define
  end
  return self.CameraFOVRange
end

function CamerasysData:GetCameraFOVSelfRange()
  if self.CameraFOVSelfRange ~= nil and table.zcount(self.CameraFOVSelfRange) > 1 then
    return self.CameraFOVSelfRange
  end
  local groupStr = Z.Global.Photograph_SelfCameraVFOVRange
  self:initCameraSettingParamRange(groupStr, self.CameraFOVSelfRange)
  self.CameraFOVSelfRange.type = "GetCameraFOVSelfRange"
  if not self.CameraFOVSelfRange.value then
    self.CameraFOVSelfRange.value = self.CameraFOVSelfRange.define
  end
  return self.CameraFOVSelfRange
end

function CamerasysData:GetCameraFOVARRange()
  if self.CameraFOVARRange ~= nil and table.zcount(self.CameraFOVARRange) > 1 then
    return self.CameraFOVARRange
  end
  local groupStr = Z.Global.Photograph_ARCameraVFOVRange
  self:initCameraSettingParamRange(groupStr, self.CameraFOVARRange)
  self.CameraFOVARRange.type = "GetCameraFOVARRange"
  if not self.CameraFOVARRange.value then
    self.CameraFOVARRange.value = self.CameraFOVARRange.define
  end
  return self.CameraFOVARRange
end

function CamerasysData:GetCameraAngleRange()
  if self.CameraAngleRange ~= nil and table.zcount(self.CameraAngleRange) > 1 then
    return self.CameraAngleRange
  end
  local groupStr = Z.Global.Photograph_CameraAngleRange
  self:initCameraSettingParamRange(groupStr, self.CameraAngleRange)
  if not self.CameraAngleRange.value then
    self.CameraAngleRange.value = self.CameraAngleRange.define
  end
  return self.CameraAngleRange
end

function CamerasysData:GetCameraFontSizeRange()
  if self.CameraFontSizeRange ~= nil and table.zcount(self.CameraFontSizeRange) > 1 then
    return self.CameraFontSizeRange
  end
  local groupStr = Z.Global.Photograph_FontSizeRange
  self:initCameraSettingParamRange(groupStr, self.CameraFontSizeRange)
  if not self.CameraFontSizeRange.value then
    self.CameraFontSizeRange.value = self.CameraFontSizeRange.define
  end
  return self.CameraFontSizeRange
end

function CamerasysData:GetCameraDecorateScaleRange()
  if self.CameraDecorateScaleRange ~= nil and table.zcount(self.CameraDecorateScaleRange) > 1 then
    return self.CameraDecorateScaleRange
  end
  local groupStr = Z.Global.Photograph_DecorateScaleRange
  self:initCameraSettingParamRange(groupStr, self.CameraDecorateScaleRange)
  if not self.CameraDecorateScaleRange.value then
    self.CameraDecorateScaleRange.value = self.CameraDecorateScaleRange.define
  end
  return self.CameraDecorateScaleRange
end

function CamerasysData:GetDecoreateTextMaxLength()
  if self.DecoreateTextMaxLength ~= -1 then
    return self.DecoreateTextMaxLength
  end
  self.DecoreateTextMaxLength = Z.Global.Photograph_TextMaxLength
  return self.DecoreateTextMaxLength
end

function CamerasysData:GetDecoreateMaxNum()
  if self.decoreteMaxNum ~= -1 then
    return self.decoreteMaxNum
  end
  self.decoreteMaxNum = Z.Global.Photograph_DecorationsAddLimit
  return self.decoreteMaxNum
end

function CamerasysData:GetDecorativeTextMaxNum()
  if self.decorativeText ~= -1 then
    return self.decorativeText
  end
  self.decorativeText = Z.Global.Photograph_DecorationsOfTextAddLimit
  return self.decorativeText
end

function CamerasysData:GetShowEntityData()
  if self.MenuContainerShowDirty then
    self.ShowEntityData = {}
  end
  if self.ShowEntityData ~= nil and next(self.ShowEntityData) ~= nil then
    return self.ShowEntityData
  end
  if not self.ShowEntityData or not next(self.ShowEntityData) then
    self:InitShowCfg()
    self.ShowEntityData = self.ShowEntityCfg
  end
  return self.ShowEntityData
end

function CamerasysData:GetShowEntitySelfPhotoData()
  if self.MenuContainerShowDirty then
    self.ShowEntitySelfPhotoData = {}
  end
  if self.ShowEntitySelfPhotoData ~= nil and next(self.ShowEntitySelfPhotoData) ~= nil then
    return self.ShowEntitySelfPhotoData
  end
  if not self.ShowEntitySelfPhotoData or not next(self.ShowEntitySelfPhotoData) then
    self:InitShowCfg()
    self.ShowEntitySelfPhotoData = self.ShowEntitySelfPhotoCfg
  end
  return self.ShowEntitySelfPhotoData
end

function CamerasysData:GetShowEntityARData()
  if self.MenuContainerShowDirty then
    self.ShowEntityARData = {}
  end
  if self.ShowEntityARData ~= nil and next(self.ShowEntityARData) ~= nil then
    return self.ShowEntityARData
  end
  if not self.ShowEntityARData or not next(self.ShowEntityARData) then
    self:InitShowCfg()
    self.ShowEntityARData = self.ShowEntityARCfg
  end
  return self.ShowEntityARData
end

function CamerasysData:SetShowEntityState(typeE, state, type)
  local showData = self.ShowEntityData
  if type == E.CameraState.Default then
    showData = self.ShowEntityData
  elseif type == E.CameraState.SelfPhoto then
    showData = self.ShowEntitySelfPhotoData
  elseif type == E.CameraState.AR then
    showData = self.ShowEntityARData
  end
  if not showData or not next(showData) then
    return
  end
  for key, value in pairs(showData) do
    if value.type == typeE then
      value.state = state
      break
    end
  end
end

function CamerasysData:GetShowUIData()
  if self.MenuContainerShowDirty then
    self.ShowUIData = {}
  end
  if self.ShowUIData ~= nil and next(self.ShowUIData) ~= nil then
    return self.ShowUIData
  end
  self:InitShowCfg()
  self.ShowUIData = self.ShowUITCfg
  return self.ShowUIData
end

function CamerasysData:SetShowUIState(index, state)
  if self.ShowUIData[index] ~= nil then
    self.ShowUIData[index].state = state
  end
end

function CamerasysData:SetTextFontSize(num)
  self.decoreteTextFontSize = num
end

function CamerasysData:GetTextFontSize()
  if self.decoreteTextFontSize == -1 then
    self:GetCameraFontSizeRange()
    self.decoreteTextFontSize = self.CameraFontSizeRange.define
  end
  return self.decoreteTextFontSize
end

function CamerasysData:GetSchemeInfoDatas()
  Z.LsqLiteMgr.CreateTable("camera_scheme_info")
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local cameraSchemeCache = Z.LsqLiteMgr.GetDataByKey("camera_scheme_info", "zproto.cameraSchemeCache", roleKey)
  if not cameraSchemeCache or not next(cameraSchemeCache) then
    cameraSchemeCache = {}
    cameraSchemeCache.cameraSchemeDict = {}
  end
  self.CameraSchemeInfo = cameraSchemeCache.cameraSchemeDict
  local temp = {}
  temp[1] = self:GetCameraDefineSchemeInfo()
  for _, value in pairs(self.CameraSchemeInfo) do
    if self.CameraPatternType == E.CameraState.UnrealScene then
      if value.cameraPatternType == E.CameraState.UnrealScene then
        temp[#temp + 1] = value
      end
    elseif value.cameraPatternType ~= E.CameraState.UnrealScene then
      temp[#temp + 1] = value
    end
  end
  return temp
end

function CamerasysData:AddSchemeInfoDatas(key, value)
  if not self.CameraSchemeInfo or not next(self.CameraSchemeInfo) then
    self.CameraSchemeInfo = self:GetSchemeInfoDatas()
  end
  local targetKey
  for schemeKey, value in pairs(self.CameraSchemeInfo) do
    if value.schemeKey == key then
      targetKey = schemeKey
      break
    end
  end
  if not targetKey then
    return
  end
  self.CameraSchemeInfo[targetKey] = value
end

function CamerasysData:SetCameraSchemeTempInfo()
  self.CameraSchemeTempInfo = self:GetCameraSchemeInfo()
end

function CamerasysData:GetCameraSchemeInfo()
  local schemeInfo = {}
  schemeInfo.cameraPatternType = self.CameraPatternType
  schemeInfo.cameraSchemeType = E.CameraSchemeType.CustomScheme
  schemeInfo.schemeName = Z.VMMgr.GetVM("camerasys").CreateCameraSchemefName()
  schemeInfo.schemeTime = Z.ServerTime:GetServerTime()
  schemeInfo.schemeKey = string.format("schemeKey%s", Z.ServerTime:GetServerTime())
  schemeInfo.exposure = self.ScreenBrightnessRange.value
  schemeInfo.contrast = self.ScreenContrastRange.value
  schemeInfo.saturation = self.ScreenSaturationRange.value
  schemeInfo.angle = self.CameraAngleRange.value
  schemeInfo.depthTag = self.IsDepthTag
  schemeInfo.aperture = self.DOFApertureFactorRange.value
  schemeInfo.nearBlend = self.NearBlendRange.value
  schemeInfo.farBlend = self.FarBlendRange.value
  schemeInfo.focusTag = self.IsFocusTag
  schemeInfo.focus = self.DOFFocalLengthRange.value
  schemeInfo.isHeadFollow = self.IsHeadFollow
  schemeInfo.isEyeFollow = self.IsEyeFollow
  schemeInfo.worldTime = self.WorldTime
  local showEntityCfg = {}
  schemeInfo.showEntityDicts = {}
  if self.CameraPatternType == E.CameraState.Default then
    showEntityCfg = self:GetShowEntityData()
    schemeInfo.horizontal = self.CameraHorizontalRange.value
    schemeInfo.vertical = self.CameraVerticalRange.value
  elseif self.CameraPatternType == E.CameraState.SelfPhoto then
    showEntityCfg = self:GetShowEntitySelfPhotoData()
    schemeInfo.horizontal = self.CameraSelfHorizontalRange.value
    schemeInfo.vertical = self.CameraSelfVerticalRange.value
  elseif self.CameraPatternType == E.CameraState.AR then
    showEntityCfg = self:GetShowEntityARData()
  end
  for _, value in pairs(showEntityCfg) do
    schemeInfo.showEntityDicts[value.type] = value.state
  end
  local showUICfg = self:GetShowUIData()
  schemeInfo.showUIDicts = {}
  for _, value in pairs(showUICfg) do
    schemeInfo.showUIDicts[value.type] = value.state
  end
  schemeInfo.filterPath = self.FilterPath
  schemeInfo.id = Z.ServerTime:GetServerTime()
  return schemeInfo
end

function CamerasysData:GetCameraDefineSchemeInfo()
  local schemeInfo = {}
  schemeInfo.cameraPatternType = E.CameraState.Default
  schemeInfo.cameraSchemeType = E.CameraSchemeType.DefaultScheme
  schemeInfo.schemeName = Lang("DefaultPlan")
  schemeInfo.schemeTime = 0
  schemeInfo.schemeKey = string.format("schemeKey%s", Z.ServerTime:GetServerTime())
  schemeInfo.exposure = self.ScreenBrightnessRange.define
  schemeInfo.contrast = self.ScreenContrastRange.define
  schemeInfo.saturation = self.ScreenSaturationRange.define
  schemeInfo.horizontal = self.CameraHorizontalRange.define
  schemeInfo.vertical = self.CameraVerticalRange.define
  schemeInfo.angle = self.CameraAngleRange.define
  schemeInfo.depthTag = false
  schemeInfo.aperture = self.DOFApertureFactorRange.define
  schemeInfo.nearBlend = self.NearBlendRange.define
  schemeInfo.farBlend = self.FarBlendRange.define
  schemeInfo.focusTag = false
  schemeInfo.focus = self.DOFFocalLengthRange.define
  schemeInfo.isHeadFollow = false
  schemeInfo.isEyeFollow = false
  schemeInfo.worldTime = -1
  schemeInfo.showEntityDicts = {
    [E.CamerasysShowEntityType.Oneself] = true,
    [E.CamerasysShowEntityType.Stranger] = true,
    [E.CamerasysShowEntityType.FriendlyNPCS] = true,
    [E.CamerasysShowEntityType.Enemy] = true
  }
  schemeInfo.showUIDicts = {
    [E.CamerasysShowUIType.Name] = true
  }
  schemeInfo.filterPath = ""
  schemeInfo.id = -1
  return schemeInfo
end

function CamerasysData:GetSecondEditPressIndexByCamerasysFuncType()
  if not self.secondEditTagPressIndex then
    return
  end
  for k, v in pairs(self.funcTbSecondEdit) do
    if v == self.secondEditTagPressIndex then
      return k
    end
  end
  return nil
end

function CamerasysData:Clear()
  self:ResetMainCameraPhotoData()
  self.isSchemeParamUpdated = false
  self.IsDecorateAddViewSliderShow = false
  self.HeadImgOriSize = nil
  self.BodyImgOriSize = nil
  self.HeadImgOriPos = nil
  self.BodyImgOriPos = nil
  self.IsHideSelfModel = false
  self.CameraEntityVisible = {}
  self.IsBlockTakePhotoAction = false
end

function CamerasysData:ResetMainCameraPhotoData()
  self.mainCameraPhoto = {}
end

function CamerasysData:SetMainCameraPhotoData(oriId, effectId, thumbId)
  self.mainCameraPhoto.oriId = oriId
  self.mainCameraPhoto.effectId = effectId
  self.mainCameraPhoto.thumbId = thumbId
end

function CamerasysData:GetMainCameraPhotoData()
  return self.mainCameraPhoto
end

function CamerasysData:SetIsSchemeParamUpdated(isUpdated)
  if self.CameraSchemeSelectId ~= -1 then
    self.isSchemeParamUpdated = isUpdated
  end
end

function CamerasysData:GetIsSchemeParamUpdated()
  return self.isSchemeParamUpdated
end

function CamerasysData:ResetHeadAndEyesFollow()
  self.IsHeadFollow = false
  self.IsEyeFollow = false
  self.IsFreeFollow = false
end

return CamerasysData
