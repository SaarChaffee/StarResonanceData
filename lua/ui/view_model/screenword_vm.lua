local httpPlatformProxy = require("zproxy.http_platform_proxy")
local screenWordResult, grpcResult
local needCheckGrpcResult = false
local resetCheckInfo = function()
  screenWordResult = nil
  grpcResult = nil
  needCheckGrpcResult = false
end
local checkResult = function()
  if needCheckGrpcResult and screenWordResult and grpcResult then
    if screenWordResult ~= 0 then
      Z.TipsVM.ShowTips(screenWordResult)
      resetCheckInfo()
      return
    elseif grpcResult ~= 0 then
      Z.TipsVM.ShowTips(grpcResult)
      resetCheckInfo()
      return
    end
    resetCheckInfo()
    Z.EventMgr:Dispatch(Z.ConstValue.ScreenWordAndGrpcPass)
  end
end
local checkScreenWord = function(string, sceneType, cancelToken, successCallBack, failCallBack)
  sceneType = sceneType or E.TextCheckSceneType.TextCheckError
  local request = {}
  request.str = {string}
  request.sceneType = sceneType
  local ret = httpPlatformProxy.TextCheck(request, cancelToken)
  if ret.errCode == 0 then
    if ret.checkDataResult.itemResults[1].errCode == 0 then
      Z.EventMgr:Dispatch(Z.ConstValue.ScreenWordPass)
      if successCallBack then
        successCallBack()
      end
    else
      Z.TipsVM.ShowTips(ret.checkDataResult.itemResults[1].errCode)
      if failCallBack then
        failCallBack(ret.checkDataResult.itemResults[1].errCode)
      end
    end
  else
    Z.TipsVM.ShowTips(ret.errCode)
    if failCallBack then
      failCallBack(ret.errCode)
    end
  end
end
local notifyScreenWordResult = function(errCode)
  if errCode == 0 then
    Z.EventMgr:Dispatch(Z.ConstValue.ScreenWordPass)
  else
    Z.TipsVM.ShowTips(errCode)
  end
end
local checkScreenWordResult = function(errCode)
  screenWordResult = errCode
  if needCheckGrpcResult then
    checkResult()
  else
    notifyScreenWordResult(errCode)
  end
end
local checkGrpcResult = function()
  resetCheckInfo()
  needCheckGrpcResult = true
end
local addGrpcRet = function(ret)
  grpcResult = ret
  checkResult()
end
local ret = {
  CheckScreenWord = checkScreenWord,
  CheckScreenWordResult = checkScreenWordResult,
  CheckGrpcResult = checkGrpcResult,
  AddGrpcRet = addGrpcRet
}
return ret
