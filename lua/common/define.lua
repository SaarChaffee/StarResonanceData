_G.module = nil
require("zutil.class")
require("zutil.expand")
require("zutil.log")
require("utility.pb_helper")
require("common.ui_load_path")

function logError(...)
  local report = Panda.SDK.ZReport
  local zlog = ZUtil.ZDebug
  zlog.LogError("[lua] " .. _formatStr(...) .. [[

[traceback] ]] .. debug.traceback())
  report.ReportError("LuaLogError", "[lua] " .. _formatStr(...) .. [[

[traceback] ]] .. debug.traceback(), "")
end

Z = {}
BridgeDataCache = {}
SkillSlotShowData = {}
Z.GameObject = UnityEngine.GameObject
Z.Transform = UnityEngine.Transform
Z.CancelSource = ZUtil.ZCancelSource
Z.CancelException = Z.CancelSource.CancelException
Z.LuaBridge = Panda.LuaAsyncBridge
Z.UIRoot = Panda.ZUi.ZUiRoot.Instance
Z.Rpc = ZCode.ZRpc.ZRpcCtrl
Z.RpcCallRegister = ZCode.ZRpc.ZRpcCallRegister
Z.InputMgr = Panda.ZInput.ZInputManager.Instance
Z.PlayerInputController = Panda.ZInput.PlayerInputController.Instance
Z.RewiredActionsConst = Panda.ZInput.RewiredActionsConst
Z.PGame = Panda.ZGame
Z.MiniMapManager = Panda.ZGame.MiniMapManager.Instance
Z.HeroDungeonMgr = Panda.ZGame.HeroDungeonManager.Instance
Z.World = Panda.ZGame.ZWorld.Instance
Z.EntityMgr = Panda.ZGame.ZEntityMgr.Instance
Z.Entity = Panda.ZGame.ZEntity
Z.LocalAttr = Panda.ZGame.EAttrLocalType
Z.ModelAttr = Panda.ZGame.EAttrModelType
Z.PackAttr = Panda.ZGame.EAttrPackType
Z.ModelRenderType = Panda.ZGame.EModelRenderType
Z.AttrCreator = Panda.ZGame.ZAttrCreator
Z.AudioMgr = Panda.ZAudio.ZAudioMgr.Instance
Z.EventParser = Panda.ZGame.ZEventParser
Z.QuestMgr = Panda.ZGame.QuestMgr.Instance
Z.BugReportMgr = Panda.BugReport.BugReportManager.Instance
Z.CameraMgr = Panda.ZGame.CameraManager.Instance
Z.CameraFrameCtrl = Panda.ZGame.CameraFrameCtrl.Instance
Z.ZAnimActionPlayMgr = Panda.ZAnim.ZAnimActionPlayMgr.Instance
Z.ModelGlobalColor = Panda.ZGame.ZModelGlobalColor
Z.AnimBaseData = Panda.ZGame.AnimBaseData
Z.GoalPosType = Panda.ZGame.EGoalPosType
Z.EInteractionBtnType = Panda.ZGame.EInteractionBtnType
Z.DamageData = Panda.ZGame.DamageDataMgr.Instance
Z.TouchManager = Panda.ZInput.ZTouchManager.Instance
Z.LocalizationMgr = Panda.Utility.Localization.LocalizationMgr.Instance
Z.AnimObjData = Panda.ZGame.AnimObjData
Z.UIEffectMgr = Panda.ZGame.ZUiEffectMgr.Instance
Z.Streaming = Panda.Streaming.StreamingManager.Instance
Z.HttpMgr = Panda.ZGame.HttpMgr.Instance
Z.HttpRequest = Panda.ZGame.HttpRequest
Z.SnapShotMgr = Panda.ZGame.SnapShotMgr.Instance
Z.HttpResponse = Panda.ZGame.HttpResponse
Z.DOTweenAnimType = Panda.ZUi.DOTweenAnimType
Z.GoalGuideMgr = Panda.ZGame.GoalGuideMgr.Instance
Z.ZTaskUtils = Panda.Utility.ZTaskUtils
Z.PlayerLoopTiming = Cysharp.Threading.Tasks.PlayerLoopTiming
Z.MultActionMgr = Panda.ZGame.ZMultActionMgr.Instance
Z.EPFlowBridge = DreamMaker.Logic.EPFlowFromLuaBridge
Z.EPFlowConfrontationType = DreamMaker.Logic.EConfrontationOptionType
Z.QuestFlowMgr = Panda.ZGame.EPFlowGraph.QuestFlowManager.Instance
Z.NpcBehaviourMgr = Panda.ZGame.ZNpcBehaviourMgr.Instance
Z.CosXmlRequest = Panda.ZGame.CosXmlRequest
Z.EPFlowEventType = DreamMaker.Logic.EPFlowEventType
Z.WorldUIMgr = Panda.ZUi.ZWorldUIMgr.Instance
Z.SceneMaskMgr = Panda.ZUi.ZSceneMaskMgr.Instance
Z.UITimelineDisplay = Panda.ZUi.ZUiTimelineDisplay.Instance
Z.SettlementCutMgr = Panda.ZGame.SettlementCutMgr.Instance
Z.Voice = Panda.SDK.ZVoice
Z.SDKDevices = Panda.SDK.ZDevices
Z.SDKLogin = Panda.SDK.ZLogin
Z.SDKReport = Panda.SDK.ZReport
Z.SDKReportEvent = Bokura.Plugins.Report.Event
Z.SDKWebView = Panda.SDK.ZWebView
Z.SDKNotice = Panda.SDK.ZNotice
Z.SDKAntiCheating = Panda.SDK.ZAntiCheating
Z.SDKHotUpdate = Panda.SDK.ZHotUpdate
Z.SDKShare = Panda.SDK.ZShare
Z.CosMgr = Panda.ZGame.CosMgr.Instance
Z.VoiceBridge = Panda.ZGame.ZVoiceBridge
Z.SkillDataMgr = Panda.ZGame.SkillControlDataMgr.Instance
Z.LocalUserDataMgr = Panda.Utility.LocalUserDataManager
Z.GameDisplayInfoUtil = Panda.Utility.GameDisplayInfoUtil
Z.StatusSwitchMgr = Panda.ZGame.ZStatusSwitchMgr.Instance
Z.EStatusSwitch = require("table.gen.enum_status_switch")
Z.ViewStatusSwitchMgr = require("common.status_switch_mgr")
Z.CoroUtil = require("zutil.coro_util")
Z.NetWaitHelper = require("utility.net_wait_helper")
Z.ModelHelper = Panda.ZGame.ZModelHelper
Z.ModelManager = Panda.ZGame.ZModelManager.Instance
Z.EntityHelper = Panda.ZGame.ZEntityHelper
local evtDispatcher = require("common.event_dispatcher")
Z.EventMgr = evtDispatcher.new()
Z.CoroEventMgr = evtDispatcher.new(nil, true)
Z.UI = require("ui.ui_define")
Z.UIConfig = require("ui.ui_config")
Z.UIMgr = require("ui.ui_manager").new()
Z.DataMgr = require("ui.model.data_manager")
Z.VMMgr = require("ui.view_model.vm_mgr")
Z.ServiceMgr = require("ui.service.service_mgr")
Z.TableMgr = require("utility.table_manager")
Z.StageMgr = require("stage.stage_mgr")
Z.TimerMgr = require("utility.timer_manager")
Z.ConnectMgr = require("utility.connect_manager").new()
Z.UnrealSceneMgr = require("utility.unreal_scene_manager").new()
Z.PhotoQuestMgr = require("utility.photo_quest_manager").new()
Z.Game = require("game")
Z.GameContext = Panda.Core.GameContext
local cjson = require("cjson")
local configVersionJsonStr = Z.GameContext.GetConfigVersionJsonStr()
local protocolVersionJsonStr = Z.GameContext.GetProtocolVersionJsonStr()
Z.Version = {}
Z.Version.ConfigVersion = cjson.decode(configVersionJsonStr).ConfigVersion
Z.Version.ProtocolVersion = cjson.decode(protocolVersionJsonStr).ProtocolVersion
Z.Global = require("table.gen.Global")
Z.MonsterHunt = require("table.gen.MonsterHuntConfig")
Z.TrialRoadConfig = require("table.gen.TrialRoadConfig")
Z.WorldBoss = require("table.gen.WorldBossGlobalConfig")
Z.GlobalParkour = require("table.gen.GlobalParkour")
Z.GlobalWorldEvent = require("table.gen.GlobalWorldEvent")
Z.UnionActivityConfig = require("table.gen.UnionActivityConfig")
Z.PlanetMemorySeasonConfig = require("table.gen.PlanetMemorySeasonConfig")
Z.StallRuleConfig = require("table.gen.StallRule")
Z.SystemItem = require("table.gen.SystemItem")
Z.EntityTabManager = require("common.entitytablemgr")
Z.ServerTime = Panda.Utility.ZServerTime.Instance
Z.UIUtil = require("ui.ui_util")
Z.LevelMgr = require("level.level_mgr")
Z.LocalGmMgr = require("level.local_gm_mgr")
Z.LuaGoalMgr = require("goal.goal_mgr")
Z.GlobalTimerMgr = require("utility.global_timer_manager").new()
Z.QteMgr = require("ui.component.qte.qte_creator")
Z.QueueTipManager = require("utility.queue_tip_manager")
Z.GameShareManager = require("utility.gameshare_manager").new()
Z.ConstValue = require("common.const_value")
Z.DialogViewDataMgr = require("utility.dialog_viewdata_manager").new()
Z.ContainerMgr = require("zcontainer.container_mgr")
Z.ItemOperatBtnMgr = require("ui.item_btns.itembtns_mgr")
Z.Placeholder = require("common.placeholder")
Z.ColorHelper = require("common.color")
Z.RichTextHelper = require("common.rich_text_helper")
Z.ConditionHelper = require("common.condition_helper")
Z.CounterHelper = require("common.counter_helper")
Z.ChatTimmingMark = require("utility.chat_timming_mark")
Z.ChatMsgHelper = require("common.chat_msg_helper")
Z.NumTools = require("utility.number_tools")
Z.TimeTools = require("tools.time_tools")
Z.LsqLiteMgr = require("utility.lsqlite_manager")
Z.IsPCUI = Z.GameContext.IsPlayInPCMode
Z.RedPointMgr = require("rednode.reddot_mgr")
Z.GuideMgr = require("utility.guide_mgr").new()
Z.GuideEventMgr = require("utility.guide_event")
Z.TipsVM = Z.VMMgr.GetVM("all_tips")
Z.CommonTipsVM = Z.VMMgr.GetVM("common_tips")
Z.IgnoreMgr = Panda.ZGame.ZIgnoreMgr.Instance
Z.InteractionMgr = Panda.ZGame.ZInteractionMgr.Instance
Z.MouseMgr = Panda.ZInput.ZMouseManager.Instance
Z.SteerMgr = Panda.ZUi.SteerMgr.Instance
Z.IsOfficalVersion = Panda.Core.GameContext.IsOfficalVersion
Z.ScreenMark = Panda.Core.GameContext.ScreenMark
Z.IsBlockGM = Panda.Core.GameContext.IsBlockGM
Z.IsBlockBUGReport = Panda.Core.GameContext.IsBlockBUGReport
Z.IsHideGM = Panda.Core.GameContext.IsHideGM
Z.IsHideBUGReport = Panda.Core.GameContext.IsHideBUGReport
Z.InputActionEventType = Rewired.InputActionEventType
Z.BuffMgr = require("mgr.buff.buff_mgr").new()
Z.UICameraHelper = require("common.ui_camera_helper")
Z.ECameraState = Z.PGame.CameraDefine.ECameraState
Z.DIInjector = require("utility.di_injector")
Z.GridFixedType = Panda.ZUi.GridFixedType
Z.LangMgr = require("mgr.language.lang_mgr").new()
Z.ItemEventMgr = require("common.item_event_mgr")
Z.LuaDataMgr = Panda.ZUi.LuaDataMgr.Instance
Z.ZInputMapModeMgr = Panda.ZInput.ZInputMapModeMgr.Instance
Z.WaitFadeManager = Panda.ZGame.WaitFadeManager.Instance

