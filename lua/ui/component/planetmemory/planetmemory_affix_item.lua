local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local PlanetmemoryAffixItem = class("PlanetmemoryAffixItem", super)

function PlanetmemoryAffixItem:ctor()
end

function PlanetmemoryAffixItem:initComp()
  self.affixNameLab_ = self.panel.lab_affix_name.TMPLab
  self.affixIconImg_ = self.panel.img_affix_icon.Img
  self.lineImg_ = self.panel.img_line.Img
end

function PlanetmemoryAffixItem:InitListener()
end

function PlanetmemoryAffixItem:OnInit()
end

function PlanetmemoryAffixItem:Refresh()
end

function PlanetmemoryAffixItem:OnReset()
end

function PlanetmemoryAffixItem:OnUnInit()
end

function PlanetmemoryAffixItem:OnBeforePlayAnim()
end

return PlanetmemoryAffixItem
