local initFishData = function()
  local fishingData = Z.DataMgr.Get("fishing_data")
  if not fishingData.HaveInitData then
    fishingData:UpdateFishingData(false)
    fishingData:AddFishingSettingWatcher()
    local fishingSettingData = Z.DataMgr.Get("fishing_setting_data")
    fishingSettingData:InitShowCfg()
  end
  fishingData.HaveInitData = true
end
local resetEntityAndUIVisible = function(isFishing)
  local fishingSettingData = Z.DataMgr.Get("fishing_setting_data")
  local entityandhudRecordData = Z.DataMgr.Get("entityandhud_record_data")
  for _, v in ipairs(fishingSettingData.ShowEntityAllCfg) do
    local show
    if isFishing == true then
      show = v.state
    else
      show = entityandhudRecordData:GetShowEntityRecord(v.type)
    end
    Z.DIServiceMgr.FishingService:SetEntityShow(v.type, show)
  end
  for _, v in ipairs(fishingSettingData.ShowUIAllCfg) do
    local show
    if isFishing then
      show = v.state
    else
      show = entityandhudRecordData:GetShowUIRecord(v.type)
    end
    Z.LuaBridge.SetHudSwitch(show)
  end
end
local quitFishingUI = function()
  local fishingData = Z.DataMgr.Get("fishing_data")
  Z.UIMgr:CloseView("fishing_main_window")
  fishingData:SetStage(E.FishingStage.Quit)
end
local quitFishingState = function(cancelToken)
  Z.CoroUtil.create_coro_xpcall(function()
    local worldProxy = require("zproxy.world_proxy")
    local ret = worldProxy.FishingExit(cancelToken)
    if ret == 0 then
      Z.DIServiceMgr.FishingService:ExitFishing()
      quitFishingUI()
      local fishingSettingData = Z.DataMgr.Get("fishing_setting_data")
      fishingSettingData:WriteSettingData()
    else
      Z.TipsVM.ShowTips(ret)
    end
  end)()
end
local fishingRodTensionChange = function(rodTension)
  Z.DIServiceMgr.FishingService:FishingRodTensionChange(rodTension)
end
local fishingProgressChange = function(progress)
  Z.DIServiceMgr.FishingService:FishingProgressChange(progress)
end
local fishingEnd = function(success, complete)
  local fishingData = Z.DataMgr.Get("fishing_data")
  if fishingData.IsRequestFishingEnd == false then
    fishingData.IsRequestFishingEnd = true
    Z.CoroUtil.create_coro_xpcall(function()
      local worldProxy = require("zproxy.world_proxy")
      local request = {}
      request.isSuccess = success
      local ret = worldProxy.FishingResultReport(request, fishingData.CancelSource:CreateToken())
      if ret.errorCode == 0 then
        if ret.durabilityExhausted or ret.isBurst then
          fishingData.FishingRod = nil
          Z.TipsVM.ShowTips(1381010)
        end
        fishingData.TargetFish.Size = ret.size
        if complete then
          complete()
        end
      else
        Z.TipsVM.ShowTips(Lang(Z.PbErrName(ret.errorCode)))
      end
      fishingData.IsRequestFishingEnd = false
    end)()
  end
end
local dragFishingRod = function()
  Z.DIServiceMgr.FishingService:DragFishingRod()
end
local fishingRodBreak = function()
  fishingEnd(false, function()
    Z.DIServiceMgr.FishingService:FishingRodBreak()
    local fishingData = Z.DataMgr.Get("fishing_data")
    fishingData:SetStage(E.FishingStage.EndRodBreak)
  end)
end
local fishingSuccess = function()
  fishingEnd(true, function()
    local fishingData = Z.DataMgr.Get("fishing_data")
    Z.DIServiceMgr.FishingService:FishingSuccess(fishingData.TargetFish.Size)
    fishingData:SetStage(E.FishingStage.EndSuccess)
  end)
end
local fishRunAway = function()
  fishingEnd(false, function()
    Z.DIServiceMgr.FishingService:FishingRunAway()
    local fishingData = Z.DataMgr.Get("fishing_data")
    fishingData:SetStage(E.FishingStage.EndRunAway)
  end)
