local DungeonPrepare = {}
local worldTeamProxy = require("zproxy.world_proxy")

function DungeonPrepare.OpenView()
  Z.UIMgr:OpenView("hero_dungeon_prewar_popup")
end

function DungeonPrepare.CloseView()
  Z.UIMgr:CloseView("hero_dungeon_prewar_popup")
end

function DungeonPrepare.GetPrepareBuffInfo()
  local buffTypes = Z.Global.DungeonPrepareBuffType or {}
  local haveBuffMap = {}
  local typeCount = #buffTypes
  for index, buffType in ipairs(buffTypes) do
    haveBuffMap[buffType] = {buffId = buffType, buffTime = 0}
  end
  local buffItemMap = Z.BuffMgr:GetBuffItemMap(Z.EntityMgr.PlayerUuid)
  if buffItemMap then
    local index = 0
    for buffId, value in pairs(buffItemMap) do
      local buffRow = Z.TableMgr.GetRow("BuffTableMgr", buffId)
      if buffRow and haveBuffMap[buffRow.BuffAbilityType] and haveBuffMap[buffRow.BuffAbilityType].buffTime == 0 then
        haveBuffMap[buffRow.BuffAbilityType].buffTime = 1
        index = index + 1
        if index == typeCount then
          return haveBuffMap
        end
      end
    end
  end
  return table.zvalues(haveBuffMap)
end

function DungeonPrepare.GetDungeonPrepareInfo()
  local prepareInfo = {}
  local itemsVm = Z.VMMgr.GetVM("items")
  local reviveItemTab = {}
  local reviveItemIds = Z.Global.DungeonPrepareReviveItemId or {}
  for index, configId in ipairs(reviveItemIds) do
    reviveItemTab[index] = {
      itemId = configId,
      itemNum = itemsVm.GetItemTotalCount(configId)
    }
  end
  local revertItemIds = Z.Global.DungeonPrepareRecoveryItemId or {}
  local revertItemTab = {}
  for index, configId in ipairs(revertItemIds) do
    revertItemTab[index] = {
      itemId = configId,
      itemNum = itemsVm.GetItemTotalCount(configId)
    }
  end
  prepareInfo.revertInfo = revertItemTab
  prepareInfo.reviveInfo = reviveItemTab
  return prepareInfo
end

function DungeonPrepare.AsyncCancelPrepare(token)
  local data = {}
  data.isReady = false
  local ret = worldTeamProxy.TeamMemberReadyCheckReport(data, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function DungeonPrepare.AsyncConfirmPrepare(prepareInfo, token)
  local data = {
    isReady = true,
    buffs = prepareInfo.buffInfo,
    medicaments = prepareInfo.revertInfo,
    items = prepareInfo.reviveInfo
  }
  local ret = worldTeamProxy.TeamMemberReadyCheckReport(data, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function DungeonPrepare.ShowTips()
  local teamData = Z.DataMgr.Get("team_data")
  local members = teamData.TeamInfo.members
  local checkInfo = teamData.DungeonPrepareCheckInfo
  local str = ""
  for index, value in pairs(members) do
    if value.charId ~= teamData.TeamInfo.baseInfo.leaderId and (not checkInfo[value.charId] or not checkInfo[value.charId].isReady) then
      str = str .. value.socialData.basicData.name .. ","
    end
  end
  if str ~= "" then
    Z.TipsVM.ShowTips(1004113, {
      player = {name = str}
    })
  else
    Z.TipsVM.ShowTips(1004112)
  end
end

function DungeonPrepare.AsyncLeaderReadyCheck(token)
  local ret = worldTeamProxy.TeamLeaderReadyCheck(token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  else
    local teamData = Z.DataMgr.Get("team_data")
    Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.DungeonPrepareTime, function()
      Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.DungeonPrepareCD, function()
        DungeonPrepare.ShowTips()
        teamData.IsDungeonPrepareIng = false
        Z.EventMgr:Dispatch(Z.ConstValue.Team.EndDungeonPrepare)
      end, Z.Global.DungeonPrepareCD, 1)
    end, Z.Global.DungeonPrepareTime, 1)
    DungeonPrepare.OpenView()
    teamData.DungeonPrepareCheckInfo = {}
    teamData.IsDungeonPrepareIng = true
    teamData.DungeonPrepareBeginTime = Z.ServerTime:GetServerTime()
  end
  return ret
end

function DungeonPrepare.CancelReadyCheck()
  local teamData = Z.DataMgr.Get("team_data")
  DungeonPrepare.CloseView()
  Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.DungeonPrepareTime)
  Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.DungeonPrepareCD)
  if teamData.IsDungeonPrepareIng then
    Z.TipsVM.ShowTips(1004111)
  end
  teamData.DungeonPrepareCheckInfo = {}
  teamData.IsDungeonPrepareIng = false
  Z.EventMgr:Dispatch(Z.ConstValue.Team.EndDungeonPrepare)
end

return DungeonPrepare
