local LocalGM = {}
LocalGM.show = {}

function LocalGM.show.openUI(...)
  local params = {
    ...
  }
  local success = Z.VMMgr.GetVM("gotofunc").GoToFunc(params[1])
  if not success then
    Z.EventMgr:Dispatch("CmdResult", os.date("%Y.%m.%d %H:%M:%S", os.time()) .. " " .. "GM: cmd fail " .. "no open UI")
    return
  end
  Z.EventMgr:Dispatch("CmdResult", os.date("%Y.%m.%d %H:%M:%S", os.time()) .. " " .. "GM: cmd success")
end

function LocalGM.show.exitLogout(...)
  local success = Z.VMMgr.GetVM("gotofunc").GoToFunc(900001)
  if not success then
    Z.EventMgr:Dispatch("CmdResult", os.date("%Y.%m.%d %H:%M:%S", os.time()) .. " " .. "GM: cmd fail " .. "logout")
    return
  end
  Z.EventMgr:Dispatch("CmdResult", os.date("%Y.%m.%d %H:%M:%S", os.time()) .. " " .. "GM: cmd success")
end

function LocalGM.show.showMessage(...)
  local params = {
    ...
  }
  local success = Z.TipsVM.ShowTips(params[1])
  if not success then
    Z.EventMgr:Dispatch("CmdResult", os.date("%Y.%m.%d %H:%M:%S", os.time()) .. " " .. "GM: cmd fail " .. "showMessage")
    return
  end
  Z.EventMgr:Dispatch("CmdResult", os.date("%Y.%m.%d %H:%M:%S", os.time()) .. " " .. "GM: cmd success")
end

function LocalGM.show.showCutscene(...)
  local params = {
    ...
  }
  if params and 0 < #params then
    Z.LevelMgr.FireSceneEvent({
      eventType = 4,
      intParams = {
        params[1]
      }
    })
  end
end

function LocalGM.show.stopCutscene(...)
  local params = {
    ...
  }
  if params and 0 < #params then
    Z.LevelMgr.FireSceneEvent({
      eventType = 4,
      e = {
        -params[1]
      }
    })
  end
end

function LocalGM.show.openDebugGUI(...)
  local param = {
    ...
  }
  local index = tonumber(param[1])
  if index ~= nil then
    DebugGUIView.OpenDebug(index)
  end
end

function LocalGM.show.setResolution(...)
  local params = {
    ...
  }
  local isFullScreen = params[3] == 1
  Panda.Launch.ResolutionManager.SetResolution(params[1], params[2], isFullScreen)
end

function LocalGM.show.setIsPCUI(...)
  local params = {
    ...
  }
  local isPCUI = params[1] == 1
  Z.IsPCUI = isPCUI
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Device, "BKR_IS_PCUI", isPCUI)
  Z.LocalUserDataMgr.Save()
end

function LocalGM.show.saveFaceData(...)
  local faceVM = Z.VMMgr.GetVM("face")
  faceVM.SaveFaceDataToFile()
end

function LocalGM.show.loadFaceData(...)
  local params = {
    ...
  }
  local faceVM = Z.VMMgr.GetVM("face")
  faceVM.LoadFaceDataFromFile(params[1])
end

function LocalGM.show.saveFaceLuaData(...)
  local faceVM = Z.VMMgr.GetVM("face")
  faceVM.SaveFaceDataToLuaFile()
end

function LocalGM.show.saveFaceLuaDataWithPath(...)
  local params = {
    ...
  }
  local faceVM = Z.VMMgr.GetVM("face")
  faceVM.SaveFaceDataToLuaFile(params[1])
end

function LocalGM.show.setShowAllFashion(...)
  local params = {
    ...
  }
  local isShowAllFashion = params[1] == 1
  local fashionData = Z.DataMgr.Get("fashion_data")
  fashionData.IsShowAllFashion = isShowAllFashion
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionShowState)
end

function LocalGM.show.loadFashionLuaData(...)
  local faceVM = Z.VMMgr.GetVM("face")
  faceVM.LoadFashionLuaData()
end

function LocalGM.show.loadFashionLuaDataWithPath(...)
  local params = {
    ...
  }
  local faceVM = Z.VMMgr.GetVM("face")
  faceVM.LoadFashionLuaDataWithPath(params[1])
end

function LocalGM.show.loadFashionLuaDataWithFilePath(...)
  local params = {
    ...
  }
  local faceVM = Z.VMMgr.GetVM("face")
  faceVM.LoadFashionLuaDataWithFilePath(params[1])
end

function LocalGM.show.saveFashionData(...)
  local fashionVM = Z.VMMgr.GetVM("fashion")
  fashionVM.SaveFashionDataToFile()
end

function LocalGM.show.loadFashionData(...)
  local params = {
    ...
  }
  local fashionVM = Z.VMMgr.GetVM("fashion")
  fashionVM.LoadFashionDataFromFile(params[1])
