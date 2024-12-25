local UI = Z.UI
local super = require("ui.ui_subview_base")
local Panel_shield_subView = class("Panel_shield_subView", super)
local loopscrollrect = require("ui/component/loopscrollrect")
local buffLoopItem = require("ui.component.damage.dmg_control_buff_loop_item")
local shieldLoopItem = require("ui.component.damage.dmg_shield_loop_item")
local dmgVm = Z.VMMgr.GetVM("damage")
local dmgData = Z.DataMgr.Get("damage_data")

function Panel_shield_subView:ctor(parent)
  self.panel = nil
  super.ctor(self, "panel_shield_sub", "dmg/panel_shield_sub", UI.ECacheLv.None)
end

function Panel_shield_subView:initZWidget()
  self.shieldTargetNode_ = self.panel.node_shield_target
  self.shieldTargetLoop_ = self.shieldTargetNode_.node_loop
  self.shieldTargetScrollRect_ = loopscrollrect.new(self.shieldTargetLoop_.VLoopScrollRect, self, buffLoopItem)
  self.buffInfoScrollRect = loopscrollrect.new(self.panel.loopscroll.VLoopScrollRect, self, shieldLoopItem)
  self:AddClick(self.shieldTargetNode_.input.Input, function(str)
    if self.isSelectedShieldDro then
      self.isSelectedShieldDro = false
      return
    end
    self.showData_ = dmgVm.DimFindData(str, dmgData.ShieldTargetTab)
    self.shieldTargetScrollRect_:SetData(self.showData_)
    self.shieldTargetLoop_:SetVisible(#self.showData_ > 0)
  end)
  self.shieldTargetNode_.input.Input:AddSelectListener(function(bool)
    if bool == false then
      return
    end
    self:setShieldTargetTab()
    self.shieldTargetLoop_:SetVisible(#dmgData.ShieldTargetTab > 0)
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.shieldTargetLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.shieldTargetLoop_:SetVisible(false)
    end
  end)
  self:AddClick(self.panel.gm_input_tpl03.panel_input.Input, function(str)
    self.shieldInputStr_ = str
    local attrData = dmgVm.GetAttrData(str)
    self.shieldTargetScrollRect_:SetData(attrData)
  end)
end

function Panel_shield_subView:OnActive()
  self.panel.Ref:SetSize(Vector2.zero)
  self.panel.node_now:SetVisible(dmgData.IsShowNowShield)
  self.panel.node_sum:SetVisible(not dmgData.IsShowNowShield)
  self:initZWidget()
  self.isSelectedShieldDro = false
  self:setShieldTargetTab()
  self:BuffSelected(dmgData.ShieldTargetTab[1])
end

function Panel_shield_subView:setShieldTargetTab()
  dmgVm.SetNearMosterTab()
  dmgData:SetShieldTargetTab(table.zclone(dmgData.ControlNearMonsterTab))
  self.shieldTargetScrollRect_:SetData(dmgData.ShieldTargetTab)
end

function Panel_shield_subView:BuffSelected(data)
  if data == nil then
    return
  end
  self.shieldTargetLoop_:SetVisible(false)
  if self.shieldTargetNode_.input.Input.text == data then
    return
  end
  self.isSelectedShieldDro = true
  self.shieldTargetNode_.input.Input.text = data
  self.shieldData_ = string.split(data, " ")[1]
  self:getEnitityShield()
end

function Panel_shield_subView:OnDeActive()
  self.buffInfoScrollRect = nil
  self.shieldTargetScrollRect_ = nil
end

function Panel_shield_subView:RefreshData()
  self:getEnitityShield()
end

function Panel_shield_subView:getEnitityShield()
  if self.buffInfoScrollRect == nil then
    return
  end
  local entUuid
  if self.shieldData_ == Lang("DamageSelfTxt") then
    entUuid = dmgData.PlayerUuid
  else
    entUuid = self.shieldData_
  end
  if entUuid == nil then
    return
  end
  dmgVm.GetEnitityShieldTab(entUuid)
  if dmgData.IsShowNowShield then
    self.buffInfoScrollRect:SetData(dmgData.ShieldDataTab[tonumber(entUuid)])
  else
    self.buffInfoScrollRect:SetData(dmgData:GetShowShieldStatisticsData(tonumber(entUuid)))
  end
end

function Panel_shield_subView:OnRefresh()
end

return Panel_shield_subView
