local cls = {}
local reportProxy = require("zproxy.report_proxy")

function cls.OpenReportPop(reportType, name, charId, param)
  if cls.IsReportOpen() then
    local viewData = {
      reportType = reportType,
      name = name,
      charId = charId,
      param = param
    }
    Z.UIMgr:OpenView("report_popup", viewData)
  end
end

function cls.IsReportOpen(isIgnoreTips)
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  return funcVm.CheckFuncCanUse(E.FunctionID.Report, isIgnoreTips)
end

function cls.AsyncReport(reportInfo, cancelToken)
  local reply = reportProxy.ReportUpload(reportInfo, cancelToken)
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  end
  return true
end

return cls
