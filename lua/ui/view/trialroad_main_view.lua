local UI = Z.UI
local super = require("ui.ui_view_base")
local Trialroad_mainView = class("Trialroad_mainView", super)
local loopListView = require("ui.component.loop_list_view")
local trialroad_challenge_loop_item = require("ui.component.trialroad.trialroad_challenge_loop_item")
local trialroad_room_loop_item = require("ui.component.trialroad.trialroad_room_loop_item")
local trialRoadRed_ = require("rednode.trialroad_red")
local competencyAssessView = require("ui.view.competency_assessment_sub_view")

function Trialroad_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "trialroad_main")
  self.trialRoadVM_ = Z.VMMgr.GetVM("trialroad")
  self.trialRoadData_ = Z.DataMgr.Get("trialroad_data")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.curTrialRoadType_ = E.TrialRoadType.Power
  self.selectRoom_ = nil
  self.dungeonsTableMgr_ = Z.TableMgr.GetTable("DungeonsTableMgr")
  self.isQuantityEnough_ = false
  self.isRFEnough_ = false
  self.challengeTargetsUnits_ = {}
  self.challengeTargets_ = {}
  self.unitTokenDict_ = {}
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.capabilityAssessVM_ = Z.VMMgr.GetVM("capability_assessment")
  self.competencyAssessView_ = competencyAssessView.new()
end

function Trialroad_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  self:initBinder()
  self:initBtnEvent()
  self:bindEvent()
  self:initLoopListView()
  self:showOrHideTop(false)
end

function Trialroad_mainView:showOrHideTop(hide)
  self.uiBinder.node_title_close_new.Ref.UIComp:SetVisible(not hide)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_type, not hide)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_left, not hide)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_treasure, not hide)
end

function Trialroad_mainView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.TrialRoad.RefreshRoomTarget, self.refreshChallengeInfo, self)
  Z.EventMgr:Add(Z.ConstValue.CompetencyAssess.IsHideLeftView, self.showOrHideTop, self)
end

function Trialroad_mainView:unBindEvent()
  Z.EventMgr:Remove(Z.ConstValue.TrialRoad.RefreshRoomTarget, self.refreshChallengeInfo, self)
  Z.EventMgr:Remove(Z.ConstValue.CompetencyAssess.IsHideLeftView, self.showOrHideTop, self)
end

function Trialroad_mainView:initBinder()
  self.tog_Power_ = self.uiBinder.group_power.tog_item
  self.tog_Guard_ = self.uiBinder.group_guardisn.tog_item
  self.tog_Auxiliary_ = self.uiBinder.group_auxiliary.tog_item
  self.lab_title_ = self.uiBinder.node_right.lab_title
  self.lab_gs_ = self.uiBinder.node_right.lab_gs
  self.labTaskExplain_ = self.uiBinder.node_right.lab_content
  self.enterBtn_ = self.uiBinder.btn_go_copy
  self.levelLimit_ = self.uiBinder.img_level
  self.lab_level_limit = self.uiBinder.lab_level
  self.lab_suggest_ = self.uiBinder.lab_recommendations
  self.btnCompetencyAssess_ = self.uiBinder.btn_strength_assessment
end

function Trialroad_mainView:initBtnEvent()
  self.tog_Power_:AddListener(function(isOn)
    if isOn then
      self:setTrialRoadType(E.TrialRoadType.Power)
    end
  end)
  self.tog_Guard_:AddListener(function(isOn)
    if isOn then
      self:setTrialRoadType(E.TrialRoadType.Guard)
    end
  end)
  self.tog_Auxiliary_:AddListener(function(isOn)
    if isOn then
      self:setTrialRoadType(E.TrialRoadType.Auxiliary)
    end
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.trialRoadVM_.CloseView()
  end)
  self:AddClick(self.enterBtn_, function()
    self:onEnterBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_box, function()
    self.trialRoadVM_.OpenGradePopup()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self.helpsysVM_.OpenFullScreenTipsView(30046)
  end)
end

function Trialroad_mainView:initLoopListView()
  self.roomListView_ = loopListView.new(self, self.uiBinder.loop_item_left, trialroad_room_loop_item, "trialroad_picture_tpl")
  self.roomListView_:Init({})
