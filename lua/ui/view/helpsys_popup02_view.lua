local UI = Z.UI
local super = require("ui.ui_view_base")
local Helpsys_popup02View = class("Helpsys_popup02View", super)
local firstFloorItemPathKey = "helpsysFirstFloorItem"
local secondFloorItemPathKey = "helpsysSecondFloorItem"
local helpsysTab = require("ui/component/helpsys/helpsys_tab")

function Helpsys_popup02View:ctor()
  self.uiBinder = nil
  super.ctor(self, "helpsys_popup02")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.helpsysData_ = Z.DataMgr.Get("helpsys_data")
end

function Helpsys_popup02View:OnActive()
  self:startAnimatedShow()
  self:initTabs()
  self:BindEvents()
end

function Helpsys_popup02View:OnDeActive()
end

function Helpsys_popup02View:BindEvents()
  self:AddClick(self.uiBinder.close_btn, function()
    self.helpsysVM_:CloseMixHelpSysView()
  end)
end

function Helpsys_popup02View:OnRefresh()
end

function Helpsys_popup02View:initTabs()
  self.tabView_ = helpsysTab.new(self, self.uiBinder.node_content.transform, GetLoadAssetPath(firstFloorItemPathKey), GetLoadAssetPath(secondFloorItemPathKey))
  local data = self.helpsysData_:GetMixDataByType(self.viewData.type)
  self.datas_ = data.Datas
  self.uiBinder.lab_title_name.text = data.MainTitle
  Z.CoroUtil.create_coro_xpcall(function()
    self.tabView_:Init(self.datas_, nil)
    self.tabView_:InitShow(false)
  end)()
end

function Helpsys_popup02View:tabViewCallback(data)
  self:refreshView(data)
end

function Helpsys_popup02View:refreshView(data)
end

function Helpsys_popup02View:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Helpsys_popup02View:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlay)
  coro(self.uiBinder.anim, Z.DOTweenAnimType.Close)
end

return Helpsys_popup02View
