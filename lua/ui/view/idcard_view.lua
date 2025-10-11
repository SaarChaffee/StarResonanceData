local UI = Z.UI
local super = require("ui.ui_view_base")
local IdcardView = class("IdcardView", super)
local snapShotVM = Z.VMMgr.GetVM("snapshot")
local PERSONALZONEDEFINE = require("ui.model.personalzone_define")
local vehicleDefine = require("ui.model.vehicle_define")
local reportDefine = require("ui.model.report_define")

function IdcardView:ctor()
  self.uiBinder = nil
  super.ctor(self, "idcard")
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.teamMainVM_ = Z.VMMgr.GetVM("team_main")
  self.vm_ = Z.VMMgr.GetVM("idcard")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
  self.socialVM_ = Z.VMMgr.GetVM("social")
  self.deadVM_ = Z.VMMgr.GetVM("dead")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.reportVM_ = Z.VMMgr.GetVM("report")
  self.switchVM_ = Z.VMMgr.GetVM("switch")
  self.downloadVm_ = Z.VMMgr.GetVM("download")
end

function IdcardView:OnActive()
  self:startAnimatedShow()
  self.uiBinder.node_press:StartCheck()
  if not self.viewData.photoData then
    self:EventAddAsyncListener(self.uiBinder.node_press.ContainGoEvent, function(isContain)
      if not isContain then
        self.vm_.CloseIdCardView()
      end
    end, nil, nil)
  end
  self:setUnionPhotoState()
end

function IdcardView:setPlayerUnion(unionName)
  self.unionName_ = unionName
  self.uiBinder.lab_union.text = Lang("IdCardInfo", {
    val1 = Lang("Union"),
    val2 = self.unionName_
  })
end

