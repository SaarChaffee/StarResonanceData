local monsterData = Z.DataMgr.Get("monster_data")
local deadStateId = Z.PbEnum("EActorState", "ActorStateDead")
local setBossUuid = function(uuid)
  if uuid == nil then
    monsterData.SelectBossInfo = {
      selectedBossUuid = nil,
      lastHp = nil,
      lastMaxHp = nil
    }
  else
    monsterData:UpdateData("SelectBossInfo", {selectedBossUuid = uuid})
  end
end
local updateBossList = function(bossUuid, isEnable, isALive)
  if monsterData.BossList == nil then
    monsterData.BossList = {}
  end
  if bossUuid ~= -1 then
    local isExist = false
    for i = 1, #monsterData.BossList do
      if monsterData.BossList[i].uuid == bossUuid then
        isExist = true
        if not isALive then
          table.remove(monsterData.BossList, i)
          break
        end
        monsterData.BossList[i].enabled = isEnable
        break
      end
    end
    if not isExist and isALive then
      local bossData = {}
      bossData.uuid = bossUuid
      bossData.enabled = isEnable
      table.insert(monsterData.BossList, bossData)
    end
  end
  if #monsterData.BossList == 0 then
    monsterData.BossTopUuid = 0
    return 0
  end
  local mainBossUuid = 0
  for i = 1, #monsterData.BossList do
    local data = monsterData.BossList[i]
    if data.enabled then
      mainBossUuid = data.uuid
      if monsterData.BossTopUuid == 0 or monsterData.BossTopUuid == data.uuid then
        break
      end
    end
  end
  return mainBossUuid
end
local closeBossUI = function()
  Z.UIMgr:CloseView("bossbattle")
end
local displayBossUI = function(bossUuid, isEnable, isALive)
  local uuid = updateBossList(bossUuid, isEnable, isALive)
  if uuid ~= 0 then
    if monsterData.SelectBossInfo and monsterData.SelectBossInfo.selectedBossUuid ~= uuid then
      closeBossUI()
    end
    setBossUuid(uuid)
    Z.UIMgr:OpenView("bossbattle")
  else
    setBossUuid(nil)
    closeBossUI()
  end
end
local setBossTop = function(topUuid)
  monsterData.BossTopUuid = topUuid
  displayBossUI(-1)
end
local getBossUuid = function()
  if monsterData.SelectBossInfo == nil then
    return nil
  end
  return monsterData.SelectBossInfo.selectedBossUuid
end
local checkHasBoss = function()
  return Z.EntityMgr:CheckHasBoss()
end
local checkBossBattleComplete = function()
  local state = Z.EntityMgr:CheckBossBattleComplete()
  if not state then
    local teamVm = Z.VMMgr.GetVM("team")
    local memberList = teamVm.GetTeamMemData()
    for i = 1, #memberList do
      local memberInfo = memberList[i]
      if deadStateId ~= memberInfo.state then
        return false
      end
    end
  end
  return true
end
local ret = {
  SetBossTop = setBossTop,
  DisplayBossUI = displayBossUI,
  CloseBossUI = closeBossUI,
  SetBossUuid = setBossUuid,
  GetBossUuid = getBossUuid,
  CheckHasBoss = checkHasBoss,
  CheckBossBattleComplete = checkBossBattleComplete
}
return ret
