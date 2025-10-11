local super = require("ui.model.data_base")
local TalentSkillData = class("TalentSkillData", super)
local TalentSkillDefine = require("ui.model.talent_skill_define")

function TalentSkillData:ctor()
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.talentSkillVm_ = Z.VMMgr.GetVM("talent_skill")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.maxWeaponLevel_ = table.zcount(Z.TableMgr.GetTable("WeaponLevelTableMgr").GetDatas())
  self.weaponUpgradeItems_ = {}
  local materials = Z.Global.WeaponLevelUpItem
  local tempIndex = 0
  for _, info in ipairs(materials) do
    tempIndex = tempIndex + 1
    local item = {}
    item.itemID = info[1]
    item.effect = info[2]
    item.costItemID = info[3]
    item.costItemCnt = info[4]
    self.weaponUpgradeItems_[tempIndex] = item
  end
  self.skillLevelConfigs_ = {}
  local skillLevelTableDatas = Z.TableMgr.GetTable("SkillUpgradeTableMgr").GetDatas()
  for _, value in pairs(skillLevelTableDatas) do
    if self.skillLevelConfigs_[value.UpgradeId] == nil then
      self.skillLevelConfigs_[value.UpgradeId] = {}
    end
    self.skillLevelConfigs_[value.UpgradeId][value.SkillLevel] = value
  end
  self.talentShowVideo_ = {}
  self.talentStageConfigs_ = {}
  local talentStageTableDatas = Z.TableMgr.GetTable("TalentStageTableMgr").GetDatas()
  for _, value in pairs(talentStageTableDatas) do
    if self.talentStageConfigs_[value.WeaponType] == nil then
      self.talentStageConfigs_[value.WeaponType] = {}
    end
    if self.talentStageConfigs_[value.WeaponType][value.TalentStage] == nil then
      self.talentStageConfigs_[value.WeaponType][value.TalentStage] = {}
    end
    self.talentStageConfigs_[value.WeaponType][value.TalentStage][value.BdType] = value
    self.talentShowVideo_[value.RootId] = value.ShowVideo
  end
  self.unActiveUnlockNodes_ = {}
end

function TalentSkillData:Clear()
  self.unActiveUnlockNodes_ = {}
end

function TalentSkillData:GetResetFreeTimesLimit()
  return Z.Global.ResetTalentFreeTimes
end

function TalentSkillData:GetTalentPointConfigId()
  return Z.SystemItem.ItemTalentPoint
end

function TalentSkillData:GetResetCostItem()
  local itemInfo = Z.Global.ResetTalentConsumables
  local itemId = itemInfo[1]
  local itemNum = itemInfo[2]
  return itemId, itemNum
end

function TalentSkillData:GetSkillLevelConfig(type, level)
  return self.skillLevelConfigs_[type][level]
end

function TalentSkillData:GetMaxWeaponLv()
  return self.maxWeaponLevel_
end

function TalentSkillData:GetWeaponUpgradeItems()
  return self.weaponUpgradeItems_
end

function TalentSkillData:GetTalentStageConfigs(weaponId, stage)
  return self.talentStageConfigs_[weaponId][stage]
end

function TalentSkillData:GetTalentTreeByWeapon(weaponId)
  return self.talentStageConfigs_[weaponId]
end

function TalentSkillData:GetTalentStageConfigByTalentTreeConfig(config)
  if config == nil then
    return
  end
  return self.talentStageConfigs_[config.WeaponType][config.TalentStage][config.BdType]
end

function TalentSkillData:GetTalentShowVideo(talentId)
  local showVideo = self.talentShowVideo_[talentId]
  if showVideo and showVideo[1] then
    return showVideo[1]
  end
  return nil
end

function TalentSkillData:GetCurUnActiveUnlockTalentTreeNodes()
  return self.unActiveUnlockNodes_
end

function TalentSkillData:RefreshCurUnActiveUnlockTalentTreeNodes()
  self.unActiveUnlockNodes_ = {}
  local professionId = self.weaponVm_.GetCurWeapon()
  local activeTalentTreeNodes = self.talentSkillVm_.GetWeaponActiveTalentTreeNode(professionId)
  local tempActiveTalentTreeNodes = {}
  if activeTalentTreeNodes and activeTalentTreeNodes.talentNodeIds then
    for _, nodes in ipairs(activeTalentTreeNodes.talentNodeIds) do
      tempActiveTalentTreeNodes[nodes] = nodes
    end
  end
  local allStageConfigs = self:GetTalentTreeByWeapon(professionId)
  if allStageConfigs == nil then
    return
  end
  local talentTreeTableMgr = Z.TableMgr.GetTable("TalentTreeTableMgr")
  local talentTableMgr = Z.TableMgr.GetTable("TalentTableMgr")
  local surplusTalentPoints = self.talentSkillVm_.GetSurpluseTalentPointCount(professionId)
  for i = 0, TalentSkillDefine.TalentTreeMaxStage - 1 do
    local timeCondition = true
    local tipsStr = ""
    local progress = ""
    if next(allStageConfigs[i][0].OpenCondition) then
      local condition = allStageConfigs[i][0].OpenCondition[1]
      timeCondition, tipsStr, progress = Z.ConditionHelper.GetSingleConditionDesc(condition[1], condition[2])
    end
    if timeCondition then
      local activeNodeId = -1
      for key, bdType in pairs(allStageConfigs[i]) do
        if tempActiveTalentTreeNodes[bdType.RootId] ~= nil then
          activeNodeId = bdType.RootId
          break
        end
      end
      if activeNodeId == -1 then
        for _, bdType in pairs(allStageConfigs[i]) do
          self:recursionGetUnActiveUnlockTalentTreeNodes(bdType.RootId, self.unActiveUnlockNodes_, talentTreeTableMgr, tempActiveTalentTreeNodes, talentTableMgr, surplusTalentPoints)
        end
        break
      else
        self:recursionGetUnActiveUnlockTalentTreeNodes(activeNodeId, self.unActiveUnlockNodes_, talentTreeTableMgr, tempActiveTalentTreeNodes, talentTableMgr, surplusTalentPoints)
      end
    else
      break
    end
  end
end

function TalentSkillData:recursionGetUnActiveUnlockTalentTreeNodes(nodeId, lists, talentTreeTableMgr, activeNodes, talentTableMgr, surplusTalentPoints)
  if activeNodes[nodeId] then
    local config = talentTreeTableMgr.GetRow(nodeId)
    if config then
      for _, node in ipairs(config.NextTalent) do
        self:recursionGetUnActiveUnlockTalentTreeNodes(node, lists, talentTreeTableMgr, activeNodes, talentTableMgr, surplusTalentPoints)
      end
    end
  else
    local config = talentTreeTableMgr.GetRow(nodeId)
    if config then
      local talentConfig = talentTableMgr.GetRow(config.TalentId)
      if talentConfig then
        local itemEnough = true
        if talentConfig.UnlockConsume and #talentConfig.UnlockConsume > 0 then
          for _, unlockConsume in ipairs(talentConfig.UnlockConsume) do
            if self.itemVm_.GetItemTotalCount(unlockConsume[1]) < unlockConsume[2] then
              itemEnough = false
            end
          end
        end
        if Z.ConditionHelper.CheckCondition(config.Unlock, false, self.weaponVm_.GetCurWeapon()) and surplusTalentPoints >= talentConfig.TalentPointsConsume and itemEnough then
          table.insert(lists, nodeId)
        end
      end
    end
  end
end

return TalentSkillData
