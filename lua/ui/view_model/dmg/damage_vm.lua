local world_proxy = require("zproxy.world_proxy")
local fightAttrData = Z.TableMgr.GetTable("FightAttrTableMgr").GetDatas()
local tempAttrData = Z.TableMgr.GetTable("TempAttrTableMgr").GetDatas()
local monsterTab = Z.TableMgr.GetTable("MonsterTableMgr").GetDatas()
local dummyTab = Z.TableMgr.GetTable("DummyTableMgr").GetDatas()
local buffData = Z.TableMgr.GetTable("BuffTableMgr").GetDatas()
local EDamageTypeHeal = Z.PbEnum("EDamageType", "Heal")
local dmgData = Z.DataMgr.Get("damage_data")
local EntChar = Z.PbEnum("EEntityType", "EntChar")
local openDamageView = function()
  Z.UIMgr:OpenView("dmg_control")
  Z.UIMgr:OpenView("dmg_data_panel")
end
local closeDamageView = function()
  Z.UIMgr:CloseView("damage")
end
local asynceSendSkillCmd = function(dataUuid, skillId, targetUuid)
  local gmProxy = require("zproxy.world_proxy")
  gmProxy.MonsterCastSkill(dataUuid, skillId, targetUuid)
end
local getDamageData = function()
  local data = {}
  data.allHit = 0
  data.allCount = 0
  data.timer = 0
  data.overHit = 0
  local byattuuid = 0
  local attuuid = 0
  if dmgData.ShowType == 0 then
    for key, value in pairs(dmgData.ShowDamageDatas) do
      for k, weapon in pairs(value.data) do
        for key, skill in pairs(weapon.data) do
          if dmgData.TypeIndex == 3 then
            data.allHit = data.allHit + skill.Hit
          else
            data.allHit = data.allHit + skill.sheildAndHpLessenValue
          end
          data.allCount = data.allCount + skill.count
          data.overHit = data.overHit + skill.overHit
        end
        data.timer = weapon.time + data.timer
      end
    end
  elseif dmgData.ShowType == 1 then
    for key, value in pairs(dmgData.ShowDamageDatas) do
      byattuuid = value.byAttUuid
      for k, weapon in pairs(value.data) do
        for key, skill in pairs(weapon.data) do
          if dmgData.TypeIndex == 3 then
            data.allHit = data.allHit + skill.Hit
          else
            data.allHit = data.allHit + skill.sheildAndHpLessenValue
          end
          data.allCount = data.allCount + skill.count
          data.overHit = data.overHit + skill.overHit
        end
      end
    end
    for key, value in pairs(dmgData.AllByAttUuid) do
      if value.uuid == byattuuid then
        data.timer = value.time
      end
    end
  else
    for key, value in pairs(dmgData.ShowDamageDatas) do
      attuuid = value.attUuid
      for k, weapon in pairs(value.data) do
        for key, skill in pairs(weapon.data) do
          if dmgData.TypeIndex == 3 then
            data.allHit = data.allHit + skill.Hit
          else
            data.allHit = data.allHit + skill.sheildAndHpLessenValue
          end
          data.allCount = data.allCount + skill.count
          data.overHit = data.overHit + skill.overHit
        end
      end
    end
    for key, value in pairs(dmgData.AllAttUuid) do
      if value.uuid == attuuid then
        data.timer = value.time
      end
    end
  end
  dmgData:SetTotalDamage(data.allHit)
  return data
end
local getModelData = function(modelId)
  local monsterTableMgr = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(modelId, true)
  if monsterTableMgr == nil then
    return nil
  end
  local modelTableMgr = Z.TableMgr.GetTable("ModelTableMgr").GetRow(monsterTableMgr.ModelID, true)
  if modelTableMgr == nil then
    return nil
  end
  return modelTableMgr
end
local getPartData = function(modelId)
  local modelTableMgr = getModelData(modelId)
  if modelTableMgr == nil then
    return nil
  end
  return modelTableMgr.BodyParts
end
local getBodyPartData = function(partId)
  local bodyPartsTab = Z.TableMgr.GetTable("BodyPartsTableMgr").GetRow(partId, true)
  if bodyPartsTab == nil then
    return
  end
  return bodyPartsTab
end
local refreshPartTab = function(oldTab)
  local nowTab = {}
  for key, value in pairs(oldTab) do
    if tonumber(value) ~= nil then
      local bodyPartsTab = getBodyPartData(tonumber(value))
      if bodyPartsTab ~= nil then
        table.insert(nowTab, value .. " " .. bodyPartsTab.BodyPartsDesc)
      end
    else
      table.insert(nowTab, value)
    end
  end
  return nowTab
end
local getModelId = function(uuid)
  local modelId = -1
  local entity = Z.EntityMgr:GetEntity(uuid)
  if not entity then
    modelId = -1
  else
    modelId = entity:GetLuaAttr(Z.PbAttrEnum("AttrId")).Value
  end
  return modelId
end
local refreshTab = function(oldTab)
  local nowTab = {}
  for key, value in pairs(oldTab) do
    if tonumber(value) then
      local modelId = getModelId(tonumber(value))
      local monsterTab = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(modelId, true)
      if monsterTab ~= nil then
        table.insert(nowTab, value .. " " .. monsterTab.Name)
      end
    else
      table.insert(nowTab, value)
    end
  end
  return nowTab
