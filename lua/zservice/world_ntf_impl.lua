local pb = require("pb2")
local WorldNtfStubImpl = {}

function WorldNtfStubImpl:OnCreateStub()
end

function WorldNtfStubImpl:SyncEntityAttrs(call, attrs)
end

function WorldNtfStubImpl:SyncPioneerInfo(call, targetId, targetNum)
  Z.VMMgr.GetVM("ui_enterdungeonscene").NotifyPoinnersChange(targetId, targetNum)
end

function WorldNtfStubImpl:SyncSwitchChange(call, Id, onOff)
end

function WorldNtfStubImpl:SyncSwitchInfo(call, switchInfo)
end

function WorldNtfStubImpl:AwardNotify(call, award)
  Z.EventMgr:Dispatch(Z.ConstValue.AwardNotify, award)
end

function WorldNtfStubImpl:SyncContainerData(call, vData)
  logGreen("[ContainerData]: sync Container Data successed ")
  Z.ContainerMgr.CharSerialize:ResetData(vData)
  Z.LuaBridge.ContainerDataChanged()
  Z.ItemEventMgr.WatcherItemsChange()
  Z.ServiceMgr.OnSyncAllContainerData()
  local rolelevelVm = Z.VMMgr.GetVM("rolelevel_main")
  rolelevelVm.AddRoleRegWatcher()
  rolelevelVm.InitRoleData()
  local switchVM = Z.VMMgr.GetVM("switch")
  switchVM.WatcherSwitchChange()
  local equipVm = Z.VMMgr.GetVM("equip_system")
  equipVm.EquipDurabilityWatcher()
  local mapClockVM = Z.VMMgr.GetVM("map_clock")
  mapClockVM.OnSyncAllContainerData()
  Z.GuideMgr:InitGuideData()
  Z.EventMgr:Dispatch(Z.ConstValue.SyncAllContainerData)
end

function WorldNtfStubImpl:QteBegin(call, qteId)
  Z.EventMgr:Dispatch("CreateQteUIUnit", qteId)
end

function WorldNtfStubImpl:QuestAbort(call, questId)
  logGreen("quest abort: questId = {0}", questId)
  local questVM = Z.VMMgr.GetVM("quest")
  questVM.HandelQuestComplete(questId, false)
end

function WorldNtfStubImpl:SyncDungeonData(call, vData)
  logGreen("[ContainerData]: sync Dungeon Data successed ")
  Z.ContainerMgr.DungeonSyncData:ResetData(vData)
  Z.LuaBridge.ContainerDataChanged()
  local dungeonVm = Z.VMMgr.GetVM("dungeon")
  dungeonVm.OnSyncAllContainerData()
end

function WorldNtfStubImpl:SyncSeason(call, vSeason)
  local seasonVm = Z.VMMgr.GetVM("season")
  seasonVm.RefreshSeasonData(vSeason)
  Z.EventMgr:Dispatch(Z.ConstValue.SyncSeason)
end

function WorldNtfStubImpl:CardInfoAck(call, charId, info)
end

function WorldNtfStubImpl:EnterGame(call)
end

function WorldNtfStubImpl:UserAction(call, vCharId, vActionId)
  Z.EventMgr:Dispatch(Z.ConstValue.HeroDungeonPraiseUIModelAction, vCharId, vActionId)
end

function WorldNtfStubImpl:NotifyDisplayPlayHelp(call, vPlayHelpId)
  local helpsysVM = Z.VMMgr.GetVM("helpsys")
  helpsysVM.CheckAndShowView(vPlayHelpId)
end

function WorldNtfStubImpl:NotifyApplicationInteraction(call, vOrigId, vActionId)
  local multActionVm = Z.VMMgr.GetVM("multaction")
  multActionVm.NotifyInvite(vOrigId, vActionId)
end

function WorldNtfStubImpl:NotifyIsAgree(call, vInviteeId, vActionId, vIsAgree)
  local multActionVm = Z.VMMgr.GetVM("multaction")
  multActionVm.NotifyIsAgree(vInviteeId, vActionId, vIsAgree)
