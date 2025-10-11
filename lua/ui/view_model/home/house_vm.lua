local HouseVm = {}
local homeEditorVm = Z.VMMgr.GetVM("home_editor")
local houseData = Z.DataMgr.Get("house_data")
local worldProxy = require("zproxy.world_proxy")
local funcVm = Z.VMMgr.GetVM("gotofunc")

function HouseVm.CloseAllHomeView()
  HouseVm.CloseHouseMainView()
  HouseVm.CloseHouseSignatureView()
  HouseVm.CloseHouseInvitationLetterView()
  HouseVm.CloseHouseBuyView()
  HouseVm.CloseHouseApplyView()
  HouseVm.CloseHouseBulletinBoardView()
  HouseVm.CloseHouseFurnitureGuideView()
  HouseVm.CloseHouseSetView()
  HouseVm.CloseHouseProductionView()
  HouseVm.CloseHouseLevelView()
end

function HouseVm.OpenHouseMainView()
  local viewData = {
    homeId = houseData:GetHomeId()
  }
  Z.UIMgr:OpenView("house_main", viewData)
end

function HouseVm.CloseHouseMainView()
  Z.UIMgr:CloseView("house_main")
end

function HouseVm.CloseHouseSignatureView()
  Z.UIMgr:CloseView("house_check_signature_popup")
end

function HouseVm.OpenHouseInvitationLetterView(viewData)
  Z.UIMgr:OpenView("house_invitation_letter_popup", viewData)
end

function HouseVm.CloseHouseInvitationLetterView()
  Z.UIMgr:CloseView("house_invitation_letter_popup")
end

function HouseVm.OpenHouseBuyView()
  Z.UIMgr:OpenView("house_buy_title_deed_sub")
end

function HouseVm.CloseHouseBuyView()
  Z.UIMgr:CloseView("house_buy_title_deed_sub")
end

function HouseVm.CloseHouseGetView()
  Z.UIMgr:CloseView("house_get_popup")
end

function HouseVm.OpenHouseApplyView()
  Z.UIMgr:OpenView("house_application_list_popup")
end

function HouseVm.CloseHouseApplyView()
  Z.UIMgr:CloseView("house_application_list_popup")
end

function HouseVm.OpenHouseBulletinBoardView()
  Z.UIMgr:OpenView("house_bulletin_board_popup")
end

function HouseVm.CloseHouseBulletinBoardView()
  Z.UIMgr:CloseView("house_bulletin_board_popup")
end

function HouseVm.OpenHouseFurnitureGuideView()
  if funcVm.CheckFuncCanUse(E.FunctionID.HouseFurnitureGuide) then
    Z.UIMgr:OpenView("house_furniture_guide_window")
  end
end

function HouseVm.CloseHouseFurnitureGuideView()
  Z.UIMgr:CloseView("house_furniture_guide_window")
end

function HouseVm.OpenHouseSetView(data)
  Z.UIMgr:OpenView("house_set_popup", data)
end

function HouseVm.CloseHouseSetView()
  Z.UIMgr:CloseView("house_set_popup")
end

function HouseVm.OpenHouseProductionView(type)
  if funcVm.CheckFuncCanUse(E.FunctionID.HouseProduction) then
    Z.UIMgr:OpenView("house_production_main", type)
  end
end

function HouseVm.CloseHouseProductionView()
  Z.UIMgr:CloseView("house_production_main")
end

function HouseVm.OpenHoseGetItemView(data)
  Z.UIMgr:OpenView("house_get_item_popup", data)
end

function HouseVm.CloseHoseGetItemView()
  Z.UIMgr:CloseView("house_get_item_popup")
end

function HouseVm.OpenHouseLevelView()
  Z.UIMgr:FadeOut()
  Z.UIMgr:OpenView("house_level_window")
end

function HouseVm.CloseHouseLevelView()
  Z.UIMgr:CloseView("house_level_window")
end

function HouseVm.OpenHouseUpgradeView()
  Z.UIMgr:OpenView("house_upgrade_popup")
end

function HouseVm.CloseHouseUpgradeView()
  Z.UIMgr:CloseView("house_upgrade_popup")
end

