local UI = Z.UI
local super = require("ui.ui_view_base")
local House_mainView = class("House_mainView", super)
local PlayerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local currency_item_list = require("ui.component.currency.currency_item_list")
local REPORTDEFINE = require("ui.model.report_define")

function House_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_main")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.homeEditorVm_ = Z.VMMgr.GetVM("home_editor")
  self.commonVm_ = Z.VMMgr.GetVM("common")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.helpSysVM_ = Z.VMMgr.GetVM("helpsys")
  self.gotofuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function House_mainView:initUiBinders()
  self.closeBtn_ = self.uiBinder.binder_function_close.btn
  self.enterHouse_ = self.uiBinder.btn_enter_house.btn
  self.houseLevelLab_ = self.uiBinder.lab_level_num
  self.houseLevelBtnDes_ = self.uiBinder.btn_house_level.lab_normal
  self.boardBtn_ = self.uiBinder.btn_bulletin_board
  self.applyListBtn_ = self.uiBinder.btn_requisition_list
  self.furnitureBtn_ = self.uiBinder.btn_furniture_guide
  self.houseNameLab_ = self.uiBinder.lab_name
  self.houseIntroducLab_ = self.uiBinder.lab_output
  self.askBtn_ = self.uiBinder.btn_ask
  self.inputBtn_ = self.uiBinder.btn_input
  self.cohabitationLab_ = self.uiBinder.lab_cohabitation
  self.titleLab_ = self.uiBinder.lab_title
  self.editBtn_ = self.uiBinder.btn_edit
  self.reportBtn_ = self.uiBinder.btn_report
  self.fabricateNode_ = self.uiBinder.node_fabricate
  self.headNodes_ = {
    self.uiBinder.node_head_1,
    self.uiBinder.node_head_2,
    self.uiBinder.node_head_3,
    self.uiBinder.node_head_4,
    self.uiBinder.node_head_5
  }
  self.materialNode_ = self.uiBinder.node_material
  self.hoursOutputNode_ = self.uiBinder.node_hours_output
  self.weekGetNode_ = self.uiBinder.node_week_get
  self.farmNode_ = self.uiBinder.node_farm
  self.flowerNode_ = self.uiBinder.node_flower
end

function House_mainView:initUi()
  self.houseLevelLab_.text = self.houseData_:GetHouseLevel()
  self:RefreshExp()
  self.houseNameLab_.text = self.houseData_:GetHouseName() or Lang("DefaultHouseName")
  self.uiBinder.Ref:SetVisible(self.editBtn_, self.houseData_:IsHomeOwner())
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_edit, self.houseData_:IsHomeOwner())
  self.uiBinder.Ref:SetVisible(self.reportBtn_, not self.houseData_:IsHomeOwner())
  local isInviteUnlock = self.gotofuncVM_.CheckFuncCanUse(E.FunctionID.HomeLiveTogether, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_invite, isInviteUnlock)
  self.uiBinder.Ref:SetVisible(self.applyListBtn_, isInviteUnlock)
  local introduc = self.houseData_:GetHouseIntroduc()
  if introduc then
    self.houseIntroducLab_.text = introduc
  else
    self.houseIntroducLab_.text = self.houseData_:IsHomeOwner() and Lang("PleaseClickEnter") or ""
  end
  self.commonVm_.SetLabText(self.titleLab_, E.FunctionID.House)
  local stateNoneCount = self.houseData_:GetHomeBuildFurnitureCount(E.BuildFurnitureState.BuildFurnitureStateNone)
  local stateBuildingCount = self.houseData_:GetHomeBuildFurnitureCount(E.BuildFurnitureState.BuildFurnitureStateBuilding)
  local stateSucessCount = self.houseData_:GetHomeBuildFurnitureCount(E.BuildFurnitureState.BuildFurnitureStateSuccess)
  self.fabricateNode_.lab_idle.text = Lang("HouseFurnitureStateNone", {val = stateNoneCount})
  self.fabricateNode_.lab_production.text = Lang("HouseFurnitureStateBuilding", {val = stateBuildingCount})
  self.fabricateNode_.lab_completed.text = Lang("HouseFurnitureStateSuccess", {val = stateSucessCount})
  self.materialNode_.lab_info.text = ""
  self.materialNode_.lab_num.text = ""
  self.hoursOutputNode_.lab_info.text = ""
  self.hoursOutputNode_.lab_num.text = ""
  self.weekGetNode_.lab_info.text = ""
  self.weekGetNode_.lab_num.text = ""
  self:RefreshCohabitant()
  self:RefreshCleaniness()
  self:RefreshHouseQuest()
  self:refreshFarm()