end

function WorldNtfStubImpl:NotifyCancelAction(call, vCancelCharId)
  local multActionVm = Z.VMMgr.GetVM("multaction")
  multActionVm.NotifyCancelAction(vCancelCharId)
end

function WorldNtfStubImpl:NotifyUploadPictureResult(call, success, photoType, photoId, photoName)
  local albumVm = Z.VMMgr.GetVM("album_main")
  if success then
    albumVm.AlbumUpLoadSliderValue()
  else
    local errorData = {}
    errorData.photoType = photoType
    errorData.photoId = photoId
    errorData.photoName = photoName
    albumVm.AlbumUpLoadErrorCollection(E.CameraUpLoadErrorType.CommonError, errorData)
  end
end

function WorldNtfStubImpl:SyncInvite(call, vRequest)
  local unionInviteFunc = function(callData, flag, cancelSource)
    local unionVM = Z.VMMgr.GetVM("union")
    if flag then
      unionVM:AsyncReqJoinUnions({
        callData.unionId
      }, false, cancelSource:CreateToken())
    end
  end
  local info = {
    charId = vRequest.InviteId,
    tipsType = E.InvitationTipsType.TeamInvite,
    content = string.format("%s\227\128\144%s\227\128\145", Lang("RequestToJoinUnion"), vRequest.unionName),
    cd = Z.Global.TeamInviteLastTime,
    func = unionInviteFunc,
    funcParam = {
      unionId = vRequest.unionId
    }
  }
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, info)
end

function WorldNtfStubImpl:ChangeNameResultNtf(call, errCode)
  Z.EventMgr:Dispatch(Z.ConstValue.Player.ChangeNameResultNtf, errCode)
end

function WorldNtfStubImpl:NotifyReviveUser(call, uuid)
  if uuid ~= Z.EntityMgr.PlayerUuid then
    Z.EventMgr:Dispatch(Z.ConstValue.Revive)
  end
end

function WorldNtfStubImpl:NotifyParkourRankInfo(call, vRankId)
  local parkourTipsVm = Z.VMMgr.GetVM("parkourtips")
  parkourTipsVm.RankInfoChanged(vRankId)
end

function WorldNtfStubImpl:NotifyParkourRecordInfo(call, result, vRecord)
  local parkourTipsVm = Z.VMMgr.GetVM("parkourtips")
  parkourTipsVm.RecordInfoChanged(result, vRecord)
end

function WorldNtfStubImpl:NotifyShowTips(call, vTips)
  if vTips.tipsType == E.ETipsType.ETipsTypeNormal then
    Z.TipsVM.ShowTips(vTips.errCode)
  elseif vTips.tipsType == E.ETipsType.ETipsTypeUseItemLimit then
    Z.TipsVM.ShowTips(vTips.errCode)
  elseif vTips.tipsType == E.ETipsType.ETipsTypeCraftEnergy then
    local protoData = pb.decode("zproto.CraftEnergyTipsInfo", vTips.tipsParams)
    Z.TipsVM.ShowTips(vTips.errCode, {
      consumeValue = protoData.consumeValue,
      residue = protoData.residue
    })
  elseif vTips.tipsType == E.ETipsType.ETipsTypeGetLifePoint then
    local craftEnergyTableRow = Z.TableMgr.GetRow("CraftEnergyTableMgr", Z.SystemItem.VigourItemId)
    local total = 0
    local cnt = 0
    for k, v in pairs(craftEnergyTableRow.CostAward) do
      if v[2] == Z.SystemItem.LifeProfessionPointItem then
        total = v[1]
        cnt = v[3]
      end
    end
    local protoData = pb.decode("zproto.LifProfessionPointTipsInfo", vTips.tipsParams)
    local consumeCount = 0
    if cnt ~= 0 then
      consumeCount = total * protoData.pointCount / cnt
    end
    local professionName = ""
    if protoData.lifeProfessionId and protoData.lifeProfessionId ~= 0 then
      local lifeProfessionRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(protoData.lifeProfessionId)
      if lifeProfessionRow then
        professionName = lifeProfessionRow.Name
      end
    end
    Z.TipsVM.ShowTips(protoData.getLifePointType, {
      consumeCount = math.floor(consumeCount),
      pointCount = protoData.pointCount,
      professionName = professionName
    })
  end
