local UI = Z.UI
local super = require("ui.ui_view_base")
local Resonance_Power_Decompose_acquireView = class("Resonance_Power_Decompose_acquireView", super)
local itemClass = require("common.item")
local itemSortFactoryVm = Z.VMMgr.GetVM("item_sort_factory")

function Resonance_Power_Decompose_acquireView:ctor()
  self.panel = nil
  super.ctor(self, "resonacne_power_decompose_acquire")
  self.resonancePowerVM = Z.VMMgr.GetVM("resonance_power")
end

function Resonance_Power_Decompose_acquireView:OnActive()
  self.itemClassTab_ = {}
  self.panel.scenemask_bg.SceneMask:SetSceneMaskByKey(self.SceneMaskKey)
  self.isShowName = self.viewData and self.viewData[1] and self.viewData[1].isShowName
  self.panel.cont.pointcheck.PressCheck:StopCheck()
  self:EventAddAsyncListener(self.panel.cont.pointcheck.PressCheck.ContainGoEvent, function(isContain)
    if not isContain then
      self.resonancePowerVM.CloseDecomposeAcquireView()
    end
  end, nil, nil)
end

function Resonance_Power_Decompose_acquireView:OnDeActive()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
end

function Resonance_Power_Decompose_acquireView:OnRefresh()
  self.cancelSource:CancelAll()
  self:ClearAllUnits()
  Z.CoroUtil.create_coro_xpcall(function()
    self.panel.cont.pointcheck.PressCheck:StartCheck()
    self:asyncShowAcquireItems()
  end)()
  if self.viewData and self.viewData[1] and self.viewData[1].name then
    self.panel.cont.lab_title_2.TMPLab.text = self.viewData[1].name
  else
    self.panel.cont.lab_title_2.TMPLab.text = Lang("CongratulationsGetting")
  end
end

function Resonance_Power_Decompose_acquireView:asyncShowAcquireItems()
  if not self.viewData then
    return
  end
  local parent = self.panel.cont.node_content.Trans
  local itemPath = self:GetPrefabCacheData("item")
  if itemPath == nil then
    return
  end
  itemSortFactoryVm.DefaultSendAwardSortByConfigId(self.viewData)
  for key, value in pairs(self.viewData) do
    local unit = self:AsyncLoadUiUnit(itemPath, key, parent)
    local item = itemClass.new(self)
    item:Init({
      unit = unit,
      configId = value.configId,
      lab = value.count,
      isShowName = self.isShowName
    })
    table.insert(self.itemClassTab_, item)
  end
end

return Resonance_Power_Decompose_acquireView
