local UI = Z.UI
local super = require("ui.ui_view_base")
local Dmg_data_panelView = class("Dmg_data_panelView", super)
local dmgVm = Z.VMMgr.GetVM("damage")
local dmgData = Z.DataMgr.Get("damage_data")
local subType = {
  dmg = 1,
  cure = 2,
  take = 3,
  attr = 4,
  buff = 5,
  shield = 6
}

function Dmg_data_panelView:ctor()
  self.panel = nil
  super.ctor(self, "dmg_data_panel")
  self.vm_ = Z.VMMgr.GetVM("damage")
  self.settView_ = require("ui/view/dmg/dmg_sett_pop_view").new(self)
  self.subViewTab = {
    [subType.dmg] = require("ui.view.dmg.panel_dmg_sub_view").new(self),
    [subType.cure] = require("ui.view.dmg.panel_dmg_sub_view").new(self),
    [subType.take] = require("ui.view.dmg.panel_bear_sub_view").new(self),
    [subType.attr] = require("ui.view.dmg.panel_attr_sub_view").new(self),
    [subType.buff] = require("ui.view.dmg.panel_buff_sub_view").new(self),
    [subType.shield] = require("ui.view.dmg.panel_shield_sub_view").new(self)
  }
end

function Dmg_data_panelView:initZWidget()
  self.controlBtn_ = self.panel.btn_control
  self.subViewPanel_ = self.panel.content_sub
  self.layoutRebuilder_ = self.panel.content.ZLayout
  self.tabTab_ = {}
  for _, type in pairs(subType) do
    self.tabTab_[type] = self.panel["cont_tab1_tpl0" .. type]
    self.tabTab_[type].on:SetVisible(false)
    self.tabTab_[type].off:SetVisible(true)
  end
end

function Dmg_data_panelView:iniBtn()
  local sizeDelta = self.panel.panel_l.Ref.RectTransform.sizeDelta
  local nowText = self.panel.cont_tab1_tpl05.on.img_tab_s01_lab.TMPLab.text
  local statisText = self.panel.cont_tab1_tpl05.on.img_tab_s02_lab.TMPLab.text
  self:AddClick(self.controlBtn_.Btn, function()
    self.vm_.OpenDamageView()
  end)
  self.panel.drag.EventTrigger.onDrag:AddListener(function(go, pointerData)
    local nowSizeDelta = self.panel.panel_l.Ref.RectTransform.sizeDelta
    local v2 = self.panel.drag.DragTool:GetNewDelta(nowSizeDelta.x, nowSizeDelta.y, sizeDelta.x, pointerData.delta.x)
    self.panel.panel_l.Ref.RectTransform.sizeDelta = v2
  end)
  self:AddClick(self.panel.btn_open.Btn, function()
    self.panel.node_content:SetVisible(true)
    self.panel.btn_open:SetVisible(false)
    self.panel.btn_arrow:SetVisible(true)
  end)
  self:AddClick(self.panel.btn_arrow.Btn, function()
    self.panel.node_content:SetVisible(false)
    self.panel.btn_open:SetVisible(true)
    self.panel.btn_arrow:SetVisible(false)
  end)
  self:AddClick(self.panel.btn_set.Btn, function()
    self.settView_:Active(nil, self.panel.subview_parent.Trans)
  end)
  self:AddClick(self.panel.btn_lock.Btn, function()
    self.lock_ = not self.lock_
    self.panel.img_icon_normal:SetVisible(self.lock_)
    self.panel.img_icon_press:SetVisible(not self.lock_)
    self.panel.node_content.Ref.CanvasGroup.interactable = self.lock_
    self.panel.node_content.Ref.CanvasGroup.blocksRaycasts = self.lock_
  end)
  self:AddClick(self.panel.btn_refresh.Btn, function()
    self.subViewTab[self.lastSubView_]:RefreshData()
  end)
  self:AddClick(self.panel.btn_close.Btn, function()
    Z.UIMgr:CloseView("dmg_data_panel")
  end)
  self:AddClick(self.panel.btn_switch.Btn, function()
    dmgData:RefreshData()
  end)
  for type, toggle in pairs(self.tabTab_) do
    self:AddClick(toggle.btn.Btn, function()
      if self.lastSubView_ ~= type then
        self:selectType(type)
      end
    end)
  end
  self:AddClick(self.panel.cont_tab1_tpl05.on.img_tab_s01.Btn, function()
    dmgData.IsShowNowBuff = true
    local parent = self.panel.cont_tab1_tpl05.on
    parent.img_tab_s01_lab.TMPLab.text = Z.RichTextHelper.ApplyStyleTag(nowText, E.TextStyleTag.DmgYellow)
    parent.img_tab_s02_lab.TMPLab.text = Z.RichTextHelper.ApplyStyleTag(statisText, E.TextStyleTag.DmgGray)
    self:refreshBuffView(0)
  end)
  self:AddClick(self.panel.cont_tab1_tpl05.on.img_tab_s02.Btn, function()
    dmgData.IsShowNowBuff = false
    local parent = self.panel.cont_tab1_tpl05.on
    parent.img_tab_s01_lab.TMPLab.text = Z.RichTextHelper.ApplyStyleTag(nowText, E.TextStyleTag.DmgGray)
    parent.img_tab_s02_lab.TMPLab.text = Z.RichTextHelper.ApplyStyleTag(statisText, E.TextStyleTag.DmgYellow)
    self:refreshBuffView(1)
  end)
  self:AddClick(self.panel.cont_tab1_tpl06.on.img_tab_s01.Btn, function()
    dmgData.IsShowNowShield = true
    local parent = self.panel.cont_tab1_tpl06.on
    parent.img_tab_s01_lab.TMPLab.text = Z.RichTextHelper.ApplyStyleTag(nowText, E.TextStyleTag.DmgYellow)
    parent.img_tab_s02_lab.TMPLab.text = Z.RichTextHelper.ApplyStyleTag(statisText, E.TextStyleTag.DmgGray)
    self:refreshShieldView(0)
  end)
  self:AddClick(self.panel.cont_tab1_tpl06.on.img_tab_s02.Btn, function()
    dmgData.IsShowNowShield = false
    local parent = self.panel.cont_tab1_tpl06.on
    parent.img_tab_s01_lab.TMPLab.text = Z.RichTextHelper.ApplyStyleTag(nowText, E.TextStyleTag.DmgGray)
    parent.img_tab_s02_lab.TMPLab.text = Z.RichTextHelper.ApplyStyleTag(statisText, E.TextStyleTag.DmgYellow)
    self:refreshShieldView(1)
  end)