end
local getMonsterTab = function(monsterUuid)
  local modelId = getModelId(tonumber(monsterUuid))
  if modelId == -1 then
    return nil
  end
  local monsterTab = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(modelId, true)
  if monsterTab == nil then
    return nil
  end
  return monsterTab
end
local getDummyTabByUuid = function(dummyUuid)
  local modelId = getModelId(tonumber(dummyUuid))
  if modelId == -1 then
    return nil
  end
  local dummyTab = Z.TableMgr.GetTable("DummyTableMgr").GetRow(modelId, true)
  if dummyTab == nil then
    return nil
  end
  return dummyTab
end
local getMonsterlSkills = function(monsterUuid)
  local monsterData = getMonsterTab(monsterUuid)
  if monsterData then
    local skillTab = {}
    for key, value in pairs(monsterData.SkillIds) do
      local skillCfgData = Z.TableMgr.GetTable("SkillTableMgr").GetRow(value, true)
      if skillCfgData then
        table.insert(skillTab, tostring(value) .. " " .. skillCfgData.NameDesign)
      end
    end
    return skillTab
  end
  return nil
end
local getDummySkills = function(dummyUuid)
  local dummyData = getDummyTabByUuid(dummyUuid)
  if dummyData then
    local skillTab = {}
    for key, value in pairs(dummyData.SkillIds) do
      local skillCfgData = Z.TableMgr.GetTable("SkillTableMgr").GetRow(value, true)
      if skillCfgData then
        table.insert(skillTab, tostring(value) .. " " .. skillCfgData.NameDesign)
      end
    end
    local skillCfgData = Z.TableMgr.GetTable("SkillTableMgr").GetRow(dummyData.SkillId, true)
    if skillCfgData then
      table.insert(skillTab, tostring(dummyData.SkillId) .. " " .. skillCfgData.NameDesign)
    end
    return skillTab
  end
  return nil
end
local toPlayerDictance = function(uuid)
  return Z.DamageData:ToPlayerDictance(uuid)
end
local sortMonsterTab = function(modelTabs)
  table.sort(modelTabs, function(a, b)
    local modelIdA = getMonsterTab(tonumber(a))
    local modelIdB = getMonsterTab(tonumber(b))
    if modelIdA and modelIdB then
      if modelIdB.MonsterType < modelIdA.MonsterType then
        return true
      elseif modelIdB.MonsterType == modelIdA.MonsterType then
        return toPlayerDictance(tonumber(a)) < toPlayerDictance(tonumber(b))
      else
        return false
      end
    end
    return false
  end)
end
local selectPart = function(sign)
  local entityVM = Z.VMMgr.GetVM("entity")
  local tab = {}
  if dmgData.SelectAttUuid == Lang("DamageAllData") then
    if dmgData.SelectByAttUuid == Lang("DamageAllData") then
    elseif dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
    elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
    else
      if dmgData.SelectByAttUuid == Lang("Team") then
      else
      end
    end
  elseif dmgData.SelectAttUuid == Lang("DamageAllTxt") then
    dmgData.ShowType = 1
    if dmgData.SelectByAttUuid == Lang("DamageAllData") or dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
    elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
      for key, value in pairs(dmgData.DamageDatas) do
        if (value.byAttUuid == tonumber(dmgData.PlayerUuid) and value.patrUuid ~= 0 and sign == 0 or value.patrUuid == tonumber(dmgData.SelectPartId)) and value.hitType ~= EDamageTypeHeal then
          table.insert(tab, value)
        end
      end
    elseif dmgData.SelectByAttUuid == Lang("Team") then
      local teamVm = Z.VMMgr.GetVM("team")
      local members = teamVm.GetTeamMemData()
      if 0 < table.zcount(members) then
        for index, member in ipairs(members) do
          local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
          for key, value in pairs(dmgData.DamageDatas) do
            if (value.byAttUuid == uuid and value.patrUuid ~= 0 and sign == 0 or value.patrUuid == tonumber(dmgData.SelectPartId)) and value.hitType ~= EDamageTypeHeal then
              table.insert(tab, value)
            end
          end
        end
      end
    else
      for key, value in pairs(dmgData.DamageDatas) do
        if (value.byAttUuid == tonumber(dmgData.SelectByAttUuid) and value.patrUuid ~= 0 and sign == 0 or value.patrUuid == tonumber(dmgData.SelectPartId)) and value.hitType ~= EDamageTypeHeal then
          table.insert(tab, value)
        end
      end
    end
  elseif dmgData.SelectAttUuid == Lang("DamageSelfTxt") then
    if dmgData.SelectByAttUuid == Lang("DamageAllData") then
    elseif dmgData.SelectByAttUuid == Lang("Team") or dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
    elseif dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
      dmgData.ShowType = 2
      for key, value in pairs(dmgData.DamageDatas) do
        if (sign == 0 or value.patrUuid == tonumber(dmgData.SelectPartId)) and value.hitType ~= EDamageTypeHeal then
          table.insert(tab, value)
        end
      end
    else
      dmgData.ShowType = 0
      for key, value in pairs(dmgData.DamageDatas) do
        if (value.byAttUuid == tonumber(dmgData.SelectByAttUuid) and value.patrUuid ~= 0 and sign == 0 or value.patrUuid == tonumber(dmgData.SelectPartId)) and value.hitType ~= EDamageTypeHeal then
          table.insert(tab, value)
        end
      end
    end
  elseif dmgData.SelectAttUuid == Lang("Team") then
    if dmgData.SelectByAttUuid == Lang("DamageAllData") then
    elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
      local teamVm = Z.VMMgr.GetVM("team")
      local members = teamVm.GetTeamMemData()
      if 0 < table.zcount(members) then
        for index, member in ipairs(members) do
          local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
          for key, value in pairs(dmgData.DamageDatas) do
            if (value.attUuid == uuid and value.patrUuid ~= 0 and sign == 0 or value.patrUuid == tonumber(dmgData.SelectPartId)) and value.hitType ~= EDamageTypeHeal then
              table.insert(tab, value)
            end
          end
        end
      end
    elseif dmgData.SelectByAttUuid == Lang("Team") or dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
    else
      local teamVm = Z.VMMgr.GetVM("team")
      local members = teamVm.GetTeamMemData()
      if 0 < table.zcount(members) then
        for index, member in ipairs(members) do
          local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
          for key, value in pairs(dmgData.DamageDatas) do
            if value.byAttUuid == tonumber(dmgData.SelectByAttUuid) and value.attUuid == uuid and value.patrUuid ~= 0 and (sign == 0 or value.patrUuid == tonumber(dmgData.SelectPartId)) and value.hitType ~= EDamageTypeHeal then
              table.insert(tab, value)
            end
          end
        end
      end
    end
  elseif dmgData.SelectByAttUuid == 1 then
    dmgData.ShowType = 2
    for key, value in pairs(dmgData.DamageDatas) do
      if (value.attUuid == tonumber(dmgData.SelectAttUuid) and value.patrUuid ~= 0 and sign == 0 or value.patrUuid == tonumber(dmgData.SelectPartId)) and value.hitType ~= EDamageTypeHeal then
        table.insert(tab, value)
      end
    end
  elseif dmgData.SelectByAttUuid == 1 then
    dmgData.ShowType = 0
    for key, value in pairs(dmgData.DamageDatas) do
      if value.attUuid == tonumber(dmgData.SelectAttUuid) and value.byAttUuid == tonumber(dmgData.PlayerUuid) and value.patrUuid ~= 0 and (sign == 0 or value.patrUuid == tonumber(dmgData.SelectPartId)) and value.hitType ~= EDamageTypeHeal then
        table.insert(tab, value)
      end
    end
  else
    dmgData.ShowType = 0
    for key, value in pairs(dmgData.DamageDatas) do
      if value.byAttUuid == tonumber(dmgData.Target[dmgData.SelectByAttUuid]) and value.attUuid == tonumber(dmgData.SelectAttUuid) and value.patrUuid ~= 0 and (sign == 0 or value.patrUuid == tonumber(dmgData.SelectPartId)) and value.hitType ~= EDamageTypeHeal then
        table.insert(tab, value)
      end
    end
  end
  dmgData:SetShowDmgData(tab)
