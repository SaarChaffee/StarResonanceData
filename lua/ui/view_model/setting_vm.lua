local QualityGradeSetting = Panda.Utility.Quality.QualityGradeSetting
local settingData = Z.DataMgr.Get("setting_data")
local EQualityGrade = Panda.Utility.Quality.EQualityGrade
local lensCompensateIds_ = {
  [E.SettingID.CameraTemplate] = {21},
  [E.SettingID.PitchAngleCorrection] = {22},
  [E.SettingID.BattleZoomCorrection] = {23},
  [E.SettingID.BattlePitchAngkeCorrection] = {26},
  [E.SettingID.CameraTranslationRotate] = {20},
  [E.SettingID.CameraReleasingSkill] = {28},
  [E.SettingID.CameraReleasingSkillAngle] = {30, 31},
  [E.SettingID.CameraSeek] = {32},
  [E.SettingID.CameraMelee] = {
    7,
    8,
    24,
    25
  }
}
local openSettingView = function(showFuncs, firstFunc)
  Z.UIMgr:OpenView("setting", {showFuncs = showFuncs, firstFunc = firstFunc})
end
local closeSettingView = function()
  Z.UIMgr:CloseView("setting")
end
local closeSettingPopupView = function()
  Z.UIMgr:CloseView("setting_popup")
end
local getSettingPopupViewShowed = function()
  local showed = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Device, "SettingPopupViewShowed", 0)
  return 0 < showed
end
local setSettingPopupViewShowed = function()
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Device, "SettingPopupViewShowed", 1)
end
local openSettingPopupView = function()
  if getSettingPopupViewShowed() then
    return
  end
  setSettingPopupViewShowed()
  Z.UIMgr:OpenView("setting_popup")
end
local asyncSaveSetting = function(setData)
  local worldProxy = require("zproxy.world_proxy")
  worldProxy.SaveSetting(setData)
end
local setInt = function(id, value)
  local valueType = type(value)
  local newValue
  if valueType == "string" then
    newValue = tonumber(value)
    newValue = Mathf.Round(newValue)
  elseif valueType == "boolean" then
    newValue = value and 1 or 0
  elseif valueType == "number" then
    newValue = Mathf.Round(value)
  else
    logError("saveInt type error value?{0} type?{1}", value, valueType)
    return
  end
  local row
  if 0 <= id then
    local settingTbl = Z.TableMgr.GetTable("SettingsTableMgr")
    row = settingTbl.GetRow(id)
  end
  if row then
    if row.DataStorage == settingData.DataStorage.ClientDeviceData then
      Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Device, "BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.ClientEnvData then
      Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Env, "BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.ClientAccountData then
      Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Account, "BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.ClientCharacterData then
      Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, "BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.ServerData then
      local worldProxy = require("zproxy.world_proxy")
      worldProxy.SaveSetting({
        [id] = tostring(newValue)
      })
    end
  else
    Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Device, "BKL_CUSTOM_SETID_" .. id, newValue)
  end
end
local getInt = function(id)
  local row
  if 0 <= id then
    local settingTbl = Z.TableMgr.GetTable("SettingsTableMgr")
    row = settingTbl.GetRow(id)
  end
  if row then
    local defaultValue = 0
    local rowValue = tonumber(row.Value)
    if rowValue then
      defaultValue = Mathf.Round(rowValue)
    else
      local idArrays = string.split(row.Value, "=")
      if idArrays and #idArrays == 2 then
        if Z.GameContext.IsPC then
          rowValue = tonumber(idArrays[1])
        else
          rowValue = tonumber(idArrays[2])
        end
      end
    end
    if rowValue then
      defaultValue = Mathf.Round(rowValue)
    end
    local value = defaultValue
    if row.DataStorage == settingData.DataStorage.ClientDeviceData then
      value = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Device, "BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.ClientEnvData then
      value = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Env, "BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.ClientAccountData then
      value = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Account, "BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.ClientCharacterData then
      value = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, "BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.ServerData and Z.ContainerMgr.CharSerialize.settingData.settingMap[id] then
      value = Mathf.Round(tonumber(Z.ContainerMgr.CharSerialize.settingData.settingMap[id]))
    end
    return value
  else
    return Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Device, "BKL_CUSTOM_SETID_" .. id, -99999)
  end
end
local getBoolean = function(id)
  local value = getInt(id)
  return value and 0 < value