end

function WorldNtfStubImpl:NotifyNoticeInfo(call, vInfo)
  local broadcastVM = Z.VMMgr.GetVM("tips_broadcast")
  broadcastVM.AddBroadcast(vInfo)
end

function WorldNtfStubImpl:NotifyTextCheckResult(call, errCode)
  local screenWordVM = Z.VMMgr.GetVM("screenword")
  screenWordVM.CheckScreenWordResult(errCode)
end

function WorldNtfStubImpl:NotifyClientKickOff(call, errCode)
  Z.ConnectMgr:SetReconnectEnabled(E.RpcChannelType.Gateway, false)
  if errCode == Z.PbEnum("EErrorCode", "ErrExitGame") then
    return
  end
  local loginVM = Z.VMMgr.GetVM("login")
  loginVM:KickOffByServer(errCode)
end

function WorldNtfStubImpl:NotifyBuyShopResult(call, data)
  local shopVm = Z.VMMgr.GetVM("shop")
  shopVm.NotifyBuyShopResult(data)
end

function WorldNtfStubImpl:NotifyShopItemCanBuy(call, data)
  for type, showRed in pairs(data.isShowRed) do
    if showRed then
      if type == E.EShopType.Shop then
        Z.RedPointMgr.UpdateNodeCount(E.RedType.Shop, 1)
      elseif type == E.EShopType.SeasonShop then
        Z.RedPointMgr.UpdateNodeCount(E.RedType.SeasonShop, 1)
      end
    end
  end
  local shopVM = Z.VMMgr.GetVM("shop")
  shopVM.SetMallItemRed()
end

function WorldNtfStubImpl:PaymentResponse(call, vRequest)
  local shopVm = Z.VMMgr.GetVM("shop")
  shopVm.BuyCallFunc(vRequest)
  Z.EventMgr:Dispatch(Z.ConstValue.Shop.PaymentResponse)
end

function WorldNtfStubImpl:ExchangeCurrencyResponse(call, errCode)
  if errCode == 0 then
    Z.TipsVM.ShowTipsLang(1000731)
  else
    Z.TipsVM.ShowTips(errCode)
  end
end

function WorldNtfStubImpl:NotifyUnlockCookBook(call, data)
end

function WorldNtfStubImpl:NotifyCustomEvent(call, eventParams)
  logGreen("[NotifyCustomEvent]eventParams={0}", tostring(eventParams))
  Z.EventMgr:Dispatch("level_event", E.LevelEventType.TriggerEvent, eventParams.customEventId)
end

function WorldNtfStubImpl:NotifyStartPlayingDungeon(call, data)
  if Z.ContainerMgr.CharSerialize.charId == data.charId then
    return
  end
  local vm = Z.VMMgr.GetVM("hero_dungeon_main")
  vm.OpenDungeonOpenView(data)
  local teamData = Z.DataMgr.Get("team_data")
  local mems = teamData.TeamInfo.members
  local memInfo = mems[data.charId]
  if not memInfo then
    return
  end
  local param = {
    player = {
      name = memInfo.socialData and memInfo.socialData.basicData.name or ""
    }
  }
  Z.TipsVM.ShowTipsLang(15001101, param)
end

function WorldNtfStubImpl:ChangeShowIdResultNtf(call, vCode)
  Z.EventMgr:Dispatch(Z.ConstValue.Player.ChangeShowIdResultNtf, vCode)
end