end

function Trialroad_mainView:unInitLoopListView()
  self.roomListView_:UnInit()
  self.roomListView_ = nil
end

function Trialroad_mainView:setTrialRoadType(type)
  self.curTrialRoadType_ = type
  self.trialRoadVM_.SwitchUnrealSceneStyle(type)
  trialRoadRed_.RemoveAllTrialRoadRedItem()
  self:refreshRoomInfo()
end

function Trialroad_mainView:OnDeActive()
  self:unBindEvent()
  self:unInitLoopListView()
  self.trialRoadVM_.CloseMonsterTips()
  self.competencyAssessView_:DeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  for index, value in ipairs(self.challengeTargets_) do
    value:UnInit()
  end
  self.challengeTargets_ = {}
  self:ClearAllUnits()
  self.challengeTargetsUnits_ = {}
end

function Trialroad_mainView:OnRefresh()
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local weaponId = weaponVm.GetCurWeapon()
  local startType_ = E.TrialRoadType.Power
  if weaponId and 0 < weaponId then
    local weaponSystem = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(weaponId)
    if weaponSystem then
      startType_ = weaponSystem.Talent
    end
  end
  self:setTrialRoadType(startType_)
  self.tog_Power_:SetIsOnWithoutCallBack(startType_ == E.TrialRoadType.Power)
  self.tog_Auxiliary_:SetIsOnWithoutCallBack(startType_ == E.TrialRoadType.Auxiliary)
  self.tog_Guard_:SetIsOnWithoutCallBack(startType_ == E.TrialRoadType.Guard)
  self:refreshEnterBtnState()
  self:refreshRed()
end

function Trialroad_mainView:refreshRed()
  trialRoadRed_.LoadTrialRoadSelectItem(E.TrialRoadType.Auxiliary, self, self.uiBinder.group_auxiliary_trans)
  trialRoadRed_.LoadTrialRoadSelectItem(E.TrialRoadType.Power, self, self.uiBinder.group_power_trans)
  trialRoadRed_.LoadTrialRoadSelectItem(E.TrialRoadType.Guard, self, self.uiBinder.group_guardisn_trans)
  trialRoadRed_.LoadTrialRoadGradeBtnItem(self, self.uiBinder.img_treasure)
end

function Trialroad_mainView:OnSelectRoom(roomData)
  self.selectRoom_ = roomData
  self.trialRoadVM_.RefreshRoomTargetState(roomData.TrialRoadInfo.RoomId)
  self:refreshInfo()
  self:refreshEnterBtnState()
end

function Trialroad_mainView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Trialroad_mainView:refreshInfo()
  self.lab_title_.text = self.selectRoom_.TrialRoadInfo.RoomName
  local dungeonCfgData = self.dungeonsTableMgr_.GetRow(self.selectRoom_.TrialRoadInfo.DungeonId)
  if dungeonCfgData == nil then
    return
  end
  self:AddClick(self.btnCompetencyAssess_, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.CompetencyAssess)
    if not isOn then
      return
    end
    self.competencyAssessView_:Active({
      dungeonId = self.selectRoom_.TrialRoadInfo.DungeonId
    }, self.uiBinder.Trans)
  end)
  self.uiBinder.rimg_picture:SetImage(self.selectRoom_.TrialRoadInfo.BackGroundPic)
  self.uiBinder.img_type:SetImage(self.trialRoadData_.DictTypeIconPath[self.curTrialRoadType_])
  local _, suggest = self.capabilityAssessVM_.GetAllAttrValue(dungeonCfgData.AssessId)
  self.lab_suggest_.text = Lang("ReviewSuggestions") .. suggest
  self:refreshRF()
  self:refreshLevelLimit(dungeonCfgData)
  self.labTaskExplain_.text = dungeonCfgData.Content
  self:refreshChallengeInfo()
end

