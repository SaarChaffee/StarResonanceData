local actionTriggerIngoreViewConfigKey = {
  mainui_funcs_list = true,
  socialcontact_main = true,
  expression = true
}
local clientShowFuncBtnMap = {}
local exitDungeon = function()
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("DescLeaveDungeon"), function(cancelToken)
    local proxy = require("zproxy.world_proxy")
    local visualLayerId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
    if 0 < visualLayerId then
      proxy.ExitVisualLayer()
    else
      proxy.LeaveScene(cancelToken)
    end
    Z.DialogViewDataMgr:CloseDialogView()
  end)
end
local openGmView = function()
  local gmVM = Z.VMMgr.GetVM("gm")
  if gmVM then
    gmVM.OpenGmView()
  end
end
local openBugReport = function()
  Z.BugReportMgr:CaptureScreenAndShowUI()
end
local checkSceneShowMiniMap = function()
  local mapInfoTableRow = Z.TableMgr.GetRow("MapInfoTableMgr", Z.StageMgr.GetCurrentSceneId(), true)
  if mapInfoTableRow == nil then
    return false
  end
  return mapInfoTableRow.IsShowMiniMap
end
local checkSceneShowMainMap = function()
  local mapInfoTableRow = Z.TableMgr.GetRow("MapInfoTableMgr", Z.StageMgr.GetCurrentSceneId(), true)
  if mapInfoTableRow == nil then
    return false
  end
  return mapInfoTableRow.IsShowMainMap
end
local refreshIdCard = function(charIdList)
  Z.EventMgr:Dispatch(Z.ConstValue.RefreshIdCard, charIdList)
end
local getMianUICfg = function()
  if not Z.EntityMgr.PlayerEnt then
    return nil
  end
  local visualLayerId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
  local mainUICfgId = 0
  if 0 < visualLayerId then
    local visualLayerCfg = Z.TableMgr.GetTable("VisualLayerMgr").GetRow(visualLayerId)
    if not visualLayerCfg then
      logError("\228\184\141\229\173\152\229\156\168\229\189\147\229\137\141\232\167\134\233\135\142\229\177\130\231\186\167id\233\133\141\231\189\174: {0}", visualLayerId)
      return nil
    end
    mainUICfgId = visualLayerCfg.MainUi
  else
    local sceneId = Z.StageMgr.GetCurrentSceneId()
    local sceneMgr = Z.TableMgr.GetTable("SceneTableMgr")
    if sceneMgr == nil then
      return nil
    end
    local sceneCfg = sceneMgr.GetRow(sceneId)
    if not sceneCfg then
      logError("\228\184\141\229\173\152\229\156\168\229\189\147\229\137\141\229\156\186\230\153\175id\233\133\141\231\189\174: {0}", sceneId)
      return nil
    end
    mainUICfgId = sceneCfg.MainUi
  end
  local mainUiCfg = Z.TableMgr.GetTable("MainUiTableMgr").GetRow(mainUICfgId, true)
  if not mainUiCfg then
    return nil
  end
  return mainUiCfg
end
local checkFunctionCanShowInScene = function(functionId)
  local mainUiCfg = getMianUICfg()
  if not mainUiCfg then
    return false
  end
  local iconList = mainUiCfg.MainIcon
  for k, v in pairs(iconList) do
    if v == functionId then
      return true
    end
  end
  return false
end
local getUnclickableFuncsInScene = function()
  local result = {}
  local mainUiCfg = getMianUICfg()
  if mainUiCfg then
    local iconList = mainUiCfg.UnclickedMainIcon
    for k, v in pairs(iconList) do
      result[v] = true
    end
  end
  return result
end
local isShowKeyHint = function()
  if not Z.IsPCUI then
    return false
  end
  local settingVM = Z.VMMgr.GetVM("setting")
  return settingVM.Get(E.SettingID.KeyHint)
end
local gotoMainUIFunc = function(funcId)
  local isCanSwitch = checkFunctionCanShowInScene(funcId)
  if funcId == E.FunctionID.Map and not isCanSwitch then
    isCanSwitch = checkFunctionCanShowInScene(E.FunctionID.MiniMap)
  end
  if isCanSwitch then
    local gotoVM = Z.VMMgr.GetVM("gotofunc")
    gotoVM.GoToFunc(funcId)
  end
