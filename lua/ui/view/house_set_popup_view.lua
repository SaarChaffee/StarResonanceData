local UI = Z.UI
local super = require("ui.ui_view_base")
local House_set_popupView = class("House_set_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local setLoopItem = require("ui.component.house.house_set_loop_item")
local friendLoopItem = require("ui.component.house.house_friends_loop_item")
local friendConditionLoopItem = require("ui.component.house.house_friends_condition_loop_item")
local switchLoopItem = require("ui.component.house.house_switch_loop_item")

function House_set_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_set_popup")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.friendsMainData_ = Z.DataMgr.Get("friend_main_data")
  self.memberState_ = E.HouseMemberState.Normal
end

function House_set_popupView:OnActive()
  self:initBinders()
  self:initData()
  self:initBtns()
  self:initUI()
  Z.EventMgr:Add(Z.ConstValue.Home.CohabitationInfoUpdate, self.OnCohabintantInfoUpdate, self)
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshInviteList, self.RefreshFriendData, self)
end

function House_set_popupView:OnDeActive()
  if self.setLoopListView_ then
    self.setLoopListView_:UnInit()
    self.setLoopListView_ = nil
  end
  if self.friendsLoopListView_ then
    self.friendsLoopListView_:UnInit()
    self.friendsLoopListView_ = nil
  end
  if self.switchLoopListView_ then
    self.switchLoopListView_:UnInit()
    self.switchLoopListView_ = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.Home.CohabitationInfoUpdate, self.OnCohabintantInfoUpdate, self)
  Z.EventMgr:Remove(Z.ConstValue.Home.RefreshInviteList, self.RefreshFriendData, self)
end

function House_set_popupView:OnRefresh()
end

function House_set_popupView:initBinders()
  self.closeBtn_ = self.uiBinder.btn_close
  self.editorBtn_ = self.uiBinder.btn_edit
  self.memberLoopList_ = self.uiBinder.scrollview_left
  self.switchLoopList_ = self.uiBinder.scrollview_switch
  self.friendLoopList_ = self.uiBinder.scrollview_friends
  self.friendConditionLab_ = self.uiBinder.lab_friend
  self.memberBtnNode_ = self.uiBinder.node_btn
  self.houseBtnNode_ = self.uiBinder.node_btn_house
  self.consentBtnNode_ = self.uiBinder.btn_consent
  self.rejectBtnNode_ = self.uiBinder.btn_reject
  self.transferBtnNode_ = self.uiBinder.btn_transfer_house
  self.quitCohabitantBtnNode_ = self.uiBinder.btn_quit_cohabitant
  self.quitCohabitantCancelBtnNode_ = self.uiBinder.btn_quit_cohabitant_cancel
  self.revocationBtn_ = self.uiBinder.btn_no_transfer
  self.promptLab_ = self.uiBinder.lab_prompt
  self.infoLab_ = self.uiBinder.lab_info
  self.timeLab_ = self.uiBinder.lab_time
  self.sceneMask_ = self.uiBinder.scene_mask
  self.sceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
end

function House_set_popupView:initData()
  self.homeId_ = self.houseData_:GetHomeId()
  self.selectingCharId_ = 0
  self.selectingData_ = nil
  self.selectingIndex_ = nil
  self.friendsData_ = {}
  self:RefreshFriendData()
end

function House_set_popupView:RefreshFriendData()
  Z.CoroUtil.create_coro_xpcall(function()
    self.houseVm_.AsyncGetInvitationList(self.cancelSource:CreateToken())
    self:initFriendData()
    self:OnSelectedLeftTab(self.selectingData_, self.selectingIndex_)
  end)()
end

