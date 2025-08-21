local openEnvWindowView = function()
  local weaponSkillVM = Z.VMMgr.GetVM("weapon_skill")
  weaponSkillVM.OpenWeaponSkillView(E.SkillType.EnvironmentSkill)
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
  if time == -1 then
    return time
  else
    return time / 1000
  end
end
local getResonanceRemainTime = function(resonanceId)
  local resonanceTime = getResonanceTime(resonanceId)
  if resonanceTime == -1 then
    return -1
  else
    local expireTime = resonanceTime - Z.ServerTime:GetServerTime() / 1000
    if expireTime < 0 then
      expireTime = 0
    end
    return math.floor(expireTime)
  end
end
local checkResonanceExpired = function(resonanceId)
  local remainTime = getResonanceRemainTime(resonanceId)
  if remainTime == -1 then
    return false
  else
    return remainTime <= 0
  end
end
local checkSkillExpired = function(pos)
  local resonanceId = getEquipResonance(pos)
  if resonanceId == 0 then
    return true
  end
  return checkResonanceExpired(resonanceId)
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
  if entity == nil then
    logError("entity is nil")
    return false
  end
  local configId = entity:GetLuaAttr(Z.PbAttrEnum("AttrId")).Value
  local resonanceTbl = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr").GetRow(configId)
  local pivotVm = Z.VMMgr.GetVM("pivot")
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.ResonanceReq(handleData, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  else
    if not Z.EntityMgr.PlayerEnt then
      logError("PlayerEnt is nil")
      return false
    end
    Z.EntityMgr.PlayerEnt:PlayWorldEffectBySelf("effect/character/p_fx_saomiao", 1)
    Z.TipsVM.ShowTipsLang(130028)
    Z.EventMgr:Dispatch(Z.ConstValue.OnResonanceSuccess)
  end
  return true
end
local getInteractionName = function(handleData)
  local entity = Z.EntityMgr:GetEntity(handleData.uuid)
  if entity == nil then
    logError("entity is nil")
    return ""
  end
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
  local isExpired = checkResonanceExpired(resonanceId)
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
  local isRedDowShown = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, Z.ConstValue.PlayerPrefsKey.ResonanceRedDot, 0) == 1
  if isRedDowShown then
    return false, false
  end
  for k, v in pairs(Z.ContainerMgr.CharSerialize.resonance.resonances) do
    if checkResonanceActive(k) and checkResonanceExpired(k) then
      return true, false
    end
  end
  return false, false
end
local checkEnvRedDot = function()
  local isCanShowRedDot, isResonanceEquip = isCanShowRedDot()
  if isResonanceEquip then
    Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, Z.ConstValue.PlayerPrefsKey.ResonanceRedDot, 1)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnResonancEnvironment, isCanShowRedDot)
  Z.RedPointMgr.UpdateNodeCount(E.RedType.EnvSkillPageBtn, isCanShowRedDot and 1 or 0)
end
local showResonanceEffect = function()
  if Z.EntityMgr.PlayerEnt then
    Z.EntityMgr.PlayerEnt:PlayWorldEffectBySelf("effect/common_new/tips/p_fx_saomiao_2", 1)
    Z.TipsVM.ShowTipsLang(130028)
    Z.EventMgr:Dispatch(Z.ConstValue.OnResonanceSuccess)
  end
end
local getScreenDistance = function(tranA, tranB)
  return Panda.LuaAsyncBridge.GetScreenDistance(tranA.position, tranB.position)
end
local ret = {
  OpenEnvWindowView = openEnvWindowView,
  GetSkillIdByResonance = getSkillIdByResonance,
  GetEquipResonance = getEquipResonance,
  GetResonanceTime = getResonanceTime,
  GetResonanceRemainTime = getResonanceRemainTime,
  CheckResonanceExpired = checkResonanceExpired,
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
  IsCanShowRedDot = isCanShowRedDot,
  GetScreenDistance = getScreenDistance,
  CheckEnvRedDot = checkEnvRedDot,
  ShowResonanceEffect = showResonanceEffect
}
return ret