end
local harvestingFishingRod = function()
  Z.DIServiceMgr.FishingService:HarvestingFishingRod()
  local fishingData = Z.DataMgr.Get("fishing_data")
  if fishingData.QTEData.FishBiteHook then
    local cfg_ = fishingData.FishRecordDict[fishingData.TargetFish.FishInfo.FishId].FishCfg
    local attrCfg_ = Z.TableMgr.GetTable("FishingAttrTableMgr").GetRow(cfg_.FishingAttrId)
    if attrCfg_ and attrCfg_.Qte == 1 then
      fishingData:SetStage(E.FishingStage.QTE)
    else
      fishingSuccess()
    end
  else
    local fishingData = Z.DataMgr.Get("fishing_data")
    if fishingData.FishingStage == E.FishingStage.BuoyDive then
      fishingData:SetStage(E.FishingStage.EndBuoyDive)
    end
    Z.DIServiceMgr.FishingService:FishingCancel()
    fishingData:SetStage(E.FishingStage.EnterFishing)
  end
end
local setFishingRodAsync = function(rodId, cancelToken)
  Z.CoroUtil.create_coro_xpcall(function()
    local fishingData = Z.DataMgr.Get("fishing_data")
    local worldProxy = require("zproxy.world_proxy")
    local request = {}
    request.rodUuid = rodId
    local ret = worldProxy.FishingSetRod(request, cancelToken)
    if ret == 0 then
      fishingData.FishingRod = rodId
      Z.EventMgr:Dispatch(Z.ConstValue.Fishing.FishingRodChange)
    else
      Z.TipsVM.ShowTips(ret)
    end
  end)()
end
local setFishingBaitAsync = function(baitId, cancelToken)
  Z.CoroUtil.create_coro_xpcall(function()
    local fishingData = Z.DataMgr.Get("fishing_data")
    local worldProxy = require("zproxy.world_proxy")
    local request = {}
    request.baitId = baitId
    local ret = worldProxy.FishingSetBait(request, cancelToken)
    if ret == 0 then
      fishingData.FishBait = baitId
      Z.EventMgr:Dispatch(Z.ConstValue.Fishing.FishingBaitChange)
    else
      Z.TipsVM.ShowTips(ret)
    end
  end)()
end
local setFishBiteHook = function(bitehook)
  local fishingData = Z.DataMgr.Get("fishing_data")
  if bitehook then
    fishingData:SetFishBiteHook(bitehook)
    fishingData:SetStage(E.FishingStage.FishBiteHook)
  else
    fishingData:SetStage(E.FishingStage.EndRunAway)
  end
end
local enterFishingState = function()
  local fishingData = Z.DataMgr.Get("fishing_data")
  local FishingMgr = require("utility/fishing_manager")
  FishingMgr:OpenMgr()
  initFishData()
  local args = {
    EndCallback = function()
      Z.UIMgr:GotoMainView()
      Z.UIMgr:OpenView("fishing_main_window")
    end
  }
  Z.UIMgr:FadeIn(args)
  fishingData.IgnoreInputBack = false
  fishingData:SetStage(E.FishingStage.EnterFishing)
end
local setPlayerSwingDir = function(dir)
  local fishingData = Z.DataMgr.Get("fishing_data")
  fishingData:SetPlayerSwingDir(dir)
end
local setHookInWater = function()
  local fishingData = Z.DataMgr.Get("fishing_data")
  fishingData:SetStage(E.FishingStage.ThrowFishingRodInWater)
end
local setFishSwingDir = function(dir)
  local fishingData = Z.DataMgr.Get("fishing_data")
  fishingData:SetFishSwingDir(dir)
end
local fishingProcessUpdate = function()
  local fishingData = Z.DataMgr.Get("fishing_data")
  local change = fishingData:FishingUpdate()
  if change then
    fishingRodTensionChange(fishingData.QTEData.FishRodTensionInt)
    fishingProgressChange(fishingData.QTEData.FishingProgressInt)
  end
end
local fishingSuccessShowEnd = function()
  Z.DIServiceMgr.FishingService:FishingSuccessShowEnd()
end
local throwFishingRod = function()
  Z.CoroUtil.create_coro_xpcall(function()
    local fishingData = Z.DataMgr.Get("fishing_data")
    if fishingData.FishBait == nil or fishingData.FishBait == 0 then
      Z.TipsVM.ShowTips(1381012)
      return
    end
    if fishingData.FishingRod == nil or fishingData.FishingRod == 0 then
      Z.TipsVM.ShowTips(1381011)
      return
    end
    local worldProxy = require("zproxy.world_proxy")
    local ret = worldProxy.FishingRod(fishingData.CancelSource:CreateToken())
    if ret.errCode == 0 then
      fishingData:SetTargetFish(ret.fishId)
      Z.DIServiceMgr.FishingService:CastingFishingRod(ret.fishId, ret.waitMills, fishingData.TargetFish.FishSpeed, fishingData.TargetFish.FishPathInterval, fishingData.TargetFish.BiteTime, fishingData.TargetFish.FishStayInterval)
      fishingData:SetStage(E.FishingStage.ThrowFishingRod)
    else
      Z.TipsVM.ShowTips(Lang(Z.PbErrName(ret.errCode)))
    end
  end)()
