local super = require("ui.model.data_base")
local SDKReportData = class("SDKReportData", super)

function SDKReportData:ctor()
  super.ctor(self)
  self:ResetData()
end

function SDKReportData:Init()
end

function SDKReportData:Clear()
end

function SDKReportData:UnInit()
end

function SDKReportData:ResetData()
  self.gashCount_ = {}
  self.CurGemCount = 0
end

function SDKReportData:AddGashaData(type, count)
  if self.gashCount_[type] == nil then
    self.gashCount_[type] = count
  else
    self.gashCount_[type] = self.gashCount_[type] + count
  end
  if self.gashCount_[type] >= 10 then
    self.gashCount_[type] = self.gashCount_[type] - 10
    if type == 1 then
      Z.SDKReport.Report(Z.SDKReportEvent.ClothingLottery)
    elseif type == 2 then
      Z.SDKReport.Report(Z.SDKReportEvent.MountLottery)
    end
  end
end

return SDKReportData
