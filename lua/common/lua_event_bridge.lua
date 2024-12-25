local paraseInfo = function()
  local data = {}
  for k, v in pairs(BridgeDataCache) do
    data[k] = v
  end
  BridgeDataCache = {}
  return data
end
local events = {
  QUIT_GAME_NOTICE = function(quitType)
    logGreen("QUIT_GAME_NOTICE, Type is {0}", tostring(quitType))
    Z.DialogViewDataMgr:OpenOKDialog(Lang("QuitGameNotice"), function()
      Z.DialogViewDataMgr:CloseDialogView()
      Z.GameContext.QuitGame()
    end, E.EDialogViewDataType.System, true)
  end,
  ANTI_ADDICTION_NOTICE = function(isForceClose, content, title, duration)
    logGreen("ANTI_ADDICTION_NOTICE, isForceClose={0}, content={1}, title={2}, duration={3}", tostring(isForceClose), content, title, tostring(duration))
    Z.DialogViewDataMgr:OpenOKDialogWithTitle(title, content, function()
      Z.DialogViewDataMgr:CloseDialogView()
      if isForceClose then
        Z.GameContext.QuitGame()
      end
    end, E.EDialogViewDataType.System, true)
  end,
  ON_AUTO_LOGIN = function(data)
    local loginVM = Z.VMMgr.GetVM("login")
    loginVM:OnSDKAutoLogin(data)
  end,
  ON_LOGIN = function(data)
    local loginVM = Z.VMMgr.GetVM("login")
    loginVM:OnSDKLogin(data)
  end,
  ON_LOGOUT = function(data)
    logGreen("SDK logout ")
  end,
  ON_VISUAL_LAYER_CHANGED = function()
    local deadVm = Z.VMMgr.GetVM("dead")
    if deadVm.CheckPlayerIsDead() then
      deadVm.OpenDeadView()
    else
      Z.UIMgr:GotoMainView()
    end
    Z.ServiceMgr:OnVisualLayerChange()
    Z.EventMgr:Dispatch(Z.ConstValue.VisualLayerChange)
  end,
  DAGAME_SKILLCOUNT = function(count)
    Z.DataMgr.Get("damage_data").ReleaseSkillCount = count
  end,
  ON_INSTANCE_CHARENT = function(Uuid)
    Z.VMMgr.GetVM("friends_main").CheckFriendRemark(Uuid)
  end,
  USE_GM = function(Command, param, tagetId)
    local gmVM = Z.VMMgr.GetVM("gm")
    if gmVM then
      gmVM.SendCmd(Command, param, tagetId)
    end
  end,
  DAGAME_DATA = function(data, count)
    Z.VMMgr.GetVM("damage").SetGamadeData(data, count)
  end,
  ON_DAGAME_BUFF = function(buffData)
    Z.VMMgr.GetVM("damage").SetBuffData(buffData)
  end,
  ON_NORMAL_HIT_BUFF = function(buffData)
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.HurtEvent)
  end,
  ON_IDCARD_INFO = function(uuidList)
    local mainUiVM = Z.VMMgr.GetVM("mainui")
    mainUiVM.RefreshIdCard(uuidList)
    if uuidList ~= nil and uuidList.count > 0 then
      local entityVm = Z.VMMgr.GetVM("entity")
      local multActionVM = Z.VMMgr.GetVM("multaction")
      local charID = entityVm.UuidToEntId(uuidList[0])
      multActionVM.SetInviteId(charID)
    end
  end,
  ON_UNREALSCENE_INFO = function(unRealSceneList)
    local planetmemoryVM = Z.VMMgr.GetVM("planetmemory")
    planetmemoryVM.RefPlanetmemoryMainUI(unRealSceneList)
  end,
  ON_MULTACTION_INFO = function(vOrigId, vActionId)
    local multActionVM = Z.VMMgr.GetVM("multaction")
    multActionVM.NotVaildMultAction(vOrigId, vActionId)
  end,
  ON_LOADING_UPDATE = function()
  end,
  ON_GM_VISIBLE = function()
    local gmVM = Z.VMMgr.GetVM("gm")
    if gmVM then
      local visible = Z.UIMgr:IsActive("gm")
      if not visible then
        gmVM.OpenGmView()
      else
        gmVM.CloseGmView()
      end
    end
  end,
  ON_GM_INPUTTAB = function()
    Z.EventMgr:Dispatch("InputKeyTab")
  end,
  ON_GM_INPUTUP = function()
    Z.EventMgr:Dispatch("InputKeyUp")
  end,
  ON_GM_INPUTDOWN = function()
    Z.EventMgr:Dispatch("InputKeyDown")
  end,
  ON_SHOW_MAINUI = function()
    Z.UIMgr:OpenView(Z.ConstValue.MainViewName)
  end,
  ON_CLOSE_MAINUI = function()
    Z.UIMgr:CloseView(Z.ConstValue.MainViewName)
  end,
  ON_GMMAIN_VISIBLE = function()
    local isActive = Z.UIMgr:IsActive("gm_main")
    if isActive then
      Z.UIMgr:CloseView("gm_main")
    else
      Z.UIMgr:OpenView("gm_main")
    end
  end,
  ON_GMBUTTON_VISIBLE = function()
    local isActive = Z.UIMgr:IsActive("gm_main")
    if isActive then
      Z.UIMgr:CloseView("gm_main")
    else
      Z.UIMgr:OpenView("gm_main")
    end
    Z.UIRoot:ActiveDebug(not isActive)
  end,
  ON_SHOW_SCREENFFECT = function(...)
    local arg = {
      ...
    }
    local animName = table.unpack(arg)
    Z.UIMgr:OpenView("screeneffect", {effectname = animName})
  end,
  BLACK_FADE_IN = function(isInstant, isWhite)
    local args = {}
    args.IsInstant = isInstant
    args.IsWhite = isWhite
    args.TimeOut = 10
    Z.UIMgr:FadeIn(args)
  end,
  BLACK_FADE_OUT = function(isInstant, isWhite)
    local args = {}
    args.IsInstant = isInstant
    args.IsWhite = isWhite
    args.TimeOut = 10
    Z.UIMgr:FadeOut(args)
  end,
  ON_ENERGY_CHANGE = function()
    Z.VMMgr.GetVM("parkourtpl").OpenView()
  end,
  ON_ENERGY_ALERT = function()
    Z.EventMgr:Dispatch(Z.ConstValue.Parkour.QteAlert)
  end,
  ON_SHOW_ALL_ACTIVEVIEWS = function()
    Z.UIMgr:ShowAllActiveViews()
  end,
  ON_HIDE_ALL_ACTIVEVIEWS = function()
    Z.UIMgr:HideAllActiveViews()
  end,
  SET_ALL_UI_EFFECT_VISIBLE = function(...)
    local arg = {
      ...
    }
    if #arg < 1 then
      return
    end
    Z.UIMgr:SetAllEffectGOVisible(arg[1])
  end,
  ON_OPEN_UI = function(...)
    local arg = {
      ...
    }
    local data = paraseInfo()
    Z.UIMgr:OpenView(arg[1], data)
  end,
  ON_CLOSE_UI = function(...)
    local arg = {
      ...
    }
    Z.UIMgr:CloseView(arg[1])
  end,
  ON_CALL_VM_FUNC = function(...)
    local arg = {
      ...
    }
    local data = paraseInfo()
    Z.VMMgr.GetVM(arg[1])[arg[2]](data)
  end,
  DISPATCH_COROEVENT = function(...)
    local arg = {
      ...
    }
    if #arg < 1 then
      return
    end
    local eventName = arg[1]
    Z.CoroEventMgr:Dispatch(eventName, table.unpack(arg, 2))
  end,
  DISPATCH_EVENT = function(...)
    local arg = {
      ...
    }
    if #arg < 1 then
      return
    end
    local eventName = arg[1]
    Z.EventMgr:Dispatch(eventName, table.unpack(arg, 2))
  end,
  OPEN_CFTATION_TALK_OPTIONS_BY_FLOW = function(options)
    local vm = Z.VMMgr.GetVM("talk_option")
    vm.OpenConfrontationTalkOptionView(options)
  end,
  SET_BACK_GROUND = function(data)
    Z.EventMgr:Dispatch(Z.ConstValue.Talk.OnSetBackGround, data)
  end,
  OPEN_TALK_OPTIONS_BY_FLOW = function(optionData)
    local vm = Z.VMMgr.GetVM("talk_option")
    vm.OpenFlowTalkOptionView(optionData.OptionContentList, optionData.IsAddExtraOption)
  end,
  OPEN_INTERROGATE_OPTIONS_BY_FLOW = function(optionData)
    local vm = Z.VMMgr.GetVM("talk_option")
    vm.OpenFlowInterrogateOptionView(optionData.OptionContentList, optionData.IsAddExtraOption)
  end,
  CLOSE_TALK_OPTIONS = function()
    local vm = Z.VMMgr.GetVM("talk_option")
    vm.CloseOptionView()
  end,
  SET_NODE_IS_ALLOW_SKIP = function(isAllow)
    local vm = Z.VMMgr.GetVM("talk")
    vm.SetNodeIsAllowSkip(isAllow)
  end,
  OPEN_COMMON_TALK_DIALOG_UI = function(viewData)
    local vm = Z.VMMgr.GetVM("talk")
    vm.OpenCommonTalkDialog(viewData)
  end,
  CLOSE_COMMON_TALK_DIALOG_UI = function()
    local vm = Z.VMMgr.GetVM("talk")
    vm.CloseCommonTalkDialog()
  end,
  OPEN_COMMON_TALK = function(viewData)
    local vm = Z.VMMgr.GetVM("talk")
    vm.OpenCommonTalk(viewData)
  end,
  CLOSE_COMMON_TALK = function()
    local vm = Z.VMMgr.GetVM("talk")
    vm.CloseCommonTalk()
  end,
  OPEN_MODEL_TALK = function(viewData)
    local vm = Z.VMMgr.GetVM("talk_model")
    vm.OpenModelTalk(viewData)
  end,
  CLOSE_MODEL_TALK = function(isForce)
    local vm = Z.VMMgr.GetVM("talk_model")
    vm.CloseModelTalk(isForce)
  end,
  ON_PLAY_CUTSCENE = function(cutsceneId, isInFlow)
    local vm = Z.VMMgr.GetVM("cutscene")
    vm.OnPlayCutscene(cutsceneId, isInFlow)
  end,
  ON_STOP_CUTSCENE = function(cutsceneId)
    local vm = Z.VMMgr.GetVM("cutscene")
    vm.OnStopCutscene(cutsceneId)
  end,
  ON_FINISH_CUTSCENE = function(cutsceneId)
    local vm = Z.VMMgr.GetVM("cutscene")
    vm.OnFinishCutscene(cutsceneId)
  end,
  OPEN_CUTSCENE_QTE_CLICK_ONCE = function(qteId, v2Percent, fDuration, iType, sIcon)
    local viewData = {
      Id = qteId,
      Type = E.CutsceneQteType.ClickOnce,
      X = v2Percent.x,
      Y = v2Percent.y,
      duration = fDuration,
      uiType = iType,
      icon = sIcon
    }
    Z.UIMgr:OpenView("cutscene_qte_main", viewData)
  end,
  OPEN_CUTSCENE_QTE_CLICK_MULTI = function(qteId, percentX, percentY, clickNum)
    local viewData = {
      Id = qteId,
      Type = E.CutsceneQteType.ClickMulti,
      X = percentX,
      Y = percentY,
      ClickNum = clickNum
    }
    Z.UIMgr:OpenView("cutscene_qte_main", viewData)
  end,
  OPEN_CUTSCENE_QTE_LONG_PRESS = function(qteId, percentX, percentY, pressTime)
    local viewData = {
      Id = qteId,
      Type = E.CutsceneQteType.LongPress,
      X = percentX,
      Y = percentY,
      PressTime = pressTime
    }
    Z.UIMgr:OpenView("cutscene_qte_main", viewData)
  end,
  OPEN_CUTSCENE_QTE_SLIDE = function(qteId, percentX, percentY)
    local viewData = {
      Id = qteId,
      Type = E.CutsceneQteType.Slide,
      X = percentX,
      Y = percentY
    }
    Z.UIMgr:OpenView("cutscene_qte_main", viewData)
  end,
  OPEN_CUTSCENE_SUBTITLE = function(subtitleData, maxTime)
    local viewData = {trackData = subtitleData, maxTime = maxTime}
    Z.UIMgr:OpenView("cutscene_subtitle_window", viewData)
  end,
  CLOSE_CUTSCENE_SUBTITLE = function()
    Z.UIMgr:CloseView("cutscene_subtitle_window")
  end,
  OPEN_CUTSCENE_IMAGE = function(subtitleData)
    local viewData = {trackData = subtitleData}
    Z.UIMgr:OpenView("cutscene_image_window", viewData)
  end,
  CLOSE_CUTSCENE_IMAGE = function()
    Z.UIMgr:CloseView("cutscene_image_window")
  end,
  OnEPFlowVoiceEnd = function()
    Z.EventMgr:Dispatch(Z.ConstValue.NpcTalk.EPFlowVoiceEnd)
  end,
  PLAY_CLOSE_CUTSCENE_SUBTITLE_ANIM = function()
    Z.EventMgr:Dispatch(Z.ConstValue.SubTitleClose)
  end,
  PLAY_CUTSCENE_UIEFFECT = function(UIEffectData)
    local viewData = {effectData = UIEffectData}
    Z.UIMgr:OpenView("cutscene_ui_effect_window", viewData)
  end,
  DESTORY_CUTSCENE_UIEFFECT = function(UIEffectData)
    Z.EventMgr:Dispatch(Z.ConstValue.UIEffectDestory, UIEffectData)
  end,
  OPEN_CUTSCENE_PLAY_CG = function(path, onStarted)
    local viewData = {}
    viewData.path = path
    viewData.onStarted = onStarted
    Z.UIMgr:OpenView("cutscene_play_cg", viewData)
  end,
  CLOSE_CUTSCENE_PLAY_CG = function()
    Z.UIMgr:CloseView("cutscene_play_cg")
  end,
  SEEK_CUTSCENE_PLAY_CG = function(time)
    Z.EventMgr:Dispatch(Z.ConstValue.Cutscene.SeekCG, time)
  end,
  PAUSE_SEEK_CUTSCENE_PLAY_CG = function(time)
    Z.EventMgr:Dispatch(Z.ConstValue.Cutscene.PauseSeekCG, time)
  end,
  ON_ENTER_OR_EXIT_ZONE = function(isEnter, zoneUid)
    local questTrackVM = Z.VMMgr.GetVM("quest_track")
    questTrackVM.RefreshQuestGuideEffectVisible()
    Z.EventMgr:Dispatch(Z.ConstValue.PlayerEnterOrExitZone, isEnter, zoneUid)
  end,
  ON_EPFLOW_START = function(flowId)
    local talkVM = Z.VMMgr.GetVM("talk")
    talkVM.OnEPFlowStart(flowId)
  end,
  ON_EPFLOW_STOP = function(flowId, endPort, isFinished)
    local talkVM = Z.VMMgr.GetVM("talk")
    talkVM.OnEPFlowStop(flowId, endPort, isFinished)
  end,
  ON_QUEST_FLOW_LOADED = function(questId)
    local vm = Z.VMMgr.GetVM("quest")
    vm.OnQuestFlowLoaded(questId)
  end,
  OPEN_TALK_ITEM_SUBMIT = function()
    local vm = Z.VMMgr.GetVM("item_submit")
    vm.OpenItemSubmitView(E.TalkItemSubmitType.Submit)
  end,
  OPEN_TALK_ITEM_SHOW = function()
    local vm = Z.VMMgr.GetVM("item_submit")
    vm.OpenItemSubmitView(E.TalkItemSubmitType.Show)
  end,
  GOAL_DISTANCE_REACH = function(srcId)
    local vm = Z.VMMgr.GetVM("goal_guide")
    vm.RemoveGuideGoalBySrcId(srcId)
  end,
  ONCOLLECTION_ADD = function(id, position, uuid)
    local mapVM = Z.VMMgr.GetVM("map")
    mapVM.AddCollectData(id, position, uuid)
  end,
  ONCOLLECTION_REMOVE = function(id)
    local mapVM = Z.VMMgr.GetVM("map")
    mapVM.RemoveCollectData(id)
  end,
  ADD_INTERACTION = function(uiData)
    local vm = Z.VMMgr.GetVM("interaction")
    vm.AddInteractionOption(uiData)
  end,
  DELETE_INTERACTION = function(uiData)
    local vm = Z.VMMgr.GetVM("interaction")
    vm.DeleteInteractionOption(uiData)
  end,
  DO_INTERACTION = function(uuid, interactionCfgId, templateId, actionData)
    local vm = Z.VMMgr.GetVM("interaction")
    vm.DoInteractionAction(uuid, interactionCfgId, templateId, actionData)
  end,
  DO_INTERACTION_END_TRIGGER = function(uuid, interactionCfgId, templateId, actionData)
    local vm = Z.VMMgr.GetVM("interaction")
    vm.DoInteractionActionEndTrigger(uuid, interactionCfgId, templateId, actionData)
  end,
  INTERACTION_BACK = function(isSuccess, uuid, templateId, interactionCfgId, actionType)
    Z.EventMgr:Dispatch(Z.ConstValue.Interaction.OnInteractionBack, isSuccess, uuid, templateId, actionType)
    local vm = Z.VMMgr.GetVM("interaction")
    vm.DoInteractionActionBack(isSuccess, uuid, templateId, interactionCfgId, actionType)
  end,
  CACHE_CAMERA_PARAM = function(x, y, zoom)
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.CacheParam, x, y, zoom)
  end,
  SELECT_INTERACTION = function(data)
    local vm = Z.VMMgr.GetVM("interaction")
    vm.SelectInteractionOption(data)
  end,
  ONCLICK_INTERACTION = function(data)
    local vm = Z.VMMgr.GetVM("interaction")
    vm.OnPointClickListener(data)
  end,
  ON_CHECKCONDITION = function(...)
    local args = {
      ...
    }
    return true
  end,
  ZONE_REQUEST_CONDITION_MEET = function(eventId)
    local vm = Z.VMMgr.GetVM("quest_goal")
    vm.OnZoneRequestConditionMeet(eventId)
  end,
  ADD_PIVOTPROT = function(id, distance)
    local vm = Z.VMMgr.GetVM("pivot")
    vm.AddPortGuideData(id, distance)
  end,
  OPEN_NAME_WINDOW = function()
    local vm = Z.VMMgr.GetVM("player")
    vm:OpenNameWindow()
  end,
  OPEN_EXCHANGE = function(functionId)
    local vm = Z.VMMgr.GetVM("exchange")
    vm.OpenExchangeViewByFunctionId(functionId)
  end,
  OPEN_FUNCTION_BY_FLOWATION = function(functionId)
    Z.VMMgr.GetVM("gotofunc").GoToFunc(functionId)
  end,
  EPFLOW_BROADCAST_EVENT = function(eventName)
    Z.EventMgr:Dispatch(eventName)
  end,
  START_MIXOLOGY = function(flowId)
    local pubMixology = Z.VMMgr.GetVM("pub_mixology")
    pubMixology.BeginMixilogy(flowId)
  end,
  ENT_DUNGEON = function(dungeonId)
    local cccountModuleVm = Z.VMMgr.GetVM("ui_enterdungeonscene")
    local dungeonData = Z.DataMgr.Get("dungeon_data")
    Z.CoroUtil.create_coro_xpcall(function()
      dungeonData:CreatCancelSource()
      cccountModuleVm.AsyncCreateLevel(0, dungeonId, dungeonData.CancelSource:CreateToken())
      dungeonData:RecycleCancelSource()
    end)()
  end,
  ON_OPEN_COUNTDOWN_TIPS = function(...)
    local arg = {
      ...
    }
    local tips_countdown_vm = Z.VMMgr.GetVM("tips_countdown_popup")
    tips_countdown_vm.OpenCountdownView(arg[1], arg[2], arg[3], arg[4])
  end,
  GUIDE_INPUT_EVENT = function(inputId)
    Z.GuideEventMgr:onInputEvent(inputId)
  end,
  ON_TRIGGER_EVENT = function(...)
    local arg = {
      ...
    }
    logError(table.ztostring(arg))
  end,
  KICK_OFF_CLIENT = function(...)
    local args = {
      ...
    }
    local loginVM = Z.VMMgr.GetVM("login")
    loginVM:KickOffByClient(args[1], args[2] or false)
  end,
  KICK_OFF_SERVER = function(...)
    local args = {
      ...
    }
    local loginVM = Z.VMMgr.GetVM("login")
    loginVM:KickOffByServer(args[1])
  end,
  RUN_LUA_CODE = function(...)
    local args = {
      ...
    }
    xpcall(function()
      load(args[1])()
    end, function(msg)
      logError("[lua_event_bride] RUN_LUA_CODE Error: " .. msg)
    end)
  end,
  OPEN_WAITING = function()
    Z.NetWaitHelper.SetSwitchingTag(true)
  end,
  CLOSE_WAITING = function()
    Z.NetWaitHelper.SetSwitchingTag(false)
  end,
  SHOW_TIPS = function(...)
    local args = {
      ...
    }
    Z.TipsVM.ShowTips(tonumber(args[1]) or 0, args[2])
  end,
  ON_INSIGHT = function()
    Z.EventMgr:Dispatch(Z.ConstValue.InsightEvent)
  end,
  ON_UPDATE_BOSSUI = function(bossUuid, isEnable, isALive)
    local vm = Z.VMMgr.GetVM("bossbattle")
    vm.DisplayBossUI(bossUuid, isEnable, isALive)
  end,
  SET_BOSSUI_TOP = function(bossUuid)
    local vm = Z.VMMgr.GetVM("bossbattle")
    vm.SetBossTop(bossUuid)
  end,
  ON_UI_LAYER_VISIBLE_CHANGE = function(layer, visible)
    Z.UnrealSceneMgr:SetVisibleByLayer(layer, visible)
  end,
  CUTSCENE_HIDE_UI = function(isHide)
    Z.EventMgr:Dispatch(Z.ConstValue.Cutscene.CutsceneHideUI, isHide)
  end,
  Voice_RecordUploaded = function(isSuccess, fileID, text)
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatVoiceUpLoad, isSuccess, fileID, text)
  end,
  Voice_RecordDownloaded = function(isSuccess, filePath)
    local chatMainVM = Z.VMMgr.GetVM("chat_main")
    chatMainVM.OnVoiceDownLoad(isSuccess, filePath)
  end,
  Voice_PlaybackStoped = function(filePath)
    local chatData = Z.DataMgr.Get("chat_main_data")
    if table.zcount(chatData.VoicePlayEndFuncList) > 0 then
      chatData.VoicePlayEndFuncList[1]()
      table.remove(chatData.VoicePlayEndFuncList, 1)
    end
  end,
  Voice_Init = function(isSuccess)
    local chatMainData = Z.DataMgr.Get("chat_main_data")
    chatMainData.VoiceIsInit = isSuccess
  end,
  Voice_JoinRoom = function(roomName, member)
    local teamVm = Z.VMMgr.GetVM("team")
    teamVm.EnterVoiceRoom(roomName, member)
  end,
  Voice_MemberQuitRoom = function(roomName, memberId)
    local teamVm = Z.VMMgr.GetVM("team")
    teamVm.QuitVoiceRoom(roomName, memberId)
  end,
  Voice_MemberJoinRoom = function(roomName, memberId)
  end,
  Voice_MemberOpenMic = function(roomName, memberId)
  end,
  Voice_MemberCloseMic = function(roomName, memberId)
  end,
  Voice_QuitRoom = function(roomName, memberId)
  end,
  WEEKLYHUNTCOUNTDOWNNEXT = function(isShow)
    local weeklyHunt = Z.VMMgr.GetVM("weekly_hunt")
    weeklyHunt.Countdown(isShow)
  end,
  HomeEntityCreated = function(entityId, configId)
    logGreen("HomeEntityCreated entityId:{0} configId:{1}", entityId, configId)
    Z.DIServiceMgr.HomeService:SelectEntity(entityId, false)
    Z.EventMgr:Dispatch(Z.ConstValue.Home.HomeEntitySelectingSingle, entityId, configId)
    local data = Z.DataMgr.Get("home_data")
    data:CreatHomeFurniture(configId)
    Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshWareHouseCount, configId)
  end,
  HomeEntitySelectingSingle = function(entityId, configId)
    logGreen("HomeEntitySelectingSingle entityId:{0}", entityId)
    local data = Z.DataMgr.Get("home_data")
    if data.IsDrag then
      return
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Home.HomeEntitySelectingSingle, entityId, configId)
  end,
  HomeEntitySelecting = function(selectingEntityIds, selectingConfigIds)
    logGreen("HomeEntitySelecting selectingEntityIds:{0}", table.ztostring(selectingEntityIds))
    local data = Z.DataMgr.Get("home_data")
    if data.IsDrag then
      return
    end
    local homeVm = Z.VMMgr.GetVM("home")
    homeVm.OpenOptionView(selectingEntityIds, selectingConfigIds)
  end,
  CONDITION_CHECK_FAIL_TIPS = function(condTbl)
    Z.ConditionHelper.CheckCondition(condTbl, true)
  end,
  ON_UI_VERTICAL = function(axis)
    logError("ON_UI_VERTICAL axis:{0}", axis)
  end,
  ON_UI_SUBMIT = function()
    logError("ON_UI_SUBMIT")
  end,
  FISHING_VM_OPEN = function()
    local fishingVM = Z.VMMgr.GetVM("fishing")
    fishingVM.EnterFishingState()
  end,
  FISHING_WAIT_BITE = function()
    local fishingVM = Z.VMMgr.GetVM("fishing")
    fishingVM.SetHookInWater()
  end,
  FISHING_BUOY_DIVE = function()
    local fishingVM = Z.VMMgr.GetVM("fishing")
    fishingVM.BuoyDive()
  end,
  FISHING_BITE_HOOK = function(isBite)
    local fishingVM = Z.VMMgr.GetVM("fishing")
    fishingVM.SetFishBiteHook(isBite)
  end,
  FISHING_PLAYER_DIR = function(dirType)
    local fishingVM = Z.VMMgr.GetVM("fishing")
    fishingVM.SetPlayerSwingDir(dirType)
  end,
  FISHING_FISH_DIR = function(dirType)
    local fishingVM = Z.VMMgr.GetVM("fishing")
    fishingVM.SetFishSwingDir(dirType)
  end,
  GetResolveAward = function()
    local unionTaskVM = Z.VMMgr.GetVM("union_task")
    unionTaskVM:GetResolveAward()
  end,
  ON_CREATE_WAREHOUSE = function()
    local vm = Z.VMMgr.GetVM("warehouse")
    vm.AsyncCreateWarehouse()
  end,
  GotoNextLevel = function()
    local trialroadVM_ = Z.VMMgr.GetVM("trialroad")
    trialroadVM_.GotoNextLevel()
  end,
  ReChallengeLevel = function()
    local trialroadVM_ = Z.VMMgr.GetVM("trialroad")
    trialroadVM_.ReChallengeLevel()
  end,
  ReturnTrialRoadUI = function()
    local trialroadVM_ = Z.VMMgr.GetVM("trialroad")
    trialroadVM_.ReturnTrialRoadUI()
  end,
  LeaveDuplicate = function()
    local trialroadVM_ = Z.VMMgr.GetVM("trialroad")
    trialroadVM_.LeaveDuplicate()
  end,
  SKILLAOYI_CREATE = function()
    local vm = Z.VMMgr.GetVM("resonance_power")
    vm.OpenResonancePowerCreate()
  end,
  SKILLAOYI_DECOMPOSE = function()
    local vm = Z.VMMgr.GetVM("resonance_power")
    vm.OpenResonancePowerDecompose()
  end,
  UI_UPDATE_CAMERA_STATE = function()
    Z.UIMgr:UpdateCameraState()
  end,
  SHOW_EPISOND_UI = function(...)
    local args = {
      ...
    }
    local viewData = {
      EpisodeId = args[1],
      IsStart = args[2]
    }
    Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.Episode, "quest_chapter_window", viewData)
  end,
  Time_Service_Init = function(...)
    Z.EventMgr:Dispatch(Z.ConstValue.Timer.TimerInited)
  end,
  Time_Service_UnInit = function(...)
    Z.EventMgr:Dispatch(Z.ConstValue.Timer.TimerUnInited)
  end
}
local sendLuaEvent = function(eventName, ...)
  local fun = events[eventName]
  if not fun then
    logError("SendLuaEvent {0} not found", eventName)
    return
  end
  fun(...)
end
local bridge = {SendLuaEvent = sendLuaEvent}
LuaBridge = bridge