function IdcardView:setPlayerInfo(cardData)
  local collectionVM = Z.VMMgr.GetVM("collection")
  self.uiBinder.lab_num.text = collectionVM.GetFashionCollectionPoints(cardData)
  local info = Lang("None")
  if cardData.teamData then
    local teamId = cardData.teamData.teamId
    if teamId ~= 0 then
      local teamTargetData = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(cardData.teamData.teamTargetId)
      if teamTargetData then
        local targetName = teamTargetData.Name
        local teamMaxNum = cardData.teamData.teamMemberType == E.ETeamMemberType.Five and 5 or 20
        info = targetName .. " " .. cardData.teamData.teamNum .. "/" .. teamMaxNum
      end
    end
  end
  self.uiBinder.lab_team.text = Lang("IdCardInfo", {
    val1 = Lang("Team"),
    val2 = info
  })
  if cardData.personalZone and cardData.personalZone.titleId and cardData.personalZone.titleId ~= 0 then
    local titleId = cardData.personalZone.titleId
    local titleConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(titleId)
    if titleConfig then
      self.uiBinder.lab_gs.text = Lang("IdCardInfo", {
        val1 = Lang("PersonalzoneTitle"),
        val2 = titleConfig.Name
      })
    else
      self.uiBinder.lab_gs.text = Lang("IdCardInfo", {
        val1 = Lang("PersonalzoneTitle"),
        val2 = Lang("None")
      })
    end
  else
    self.uiBinder.lab_gs.text = Lang("IdCardInfo", {
      val1 = Lang("PersonalzoneTitle"),
      val2 = Lang("None")
    })
  end
  if cardData.basicData then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(cardData.basicData.isNewbie))
    local playerName = cardData.basicData.name
    self.uiBinder.lab_name.text = playerName
    self.uiBinder.lab_uid.text = Lang("UID") .. cardData.basicData.showId
    local lv = cardData.basicData.level or 1
    self.uiBinder.lab_lv.text = Lang("RoleLevel", {val = lv})
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_profession_bg, false)
  if cardData.professionData then
    local professionId = cardData.professionData.professionId
    local ProfessionSystemTableBase = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
    if ProfessionSystemTableBase then
      self.uiBinder.img_icon_profession:SetImage(ProfessionSystemTableBase.Icon)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_profession_bg, true)
    end
  end
  self.uiBinder.lab_union.text = Lang("IdCardInfo", {
    val1 = Lang("Union"),
    val2 = cardData.unionData == nil and Lang("None") or cardData.unionData.name
  })
  if cardData.masterModeDungeonData then
    local score = cardData.masterModeDungeonData.seasonScore
    local scoreText = Z.VMMgr.GetVM("hero_dungeon_main").GetPlayerSeasonMasterDungeonTotalScoreWithColor(score)
    local master_dungeon_score_text = Lang("MaterDungeonScore") .. scoreText
    if cardData.masterModeDungeonData.isShow then
      master_dungeon_score_text = Lang("MaterDungeonScore") .. Lang("Hidden")
    end
    self.uiBinder.lab_score.text = master_dungeon_score_text
  else
    self.uiBinder.lab_score.text = Lang("MaterDungeonScore") .. Lang("None")
  end
  local idCardId
  if cardData.personalZone and cardData.personalZone.businessCardStyleId and 0 < cardData.personalZone.businessCardStyleId then
    idCardId = cardData.personalZone.businessCardStyleId
  else
    local personalZoneData = Z.DataMgr.Get("personal_zone_data")
    idCardId = personalZoneData:GetDefaultProfileImageConfigByType(PERSONALZONEDEFINE.ProfileImageType.Card)
  end
  if idCardId then
    local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(idCardId)
    if config then
      self.uiBinder.rimg_bg:SetImage(Z.ConstValue.PersonalZone.PersonalCardBg .. config.Image)
      self.uiBinder.rimg_player_bg:SetImage(Z.ConstValue.PersonalZone.PersonalBg .. config.Image)
    end
  end
  if cardData.seasonRank then
    local seasonData = Z.DataMgr.Get("season_data")
    local seasonTitleId = cardData.seasonRank.seasonRanks[seasonData.CurSeasonId]
    if seasonTitleId and seasonTitleId ~= 0 then
      local seasonRankConfig = Z.TableMgr.GetTable("SeasonRankTableMgr").GetRow(seasonTitleId)
      if seasonRankConfig then
        self.uiBinder.img_armband_icon:SetImage(seasonRankConfig.IconBig)
      end
    else
      local seasonData = Z.DataMgr.Get("season_title_data")
      local rankRewardConfigList = seasonData:GetRankRewardConfigList()
      if rankRewardConfigList ~= nil and rankRewardConfigList[1] ~= nil then
        self.uiBinder.img_armband_icon:SetImage(rankRewardConfigList[1].IconBig)
      end
    end
  else
    local seasonData = Z.DataMgr.Get("season_title_data")
    local rankRewardConfigList = seasonData:GetRankRewardConfigList()
    if rankRewardConfigList ~= nil and rankRewardConfigList[1] ~= nil then
      self.uiBinder.img_armband_icon:SetImage(rankRewardConfigList[1].IconBig)
    end
  end
  self:refreshMedals(cardData)
  if Z.EntityMgr.PlayerEnt then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_personal, cardData.basicData.charID ~= Z.EntityMgr.PlayerEnt.CharId)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_personal, false)
    logError("PlayerEnt is nil")
  end
  local parent = self.uiBinder.layout_interactive
  local roleCardTbl = self.vm_.GetFuncList()
  local path = "ui/prefabs/idcard/idcard_item_tpl"
  if Z.IsPCUI then
    path = path .. "_pc"
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for k, v in ipairs(roleCardTbl) do
      local funcId = tonumber(v.FunctionId)
      if not self.units[funcId] then
        local item = self:AsyncLoadUiUnit(path, funcId, parent)
        if item then
          item.img_card:SetImage(v.Icon)
          item.lab_card.text = v.Name
        end
      end
    end
    self:setIdCardItem(cardData)
  end)()
end

function IdcardView:setDefaultModelHalf(cardData)
  if not cardData or not cardData.basicData then
    return
  end
  local modelId = Z.ModelManager:GetModelIdByGenderAndSize(cardData.basicData.gender, cardData.basicData.bodySize)
  local path = snapShotVM.GetModelHalfPortrait(modelId)
  if path ~= nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_idcard_figure, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_idcard_figure, false)
    self.uiBinder.img_idcard_figure:SetImage(path)
  else
    logError("ModelHalfPortrait config row is Empty!")
  end
end

function IdcardView:getHalfBodyTextureCallBack(cardData, nativeTextureId)
  if self.uiBinder == nil then
    return
  end
  if nativeTextureId and nativeTextureId ~= -1 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_idcard_figure, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_idcard_figure, true)
    self.uiBinder.rimg_idcard_figure:SetNativeTexture(nativeTextureId)
  else
    self:setDefaultModelHalf(cardData)
  end
end

