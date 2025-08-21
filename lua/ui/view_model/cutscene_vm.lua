local openCutsceneView = function(cutsceneId, isInFlow, skipType)
  local viewData = {}
  viewData.CutsceneId = cutsceneId
  viewData.IsInFlow = isInFlow
  viewData.SkipType = skipType
  if Z.StatusSwitchMgr:TrySwitchToState(Z.EStatusSwitch.StatusCutscene) then
    Z.UIMgr:OpenView("cutscene_main", viewData)
  end
end
local closeCutsceneView = function()
  Z.UIMgr:CloseView("cutscene_main")
end
local onPlayCutscene = function(cutsceneId, isInFlow, skipType)
  if skipType == -1 or skipType == nil then
    local cutRow = Z.TableMgr.GetTable("CutsceneTableMgr").GetRow(cutsceneId)
    skipType = cutRow.CanSkip
  end
  if skipType ~= E.CutsceneSkipType.NotAllow then
    local isSkip = false
    if skipType == E.CutsceneSkipType.Allow then
      isSkip = true
    elseif skipType == E.CutsceneSkipType.FirstNotAllow then
      isSkip = Z.LuaBridge.GetCutsceneIsPlayedOnce(cutsceneId)
    end
    if isSkip then
      local cutData = Z.DataMgr.Get("cutscene_data")
      cutData.CutsceneUIHost = cutsceneId
      openCutsceneView(cutsceneId, isInFlow, skipType)
    end
  end
  local questGoalGuideVm = Z.VMMgr.GetVM("quest_goal_guide")
  questGoalGuideVm.SetQuestGuideEffectVisible(false)
  Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnPlayCutscene, cutsceneId)
end
local onStopCutscene = function(cutsceneId)
  local cutData = Z.DataMgr.Get("cutscene_data")
  if cutData.CutsceneUIHost == cutsceneId then
    closeCutsceneView()
    cutData.CutsceneUIHost = 0
  end
  local questGoalGuideVm = Z.VMMgr.GetVM("quest_goal_guide")
  questGoalGuideVm.SetQuestGuideEffectVisible(true)
  local questData = Z.DataMgr.Get("quest_data")
  local args = questData.CutsceneBlackMaskArgsDict[cutsceneId]
  if args then
    args.TimeOut = 10
    Z.UIMgr:FadeIn(args)
    questData.CutsceneBlackMaskArgsDict[cutsceneId] = nil
  end
end
local onFinishCutscene = function(cutsceneId)
  logGreen("[quest] Cutscene finish: " .. cutsceneId)
  local goalVM = Z.VMMgr.GetVM("goal")
  goalVM.SetGoalFinish(E.GoalType.AutoPlayCutscene, cutsceneId)
  Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnFinishCutscene, cutsceneId)
end
local ret = {
  OpenCutsceneView = openCutsceneView,
  CloseCutsceneView = closeCutsceneView,
  OnPlayCutscene = onPlayCutscene,
  OnStopCutscene = onStopCutscene,
  OnFinishCutscene = onFinishCutscene
}
return ret
