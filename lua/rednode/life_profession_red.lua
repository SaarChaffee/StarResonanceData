local LifeProfessionRed = {}
local lifeProfessionData = Z.DataMgr.Get("life_profession_data")
local lifeProfessionVM = Z.VMMgr.GetVM("life_profession")

function LifeProfessionRed.CheckAwardRed(proID)
  local redNodeName = string.zconcat("LifeProfessionReward_", proID)
  local redCount = lifeProfessionVM.GetRewardCanGainCnt(proID)
  if not lifeProfessionVM.IsLifeProfessionUnlocked(proID) then
    redCount = 0
  end
  Z.RedPointMgr.UpdateNodeCount(redNodeName, redCount)
end

function LifeProfessionRed.CheckSpec()
  local lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  local professions = lifeProfessionData_:GetProfessionDatas()
  for k, v in pairs(professions) do
    local redNodeName = string.zconcat("LifeProfessionSpec_", v.ProId)
    local redCount = lifeProfessionVM.GetSpecCanUnlockCnt(v.ProId)
    if not lifeProfessionVM.IsLifeProfessionUnlocked(v.ProId) then
      redCount = 0
    end
    Z.RedPointMgr.UpdateNodeCount(redNodeName, redCount)
  end
end

function LifeProfessionRed.Init()
  local lifeProfessionDatas = lifeProfessionData:GetProfessionDatas()
  for k, v in pairs(lifeProfessionDatas) do
    local proID = v.ProId
    local _, proTabRed, proRewardRed, proSpecRed = lifeProfessionData:GetRedPointID(proID)
    Z.RedPointMgr.AddChildNodeData(proTabRed, proRewardRed, string.zconcat("LifeProfessionReward_", proID))
    Z.RedPointMgr.AddChildNodeData(proTabRed, proSpecRed, string.zconcat("LifeProfessionSpec_", proID))
    LifeProfessionRed.CheckAwardRed(proID)
  end
  LifeProfessionRed.CheckSpec()
  
  function LifeProfessionRed.redCheck(proID)
    LifeProfessionRed.CheckAwardRed(proID)
  end
  
  function LifeProfessionRed.speRedCheck()
    LifeProfessionRed.CheckSpec()
  end
  
  function LifeProfessionRed.redTargetCheck(target)
    local lifeProfessionDatas = lifeProfessionData:GetProfessionDatas()
    for k, v in pairs(lifeProfessionDatas) do
      for _, targetID in pairs(v.LevelAward) do
        local lifeAwardTargetTableRow = Z.TableMgr.GetTable("LifeAwardTargetTableMgr").GetRow(targetID)
        if lifeAwardTargetTableRow.TargetGroupId == target then
          LifeProfessionRed.CheckAwardRed(v.ProId)
          LifeProfessionRed.CheckSpec()
          break
        end
      end
    end
  end
  
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionPointChanged, LifeProfessionRed.speRedCheck)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionSpecChanged, LifeProfessionRed.speRedCheck)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionUnlocked, LifeProfessionRed.redCheck)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionTargetLevelChanged, LifeProfessionRed.redTargetCheck)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionTargetStateChanged, LifeProfessionRed.redTargetCheck)
end

function LifeProfessionRed.UnInit()
  Z.EventMgr:Remove(Z.ConstValue.LifeProfession.LifeProfessionPointChanged, LifeProfessionRed.speRedCheck)
  Z.EventMgr:Remove(Z.ConstValue.LifeProfession.LifeProfessionSpecChanged, LifeProfessionRed.speRedCheck)
  Z.EventMgr:Remove(Z.ConstValue.LifeProfession.LifeProfessionUnlocked, LifeProfessionRed.redTargetCheck)
  Z.EventMgr:Remove(Z.ConstValue.LifeProfession.LifeProfessionTargetLevelChanged, LifeProfessionRed.redTargetCheck)
  Z.EventMgr:Remove(Z.ConstValue.LifeProfession.LifeProfessionTargetStateChanged, LifeProfessionRed.redTargetCheck)
end

return LifeProfessionRed
