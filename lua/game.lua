local game = {
  Init = function()
    Z.VMMgr.Init()
    Z.ServiceMgr.Init()
    Z.VMMgr.GetVM("fighterbtns"):RegisterEvent()
    Z.VMMgr.GetVM("skill_slot"):RegisterEvent()
    Z.VMMgr.GetVM("gasha").RegisteFuncShow()
    Z.LsqLiteMgr.Init()
    Z.NetWaitHelper.Init()
    Z.LangMgr:Init()
  end,
  LateInit = function()
    require("utility.restrict_global")
    require("sync.entry")
    if not Z.GameContext.StarterRun then
      Z.ServiceMgr.LateInit()
      Z.EntityTabManager.Init()
    end
  end,
  UnInit = function()
    Z.LangMgr:UnInit()
    Z.DataMgr.UnInit()
    Z.VMMgr.UnInit()
    Z.ServiceMgr.UnInit()
    Z.LsqLiteMgr.UnInit()
  end,
  Update = function()
  end,
  OnPlayerInited = function(playerUuid)
    local settingVm = Z.VMMgr.GetVM("setting")
    settingVm.SetPlayerGlideAttr()
    settingVm.SetCameraRotateSpeed()
  end,
  OnPrepareSwitchScene = function(sceneId)
    Z.StageMgr.OnPrepareSwitchScene(sceneId)
    Z.VMMgr.GetVM("snapshot").ChangeSwitchCenceState(true)
  end,
  OnLeaveScene = function()
    Z.StageMgr.OnLeaveScene()
    Z.ServiceMgr.OnLeaveScene()
    Z.QteMgr.OnLeaveScene()
  end,
  OnLeaveStage = function()
    Z.StageMgr.OnLeaveStage()
    Z.LevelMgr:OnLeaveScene()
  end,
  OnEnterStage = function(stage, toSceneId, dungeonId)
    Z.ServiceMgr.OnEnterStage(stage, toSceneId, dungeonId)
    Z.StageMgr.OnEnterStage(stage, toSceneId, dungeonId)
  end,
  OnSceneResLoadFinish = function(sceneId)
    Z.StageMgr.OnSceneResLoadFinish(sceneId)
  end,
  OnEnterScene = function(sceneId)
    Z.StageMgr.OnEnterScene(sceneId)
    Z.LevelMgr:OnEnterScene(sceneId)
    Z.ServiceMgr.OnEnterScene(sceneId)
    Z.QteMgr.OnEnterScene()
    Z.VMMgr.GetVM("snapshot").ChangeSwitchCenceState(false)
    Z.QueueTipManager:OnEnterScene()
    if sceneId ~= 1 then
      Z.VMMgr.GetVM("season_quest_sub").InitQuestSeason()
      Z.VMMgr.GetVM("explore_monster").InitExploreMonster()
      Z.VMMgr.GetVM("planetmemory").InitRedpoint()
      local shopVM = Z.VMMgr.GetVM("shop")
      shopVM.SetMallItemRed()
    end
  end,
  OnEndSwitchScene = function(sceneId)
  end,
  OnDead = function()
    Z.VMMgr.GetVM("dead").OpenDeadView()
    Z.QueueTipManager:OnEnterScene()
  end,
  OnResurrection = function()
    local deadVm = Z.VMMgr.GetVM("dead")
    if not deadVm.CheckPlayerIsDead() then
      deadVm.CloseDeadView()
    end
  end,
  OnResurrectionEnd = function()
    Z.UIMgr:OpenView(Z.ConstValue.MainViewName)
  end,
  OnLogin = function()
    Z.RedPointMgr.InitRedDotNode()
    Z.ServiceMgr.OnLogin()
    Z.VMMgr.OnLogin()
    Z.DataMgr.Get("head_snapshot_data"):Init()
    Z.QueueTipManager:OnLogin()
  end,
  OnEnterGame = function()
  end,
  OnLogout = function()
    Z.ServiceMgr.OnLogout()
    Z.QueueTipManager:OnLogout()
  end,
  OnReconnect = function()
    Z.NetWaitHelper.SetSwitchingTag(false)
    Z.ServiceMgr.OnReconnect()
    Z.DataMgr.OnReconnect()
    Z.CameraMgr:SetDefaultCullingMask()
  end,
  OpenLoading = function(loadingType)
    Z.VMMgr.GetVM("loading").OpenUILoading(loadingType)
  end,
  CloseLoading = function()
    Z.VMMgr.GetVM("loading").CloseUILoading()
  end,
  SetLoadingProgress = function(progress)
    Z.VMMgr.GetVM("loading").SetLoadingProgress(progress)
  end
}
return game