function IdcardView:setIdCardItem(cardData)
  if self.uiBinder == nil then
    return
  end
  local havTeam = self.teamVM_.CheckIsInTeam()
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  local isSameTeam = havTeam and cardData.teamData ~= nil and teamInfo.teamId == cardData.teamData.teamId
  local selectIsLeader = teamInfo.leaderId == self.cardId_
  local selfIsLeader = teamInfo.leaderId == Z.ContainerMgr.CharSerialize.charBase.charId
  if not self.viewData.photoData then
    if not self.switchVM_.CheckFuncSwitch(E.FunctionID.DisplayCustomHalfBody) then
      self:setDefaultModelHalf(cardData)
    elseif cardData.avatarInfo and cardData.avatarInfo.halfBody and not string.zisEmpty(cardData.avatarInfo.halfBody.url) and cardData.avatarInfo.halfBody.verify.ReviewStartTime == E.EPictureReviewType.EPictureReviewed then
      local name = self.downloadVm_:GetFileName(cardData.charId, cardData.avatarInfo.halfBody.verify.version, E.HttpPictureDownFoldType.HalfBody)
      self.downloadVm_:GetPicture(name, cardData.avatarInfo.halfBody.url, self.cancelSource:CreateToken(), function(nativeTextureId)
        self:getHalfBodyTextureCallBack(cardData, nativeTextureId)
      end, E.HttpPictureDownFoldType.HalfBody)
    else
      self:setDefaultModelHalf(cardData)
    end
  end
  local isShowKickTeam = false
  if isSameTeam and selfIsLeader then
    isShowKickTeam = true
  end
  self.units[E.IdCardFuncId.KickTeam].Ref.UIComp:SetVisible(isShowKickTeam)
  self.units[E.IdCardFuncId.JoinTeam].Ref.UIComp:SetVisible(cardData.teamData ~= nil and cardData.teamData.teamId ~= 0 and not isSameTeam)
  self.units[E.IdCardFuncId.InviteTeam].Ref.UIComp:SetVisible(not isSameTeam)
  self.units[E.IdCardFuncId.RequestLeader].Ref.UIComp:SetVisible(isSameTeam and selectIsLeader)
  self.units[E.IdCardFuncId.TransferLeader].Ref.UIComp:SetVisible(isSameTeam and selfIsLeader)
  self.units[E.IdCardFuncId.InviteAction].Ref.UIComp:SetVisible(self.viewData.isShowInviteAction == true)
  self.units[E.IdCardFuncId.SendMsg].Ref.UIComp:SetVisible(true)
  self:refreshFriendBtn(cardData.charId)
  local unionFuncId = 500100
  local isUnionFuncOpen = self.switchVM_.CheckFuncSwitch(unionFuncId)
  local isOpenUnionApplicationUI = Z.UIMgr:IsActive("union_application_popup")
  local isOpenUnionMainUI = Z.UIMgr:IsActive("union_main")
  local isUnionMember = self.unionVM_:IsUnionMember(cardData.charId)
  local playerUnionId = self.unionVM_:GetPlayerUnionId()
  local hasSetPositionPower = self.unionVM_:CheckPlayerPower(E.UnionPowerDef.SetMemberPosition)
  local hasKickOutPower = self.unionVM_:CheckPlayerPower(E.UnionPowerDef.KickOut)
  local unionId = cardData.unionData and cardData.unionData.unionid or 0
  self.units[E.IdCardFuncId.InviteUnion].Ref.UIComp:SetVisible(isUnionFuncOpen and isUnionMember == false and unionId == 0 and playerUnionId ~= 0 and isOpenUnionApplicationUI == false)
  self.units[E.IdCardFuncId.JoinUnion].Ref.UIComp:SetVisible(isUnionFuncOpen and isUnionMember == false and unionId ~= 0 and playerUnionId == 0)
  self.units[E.IdCardFuncId.UnionPosManage].Ref.UIComp:SetVisible(isUnionFuncOpen and isUnionMember == true and hasSetPositionPower and isOpenUnionMainUI)
  self.units[E.IdCardFuncId.KickUnion].Ref.UIComp:SetVisible(isUnionFuncOpen and isUnionMember == true and hasKickOutPower and isOpenUnionMainUI)
  self.units[E.IdCardFuncId.EnterLine].Ref.UIComp:SetVisible(false)
  Z.CoroUtil.create_coro_xpcall(function()
    local socialVm_ = Z.VMMgr.GetVM("social")
    local socialData_ = socialVm_.AsyncGetSocialData(0, Z.EntityMgr.PlayerEnt.CharId, self.cancelSource:CreateToken())
    local friendMainData = Z.DataMgr.Get("friend_main_data")
    local isFriend = friendMainData:IsFriendByCharId(cardData.charId)
    local isSceneLineFuncOpen = self.switchVM_.CheckFuncSwitch(E.FunctionID.SceneLine)
    local friendSceneId = cardData.basicData.sceneId
    local playerSceneId = socialData_.basicData.sceneId
    local friendLineId = cardData.sceneData.lineId
    local playerLineId = socialData_.sceneData.lineId
    self.units[E.IdCardFuncId.EnterLine].Ref.UIComp:SetVisible(isFriend and isSceneLineFuncOpen and friendSceneId == playerSceneId and friendLineId ~= playerLineId)
  end)()
  local isShowWarehouseBtn = false
  self.units[E.IdCardFuncId.InvteWarehouse].Ref.UIComp:SetVisible(isShowWarehouseBtn)
  local isRideFunction = self.switchVM_.CheckFuncSwitch(E.FunctionID.Vehicle)
  if self.viewData.rideId == nil or not isRideFunction then
    self.units[E.IdCardFuncId.ApplyForRide].Ref.UIComp:SetVisible(false)
    self.units[E.IdCardFuncId.InviteRide].Ref.UIComp:SetVisible(false)
  elseif self.viewData.rideId == 0 then
    self.units[E.IdCardFuncId.ApplyForRide].Ref.UIComp:SetVisible(false)
    local ridingId = Z.EntityMgr.PlayerEnt:GetLuaRidingId()
    if ridingId ~= 0 then
      local vehicleConfig = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(ridingId)
      if vehicleConfig then
        self.units[E.IdCardFuncId.InviteRide].Ref.UIComp:SetVisible(vehicleConfig.PropertyId[1] == vehicleDefine.VehiclePeopleNum.Multiple)
      else
        self.units[E.IdCardFuncId.InviteRide].Ref.UIComp:SetVisible(false)
      end
    else
      self.units[E.IdCardFuncId.InviteRide].Ref.UIComp:SetVisible(false)
    end
  else
    self.units[E.IdCardFuncId.InviteRide].Ref.UIComp:SetVisible(false)
    local vehicleConfig = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(self.viewData.rideId)
    if vehicleConfig then
      self.units[E.IdCardFuncId.ApplyForRide].Ref.UIComp:SetVisible(vehicleConfig.PropertyId[1] == vehicleDefine.VehiclePeopleNum.Multiple)
    else
      self.units[E.IdCardFuncId.ApplyForRide].Ref.UIComp:SetVisible(false)
    end
  end
  self.units[E.IdCardFuncId.Report].Ref.UIComp:SetVisible(self.reportVM_.IsReportOpen(true))
  self:AddAsyncClick(self.units[E.IdCardFuncId.JoinTeam].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.JoinTeam) then
      return
    end
    local teamData = Z.DataMgr.Get("team_data")
    local isApply = teamData:GetTeamApplyStatus(cardData.teamData.teamId)
    local isUnlock = self.teamMainVM_.CheckTargetCondition(cardData.teamData.teamTargetId, true)
    if not isUnlock then
      return
    end
    if isApply then
      Z.TipsVM.ShowTipsLang(1000610)
      return
    end
    if havTeam then
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("QuitJoinTeam"), function()
        Z.EventMgr:Dispatch(Z.ConstValue.Team.QuitAndApplyTeam, {
          cardData.teamData.teamId
        })
      end)
    else
      self.teamVM_.AsyncApplyJoinTeam({
        cardData.teamData.teamId
      }, self.cancelSource:CreateToken())
    end
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.InviteTeam].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.InviteTeam) then
      return
    end
    if not havTeam then
      self.teamVM_.AsyncCreatTeam(E.TeamTargetId.Costume, self.cancelSource:CreateToken())
    end
    self.teamVM_.AsyncInviteToTeam(self.cardId_, self.cancelSource:CreateToken())
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.RequestLeader].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.RequestLeader) then
      return
    end
    local teamData = Z.DataMgr.Get("team_data")
    local isApply = teamData:GetTeamSimpleTime("applyCaptain")
    if isApply ~= 0 then
      Z.TipsVM.ShowTipsLang(1000611)
      return
    end
    self.teamVM_.AsyncApplyBeLeader(self.cancelSource:CreateToken())
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.TransferLeader].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.TransferLeader) then
      return
    end
    self.teamVM_.AsyncTransferLeader(self.cardId_, self.cancelSource:CreateToken())
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.KickTeam].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.KickTeam) then
      return
    end
    self.teamVM_.AsyncTickOut(self.cardId_, self.cancelSource:CreateToken())
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.InviteAction].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.InviteAction) then
      return
    end
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    local functionId = Z.IsPCUI and E.FunctionID.ExpressionPC or E.FunctionID.Performace
    if not gotoFuncVM.CheckFuncCanUse(functionId) then
      return
    end
    local multActionVM = Z.VMMgr.GetVM("multaction")
    multActionVM.SetInviteId(self.cardId_)
    Z.EventMgr:Dispatch(Z.ConstValue.Idcard.InviteAction)
    gotoFuncVM.GoToFunc(functionId)
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.AddFriend].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.AddFriend) then
      return
    end
    Z.VMMgr.GetVM("friends_main").AsyncSendAddFriend(self.cardId_, E.FriendAddSource.EIdcard, self.cancelSource:CreateToken())
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.SendMsg].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.SendMsg) then
      return
    end
    Z.VMMgr.GetVM("friends_main").OpenPrivateChat(self.cardId_)
    self.vm_.CloseIdCardView()
  end)
  self:AddClick(self.units[E.IdCardFuncId.BlockPlayer].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.BlockPlayer) then
      return
    end
    local chatMainVM_ = self.chatMainVM_
    local token = self.cancelSource
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("FriendAddBlackTipsContent"), function()
      local ret = chatMainVM_.AsyncSetBlack(self.cardId_, true, token)
      if ret then
        Z.TipsVM.ShowTipsLang(130104)
      end
      self.vm_.CloseIdCardView()
    end, function()
      self.vm_.CloseIdCardView()
    end)
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.CancelBlock].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.CancelBlock) then
      return
    end
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("FriendRemoveBlackTipsContent"), function(cancelToken)
      local ret = self.chatMainVM_.AsyncSetBlack(self.cardId_, false, self.cancelSource)
      if ret then
        Z.TipsVM.ShowTipsLang(130105)
      end
      self.vm_.CloseIdCardView()
    end, function()
      self.vm_.CloseIdCardView()
    end)
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.InviteUnion].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.InviteUnion) then
      return
    end
    local myCharId = Z.ContainerMgr.CharSerialize.charBase.charId
    local myName = Z.ContainerMgr.CharSerialize.charBase.name
    local unionId = self.unionVM_:GetPlayerUnionId()
    local unionName = self.unionVM_:GetPlayerUnionName()
    self.unionVM_:AsyncInviteRequestInfo(myCharId, myName, unionId, unionName, cardData.charId, self.cancelSource:CreateToken())
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.JoinUnion].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.JoinUnion) then
      return
    end
    self.unionVM_:AsyncReqJoinUnions({
      cardData.unionData.unionid
    }, false, self.cancelSource:CreateToken())
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.UnionPosManage].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.UnionPosManage) then
      return
    end
    self.unionVM_:OpenUnionPositionManagePopup(E.UnionPositionPopupType.MemberAppoint, self.cancelSource:CreateToken())
    Z.TipsVM.ShowTips(1000596)
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.KickUnion].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.KickUnion) then
      return
    end
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("UnionKickOutMember"), function(cancelToken)
      local errCode = self.unionVM_:AsyncReqKickOut(cardData.unionData.unionid, {
        cardData.charId
      }, cancelToken)
      if errCode == 0 then
        self.vm_.CloseIdCardView()
      end
    end)
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.EnterLine].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.EnterLine) then
      return
    end
    local scenelineVM_ = Z.VMMgr.GetVM("sceneline")
    local success = scenelineVM_.AsyncReqSwitchSceneLineByCharId(cardData.charId)
    if success then
      self.vm_.CloseIdCardView()
    end
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.InvteWarehouse].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.InvteWarehouse) then
      return
    end
    local warehouseVm_ = Z.VMMgr.GetVM("warehouse")
    warehouseVm_.AsyncInviteToWarehouse(cardData.charId, self.cancelSource:CreateToken())
    self.vm_.CloseIdCardView()
  end)
  self:AddClick(self.uiBinder.btn_personal, function()
    if not self:checkCanSwitch() then
      return
    end
    local vm = Z.VMMgr.GetVM("personal_zone")
    vm.OpenPersonalZoneMain(cardData)
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.ApplyForRide].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.ApplyForRide) then
      return
    end
    local vehicleVm = Z.VMMgr.GetVM("vehicle")
    vehicleVm.AsyncApplyToRide(cardData.charId, self.cancelSource:CreateToken())
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.InviteRide].btn_idcard, function()
    if not self:checkCanSwitch(E.IdCardFuncId.InviteRide) then
      return
    end
    local vehicleVm = Z.VMMgr.GetVM("vehicle")
    vehicleVm.AsyncInviteToRide(cardData.charId, self.cancelSource:CreateToken())
    self.vm_.CloseIdCardView()
  end)
  self:AddAsyncClick(self.units[E.IdCardFuncId.Report].btn_idcard, function()
    local name = ""
    if cardData.basicData then
      name = cardData.basicData.name
    end
    self.reportVM_.OpenReportPop(reportDefine.ReportScene.PersonalInfo, name, cardData.charId)
  end)