function WorldNtfStubImpl:NotifyShowItems(call, vInfo)
  local itemShowVm = Z.VMMgr.GetVM("item_show")
  local itemSortFactoryVm = Z.VMMgr.GetVM("item_sort_factory")
  local itemsData = itemShowVm.MergeRepeatedItems(vInfo.items)
  if vInfo.type & E.ShowItemType.ItemTips > 0 then
    itemSortFactoryVm.DefaultSendAwardSortByConfigId(itemsData)
    for i, v in ipairs(itemsData) do
      if v.count >= 1 then
        Z.ItemEventMgr.AddItemGetTipsData(v)
      end
    end
  end
  if 0 < vInfo.type & E.ShowItemType.RewardTips then
    itemShowVm.OpenItemShowView(itemsData)
  end
  if 0 < vInfo.type & E.ShowItemType.MonthCardTips then
    local monthlyCardVM = Z.VMMgr.GetVM("monthly_reward_card")
    monthlyCardVM:CheckEveryDayRewardPopupCanShow()
  end
end

function WorldNtfStubImpl:NotifySeasonActivationTargetInfo(call, vSeasonId, isRefresh)
  Z.EventMgr:Dispatch(Z.ConstValue.SeasonActivation.RefreshData, vSeasonId, isRefresh)
end

function WorldNtfStubImpl:WorldBossRankInfoNtf(call, vInfo)
  local worldBossData = Z.DataMgr.Get("world_boss_data")
  worldBossData:SetWorldBossRankInfo(vInfo.rankInfos)
  Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.ContributionInfoChange)
end

function WorldNtfStubImpl:NotifyDebugMessageTip(call, vInfo)
  Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameNormal, E.ESysDialogGameNormalOrder.Normal, nil, vInfo.message)
end

function WorldNtfStubImpl:NotifyDriverApplyRide(call, param)
  local chatSettingVm = Z.VMMgr.GetVM("chat_setting")
  if not chatSettingVm.CheckApplyType(E.ESocialApplyType.ECarpoolApply, param.applyId) then
    return
  end
  local vehicleApplyFunc = function(callData, flag, cancelSource)
    local vehicleVM = Z.VMMgr.GetVM("vehicle")
    if flag then
      vehicleVM.AsyncApplyToRideResult(callData.applyId, E.VehicleApplyRideResult.ApplyRideResultAgree, cancelSource:CreateToken())
    else
      vehicleVM.AsyncApplyToRideResult(callData.applyId, E.VehicleApplyRideResult.ApplyRideResultRefuse, cancelSource:CreateToken())
    end
  end
  local info = {
    charId = param.applyId,
    tipsType = E.InvitationTipsType.VehicleApply,
    content = string.format("%s", Lang("DriverApplyRide"), param.applyName),
    cd = Z.Global.VehicleTogetherApplyDuration,
    func = vehicleApplyFunc,
    funcParam = {
      applyId = param.applyId
    }
  }
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, info)
end

function WorldNtfStubImpl:NotifyInviteApplyRide(call, param)
  local chatSettingVm = Z.VMMgr.GetVM("chat_setting")
  if not chatSettingVm.CheckApplyType(E.ESocialApplyType.ECarpoolApply, param.driverId) then
    return
  end
  local vehicleApplyFunc = function(callData, flag, cancelSource)
    local vehicleVM = Z.VMMgr.GetVM("vehicle")
    if flag then
      vehicleVM.AsyncApplyToRideResult(callData.driverId, E.VehicleApplyRideResult.ApplyRideResultAgree, cancelSource:CreateToken())
    else
      vehicleVM.AsyncApplyToRideResult(callData.driverId, E.VehicleApplyRideResult.ApplyRideResultRefuse, cancelSource:CreateToken())
    end
  end
  local info = {
    charId = param.driverId,
    tipsType = E.InvitationTipsType.VehicleInvite,
    content = string.format("%s", Lang("InviteApplyRide"), param.driverName),
    cd = Z.Global.VehicleTogetherApplyDuration,
    func = vehicleApplyFunc,
    funcParam = {
      driverId = param.driverId
    }
  }
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, info)
end

