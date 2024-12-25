local openEnvWindowView = function()
  Z.UIMgr:OpenView("env_window")
end
local closeEnvWindowView = function()
  Z.UIMgr:CloseView("env_window")
end
local getEquipResonance = function(portIndex)
  if Z.ContainerMgr.CharSerialize.resonance.installed == nil then
    return 0
  end
  local installedId = Z.ContainerMgr.CharSerialize.resonance.installed[portIndex]
  if installedId == nil or installedId == 0 then
    return 0
  end
  return installedId
end
local getSkillIdByResonance = function(resonanceId)
  local config = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr").GetRow(resonanceId)
  if config then
    local skillId = config.skill[1]
    return skillId or 0
  end
  return 0
end
local getResonanceTime = function(resonanceId)
  local time = Z.ContainerMgr.CharSerialize.resonance.resonances[resonanceId]
  if time == nil then
    time = 0
  end
  return time / 1000
end
local getResonanceRemainTime = function(resonanceId)
  local expireTime = getResonanceTime(resonanceId) - Z.ServerTime:GetServerTime() / 1000
  if expireTime < 0 then
    expireTime = 0
  end
  return math.floor(expireTime)
end
local checkSkillExpired = function(pos)
  local resonanceId = getEquipResonance(pos)
  if resonanceId == 0 then
    return true
  end
  return getResonanceRemainTime(resonanceId) <= 0
end
local getSkillRemainTime = function(pos)
  local resonanceId = getEquipResonance(pos)
  if resonanceId == 0 then
    return 0
  end
  return getResonanceRemainTime(resonanceId)
end
local getSkillTime = function(pos)
  local resonanceId = getEquipResonance(pos)
  if resonanceId == 0 then
    return 0
  end
  local config = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr").GetRow(resonanceId)
  if config then
    return config.Time
  end
  return 0
end
local checkSkillEquip = function(skillId)
  if Z.ContainerMgr.CharSerialize.resonance.installed == nil then
    return false
  end
  for index, value in ipairs(Z.ContainerMgr.CharSerialize.resonance.installed) do
    if value and value ~= 0 and skillId == getSkillIdByResonance(value) then
      return true
    end
  end
  return false
end
local checkResonanceActive = function(resonanceId)
  return Z.ContainerMgr.CharSerialize.resonance.resonances[resonanceId] ~= nil
end
local checkAnyResonanceActive = function()
  if Z.ContainerMgr.CharSerialize.resonance.resonances == nil then
    return false
  end
  for k, v in pairs(Z.ContainerMgr.CharSerialize.resonance.resonances) do
    if checkResonanceActive(k) then
      return true
    end
  end
  return false
end
local checkResonanceEquip = function(resonanceId)
  if Z.ContainerMgr.CharSerialize.resonance.installed == nil then
    return false
  end
  local installed = Z.ContainerMgr.CharSerialize.resonance.installed
  for index, value in ipairs(installed) do
    if value == resonanceId then
      return true
    end
  end
  return false