end
local selectBody = function(type)
  local entityVM = Z.VMMgr.GetVM("entity")
  local tab = {}
  if dmgData.SelectAttUuid == Lang("DamageAllData") then
    if dmgData.SelectByAttUuid == Lang("DamageAllData") or dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
    elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
    else
      if dmgData.SelectByAttUuid == Lang("Team") then
      else
      end
    end
  elseif dmgData.SelectAttUuid == Lang("DamageAllTxt") then
    dmgData.ShowType = 1
    if dmgData.SelectByAttUuid == Lang("DamageAllData") or dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
    elseif dmgData.SelectByAttUuid == Lang("Team") then
      local teamVm = Z.VMMgr.GetVM("team")
      local members = teamVm.GetTeamMemData()
      if table.zcount(members) > 0 then
        for index, member in ipairs(members) do
          local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
          for index, value in ipairs(dmgData.DamageDatas) do
            if value.byAttUuid == uuid and value.patrUuid == 0 then
              if type == nil and value.hitType ~= EDamageTypeHeal then
                table.insert(tab, value)
              elseif type == value.hitType then
                table.insert(tab, value)
              end
            end
          end
        end
      end
    elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
      for key, value in pairs(dmgData.DamageDatas) do
        if value.byAttUuid == tonumber(dmgData.PlayerUuid) and value.patrUuid == 0 then
          if type == nil and value.hitType ~= EDamageTypeHeal then
            table.insert(tab, value)
          elseif type == value.hitType then
            table.insert(tab, value)
          end
        end
      end
    else
      for key, value in pairs(dmgData.DamageDatas) do
        if value.byAttUuid == tonumber(dmgData.SelectByAttUuid) and value.patrUuid == 0 then
          if type == nil and value.hitType ~= EDamageTypeHeal then
            table.insert(tab, value)
          elseif type == value.hitType then
            table.insert(tab, value)
          end
        end
      end
    end
  elseif dmgData.SelectAttUuid == Lang("DamageSelfTxt") then
    if dmgData.SelectByAttUuid == Lang("DamageAllData") then
    elseif dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
      dmgData.ShowType = 2
      for key, value in pairs(dmgData.DamageDatas) do
        if value.attUuid == tonumber(dmgData.PlayerUuid) and value.patrUuid == 0 then
          if type == nil and value.hitType ~= EDamageTypeHeal then
            table.insert(tab, value)
          elseif type == value.hitType then
            table.insert(tab, value)
          end
        end
      end
    elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
      for index, value in ipairs(dmgData.DamageDatas) do
        if value.attUuid == tonumber(dmgData.PlayerUuid) and tonumber(dmgData.PlayerUuid) == value.byAttUuid and value.patrUuid == 0 then
          if type == nil and value.hitType ~= EDamageTypeHeal then
            table.insert(tab, value)
          elseif type == value.hitType then
            table.insert(tab, value)
          end
        end
      end
    elseif dmgData.SelectByAttUuid == Lang("Team") then
      local teamVm = Z.VMMgr.GetVM("team")
      local members = teamVm.GetTeamMemData()
      if table.zcount(members) > 0 then
        for index, member in ipairs(members) do
          local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
          for index, value in ipairs(dmgData.DamageDatas) do
            if value.attUuid == tonumber(dmgData.PlayerUuid) and uuid == value.byAttUuid and value.patrUuid == 0 then
              if type == nil and value.hitType ~= EDamageTypeHeal then
                table.insert(tab, value)
              elseif type == value.hitType then
                table.insert(tab, value)
              end
            end
          end
        end
      end
    else
      dmgData.ShowType = 0
      for key, value in pairs(dmgData.DamageDatas) do
        if value.byAttUuid == tonumber(dmgData.SelectByAttUuid) and value.attUuid == tonumber(dmgData.PlayerUuid) and value.patrUuid == 0 then
          if type == nil and value.hitType ~= EDamageTypeHeal then
            table.insert(tab, value)
          elseif type == value.hitType then
            table.insert(tab, value)
          end
        end
      end
    end
  elseif dmgData.SelectAttUuid == Lang("Team") then
    if dmgData.SelectByAttUuid == Lang("DamageAllData") then
    elseif dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
      local teamVm = Z.VMMgr.GetVM("team")
      local members = teamVm.GetTeamMemData()
      if table.zcount(members) > 0 then
        for index, member in ipairs(members) do
          local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
          for index, value in ipairs(dmgData.DamageDatas) do
            if value.attUuid == uuid and value.patrUuid == 0 then
              if type == nil and value.hitType ~= EDamageTypeHeal then
                table.insert(tab, value)
              elseif type == value.hitType then
                table.insert(tab, value)
              end
            end
          end
        end
      end
    elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
      local teamVm = Z.VMMgr.GetVM("team")
      local members = teamVm.GetTeamMemData()
      if table.zcount(members) > 0 then
        for index, member in ipairs(members) do
          local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
          for index, value in ipairs(dmgData.DamageDatas) do
            if value.attUuid == uuid and tonumber(dmgData.PlayerUuid) == value.byAttUuid and value.patrUuid == 0 then
              if type == nil and value.hitType ~= EDamageTypeHeal then
                table.insert(tab, value)
              elseif type == value.hitType then
                table.insert(tab, value)
              end
            end
          end
        end
      end
    elseif dmgData.SelectByAttUuid == Lang("Team") then
      local teamVm = Z.VMMgr.GetVM("team")
      local members = teamVm.GetTeamMemData()
      if table.zcount(members) > 0 then
        local teamUuids = {}
        for index, member in ipairs(members) do
          local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
          teamUuids[uuid] = 1
        end
        for key, value in pairs(teamUuids) do
          for index, value in ipairs(dmgData.DamageDatas) do
            if teamUuids[value.attUuid] and teamUuids[value.byAttUuid] and value.patrUuid == 0 then
              if type == nil and value.hitType ~= EDamageTypeHeal then
                table.insert(tab, value)
              elseif type == value.hitType then
                table.insert(tab, value)
              end
            end
          end
        end
      end
    else
      local teamVm = Z.VMMgr.GetVM("team")
      local members = teamVm.GetTeamMemData()
      if table.zcount(members) > 0 then
        for index, member in ipairs(members) do
          local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
          for index, value in ipairs(dmgData.DamageDatas) do
            if value.attUuid == uuid and value.byAttUuid == tonumber(dmgData.SelectByAttUuid) and value.patrUuid == 0 then
              if type == nil and value.hitType ~= EDamageTypeHeal then
                table.insert(tab, value)
              elseif type == value.hitType then
                table.insert(tab, value)
              end
            end
          end
        end
      end
    end
  elseif dmgData.SelectByAttUuid == Lang("DamageAllData") then
  elseif dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
    dmgData.ShowType = 2
    for key, value in pairs(dmgData.DamageDatas) do
      if value.attUuid == tonumber(dmgData.SelectAttUuid) and value.attUuid == tonumber(dmgData.SelectAttUuid) and value.patrUuid == 0 then
        if type == nil and value.hitType ~= EDamageTypeHeal then
          table.insert(tab, value)
        elseif type == value.hitType then
          table.insert(tab, value)
        end
      end
    end
  elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
    dmgData.ShowType = 0
    for key, value in pairs(dmgData.DamageDatas) do
      if value.attUuid == tonumber(dmgData.SelectAttUuid) and value.byAttUuid == tonumber(dmgData.PlayerUuid) and value.patrUuid == 0 then
        if type == nil and value.hitType ~= EDamageTypeHeal then
          table.insert(tab, value)
        elseif type == value.hitType then
          table.insert(tab, value)
        end
      end
    end
  elseif dmgData.SelectByAttUuid == Lang("Team") then
    local teamVm = Z.VMMgr.GetVM("team")
    local members = teamVm.GetTeamMemData()
    if table.zcount(members) > 0 then
      for index, member in ipairs(members) do
        local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
        for index, value in ipairs(dmgData.DamageDatas) do
          if value.attUuid == dmgData.SelectAttUuid and uuid == value.byAttUuid and value.patrUuid == 0 then
            if type == nil and value.hitType ~= EDamageTypeHeal then
              table.insert(tab, value)
            elseif type == value.hitType then
              table.insert(tab, value)
            end
          end
        end
      end
    end
  else
    dmgData.ShowType = 0
    for key, value in pairs(dmgData.DamageDatas) do
      if value.byAttUuid == tonumber(dmgData.SelectByAttUuid) and value.attUuid == tonumber(dmgData.SelectAttUuid) and value.patrUuid == 0 then
        if type == nil and value.hitType ~= EDamageTypeHeal then
          table.insert(tab, value)
        elseif type == value.hitType then
          table.insert(tab, value)
        end
      end
    end
  end
  dmgData:SetShowDmgData(tab)