function House_set_popupView:initUI()
  self.friendsLoopListView_ = loopListView.new(self, self.friendLoopList_)
  self.friendsLoopListView_:SetGetItemClassFunc(function(data)
    if data.isTitle then
      return friendConditionLoopItem
    end
    return friendLoopItem
  end)
  self.friendsLoopListView_:SetGetPrefabNameFunc(function(data)
    if data.isTitle then
      return "house_invited_conditions_title_tpl"
    end
    return "house_meet_conditions_list_tpl"
  end)
  self.friendsLoopListView_:Init({})
  self.switchLoopListView_ = loopListView.new(self, self.switchLoopList_, switchLoopItem, "house_item_switch_tpl")
  self.switchLoopListView_:Init({})
  self.setLoopListView_ = loopListView.new(self, self.memberLoopList_, setLoopItem, "house_set_tog_tpl")
  self.setLoopListView_:Init({
    {
      state = E.HouseSetOptionType.Set
    },
    {
      state = E.HouseSetOptionType.Member
    },
    {
      state = E.HouseSetOptionType.Apply
    }
  })
  self:refreshCohabitant(self.viewData)
  self.uiBinder.Ref:SetVisible(self.houseBtnNode_, false)
  self.uiBinder.Ref:SetVisible(self.memberBtnNode_, false)
  self.uiBinder.Ref:SetVisible(self.infoLab_, false)
  self.uiBinder.Ref:SetVisible(self.promptLab_, false)
  self.uiBinder.Ref:SetVisible(self.friendConditionLab_, false)
  self.uiBinder.Ref:SetVisible(self.editorBtn_.btn, self.houseData_:IsHomeOwner())
  self.friendConditionLab_.text = Lang("HouseInvitationConditionTips", {
    val = Z.GlobalHome.HouseLivetogetherFriendshipValue
  })
end