end
local getFishingRankData = function(forceRefresh, cancelToken)
  local fishingData = Z.DataMgr.Get("fishing_data")
  if forceRefresh or fishingData.RankDict == nil or table.zcount(fishingData.RankDict) == 0 then
    local worldProxy = require("zproxy.world_proxy")
    local ret = worldProxy.GetRankInfo({}, cancelToken)
    if ret.errCode == 0 then
      fishingData:SetRankDict(ret.records)
      return fishingData.RankDict
    else
      Z.TipsVM.ShowTips(Lang(Z.PbErrName(ret.errCode)))
    end
  else
    return fishingData.RankDict
  end
end
local openMainFuncWindow = function(funcId)
  funcId = funcId and tonumber(funcId)
  initFishData()
  Z.UIMgr:OpenView("fishing_func_main_window", {startFunc_ = funcId})
end
local closeMainFuncWindow = function()
  Z.UIMgr:CloseView("fishing_func_main_window")
end
local useFishingResearch = function(fishId, cancelToken)
  local fishingData = Z.DataMgr.Get("fishing_data")
  local worldProxy = require("zproxy.world_proxy")
  local request = {}
  request.fishId = fishId
  local ret = worldProxy.FishingSetResearchFish(request, cancelToken)
  if ret == 0 then
    fishingData.QTEData.UseResearchFish = fishId
    Z.EventMgr:Dispatch(Z.ConstValue.Fishing.FishingResearchUseChange)
  else
    Z.TipsVM.ShowTips(Lang(Z.PbErrName(ret)))
  end
end
local researchFish = function(fishId, count, cancelToken)
  local fishingData = Z.DataMgr.Get("fishing_data")
  local worldProxy = require("zproxy.world_proxy")
  local request = {}
  request.fishId = fishId
  request.count = count
  local lastResearchLevel_ = fishingData.FishRecordDict[fishId].ResearchLevel
  local ret = worldProxy.FishingResearch(request, cancelToken)
  if ret == 0 then
    Z.TipsVM.ShowTips(1381013)
    local curResearchLevel_ = fishingData.FishRecordDict[fishId].ResearchLevel
    if lastResearchLevel_ < curResearchLevel_ then
      local name_ = fishingData.FishRecordDict[fishId].FishCfg.Name
      Z.TipsVM.ShowTips(1381014, {val = name_})
      Z.EventMgr:Dispatch(Z.ConstValue.Fishing.FishingStudyLevelChange)
    end
    return true
  else
    Z.TipsVM.ShowTips(Lang(Z.PbErrName(ret)))
    return false
  end
end
local updateFishFirstUnLockFlag = function(fishId, cancelToken)
  local fishingData = Z.DataMgr.Get("fishing_data")
  local worldProxy = require("zproxy.world_proxy")
  local request = {}
  request.fishId = fishId
  local ret = worldProxy.FishingFirstShowRecord(request, cancelToken)
  if ret == 0 then
    Z.AudioMgr:Play("UI_Event_Activate")
  else
    Z.TipsVM.ShowTips(Lang(Z.PbErrName(ret)))
  end
end
local openResearchPopWindow = function(selectFish, researchView)
  Z.UIMgr:OpenView("fishing_study_popup", {selectFish = selectFish, researchView = researchView})
end
local closeResearchPopWindow = function()
  Z.UIMgr:CloseView("fishing_study_popup")
end
local openFishingLevelUpTip = function()
  Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FunctionOpen, "fishing_acquire_window")
end
local buoyDive = function()
  local fishingData = Z.DataMgr.Get("fishing_data")
  fishingData:SetStage(E.FishingStage.BuoyDive)
end
local getLevelReward = function(level, cancelToken)
  local lv
  if level then
    lv = level
  else
    lv = 0
  end
  local worldProxy = require("zproxy.world_proxy")
  local request = {}
  request.level = lv
  local ret = worldProxy.FishingGetLevelReward(request, cancelToken)
  if ret == 0 then
    return true
  else
    Z.TipsVM.ShowTips(Lang(Z.PbErrName(ret)))
    return false
  end
