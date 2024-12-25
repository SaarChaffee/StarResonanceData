local fighterBtns_vm = {}

function fighterBtns_vm:RegisterEvent()
  Z.EventMgr:Add(Z.ConstValue.OnBattleResChange, self.OnBattleResChange, self)
  Z.EventMgr:Add(Z.ConstValue.OnChangeSkillSlot, self.onSkillSlotChange, self)
end

function fighterBtns_vm:OnBattleResChange()
  local keys = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrFightResourceIds")).Value
  local values = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrFightResources")).Value
  if keys == nil or values == nil then
    return
  end
  if keys.count ~= values.count then
    logError("[fighterbtns_vm] AttrFightResourceIds AttrFightResources not Equip")
    return
  end
  local weaponData = Z.DataMgr.Get("weapon_data")
  weaponData:ClearBattleRes()
  for i = 0, keys.count - 1 do
    weaponData:UpdateBattleRes(keys[i], values[i])
  end
end

function fighterBtns_vm:GetBattleResValue(k)
  local weaponData = Z.DataMgr.Get("weapon_data")
  local battleRes = weaponData.BattleRes
  return battleRes[k] or 0
end

function fighterBtns_vm:SetPlayerLastHpData(lastHp, lastMaxHp)
  local weaponData = Z.DataMgr.Get("weapon_data")
  weaponData.PlayerInfo.lastHp = lastHp
  weaponData.PlayerInfo.lastMaxHp = lastMaxHp
end

function fighterBtns_vm:calculatePlayerBlood(curHp, maxHp, shieldTotalValue)
  local weaponData = Z.DataMgr.Get("weapon_data")
  local lastHp = weaponData.PlayerInfo.lastHp
  local lastMaxHp = weaponData.PlayerInfo.lastMaxHp
  if lastHp == nil or lastMaxHp == nil then
    lastHp = curHp
    lastMaxHp = maxHp
  end
  self:SetPlayerLastHpData(curHp, maxHp)
  local stage = 0
  local progress1 = curHp / maxHp
  if maxHp < curHp + shieldTotalValue then
    progress1 = curHp / (maxHp + shieldTotalValue)
  end
  local progress2 = lastHp / maxHp
  if maxHp < lastHp + shieldTotalValue then
    progress2 = lastHp / (maxHp + shieldTotalValue)
  end
  progress1 = progress1 < 0.02 and 0.02 or progress1
  progress2 = progress2 < 0.02 and 0.02 or progress2
  local deltaProgress = progress2 - progress1
  local largeDropBloodPercent = Z.Global.LargeDropBloodPercent
  if maxHp == lastMaxHp then
    if 0 < deltaProgress and deltaProgress < largeDropBloodPercent then
      stage = 2
    elseif deltaProgress >= largeDropBloodPercent then
      stage = 3
    elseif deltaProgress < 0 then
      stage = 1
    end
  end
  return progress1, stage
end

function fighterBtns_vm:onSkillSlotChange(slotKey, tmpFlag, behave, isRemove)
  if not self.SkillSlotEventCache then
    self.SkillSlotEventCache = {}
  end
  if not isRemove then
    table.insert(self.SkillSlotEventCache, {
      slotKey = slotKey,
      tmpFlag = tmpFlag,
      behave = behave
    })
  else
    for idx = 1, #self.SkillSlotEventCache do
      local v = self.SkillSlotEventCache[idx]
      if v.slotKey == slotKey and v.tmpFlag == tmpFlag then
        self.SkillSlotEventCache[idx] = nil
        break
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.OnChangeSkillSlotByVm, slotKey, tmpFlag, behave)
end

function fighterBtns_vm:GetSkillSlotEventCache()
  return self.SkillSlotEventCache
end

function fighterBtns_vm:GetSkillPanelShow()
  local weaponData = Z.DataMgr.Get("weapon_data")
  return weaponData.SkillPanelToggleIsOn
end