end

function House_mainView:RefreshCleaniness()
  local cleaniness = self.houseData_:GetHouseCleanValue()
  local maxCleaniness = Z.GlobalHome.HomeCleanInitial
  local cleaninessLevel = self.houseData_:GetHouseCleanLevel()
  self.uiBinder.node_clean.lab_function_name.text = Lang("HouseCleanlinessLevel" .. cleaninessLevel)
  self.uiBinder.node_clean.lab_clean.text = Lang("season_achievement_progress", {val1 = cleaniness, val2 = maxCleaniness})
end

function House_mainView:refreshFarm()
  self.farmNode_.lab_farm.text = Lang("Leisure") .. self.houseData_:GetEmptyLand()
  self.flowerNode_.lab_flower.text = Lang("CanPick") .. self.houseData_:GetFlowerNum()
end

function House_mainView:RefreshHouseQuest()
  local taskInfo = self.houseData_:GetTaskInfo()
  if not taskInfo then
    return
  end
  if taskInfo.curLeftTimes == 0 then
    self.uiBinder.node_task.lab_quest.text = Lang("Complete")
  else
    self.uiBinder.node_task.lab_quest.text = Lang("NotFinish")
  end
end

function House_mainView:RefreshCohabitant()
  self.cohabitationLab_.text = Lang("HouseCohabitantInfo", {
    val1 = self.houseData_:GetHomeCohabitantCount(),
    val2 = Z.GlobalHome.HouseLivetogetherCount + 1
  })
  for i = 1, #self.headNodes_ do
    local headNode = self.headNodes_[i]
    headNode.Ref:SetVisible(headNode.img_mask, false)
    headNode.Ref:SetVisible(headNode.btn_add, true)
  end
  local count = 0
  for charId, playerInfo in pairs(self.houseData_:GetHomeCohabitantInfo()) do
    count = count + 1
    local headNode = self.headNodes_[count]
    headNode.Ref:SetVisible(headNode.img_mask, true)
    headNode.Ref:SetVisible(headNode.btn_add, false)
    if playerInfo.communityChar == nil then
      Z.CoroUtil.create_coro_xpcall(function()
        local socialData = self.socialVm_.AsyncGetHeadAndHeadFrameInfo(charId, self.cancelSource:CreateToken())
        PlayerPortraitHgr.InsertNewPortraitBySocialData(self.headNodes_[count], socialData, nil, self.cancelSource:CreateToken())
      end)()
    else
      PlayerPortraitHgr.InsertNewPortraitBySocialData(headNode, playerInfo.communityChar, nil, self.cancelSource:CreateToken())
    end
  end
end

function House_mainView:initBtns()
  self:AddClick(self.closeBtn_, function()
    self.houseVm_.CloseHouseMainView()
  end)
  self:AddAsyncClick(self.enterHouse_, function()
    self.houseVm_.AsyncEnterCommunity(self.cancelSource:CreateToken())
  end, function()
    self.houseData_.IsEntering = false
  end)
  self:AddClick(self.askBtn_, function()
    self.helpSysVM_.OpenFullScreenTipsView(40005)
  end)
  self:AddClick(self.boardBtn_, function()
    self.houseVm_.OpenHouseBulletinBoardView()
  end)
  self:AddClick(self.furnitureBtn_, function()
    self.houseVm_.OpenHouseFurnitureGuideView()
  end)
  self:AddClick(self.applyListBtn_, function()
    self.houseVm_.OpenHouseApplyView()
  end)
  self:AddClick(self.editBtn_, function()
    self:openHouseNameEditPopup()
  end)
  self:AddClick(self.inputBtn_, function()
    if self.houseData_:IsHomeOwner() then
      self:openHouseIntroducEditPopup()
    end
  end)
  self:AddClick(self.reportBtn_, function()
    if not self.houseData_:IsHomeOwner() then
      local homeOwnerId = self.houseData_:GetHomeOwnerCharId()
      local info = self.houseData_:GetHomeCohabitantInfoByCharId(homeOwnerId)
      if info ~= nil then
        local name = info.communityChar.basicData.name
        local reportVm = Z.VMMgr.GetVM("report")
        reportVm.OpenReportPop(REPORTDEFINE.ReportScene.Home, name, 0, {
          homeId = self.viewData.homeId
        })
      end
    end
  end)
  for k, v in ipairs(self.headNodes_) do
    self:AddClick(v.btn, function()
      local charId = self.houseData_:GetHomeCohabitantCharIdByIndex(k)
      local data = {
        charId = charId,
        type = E.HouseSetOptionType.Member
      }
      self.houseVm_.OpenHouseSetView(data)
    end)
    self:AddClick(v.btn_add, function()
      local data = {
        type = E.HouseSetOptionType.Apply
      }
      self.houseVm_.OpenHouseSetView(data)
    end)
  end
  self:AddClick(self.uiBinder.btn_house_level.btn, function()
    self.houseVm_.OpenHouseLevelView()
  end)
