local openView = function()
  Z.UIMgr:OpenView("mainui_funcs_list")
end
local closeView = function()
  Z.UIMgr:CloseView("mainui_funcs_list")
end
local openSurveys = function()
  local questionnaireVM = Z.VMMgr.GetVM("questionnaire")
  local allQuestionnaireInfos = questionnaireVM.GetAllOpenedQuestionnaireInfos()
  if 0 < #allQuestionnaireInfos then
    questionnaireVM.OpenQuestionnaireView()
  end
end
local getFunctionPreviewBanner = function()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  if not gotoFuncVM.CheckFuncCanUse(E.FunctionID.FunctionPreview) then
    return
  end
  local switchVM = Z.VMMgr.GetVM("switch")
  local allFeatureList = switchVM.GetAllFeature(true)
  if allFeatureList == nil or next(allFeatureList) == nil then
    return
  end
  local funcPreviewVM = Z.VMMgr.GetVM("function_preview")
  if funcPreviewVM.CheckAllFuncOpen() then
    return
  end
  table.sort(allFeatureList, function(a, b)
    local stateA = funcPreviewVM.GetAwardState(a.Id)
    local stateB = funcPreviewVM.GetAwardState(b.Id)
    local previewCfgA = Z.TableMgr.GetTable("FunctionPreviewTableMgr").GetRow(a.Id)
    local previewCfgB = Z.TableMgr.GetTable("FunctionPreviewTableMgr").GetRow(b.Id)
    if stateA ~= stateB then
      return stateA < stateB
    elseif previewCfgA and previewCfgB then
      return previewCfgA.Preview < previewCfgB.Preview
    else
      return false
    end
  end)
  local data = {
    type = E.MenuBannerType.FuncPreview,
    config = allFeatureList[1]
  }
  return data
end
local getBannerList = function()
  local themePlayVM = Z.VMMgr.GetVM("theme_play")
  local allBannerList = themePlayVM:GetShowBannerActivityList()
  local funcPreviewBanner = getFunctionPreviewBanner()
  if funcPreviewBanner then
    table.insert(allBannerList, 1, funcPreviewBanner)
  end
  return allBannerList
end
local ret = {
  OpenView = openView,
  CloseView = closeView,
  OpenSurveys = openSurveys,
  GetFunctionPreviewBanner = getFunctionPreviewBanner,
  GetBannerList = getBannerList
}
return ret