end
local selectTakeDmgBody = function(type)
  local entityVM = Z.VMMgr.GetVM("entity")
  local tab = {}
  if dmgData.SelectAttUuid == Lang("DamageAllData") then
    if dmgData.SelectByAttUuid == Lang("DamageAllData") or dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
    elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
    else
      if dmgData.SelectByAttUuid == Lang("Team") then
      else
      end
    end
  elseif dmgData.SelectAttUuid == Lang("DamageAllTxt") then
    dmgData.ShowType = 1
    if dmgData.SelectByAttUuid == Lang("DamageAllData") or dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
    elseif dmgData.SelectByAttUuid == Lang("Team") then
      local teamVm = Z.VMMgr.GetVM("team")
      local members = teamVm.GetTeamMemData()
      if table.zcount(members) > 0 then
        for index, member in ipairs(members) do
          local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
          for index, value in ipairs(dmgData.DamageDatas) do
            if value.byAttUuid == uuid and value.patrUuid == 0 then
              if type == nil and value.hitType ~= EDamageTypeHeal then
                table.insert(tab, value)
              elseif type == value.hitType then
                table.insert(tab, value)
              end
            end
          end
        end
      end
    elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
      for key, value in pairs(dmgData.DamageDatas) do
        if value.attUuid == tonumber(dmgData.PlayerUuid) and value.patrUuid == 0 then
          if type == nil and value.hitType ~= EDamageTypeHeal then
            table.insert(tab, value)
          elseif type == value.hitType then
            table.insert(tab, value)
          end
        end
      end
    else
      for key, value in pairs(dmgData.DamageDatas) do
        if value.attUuid == tonumber(dmgData.SelectByAttUuid) and value.patrUuid == 0 then
          if type == nil and value.hitType ~= EDamageTypeHeal then
            table.insert(tab, value)
          elseif type == value.hitType then
            table.insert(tab, value)
          end
        end
      end
    end
  elseif dmgData.SelectAttUuid == Lang("DamageSelfTxt") then
    if dmgData.SelectByAttUuid == Lang("DamageAllData") then
    elseif dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
      dmgData.ShowType = 2
      for key, value in pairs(dmgData.DamageDatas) do
        if value.byAttUuid == tonumber(dmgData.PlayerUuid) and value.patrUuid == 0 then
          if type == nil and value.hitType ~= EDamageTypeHeal then
            table.insert(tab, value)
          elseif type == value.hitType then
            table.insert(tab, value)
          end
        end
      end
    elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") or dmgData.SelectByAttUuid == Lang("Team") then
    else
      dmgData.ShowType = 0
      for key, value in pairs(dmgData.DamageDatas) do
        if value.byAttUuid == tonumber(dmgData.PlayerUuid) and value.attUuid == tonumber(dmgData.SelectByAttUuid) and value.patrUuid == 0 then
          if type == nil and value.hitType ~= EDamageTypeHeal then
            table.insert(tab, value)
          elseif type == value.hitType then
            table.insert(tab, value)
          end
        end
      end
    end
  elseif dmgData.SelectAttUuid == Lang("Team") then
    if dmgData.SelectByAttUuid == Lang("DamageAllData") then
    elseif dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
      local teamVm = Z.VMMgr.GetVM("team")
      local members = teamVm.GetTeamMemData()
      if table.zcount(members) > 0 then
        for index, member in ipairs(members) do
          local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
          for index, value in ipairs(dmgData.DamageDatas) do
            if value.byAttUuid == uuid and value.patrUuid == 0 then
              if type == nil and value.hitType ~= EDamageTypeHeal then
                table.insert(tab, value)
              elseif type == value.hitType then
                table.insert(tab, value)
              end
            end
          end
        end
      end
    elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") or dmgData.SelectByAttUuid == Lang("Team") then
    else
      local teamVm = Z.VMMgr.GetVM("team")
      local members = teamVm.GetTeamMemData()
      if table.zcount(members) > 0 then
        for index, member in ipairs(members) do
          local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
          for index, value in ipairs(dmgData.DamageDatas) do
            if value.byAttUuid == uuid and value.attUuid == tonumber(dmgData.SelectByAttUuid) and value.patrUuid == 0 then
              if type == nil and value.hitType ~= EDamageTypeHeal then
                table.insert(tab, value)
              elseif type == value.hitType then
                table.insert(tab, value)
              end
            end
          end
        end
      end
    end
  elseif dmgData.SelectByAttUuid == Lang("DamageAllData") then
  elseif dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
    dmgData.ShowType = 2
    for key, value in pairs(dmgData.DamageDatas) do
      if value.byAttUuid == tonumber(dmgData.SelectAttUuid) and value.patrUuid == 0 then
        if type == nil and value.hitType ~= EDamageTypeHeal then
          table.insert(tab, value)
        elseif type == value.hitType then
          table.insert(tab, value)
        end
      end
    end
  elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
    dmgData.ShowType = 0
    for key, value in pairs(dmgData.DamageDatas) do
      if value.attUuid == tonumber(dmgData.PlayerUuid) and value.byAttUuid == tonumber(dmgData.SelectAttUuid) and value.patrUuid == 0 then
        if type == nil and value.hitType ~= EDamageTypeHeal then
          table.insert(tab, value)
        elseif type == value.hitType then
          table.insert(tab, value)
        end
      end
    end
  elseif dmgData.SelectByAttUuid == Lang("Team") then
    local teamVm = Z.VMMgr.GetVM("team")
    local members = teamVm.GetTeamMemData()
    if table.zcount(members) > 0 then
      for index, member in ipairs(members) do
        local uuid = entityVM.EntIdToUuid(member.charId, EntChar)
        for index, value in ipairs(dmgData.DamageDatas) do
          if value.byAttUuid == dmgData.SelectAttUuid and uuid == value.attUuid and value.patrUuid == 0 then
            if type == nil and value.hitType ~= EDamageTypeHeal then
              table.insert(tab, value)
            elseif type == value.hitType then
              table.insert(tab, value)
            end
          end
        end
      end
    end
  else
    dmgData.ShowType = 0
    for key, value in pairs(dmgData.DamageDatas) do
      if value.attUuid == tonumber(dmgData.SelectByAttUuid) and value.byAttUuid == tonumber(dmgData.SelectAttUuid) and value.patrUuid == 0 then
        if type == nil and value.hitType ~= EDamageTypeHeal then
          table.insert(tab, value)
        elseif type == value.hitType then
          table.insert(tab, value)
        end
      end
    end
  end
  dmgData:SetTakeDmgData(tab)