end
local getInputFuncActionIds = function()
  local setKeyboardTableMgr = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  local actionIds = {}
  for _, value in pairs(setKeyboardTableMgr.GetDatas()) do
    if value.KeyboardDes == 2 then
      table.insert(actionIds, value.ActionIds)
    end
  end
  return actionIds
end
local triggerInputFuncAction = function(actionId)
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.UIInteract) then
    return
  end
  if Z.UIMgr:HasFocusView(actionTriggerIngoreViewConfigKey) then
    return
  end
  if actionId == Z.RewiredActionsConst.ExitUI then
    return
  end
  local setKeyboardTableMgr = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  for _, value in pairs(setKeyboardTableMgr.GetDatas()) do
    local actionIds = value.ActionIds
    for _, id in ipairs(actionIds) do
      if id == actionId and value.FunctionId ~= nil and value.FunctionId ~= 0 then
        gotoMainUIFunc(value.FunctionId)
      end
    end
  end
end
local hideMainViewArea = function(hideStyle, viewConfigKey, isHide)
  local mainData = Z.DataMgr.Get("mainui_data")
  mainData:SetMainUiAreaHideStyle(hideStyle, viewConfigKey, isHide)
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.HideMainViewArea)
end
local completeDoTweenAnimShow = function()
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.CompleteMainViewAnimShow)
end
local isHomeFunction = function(functionId)
  return false
end
local getPlayerExp = function(functionId)
  local playerLevelCfg = Z.TableMgr.GetTable("PlayerLevelTableMgr")
  local curLevel = Z.ContainerMgr.CharSerialize.roleLevel.level or 0
  if 0 < curLevel then
    local levelCfg = playerLevelCfg.GetRow(curLevel)
    if levelCfg then
      return levelCfg.Exp
    end
  end
  return 0
end
local getMainItem = function()
  local mainData = Z.DataMgr.Get("mainui_data")
  local mainItemList = {
    [E.MainUiArea.UpperRight] = {},
    [E.MainUiArea.BottomLeft] = {}
  }
  if mainData.mainUiBtnItemList == nil or table.zcount(mainData.mainUiBtnItemList) <= 0 then
    return mainItemList
  end
  for k, v in pairs(mainData.mainUiBtnItemList) do
    local cilentHide = clientShowFuncBtnMap[v.Id] ~= nil and not clientShowFuncBtnMap[v.Id]()
    if (isHomeFunction(v.Id) or checkFunctionCanShowInScene(v.Id)) and not cilentHide then
      if v.SystemPlace == E.MainUiArea.UpperRight then
        table.insert(mainItemList[E.MainUiArea.UpperRight], v)
      elseif v.SystemPlace == E.MainUiArea.BottomLeft then
        table.insert(mainItemList[E.MainUiArea.BottomLeft], v)
      end
    end
  end
  if mainItemList and table.zcount(mainItemList) > 0 then
    for k, v in pairs(mainItemList) do
      table.sort(v, function(a, b)
        return a.SortId < b.SortId
      end)
    end
  end
  return mainItemList
end
local registClientFuncShow = function(funcID, checkCanShow)
  clientShowFuncBtnMap[funcID] = checkCanShow
end
local ret = {
  ExitDungeon = exitDungeon,
  OpenGmView = openGmView,
  OpenBugReport = openBugReport,
  RefreshIdCard = refreshIdCard,
  CheckFunctionCanShowInScene = checkFunctionCanShowInScene,
  IsShowKeyHint = isShowKeyHint,
  GotoMainUIFunc = gotoMainUIFunc,
  CheckSceneShowMiniMap = checkSceneShowMiniMap,
  CheckSceneShowMainMap = checkSceneShowMainMap,
  TriggerInputFuncAction = triggerInputFuncAction,
  GetInputFuncActionIds = getInputFuncActionIds,
  HideMainViewArea = hideMainViewArea,
  CompleteDoTweenAnimShow = completeDoTweenAnimShow,
  IsHomeFunction = isHomeFunction,
  GetPlayerExp = getPlayerExp,
  GetUnclickableFuncsInScene = getUnclickableFuncsInScene,
  GetMainItem = getMainItem,
  RegistClientFuncShow = registClientFuncShow
}
return ret