function fighterBtns_vm:SetSkillPanelShow(isSwitch)
  local weaponData = Z.DataMgr.Get("weapon_data")
  weaponData.SkillPanelToggleIsOn = isSwitch
end

function fighterBtns_vm:GetAutoBattleFlag()
  return self.AutoBattleFlag
end

function fighterBtns_vm:SetAutoBattleFlag(flag)
  self.AutoBattleFlag = flag
end

function fighterBtns_vm:GetBtnContainerState()
  local templateData = {}
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  if not stateID or not Z.EntityMgr.PlayerEnt then
    return
  end
  if Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EMultiActionState).Value ~= 0 then
    templateData.Type = E.PlayerCtrlBtnTmpType.MulAction
    templateData.ForcedOpenSlot = E.SlotName.CancelMulAction
    return templateData
  end
  if Z.PbEnum("EActorState", "ActorStateSceneInteraction") == stateID then
    templateData.Type = E.PlayerCtrlBtnTmpType.Interactive
    return templateData
  end
  if Z.PbEnum("EActorState", "ActorStateClimb") == stateID then
    templateData.Type = E.PlayerCtrlBtnTmpType.Climb
    return templateData
  end
  if Z.PbEnum("EActorState", "ActorStateFlow") == stateID or Z.PbEnum("EActorState", "ActorStateGlide") == stateID then
    templateData.Type = E.PlayerCtrlBtnTmpType.FlowGlide
    templateData.IsChangeSkillPanel = false
    templateData.IsShowSkillCheckBtn = false
    templateData.PCShowBtnType = E.PlayerCtrlBtnPCShowBtnType.Less
    return templateData
  end
  if Z.PbEnum("EActorState", "ActorStateSwim") == stateID then
    templateData.Type = E.PlayerCtrlBtnTmpType.Swim
    templateData.IsChangeSkillPanel = false
    templateData.IsShowSkillCheckBtn = false
    templateData.PCShowBtnType = E.PlayerCtrlBtnPCShowBtnType.Less
    return templateData
  end
  if Z.PbEnum("EActorState", "ActorStatePedalWall") == stateID then
    templateData.Type = E.PlayerCtrlBtnTmpType.ClimbRun
    templateData.IsChangeSkillPanel = false
    templateData.IsShowSkillCheckBtn = false
    templateData.PCShowBtnType = E.PlayerCtrlBtnPCShowBtnType.Less
    return templateData
  end
  if Z.PbEnum("EActorState", "ActorStateTunnelFly") == stateID then
    templateData.Type = E.PlayerCtrlBtnTmpType.TunnelFly
    templateData.IsChangeSkillPanel = false
    templateData.IsShowSkillCheckBtn = false
    templateData.PCShowBtnType = E.PlayerCtrlBtnPCShowBtnType.Less
    return templateData
  end
  if Z.PbEnum("EActorState", "ActorStateRideControl") == stateID then
    templateData.Type = E.PlayerCtrlBtnTmpType.Vehicles
    templateData.IsChangeSkillPanel = false
    templateData.PCShowBtnType = E.PlayerCtrlBtnPCShowBtnType.Vehicles
    return templateData
  end
  if Z.EntityMgr.PlayerEnt.IsRiding then
    if Z.PbEnum("EActorState", "ActorStateRide") == stateID then
      templateData.Type = E.PlayerCtrlBtnTmpType.VehiclePassenger
      templateData.IsChangeSkillPanel = false
      templateData.PCShowBtnType = E.PlayerCtrlBtnPCShowBtnType.Less
      return templateData
    end
    templateData.Type = E.PlayerCtrlBtnTmpType.Vehicles
    templateData.IsChangeSkillPanel = false
    templateData.PCShowBtnType = E.PlayerCtrlBtnPCShowBtnType.Vehicles
    return templateData
  end
  templateData.Type = E.PlayerCtrlBtnTmpType.Default
  templateData.PCShowBtnType = E.PlayerCtrlBtnPCShowBtnType.Less
  return templateData
end

return fighterBtns_vm