end
local changeDrowIndex = function()
  local data = dmgData
  data.ShowDamageDatas = {}
  if data.TypeIndex == 1 then
    if data.SelectPartId == Lang("DamagePartTxt") then
      selectBody()
    elseif data.SelectPartId == Lang("DamageAllPartTxt") then
      selectPart(0)
    else
      selectPart(1)
    end
  elseif data.TypeIndex == 2 then
    selectBody(Z.PbEnum("EDamageType", "Heal"))
  elseif data.TypeIndex == 3 then
    selectTakeDmgBody()
  end
  getDamageData()
  Z.EventMgr:Dispatch(Z.ConstValue.Damage.RefreshPanel)
end
local isExsit = function(attUuid, tab)
  return table.zcontains(tab, attUuid)
end
local addTab = function(tab, uuid, uuid2)
  local data = dmgData
  if table.zcount(data.NearByEnity) > 0 then
    for key, value in pairs(data.NearByEnity) do
      if table.zcount(tab) < 15 then
        if value ~= tostring(uuid) and value ~= tostring(uuid2) and not isExsit(value, tab) then
          table.insert(tab, value)
        end
      else
        return
      end
    end
  end
end
local nowAllAttandByAtt = function()
  local data = dmgData
  local body = {}
  local target = {}
  if table.zcount(data.DamageDatas) > 0 then
    for key, value in pairs(data.DamageDatas) do
      if value.attUuid ~= data.NowAttUuid and table.zcount(body) < 15 and value.attUuid ~= tonumber(data.PlayerUuid) and value.attUuid ~= data.NowByAttUuid and not isExsit(tostring(value.attUuid), body) then
        table.insert(body, tostring(value.attUuid))
      end
      if value.byAttUuid ~= data.NowByAttUuid and table.zcount(body) < 15 and value.byAttUuid ~= tonumber(data.PlayerUuid) and value.byAttUuid ~= data.NowAttUuid and not isExsit(tostring(value.byAttUuid), body) then
        table.insert(body, tostring(value.byAttUuid))
      end
      if value.byAttUuid ~= data.NowByAttUuid and table.zcount(target) < 15 and value.byAttUuid ~= data.NowAttUuid and not isExsit(tostring(value.byAttUuid), target) then
        table.insert(target, tostring(value.byAttUuid))
      end
      if value.attUuid ~= data.NowAttUuid and table.zcount(target) < 15 and value.attUuid ~= tonumber(data.PlayerUuid) and value.attUuid ~= data.NowByAttUuid and not isExsit(tostring(value.attUuid), target) then
        table.insert(target, tostring(value.attUuid))
      end
    end
  end
  sortMonsterTab(body)
  sortMonsterTab(target)
  if table.zcount(body) < 15 then
    addTab(body, data.NowAttUuid, data.NowByAttUuid)
  end
  if table.zcount(target) < 15 then
    addTab(target, data.NowAttUuid, data.NowByAttUuid)
  end
  if data.NowAttUuid ~= 0 then
    if tostring(data.NowAttUuid) == data.PlayerUuid then
      table.insert(target, 1, tostring(data.NowByAttUuid))
      table.insert(body, 1, tostring(data.NowByAttUuid))
    elseif tostring(data.NowByAttUuid) == data.PlayerUuid then
      table.insert(body, 1, tostring(data.NowAttUuid))
      table.insert(target, 1, tostring(data.NowAttUuid))
    else
      table.insert(body, 1, tostring(data.NowAttUuid))
      table.insert(body, 1, tostring(data.NowByAttUuid))
      table.insert(target, 1, tostring(data.NowAttUuid))
      table.insert(target, 1, tostring(data.NowByAttUuid))
    end
  end
  data:SetTargetTab(table.zclone(target))
  data:SetBodyTab(table.zclone(body))
  data:SetBuffTargetTab(table.zclone(body))
  data:SetAttrTargetTab(table.zclone(body))
  data:Init()
  Z.EventMgr:Dispatch(Z.ConstValue.Damage.RefreshDropDown)