function HouseVm.OpenHouseTaskView()
  Z.UIMgr:OpenView("house_quest_window")
end

function HouseVm.CloseHouseTaskView()
  Z.UIMgr:CloseView("house_quest_window")
end

function HouseVm.OpenHouseShopView()
  local shopVM_ = Z.VMMgr.GetVM("shop")
  shopVM_.openCommonShopView(E.EShopType.HouseShop)
end

function HouseVm.CloseHouseShopView()
  Z.UIMgr:CloseView("shop_token")
end

function HouseVm.OpenHouseSellShopView()
  Z.UIMgr:OpenView("house_shop_main")
end

function HouseVm.CloseHouseSellShopView()
  Z.UIMgr:CloseView("house_shop_main")
end

function HouseVm.OpenHousePlayFarmTipsView(uuid)
  Z.UIMgr:OpenView("house_play_farm_tips", uuid)
end

function HouseVm.CloseHousePlayFarmTipsView(uuid, interactionCfgId)
  if houseData.CurFarmInteractionConfigId == interactionCfgId and houseData.CuyFarmInteractionUuid == uuid then
    Z.UIMgr:CloseView("house_play_farm_tips")
  end
end

function HouseVm.OpenHousePlayFarmMainView(uuid, interactionCfgId, param)
  houseData.CurFarmInteractionConfigId = interactionCfgId
  houseData.CuyFarmInteractionUuid = uuid
  local structure = Z.DIServiceMgr.HomeService:GetHouseItemStructure(uuid)
  if structure then
    if structure.farmlandInfo and not structure.farmlandInfo.isEnd and structure.farmlandInfo.farmlandState:ToInt() ~= E.HomeEFarmlandState.EFarmlandStateEmpty then
      HouseVm.OpenHousePlayFarmTipsView(uuid)
    else
      Z.UIMgr:CloseView("house_play_farm_tips")
    end
    if not structure.farmlandInfo then
      Z.UIMgr:OpenView("house_play_farm_main", {uuid, param})
    else
      local state = structure.farmlandInfo.farmlandState:ToInt()
      if state == E.HomeEFarmlandState.EFarmlandStateEmpty or state == E.HomeEFarmlandState.EFarmlandStateGrow or state == E.HomeEFarmlandState.EFarmlandStatePollen then
        Z.UIMgr:OpenView("house_play_farm_main", {uuid, param})
      end
    end
  end
end

function HouseVm.CloseHousePlayFarmMainView(uuid, interactionCfgId)
  if houseData.CurFarmInteractionConfigId == interactionCfgId and houseData.CuyFarmInteractionUuid == uuid then
    Z.UIMgr:CloseView("house_play_farm_main")
  end
end

function HouseVm.HomeEntrance()
  local homeId = Z.ContainerMgr.CharSerialize.communityHomeInfo.homelandId
  if homeId ~= 0 then
    HouseVm.OpenHouseMainView()
  else
    HouseVm.OpenHouseBuyView()
  end
end

function HouseVm.EnterHome()
  Z.CoroUtil.create_coro_xpcall(function()
    HouseVm.AsyncEnterHomeland(houseData.CancelSource:CreateToken())
  end, function()
    houseData.IsEntering = false
  end)()
end

function HouseVm.ExitHome()
  Z.CoroUtil.create_coro_xpcall(function()
    HouseVm.AsyncEnterCommunity(houseData.CancelSource:CreateToken())
  end, function()
    houseData.IsEntering = false
  end)()
end

function HouseVm.OpenAnnouncementsLink()
  local data = {
    dlgType = E.DlgType.OK,
    labTitle = Lang("HouseInvitationTipsPopupTitle"),
    labOK = Lang("BtnClose"),
    textAnchor = TMPro.TextAlignmentOptions.TopLeft,
    labDesc = Lang("HouseInvitationTipsPopupDesc")
  }
  Z.DialogViewDataMgr:OpenDialogView(data)
end

function HouseVm.OpenAnnouncements(onConfirm)
  local data = {
    dlgType = E.DlgType.YesNo,
    labTitle = Lang("HouseInvitationTipsPopupTitle"),
    labYes = Lang("Accept"),
    labNo = Lang("BtnClose"),
    textAnchor = TMPro.TextAlignmentOptions.TopLeft,
    labDesc = Lang("HouseInvitationTipsPopupDesc"),
    onConfirm = onConfirm
  }
  Z.DialogViewDataMgr:OpenDialogView(data)
