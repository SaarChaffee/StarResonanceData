local UI = Z.UI
local super = require("ui.ui_subview_base")
local Panel_dmg_subView = class("Panel_dmg_subView", super)
local loopscrollrect = require("ui/component/loopscrollrect")
local dmgLoopItme = require("ui.component.damage.dmg_loop_item")
local bodyLooyItem = require("ui.component.damage.dmg_control_buff_loop_item")
local targetLoopItem = require("ui.component.damage.dmg_control_attr_loop_item")
local partLoopItem = require("ui.component.damage.dmg_control_monster_loop_item")
local dmgVm = Z.VMMgr.GetVM("damage")
local dmgData = Z.DataMgr.Get("damage_data")

function Panel_dmg_subView:ctor(parent)
  self.panel = nil
  super.ctor(self, "panel_dmg_sub", "dmg/panel_dmg_sub", UI.ECacheLv.None)
end

function Panel_dmg_subView:initZWidget()
  self.bodyNode_ = self.panel.node_body
  self.targetNode_ = self.panel.node_target
  self.partNode_ = self.panel.node_part
  self.bodyLoop_ = self.bodyNode_.node_loop
  self.targetLoop_ = self.targetNode_.node_loop
  self.partLoop_ = self.partNode_.node_loop
  self.bodyScrollRect_ = loopscrollrect.new(self.bodyLoop_.VLoopScrollRect, self, bodyLooyItem)
  self.targetScrollRect_ = loopscrollrect.new(self.targetLoop_.VLoopScrollRect, self, targetLoopItem)
  self.partScrollRect_ = loopscrollrect.new(self.partLoop_.VLoopScrollRect, self, partLoopItem)
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
  self:AddClick(self.partNode_.input.Input, function(str)
    if self.isSelectedPartDro then
      self.isSelectedPartDro = false
      return
    end
    local data = dmgVm.DimFindData(str, dmgData.Part)
    self.partScrollRect_:SetData(data)
    self.partLoop_:SetVisible(0 < #data)
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
  self.partNode_.input.Input:AddSelectListener(function(bool)
    if bool == false then
      return
    end
    self.partLoop_:SetVisible(#dmgData.Part > 0)
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
  Z.UIUtil.UnityEventAddCoroFunc(self.partLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.partLoop_:SetVisible(false)
    end
  end)
  self:AddClick(self.panel.btn_refresh.Btn, function()
    self.isSelectedBodyDro = true
    self.isSelectedTargetDro = true
    local str = dmgData.SelectAttUuid
    dmgData.SelectAttUuid = dmgData.SelectByAttUuid
    dmgData.SelectByAttUuid = str
    self.targetNode_.input.Input.text = dmgData.SelectByAttUuid
    self.bodyNode_.input.Input.text = dmgData.SelectAttUuid
    dmgVm.ChangeDrowIndex()
  end)
end

function Panel_dmg_subView:OnActive()
  self.panel.Ref:SetSize(Vector2.zero)
  self:initZWidget()
  dmgData.TypeIndex = self.viewData
  self.isSelectedBodyDro = false
  self.isSelectedTargetDro = false
  self.isSelectedPartDro = false
  dmgVm.ChangeDrowIndex()
  self.damageLoopScrollRect = loopscrollrect.new(self.panel.loopscroll.VLoopScrollRect, self, dmgLoopItme)
  self:BindEvents()
  self:refrehDamagePanel()
  self:refrehDevelopmentView()
  self:BuffSelected(dmgData.Body[2])
  self:AttrSelected(dmgData.Target[1])
  self:MonsterSelected(dmgData.Part[1])
end

function Panel_dmg_subView:OnDeActive()
  Z.EventMgr:RemoveObjAll(self)
end

function Panel_dmg_subView:refrehDamagePanel()
  self.damageLoopScrollRect:SetData(dmgData.ShowDamageDatas)
end

function Panel_dmg_subView:refrehDevelopmentView()
  dmgVm.SetNearMosterTab()
  dmgData:SetBodyTab(table.zclone(dmgData.ControlNearMonsterTab))
  self.bodyScrollRect_:SetData(dmgData.Body)
  self:refreshTargetDro()
  self:refreshPartDro()
end

function Panel_dmg_subView:BuffSelected(data)
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

function Panel_dmg_subView:AttrSelected(data)
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
  dmgVm.RefrehPartDevel()
  self:refreshPartDro()
  dmgVm.ChangeDrowIndex()
end

function Panel_dmg_subView:MonsterSelected(data)
  if data == nil then
    return
  end
  self.partLoop_:SetVisible(false)
  if self.partNode_.input.Input.text == data then
    return
  end
  self.isSelectedPartDro = true
  self.partNode_.input.Input.text = data
  dmgData.SelectPartId = string.split(data, " ")[1]
  dmgVm.ChangeDrowIndex()
end

function Panel_dmg_subView:refreshPartDro()
  self.partScrollRect_:SetData(dmgData.Part)
end

function Panel_dmg_subView:refreshTargetDro()
  dmgVm.SetNearMosterTab()
  dmgData:SetTargetTab(table.zclone(dmgData.ControlNearMonsterTab))
  self.targetScrollRect_:SetData(dmgData.Target)
  dmgData.Part = {
    Lang("DamagePartTxt")
  }
end

function Panel_dmg_subView:RefreshData()
end

function Panel_dmg_subView:OnRefresh()
end

function Panel_dmg_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Damage.RefreshPanel, self.refrehDamagePanel, self)
end

return Panel_dmg_subView