end
local getNearEntityByType = function(type)
  if type == nil then
    return nil
  end
  local monsterUuidTab = Z.DamageData:GetNearEntityByType(type)
  local modelTabs = {}
  for i = 0, monsterUuidTab.count - 1 do
    table.insert(modelTabs, #modelTabs + 1, monsterUuidTab[i])
  end
  monsterUuidTab:Recycle()
  if 0 < table.zcount(modelTabs) then
    return modelTabs
  end
  return nil
end
local setNearMosterTab = function()
  local tab = getNearEntityByType(Z.PbEnum("EEntityType", "EntMonster"))
  dmgData.ControlNearMonsterTab = {}
  if tab then
    for key, value in pairs(tab) do
      local monsterTab = getMonsterTab(value)
      local targetName
      if monsterTab then
        targetName = monsterTab.Name
      end
      table.insert(dmgData.ControlNearMonsterTab, value .. " " .. targetName)
    end
    table.insert(dmgData.ControlNearMonsterTab, dmgData.PlayerUuid .. " " .. Z.ContainerMgr.CharSerialize.charBase.name)
  else
    dmgData.ControlNearMonsterTab = {}
    table.insert(dmgData.ControlNearMonsterTab, dmgData.PlayerUuid .. " " .. Z.ContainerMgr.CharSerialize.charBase.name)
  end
end
local refrehBodyData = function()
  local modelTabs = getNearEntityByType(Z.PbEnum("EEntityType", "EntMonster"))
  if modelTabs then
    sortMonsterTab(modelTabs)
    dmgData:SetNearByEnity(modelTabs)
  end
  nowAllAttandByAtt()
end
local refrehPartDevel = function()
  local uuid = dmgData.SelectByAttUuid
  if dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
    uuid = dmgData.PlayerUuid
  end
  local modelId = -1
  if dmgData.SelectByAttUuid == Lang("DamageAllTxt") or dmgData.SelectByAttUuid == Lang("DamageAllData") or dmgData.SelectByAttUuid == Lang("Team") then
    modelId = -1
  else
    modelId = getModelId(uuid)
  end
  if modelId ~= -1 then
    local tab = getPartData(modelId)
    if tab == nil or table.zcount(tab) == 0 then
      dmgData.Part = {
        Lang("DamagePartTxt")
      }
    else
      dmgData:AddPartTab(refreshPartTab(tab))
    end
  else
    dmgData.Part = {
      Lang("DamagePartTxt")
    }
  end
end
local getEntAttr = function(uuid)
  if uuid == nil then
    return
  end
  if uuid == Lang("DamageSelfTxt") then
    uuid = dmgData.PlayerUuid
  end
  local ent = Z.EntityMgr:GetEntity(tonumber(uuid))
  if not ent then
    return
  end
  local tab = {}
  if dmgData.ControlSelectAttrPartData == Lang("DamagePartTxt") then
    for key, value in pairs(fightAttrData) do
      local t = {}
      local attr = ent:GetLuaAttr(value.Id)
      if attr then
        local attrNum = attr.Value
        t.id = value.Id
        t.name = value.Name
        t.content = attrNum
        table.insert(tab, t)
      end
    end
  else
    local partId = dmgData.ControlSelectAttrPartData
    local partHp = Z.DamageData:GetPartHp(ent, tonumber(partId))
    local t = {}
    t.id = partId
    t.name = "HP"
    t.content = tostring(partHp)
    table.insert(tab, t)
  end
  dmgData.ControlShowAttrData = tab
end
local getAttrData = function(str)
  if not dmgData.ControlShowAttrData then
    return
  end
  local tab = {}
  for key, value in pairs(dmgData.ControlShowAttrData) do
    if string.find(value.id, str) or string.find(value.name, str) then
      table.insert(tab, value)
    end
  end
  if 0 < #tab then
    table.sort(tab, function(a, b)
      if a.content > 0 and b.content > 0 then
        return a.id < b.id
      end
      if a.content == 0 and b.content == 0 then
        return a.id < b.id
      end
      if b.content == 0 then
        return true
      end
      if a.content == 0 then
        return false
      end
      return false
    end)
  end
  return tab
end
local setBuffData = function(buffData)
  dmgData:SetBuffData(buffData)
end
local getBuffData = function(str)
  if not dmgData.ControlShowBuffData then
    return
  end
  local tab = {}
  for buffConfigId, buffData in pairs(dmgData.ControlShowBuffData) do
    local buffTable = Z.TableMgr.GetTable("BuffTableMgr").GetRow(buffConfigId, true)
    if buffTable and (string.find(buffConfigId, str) or string.find(buffTable.Name, str)) then
      table.insert(tab, buffData.data)
    end
  end
  table.sort(tab, function(a, b)
    if a.Duration > 0 and b.Duration > 0 then
      return a.BuffBaseId < b.BuffBaseId
    end
    if a.Duration == 0 and b.Duration == 0 then
      return a.BuffBaseId < b.BuffBaseId
    end
    if b.Duration == 0 then
      return true
    end
    if a.Duration == 0 then
      return false
    end
    return false
  end)
  return tab
end
local dimFindData = function(str, data)
  if not data then
    return
  end
  local tab = {}
  for key, value in pairs(data) do
    if string.find(value, str) then
      table.insert(tab, value)
    end
  end
  return tab
end
local initControlData = function()
  dmgData.ControlMonsterTab = {}
  local tab = table.zvalues(monsterTab)
  table.sort(tab, function(a, b)
    return a.Id < b.Id
  end)
  for key, monsterCfgData in pairs(tab) do
    table.insert(dmgData.ControlMonsterTab, monsterCfgData.Id .. " " .. monsterCfgData.Name)
  end
  dmgData.ShowMonsterDroData = dmgData.ControlMonsterTab
  dmgData.ControlFightAttrData = {}
  tab = table.zvalues(fightAttrData)
  table.sort(tab, function(a, b)
    return a.Id < b.Id
  end)
  for key, value in pairs(tab) do
    table.insert(dmgData.ControlFightAttrData, value.Id .. " " .. value.Name)
  end
  tab = table.zvalues(tempAttrData)
  table.sort(tab, function(a, b)
    return a.Id < b.Id
  end)
  for key, value in pairs(tab) do
    table.insert(dmgData.ControlFightAttrData, value.Id .. " " .. value.Name)
  end
  dmgData.ControlDummyTab = {}
  tab = table.zvalues(dummyTab)
  table.sort(tab, function(a, b)
    return a.Id < b.Id
  end)
  for key, value in pairs(tab) do
    table.insert(dmgData.ControlDummyTab, value.Id .. " " .. value.Name)
  end
  dmgData.ShowAttrDroData = dmgData.ControlFightAttrData
  dmgData.ControlMonsterFormationTab = {}
  for key, value in pairs(Z.Global.MonsterFormation) do
    table.insert(dmgData.ControlMonsterFormationTab, Lang(value[1]))
  end
  dmgData.ControlBuffData = {}
  tab = table.zvalues(buffData)
  table.sort(tab, function(a, b)
    return a.Id < b.Id
  end)
  for key, value in pairs(tab) do
    table.insert(dmgData.ControlBuffData, value.Id .. " " .. value.Name)
  end
  dmgData.ShowBuffDroData = dmgData.ControlBuffData
end
local getNowEntBuff = function(ent)
  local buffData = Z.DamageData:GetEntBuffData(ent)
  local buffTabs = {}
  for i = 0, buffData.count - 1 do
    table.insert(buffTabs, #buffTabs + 1, buffData[i])
  end
  local part = dmgData.ControlSelectBuffPartData
  if part == Lang("DamagePartTxt") then
    return buffTabs
  else
    local tab = {}
    for key, value in pairs(buffTabs) do
      if value.PartId == tonumber(part) then
        table.insert(tab, value)
      end
    end
    return tab
  end
end
local getEnitityShieldTab = function(uuid)
  local entity = Z.EntityMgr:GetEntity(tonumber(uuid))
  local shieldList
  shieldList = entity:GetLuaAttr(Z.PbAttrEnum("AttrShieldList")).Value
  local tab = {}
  for i = shieldList.count - 1, 0, -1 do
    table.insert(tab, shieldList[i])
  end
  table.sort(tab, function(a, b)
    return a.buffId < b.buffId
  end)
  dmgData:SetShieldTab(tonumber(uuid), tab)
  dmgData:SetShieldStatisticsData(tonumber(uuid), tab)
end
local setGamadeData = function(datas, count)
  local entity = Z.EntityMgr:GetEntity(datas.attUuid)
  if entity then
    local weaponId = entity:GetLuaAttr(Z.PbAttrEnum("AttrProfessionId")).Value
    dmgData:SetDmgData(datas, weaponId)
    if dmgData.ShieldStatisticsData[datas.byAttUuid] then
      getEnitityShieldTab(tonumber(datas.byAttUuid))
    end
    if datas.attUuid == Z.EntityMgr.PlayerUuid and datas.weapon.dmgSkill.hitType ~= EDamageTypeHeal then
      Z.EventMgr:Dispatch(Z.ConstValue.Damage.ControlRefreshData, datas.weapon.dmgSkill.hpLessenValue + datas.weapon.dmgSkill.shieldLessenValue, count)
    end
  end
end
local ret = {
  GetDamageData = getDamageData,
  CloseDamageView = closeDamageView,
  OpenDamageView = openDamageView,
  SetGamadeData = setGamadeData,
  GetPartData = getPartData,
  RefrehBodyData = refrehBodyData,
  SortMonsterTab = sortMonsterTab,
  SelectBody = selectBody,
  SelectPart = selectPart,
  ChangeDrowIndex = changeDrowIndex,
  NowAllAttandByAtt = nowAllAttandByAtt,
  RefrehPartDevel = refrehPartDevel,
  GetNearEntityByType = getNearEntityByType,
  GetMonsterSkills = getMonsterlSkills,
  GetDummySkills = getDummySkills,
  AsynceSendSkillCmd = asynceSendSkillCmd,
  RefreshTab = refreshTab,
  RefreshPartTab = refreshPartTab,
  GetEntAttr = getEntAttr,
  GetMonsterTab = getMonsterTab,
  SetBuffData = setBuffData,
  GetBuffData = getBuffData,
  GetAttrData = getAttrData,
  InitControlData = initControlData,
  GetNowEntBuff = getNowEntBuff,
  GetModelId = getModelId,
  GetDummyTabByUuid = getDummyTabByUuid,
  DimFindData = dimFindData,
  SetNearMosterTab = setNearMosterTab,
  GetEnitityShieldTab = getEnitityShieldTab
}
return ret
