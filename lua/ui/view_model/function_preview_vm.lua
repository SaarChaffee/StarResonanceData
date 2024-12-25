local reqGetAward = function(funcId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.DrawnFunctionOpenAward(funcId, cancelToken)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  else
    return true
  end
end
local getAwardState = function(funcId)
  local funcPreviewData = Z.DataMgr.Get("function_preview_data")
  return funcPreviewData:GetFuncAwardState(funcId)
end
local openFuncPreviewWindow = function(funcId)
  Z.UIMgr:OpenView("sevendaystarget_main", {
    showType = E.SevenDayFuncType.FuncPreview,
    previewFuncId = funcId
  })
end
local closeFuncPreviewWindow = function()
  Z.UIMgr:CloseView("sevendaystarget_main")
end
local checkAllFuncOpen = function()
  local funcs = Z.TableMgr.GetTable("FunctionPreviewTableMgr").GetDatas()
  for k, v in pairs(funcs) do
    local state = getAwardState(v.Id)
    if state ~= E.FuncPreviewAwardState.Complete then
      return false
    end
  end
  return true
end
local ret = {
  ReqGetAward = reqGetAward,
  GetAwardState = getAwardState,
  OpenFuncPreviewWindow = openFuncPreviewWindow,
  CloseFuncPreviewWindow = closeFuncPreviewWindow,
  CheckAllFuncOpen = checkAllFuncOpen
}
return ret
