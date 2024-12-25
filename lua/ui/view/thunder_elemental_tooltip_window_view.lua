local UI = Z.UI
local super = require("ui.ui_view_base")
local Thunder_elemental_tooltip_windowView = class("thunder_elemental_tooltip_windowView", super)

function Thunder_elemental_tooltip_windowView:ctor()
  self.panel = nil
  super.ctor(self, "thunder_elemental_tooltip_window")
  self.componentArray_ = {
    timePreparePrefab = nil,
    rankingPrefab = nil,
    endStatePrefab = nil
  }
  self.viewData = nil
  self.thunder_elemental_vm = Z.VMMgr.GetVM("thunder_elemental")
  self.thunderElementalData = Z.DataMgr.Get("thunder_elemental_tooltip_data")
end

function Thunder_elemental_tooltip_windowView:OnActive()
  self:InitUI()
  self:BindEvents()
end

function Thunder_elemental_tooltip_windowView:InitUI()
  self.timePrepareZwidget = self.panel.node_time_prepare
  self.endStateZwidget = self.panel.node_end_state
  self.rankingZwidget = self.panel.node_rangking
end

function Thunder_elemental_tooltip_windowView:ClearAll()
  for _, v in pairs(self.componentArray_) do
    if v then
      v:DeActive()
      v = nil
    end
  end
  self.componentArray_ = {}
  self:ClearAllUnits()
end

function Thunder_elemental_tooltip_windowView:CloseTipsWindow(sceneId)
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
  self.thunder_elemental_vm.SetDungeonHideTag(false)
  self.thunder_elemental_vm.CloseTooltipView()
end

function Thunder_elemental_tooltip_windowView:OnDeActive()
  self:UnBindEvents()
  self:ClearAll()
end

function Thunder_elemental_tooltip_windowView:OnRefresh()
  if self.thunderElementalData.DungeonHideTag and self.thunderElementalData.MainViewHideTag then
    self:Show()
  else
    self:Hide()
  end
end

function Thunder_elemental_tooltip_windowView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.SceneActionEvent.EnterScene, self.CloseTipsWindow, self)
end

function Thunder_elemental_tooltip_windowView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.SceneActionEvent.EnterScene, self.CloseTipsWindow, self)
end

return Thunder_elemental_tooltip_windowView
