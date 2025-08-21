local UI = Z.UI
local super = require("ui.ui_view_base")
local Parkour_tooltip_windowView = class("Parkour_tooltip_windowView", super)
local endStateView = require("ui.view.parkour_end_state_tpl_view")
local globalTable = Z.TableMgr.GetTable("GlobalWorldEventTableMgr")
local endStatePath = "ui/prefabs/parkour/parkour_end_state_tpl"

function Parkour_tooltip_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "parkour_tooltip_window")
  self.componentArray_ = {
    timePreparePrefab = nil,
    rankingPrefab = nil,
    countDownPrefab = nil,
    endStatePrefab = nil
  }
  self.viewData = nil
  self.parkourtips_vm = Z.VMMgr.GetVM("parkourtips")
  self.parkourData = Z.DataMgr.Get("parkour_tooltip_data")
end

function Parkour_tooltip_windowView:OnActive()
  self.isShowBackTips_ = false
  self:InitUI()
  self:BindEvents()
end

function Parkour_tooltip_windowView:InitUI()
  self.uiBinder.lab_content.text = Lang("Multiparkour_TurnOnVolume")
  self:AddClick(self.uiBinder.btn_mask, function()
    self:SetUIVisible(self.uiBinder.node_back_tracking_tips, false)
    self.isShowBackTips_ = true
  end)
  self:AddAsyncClick(self.uiBinder.btn_back_tracking, function()
    self.parkourtips_vm.SetUserOptionSelect(self.cancelSource)
  end)
  self:SetUIVisible(self.uiBinder.node_back_tracking_tips, false)
  self:SetUIVisible(self.uiBinder.btn_mask, false)
  self:SetUIVisible(self.uiBinder.btn_back_tracking, false)
end

function Parkour_tooltip_windowView:ClearAll()
  for _, v in pairs(self.componentArray_) do
    if v then
      v:DeActive()
      v = nil
    end
  end
  self.componentArray_ = {}
  self:ClearAllUnits()
end

function Parkour_tooltip_windowView:CloseParkourTipsWindow(sceneId)
  if not sceneId then
    return
  end
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  if dungeonId ~= 0 then
    local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
    if cfgData ~= nil and cfgData.SceneID == sceneId then
      return
    end
  end
  self.parkourtips_vm.SetStartMark(true)
  self.parkourtips_vm.SetDungeonHideTag(false)
  self.parkourtips_vm.CloseTooltipView()
end

function Parkour_tooltip_windowView:OnDeActive()
  self:UnBindEvents()
  self:ClearAll()
end

function Parkour_tooltip_windowView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.ParkourActionEvt.NotifyResultRecord, self.RefreshResultRecord, self)
  Z.EventMgr:Add(Z.ConstValue.SceneActionEvent.EnterScene, self.CloseParkourTipsWindow, self)
end

function Parkour_tooltip_windowView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.ParkourActionEvt.NotifyResultRecord, self.RefreshResultRecord, self)
  Z.EventMgr:Remove(Z.ConstValue.SceneActionEvent.EnterScene, self.CloseParkourTipsWindow, self)
end

function Parkour_tooltip_windowView:OnRefresh()
  if self.parkourData.DungeonHideTag and self.parkourData.MainViewHideTag then
    self:Show()
  else
    self:Hide()
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self:InitSubView()
  end)()
end

function Parkour_tooltip_windowView:InitSubView()
  self:ShowViewUI()
  if not (self.parkourData.WorldEventDungeonData and self.parkourData.WorldEventDungeonData.DungeonInfo) or not self.parkourData.WorldEventDungeonData.ViewType then
    return
  end
  local viewType = self.parkourData.WorldEventDungeonData.ViewType
  if viewType ~= E.WorldEventDungeonViewState.EndState then
    self:ClearAll()
    return
  end
  if viewType == E.WorldEventDungeonViewState.EndState then
    local timeNumber = self:GetCalculatedTime()
    local param = {val = timeNumber}
    local worldEventCfg
    if globalTable then
      worldEventCfg = globalTable.GetRow(6)
    end
    local delayTime = 0
    if worldEventCfg and worldEventCfg.Value and worldEventCfg.Value then
      delayTime = worldEventCfg.Value[1]
    end
    self.timerMgr:StartTimer(function()
      Z.TipsVM.ShowTipsLang(16001007, param)
    end, delayTime)
  end
end

function Parkour_tooltip_windowView:RefreshResultRecord(result, vRecord)
  self:ClearAll()
  if not self.componentArray_.endStatePrefab then
    Z.CoroUtil.create_coro_xpcall(function()
      local name = "parkour_end_state_tpl_view"
      local uiUnit_ = self:AsyncLoadUiUnit(endStatePath, name, self.uiBinder.node_end_state, self.cancelSource:CreateToken())
      self.componentArray_.endStatePrefab = endStateView.new()
      local worldEventCfg
      if globalTable then
        worldEventCfg = globalTable.GetRow(5)
      end
      local delayTime = 5
      if worldEventCfg and worldEventCfg.Value then
        delayTime = worldEventCfg.Value[1]
      end
      self.componentArray_.endStatePrefab:Init(uiUnit_.Go, name, function()
        self:ClearAll()
      end, delayTime)
      self.componentArray_.endStatePrefab:SetData(result, vRecord)
    end)()
  end
end

function Parkour_tooltip_windowView:GetCalculatedTime()
  if not (self.parkourData.WorldEventDungeonData and self.parkourData.WorldEventDungeonData.DungeonInfo) or not self.parkourData.WorldEventDungeonData.ViewType then
    return
  end
  local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local deltaTime = 0
  local duration = 0
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  if dungeonId == 0 then
    return 0
  end
  local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if not cfgData then
    return 0
  end
  duration = cfgData.SettlementStateTime
  if nowTime > self.parkourData.WorldEventDungeonData.DungeonInfo.settlementTime then
    deltaTime = nowTime - self.parkourData.WorldEventDungeonData.DungeonInfo.settlementTime
  end
  local timeNumber = duration - deltaTime
  return timeNumber
end

function Parkour_tooltip_windowView:CreateUiUnit(path, name, trans)
  local uiUnit = self:AsyncLoadUiUnit(path, name, trans, self.cancelSource:CreateToken())
  return uiUnit
end

function Parkour_tooltip_windowView:ShowViewUI()
  self:SetUIVisible(self.uiBinder.node_tips, false)
  local flowInfo = Z.ContainerMgr.DungeonSyncData.flowInfo
  if not flowInfo.state then
    return
  end
  if flowInfo.state == E.DungeonState.DungeonStateActive then
    self:SetUIVisible(self.uiBinder.node_tips, true)
  end
end

return Parkour_tooltip_windowView
