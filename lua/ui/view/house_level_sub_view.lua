local UI = Z.UI
local super = require("ui.ui_view_base")
local House_level_subView = class("House_level_subView", super)
local loopListView = require("ui.component.loop_list_view")
local houseLevelAwardLoopItem = require("ui.component.house.house_level_reward_loop_item")
local houseLevelLoopItem = require("ui.component.house.house_level_loop_item")
local currency_item_list = require("ui.component.currency.currency_item_list")

function House_level_subView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_level_window")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.awardprevVm_ = Z.VMMgr.GetVM("awardpreview")
end

function House_level_subView:OnActive()
  self:bindBtnClick()
  self:initViewList()
  Z.EventMgr:Add(Z.ConstValue.House.HouseExpChange, self.OnHouseExpChange, self)
  Z.EventMgr:Add(Z.ConstValue.House.HouseCleaninessChange, self.OnsHouseCleaninessChange, self)
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, Z.SystemItem.HomeShopCurrencyDisplay)
end

function House_level_subView:OnDeActive()
  self.loopLevelListView_:UnInit()
  self.loopLevelListView_ = nil
  self.rewardListView_:UnInit()
  self.rewardListView_ = nil
  Z.EventMgr:RemoveObjAll(self)
  self.currencyItemList_:UnInit()
end

function House_level_subView:OnRefresh()
  local levelDatas = self.houseData_:GetAllLevelData()
  self.loopLevelListView_:RefreshListView(levelDatas)
  local curLevel = self.houseData_:GetHouseLevel()
  if curLevel < 1 then
    curLevel = 1
  end
  self:SetIsCenter(curLevel)
end

function House_level_subView:OnHouseExpChange()
  self:refreshCondition()
  self:refreshBtnState()
end

function House_level_subView:OnsHouseCleaninessChange()
  self:refreshCondition()
  self:refreshBtnState()
end

function House_level_subView:RefreshByLevel(level)
  self:ClearAllUnits()
  self.curLevel = level
  local curLevel = self.houseData_:GetHouseLevel()
  local unlocked = curLevel >= self.curLevel
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_level_upgrade, not unlocked)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_upgrade_award, self.curLevel ~= 1 and not unlocked)
  self:refreshLevelReward()
  self:refreshCondition()
  self:refreshAwards()
  self:refreshBtnState()
end

function House_level_subView:refreshLevelReward()
  local curLevel = self.houseData_:GetHouseLevel()
  local unlocked = curLevel >= self.curLevel
  local homeLevelTableRow = Z.TableMgr.GetTable("HomeLevelTableMgr").GetRow(self.curLevel)
  if not homeLevelTableRow then
    return
  end
  local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "house_unlock_item_tpl")
  for k, v in ipairs(homeLevelTableRow.LvUpDesc) do
    Z.CoroUtil.create_coro_xpcall(function()
      local uiUnit_ = self:AsyncLoadUiUnit(path, "reward" .. k, self.uiBinder.layout_reward, self.cancelSource:CreateToken())
      if not uiUnit_ then
        return
      end
      uiUnit_.lab_info.text = v
      uiUnit_.Ref:SetVisible(uiUnit_.img_finished, unlocked)
      uiUnit_.Ref:SetVisible(uiUnit_.img_lcok, not unlocked)
    end)()
  end
end

