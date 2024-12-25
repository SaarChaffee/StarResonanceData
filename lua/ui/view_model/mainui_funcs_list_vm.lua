local isPCUIPrefab = function()
  if Z.IsPCUI then
    Z.UIConfig.mainui_funcs_list.PrefabPath = "main/main_funcs_list_window_pc"
  else
    Z.UIConfig.mainui_funcs_list.PrefabPath = "main/main_funcs_list_window"
  end
end
local openView = function()
  isPCUIPrefab()
  Z.UIMgr:OpenView("mainui_funcs_list")
end
local closeView = function()
  isPCUIPrefab()
  Z.UIMgr:CloseView("mainui_funcs_list")
end
local getAllOpenFuncId = function()
  local switchVM = Z.VMMgr.GetVM("switch")
  local rowList = {}
  for id, row in pairs(Z.TableMgr.GetTable("MainIconTableMgr").GetDatas()) do
    if row.SystemPlace == 5 and switchVM.CheckFuncSwitch(id) then
      table.insert(rowList, row)
    end
  end
  table.sort(rowList, function(left, right)
    if left.SortId ~= right.SortId then
      return left.SortId < right.SortId
    end
    return left.Id < right.Id
  end)
  local idList = {}
  for _, row in ipairs(rowList) do
    table.insert(idList, row.Id)
  end
  return idList
end
local openSurveys = function()
  local questionnaireVM = Z.VMMgr.GetVM("questionnaire")
  local allQuestionnaireInfos = questionnaireVM.GetAllOpenedQuestionnaireInfos()
  if 0 < #allQuestionnaireInfos then
    questionnaireVM.OpenQuestionnaireView()
  end
end
local ret = {
  OpenView = openView,
  CloseView = closeView,
  GetAllOpenFuncId = getAllOpenFuncId,
  OpenSurveys = openSurveys
}
return ret