end
local asyncResonanceSkill = function(handleData, cancelToken)
  local entity = Z.EntityMgr:GetEntity(handleData)
  local configId = entity:GetLuaAttr(Z.PbAttrEnum("AttrId")).Value
  local resonanceTbl = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr").GetRow(configId)
  local pivotVm = Z.VMMgr.GetVM("pivot")
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.ResonanceReq(handleData, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  else
    Z.EntityMgr.PlayerEnt:PlayWorldEffectBySelf("effect/character/p_fx_saomiao", 1)
    Z.TipsVM.ShowTipsLang(130028)
    Z.EventMgr:Dispatch(Z.ConstValue.OnResonanceSuccess)
  end
  return true
end
local getInteractionName = function(handleData)
  local entity = Z.EntityMgr:GetEntity(handleData.uuid)
  local configId = entity:GetLuaAttr(Z.PbAttrEnum("AttrId")).Value
  local resonanceTbl = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr").GetRow(configId)
  local pivotVm = Z.VMMgr.GetVM("pivot")
  return Lang("resonce")
end
local asyncChangeResonanceSkill = function(pos, resonanceId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.InstallResonanceSkillReq(pos, resonanceId, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  return true
end
local getSkillState = function(resonanceId)
  local config = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr").GetRow(resonanceId)
  local isUnlock = true
  local isActive = checkResonanceActive(resonanceId)
  local isExpired = getResonanceRemainTime(resonanceId) <= 0
  local isEquip = checkResonanceEquip(resonanceId)
  if isUnlock then
    if isActive and isExpired then
      return E.EnvResonanceSkillState.Expired
    elseif isActive and isEquip then
      return E.EnvResonanceSkillState.Equip
    elseif isActive then
      return E.EnvResonanceSkillState.Active
    else
      return E.EnvResonanceSkillState.NotActive
    end
  else
    return E.EnvResonanceSkillState.Lock
  end
end
local getTrackResonanceDic = function()
  local resonanceUidDic = {}
  local dataList = Z.Global.EnvironmentResonancePresetObject
  resonanceUidDic[dataList[1]] = dataList[2]
  return resonanceUidDic
end
local isCanShowRedDot = function()
  if Z.ContainerMgr.CharSerialize.resonance.resonances == nil then
    return false, false
  end
  for k, v in pairs(Z.ContainerMgr.CharSerialize.resonance.resonances) do
    if checkResonanceEquip(k) then
      return false, true
    end
  end
  local isRedDowShown = Z.LocalUserDataMgr.GetInt(Z.ConstValue.PlayerPrefsKey.ResonanceRedDot, 0) == 1
  if isRedDowShown then
    return false, false
  end
  for k, v in pairs(Z.ContainerMgr.CharSerialize.resonance.resonances) do
    if checkResonanceActive(k) and 0 < getResonanceRemainTime(k) then
      return true, false
    end
  end
  return false, false
end
local checkEnvRedDot = function()
  local isCanShowRedDot, isResonanceEquip = isCanShowRedDot()
  if isResonanceEquip then
    Z.LocalUserDataMgr.SetInt(Z.ConstValue.PlayerPrefsKey.ResonanceRedDot, 1)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnResonancEnvironment, isCanShowRedDot)
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.EnvEnter1, isCanShowRedDot and 1 or 0)
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.EnvEnter2, isCanShowRedDot and 1 or 0)
end
local checkEnvActive = function()
  for i, v in pairs(Z.ContainerMgr.CharSerialize.resonance.resonances) do
    local time
    local config = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr").GetRow(i)
    if config then
      time = config.Time
    end
    if time and getResonanceRemainTime(i) >= time - 2 and Z.EntityMgr.PlayerEnt then
      Z.EntityMgr.PlayerEnt:PlayWorldEffectBySelf("effect/common_new/tips/p_fx_saomiao_2", 1)
      Z.TipsVM.ShowTipsLang(130028)
      Z.EventMgr:Dispatch(Z.ConstValue.OnResonanceSuccess)
      break
    end
  end
end
local addEnvWatcher = function()
  local resonance = Z.ContainerMgr.CharSerialize.resonance
  if resonance then
    resonance.Watcher:RegWatcher(function()
      checkEnvRedDot()
      checkEnvActive()
    end)
  end
  checkEnvRedDot()
end
local getScreenDistance = function(tranA, tranB)
  return Panda.LuaAsyncBridge.GetScreenDistance(tranA.position, tranB.position)
end
local ret = {
  OpenEnvWindowView = openEnvWindowView,
  CloseEnvWindowView = closeEnvWindowView,
  GetSkillIdByResonance = getSkillIdByResonance,
  GetEquipResonance = getEquipResonance,
  GetResonanceTime = getResonanceTime,
  GetResonanceRemainTime = getResonanceRemainTime,
  CheckResonanceActive = checkResonanceActive,
  CheckAnyResonanceActive = checkAnyResonanceActive,
  CheckSkillEquip = checkSkillEquip,
  GetSkillRemainTime = getSkillRemainTime,
  GetSkillTime = getSkillTime,
  CheckResonanceEquip = checkResonanceEquip,
  AsyncResonanceSkill = asyncResonanceSkill,
  GetInteractionName = getInteractionName,
  AsyncChangeResonanceSkill = asyncChangeResonanceSkill,
  CheckSkillExpired = checkSkillExpired,
  GetSkillState = getSkillState,
  GetTrackResonanceDic = getTrackResonanceDic,
  AddEnvWatcher = addEnvWatcher,
  IsCanShowRedDot = isCanShowRedDot,
  GetScreenDistance = getScreenDistance
}
return ret