function House_set_popupView:initBtns()
  self:AddClick(self.closeBtn_, function()
    self.houseVm_.CloseHouseSetView()
  end)
  self:AddClick(self.editorBtn_.btn, function()
    self:openCheckInContentEditPopup()
  end)
  self:AddAsyncClick(self.consentBtnNode_.btn, function()
    if self.memberState_ == E.HouseMemberState.Transfer then
      if self.houseVm_.HasHouseCertificate() then
        self.houseVm_.OpenTransferOwnershipDialogWithCertificate(function()
          local jumpCfg = Z.GlobalHome.RecycleHouseNpcTrack
          local jumpPram = {
            jumpCfg[2],
            jumpCfg[3],
            jumpCfg[4]
          }
          local quickJumpVM = Z.VMMgr.GetVM("quick_jump")
          quickJumpVM.DoJumpByConfigParam(jumpCfg[1], jumpPram)
        end)
      else
        self.houseVm_.AsyncTransferOwnershipAgree(self.homeId_, true, self.cancelSource:CreateToken())
      end
    elseif self.memberState_ == E.HouseMemberState.Quit then
      self.houseVm_.AsyncQuitCohabitantAgree(self.selectingCharId_, self.homeId_, Z.ContainerMgr.CharSerialize.charId, self.cancelSource:CreateToken())
    elseif self.memberState_ == E.HouseMemberState.InitiativeQuit and self.isMyHouse_ then
      self.houseVm_.AsyncQuitCohabitantAgree(self.selectingCharId_, self.homeId_, Z.ContainerMgr.CharSerialize.charId, self.cancelSource:CreateToken())
    end
  end)
  self:AddAsyncClick(self.rejectBtnNode_.btn, function()
    self.houseVm_.AsyncTransferOwnershipAgree(self.homeId_, false, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.quitCohabitantBtnNode_.btn, function()
    self.houseVm_.OpenQuitCohabitDialog(function()
      if self.isMyHouse_ then
        self.houseVm_.AsyncQuitCohabitant(self.selectingCharId_, self.homeId_, Z.ContainerMgr.CharSerialize.charId, self.cancelSource:CreateToken())
      else
        self.houseVm_.AsyncQuitCohabitant(Z.ContainerMgr.CharSerialize.charId, self.homeId_, Z.ContainerMgr.CharSerialize.charId, self.cancelSource:CreateToken())
      end
    end, self.isMyHouse_)
  end)
  self:AddAsyncClick(self.quitCohabitantCancelBtnNode_.btn, function()
    if self.isMyHouse_ then
      self.houseVm_.AsyncQuitCohabitantCancel(self.selectingCharId_, self.homeId_, Z.ContainerMgr.CharSerialize.charId, self.cancelSource:CreateToken())
    else
      self.houseVm_.AsyncQuitCohabitantCancel(Z.ContainerMgr.CharSerialize.charId, self.homeId_, Z.ContainerMgr.CharSerialize.charId, self.cancelSource:CreateToken())
    end
  end)
  self:AddAsyncClick(self.transferBtnNode_.btn, function()
    local transferData = self.houseData_:GetHomeTransferData()
    local remainTime = transferData.lastTime + Z.GlobalHome.HouseTransferCD - Z.TimeTools.Now() / 1000
    if 0 < remainTime then
      self.houseVm_:OpenTransferOwnershipInCdDialog(Z.TimeFormatTools.FormatToDHMS(remainTime))
    else
      self.houseVm_.OpenTransferOwnershipDialog(function()
        self.houseVm_.AsyncTransferOwnership(self.homeId_, self.selectingCharId_, self.cancelSource:CreateToken())
      end)
    end
  end)
  self:AddAsyncClick(self.revocationBtn_.btn, function()
    self.houseVm_.AsyncTransferOwnershipCancel(self.homeId_, self.cancelSource:CreateToken())
  end)
end

function House_set_popupView:initFriendData()
  self.friendsData_ = {}
  local friendList = self.friendsMainData_:GetFriendCharList()
  local satisfyFriendList = {}
  local dissatifyFriendList = {}
  for _, charId in pairs(friendList) do
    if self.houseData_:GetHomeCohabitantInfoByCharId(charId) == nil then
      local friendlinessData = self.friendsMainData_:GetFriendLinessData(charId)
      if not friendlinessData then
        self.friendsMainVm_.UpdateFriendliness(charId, self.cancelSource:CreateToken())
        friendlinessData = self.friendsMainData_:GetFriendLinessData(charId)
      end
      local socialData = self.socialVm_.AsyncGetSocialDataTypeBasic(charId, self.cancelSource:CreateToken())
      local level = socialData.basicData.level
      if level >= Z.GlobalHome.HomeLandLevelLimit and friendlinessData.friendLinessLevel >= Z.GlobalHome.HouseLivetogetherFriendshipValue then
        table.insert(satisfyFriendList, charId)
      else
        table.insert(dissatifyFriendList, charId)
      end
    end
  end
  table.insert(self.friendsData_, {isTitle = true, isSatisfy = true})
  self:addFriendsData(satisfyFriendList, true)
  table.insert(self.friendsData_, {isTitle = true, isSatisfy = false})
  self:addFriendsData(dissatifyFriendList, false)
end

function House_set_popupView:addFriendsData(friendList, isSatisfy)
  for i = 1, #friendList, 2 do
    local charId1 = friendList[i]
    local data = {}
    if i + 1 <= #friendList then
      local charId2 = friendList[i + 1]
      data = {
        isTitle = false,
        isSatisfy = isSatisfy,
        friendInfo1 = self:getFriendInfoByCharId(charId1),
        friendInfo2 = self:getFriendInfoByCharId(charId2)
      }
    else
      data = {
        isTitle = false,
        isSatisfy = isSatisfy,
        friendInfo1 = self:getFriendInfoByCharId(charId1)
      }
    end
    table.insert(self.friendsData_, data)
  end
end

function House_set_popupView:getFriendInfoByCharId(charId)
  local data = {}
  local friendlinessData = self.friendsMainData_:GetFriendLinessData(charId)
  local friendData = self.friendsMainData_:GetFriendDataByCharId(charId)
  data.friendliness = friendlinessData.friendLinessLevel
  data.socialData = friendData:GetSocialData()
  data.hasCohabitant = friendData:GetHasCohabitant()
  local invitationTime = self.houseData_:GetInvitationTimeByCharId(charId)
  local now = Z.TimeTools.Now() / 1000
  data.isInvited = 0 < invitationTime and now < invitationTime + Z.GlobalHome.InviteLiveTogetherPassiveCD
  return data
end

function House_set_popupView:memberOption(charId)
  local cohabitantInfo = self.houseData_:GetHomeCohabitantInfoByCharId(charId)
  if not cohabitantInfo then
    logError("cohabitantInfo not found, charId={0}, owner={1}, me={2}", charId, self.houseData_:GetHomeOwnerCharId(), Z.ContainerMgr.CharSerialize.charBase.charId)
    self.memberState_ = E.HouseMemberState.Normal
    self:RefreshCohabitantBtns()
    return
  end
  local now = math.floor(Z.TimeTools.Now() / 1000)
  local transferData = self.houseData_:GetHomeTransferData()
  local isTransferState = transferData.charId == charId
  if isTransferState then
    local leftTime = transferData.time + Z.GlobalHome.HouseTransferApplyCountdown - now
    if 0 < leftTime then
      self.memberState_ = E.HouseMemberState.Transfer
      self.timeLab_.text = Z.TimeFormatTools.FormatToDHMS(leftTime)
    else
      self.memberState_ = E.HouseMemberState.Normal
    end
    if self.isMyHouse_ then
      self.infoLab_.text = Lang("HouseOwnerTransferInfo")
    else
      self.infoLab_.text = Lang("HouseTransferInfo")
    end
    self.promptLab_.text = Lang("HouseTransferPrompt")
  else
    local isQuitState = cohabitantInfo.quitCohabitant and cohabitantInfo.quitCohabitant.time ~= 0
    if isQuitState then
      local leftTime = cohabitantInfo.quitCohabitant.time + Z.GlobalHome.HouseDivorceCountdown - now
      if 0 < leftTime then
        self.timeLab_.text = Z.TimeFormatTools.FormatToDHMS(leftTime)
      end
      logGreen("charId={0}, isInitiativeQuit={1}", charId, cohabitantInfo.quitCohabitant.isInitiativeQuit)
      if cohabitantInfo.quitCohabitant.isInitiativeQuit then
        self.memberState_ = E.HouseMemberState.InitiativeQuit
        if self.isMyHouse_ then
          self.infoLab_.text = Lang("HouseQuitCohabitantInfo")
        else
          self.infoLab_.text = Lang("HouseInitiativeQuitCohabitantInfo")
        end
      else
        self.memberState_ = E.HouseMemberState.Quit
        if self.isMyHouse_ then
          self.infoLab_.text = Lang("HouseInitiativeQuitCohabitantInfo")
        else
          self.infoLab_.text = Lang("HouseQuitCohabitantInfo")
        end
      end
    else
      self.memberState_ = E.HouseMemberState.Normal
    end
    self.promptLab_.text = Lang("HouseQuitCohabitantPrompt")
  end
  logGreen("charId={0}, state={1}, isMyHouse_={3}, me={4}", self.selectingCharId_, self.memberState_, self.isMyHouse_, Z.ContainerMgr.CharSerialize.charId)
  self:RefreshCohabitantBtns()
end

function House_set_popupView:RefreshCohabitantBtns()
  local myCharId = Z.ContainerMgr.CharSerialize.charId
  self.uiBinder.Ref:SetVisible(self.houseBtnNode_, true)
  self.transferBtnNode_.Ref.UIComp:SetVisible(false)
  self.revocationBtn_.Ref.UIComp:SetVisible(self.isMyHouse_ and self.memberState_ == E.HouseMemberState.Transfer)
  self.quitCohabitantBtnNode_.Ref.UIComp:SetVisible(self.memberState_ == E.HouseMemberState.Normal and not self.houseData_:IsCharHomeOwner(self.selectingCharId_) and (myCharId == self.selectingCharId_ or self.isMyHouse_))
  self.quitCohabitantCancelBtnNode_.Ref.UIComp:SetVisible(self.memberState_ == E.HouseMemberState.InitiativeQuit and myCharId == self.selectingCharId_ or self.memberState_ == E.HouseMemberState.Quit and self.isMyHouse_)
  self.uiBinder.Ref:SetVisible(self.memberBtnNode_, self.memberState_ ~= E.HouseMemberState.Normal)
  self.consentBtnNode_.Ref.UIComp:SetVisible((self.memberState_ == E.HouseMemberState.Transfer or self.memberState_ == E.HouseMemberState.Quit) and myCharId == self.selectingCharId_ or self.isMyHouse_ and self.memberState_ == E.HouseMemberState.InitiativeQuit)
  self.rejectBtnNode_.Ref.UIComp:SetVisible(self.memberState_ == E.HouseMemberState.Transfer and myCharId == self.selectingCharId_)
  self.uiBinder.Ref:SetVisible(self.promptLab_, self.memberState_ ~= E.HouseMemberState.Normal and (self.isMyHouse_ or self.selectingCharId_ == myCharId))
  self.uiBinder.Ref:SetVisible(self.infoLab_, self.memberState_ ~= E.HouseMemberState.Normal and (self.isMyHouse_ or self.selectingCharId_ == myCharId))
  self.uiBinder.Ref:SetVisible(self.timeLab_, self.memberState_ ~= E.HouseMemberState.Normal and (self.isMyHouse_ or self.selectingCharId_ == myCharId))
end

function House_set_popupView:OnSelectedLeftTab(data, index)
  logGreen("OnSelectedLeftTab, index={0}", index)
  if data == nil then
    return
  end
  self.selectingData_ = data
  self.selectingIndex_ = index
  local isMemberOption = data.state == E.HouseSetOptionType.Member
  local isApplyOption = data.state == E.HouseSetOptionType.Apply
  local isSetOption = data.state == E.HouseSetOptionType.Set
  if isMemberOption then
    self.selectingCharId_ = data.charId
    self:memberOption(data.charId)
    self.switchLoopListView_:RefreshListView(self:getMemberSwitchListViewData(data.charId))
    self.friendsLoopListView_:RefreshListView({})
  else
    self.selectingCharId_ = 0
    self.uiBinder.Ref:SetVisible(self.promptLab_, false)
    self.uiBinder.Ref:SetVisible(self.infoLab_, false)
    self.uiBinder.Ref:SetVisible(self.memberBtnNode_, false)
    self.uiBinder.Ref:SetVisible(self.houseBtnNode_, false)
  end
  self.uiBinder.Ref:SetVisible(self.friendLoopList_, isApplyOption)
  self.uiBinder.Ref:SetVisible(self.friendConditionLab_, isApplyOption)
  if isApplyOption then
    self.friendsLoopListView_:RefreshListView(self.friendsData_)
    self.switchLoopListView_:RefreshListView({})
  end
  if isSetOption then
    self.switchLoopListView_:RefreshListView(self:getOwnerSwitchListViewData(data.charId))
  end
end

function House_set_popupView:getMemberSwitchListViewData(charId)
  local data = {}
  if self.houseData_:IsCharHomeOwner(charId) then
    return data
  end
  table.insert(data, self:getSwitchDataByType(E.HousePlayerLimitType.FurnitureEdit, charId))
  table.insert(data, self:getSwitchDataByType(E.HousePlayerLimitType.FurnitureMake, charId))
  return data
end

function House_set_popupView:getOwnerSwitchListViewData(charId)
  local data = {}
  table.insert(data, {
    limitType = E.HouseLimitType.WareHouse,
    value = self.houseData_:GetHomeLimit(E.HouseLimitType.WareHouse)
  })
  return data
end

function House_set_popupView:getSwitchDataByType(limitType, charId)
  local data = {}
  data.playerLimitType = limitType
  data.value = self.houseData_:GetHomeCharLimit(limitType, charId)
  data.charId = charId
  return data
end

function House_set_popupView:OnCohabintantInfoUpdate()
  local lastCount = #self.setLoopListView_:GetData()
  self:refreshCohabitant()
  if #self.setLoopListView_:GetData() ~= lastCount then
    self.setLoopListView_:ClearAllSelect()
    self.setLoopListView_:SetSelected(1)
  elseif self.selectingData_.state == E.HouseSetOptionType.Member then
    self:memberOption(self.selectingCharId_)
  end
end

function House_set_popupView:refreshCohabitant(viewData)
  self.isMyHouse_ = self.houseData_:IsHomeOwner()
  local dataList = {}
  local index = 0
  local selectIndexByCharId = 0
  if self.houseData_:IsHomeOwner() then
    table.insert(dataList, {
      state = E.HouseSetOptionType.Set
    })
    index = index + 1
  end
  local cohabitantInfo = self.houseData_:GetHomeCohabitantInfo()
  for charId, value in pairs(cohabitantInfo) do
    local data = {
      state = E.HouseSetOptionType.Member,
      charId = charId,
      cohabitantInfo = value
    }
    table.insert(dataList, data)
    index = index + 1
    if viewData and viewData.type == E.HouseSetOptionType.Member and charId == viewData.charId then
      selectIndexByCharId = index
    end
  end
  if self.houseData_:IsHomeOwner() then
    table.insert(dataList, {
      state = E.HouseSetOptionType.Apply
    })
  end
  self.setLoopListView_:RefreshListView(dataList, true)
  if 0 < selectIndexByCharId then
    self.setLoopListView_:SetSelected(selectIndexByCharId)
  elseif viewData and viewData.type == E.HouseSetOptionType.Apply then
    self.setLoopListView_:SetSelected(#dataList)
  elseif viewData and viewData.type == E.HouseSetOptionType.Set then
    self.setLoopListView_:SetSelected(1)
  end
end

function House_set_popupView:openCheckInContentEditPopup()
  local checkInContent = self.houseData_:GetHouseCheckInContent()
  local data = {
    title = Lang("HouseEditInvitation"),
    inputContent = checkInContent,
    onConfirm = function(value)
      local vm = Z.VMMgr.GetVM("screenword")
      vm.CheckScreenWord(value, E.TextCheckSceneType.TextCheckCommunityCheckInvite, self.cancelSource:CreateToken(), function()
        if value == "" or value == checkInContent then
          return
        end
        self.houseVm_.AsyncSetCheckInContent(value, self.cancelSource:CreateToken())
      end)
    end,
    stringLengthLimitNum = Z.GlobalHome.HouseWelcomeNotesLimit,
    inputDesc = ""
  }
  Z.TipsVM.OpenCommonPopupInput(data)
end

return House_set_popupView