function Trialroad_mainView:refreshLevelLimit(dungeonCfg)
  local minlevel, maxlevel
  if #dungeonCfg.Condition > 0 then
    for _, v in pairs(dungeonCfg.Condition) do
      if v[1] == E.ConditionType.Level then
        minlevel = v[2]
        if 2 < #v then
          maxlevel = v[3]
        end
        break
      end
    end
  end
  local showLevel = minlevel ~= nil
  self.uiBinder.Ref:SetVisible(self.levelLimit_, showLevel)
  if showLevel then
    self.lab_level_limit.text = maxlevel and Lang("TrialRoadLevelLimmit2", {val1 = minlevel, val2 = maxlevel}) or Lang("TrialRoadLevelLimmit1", {val = minlevel})
  end
end

function Trialroad_mainView:checkWeaponSameRoad()
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local weaponId = weaponVm.GetCurWeapon()
  local isWeaponSameRoad_ = true
  if weaponId and 0 < weaponId then
    local weaponSystem = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(weaponId)
    if weaponSystem then
      isWeaponSameRoad_ = weaponSystem.Talent == self.selectRoom_.TrialRoadInfo.RoomType
    end
  end
  return isWeaponSameRoad_
end

function Trialroad_mainView:onEnterBtnClick()
  if not self.selectRoom_.IsLastFinish then
    Z.TipsVM.ShowTipsLang(3314)
    return
  end
  self.gsCheck_ = self.isRFEnough_
  self.weaponSameCheck_ = self:checkWeaponSameRoad()
  self.reqSync = true
  self:reqEnterRoom()
end

function Trialroad_mainView:reqEnterRoom()
  if not self.weaponSameCheck_ then
    self.weaponSameCheck_ = true
    self.reqSync = false
    self:changeWeaponDialog(Lang("TrialRoadEnterRoomSure"))
  elseif not self.selectRoom_.IsUnLockTime then
    Z.TipsVM.ShowTipsLang(15001011)
  elseif not self.isQuantityEnough_ then
    Z.TipsVM.ShowTipsLang(15001010)
  elseif not self.gsCheck_ then
    self.gsCheck_ = true
    self.reqSync = false
    self:EnterRoomCheckDialog(Lang("ConfirmationEquipGS"))
  elseif self.reqSync then
    self:reqEnterRoomAsync()
  else
    self:reqEnterRoomNoAsync()
  end
end

function Trialroad_mainView:refreshConsumeInfo()
  local isSp, itemId, itemNum = self.trialRoadVM_.IsSpecialCopy(self.selectRoom_.TrialRoadInfo.DungeonId)
  if isSp then
    self.uiBinder.Ref:SetVisible(self.propGroup_.Ref, true)
    local itemFuncTable = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId, true)
    if itemFuncTable then
      local itemsVM = Z.VMMgr.GetVM("items")
      self.propIconImg_:SetImage(itemsVM.GetItemIcon(itemId))
    end
    local num = Z.VMMgr.GetVM("items").GetItemTotalCount(itemId)
    if itemNum <= num then
      return true
    else
      return false
    end
  else
    return true
  end
end

function Trialroad_mainView:refreshEnterBtnState()
  self.isQuantityEnough_ = self:refreshConsumeInfo()
  local isOn = true
  if not self.selectRoom_.IsLastFinish or not self.isQuantityEnough_ then
    isOn = false
  else
    isOn = true
  end
  self.enterBtn_.IsDisabled = not isOn
end

function Trialroad_mainView:refreshRF()
  local dungenonCfg_ = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.selectRoom_.TrialRoadInfo.DungeonId)
  local RFLimit_ = dungenonCfg_.RecommendFightValue
  local param = {val = RFLimit_}
  self.lab_gs_.text = Lang("GSSuggest", param)
  self:checkRF(RFLimit_)
end

function Trialroad_mainView:checkRF(value)
  Z.CoroUtil.create_coro_xpcall(function()
    local socialData = self.socialVm_.AsyncGetSocialData(0, Z.EntityMgr.PlayerEnt.CharId, self.cancelSource:CreateToken())
    if socialData.userAttrData.fightPoint and socialData.userAttrData.fightPoint < value then
      self.isRFEnough_ = false
    else
      self.isRFEnough_ = true
    end
  end)()
end

