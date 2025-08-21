local super = require("ui.model.data_base")
local BugReportData = class("BugReportData", super)

function BugReportData:ctor()
  super.ctor(self)
end

function BugReportData:Init()
  self.NewItems = {}
  self.NewPackageItems = {}
end

function BugReportData:Clear()
  self.NewItems = {}
  self.NewPackageItems = {}
end

function BugReportData:GetAllPipeLineOptions()
  if not self.bugReportConfigs then
    local bugReportConfigTableMgr = Z.TableMgr.GetTable("BugReportConfigTableMgr")
    self.bugReportConfigs = bugReportConfigTableMgr:GetDatas()
  end
  local options = {}
  for k, v in pairs(self.bugReportConfigs) do
    if v.DataType == 0 then
      table.insert(options, v.Desc)
    end
  end
  return options
end

function BugReportData:GetConfigByIndex(index)
  if not self.bugReportConfigs then
    local bugReportConfigTableMgr = Z.TableMgr.GetTable("BugReportConfigTableMgr")
    self.bugReportConfigs = bugReportConfigTableMgr:GetDatas()
  end
  local curIndex = 1
  for k, v in pairs(self.bugReportConfigs) do
    if v.DataType == 0 and curIndex == index then
      return v
    end
    curIndex = curIndex + 1
  end
  return nil
end

return BugReportData