end

function LocalGM.show.startFlow(...)
  local params = {
    ...
  }
  Z.EPFlowBridge.StartFlow(params[1])
end

function LocalGM.show.stopFlow(...)
  local params = {
    ...
  }
  local flowId = tonumber(params[1])
  if flowId and 0 < flowId then
    Z.EPFlowBridge.StopFlow(flowId)
  else
    local talkData = Z.DataMgr.Get("talk_data")
    local curFlow = talkData:GetTalkCurFlow()
    Z.EPFlowBridge.StopFlow(curFlow)
  end
end

function LocalGM.show.luaDoString(...)
  local params = {
    ...
  }
  if params and 0 < #params and type(params[1]) == "string" then
    assert(load(params[1]))()
  end
end

function LocalGM.show.openZoneDebug(...)
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Device, "ZoneDebugMode", true)
  Z.LocalUserDataMgr.Save()
end

function LocalGM.show.closeZoneDebug(...)
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Device, "ZoneDebugMode", false)
  Z.LocalUserDataMgr.Save()
end

function LocalGM.show.setSeason(...)
  local ps = {
    ...
  }
  local i = tonumber(ps[1])
  logGreen("gm change season:" .. tostring(i))
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Device, "Season", i)
  Z.LocalUserDataMgr.Save()
end

function LocalGM.show.clearPrefs(...)
  Z.LocalUserDataMgr.ClearAll()
end

function LocalGM.show.switchEventLog(...)
  local params = {
    ...
  }
  Z.UserDataManager.SetInt("avoidEventLogs_", tonumber(params[1]))
end

local doFileErrorFunc = function(err)
  logError(err)
end

function LocalGM.show.luaDoFile(...)
  local params = {
    ...
  }
  if params and 0 < #params and type(params[1]) == "string" then
    local path = string.zreplace(params[1], ".lua", "")
    xpcall(dofile, doFileErrorFunc, path)
  end
end

function LocalGM.show.playerWayPoint(...)
  local params = {
    ...
  }
  if params and 0 < #params and type(params[1]) == "string" then
    Panda.LuaAsyncBridge.SetPlayerWayPoint(params[1])
  end
end

function LocalGM.show.discardPlayerWayPoint(...)
  local params = {
    ...
  }
  Panda.LuaAsyncBridge.DiscardPlayerWayPoint()
end

function LocalGM.show.lockCamera(...)
  Panda.LuaAsyncBridge.LockCamera()
end

function LocalGM.show.unlockCamera(...)
  Panda.LuaAsyncBridge.UnlockCamera()
end

function LocalGM.show.clearIgnoreData(...)
  Z.IgnoreMgr:ClearAllIgnore()
end

function LocalGM.show.showGuide(...)
  local params = {
    ...
  }
  local ids = string.zsplit(params[1], "=")
  for index, value in ipairs(ids) do
    Z.GuideMgr:showGuide(tonumber(value))
  end
end

function LocalGM.show.showDebugLogWind(...)
  Panda.LuaAsyncBridge.OpenDebugLogWindow()
end

function LocalGM.show.switchIdLogin(...)
  local params = {
    ...
  }
  Z.EventMgr:Dispatch(Z.ConstValue.LoginEvt.GMSwitchIdLogin, params[1])
end

function LocalGM.show.triggerOptionSelect(...)
  local ps = {
    ...
  }
  local optStr = ps[1]
  Z.LevelMgr:OnLevelEventTrigger(E.LevelEventType.OnOptionSelect, optStr)
  local cancelSource = Z.CancelSource.Rent()
  Z.CoroUtil.create_coro_xpcall(function()
    local proxy = require("zproxy.world_proxy")
    proxy.UserDoAction(optStr, cancelSource:CreateToken())
    cancelSource:Recycle()
  end)()
end

function LocalGM.show.addLocalModel(...)
  local params = {
    ...
  }
  Panda.LuaAsyncBridge.AddLocalModel(params[1])
end

function LocalGM.show.closeDamage(...)
  local dmgVm = Z.VMMgr.GetVM("damage")
  dmgVm.CloseDamageView()
end

function LocalGM.show.finishCurQuest(...)
  local questData = Z.DataMgr.Get("quest_data")
  local trackId = questData:GetQuestTrackingId()
  if trackId == nil then
    return
  end
  local data = questData:GetQuestByQuestId(trackId)
  if data == nil then
    return
  end
  local stepId = data.stepId
  local cmdInfo = string.zconcat("finishQuest ", trackId, ",", stepId)
  local gmVm = Z.VMMgr.GetVM("gm")
  local gm_data = Z.DataMgr.Get("gm_data")
  gmVm.SubmitGmCmd(cmdInfo, gm_data.CancelSource)
