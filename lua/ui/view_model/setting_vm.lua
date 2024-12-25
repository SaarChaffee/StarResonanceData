local QualityGradeSetting = Panda.Utility.Quality.QualityGradeSetting
local settingTbl = Z.TableMgr.GetTable("SettingsTableMgr")
local settingData = Z.DataMgr.Get("setting_data")
local lensCompensateIds_ = {
  [E.SettingID.CameraTemplate] = 21,
  [E.SettingID.PitchAngleCorrection] = 22,
  [E.SettingID.BattleZoomCorrection] = 23,
  [E.SettingID.BattlePitchAngkeCorrection] = 26
}
local openSettingView = function()
  Z.UIMgr:OpenView("setting")
end
local closeSettingView = function()
  Z.UIMgr:CloseView("setting")
end
local asyncSaveSetting = function(setData)
  local npcProxy = require("zproxy.world_proxy")
  npcProxy.SaveSetting(setData)
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
    row = settingTbl.GetRow(id)
  end
  if row then
    if row.DataStorage == settingData.DataStorage.clientData then
      Z.LocalUserDataMgr.SetInt("BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.onlyClinetData then
      Z.LocalUserDataMgr.SetInt("BKL_SETID_" .. id, newValue, 0, true)
    elseif row.DataStorage == settingData.DataStorage.serverData then
      local npcProxy = require("zproxy.world_proxy")
      npcProxy.SaveSetting({
        [id] = tostring(newValue)
      })
    end
  else
    Z.LocalUserDataMgr.SetInt("BKL_CUSTOM_SETID_" .. id, newValue)
  end
end
local getInt = function(id)
  local row
  if 0 <= id then
    row = settingTbl.GetRow(id)
  end
  if row then
    local defaultValue = Mathf.Round(tonumber(row.Value))
    local value = defaultValue
    if row.DataStorage == settingData.DataStorage.clientData then
      local key = "BKL_SETID_" .. id
      value = Z.LocalUserDataMgr.GetInt(key, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.onlyClinetData then
      local key = "BKL_SETID_" .. id
      value = Z.LocalUserDataMgr.GetInt(key, defaultValue, 0, true)
    elseif row.DataStorage == settingData.DataStorage.serverData and Z.ContainerMgr.CharSerialize.settingData.settingMap[id] then
      value = Mathf.Round(tonumber(Z.ContainerMgr.CharSerialize.settingData.settingMap[id]))
    end
    return value
  else
    return Z.LocalUserDataMgr.GetInt("BKL_CUSTOM_SETID_" .. id, -99999)
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
    row = settingTbl.GetRow(id)
  end
  if row then
    if row.DataStorage == settingData.DataStorage.clientData then
      Z.LocalUserDataMgr.SetFloat("BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.onlyClinetData then
      Z.LocalUserDataMgr.SetFloat("BKL_SETID_" .. id, newValue, 0, true)
    elseif row.DataStorage == settingData.DataStorage.serverData then
      local npcProxy = require("zproxy.world_proxy")
      npcProxy.SaveSetting({
        [id] = tostring(newValue)
      })
    end
  else
    Z.LocalUserDataMgr.SetFloat("BKL_CUSTOM_SETID_" .. id, newValue)
  end
end
local getFloat = function(id)
  local row
  if 0 <= id then
    row = settingTbl.GetRow(id)
  end
  if row then
    local defaultValue = tonumber(row.Value)
    local value = defaultValue
    if row.DataStorage == settingData.DataStorage.clientData then
      value = Z.LocalUserDataMgr.GetFloat("BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.onlyClinetData then
      value = Z.LocalUserDataMgr.GetFloat("BKL_SETID_" .. id, defaultValue, 0, true)
    elseif row.DataStorage == settingData.DataStorage.serverData and Z.ContainerMgr.CharSerialize.settingData.settingMap[id] then
      value = tonumber(Z.ContainerMgr.CharSerialize.settingData.settingMap[id])
    end
    return value
  else
    return Z.LocalUserDataMgr.GetFloat("BKL_CUSTOM_SETID_" .. id, -99999.0)
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
    row = settingTbl.GetRow(id)
  end
  if row then
    if row.DataStorage == settingData.DataStorage.clientData then
      Z.LocalUserDataMgr.SetString("BKL_SETID_" .. id, newValue)
    elseif row.DataStorage == settingData.DataStorage.onlyClinetData then
      Z.LocalUserDataMgr.SetString("BKL_SETID_" .. id, newValue, 0, true)
    elseif row.DataStorage == settingData.DataStorage.serverData then
      local npcProxy = require("zproxy.world_proxy")
      npcProxy.SaveSetting({
        [id] = newValue
      })
    end
  else
    Z.LocalUserDataMgr.SetString("BKL_CUSTOM_SETID_" .. id, newValue)
  end
end
local getString = function(id)
  local row
  if 0 <= id then
    row = settingTbl.GetRow(id)
  end
  if row then
    local defaultValue = row.Value
    local value = defaultValue
    if row.DataStorage == settingData.DataStorage.clientData then
      value = Z.LocalUserDataMgr.GetString("BKL_SETID_" .. id, defaultValue)
    elseif row.DataStorage == settingData.DataStorage.onlyClinetData then
      value = Z.LocalUserDataMgr.GetString("BKL_SETID_" .. id, defaultValue, 0, true)
    elseif row.DataStorage == settingData.DataStorage.serverData then
      value = Z.ContainerMgr.CharSerialize.settingData.settingMap[id] or ""
    end
    return value
  else
    return Z.LocalUserDataMgr.GetString("BKL_CUSTOM_SETID_" .. id, "")
  end
end
local setGrade = function(id, value)
  local dataNumber = value.ShadowGrade * 10000 + value.PostEffectGrade * 1000 + value.SceneDetailGrade * 100 + value.CharDetailGrade * 10 + value.EffectEffectGrade
  local str = tostring(dataNumber)
  Z.LocalUserDataMgr.SetString("BKL_SETID_QUALITY_", str)
end
local getGrade = function(id)
  local str = Z.LocalUserDataMgr.GetString("BKL_SETID_QUALITY_", "")
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
  [E.SettingID.HorizontalSensitivity] = {get = getFloat, set = setFloat},
  [E.SettingID.VerticalSensitivity] = {get = getFloat, set = setFloat},
  [E.SettingID.Master] = {get = getFloat, set = setFloat},
  [E.SettingID.Bgm] = {get = getFloat, set = setFloat},
  [E.SettingID.Sfx] = {get = getFloat, set = setFloat},
  [E.SettingID.Voice] = {get = getFloat, set = setFloat},
  [E.SettingID.System] = {get = getFloat, set = setFloat},
  [E.SettingID.P3] = {get = getFloat, set = setFloat},
  [E.SettingID.LockOpen] = {get = getBoolean, set = setInt},
  [E.SettingID.CameraLockFirst] = {get = getBoolean, set = setInt},
  [E.SettingID.GlideDirectionCtrl] = {get = getInt, set = setInt},
  [E.SettingID.GlideDiveCtrl] = {get = getInt, set = setInt},
  [E.SettingID.KeyHint] = {get = getBoolean, set = setInt},
  [E.SettingID.CameraSeismicScreen] = {get = getBoolean, set = setInt},
  [E.SettingID.PulseScreen] = {get = getBoolean, set = setInt},
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
  [E.SettingID.NPCPlayerHeadInformation] = {get = getString, set = setString}
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
  if Z.IsPCUI then
    return settingData.VFXIndexMapPC[vfxIndexEnum]
  else
    return settingData.VFXIndexMapMobile[vfxIndexEnum]
  end
end
local getVFXLevelEnum = function(settingId)
  local valueIndex
  local settingData = Z.DataMgr.Get("setting_data")
  local vfxMap
  if Z.IsPCUI then
    vfxMap = settingData.VFXIndexMapPC
  else
    vfxMap = settingData.VFXIndexMapMobile
  end
  local settingValue = get(settingId)
  local vfxLevelIndex = tonumber(settingValue)
  if vfxLevelIndex then
    valueIndex = vfxLevelIndex
  else
    local idArray = string.split(settingValue, "=")
    if idArray and 0 < #idArray then
      if Z.IsPCUI then
        valueIndex = tonumber(idArray[1])
      else
        valueIndex = tonumber(idArray[2])
      end
    end
  end
  if valueIndex then
    for k, v in pairs(vfxMap) do
      if v == valueIndex then
        return k
      end
    end
  end
  return E.SettingVFXLevel.Normal
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
  GetVFXLevelEnum = getVFXLevelEnum
}
return ret