function Lang(key, param)
  return Z.LangMgr:Lang(key, param)
end

Z.DIServiceMgr = {
  HomeService = Z.DIInjector.InjectTag,
  FishingService = Z.DIInjector.InjectTag,
  ContainerSyncService = Z.DIInjector.InjectTag,
  DungeonSyncService = Z.DIInjector.InjectTag,
  PlayerAttrComponentWatcherService = Z.DIInjector.InjectTag,
  ZTimeEventSchedulerService = Z.DIInjector.InjectTag,
  ZCfgTimerService = Z.DIInjector.InjectTag
}
Z.DIInjector.Inject(Z.DIServiceMgr)

function Z.RegPb()
  local pb = require("pb2")
  require("zservice.service_register")
  local buffer, len = Z.LuaBridge.GetFileIntPtr("zproto.fd", 0)
  local pb_unsafe = require("pb2.unsafe")
  local ret, reason = pb_unsafe.load(buffer, len)
  Z.LuaBridge.ReleaseIntPtr(buffer)
  assert(ret, reason)
end

function Z.PbErrCode(errName)
  local pb = require("pb2")
  return pb.enum("zproto.EErrorCode", errName)
end

function Z.PbErrName(errCode)
  local pb = require("pb2")
  return pb.enum("zproto.EErrorCode", errCode)