end

function LocalGM.show.closeEffect(state)
  local isClosed = (tonumber(state) or 0) == 1
  Z.LuaBridge.SetEffectSwitch(not isClosed)
end

function LocalGM.show.switchAsyncLoadEffect(state)
  local isOpen = (tonumber(state) or 0) == 1
  Z.LuaBridge.SetAsyncLoadEffect(isOpen)
end

function LocalGM.show.switchEffectCountMonitor(state)
  local isOpen = (tonumber(state) or 0) == 1
  Z.LuaBridge.SetEffectCountMonitor(isOpen)
end

function LocalGM.show.closeHud(state)
  local isClosed = (tonumber(state) or 0) == 1
  Z.LuaBridge.SetHudSwitch(not isClosed, Panda.ZGame.EHudAvailableSource.EGm)
end

function LocalGM.show.switchEntityShowState(...)
  local params = {
    ...
  }
  Panda.LuaAsyncBridge.SwitchEntityShowStateForGM(params[1], params[2])
end

function LocalGM.show.hudGmSwitch(...)
  local params = {
    ...
  }
  Panda.LuaAsyncBridge.SwitchHudGM(params[1])
end

function LocalGM.show.addClientBuff(buffId, uuid)
  buffId = tonumber(buffId) or 0
  uuid = tonumber(uuid) or 0
  Z.LuaBridge.GmAddClientBuff(buffId, uuid)
end

function LocalGM.show.delClientBuff(buffId, uuid)
  buffId = tonumber(buffId) or 0
  uuid = tonumber(uuid) or 0
  Z.LuaBridge.GmDelClientBuff(buffId, uuid)
end

function LocalGM.show.useKcpNetwork(networkTypeStr)
  local networkType = tonumber(networkTypeStr) or 1
  Z.Rpc.SetWorldConnectionType(networkType)
  Z.EventMgr:Dispatch("CmdResult", os.date("%Y.%m.%d %H:%M:%S", os.time()) .. " " .. "GM: cmd useKcpNetwork success")
end

function LocalGM.show.setRpcTimeOut(timeout)
  local ts = tonumber(timeout) or 5000
  Z.Rpc.SetTimeOut(ts)
end

function LocalGM.show.takePhoto()
  local cameraVM = Z.VMMgr.GetVM("camerasys")
  local gmData = Z.DataMgr.Get("gm_data")
  Z.CoroUtil.create_coro_xpcall(function()
    for i = 1, 50 do
      local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShot)
      local oriId = asyncCall(gmData.CancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysViewOri)
      local photoWidth, photoWidth = cameraVM.GetTakePhotoSize()
      local resizeOriId = Z.LuaBridge.ResizeTextureSizeForAlbum(oriId, E.NativeTextureCallToken.CamerasysViewOri, photoWidth, photoWidth)
      local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShot)
      local effectId = asyncCall(gmData.CancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysView)
      local thumbId = Z.LuaBridge.ResizeTextureSizeForAlbum(effectId, E.NativeTextureCallToken.CamerasysView, 512, 288)
      cameraVM.SavePhotoToTempAlbum(resizeOriId, effectId, thumbId)
      Z.LuaBridge.ReleaseScreenShot(resizeOriId)
      Z.LuaBridge.ReleaseScreenShot(effectId)
      Z.LuaBridge.ReleaseScreenShot(thumbId)
    end
    Z.TipsVM.ShowTipsLang(1000001)
  end, function(err)
    logError("Operation failed!")
    logError(err)
  end)()
end

function LocalGM.show.enterFunctionDungeon(functionID, dungeonId, selectType, heroKeyItemUuid)
  local enterdungeonsceneVm = Z.VMMgr.GetVM("ui_enterdungeonscene")
  Z.CoroUtil.create_coro_xpcall(function()
    local gmData = Z.DataMgr.Get("gm_data")
    local affix = {}
    enterdungeonsceneVm.AsyncCreateLevel(functionID, dungeonId, gmData.CancelSource:CreateToken(), affix, nil, selectType, heroKeyItemUuid)
  end, function(err)
    logError(err)
  end)()
end

function LocalGM.show.addMemoryPressure()
  Z.LuaBridge.AddMemoryPressure()
end

function LocalGM.show.saveHomeLocalData()
  Z.DIServiceMgr.HomeService:SaveLocalData()
end

function LocalGM.show.setSavePowerOpen(...)
  local params = {
    ...
  }
  local isOpen = params[1] == 1
  local powerSaveVM = Z.VMMgr.GetVM("power_save")
  powerSaveVM.SetIsPowerSaveOpen(isOpen)
end

function LocalGM:CallLocalGM(meesageConmmand, ...)
  local classTbl = self.show[meesageConmmand]
  if classTbl then
    classTbl(...)
  end
end

return LocalGM
