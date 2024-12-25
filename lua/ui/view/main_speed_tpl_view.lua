local UI = Z.UI
local super = require("ui.ui_subview_base")
local Main_speed_tplView = class("Main_speed_tplView", super)

function Main_speed_tplView:ctor(parent)
  self.panel = nil
  super.ctor(self, "main_speed_tpl", "main/main_speed_tpl", UI.ECacheLv.None)
end

function Main_speed_tplView:OnActive()
  self:BindLuaAttrWatchers()
end

function Main_speed_tplView:OnDeActive()
  if self.glideWatcher ~= nil then
    self.glideWatcher:Dispose()
    self.glideWatcher = nil
  end
end

function Main_speed_tplView:BindLuaAttrWatchers()
  self.glideWatcher = Z.DIServiceMgr.PlayerAttrComponentWatcherService:OnLocalAttrGlideChanged(function()
    self:onPlayerSpeedChange()
  end)
  self:BindEntityLuaAttrWatcher({
    Z.PbAttrEnum("AttrState")
  }, Z.EntityMgr.PlayerEnt, self.onPlayerStateChange)
end

function Main_speed_tplView:onPlayerStateChange()
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrState")).Value
  self.panel.lab_text:SetVisible(Z.PbEnum("EActorState", "ActorStateGlide") == stateId)
end

function Main_speed_tplView:onPlayerSpeedChange()
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrState")).Value
  if Z.PbEnum("EActorState", "ActorStateGlide") ~= stateId then
    return
  end
  self:calculationSpeed()
end

function Main_speed_tplView:calculationSpeed()
  local velocityH = Z.EntityMgr.PlayerEnt:GetLocalAttrGlideVelocityH()
  local velocityV = Z.EntityMgr.PlayerEnt:GetLocalAttrGlideVelocityV()
  local velocity = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrAttachVelocity")).Value
  local realVelocity = math.sqrt(velocityH * velocityH + velocityV * velocityV) + velocity
  self.panel.lab_text.TMPLab.text = string.format(Lang("speed"), string.format("%.2f", realVelocity))
end

function Main_speed_tplView:OnRefresh()
end

return Main_speed_tplView
