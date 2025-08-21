local LifeWorkRed = {}
local lifeProfessionData = Z.DataMgr.Get("life_profession_data")
local lifeWorkVM = Z.VMMgr.GetVM("life_work")
local lifeProfessionWorkData = Z.DataMgr.Get("life_profession_work_data")

function LifeWorkRed.CheckAwardRed(proID)
  local redNodeName = string.zconcat("LifeWorkEndReward_", proID)
  local redCount = lifeWorkVM.IsCurWorkingEnd(proID) and 1 or 0
  Z.RedPointMgr.UpdateNodeCount(redNodeName, redCount)
end

function LifeWorkRed.Init()
  local lifeProfessionDatas = lifeProfessionData:GetProfessionDatas()
  for k, v in pairs(lifeProfessionDatas) do
    local proID = v.ProId
    local _, proWorkTabRed, proRewardRed = lifeProfessionWorkData:GetRedPointID(proID)
    Z.RedPointMgr.AddChildNodeData(proWorkTabRed, proRewardRed, string.zconcat("LifeWorkEndReward_", proID))
    LifeWorkRed.CheckAwardRed(proID)
  end
  
  function LifeWorkRed.redCheck()
    local lifeProfessionDatas = lifeProfessionData:GetProfessionDatas()
    for k, v in pairs(lifeProfessionDatas) do
      LifeWorkRed.CheckAwardRed(v.ProId)
    end
  end
  
  Z.EventMgr:Add(Z.ConstValue.LifeWork.LifeWorkRewardChange, LifeWorkRed.redCheck)
end

function LifeWorkRed.UnInit()
  Z.EventMgr:Remove(Z.ConstValue.LifeWork.LifeWorkRewardChange, LifeWorkRed.redCheck)
end

return LifeWorkRed