end
local setShowEntitySetting = function(type, state)
  local fishingSettingData = Z.DataMgr.Get("fishing_setting_data")
  fishingSettingData:SetShowEntityCfg(type, state)
end
local setShowUISetting = function(type, state)
  local fishingSettingData = Z.DataMgr.Get("fishing_setting_data")
  fishingSettingData:SetShowUICfg(type, state)
end
local openFishingLevelPopup = function()
  Z.UIMgr:OpenView("fishing_reward_popup")
end
local closeFishingLevelPopup = function()
  Z.UIMgr:CloseView("fishing_reward_popup")
end
local shareIllustrateToChat = function(fishId, size)
  local data = {}
  data.FishId = fishId
  data.Size = size
  local chatData_ = Z.DataMgr.Get("chat_main_data")
  chatData_:RefreshShareData("", data, E.ChatHyperLinkType.FishingIllrate)
  local draftData = {}
  draftData.msg = chatData_:GetHyperLinkShareContent()
  chatData_:SetChatDraft(draftData, E.ChatChannelType.EComprehensive, E.ChatWindow.Main)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  gotoFuncVM.GoToFunc(E.FunctionID.MainChat)
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
end
local shareArchievesToChat = function()
  local data = {}
  local chatData_ = Z.DataMgr.Get("chat_main_data")
  chatData_:RefreshShareData("", data, E.ChatHyperLinkType.FishingArchives)
  local draftData = {}
  draftData.msg = chatData_:GetHyperLinkShareContent()
  chatData_:SetChatDraft(draftData, E.ChatChannelType.EComprehensive, E.ChatWindow.Main)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  gotoFuncVM.GoToFunc(E.FunctionID.MainChat)
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
end
local shareRankToChat = function(fishId, rank, size)
  local data = {}
  data.FishId = fishId
  data.Rank = rank
  data.Size = size
  local chatData_ = Z.DataMgr.Get("chat_main_data")
  chatData_:RefreshShareData("", data, E.ChatHyperLinkType.FishingRank)
  local draftData = {}
  draftData.msg = chatData_:GetHyperLinkShareContent()
  chatData_:SetChatDraft(draftData, E.ChatChannelType.EComprehensive, E.ChatWindow.Main)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  gotoFuncVM.GoToFunc(E.FunctionID.MainChat)
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
end
local ret = {
  EnterFishingState = enterFishingState,
  BuoyDive = buoyDive,
  SetFishBiteHook = setFishBiteHook,
  SetFishSwingDir = setFishSwingDir,
  SetPlayerSwingDir = setPlayerSwingDir,
  SetHookInWater = setHookInWater,
  QuitFishingState = quitFishingState,
  QuitFishingUI = quitFishingUI,
  ThrowFishingRod = throwFishingRod,
  HarvestingFishingRod = harvestingFishingRod,
  DragFishingRod = dragFishingRod,
  FishingRodBreak = fishingRodBreak,
  FishingSuccess = fishingSuccess,
  FishRunAway = fishRunAway,
  FishingProcessUpdate = fishingProcessUpdate,
  SetFishingRodAsync = setFishingRodAsync,
  SetFishingBaitAsync = setFishingBaitAsync,
  FishingSuccessShowEnd = fishingSuccessShowEnd,
  GetFishingRankData = getFishingRankData,
  OpenMainFuncWindow = openMainFuncWindow,
  CloseMainFuncWindow = closeMainFuncWindow,
  UseFishingResearch = useFishingResearch,
  ResearchFish = researchFish,
  OpenResearchPopWindow = openResearchPopWindow,
  CloseResearchPopWindow = closeResearchPopWindow,
  InitFishData = initFishData,
  OpenFishingLevelUpTip = openFishingLevelUpTip,
  UpdateFishFirstUnLockFlag = updateFishFirstUnLockFlag,
  GetLevelReward = getLevelReward,
  SetShowEntitySetting = setShowEntitySetting,
  SetShowUISetting = setShowUISetting,
  OpenFishingLevelPopup = openFishingLevelPopup,
  CloseFishingLevelPopup = closeFishingLevelPopup,
  ShareRankToChat = shareRankToChat,
  ShareArchievesToChat = shareArchievesToChat,
  ShareIllustrateToChat = shareIllustrateToChat,
  ResetEntityAndUIVisible = resetEntityAndUIVisible
}
return ret
