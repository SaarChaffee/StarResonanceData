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
  local envVM = Z.VMMgr.GetVM("env")
  envVM.AddEnvWatcher()
  Z.GuideMgr:InitGuideData()
  Z.EventMgr:Dispatch(Z.ConstValue.SyncAllContainerData)
end

function WorldNtfStubImpl:QteBegin(call, qteId)
  Z.EventMgr:Dispatch("CreateQteUIUnit", qteId)
end

function WorldNtfStubImpl:QuestAbort(call, questId)
  logGreen("quest abort: questId = {0}", questId)
  local questVM = Z.VMMgr.GetVM("quest")
  questVM.EndQuest(questId, false)
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
    tipsType = E.InvitationTipsType.Invite,
    content = string.format("%s\227\128\144%s\227\128\145", Lang("RequestToJoinUnion"), vRequest.unionName),
    cd = Z.Global.TeamInviteLastTime,
    func = unionInviteFunc,
    funcParam = {
      unionId = vRequest.unionId
    }
  }
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, info)
end

function WorldNtfStubImpl:ChangeNameResultNtf(call, vCode)
  Z.EventMgr:Dispatch(Z.ConstValue.Player.ChangeNameResultNtf, vCode)
end

function WorldNtfStubImpl:NotifyReviveUser(call, uuid)
  if uuid ~= Z.EntityMgr.PlayerUuid then
    Z.EventMgr:Dispatch(Z.ConstValue.BeRevire)
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
  end
end

function WorldNtfStubImpl:NotifyNoticeInfo(call, vInfo)
  local broadcastVM = Z.VMMgr.GetVM("tips_broadcast")
  broadcastVM.AddBroadcast(vInfo)
end

function WorldNtfStubImpl:NotifyTextCheckResult(call, errcode)
  local screenWordVM = Z.VMMgr.GetVM("screenword")
  screenWordVM.CheckScreenWordResult(errcode)
end

function WorldNtfStubImpl:NotifyInstructionInfo(call, vInfo)
  logError("[NotifyInstructionInfo]" .. table.ztostring(vInfo))
  local loginVM = Z.VMMgr.GetVM("login")
  local dialogViewData = {}
  dialogViewData.isTop = true
  dialogViewData.dlgType = E.DlgType.OK
  dialogViewData.labDesc = vInfo.msg
  dialogViewData.labTitle = vInfo.title
  if vInfo.type == Z.PbEnum("EInstructionType", "InstructionType_Tips") then
    function dialogViewData.onConfirm()
      Z.DialogViewDataMgr:CloseDialogView()
    end
  elseif vInfo.type == Z.PbEnum("EInstructionType", "InstructionType_Logout") then
    function dialogViewData.onConfirm()
      Z.DialogViewDataMgr:CloseDialogView()
      
      loginVM:KickOffByClient(E.KickOffClientErrCode.UnderageLimit)
    end
  elseif vInfo.type == Z.PbEnum("EInstructionType", "InstructionType_OpenUrl") then
    function dialogViewData.onConfirm()
      if Z.SDKLogin.GetSDKType() == E.LoginSDKType.MSDK then
        Z.SDKWebView.OpenAntiAddictionPage(vInfo.data)
      else
        local url = ""
        xpcall(function()
          local cjson = require("cjson")
          url = cjson.decode(vInfo.data).url
        end, function(msg)
          logError("[NotifyInstructionInfo]decode json Error : " .. msg)
        end)
        if url ~= nil and url ~= "" then
          Z.SDKWebView.OpenUrl(url)
        else
          logError("[NotifyInstructionInfo]URL is Empty or nil")
        end
      end
      Z.DialogViewDataMgr:CloseDialogView()
    end
  else
    function dialogViewData.onConfirm()
      Z.DialogViewDataMgr.CloseDialogView()
    end
  end
  Z.DialogViewDataMgr:OpenCenterControlDialog(dialogViewData)
  Z.CoroUtil.create_coro_xpcall(function()
    local accountData = Z.DataMgr.Get("account_data")
    loginVM:AsyncReportMSDK(accountData.OpenID, vInfo.ruleName, vInfo.traceId)
  end)()
