local super = require("ui.ui_view_base")
local Flux_revolt_tooltip_windowView = class("flux_revolt_tooltip_windowView", super)

function Flux_revolt_tooltip_windowView:ctor()
  self.panel = nil
  super.ctor(self, "flux_revolt_tooltip_window")
  self.componentArray_ = {
    timePreparePrefab = nil,
    rankingPrefab = nil,
    endStatePrefab = nil
  }
  self.viewData = nil
  self.fluxRevolt_tooltip_vm = Z.VMMgr.GetVM("flux_revolt_tooltip")
  self.fluxData = Z.DataMgr.Get("flux_revolt_tooltip_data")
end

function Flux_revolt_tooltip_windowView:OnActive()
  self:InitUI()
  self:BindEvents()
end

function Flux_revolt_tooltip_windowView:InitUI()
  self.timePrepareZwidget = self.panel.node_time_prepare
  self.endStateZwidget = self.panel.node_end_state
  self.rankingZwidget = self.panel.node_rangking
end

function Flux_revolt_tooltip_windowView:ClearAll()
  for _, v in pairs(self.componentArray_) do
    if v then
      v:DeActive()
      v = nil
    end
  end
  self.componentArray_ = {}
  self:ClearAllUnits()
end

function Flux_revolt_tooltip_windowView:OnDeActive()
  self:UnBindEvents()
  self:ClearAll()
end

function Flux_revolt_tooltip_windowView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.SceneActionEvent.EnterScene, self.CloseTipsWindow, self)
end

function Flux_revolt_tooltip_windowView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.SceneActionEvent.EnterScene, self.CloseTipsWindow, self)
end

function Flux_revolt_tooltip_windowView:CloseTipsWindow(sceneId)
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
  self.fluxRevolt_tooltip_vm.SetDungeonHideTag(false)
  self.fluxRevolt_tooltip_vm.CloseTooltipView()
end

function Flux_revolt_tooltip_windowView:OnRefresh()
  if self.fluxData.DungeonHideTag and self.fluxData.MainViewHideTag then
    self:Show()
  else
    self:Hide()
  end
end

return Flux_revolt_tooltip_windowView
