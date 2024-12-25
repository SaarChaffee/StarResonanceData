local UI = Z.UI
local super = require("ui.ui_view_base")
local Trialroad_closing_windowView = class("Trialroad_closing_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local trialroad_task_loop_item = require("ui.component.trialroad.trialroad_closing_task_loop_item")

function Trialroad_closing_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "trialroad_closing_window")
end

function Trialroad_closing_windowView:OnActive()
  Z.AudioMgr:Play("sys_player_enviroreso_in")
  self.dungeonId_ = Z.StageMgr.GetCurrentDungeonId()
  self.dungeonData_ = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
  self.trialroadVM_ = Z.VMMgr.GetVM("trialroad")
  self.trialRoadData_ = Z.DataMgr.Get("trialroad_data")
  self:AddClick(self.uiBinder.btn_close, function()
    self.trialroadVM_.CloseSettlementSuccessWindow()
  end)
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.uiBinder.anim:PlayOnce("anim_trialroad_closing_window_an")
  self.taskListView_ = loopListView.new(self, self.uiBinder.loop_item, trialroad_task_loop_item, "trialroad_closing_task_tpl")
  self.taskListView_:Init({})
end

function Trialroad_closing_windowView:setTitle()
  if self.dungeonData_ then
    self.uiBinder.lab_name.text = self.dungeonData_.Name
  end
end

function Trialroad_closing_windowView:setTime(num)
  local h = math.floor(num / 3600)
  local time = os.date("%M:%S", num)
  self.uiBinder.lab_time.text = h .. ":" .. time
end

function Trialroad_closing_windowView:OnDeActive()
  self.taskListView_:UnInit()
  self.taskListView_ = nil
  Z.UITimelineDisplay:ClearTimeLine()
end

function Trialroad_closing_windowView:OnRefresh()
  local planetRoomInfo = Z.ContainerMgr.DungeonSyncData.planetRoomInfo
  if not planetRoomInfo then
    return
  end
  self.trialroadVM_.RefreshRoomTargetState(planetRoomInfo.roomId)
  self:setTitle()
  self:setTime(Z.ContainerMgr.DungeonSyncData.settlement.passTime)
  local roomData_ = self.trialRoadData_:GetTrialRoadRoomDataById(planetRoomInfo.roomId)
  if roomData_ then
    if roomData_.ListRoomTarget and next(roomData_.ListRoomTarget) then
      self.taskListView_:RefreshListView(roomData_.ListRoomTarget)
    else
      self.taskListView_:RefreshListView({})
    end
    self.trialroadVM_.RefreshTrialRoadRed(planetRoomInfo.roomId)
  end
end

return Trialroad_closing_windowView