end

function House_mainView:initData()
  Z.CoroUtil.create_coro_xpcall(function()
    self.houseVm_.AsyncGetHomeLandBaseInfo(self.cancelSource:CreateToken())
  end)()
end

function House_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initUiBinders()
  self:initBtns()
  self:initData()
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, Z.SystemItem.HomeShopCurrencyDisplay)
  Z.EventMgr:Add(Z.ConstValue.Home.BaseInfoUpdate, self.OnRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.House.HouseLevelChange, self.OnHouseLevelChange, self)
  Z.EventMgr:Add(Z.ConstValue.House.HouseCleaninessChange, self.OnHouseCleaninessChange, self)
  Z.EventMgr:Add(Z.ConstValue.Home.CohabitationInfoUpdate, self.RefreshCohabitant, self)
  Z.EventMgr:Add(Z.ConstValue.House.HouseQuestChanged, self.OnHouseQuestChanged, self)
  Z.EventMgr:Add(Z.ConstValue.House.HouseQuestFinished, self.OnHouseQuestChanged, self)
  Z.EventMgr:Add(Z.ConstValue.House.HouseExpChange, self.HouseExpChange, self)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot_level, Z.RedPointMgr.GetRedState(E.RedType.HouseLevelRed))
end

function House_mainView:OnHouseLevelChange()
  self.houseLevelLab_.text = self.houseData_:GetHouseLevel()
  self:RefreshExp()
end

function House_mainView:HouseExpChange()
  self:RefreshExp()
end

function House_mainView:RefreshExp()
  local curLevel = self.houseData_:GetHouseLevel()
  local exp = self.houseData_:GetHouseExp()
  local homeLevelTableRow = Z.TableMgr.GetTable("HomeLevelTableMgr").GetRow(curLevel, true)
  if not homeLevelTableRow then
    return
  end
  local isMaxLevel = curLevel == self.houseData_:GetHouseMaxLevel()
  if isMaxLevel then
    self.uiBinder.lab_progress_num.text = Lang("HomeLevelMax")
    self.uiBinder.img_progress.fillAmount = 1
  else
    self.uiBinder.lab_progress_num.text = string.zconcat(exp, "/", homeLevelTableRow.Exp)
    self.uiBinder.img_progress.fillAmount = exp / homeLevelTableRow.Exp
  end
end

function House_mainView:OnHouseCleaninessChange()
  self:RefreshCleaniness()
end

function House_mainView:OnHouseQuestChanged()
  self:RefreshHouseQuest()
end

function House_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.EventMgr:RemoveObjAll(self)
  self.currencyItemList_:UnInit()
end

function House_mainView:OnRefresh()
  self.homeBaseInfo_ = self.houseData_:GetHomelandBaseInfo()
  self:initUi()
end

function House_mainView:openHouseNameEditPopup()
  local homeName = self.houseData_:GetHouseName()
  local data = {
    title = Lang("HouseEditName"),
    inputContent = homeName,
    onConfirm = function(value)
      if value == "" or value == homeName then
        return
      end
      self.houseVm_.AsyncSetHouseName(value, self.cancelSource:CreateToken())
    end,
    stringLengthLimitNum = Z.GlobalHome.HouseNameLimit,
    inputDesc = ""
  }
  Z.TipsVM.OpenCommonPopupInput(data)
end

function House_mainView:openHouseIntroducEditPopup()
  local homeIntroduc = self.houseData_:GetHouseIntroduc()
  local data = {
    title = Lang("HouseEditIntroduc"),
    inputContent = homeIntroduc,
    onConfirm = function(value)
      if value == "" or value == homeIntroduc then
        return
      end
      self.houseVm_.AsyncSetHouseIntroduc(value, self.cancelSource:CreateToken())
    end,
    stringLengthLimitNum = Z.GlobalHome.HouseIntroLimit,
    inputDesc = "",
    isMultiLine = true
  }
  Z.TipsVM.OpenCommonPopupInput(data)
end

return House_mainView
