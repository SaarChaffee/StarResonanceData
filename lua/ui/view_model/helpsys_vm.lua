local helpsysData = Z.DataMgr.Get("helpsys_data")
local openMulHelpSysView = function(selectId)
  local data = {}
  data.selectId = selectId
  Z.UIMgr:OpenView("helpsys_window", data)
end
local closeMulHelpSysView = function()
  Z.UIMgr:CloseView("helpsys_window")
end
local openMixHelpSysView = function(type)
  local data = {}
  data.type = type
  Z.UIMgr:OpenView("helpsys_popup02", data)
end
local closeMixHelpSysView = function()
  Z.UIMgr:CloseView("helpsys_popup02")
end
local openEntranceTipsView = function(id)
  local data = {}
  data.id = id
  Z.UIMgr:OpenView("helpsys_popup_entrance_tpl", data)
end
local openTitleContentBtn = function(rect, title, content, btnContent, func, enabled, isRightFirst)
  local viewData = {
    rect = rect,
    title = title,
    content = content,
    btnContent = btnContent,
    func = func,
    enabled = enabled,
    isRightFirst = isRightFirst ~= nil
  }
  Z.UIMgr:OpenView("tips_title_content_btn", viewData)
end
local closeTitleContentBtn = function()
  Z.UIMgr:CloseView("tips_title_content_btn")
end
local openMinTips = function(id, parent)
  local helpsysData = Z.DataMgr.Get("helpsys_data")
  if helpsysData == nil then
    return
  end
  local helpLibraryData = helpsysData:GetOtherDataById(id)
  if helpLibraryData == nil then
    return
  end
  local descContent = Z.TableMgr.DecodeLineBreak(table.concat(helpLibraryData.Content, "="))
  if helpLibraryData.Button == nil or helpLibraryData.Button == "" then
    Z.CommonTipsVM.ShowTipsTitleContent(parent, helpLibraryData.Title, descContent)
  else
    local btnFunc = function()
      Z.VMMgr.GetVM("gotofunc").GoToFunc(helpLibraryData.FunctionId)
    end
    openTitleContentBtn(parent, helpLibraryData.Title, descContent, helpLibraryData.Button, btnFunc, true, false)
  end
end
local openFullScreenTipsView = function(id)
  local data = {}
  data.id = id
  Z.UIMgr:OpenView("helpsys_popup01", data)
end
local closeFullScreenTipsView = function()
  Z.UIMgr:CloseView("helpsys_popup01")
end
local asyncSaveById = function(id, token)
  local worldProxy = require("zproxy.world_proxy")
  worldProxy.SaveDisplayedPlayHelp(id, token)
end
local openSteerHelpsyView = function(id)
  local row = Z.TableMgr.GetTable("HelpLibraryTableMgr").GetRow(id)
  if row == nil then
    return
  end
  Z.UIMgr:OpenView("steer_helpsy_window", row)
end
local closeSteerHelpsyView = function()
  Z.UIMgr:CloseView("steer_helpsy_window")
end
local solveServerTips = function(force, id)
  if not force and Z.UIMgr:IsActive("helpsys_popup_entrance_tpl") then
    helpsysData:EnqueuePopData(id)
  else
    if id ~= 0 then
      helpsysData:EnqueuePopData(id)
    end
    local showId = helpsysData:DequeuePopData()
    if showId ~= 0 then
      openEntranceTipsView(showId)
    end
  end
end
local checkAndShowView = function(id, parent)
  local row = Z.TableMgr.GetTable("HelpLibraryTableMgr").GetRow(id)
  if row == nil then
    return
  end
  if row.Type == E.HelpSysType.Mul then
    solveServerTips(false, id)
  elseif row.Type == E.HelpSysType.Tips then
    openMinTips(id, parent)
  elseif row.Type == E.HelpSysType.FullScreen then
    openFullScreenTipsView(id)
  elseif row.Type == E.HelpSysType.Mix then
    openMixHelpSysView(row.TypeGroup)
  end
end
local checkTipsView = function(forceClose, isnext)
  if forceClose or helpsysData:QueueLen() == 0 then
    Z.UIMgr:CloseView("helpsys_popup_entrance_tpl")
  elseif isnext then
    solveServerTips(true, 0)
  end
end
local ret = {
  OpenMulHelpSysView = openMulHelpSysView,
  CloseMulHelpSysView = closeMulHelpSysView,
  OpenMixHelpSysView = openMixHelpSysView,
  CloseMixHelpSysView = closeMixHelpSysView,
  OpenEntranceTipsView = openEntranceTipsView,
  CheckTipsView = checkTipsView,
  CheckAndShowView = checkAndShowView,
  OpenMinTips = openMinTips,
  OpenFullScreenTipsView = openFullScreenTipsView,
  CloseFullScreenTipsView = closeFullScreenTipsView,
  AsyncSaveById = asyncSaveById,
  OpenSteerHelpsyView = openSteerHelpsyView,
  CloseSteerHelpsyView = closeSteerHelpsyView,
  OpenTitleContentBtn = openTitleContentBtn,
  CloseTitleContentBtn = closeTitleContentBtn
}
return ret