function WorldNtfStubImpl:NotifyRideIsAgree(call, param)
  if param.result == E.VehicleApplyRideResult.ApplyRideResultAgree then
    Z.TipsVM.ShowTipsLang(1000901, {
      val = param.charName
    })
    local vehicleDefine = require("ui.model.vehicle_define")
    if Z.EntityMgr.PlayerEnt and Z.EntityMgr.PlayerEnt:GetLuaRideStage() ~= vehicleDefine.ERideStage.ERideNone then
      return
    end
    local charId = param.charId
    Z.CoroUtil.create_coro_xpcall(function()
      local vehicleVM = Z.VMMgr.GetVM("vehicle")
      local cancelSource = Z.CancelSource.Rent()
      vehicleVM.AsyncRideReconfirm(charId, cancelSource:CreateToken())
    end)()
  else
    Z.TipsVM.ShowTipsLang(1000902, {
      val = param.charName
    })
  end
end

function WorldNtfStubImpl:NotifyLifeProfessionWorkHistoryChange(call, info)
  local lifeProfessionWorkData_ = Z.DataMgr.Get("life_profession_work_data")
  lifeProfessionWorkData_:AddNewRecord(info.workInfos)
end

function WorldNtfStubImpl:NotifyUserCloseFunction(call, vParam)
  local switchVM = Z.VMMgr.GetVM("switch")
  switchVM.UserCloseFunction(vParam)
end

function WorldNtfStubImpl:NotifyServerCloseFunction(call, vParam)
  local switchVM = Z.VMMgr.GetVM("switch")
  switchVM.ServerCloseFunction(vParam)
end

function WorldNtfStubImpl:NotifyAwardAllItems(call, vAllItem)
end

function WorldNtfStubImpl:NotifyAllMemberReady(call, vOpenOrClose)
  local dungeonPrepareVm = Z.VMMgr.GetVM("dungeon_prepare")
  local teamData = Z.DataMgr.Get("team_data")
  teamData.DungeonPrepareCheckInfo = {}
  if vOpenOrClose then
    teamData.IsDungeonPrepareIng = true
    teamData.DungeonPrepareBeginTime = Z.ServerTime:GetServerTime()
    dungeonPrepareVm.OpenView()
  else
    teamData.DungeonPrepareBeginTime = 0
    teamData.IsDungeonPrepareIng = false
    dungeonPrepareVm.CloseView()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshPrepareState, vOpenOrClose)
end

function WorldNtfStubImpl:NotifyCaptainReady(call, vMemberName, vCharId, vReadyInfo)
  local teamData = Z.DataMgr.Get("team_data")
  teamData.DungeonPrepareCheckInfo[vCharId] = {
    name = vMemberName,
    readyInfo = vReadyInfo,
    isReady = vReadyInfo.isReady
  }
  Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshPrepareMemberInfo)
end

function WorldNtfStubImpl:NotifyUserAllSourcePrivilegeEffectData(call, allPrivilegeEffects)
  local privilegesData = Z.DataMgr.Get("privileges_data")
  privilegesData:InitPrivilegesData(allPrivilegeEffects)
end

function WorldNtfStubImpl:NotifyQuestAccept(call, vParam)
  if vParam == nil or vParam.questIds == nil or #vParam.questIds < 1 then
    logError("[NotifyQuestAccept] error, questIds is nil or empty")
    return
  end
  local questIds = vParam.questIds
  logGreen("[Quest] NotifyQuestAccept, questIds = " .. table.zconcat(questIds, ","))
  local questVM = Z.VMMgr.GetVM("quest")
  questVM.HandelQuestAccept(questIds)
end

function WorldNtfStubImpl:NotifyQuestChangeStep(call, vParam)
  if vParam == nil then
    logError("[NotifyQuestChangeStep] error")
    return
  end
  local questId = vParam.questId
  local lastStepId = vParam.lastStep
  local lastQuestStatus = vParam.lastQuestStatus
  local curStepId = vParam.currSetp
  logGreen("[Quest] NotifyQuestChangeStep, questId = " .. questId .. ", lastStepId = " .. lastStepId .. ", lastQuestStatus = " .. lastQuestStatus .. ", curStepId = " .. curStepId)
  local questVM = Z.VMMgr.GetVM("quest")
  questVM.HandelQuestStepChange(questId, lastStepId, lastQuestStatus, curStepId)
