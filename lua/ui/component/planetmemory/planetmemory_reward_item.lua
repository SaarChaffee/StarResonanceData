local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local PlanetmemoryRewardItem = class("PlanetmemoryRewardItem", super)

function PlanetmemoryRewardItem:ctor()
end

function PlanetmemoryRewardItem:initComp()
  self.receiveBtn_ = self.panel.cont_btn_receive.btn.Btn
  self.noLab_ = self.panel.lab_no.TMPLab
  self.reachedLab_ = self.panel.lab_reached.TMPLab
  self.paceLab_ = self.panel.lab_pace.TMPLab
  self.descriptionLab_ = self.panel.lab_description.TMPLab
  self.seasonTaskSlider_ = self.panel.slider_season.Slider
end

function PlanetmemoryRewardItem:onReceiveBtnClick()
end

function PlanetmemoryRewardItem:InitListener()
  self:AddClick(self.receiveBtn_, function()
    self:onReceiveBtnClick()
  end)
end

function PlanetmemoryRewardItem:OnInit()
end

function PlanetmemoryRewardItem:Refresh()
end

function PlanetmemoryRewardItem:OnReset()
end

function PlanetmemoryRewardItem:OnUnInit()
end

function PlanetmemoryRewardItem:OnBeforePlayAnim()
end

return PlanetmemoryRewardItem
