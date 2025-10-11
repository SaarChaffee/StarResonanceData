local super = require("ui.service.service_base")
local LogReportService = class("LogReportService", super)
local WorldProxy = require("zproxy.world_proxy")
local PerfReportType = {DungeonEnd = 1, SceneEnter = 2}

function LogReportService:OnInit()
end

function LogReportService:OnUnInit()
end

function LogReportService:OnLogin()
  Z.EventMgr:Add(Z.ConstValue.Dungeon.EndDungeon, self.onEndDungeon, self)
end

function LogReportService:OnLogout()
  Z.EventMgr:Remove(Z.ConstValue.Dungeon.EndDungeon, self.onEndDungeon, self)
end

function LogReportService:OnEnterScene(sceneId)
  local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  local subType = sceneTable.SceneSubType
  if subType ~= E.SceneSubType.Login and subType ~= E.SceneSubType.Select then
    self:reportLag(PerfReportType.SceneEnter)
  end
end

function LogReportService:onEndDungeon()
  self:reportLag(PerfReportType.DungeonEnd)
end

function LogReportService:reportLag(perfReportType)
  local currentLatency = Z.ServerTime:GetDelayTime()
  local contentList = {perfReportType, currentLatency}
  local content = table.concat(contentList, "|")
  WorldProxy.UploadTLogBody("ClientPerformanceReport", content)
end

return LogReportService
