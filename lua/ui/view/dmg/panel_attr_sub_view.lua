local UI = Z.UI
local super = require("ui.ui_subview_base")
local Panel_attr_subView = class("Panel_attr_subView", super)
local loopscrollrect = require("ui/component/loopscrollrect")
local buffLoopItem = require("ui.component.damage.dmg_control_buff_loop_item")
local partLoopItem = require("ui.component.damage.dmg_control_monster_loop_item")
local dmgAttrLoopItem = require("ui.component.damage.dmg_attr_loop_item")
local dmgVm = Z.VMMgr.GetVM("damage")
local dmgData = Z.DataMgr.Get("damage_data")

function Panel_attr_subView:ctor(parent)
  self.panel = nil
  super.ctor(self, "panel_attr_sub", "dmg/panel_attr_sub", UI.ECacheLv.None)
end

function Panel_attr_subView:initZWidget()
  self.attrTargetNode_ = self.panel.node_attr_target
  self.attrTargetLoop_ = self.attrTargetNode_.node_loop
  self.partNode_ = self.panel.node_attr_part
  self.partLoop_ = self.partNode_.node_loop
  self.attrTargetScrollRect_ = loopscrollrect.new(self.attrTargetLoop_.VLoopScrollRect, self, buffLoopItem)
  self.arrtLoopScrollRect = loopscrollrect.new(self.panel.loopscroll.VLoopScrollRect, self, dmgAttrLoopItem)
  self.partScrollRect_ = loopscrollrect.new(self.partLoop_.VLoopScrollRect, self, partLoopItem)
  self:AddClick(self.attrTargetNode_.input.Input, function(str)
    if self.isSelectedAttrDro then
      self.isSelectedAttrDro = false
      return
    end
    self.showData_ = dmgVm.DimFindData(str, dmgData.AttrTargetTab)
    self.attrTargetScrollRect_:SetData(self.showData_)
    self.attrTargetLoopIsShow_ = #self.showData_ > 0
    self.attrTargetLoop_:SetVisible(self.attrTargetLoopIsShow_)
  end)
  self.attrTargetNode_.input.Input:AddSelectListener(function(bool)
    if bool == false then
      return
    end
    if self.attrTargetLoopIsShow_ then
      return
    else
      self:setAttrTargetTab()
    end
    self.attrTargetLoopIsShow_ = #dmgData.AttrTargetTab > 0
    self.attrTargetLoop_:SetVisible(self.attrTargetLoopIsShow_)
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.attrTargetLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.attrTargetLoopIsShow_ = false
      self.attrTargetLoop_:SetVisible(false)
    end
  end)
  self:AddClick(self.partNode_.input.Input, function(str)
    if self.isSelectedPartDro then
      self.isSelectedPartDro = false
      return
    end
    local data = dmgVm.DimFindData(str, dmgData.ControlAttrPartData)
    self.partScrollRect_:SetData(data)
    self.partLoop_:SetVisible(0 < #data)
  end)
  self.partNode_.input.Input:AddSelectListener(function(bool)
    if bool == false then
      return
    end
    self.partLoop_:SetVisible(#dmgData.ControlAttrPartData > 0)
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.partLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.partLoop_:SetVisible(false)
    end
  end)
  self:AddClick(self.panel.gm_input_tpl03.panel_input.Input, function(str)
    self.attrInputStr_ = str
    local attrData = dmgVm.GetAttrData(str)
    self.arrtLoopScrollRect:SetData(attrData)
  end)
end

function Panel_attr_subView:OnActive()
  self.attrInputStr_ = ""
  self.isSelectedAttrDro = false
  self.panel.Ref:SetSize(Vector2.zero)
  self.attrTargetLoopIsShow_ = false
  self:initZWidget()
  self:setAttrTargetTab()
  self:BuffSelected(dmgData.AttrTargetTab[1])
  self:MonsterSelected(dmgData.ControlAttrPartData[1])
end

function Panel_attr_subView:setAttrTargetTab()
  dmgVm.SetNearMosterTab()
  dmgData:SetAttrTargetTab(table.zclone(dmgData.ControlNearMonsterTab))
  self.attrTargetScrollRect_:SetData(dmgData.AttrTargetTab)
end

function Panel_attr_subView:BuffSelected(data)
  if data == nil then
    return
  end
  self.attrTargetLoopIsShow_ = false
  self.attrTargetLoop_:SetVisible(false)
  if self.attrTargetNode_.input.Input.text == data then
    return
  end
  self.isSelectedAttrDro = true
  self.attrTargetNode_.input.Input.text = data
  self.attrData_ = string.split(data, " ")[1]
  self:initAttrPartDown()
  self:refreshAttrLoop()
end

function Panel_attr_subView:MonsterSelected(data)
  if data == nil then
    return
  end
  self.partLoop_:SetVisible(false)
  if self.partNode_.input.Input.text == data then
    return
  end
  self.isSelectedPartDro = true
  self.partNode_.input.Input.text = data
  dmgData.ControlSelectAttrPartData = string.split(data, " ")[1]
  self:refreshAttrLoop()
end

function Panel_attr_subView:initAttrPartDown()
  local entUuid
  if self.attrData_ == Lang("DamageSelfTxt") then
    entUuid = dmgData.PlayerUuid
  else
    entUuid = self.attrData_
  end
  if entUuid == nil then
    return
  end
  local modelId = dmgVm.GetModelId(entUuid)
  if modelId ~= -1 then
    local partTab = dmgVm.GetPartData(modelId)
    if partTab == nil or table.zcount(partTab) == 0 then
      dmgData.ControlAttrPartData = {
        Lang("DamagePartTxt")
      }
    else
      for key, value in pairs(partTab) do
        table.insert(dmgData.ControlAttrPartData, tostring(value))
      end
    end
  else
    dmgData.ControlAttrPartData = {
      Lang("DamagePartTxt")
    }
  end
  dmgData.ControlSelectAttrPartData = dmgData.ControlAttrPartData[1]
  self.partScrollRect_:SetData(dmgData.ControlAttrPartData)
end

function Panel_attr_subView:RefreshData()
  self:refreshAttrLoop()
end

function Panel_attr_subView:refreshAttrLoop()
  dmgVm.GetEntAttr(self.attrData_)
  local attrData = dmgVm.GetAttrData(self.attrInputStr_)
  self.arrtLoopScrollRect:SetData(attrData)
end

function Panel_attr_subView:OnDeActive()
end

function Panel_attr_subView:OnRefresh()
end

return Panel_attr_subView
