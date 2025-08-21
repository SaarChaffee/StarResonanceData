local clientShowFuncBtnMap = {}
local getMainUICfg = function()
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
  local mainUiCfg = getMainUICfg()
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
local exitDungeon = function()
  if not checkFunctionCanShowInScene(E.FunctionID.ExitDungeon) then
    return
  end
  local str = Lang("DescLeaveDungeon")
  local curDungeonType = Z.StageMgr.GetCurrentStageType()
  if curDungeonType == Z.EStageType.CommunityDungeon or curDungeonType == Z.EStageType.HomelandDungeon then
    str = Lang("HomeLeaveTips")
  end
  Z.DialogViewDataMgr:OpenNormalDialog(str, function(cancelToken)
    local proxy = require("zproxy.world_proxy")
    local visualLayerId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
    if 0 < visualLayerId then
      local visualLayerCfg = Z.TableMgr.GetTable("VisualLayerMgr").GetRow(visualLayerId)
      if visualLayerCfg.VisualLayerType == E.VisualLayerType.VisualLayerTypeCommunityIndoor or visualLayerCfg.VisualLayerType == E.VisualLayerType.VisualLayerTypeCommunityOutdoor then
        proxy.LeaveScene(cancelToken)
      else
        proxy.ExitVisualLayer()
      end
    else
      proxy.LeaveScene(cancelToken)
    end
  end)
end
local openGmView = function()
  local gmVM = Z.VMMgr.GetVM("gm")
  if gmVM then
    gmVM.OpenGmView()
  end
end
local openBugReport = function()
  if Z.GameContext.IsBlockBUGReport then
    return
  end
  Z.BugReportMgr:CaptureScreenAndShowUI(function(tex)
    local viewData = {}
    viewData.tex = tex
    local bugReportVM = Z.VMMgr.GetVM("bug_report")
    bugReportVM.OpenBugReprotView(viewData)
  end)
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
local getUnclickableFuncsInScene = function()
  local result = {}
  local mainUiCfg = getMainUICfg()
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
local hideMainViewArea = function(hideStyle, viewConfigKey, isHide)
  local mainData = Z.DataMgr.Get("mainui_data")
  mainData:SetMainUiAreaHideStyle(hideStyle, viewConfigKey, isHide)
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.HideMainViewArea)
end
local completeDoTweenAnimShow = function()
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.CompleteMainViewAnimShow)
end
local isHomeFunction = function(functionId)
  return E.FunctionID.Home == functionId
end
local getPlayerExp = function()
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
    [E.MainUIPlaceType.RightTop] = {},
    [E.MainUIPlaceType.LeftBottom] = {}
  }
  if mainData.mainUiBtnItemList == nil or table.zcount(mainData.mainUiBtnItemList) <= 0 then
    return mainItemList
  end
  for k, v in pairs(mainData.mainUiBtnItemList) do
    local clientHide = clientShowFuncBtnMap[v.Id] ~= nil and not clientShowFuncBtnMap[v.Id]()
    if (isHomeFunction(v.Id) or checkFunctionCanShowInScene(v.Id)) and not clientHide then
      local systemPlace = Z.IsPCUI and v.PCSystemPlace or v.SystemPlace
      if table.zcontains(systemPlace, E.MainUIPlaceType.RightTop) then
        table.insert(mainItemList[E.MainUIPlaceType.RightTop], v)
      elseif table.zcontains(systemPlace, E.MainUIPlaceType.LeftBottom) then
        table.insert(mainItemList[E.MainUIPlaceType.LeftBottom], v)
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
local openShortcutMenuView = function()
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.ChangeShortcutMenuState, true)
end
local switchSceneryMode = function()
  Z.EventMgr:Dispatch(Z.ConstValue.SwitchLandSpaceMode)
end
local showEvaluateUI = function(level)
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.ShowOrHideEvaluateUI, level)
end
local shakeEvaluateUI = function()
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.ShakeEvaluateUI)
end
local hideMainChatView = function()
  local mainUIData = Z.DataMgr.Get("mainui_data")
  mainUIData:SetIsShowMainChat(false)
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.UpdateMainUIMainChat)
end
local showMainChatView = function()
  local deadView = Z.UIMgr:GetView("dead")
  if deadView and deadView.IsActive then
    local mainUIData = Z.DataMgr.Get("mainui_data")
    mainUIData:SetIsShowMainChat(true)
    Z.EventMgr:Dispatch(Z.ConstValue.MainUI.UpdateMainUIMainChat)
  end
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
  HideMainViewArea = hideMainViewArea,
  CompleteDoTweenAnimShow = completeDoTweenAnimShow,
  IsHomeFunction = isHomeFunction,
  GetPlayerExp = getPlayerExp,
  GetUnclickableFuncsInScene = getUnclickableFuncsInScene,
  GetMainItem = getMainItem,
  RegistClientFuncShow = registClientFuncShow,
  OpenShortcutMenuView = openShortcutMenuView,
  SwitchSceneryMode = switchSceneryMode,
  ShowEvaluateUI = showEvaluateUI,
  ShakeEvaluateUI = shakeEvaluateUI,
  HideMainChatView = hideMainChatView,
  ShowMainChatView = showMainChatView
}
return ret
