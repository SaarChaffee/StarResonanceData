local UI = Z.UI
local super = require("ui.ui_view_base")
local World_boss_full_schedule_popupView = class("World_boss_full_schedule_popupView", super)
local gradeItem_ = require("ui.component.world_boss.world_boss_stage_loop_item")
local loop_list_view = require("ui/component/loop_list_view")

function World_boss_full_schedule_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "world_boss_full_schedule_popup")
  self.worldBossVM_ = Z.VMMgr.GetVM("world_boss")
end

function World_boss_full_schedule_popupView:OnActive()
  self:initBinders()
  self:refreshInfo()
end

function World_boss_full_schedule_popupView:OnDeActive()
  self.rewardScrollRect_:UnInit()
  self.rewardScrollRect_ = nil
end

function World_boss_full_schedule_popupView:OnRefresh()
end

function World_boss_full_schedule_popupView:initBinders()
  self:AddClick(self.uiBinder.btn_close, function()
    self.worldBossVM_:CloseWorldBossScheduleView()
  end)
  local dataList_ = {}
  self.rewardScrollRect_ = loop_list_view.new(self, self.uiBinder.scrollview_award, gradeItem_, "world_boss_schedule_list_tpl")
  self.rewardScrollRect_:Init(dataList_)
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
end

function World_boss_full_schedule_popupView:refreshInfo()
  Z.CoroUtil.create_coro_xpcall(function()
    self.worldBossVM_:AsyncGetWorldBossInfo(self.cancelSource:CreateToken(), function(ret)
      self.uiBinder.lab_current_stage.text = Lang("WorldBossCurrentStage") .. ret.bossStage
      self.uiBinder.lab_kill_count.text = Lang("WorldBossCurrentKillNum") .. ret.bossKilledNum
      local list_ = self.worldBossVM_:GetStageTableData()
      self.rewardScrollRect_:RefreshListView(list_)
    end)
  end)()
end

function World_boss_full_schedule_popupView:RefreshRewardList()
  self.rewardScrollRect_:RefreshAllShownItem()
end

return World_boss_full_schedule_popupView