end

function HouseVm.OpenQuitCohabitDialog(onConfirm, isHomeOwner)
  local data = {
    dlgType = E.DlgType.YesNo,
    labTitle = Lang("QuitCohabitant"),
    labYes = Lang("QuitCohabitantAgree"),
    labNo = Lang("BtnNo"),
    onConfirm = onConfirm,
    labDesc = isHomeOwner and Lang("OwnerQuitCohabitantDialog") or Lang("QuitCohabitantDialog")
  }
  Z.DialogViewDataMgr:OpenDialogView(data)
end

function HouseVm.OpenTransferOwnershipDialog(onConfirm)
  local data = {
    dlgType = E.DlgType.YesNo,
    labTitle = Lang("TransferOwnershipDialogTitle"),
    labYes = Lang("BtnYes"),
    labNo = Lang("BtnNo"),
    onConfirm = onConfirm,
    labDesc = Lang("TransferOwnershipDialogDesc")
  }
  Z.DialogViewDataMgr:OpenDialogView(data)
end

function HouseVm.OpenTransferOwnershipDialogWithCertificate(onConfirm)
  local data = {
    dlgType = E.DlgType.YesNo,
    labTitle = Lang("DialogDefaultTitle"),
    labYes = Lang("Goto"),
    labNo = Lang("BtnNo"),
    onConfirm = onConfirm,
    labDesc = Lang("TransferOwnershipDialogDescWithCertificate")
  }
  Z.DialogViewDataMgr:OpenDialogView(data)
end

function HouseVm.OpenTransferOwnershipInCdDialog(remainTime)
  local data = {
    dlgType = E.DlgType.OK,
    labTitle = Lang("TransferOwnershipInCdDialogTitle"),
    labOK = Lang("BtnOK"),
    labDesc = Lang("TransferOwnershipInCdDialogDesc", {
      value = {remainTime}
    })
  }
  Z.DialogViewDataMgr:OpenDialogView(data)
end

function HouseVm:HasHouseCertificate()
  local itemVm = Z.VMMgr.GetVM("items")
  return itemVm.GetItemTotalCount(Z.GlobalHome.HouseCertificateID) > 0
end

function HouseVm.GetFurnitureItemList(type)
  local houseData = Z.DataMgr.Get("house_data")
  return houseData.HousingItemGroupItems[type] or {}
end

function HouseVm.CheckIsUnlock(itemId)
  return Z.ContainerMgr.CharSerialize.communityHomeInfo.unlockedRecipes[itemId] ~= nil
end

function HouseVm.GetUnlockFurnitureItemList(furnitureType)
  local houseData = Z.DataMgr.Get("house_data")
  local data = houseData.HosingTypeItems[furnitureType]
  if data == nil then
    return {}
  end
  local itemList = {}
  local index = 1
  for _, value in pairs(data) do
    if not value.Build then
      if #value.UnlockItem > 0 or 0 < #value.UnlockCondition then
        local isUnlock = false
        if 0 < #value.UnlockCondition then
          isUnlock = Z.ConditionHelper.CheckCondition(value.UnlockCondition)
        else
          isUnlock = true
        end
        if #value.UnlockItem > 0 and isUnlock then
          isUnlock = HouseVm.CheckIsUnlock(value.Id)
        end
        if isUnlock then
          itemList[index] = value
          index = index + 1
        end
      else
        itemList[index] = value
        index = index + 1
      end
    end
  end
  return itemList
end

