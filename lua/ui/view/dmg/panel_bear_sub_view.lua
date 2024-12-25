local UI = Z.UI
local super = require("ui.ui_subview_base")
local Panel_bear_subView = class("Panel_bear_subView", super)
local loopscrollrect = require("ui/component/loopscrollrect")
local dmgLoopItme = require("ui.component.damage.dmg_loop_item")
local bodyLooyItem = require("ui.component.damage.dmg_control_buff_loop_item")
local targetLoopItem = require("ui.component.damage.dmg_control_attr_loop_item")
local dmgVm = Z.VMMgr.GetVM("damage")
local dmgData = Z.DataMgr.Get("damage_data")

function Panel_bear_subView:ctor(parent)
  self.panel = nil
  super.ctor(self, "panel_bear_sub", "dmg/panel_bear_sub", UI.ECacheLv.None)
end

function Panel_bear_subView:initZWidget()
  self.bodyNode_ = self.panel.node_body
  self.targetNode_ = self.panel.node_target
  self.bodyLoop_ = self.bodyNode_.node_loop
  self.targetLoop_ = self.targetNode_.node_loop
  self.bodyScrollRect_ = loopscrollrect.new(self.bodyLoop_.VLoopScrollRect, self, bodyLooyItem)
  self.targetScrollRect_ = loopscrollrect.new(self.targetLoop_.VLoopScrollRect, self, targetLoopItem)
  self:AddClick(self.bodyNode_.input.Input, function(str)
    if self.isSelectedBodyDro then
      self.isSelectedBodyDro = false
      return
    end
    local data = dmgVm.DimFindData(str, dmgData.Body)
    self.bodyScrollRect_:SetData(data)
    self.bodyLoop_:SetVisible(0 < #data)
  end)
  self:AddClick(self.targetNode_.input.Input, function(str)
    if self.isSelectedTargetDro then
      self.isSelectedTargetDro = false
      return
    end
    local data = dmgVm.DimFindData(str, dmgData.Target)
    self.targetScrollRect_:SetData(data)
    self.targetLoop_:SetVisible(0 < #data)
  end)
  self.bodyNode_.input.Input:AddSelectListener(function(bool)
    if bool == false then
      return
    end
    self:refrehDevelopmentView()
    self.bodyLoop_:SetVisible(#dmgData.Body > 0)
  end)
  self.targetNode_.input.Input:AddSelectListener(function(bool)
    if bool == false then
      return
    end
    self:refreshTargetDro()
    self.targetLoop_:SetVisible(#dmgData.Target > 0)
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.bodyLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.bodyLoop_:SetVisible(false)
    end
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.targetLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.targetLoop_:SetVisible(false)
    end
  end)
end

function Panel_bear_subView:OnActive()
  self.panel.Ref:SetSize(Vector2.zero)
  self:initZWidget()
  self.isSelectedBodyDro = false
  self.isSelectedTargetDro = false
  dmgData.TypeIndex = self.viewData
  dmgVm.ChangeDrowIndex()
  self.damageLoopScrollRect = loopscrollrect.new(self.panel.loopscroll.VLoopScrollRect, self, dmgLoopItme)
  self:BindEvents()
  self:refrehDamagePanel()
  self:refrehDevelopmentView()
  self:BuffSelected(dmgData.Body[2])
  self:AttrSelected(dmgData.Target[1])
end

function Panel_bear_subView:refrehDevelopmentView()
  dmgVm.SetNearMosterTab()
  dmgData:SetBodyTab(table.zclone(dmgData.ControlNearMonsterTab))
  self.bodyScrollRect_:SetData(dmgData.Body)
  self:refreshTargetDro()
end

function Panel_bear_subView:refrehDamagePanel()
  self.damageLoopScrollRect:SetData(dmgData.TakeDamageDatas)
end

function Panel_bear_subView:BuffSelected(data)
  if data == nil then
    return
  end
  self.bodyLoop_:SetVisible(false)
  if self.bodyNode_.input.Input.text == data then
    return
  end
  self.isSelectedBodyDro = true
  self.bodyNode_.input.Input.text = data
  self.bodyData_ = string.split(data, " ")[1]
  dmgData.SelectAttUuid = self.bodyData_
  dmgVm.ChangeDrowIndex()
end

function Panel_bear_subView:refreshTargetDro()
  dmgVm.SetNearMosterTab()
  dmgData:SetTargetTab(table.zclone(dmgData.ControlNearMonsterTab))
  self.targetScrollRect_:SetData(dmgData.Target)
  dmgData.Part = {
    Lang("DamagePartTxt")
  }
end

function Panel_bear_subView:AttrSelected(data)
  if data == nil then
    return
  end
  self.targetLoop_:SetVisible(false)
  if self.targetNode_.input.Input.text == data then
    return
  end
  self.isSelectedTargetDro = true
  self.targetNode_.input.Input.text = data
  dmgData.SelectByAttUuid = string.split(data, " ")[1]
  dmgVm.ChangeDrowIndex()
end

function Panel_bear_subView:OnDeActive()
  Z.EventMgr:RemoveObjAll(self)
end

function Panel_bear_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Damage.RefreshPanel, self.refrehDamagePanel, self)
end

function Panel_bear_subView:OnRefresh()
end

return Panel_bear_subView
