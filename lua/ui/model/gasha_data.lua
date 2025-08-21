local super = require("ui.model.data_base")
local GashaData = class("GashaData", super)

function GashaData:ctor()
  super.ctor(self)
end

function GashaData:Init()
  self.historyList = {}
  self.RecordPageSize = 5
  self.RecordPageCount = 5
  self.IsDrawing_ = false
end

function GashaData:Clear()
  self.historyList = {}
end

function GashaData:SetRecordTotalCount(gashaShareId, totalCount)
  if self.historyList[gashaShareId] == nil then
    self.historyList[gashaShareId] = {}
  end
  self.historyList[gashaShareId].totalCount = totalCount
end

function GashaData:GetRecordTotalCount(gashaShareId)
  if self.historyList[gashaShareId] == nil then
    return 0
  end
  return self.historyList[gashaShareId].totalCount
end

function GashaData:GetRecordTotalPage(gashaShareId)
  local totalCount = self:GetRecordTotalCount(gashaShareId)
  return math.ceil(totalCount / self.RecordPageSize)
end

function GashaData:GetSyncRecordTotalCount(gashaShareId)
  if self.historyList[gashaShareId] == nil then
    return 0
  end
  if self.historyList[gashaShareId].data == nil then
    return 0
  end
  return #self.historyList[gashaShareId].data
end

function GashaData:GetSyncRecordTotalPage()
  local totalCount = self:GetSyncRecordTotalCount()
  return math.ceil(totalCount / self.RecordPageSize)
end

function GashaData:GetHistoryByGashaId(gashaShareId, startIndex, count)
  if self.historyList[gashaShareId] == nil then
    return nil
  end
  local data = self.historyList[gashaShareId].data
  if data == nil then
    return nil
  end
  local ret = {}
  local has = false
  for i = startIndex + 1, startIndex + count do
    if data[i] == nil then
      break
    end
    has = true
    table.insert(ret, data[i])
  end
  if has then
    return ret
  end
  return nil
end

function GashaData:AppendHistory(gashaShareId, data)
  if self.historyList[gashaShareId] == nil then
    self.historyList[gashaShareId] = {}
  end
  if self.historyList[gashaShareId].data == nil then
    self.historyList[gashaShareId].data = {}
  end
  for _, v in ipairs(data) do
    table.insert(self.historyList[gashaShareId].data, v)
  end
end

function GashaData:ClearHistory()
  self.historyList = {}
end

function GashaData:GetAllGashPoolName(openType)
  if self.gashPoolNames_ ~= nil and self.gashPoolNames_[openType] ~= nil and #self.gashPoolNames_[openType] < 1 then
    return self.gashPoolNames_[openType]
  end
  self:FillIdAndNameMap()
  return self.gashPoolNames_[openType]
end

function GashaData:GetIndexByGashaPoolId(gashaPoolId, openType)
  openType = openType or 0
  if self.gashPoolNames_ == nil and #self.gashPoolIds_ < 1 then
    self:FillIdAndNameMap()
  end
  for i, v in ipairs(self.gashPoolIds_[openType]) do
    if v == gashaPoolId then
      return i - 1
    end
  end
  return -1
end

function GashaData:GetGashaPoolIdByIndex(index, openType)
  openType = openType or 0
  if self.gashPoolNames_ == nil then
    self:FillIdAndNameMap()
  end
  return self.gashPoolIds_[openType][index + 1]
end

function GashaData:FillIdAndNameMap()
  self.gashPoolNames_ = {}
  self.gashPoolIds_ = {}
  if not self.gashaPools then
    self.gashaPools = Z.TableMgr.GetTable("GashaPoolTableMgr").GetDatas()
  end
  for key, value in pairs(self.gashaPools) do
    local isInTime = Z.TimeTools.CheckIsInTimeByTimeId(value.TimerId)
    if not table.zcontains(self.gashPoolIds_, value.ShareGuarantee) and isInTime and value.Work == 1 then
      if self.gashPoolNames_[value.openType] == nil then
        self.gashPoolNames_[value.openType] = {}
      end
      if self.gashPoolIds_[value.openType] == nil then
        self.gashPoolIds_[value.openType] = {}
      end
      table.insert(self.gashPoolNames_[value.openType], Lang("GashaSharePoolRecordTitle_" .. value.ShareGuarantee))
      table.insert(self.gashPoolIds_[value.openType], value.ShareGuarantee)
    end
  end
end

function GashaData:UnInit()
  self.IsDrawing_ = false
end

function GashaData:onLanguageChange()
  self.gashaPools = Z.TableMgr.GetTable("GashaPoolTableMgr").GetDatas()
end

function GashaData:SetIsDrawing(isDrawing)
  self.IsDrawing_ = isDrawing
end

function GashaData:IsDrawing()
  return self.IsDrawing_
end

return GashaData
