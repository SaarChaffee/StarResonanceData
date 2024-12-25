local UI = Z.UI
local super = require("ui.ui_subview_base")
local Panel_buff_subView = class("Panel_buff_subView", super)
local loopscrollrect = require("ui/component/loopscrollrect")
local dmgBuffLoopItem = require("ui.component.damage.dmg_buff_loop_item")
local buffLoopItem = require("ui.component.damage.dmg_control_buff_loop_item")
local partLoopItem = require("ui.component.damage.dmg_control_monster_loop_item")
local dmgVm = Z.VMMgr.GetVM("damage")
local dmgData = Z.DataMgr.Get("damage_data")

function Panel_buff_subView:ctor(parent)
  self.panel = nil
  super.ctor(self, "panel_buff_sub", "dmg/panel_buff_sub", UI.ECacheLv.None)
end

function Panel_buff_subView:initZWidget()
  self.buffTargetNode_ = self.panel.node_buff_target
  self.buffTargetLoop_ = self.buffTargetNode_.node_loop
  self.partNode_ = self.panel.node_buff_part
  self.partLoop_ = self.partNode_.node_loop
  self.partScrollRect_ = loopscrollrect.new(self.partLoop_.VLoopScrollRect, self, partLoopItem)
  self.buffTargetScrollRect_ = loopscrollrect.new(self.buffTargetLoop_.VLoopScrollRect, self, buffLoopItem)
  self.buffInfoScrollRect = loopscrollrect.new(self.panel.loopscroll.VLoopScrollRect, self, dmgBuffLoopItem)
end

function Panel_buff_subView:initBtn()
  self:AddClick(self.buffTargetNode_.input.Input, function(str)
    if self.IsSelectedBuffDro then
      self.IsSelectedBuffDro = false
      return
    end
    self.showData_ = dmgVm.DimFindData(str, dmgData.BuffTargetTab)
    self.buffTargetScrollRect_:SetData(self.showData_)
    self.buffTargetLoop_:SetVisible(#self.showData_ > 0)
  end)
  self.buffTargetNode_.input.Input:AddSelectListener(function(bool)
    if bool == false then
      return
    end
    self:setBuffTargetTab()
    self.buffTargetLoop_:SetVisible(#dmgData.BuffTargetTab > 0)
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.buffTargetLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.buffTargetLoop_:SetVisible(false)
    end
  end)
  self:AddClick(self.partNode_.input.Input, function(str)
    if self.isSelectedPartDro then
      self.isSelectedPartDro = false
      return
    end
    local data = dmgVm.DimFindData(str, dmgData.ControlBuffPartTab)
    self.partScrollRect_:SetData(data)
    self.partLoop_:SetVisible(0 < #data)
  end)
  self.partNode_.input.Input:AddSelectListener(function(bool)
    if bool == false then
      return
    end
    self.partLoop_:SetVisible(#dmgData.ControlBuffPartTab > 0)
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.partLoop_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.partLoop_:SetVisible(false)
    end
  end)
  self:AddClick(self.panel.gm_input_tpl03.panel_input.Input, function(str)
    self.buffInputStr_ = str
    local buffData = dmgVm.GetBuffData(str)
    self.buffInfoScrollRect:SetData(buffData)
  end)
end

function Panel_buff_subView:setBuffTargetTab()
  dmgVm.SetNearMosterTab()
  dmgData:SetBuffTargetTab(table.zclone(dmgData.ControlNearMonsterTab))
  self.buffTargetScrollRect_:SetData(dmgData.BuffTargetTab)
end

function Panel_buff_subView:OnActive()
  self:initZWidget()
  self:initBtn()
  self.buffInputStr_ = ""
  self.buffData_ = ""
  self.IsSelectedBuffDro = false
  self.panel.Ref:SetSize(Vector2.zero)
  self:setBuffTargetTab()
  self:refresh()
  self:BuffSelected(dmgData.BuffTargetTab[1])
  self:MonsterSelected(dmgData.ControlBuffPartTab[1])
end

function Panel_buff_subView:refresh()
  if self.viewData == 0 or self.viewData == nil then
    self.panel.lab_title03.TMPLab.text = Lang("DamageLayer")
  else
    self.panel.lab_title03.TMPLab.text = Lang("DamageTime")
  end
end

function Panel_buff_subView:BuffSelected(data)
  if data == nil then
    return
  end
  self.buffTargetLoop_:SetVisible(false)
  if self.buffTargetNode_.input.Input.text == data then
    return
  end
  self.IsSelectedBuffDro = true
  self.buffTargetNode_.input.Input.text = data
  self.buffData_ = string.split(data, " ")[1]
  self:refreshBuffLoop()
  self:initBuffPartDown()
end

function Panel_buff_subView:MonsterSelected(data)
  if data == nil then
    return
  end
  self.partLoop_:SetVisible(false)
  if self.partNode_.input.Input.text == data then
    return
  end
  self.isSelectedPartDro = true
  self.partNode_.input.Input.text = data
  dmgData.ControlSelectBuffPartData = string.split(data, " ")[1]
  self:refreshBuffLoop()
end

function Panel_buff_subView:OnDeActive()
end

function Panel_buff_subView:initBuffPartDown()
  local entUuid
  if self.buffData_ == Lang("DamageSelfTxt") then
    entUuid = dmgData.PlayerUuid
  else
    entUuid = self.buffData_
  end
  if entUuid == nil then
    return
  end
  local modelId = dmgVm.GetModelId(entUuid)
  if modelId ~= -1 then
    local partTab = dmgVm.GetPartData(modelId)
    if partTab == nil or table.zcount(partTab) == 0 then
      dmgData.ControlBuffPartTab = {
        Lang("DamagePartTxt")
      }
    else
      for key, value in pairs(partTab) do
        table.insert(dmgData.ControlBuffPartTab, tostring(value))
      end
    end
  else
    dmgData.ControlBuffPartTab = {
      Lang("DamagePartTxt")
    }
  end
  dmgData.ControlSelectBuffPartData = dmgData.ControlBuffPartTab[1]
  self.partScrollRect_:SetData(dmgData.ControlBuffPartTab)
end

function Panel_buff_subView:refreshBuffLoop()
  if dmgData.IsShowNowBuff then
    local entUuid
    if self.buffData_ == Lang("DamageSelfTxt") then
      entUuid = dmgData.PlayerUuid
    else
      entUuid = self.buffData_
    end
    if entUuid == nil then
      return
    end
    local entity = Z.EntityMgr:GetEntity(tonumber(entUuid))
    local buffData
    if entity then
      buffData = dmgVm.GetNowEntBuff(entity)
      self.buffInfoScrollRect:SetData(buffData)
    else
      self.buffInfoScrollRect:SetData(nil)
    end
  else
    dmgData:GetEBuffData(self.buffData_)
    local buffData = dmgVm.GetBuffData(self.buffInputStr_)
    self.buffInfoScrollRect:SetData(buffData)
  end
end

function Panel_buff_subView:RefreshData()
  self:refreshBuffLoop()
end

function Panel_buff_subView:OnRefresh()
  self:refresh()
end

return Panel_buff_subView