end

function IdcardView:checkCanSwitch(idCardFuncId)
  return self.socialVM_.CheckCanSwitch(idCardFuncId, false)
end

function IdcardView:refreshFriendBtn(charId)
  local friendMainData = Z.DataMgr.Get("friend_main_data")
  local chatMainData = Z.DataMgr.Get("chat_main_data")
  local isInBlackList = chatMainData:IsInBlack(charId)
  local isFriend = friendMainData:IsFriendByCharId(charId)
  self.units[E.IdCardFuncId.AddFriend].Ref.UIComp:SetVisible(not isFriend)
  self.units[E.IdCardFuncId.BlockPlayer].Ref.UIComp:SetVisible(not isInBlackList)
  self.units[E.IdCardFuncId.SendMsg].Ref.UIComp:SetVisible(not isInBlackList)
  self.units[E.IdCardFuncId.CancelBlock].Ref.UIComp:SetVisible(isInBlackList)
end

function IdcardView:OnDeActive()
  self.uiBinder.node_press:StopCheck()
  self:releaseTmpTextures()
end

function IdcardView:OnRefresh()
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_idcard_figure, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_idcard_figure, false)
  self.cardId_ = self.viewData.cardId
  self:setPlayerInfo(self.viewData.cardData)
  self:setPhotoData()