end

function WorldNtfStubImpl:NotifyQuestGiveUp(call, vParam)
  if vParam == nil or vParam.questId == nil or vParam.questId <= 0 then
    logError("[NotifyQuestComplete] error, questId is nil or 0")
    return
  end
  local questVM = Z.VMMgr.GetVM("quest")
  logGreen("[Quest] NotifyQuestGiveUp, questId = " .. vParam.questId)
  questVM.HandelQuestComplete(vParam.questId, false)
end

function WorldNtfStubImpl:NotifyQuestComplete(call, vParam)
  if vParam == nil or vParam.questId == nil or vParam.questId <= 0 then
    logError("[NotifyQuestComplete] error, questId is nil or 0")
    return
  end
  logGreen("[Quest] NotifyQuestComplete, questId = " .. vParam.questId)
  local questVM = Z.VMMgr.GetVM("quest")
  questVM.HandelQuestComplete(vParam.questId, true)
end

function WorldNtfStubImpl:NotifyUserAllValidBattlePassData(call, vParam)
  local battlePassData = Z.DataMgr.Get("battlepass_data")
  if not vParam.allValidBattlePasssMap or table.zcount(vParam.allValidBattlePasssMap) == 0 then
    battlePassData.CurBattlePassData = {}
    return
  end
  local curData
  for k, v in pairs(vParam.allValidBattlePasssMap) do
    if v.isValid == true then
      curData = v
      break
    end
  end
  if not curData then
    return
  end
  local dirtyTable = {}
  for key, value1 in pairs(curData) do
    local value2 = battlePassData.CurBattlePassData[key]
    if type(value1) == "table" then
      dirtyTable[key] = not table.zdeepCompare(value1, value2)
    elseif value1 ~= value2 then
      dirtyTable[key] = true
    else
      dirtyTable[key] = nil
    end
  end
  battlePassData.CurBattlePassData = curData
  Z.EventMgr:Dispatch(Z.ConstValue.BattlePassDataUpdate, dirtyTable)
end

function WorldNtfStubImpl:EnterMatchResultNtf(call, vRequest)
  local errCode = vRequest.errCode
  if errCode ~= 0 then
    Z.TipsVM.ShowTips(errCode)
    return
  end
  local matchdata = Z.DataMgr.Get("match_data")
  if vRequest.isReEnter then
    Z.TipsVM.ShowTips(16002044)
    local matchVm_ = Z.VMMgr.GetVM("match")
    matchVm_.CloseMatchView()
  end
  matchdata:SetMatchData(vRequest.matchInfo)
end

function WorldNtfStubImpl:SignRewardNotify(call, vRequest)
  local themePlayData = Z.DataMgr.Get("theme_play_data")
  logGreen("SignRewardNotify = " .. table.ztostring(vRequest))
  themePlayData:ResetSignAwardData()
  local isShowRedDot = false
  if vRequest and #vRequest.signDays > 0 then
    for i, v in ipairs(vRequest.signDays) do
      themePlayData:SetSignAwardData(v, E.DrawState.CanDraw)
    end
    isShowRedDot = true
  end
  if vRequest and 0 < #vRequest.rewardDays then
    for i, v in ipairs(vRequest.rewardDays) do
      themePlayData:SetSignAwardData(v, E.DrawState.AlreadyDraw)
    end
  end
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  if not gotoFuncVM.FuncIsOn(E.ThemeActivityFunctionId.Sign, true) then
    isShowRedDot = false
  end
  local redDotId = E.ThemeActivityRedDot[E.ThemeActivityFunctionId.Sign]
  Z.RedPointMgr.UpdateNodeCount(redDotId, isShowRedDot and 1 or 0)
  Z.EventMgr:Dispatch(Z.ConstValue.ThemePlay.SignActivityRefresh)
end

return WorldNtfStubImpl