end

function Z.PbAttrEnum(attrType)
  local pb = require("pb2")
  return pb.enum("zproto.EAttrType", attrType)
end

function Z.PbEnum(enumTypeName, enumName)
  local pb = require("pb2")
  return pb.enum("zproto." .. enumTypeName, enumName)
end

Z.Yield = Z.CoroUtil.async_to_sync(Panda.Utility.ZTaskUtils.YieldForLua, 1)
Z.Delay = Z.CoroUtil.async_to_sync(Panda.Utility.ZTaskUtils.DelayForLua, 2)

function Z.BitOR(a, b)
  local p, c = 1, 0
  while 0 < a + b do
    local ra, rb = a % 2, b % 2
    if 0 < ra + rb then
      c = c + p
    end
    a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
  end
  return c
end

function Z.BitNOT(n)
  local p, c = 1, 0
  while 0 < n do
    local r = n % 2
    if r < 1 then
      c = c + p
    end
    n, p = (n - r) / 2, p * 2
  end
  return c
end

function Z.BitAND(a, b)
  local p, c = 1, 0
  while 0 < a and 0 < b do
    local ra, rb = a % 2, b % 2
    if 1 < ra + rb then
      c = c + p
    end
    a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
  end
  return c
end

function Z.ObjectIsNullOrEmpty(obj)
  if obj == nil then
    return true
  end
  local str = tostring(obj)
  if str == "null" or str == "nil" or str == "" then
    return true
  end
  if type(obj) == "userdata" and obj.Equals ~= nil and obj:Equals(nil) then
    logError("The userdata maybe memery leak")
    return true
  end
  return false
end

function Z.Hash33(str)
  local hash = 5381
  local maxInt32 = 4.294967295E9
  for i = 1, #str do
    hash = hash * 33 + string.byte(str, i) & maxInt32
  end
  return hash
end