end

function IdcardView:startAnimatedShow()
end

function IdcardView:startAnimatedHide()
end

function IdcardView:releaseTmpTextures()
  if self.viewData.photoData and self.viewData.photoData.textureId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.viewData.photoData.textureId)
    self.viewData.photoData.textureId = 0
  end
end

function IdcardView:setPhotoData()
  if self.viewData.photoData and self.viewData.photoData.textureId ~= 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_idcard_figure, true)
    self.uiBinder.rimg_idcard_figure:SetNativeTexture(self.viewData.photoData.textureId)
  end
end

function IdcardView:setUnionPhotoState()
  if self.viewData.photoData then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.scene_mask_node, true)
    self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.scene_mask_node, false)
  end
  self:AddClick(self.uiBinder.btn_abandonuploading, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("BusinessCardUploadTips"), function()
      self.vm_.CloseIdCardView()
    end)
  end)
  self:AddClick(self.uiBinder.btn_confirmupload, function()
    if self.viewData.photoData and self.viewData.photoData.textureId then
      self.cameraVM_.GetHeadOrBodyPhotoToken(self.viewData.photoData.textureId, self.viewData.photoData.snapType)
    end
  end)
  Z.EventMgr:Add(Z.ConstValue.Camera.HeadUpLoadSuccess, self.headUpLoadSuccess, self)
end

function IdcardView:headUpLoadSuccess()
  self.vm_.CloseIdCardView()
end

function IdcardView:refreshMedals(socialData)
  local medals = {}
  local medalCount = 0
  if socialData.personalZone and socialData.personalZone.medals then
    for i = 1, Z.Global.PersonalMedalLimit * Z.Global.PersonalzoneMedalRow[1] * Z.Global.PersonalzoneMedalRow[2] do
      if socialData.personalZone.medals[i] ~= nil and socialData.personalZone.medals[i] ~= 0 then
        medalCount = medalCount + 1
        medals[medalCount] = socialData.personalZone.medals[i]
        if medalCount == Z.Global.IdCardShowMedalCount then
          break
        end
      end
    end
  end
  local mgr = Z.TableMgr.GetTable("MedalTableMgr")
  for i = 1, Z.Global.IdCardShowMedalCount do
    local img = self.uiBinder.node_badge["rimg_badge_" .. i]
    if medals[i] == nil then
      self.uiBinder.node_badge.Ref:SetVisible(img, false)
    else
      self.uiBinder.node_badge.Ref:SetVisible(img, true)
      local config = mgr.GetRow(medals[i])
      if config then
        img:SetImage(config.Image)
      end
    end
  end
end

return IdcardView