end

function WorldNtfStubImpl:NotifyClientKickOff(call, errorCode)
  Z.ConnectMgr:SetReconnectEnabled(E.RpcChannelType.Gateway, false)
  if errorCode == Z.PbEnum("EErrorCode", "ErrExitGame") then
    return
  end
  local loginVM = Z.VMMgr.GetVM("login")
  loginVM:KickOffByServer(errorCode)
end

function WorldNtfStubImpl:BuyShopItemResponse(call, data)
  Z.VMMgr.GetVM("season_shop").BuyShopItemResponse(call, data)
end

function WorldNtfStubImpl:PaymentResponse(call, vRequest)
  local shopVm = Z.VMMgr.GetVM("shop")
  shopVm.BuyCallFunc(vRequest)
end

function WorldNtfStubImpl:ExchangeCurrencyResponse(call, errorCode)
  if errorCode == 0 then
    Z.TipsVM.ShowTipsLang(1000731)
  else
    Z.TipsVM.ShowTips(errorCode)
  end
end

function WorldNtfStubImpl:NotifyUnlockCookBook(call, data)
end

function WorldNtfStubImpl:NotifyCustomEvent(call, eventParams)
  logGreen("[NotifyCustomEvent]eventParams={0}", tostring(eventParams))
  Z.EventMgr:Dispatch("level_event", E.LevelEventType.TriggerEvent, eventParams.customEventId)
end

function WorldNtfStubImpl:NotifyStartPlayingDungeon(call, data)
  local playerData = Z.DataMgr.Get("player_data")
  if playerData.CharInfo and playerData.CharInfo.baseInfo.charId == data.charId then
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
  local itemData = vInfo.items
  local awardTab = itemShowVm.AssembleData(itemData)
  itemShowVm.OpenItemShowView(awardTab)
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
  Z.DialogViewDataMgr:OpenOKDialog(vInfo.message, nil, E.EDialogViewDataType.System, true)
end

function WorldNtfStubImpl:NotifyDriverApplyRide(call, param)
  local vehicleApplyFunc = function(callData, flag, cancelSource)
    local vehicleVM = Z.VMMgr.GetVM("vehicle")
    if flag then
      vehicleVM.ApplyToRideResult(callData.applyId, E.VehicleApplyRideResult.ApplyRideResultAgree, cancelSource:CreateToken())
    else
      vehicleVM.ApplyToRideResult(callData.applyId, E.VehicleApplyRideResult.ApplyRideResultRefuse, cancelSource:CreateToken())
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
  local vehicleApplyFunc = function(callData, flag, cancelSource)
    local vehicleVM = Z.VMMgr.GetVM("vehicle")
    if flag then
      vehicleVM.ApplyToRideResult(callData.driverId, E.VehicleApplyRideResult.ApplyRideResultAgree, cancelSource:CreateToken())
    else
      vehicleVM.ApplyToRideResult(callData.driverId, E.VehicleApplyRideResult.ApplyRideResultRefuse, cancelSource:CreateToken())
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
    if Z.EntityMgr.PlayerEnt:GetLuaRideStage() ~= vehicleDefine.ERideStage.ERideNone then
      return
    end
    local charId = param.charId
    Z.CoroUtil.create_coro_xpcall(function()
      local vehicleVM = Z.VMMgr.GetVM("vehicle")
      local cancelSource = Z.CancelSource.Rent()
      vehicleVM.RideReconfirm(charId, cancelSource:CreateToken())
    end)()
  else
    Z.TipsVM.ShowTipsLang(1000902, {
      val = param.charName
    })
  end
end

function WorldNtfStubImpl:NotifyUserCloseFunction(call, vParam)
  local switchVM = Z.VMMgr.GetVM("switch")
  switchVM.UserCloseFunction(vParam)
end

function WorldNtfStubImpl:NotifyServerCloseFunction(call, vParam)
  local switchVM = Z.VMMgr.GetVM("switch")
  switchVM.ServerCloseFunction(vParam)
end

return WorldNtfStubImpl