end
local setFloat = function(id, value)
  local valueType = type(value)
  local newValue
  if valueType == "string" then
    newValue = tonumber(value)
  elseif valueType == "number" then
    newValue = value
  else
    logError("setFloat type error value?{0} type?{1}", value, valueType)
    return
  end
  local row
  if 0 <= id then
    local settingTbl = Z.TableMgr.GetTable("SettingsTableMgr")
    row = settingTbl.GetRow(id)
  end
  if row then
    if row.DataStorage == settingData.DataStorage.ClientDeviceData then
      Z.LocalUserDataMgr.SetFloatByLua(E.LocalUserDataType.Device, "BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.ClientEnvData then
      Z.LocalUserDataMgr.SetFloatByLua(E.LocalUserDataType.Env, "BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.ClientAccountData then
      Z.LocalUserDataMgr.SetFloatByLua(E.LocalUserDataType.Account, "BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.ClientCharacterData then
      Z.LocalUserDataMgr.SetFloatByLua(E.LocalUserDataType.Character, "BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.ServerData then
      local worldProxy = require("zproxy.world_proxy")
      worldProxy.SaveSetting({
        [id] = tostring(newValue)
      })
    end
  else
    Z.LocalUserDataMgr.SetFloatByLua(E.LocalUserDataType.Device, "BKL_CUSTOM_SETID_" .. id, newValue)
  end
end
local getFloat = function(id)
  local row
  if 0 <= id then
    local settingTbl = Z.TableMgr.GetTable("SettingsTableMgr")
    row = settingTbl.GetRow(id)
  end
  if row then
    local defaultValue = tonumber(row.Value)
    local value = defaultValue
    if row.DataStorage == settingData.DataStorage.ClientDeviceData then
      value = Z.LocalUserDataMgr.GetFloatByLua(E.LocalUserDataType.Device, "BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.ClientEnvData then
      value = Z.LocalUserDataMgr.GetFloatByLua(E.LocalUserDataType.Env, "BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.ClientAccountData then
      value = Z.LocalUserDataMgr.GetFloatByLua(E.LocalUserDataType.Account, "BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.ClientCharacterData then
      value = Z.LocalUserDataMgr.GetFloatByLua(E.LocalUserDataType.Character, "BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.ServerData and Z.ContainerMgr.CharSerialize.settingData.settingMap[id] then
      value = tonumber(Z.ContainerMgr.CharSerialize.settingData.settingMap[id])
    end
    return value
  else
    return Z.LocalUserDataMgr.GetFloatByLua(E.LocalUserDataType.Device, "BKL_CUSTOM_SETID_" .. id, -99999.0)
  end
end
local setString = function(id, value)
  local valueType = type(value)
  local newValue
  if valueType == "string" then
    newValue = value
  elseif valueType == "number" then
    newValue = tostring(value)
  else
    logError("setString type error value?{0} type?{1}", value, valueType)
    return
  end
  local row
  if 0 <= id then
    local settingTbl = Z.TableMgr.GetTable("SettingsTableMgr")
    row = settingTbl.GetRow(id)
  end
  if row then
    if row.DataStorage == settingData.DataStorage.ClientDeviceData then
      Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Device, "BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.ClientEnvData then
      Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Env, "BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.ClientAccountData then
      Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Account, "BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.ClientCharacterData then
      Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Character, "BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.ServerData then
      local worldProxy = require("zproxy.world_proxy")
      worldProxy.SaveSetting({
        [id] = newValue
      })
    end
  else
    Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Device, "BKL_CUSTOM_SETID_" .. id, newValue)
  end
end
local getString = function(id)
  local row
  if 0 <= id then
    local settingTbl = Z.TableMgr.GetTable("SettingsTableMgr")
    row = settingTbl.GetRow(id)
  end
  if row then
    local defaultValue = row.Value
    local value = defaultValue
    if row.DataStorage == settingData.DataStorage.ClientDeviceData then
      value = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Device, "BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.ClientEnvData then
      value = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Env, "BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.ClientAccountData then
      value = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Account, "BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.ClientCharacterData then
      value = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Character, "BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.ServerData then
      value = Z.ContainerMgr.CharSerialize.settingData.settingMap[id] or ""
    end
    return value
  else
    return Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Device, "BKL_CUSTOM_SETID_" .. id, "")
  end
end
local setGrade = function(id, value)
  local dataNumber = value.ShadowGrade * 10000 + value.PostEffectGrade * 1000 + value.SceneDetailGrade * 100 + value.CharDetailGrade * 10 + value.EffectEffectGrade
  local str = tostring(dataNumber)
  Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Character, "BKL_SETID_QUALITY_", str)
end
local getGrade = function(id)
  local str = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Character, "BKL_SETID_QUALITY_", "")
  if str ~= "" then
    local dataNumber = tonumber(str)
    return {
      ShadowGrade = dataNumber // 10000,
      PostEffectGrade = dataNumber % 10000 // 1000,
      SceneDetailGrade = dataNumber % 1000 // 100,
      CharDetailGrade = dataNumber % 100 // 10,
      EffectEffectGrade = dataNumber % 10
    }
  end
end
local SettingFunctionConfig = {
  [E.SettingID.EffSelf] = {get = getString, set = setString},
  [E.SettingID.EffEnemy] = {get = getString, set = setString},
  [E.SettingID.EffTeammate] = {get = getString, set = setString},
  [E.SettingID.EffOther] = {get = getString, set = setString},
  [E.SettingID.EffectRest] = {get = getString, set = setString},
  [E.SettingID.HorizontalSensitivity] = {get = getFloat, set = setFloat},
  [E.SettingID.VerticalSensitivity] = {get = getFloat, set = setFloat},
  [E.SettingID.Master] = {get = getFloat, set = setFloat},
  [E.SettingID.Bgm] = {get = getFloat, set = setFloat},
  [E.SettingID.Sfx] = {get = getFloat, set = setFloat},
  [E.SettingID.Voice] = {get = getFloat, set = setFloat},
  [E.SettingID.System] = {get = getFloat, set = setFloat},
  [E.SettingID.P3] = {get = getFloat, set = setFloat},
  [E.SettingID.PlayerVoiceReceptionVolume] = {get = getFloat, set = setFloat},
  [E.SettingID.PlayerVoiceTransmissionVolume] = {get = getFloat, set = setFloat},
  [E.SettingID.LockOpen] = {get = getBoolean, set = setInt},
  [E.SettingID.CameraLockFirst] = {get = getBoolean, set = setInt},
  [E.SettingID.GlideDirectionCtrl] = {get = getInt, set = setInt},
  [E.SettingID.GlideDiveCtrl] = {get = getInt, set = setInt},
  [E.SettingID.KeyHint] = {get = getBoolean, set = setInt},
  [E.SettingID.CameraSeismicScreen] = {get = getBoolean, set = setInt},
  [E.SettingID.PulseScreen] = {get = getBoolean, set = setInt},
  [E.SettingID.SkillController] = {get = getBoolean, set = setInt},
  [E.SettingID.SkillControllerPcUp] = {get = getInt, set = setInt},
  [E.SettingID.CameraMove] = {get = getBoolean, set = setInt},
  [E.SettingID.CameraTranslationRotate] = {get = getBoolean, set = setInt},
  [E.SettingID.CameraReleasingSkill] = {get = getBoolean, set = setInt},
  [E.SettingID.CameraReleasingSkillAngle] = {get = getBoolean, set = setInt},
  [E.SettingID.CameraSeek] = {get = getBoolean, set = setInt},
  [E.SettingID.CameraMelee] = {get = getBoolean, set = setInt},
  [E.SettingID.RemoveMouseRestrictions] = {get = getBoolean, set = setInt},
  [E.ClientSettingID.Grade] = {get = getGrade, set = setGrade},
  [E.ClientSettingID.AutoPlay] = {get = getBoolean, set = setInt},
  [E.SettingID.CameraTemplate] = {get = getBoolean, set = setInt},
  [E.SettingID.PitchAngleCorrection] = {get = getBoolean, set = setInt},
  [E.SettingID.BattleZoomCorrection] = {get = getBoolean, set = setInt},
  [E.SettingID.BattlePitchAngkeCorrection] = {get = getBoolean, set = setInt},
  [E.SettingID.ShowSkillTag] = {get = getBoolean, set = setInt},
  [E.SettingID.AutoBattle] = {get = getBoolean, set = setInt},
  [E.SettingID.WeaponDisplay] = {get = getBoolean, set = setInt},
  [E.SettingID.PlayerHeadInformation] = {get = getString, set = setString},
  [E.SettingID.OtherPlayerHeadInformation] = {get = getString, set = setString},
  [E.SettingID.NPCPlayerHeadInformation] = {get = getString, set = setString},
  [E.SettingID.ShowTaskEffect] = {get = getBoolean, set = setInt},
  [E.SettingID.ToyVisible] = {get = getInt, set = setInt},
  [E.SettingID.HudNumberClose] = {get = getBoolean, set = setInt},
  [E.SettingID.HudNumberSimple] = {get = getBoolean, set = setInt}
}
local set = function(id, value)
  local setFunc
  if SettingFunctionConfig[id] and SettingFunctionConfig[id].set then
    setFunc = SettingFunctionConfig[id].set
  else
    setFunc = setString
  end
  setFunc(id, value)
end
local get = function(id)
  local getFunc
  if SettingFunctionConfig[id] and SettingFunctionConfig[id].get then
    getFunc = SettingFunctionConfig[id].get
  else
    getFunc = getString
  end
  return getFunc(id)
end
local setPlayerGlideAttr = function(ctrlMode, diveMode)
  if not Z.EntityMgr.PlayerEnt then
    return
  end
  ctrlMode = ctrlMode or get(E.SettingID.GlideDirectionCtrl)
  diveMode = diveMode or get(E.SettingID.GlideDiveCtrl)
  Z.EntityMgr.PlayerEnt:SetLuaLocalAttrGlideCtrlMode(ctrlMode)
  Z.EntityMgr.PlayerEnt:SetLuaLocalAttrGlideDiveMode(diveMode)
end
local setCameraRotateSpeed = function()
  local updateValue = function(level, member, arrTable)
    if arrTable then
      Z.LuaBridge.UpdatePlayerCameraSpeed(member, arrTable[level])
    else
      logError("setCameraRotateSpeed failed level={0} member={1}", level, member)
    end
  end
  local EContextMember = Z.PGame.EContextMember
  local hLevel = math.floor(get(E.SettingID.HorizontalSensitivity))
  local vLevel = math.floor(get(E.SettingID.VerticalSensitivity))
  updateValue(hLevel, EContextMember.CameraRotRateX, Z.Global.CameraHorizontalRange)
  updateValue(vLevel, EContextMember.CameraRotRateY, Z.Global.CameraVerticalRange)
end
local getLensCompensateId = function(settingId)
  return lensCompensateIds_[settingId]
end
local getAllLensCompensateId = function()
  return lensCompensateIds_
end
local convertEnumToVFXLevel = function(vfxIndexEnum)
  local settingData = Z.DataMgr.Get("setting_data")
  if Z.GameContext.IsPC then
    return settingData.VFXIndexMapPC[vfxIndexEnum]
  else
    return settingData.VFXIndexMapMobile[vfxIndexEnum]
  end
end
local getVFXLevelEnum = function(settingId)
  local valueIndex
  local settingData = Z.DataMgr.Get("setting_data")
  local vfxMap
  if Z.GameContext.IsPC then
    vfxMap = settingData.VFXIndexMapPC
  else
    vfxMap = settingData.VFXIndexMapMobile
  end
  local settingValue = get(settingId)
  local vfxLevelIndex = tonumber(settingValue)
  local useDefault = false
  if vfxLevelIndex then
    valueIndex = vfxLevelIndex
  else
    local grade = QualityGradeSetting.QualityGrade
    grade = (grade:ToInt() < EQualityGrade.ELow:ToInt() or grade:ToInt() > EQualityGrade.ECustom:ToInt()) and EQualityGrade.EVeryHigh or grade
    local idArrays = string.split(settingValue, "|")
    if idArrays and 0 < #idArrays then
      local idArrayString = Z.GameContext.IsPC and idArrays[1] or idArrays[2]
      local idArray = string.split(idArrayString, "=")
      valueIndex = tonumber(idArray[grade:ToInt() + 1])
    end
    useDefault = true
  end
  if valueIndex then
    for k, v in pairs(vfxMap) do
      if v == valueIndex then
        return k, useDefault
      end
    end
  end
  return E.SettingVFXLevel.Normal, useDefault
end
local imageQualityChanged = function()
  local vfxMap
  if Z.GameContext.IsPC then
    vfxMap = settingData.VFXIndexMapPC
  else
    vfxMap = settingData.VFXIndexMapMobile
  end
  local grade = QualityGradeSetting.QualityGrade
  grade = (grade:ToInt() < EQualityGrade.ELow:ToInt() or grade:ToInt() > EQualityGrade.ECustom:ToInt()) and EQualityGrade.EVeryHigh or grade
  if grade:ToInt() == EQualityGrade.ECustom:ToInt() then
    return
  end
  for k, v in pairs(settingData.SettingImageQuality2Effects) do
    local settingID = v
    local settingTbl = Z.TableMgr.GetTable("SettingsTableMgr")
    local row = settingTbl.GetRow(settingID)
    local idArrays = string.split(row.Value, "|")
    local settingVFXLevel = E.SettingVFXLevel.Normal
    if idArrays and 0 < #idArrays then
      local idArrayString = Z.GameContext.IsPC and idArrays[1] or idArrays[2]
      local idArray = string.split(idArrayString, "=")
      local valueIndex = tonumber(idArray[grade:ToInt() + 1])
      for k, v in pairs(vfxMap) do
        if v == valueIndex then
          settingVFXLevel = k
        end
      end
    end
    local level = convertEnumToVFXLevel(settingVFXLevel)
    set(settingID, level)
  end
  Z.LuaBridge.ImportEffectLimitGradeConf()
end
local getSwitchIsOn = function(id)
  local settingData = Z.DataMgr.Get("setting_data")
  local settingCfg = Z.TableMgr.GetTable("SettingsTableMgr").GetRow(id)
  local localSaveType = E.LocalUserDataType.Device
  if settingCfg and settingCfg.DataStorage then
    if settingCfg.DataStorage == settingData.DataStorage.ClientDeviceData then
      localSaveType = E.LocalUserDataType.Device
    elseif settingCfg.DataStorage == settingData.DataStorage.ClientEnvData then
      localSaveType = E.LocalUserDataType.Env
    elseif settingCfg.DataStorage == settingData.DataStorage.ClientAccountData then
      localSaveType = E.LocalUserDataType.Account
    elseif settingCfg.DataStorage == settingData.DataStorage.ClientCharacterData then
      localSaveType = E.LocalUserDataType.Character
    end
  end
  return Z.LocalUserDataMgr.GetIntByLua(localSaveType, string.format(Z.ConstValue.UserSetting.ConstStrSwitchGetInt, id), 1) == 1
end
local setSwitchIsOn = function(id, val)
  local settingData = Z.DataMgr.Get("setting_data")
  local settingCfg = Z.TableMgr.GetTable("SettingsTableMgr").GetRow(id)
  local localSaveType = E.LocalUserDataType.Device
  if settingCfg and settingCfg.DataStorage then
    if settingCfg.DataStorage == settingData.DataStorage.ClientDeviceData then
      localSaveType = E.LocalUserDataType.Device
    elseif settingCfg.DataStorage == settingData.DataStorage.ClientEnvData then
      localSaveType = E.LocalUserDataType.Env
    elseif settingCfg.DataStorage == settingData.DataStorage.ClientAccountData then
      localSaveType = E.LocalUserDataType.Account
    elseif settingCfg.DataStorage == settingData.DataStorage.ClientCharacterData then
      localSaveType = E.LocalUserDataType.Character
    end
  end
  local settingData_ = Z.DataMgr.Get("setting_data")
  local tag = val and settingData_.CanOpen.open or settingData_.CanOpen.close
  Z.LocalUserDataMgr.SetIntByLua(localSaveType, string.format(Z.ConstValue.UserSetting.ConstStrSwitchGetInt, id), tag)
end
local ret = {
  OpenSettingView = openSettingView,
  CloseSettingView = closeSettingView,
  AsyncSaveSetting = asyncSaveSetting,
  SetPlayerGlideAttr = setPlayerGlideAttr,
  SetCameraRotateSpeed = setCameraRotateSpeed,
  Get = get,
  Set = set,
  GetLensCompensateId = getLensCompensateId,
  GetAllLensCompensateId = getAllLensCompensateId,
  ConvertEnumToVFXLevel = convertEnumToVFXLevel,
  GetVFXLevelEnum = getVFXLevelEnum,
  ImageQualityChanged = imageQualityChanged,
  CloseSettingPopupView = closeSettingPopupView,
  OpenSettingPopupView = openSettingPopupView,
  SetSettingPopupViewShowed = setSettingPopupViewShowed,
  GetSwitchIsOn = getSwitchIsOn,
  SetSwitchIsOn = setSwitchIsOn
}
return ret
