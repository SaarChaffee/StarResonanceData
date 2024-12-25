local UI = Z.UI
local super = require("ui.ui_subview_base")
local Cont_bpcard_content_taskView = class("Cont_bpcard_content_taskView", super)
local loopScrollRect_ = require("ui/component/loopscrollrect")
local battle_pass_quest_week_loop_item_ = require("ui/component/battle_pass/battle_pass_quest_week_loop_item")
local battle_pass_task_loop_item_ = require("ui/component/battle_pass/battle_pass_task_loop_item")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function Cont_bpcard_content_taskView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "cont_bpcard_content_task", "bpcard/cont_bpcard_content_task", UI.ECacheLv.High)
  self.battlePassCardData_ = nil
  self.awardItem_ = {}
end

function Cont_bpcard_content_taskView:OnActive()
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
  self.battlePassData_ = Z.DataMgr.Get("battlepass_data")
  self:initBinders()
  self:initParam()
  self:bindWatchers()
end

function Cont_bpcard_content_taskView:OnDeActive()
  self:unBindWatchers()
  self.awardItem_ = {}
  self.weekIndex_ = 0
  self.quest_ScrollRect_:ClearCells()
  self.weekScrollRect_:ClearCells()
end

function Cont_bpcard_content_taskView:OnRefresh()
  self:initTaskAward()
  self:initWeekLoopScroll()
  if self.daily_tog.isOn then
    self:initQuestLoopScroll(0)
  else
    self.daily_tog.isOn = true
  end
end

function Cont_bpcard_content_taskView:initBinders()
  self.top_reward_node = self.uiBinder.layout_reward
  self.week_loopscroll_item = self.uiBinder.loopscroll_week
  self.quest_loopscroll_item = self.uiBinder.loopscroll_list
  self.daily_tog = self.uiBinder.tog_temp
  self.layout_tab = self.uiBinder.layout_tab
  self.togs_tpl_node = self.uiBinder.bpcard_togs_tpl
  self.reward_layout_node = self.uiBinder.layout_buy_reward
  self.daily_tog.group = self.togs_tpl_node
  self.togs_tpl_node.AllowSwitchOff = false
  self.daily_tog:AddListener(function(isOn)
    self.togs_tpl_node.AllowSwitchOff = false
    if isOn then
      self:initQuestLoopScroll(0)
    end
  end)
end

function Cont_bpcard_content_taskView:initParam()
  self.weekIndex_ = 0
  self.weekScrollRect_ = loopScrollRect_.new(self.week_loopscroll_item, self, battle_pass_quest_week_loop_item_)
  self.quest_ScrollRect_ = loopScrollRect_.new(self.quest_loopscroll_item, self, battle_pass_task_loop_item_)
  self.season_container_ = Z.ContainerMgr.CharSerialize.seasonCenter
end

function Cont_bpcard_content_taskView:bindWatchers()
  function self.refreshQuestData_(container, dirtys)
    if dirtys and (dirtys.seasonMap or dirtys.randomMap or dirtys.isUnlock) then
      self:initQuestLoopScroll(self.weekIndex_, true)
    end
  end
  
  Z.ContainerMgr.CharSerialize.seasonCenter.bpQuestList.Watcher:RegWatcher(self.refreshQuestData_)
  Z.ContainerMgr.CharSerialize.seasonCenter.battlePass.Watcher:RegWatcher(self.refreshQuestData_)
end

function Cont_bpcard_content_taskView:unBindWatchers()
  Z.ContainerMgr.CharSerialize.seasonCenter.bpQuestList.Watcher:UnregWatcher(self.refreshQuestData_)
  Z.ContainerMgr.CharSerialize.seasonCenter.battlePass.Watcher:UnregWatcher(self.refreshQuestData_)
end

function Cont_bpcard_content_taskView:initWeekLoopScroll()
  local weekData = self.battlePassData_:GetSeasonWeek()
  self.weekScrollRect_:SetData(weekData)
  self.layout_tab:ForceRebuildLayoutImmediate()
end

function Cont_bpcard_content_taskView:onWeekLoopItemSelected(weekIndex)
  self.togs_tpl_node.AllowSwitchOff = true
  self.daily_tog.isOn = false
  self:initQuestLoopScroll(weekIndex)
end

function Cont_bpcard_content_taskView:initQuestLoopScroll(weekIndex, isRefresh)
  self.weekIndex_ = weekIndex
  local taskData = {}
  if weekIndex == 0 then
    self.weekScrollRect_:ClearSelected()
    taskData = self.battlePassVM_.GetSeasonDailyTask(self.season_container_.seasonId)
  else
    taskData = self.battlePassVM_.GetSeasonTaskByWeek(weekIndex, self.season_container_.seasonId)
  end
  self.quest_ScrollRect_:ClearCells()
  self.quest_ScrollRect_:SetData(taskData)
end

function Cont_bpcard_content_taskView:initTaskAward()
  local awardData = self.battlePassVM_.GetPaymentTaskAward(self.season_container_.seasonId, self.battlePassVM_.GetSeasonCurrentWeek())
  if self.season_container_.battlePass.isUnlock or table.zcount(awardData) == 0 then
    self.uiBinder.Ref:SetVisible(self.reward_layout_node, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.reward_layout_node, true)
  Z.CoroUtil.create_coro_xpcall(function()
    self:loadTaskAwardItem(awardData)
  end)()
end

function Cont_bpcard_content_taskView:loadTaskAwardItem(awardData)
  local awardInfo = awardPreviewVm.GetAllAwardPreListByIds(awardData)
  for k, v in pairs(awardInfo) do
    local name = "awardItem" .. k
    table.insert(self.awardItem_, name)
    local path = self:GetPrefabCacheData("TopRewardTpl")
    local unit = self:AsyncLoadUiUnit(path, name, self.top_reward_node, self.cancelSource:CreateToken())
    if not unit then
      return
    end
    local labType, lab = awardPreviewVm.GetPreviewShowNum(v)
    local itemTable = Z.TableMgr.GetTable("ItemTableMgr").GetRow(v.awardId)
    unit.lab_num.TMPLab.text = lab
    if itemTable then
      local itemsVM = Z.VMMgr.GetVM("items")
      unit.img_lock.Img:SetImage(itemsVM.GetItemIcon(v.awardId))
    end
  end
end

return Cont_bpcard_content_taskView
