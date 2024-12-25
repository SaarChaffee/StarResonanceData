local UI = Z.UI
local super = require("ui.ui_view_base")
local Weekly_hunt_target_reward_popupView = class("Weekly_hunt_target_reward_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local targetLoopItem = require("ui.component.week_hunt.week_hunt_target_loop_item")

function Weekly_hunt_target_reward_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weekly_hunt_target_reward_popup")
  self.weeklyHuntVm_ = Z.VMMgr.GetVM("weekly_hunt")
  self.weeklyHuntData_ = Z.DataMgr.Get("weekly_hunt_data")
end

function Weekly_hunt_target_reward_popupView:initBinders()
  self.closeBtn_ = self.uiBinder.close_btn
  self.layerLab_ = self.uiBinder.lab_layer
  self.reawardLoopList_ = self.uiBinder.node_loop_item
  self.getAllBtn_ = self.uiBinder.btn_get
  self.sceneMask_ = self.uiBinder.scenemask
  self.surplusTimeLab_ = self.uiBinder.lab_time
  self.sceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
end

function Weekly_hunt_target_reward_popupView:initBtns()
  self:AddClick(self.closeBtn_, function()
    self.weeklyHuntVm_.CloseTargetView()
  end)
  self:AddAsyncClick(self.getAllBtn_.btn, function()
    self.weeklyHuntVm_.AsyncGetWeeklyTowerProcessAward(nil, true, self.cancelSource:CreateToken())
  end)
end

function Weekly_hunt_target_reward_popupView:initUi()
  self.reawardLoopView_ = loopListView.new(self, self.reawardLoopList_, targetLoopItem, "weekly_hunt_target_reward_item_tpl")
  local seasonData = Z.DataMgr.Get("season_data")
  local ruleRow = Z.TableMgr.GetRow("ClimbUpRuleTableMgr", seasonData.CurSeasonId)
  self.weeklyHuntData_:SetClimbUpRuleTableRow(ruleRow)
  if ruleRow then
    self.reawardLoopView_:Init(ruleRow.ProcessId)
    self.surplusTimeLab_.text = Lang("WeeklyhuntAwardResetTime", {
      str = Z.TimeTools.FormatToDHM(Z.TimeTools.GetTimeLeftInSpecifiedTime(ruleRow.TimerId))
    })
  end
  local currentId = Z.ContainerMgr.CharSerialize.weeklyTower.maxClimbUpId
  self.layerLab_.text = Lang("WeeklyHuntRewardLyaer", {
    val1 = currentId,
    val2 = self.weeklyHuntData_.MaxLaler
  })
end

function Weekly_hunt_target_reward_popupView:OnActive()
  self:initBinders()
  self:initBtns()
  self:initUi()
end

function Weekly_hunt_target_reward_popupView:OnDeActive()
  if self.reawardLoopView_ then
    self.reawardLoopView_:UnInit()
    self.reawardLoopView_ = nil
  end
end

function Weekly_hunt_target_reward_popupView:OnRefresh()
end

return Weekly_hunt_target_reward_popupView