function HouseVm.AsyncEnterCommunity(token)
  if houseData.IsEntering then
    return
  end
  houseData.IsEntering = true
  local stageType = Z.StageMgr.GetCurrentStageType()
  if stageType == Z.EStageType.CommunityDungeon then
    Z.TipsVM.ShowTips(1044014)
    return
  end
  local request = {
    communityId = houseData:GetCommunityId(),
    homelandId = houseData:GetHomeId()
  }
  local errorId = worldProxy.CommunityEnter(request, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
    houseData.IsEntering = false
  end
end

function HouseVm.AsyncEnterHomeland(token)
  if houseData.IsEntering then
    return
  end
  houseData.IsEntering = true
  local stageType = Z.StageMgr.GetCurrentStageType()
  if stageType == Z.EStageType.HomelandDungeon then
    Z.TipsVM.ShowTips(1044014)
    return
  end
  local request = {
    homelandId = houseData:GetHomeId()
  }
  local errorId = worldProxy.CommunityEnterHomeland(request, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
    houseData.IsEntering = false
  end
end

function HouseVm.AsyncBuyHouse(token)
  local errorId = worldProxy.BuyHouse({}, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  end
end

function HouseVm.AsyncAcceptRejectInvitation(charId, homeId, accept, token)
  local request = {
    charId = charId,
    homeId = homeId,
    accept = accept
  }
  local ret = worldProxy.CommunityAcceptRejectInvitation(request, token)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.House.RefreshApplyList)
end

function HouseVm.AsyncGetPersonData(token)
  local request = {}
  local ret = worldProxy.CommunityPersonData(request, token)
  return ret
end

function HouseVm.AsyncInvitationCohabitant(charId, token)
  local request = {charId = charId}
  local errorId = worldProxy.CommunityInvitationCohabitant(request, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  else
    Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshInviteList)
  end
end

function HouseVm.AsyncGetInvitationList(token)
  local request = {}
  local ret = worldProxy.CommunityInvitation(request, token)
  if ret then
    houseData:SetInvitationList(ret.invitationIds)
  end
end

function HouseVm.AsyncGetCohabitant(token)
  local request = {
    homelandId = houseData:GetHomeId(),
    communityId = houseData:GetCommunityId()
  }
  local ret = worldProxy.GetHomelandCohabitant(request, token)
  if ret.errCode == 0 then
    return ret.cohabitant
  else
    Z.TipsVM.ShowTips(ret.errCode)
    return nil
  end
end

function HouseVm.AsyncQuitCohabitant(charId, homeId, operatorCharId, token)
  local request = {
    charId = charId,
    homeId = homeId,
    operatorCharId = operatorCharId
  }
  local errorId = worldProxy.CommunityQuitCohabitant({info = request}, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  end
end

function HouseVm.AsyncQuitCohabitantCancel(charId, homeId, operatorCharId, token)
  local request = {
    charId = charId,
    homeId = homeId,
    operatorCharId = operatorCharId
  }
  local errorId = worldProxy.CommunityQuitCohabitantCancel({info = request}, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  end
end

function HouseVm.AsyncQuitCohabitantAgree(charId, homeId, operatorCharId, token)
  local request = {
    charId = charId,
    homeId = homeId,
    operatorCharId = operatorCharId
  }
  local errorId = worldProxy.CommunityQuitCohabitantAgree({info = request}, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  else
    Z.TipsVM.ShowTips(1044012)
    HouseVm.CloseAllHomeView()
  end
end

function HouseVm.AsyncSetCheckInContent(checkInContent, token)
  local request = {checkInContent = checkInContent}
  local errorId = worldProxy.CommunitySetCheckInContent(request, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  end
end

function HouseVm.AsyncSetHouseName(name, token)
  local request = {name = name}
  local ret = worldProxy.CommunitySetName(request, token)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function HouseVm.AsyncSetHouseIntroduc(introduction, token)
  local request = {introduction = introduction}
  local errorId = worldProxy.CommunitySetIntroduction(request, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  end
end

function HouseVm.AsyncGetHomeLandBaseInfo(token)
  local communityId = houseData:GetCommunityId()
  local homeId = houseData:GetHomeId()
  if not communityId or not homeId then
    return false
  end
  if communityId == 0 or homeId == 0 then
    return false
  end
  local request = {communityId = communityId, homelandId = homeId}
  local ret = worldProxy.CommunityGetHomeLandBaseInfo(request, token)
  if ret.errCode == 0 then
    houseData:SetHomelandBaseInfo(ret.homelandBaseInfo)
    Z.EventMgr:Dispatch(Z.ConstValue.Home.BaseInfoUpdate)
  else
    Z.TipsVM.ShowTips(ret.errCode)
  end
  return ret.errCode ~= 0
end

function HouseVm.AsyncTransferOwnership(homelandId, newOwnerCharId, token)
  local request = {homelandId = homelandId, newOwnerCharId = newOwnerCharId}
  local errorId = worldProxy.CommunityTransferOwnership(request, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  end
end

function HouseVm.AsyncTransferOwnershipCancel(homelandId, token)
  local request = {homelandId = homelandId}
  local errorId = worldProxy.CommunityTransferOwnershipCancel(request, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  end
end

function HouseVm.AsyncTransferOwnershipAgree(homelandId, isAgree, token)
  local request = {homelandId = homelandId, isAgree = isAgree}
  local errorId = worldProxy.CommunityTransferOwnershipAgree(request, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  end
end

function HouseVm.AsyncSetAuthority(limitType, limitValue, token)
  local authority = {
    [limitType] = limitValue
  }
  local request = {
    authorityInfo = {authority = authority}
  }
  local errorId = worldProxy.CommunitySetAuthority(request, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  end
end

function HouseVm.AsyncSetPlayerAuthority(charId, limitType, limitValue, token)
  local authority = {
    [limitType] = limitValue
  }
  local request = {
    charId = charId,
    authorityInfo = {authority = authority}
  }
  local errorId = worldProxy.CommunitySetPlayerAuthority(request, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  end
end

function HouseVm.AsyncBuildFurnitureReceive(buildUuidId, configId, count, token)
  local request = {
    buildUuid = buildUuidId,
    isAll = buildUuidId == nil
  }
  local errorId = worldProxy.CommunityBuildFurnitureReceive(request, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  else
    Z.EventMgr:Dispatch(Z.ConstValue.House.RefreshBuildList)
  end
end

function HouseVm.AsyncGetHomelandBuildFurnitureInfo(buildType, token)
  local request = {buildType = buildType}
  local ret = worldProxy.GetHomelandBuildFurnitureInfo(request, token)
  houseData:SetBuildInfos(buildType, ret.furnitureInfo)
end

function HouseVm.AsyncCommunityBuildFurniture(furnitureId, count, token)
  if not houseData:GetHomeCharLimit(E.HousePlayerLimitType.FurnitureMake, Z.ContainerMgr.CharSerialize.charId) then
    Z.TipsVM.ShowTips(2423)
    return
  end
  local request = {recipeId = furnitureId, count = count}
  local errorId = worldProxy.CommunityBuildFurniture(request, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  end
  return errorId
end

function HouseVm.AsyncBuildFurnitureCancel(buildUuid, token)
  local request = {buildUuid = buildUuid}
  local errorId = worldProxy.CommunityBuildFurnitureCancel(request, token)
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  else
    Z.EventMgr:Dispatch(Z.ConstValue.House.RefreshBuildList)
  end
end

function HouseVm.AsyncBuildFurnitureAccelerate(buildUuid, configId, count, cancelSource)
  local request = {buildUuid = buildUuid, count = count}
  local errorId = worldProxy.CommunityBuildFurnitureAccelerate(request, cancelSource:CreateToken())
  if errorId == 0 then
    HouseVm.AsyncBuildFurnitureReceive(buildUuid, configId, count, cancelSource:CreateToken())
  else
    Z.TipsVM.ShowTips(errorId)
  end
end

function HouseVm.AsyncUnlockFurnitureRecipe(furnitureId, token)
  local request = {furnitureId = furnitureId}
  local errorId = worldProxy.CommunityUnlockFurnitureRecipe(request, token)
  if errorId == 0 then
  else
    Z.TipsVM.ShowTips(errorId)
  end
  return errorId
end

function HouseVm.AsyncGetHomelandBulletinBoards(token)
  local communityId = houseData:GetCommunityId()
  local homeId = houseData:GetHomeId()
  if not communityId or not homeId then
    return false
  end
  local request = {communityId = communityId, homelandId = homeId}
  local ret = worldProxy.GetHomelandBulletinBoards(request, token)
  return ret
end

function HouseVm.AsyncGetHomelandCheckInContent(communityId, homelandId, token)
  local request = {communityId = communityId, homelandId = homelandId}
  local ret = worldProxy.GetHomelandCheckInContent(request, token)
  return ret.checkInContent
end

function HouseVm.AsyncUpgradeHouse(level, token)
  local ret = worldProxy.LevelUp(level, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function HouseVm.AsyncCleanHouseClutter(uuid, token)
  local ret = worldProxy.DestroyClutter(uuid, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function HouseVm.AsyncCleanAllHouseClutter()
  Z.CoroUtil.create_coro_xpcall(function()
    local ret = worldProxy.DestroyClutter(-1, houseData.CancelSource:CreateToken())
    if ret ~= 0 then
      Z.TipsVM.ShowTips(ret)
    end
  end)()
end

function HouseVm.AsyncCommitHouseQuest(taskId, token)
  local ret = worldProxy.SubmitTask(taskId, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function HouseVm.AsyncSellItem(sellData, sellNum, token)
  local ret = worldProxy.SellHomeLandItems(sellData.itemId, sellNum, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function HouseVm.AsyncSWaterUpdateStructure(request, token)
  local ret = worldProxy.WaterUpdateStructure(request, token)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function HouseVm.AsyncSWaterUpdateStructure(request, token)
  local ret = worldProxy.WaterUpdateStructure(request, token)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function HouseVm.AsyncPickUpUpdateStructure(request, token)
  local ret = worldProxy.PickUpUpdateStructure(request, token)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function HouseVm.AsyncGainUpdateStructure(request, token)
  local ret = worldProxy.GainUpdateStructure(request, token)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function HouseVm.AsyncSeedingUpdateStructure(request, token)
  local ret = worldProxy.SeedingUpdateStructure(request, token)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function HouseVm.AsyncFertilizerUpdateStructure(request, token)
  local ret = worldProxy.FertilizerUpdateStructure(request, token)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function HouseVm.AsyncPollenUpdateStructure(request, token)
  local ret = worldProxy.PollenUpdateStructure(request, token)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function HouseVm.OnClickFarmBtn(uid, token, param)
  if not param then
    return
  end
  local actionType = tonumber(param[3])
  if actionType == E.HomeFarmActionType.Seed or actionType == E.HomeFarmActionType.Manure or actionType == E.HomeFarmActionType.Pollination then
    Z.EventMgr:Dispatch(Z.ConstValue.Home.OnClickFarmBtnAction)
  else
    Z.CoroUtil.create_coro_xpcall(function()
      local request = {}
      request.homeId = Z.ContainerMgr.CharSerialize.communityHomeInfo.homelandId
      request.op = {}
      request.op.uuid = uid
      if actionType == E.HomeFarmActionType.Watering then
        request.op.opType = E.HomeStructureOpType.StructureOpTypeUpdate
        HouseVm.AsyncSWaterUpdateStructure(request, houseData.CancelSource:CreateToken())
      elseif actionType == E.HomeFarmActionType.Collect then
        request.op.opType = E.HomeStructureOpType.StructureOpTypeUpdate
        HouseVm.AsyncPickUpUpdateStructure(request, houseData.CancelSource:CreateToken())
      elseif actionType == E.HomeFarmActionType.Harvest then
        request.op.opType = E.HomeStructureOpType.StructureOpTypeUpdate
        HouseVm.AsyncGainUpdateStructure(request, houseData.CancelSource:CreateToken())
      end
    end)()
  end
end

function HouseVm.CheckHouseCanUpGrade(level)
  local houseData = Z.DataMgr.Get("house_data")
  local curLevel = houseData:GetHouseLevel()
  if level == nil then
    level = curLevel + 1
  end
  if level ~= curLevel + 1 then
    return false
  end
  local homeLevelTableRow = Z.TableMgr.GetTable("HomeLevelTableMgr").GetRow(level, true)
  if not homeLevelTableRow then
    return false
  end
  local isConditionMet = Z.ConditionHelper.CheckCondition(homeLevelTableRow.Condition, true)
  local lastHomeLevelTableRow = Z.TableMgr.GetTable("HomeLevelTableMgr").GetRow(level - 1, true)
  if not lastHomeLevelTableRow then
    return false
  end
  if isConditionMet and houseData:GetHouseExp() >= lastHomeLevelTableRow.Exp then
    return true
  end
  return false
end

return HouseVm