end

function Dmg_data_panelView:OnActive()
  Z.DamageData:IsActiveUIPanel(true)
  dmgVm.RefrehBodyData()
  self.lock_ = true
  self.lastSubView_ = nil
  self:initZWidget()
  self:iniBtn()
  self:BindEvents()
  self:selectType(1)
end

function Dmg_data_panelView:selectType(type)
  self.tabTab_[type].on:SetVisible(true)
  self.tabTab_[type].off:SetVisible(false)
  self.subViewTab[type]:Active(type, self.subViewPanel_.Trans)
  if self.lastSubView_ then
    self.subViewTab[self.lastSubView_]:DeActive()
    self.tabTab_[self.lastSubView_].on:SetVisible(false)
    self.tabTab_[self.lastSubView_].off:SetVisible(true)
  end
  self.lastSubView_ = type
  self.layoutRebuilder_:ForceRebuildLayoutImmediate()
end

function Dmg_data_panelView:refreshBuffView(type)
  self.subViewTab[subType.buff]:DeActive()
  self.subViewTab[subType.buff]:Active(type, self.subViewPanel_.Trans)
end

function Dmg_data_panelView:refreshShieldView(type)
  self.subViewTab[subType.shield]:DeActive()
  self.subViewTab[subType.shield]:Active(type, self.subViewPanel_.Trans)
end

function Dmg_data_panelView:OnDeActive()
  self.settView_:DeActive()
  for key, value in pairs(self.subViewTab) do
    value:DeActive()
  end
end

function Dmg_data_panelView:refrehDamagePanel(type)
  self.subViewTab[subType.dmg]:Active(type, self.subViewPanel_.Trans)
end

function Dmg_data_panelView:refreshNameLab()
  self.attrName = ""
  if dmgData.SelectAttUuid == Lang("DamageSelfTxt") then
    self.attrName = Lang("DamageSelfTxt")
  elseif dmgData.SelectAttUuid == Lang("DamageAllTxt") then
    self.attrName = Lang("DamageAllTxt")
  elseif dmgData.SelectAttUuid == Z.EntityMgr.PlayerUuid then
    self.attrName = Z.ContainerMgr.CharSerialize.charBase.name
  else
    local monsterTab = dmgVm.GetMonsterTab(dmgData.SelectAttUuid)
    if monsterTab == nil then
      self.attrName = dmgData.SelectAttUuid
    else
      self.attrName = monsterTab.Name
    end
  end
  self.byAttName = ""
  if dmgData.SelectByAttUuid == Lang("DamageAllTxt") then
    self.byAttName = Lang("DamageAllTxt")
  elseif dmgData.SelectByAttUuid == Lang("DamageSelfTxt") then
    self.byAttName = Lang("DamageSelfTxt")
  elseif dmgData.SelectByAttUuid == Z.EntityMgr.PlayerUuid then
    self.byAttName = Z.ContainerMgr.CharSerialize.charBase.name
  else
    local monsterTab = dmgVm.GetMonsterTab(dmgData.SelectByAttUuid)
    if monsterTab == nil then
      self.byAttName = dmgData.SelectByAttUuid
    else
      self.byAttName = monsterTab.Name
    end
  end
  local partName = dmgData.SelectPartId
  self.panel.lab_name.TMPLab.text = string.zconcat("<", self.attrName, ">", "<", self.byAttName, ">", "<", partName, ">")
end

function Dmg_data_panelView:refreshDmgColor(a)
  local v4 = Color.New(0.13725490196078433, 0.13725490196078433, 0.13725490196078433, a / 100)
  self.panel.node_content_bg.Img:SetColor(Color.New(0.3333333333333333, 0.3333333333333333, 0.3333333333333333, a / 100))
  self.panel.node_top_bg.Img:SetColor(v4)
  self.panel.viewport.Img:SetColor(v4)
end

function Dmg_data_panelView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Damage.ControlRefreshPanelColor, self.refreshDmgColor, self)
  self.panel.top_container.EventTrigger.onDrag:AddListener(function(go, pointerData)
    self.dragGmBtn = true
    local pos = self.panel.panel_l.Ref:GetPosition()
    self.panel.panel_l.Ref:SetPosition(pos.x + pointerData.delta.x, pos.y + pointerData.delta.y)
  end)
end

function Dmg_data_panelView:OnRefresh()
end

return Dmg_data_panelView