function House_level_subView:refreshCondition()
  local homeLevelTableRow = Z.TableMgr.GetTable("HomeLevelTableMgr").GetRow(self.curLevel)
  if not homeLevelTableRow then
    return
  end
  local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "house_upgrade_item_tpl")
  for k, v in ipairs(homeLevelTableRow.Condition) do
    Z.CoroUtil.create_coro_xpcall(function()
      local uiUnit_ = self:AsyncLoadUiUnit(path, "condition" .. k, self.uiBinder.layout_upgrade_condition, self.cancelSource:CreateToken())
      if not uiUnit_ then
        return
      end
      local IsUnlock, _, _, _, _, showPurview = Z.ConditionHelper.GetSingleConditionDesc(v[1], v[2])
      uiUnit_.lab_info.text = showPurview
      uiUnit_.Ref:SetVisible(uiUnit_.img_unlocked, IsUnlock)
      uiUnit_.lab_info.color = IsUnlock and Color.New(1.1022222222222222, 1.0755555555555556, 0.5955555555555555, 1) or Color.New(1, 1, 1, 1)
    end)()
  end
  if self.curLevel - 1 == 0 then
    return
  end
  local lastHomeLevelTableRow = Z.TableMgr.GetTable("HomeLevelTableMgr").GetRow(self.curLevel - 1)
  if not lastHomeLevelTableRow then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local uiUnit_ = self:AsyncLoadUiUnit(path, "condition_level", self.uiBinder.layout_upgrade_condition, self.cancelSource:CreateToken())
    if not uiUnit_ then
      return
    end
    uiUnit_.lab_info.text = Lang("HouselvUpNeedExp", {
      val = lastHomeLevelTableRow.Exp
    })
    uiUnit_.Ref:SetVisible(uiUnit_.img_unlocked, self.houseData_:GetHouseExp() >= lastHomeLevelTableRow.Exp)
    uiUnit_.lab_info.color = self.houseData_:GetHouseExp() >= lastHomeLevelTableRow.Exp and Color.New(1.1022222222222222, 1.0755555555555556, 0.5955555555555555, 1) or Color.New(1, 1, 1, 1)
  end)()
end

function House_level_subView:refreshAwards()
  if self.curLevel == 1 then
    self.rewardListView_:RefreshListView({})
    return
  end
  local homeLevelTableRow = Z.TableMgr.GetTable("HomeLevelTableMgr").GetRow(self.curLevel - 1)
  if not homeLevelTableRow then
    return
  end
  local mailTableRow = Z.TableMgr.GetTable("MailTableMgr").GetRow(homeLevelTableRow.Mailid)
  if mailTableRow == nil then
    return
  end
  local awardID = mailTableRow.AwardId
  local awardList = self.awardprevVm_.GetAllAwardPreListByIds(awardID)
  self.rewardListView_:RefreshListView(awardList)
end

function House_level_subView:refreshBtnState()
  local curLevel = self.houseData_:GetHouseLevel()
  local unlocked = curLevel >= self.curLevel
  local canUnlock = curLevel + 1 == self.curLevel
  local isMaxLevel = self.curLevel == self.houseData_:GetHouseMaxLevel()
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_max_level, isMaxLevel and unlocked)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_house_level, not unlocked)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_unlocked, unlocked and not isMaxLevel)
  self.uiBinder.btn_house_level.enabled = canUnlock
  self.uiBinder.btn_house_level.IsDisabled = not canUnlock
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, self.houseVm_.CheckHouseCanUpGrade(self.curLevel) and self.houseData_:IsHomeOwner())
end

function House_level_subView:initViewList()
  self.loopLevelListView_ = loopListView.new(self, self.uiBinder.scrollview_level_item, houseLevelLoopItem, "house_level_item_tpl")
  self.rewardListView_ = loopListView.new(self, self.uiBinder.scrollview_reward_item, houseLevelAwardLoopItem, "com_item_square_1_8")
  self.loopLevelListView_:Init({})
  self.rewardListView_:Init({})
end

function House_level_subView:SetIsCenter(index)
  self.uiBinder.house_center_scroller:SetCenter(index - 1)
end

function House_level_subView:bindBtnClick()
  self:AddClick(self.uiBinder.btn_close, function()
    self.houseVm_.CloseHouseLevelView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_house_level, function()
    local homeLevelTableRow = Z.TableMgr.GetTable("HomeLevelTableMgr").GetRow(self.curLevel)
    if not homeLevelTableRow then
      return
    end
    local isConditionMet = Z.ConditionHelper.CheckCondition(homeLevelTableRow.Condition, true)
    local lastHomeLevelTableRow = Z.TableMgr.GetTable("HomeLevelTableMgr").GetRow(self.curLevel - 1)
    if not lastHomeLevelTableRow then
      return
    end
    if isConditionMet and self.houseData_:GetHouseExp() >= lastHomeLevelTableRow.Exp then
      self.houseVm_.AsyncUpgradeHouse(self.curLevel - 1, self.cancelSource:CreateToken())
    end
  end)
end

return House_level_subView