function Trialroad_mainView:reqEnterRoomAsync()
  local token = self.cancelSource:CreateToken()
  Z.CoroUtil.coro_xpcall(function()
    self.trialRoadVM_.AsyncEnterTrialRoad(self.selectRoom_.TrialRoadInfo.RoomId, token)
  end)
end

function Trialroad_mainView:reqEnterRoomNoAsync(desc, checkEnd)
  self.trialRoadVM_.AsyncEnterTrialRoad(self.selectRoom_.TrialRoadInfo.RoomId, self.cancelSource:CreateToken())
end

function Trialroad_mainView:EnterRoomCheckDialog(desc)
  Z.DialogViewDataMgr:OpenNormalDialog(desc, function()
    self:reqEnterRoom()
  end)
end

function Trialroad_mainView:changeWeaponDialog(desc)
  Z.DialogViewDataMgr:OpenNormalDialog(desc, function()
    local professionVm = Z.VMMgr.GetVM("profession")
    professionVm.OpenProfessionSelectView()
  end)
end

function Trialroad_mainView:refreshMonsterInfo()
  local itemList = self.selectRoom_.TrialRoadInfo.TargetMonster
  if itemList == nil or #itemList < 1 then
    return
  end
  self.monsterListView_:RefreshListView(itemList)
end

function Trialroad_mainView:OnMonsterInfoBtnClick()
  self.trialRoadVM_.OpenMonsterTips(self.selectRoom_.TrialRoadInfo.TargetMonster, self.selectRoom_.TrialRoadInfo.GsLimit)
end

function Trialroad_mainView:RequestGetTargetReward(targetId)
  local success_ = self.trialRoadVM_.ReqestGetTargetReward(self.selectRoom_.TrialRoadInfo.RoomId, targetId, self.cancelSource:CreateToken())
  if success_ then
    self.roomListView_:RefreshAllShownItem()
  end
end

function Trialroad_mainView:refreshChallengeInfo()
  local path = self.uiBinder.season_main_pcd:GetString("trialroadItem")
  local root = self.uiBinder.trial_item_root
  for _, token in pairs(self.unitTokenDict_) do
    Z.CancelSource.ReleaseToken(token)
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in pairs(self.selectRoom_.ListRoomTarget) do
      local unitName = "trialroad_challenge_" .. index
      local token = self.cancelSource:CreateToken()
      self.unitTokenDict_[unitName] = token
      if self.challengeTargetsUnits_[index] == nil then
        self.challengeTargetsUnits_[index] = self:AsyncLoadUiUnit(path, unitName, root, token)
      end
      local unit = self.challengeTargetsUnits_[index]
      if self.challengeTargets_[index] == nil then
        self.challengeTargets_[index] = trialroad_challenge_loop_item.new(self)
      else
        self.challengeTargets_[index]:Recycle()
      end
      self.challengeTargets_[index]:Init(value, unit)
    end
  end)()
end

function Trialroad_mainView:refreshRoomInfo()
  local roomList_ = self.trialRoadData_:GetTrialRoadRoomDataListByType(self.curTrialRoadType_)
  local dataList_ = {}
  local index = 0
  local startIndex = index
  local keys = {}
  for k in pairs(roomList_) do
    table.insert(keys, k)
  end
  table.sort(keys)
  self.ShowUnLockTime_ = nil
  for _, k in ipairs(keys) do
    table.insert(dataList_, roomList_[k])
    if not roomList_[k].IsUnLockTime and self.ShowUnLockTime_ == nil then
      self.ShowUnLockTime_ = roomList_[k].TrialRoadInfo.RoomId
    end
    index = index + 1
    if roomList_[k].IsUnLockTime and roomList_[k].IsLastFinish then
      startIndex = index
    end
  end
  self.roomListView_:RefreshListView(dataList_, true)
  self.roomListView_:MovePanelToItemIndex(startIndex - 1)
  self.roomListView_:ClearAllSelect()
  self.roomListView_:SetSelected(startIndex)
end

function Trialroad_mainView:StartTrialroadTimer(func, duration, loop)
  return self.timerMgr:StartTimer(func, duration, loop)
end

function Trialroad_mainView:StopTrialroadTimer(timer)
  return self.timerMgr:StopTimer(timer)
end

return Trialroad_mainView
