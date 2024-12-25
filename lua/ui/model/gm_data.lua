local super = require("ui.model.data_base")
local GMData = class("GMData", super)

function GMData:ctor()
  super.ctor(self)
  self.GIndex = 1
  self.DIndex = 1
  self.HIndex = 1
  self.MaxDindex = 1
  self.HistoryNames = ""
  self.NowInputContent = ""
  self.GMexplore = true
  self.CmdType = {
    single = 1,
    group = 2,
    server = 3
  }
  self.HistoryInfo = {}
  self.SendServerCallLog = {}
  self.IsOpenGm = true
  self.IsOpenBug = true
  self.IsOpenWateMark = true
end

function GMData:Init()
  if self.CancelSource == nil then
    self.CancelSource = Z.CancelSource.Rent()
  end
end

function GMData:UnInit()
  if self.CancelSource then
    self.CancelSource:Recycle()
    self.CancelSource = nil
  end
end

function GMData:SetHistoryInfo(tbl)
  self.HistoryInfo = tbl
  self.HistoryNames = table.concat(self.HistoryInfo, "&")
end

function GMData:SetLog(log)
  table.insert(self.SendServerCallLog, 1, log)
end

function GMData:SetHistoryName(name)
  if name == self.HistoryInfo[1] then
    return
  end
  table.insert(self.HistoryInfo, 1, name)
  if #self.HistoryInfo > 100 then
    table.remove(self.HistoryInfo, 101)
  end
  self.HistoryNames = table.concat(self.HistoryInfo, "&")
end

function GMData:SetNowInputContent(content)
  self.NowInputContent = content
end

function GMData:SetGMexplore(flag)
  self.GMexplore = flag
end

function GMData:SetDindex(num)
  self.DIndex = num
end

function GMData:SetMaxDindex(num)
  self.MaxDindex = num
end

return GMData
