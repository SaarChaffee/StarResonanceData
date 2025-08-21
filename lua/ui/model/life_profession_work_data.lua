local super = require("ui.model.data_base")
local LifeProfessionWorkData = class("LifeProfessionWorkData", super)

function LifeProfessionWorkData:ctor()
  self.lifeWorkVM_ = Z.VMMgr.GetVM("life_work")
end

function LifeProfessionWorkData:Init()
  self.recordSynced_ = false
  self.CancelSource = Z.CancelSource.Rent()
end

function LifeProfessionWorkData:Clear()
end

function LifeProfessionWorkData:UnInit()
end

function LifeProfessionWorkData:OnLanguageChange()
end

function LifeProfessionWorkData:TryGetRecord()
  if self.recordSynced_ then
    Z.EventMgr:Dispatch(Z.ConstValue.LifeWork.LifeWorkRecordReady)
    return true
  end
  return false
end

function LifeProfessionWorkData:SetRecordData(workInfos)
  self.recordSynced_ = true
  self.records_ = table.zclone(workInfos)
  Z.EventMgr:Dispatch(Z.ConstValue.LifeWork.LifeWorkRecordReady)
end

function LifeProfessionWorkData:GetRecord()
  if not self.recordSynced_ then
    return nil
  end
  table.sort(self.records_, function(a, b)
    return a.beginTime > b.beginTime
  end)
  return self.records_
end

function LifeProfessionWorkData:AddNewRecord(newRecords)
  if not self.recordSynced_ then
    return
  end
  table.zinsertIndexRange(self.records_, newRecords, 1)
  table.sort(self.records_, function(a, b)
    return a.beginTime > b.beginTime
  end)
  local tableCount = table.zcount(self.records_)
  if 100 < tableCount then
    for i = 101, tableCount do
      table.remove(self.records_, 101)
    end
  end
end

function LifeProfessionWorkData:Clear()
  self.recordSynced_ = false
end

function LifeProfessionWorkData:GetRedPointID(proID)
  local proBaseID = 1000000 + proID * 100
  local proWorkRed = proBaseID + 11
  local proWorkTabRed = proBaseID + 12
  local proWorkRewardRed = proBaseID + 13
  return proWorkRed, proWorkTabRed, proWorkRewardRed
end

return LifeProfessionWorkData
