local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_custom_subView = class("Map_custom_subView", super)
local SWITCH_PATH = "ui/prefabs/map/map_tog_icon_tpl"
local SWITCH_UNIT_NAME = "MapFlagSwitch"

function Map_custom_subView:ctor(parent)
  self.panel = nil
  super.ctor(self, "map_custom_sub", "map/map_custom_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.mapData_ = Z.DataMgr.Get("map_data")
end

function Map_custom_subView:OnActive()
  self:startAnimatedShow()
  self.panel.Ref:SetSize(0, 0)
  self.closeByBtn_ = false
  self.isMiniMapSettingChange_ = false
  self:AddClick(self.panel.cont_content.cont_map_bg.cont_btn_return.btn.Btn, function()
    self.closeByBtn_ = true
    self.parent_:CloseRightSubview()
  end)
  self.modifiableFlagTypeList_ = {}
  self.mainSwitchCont_ = self.panel.cont_content.layout_setting_group1.cont_tog_icon_tpl.cont_switch
  self:initSwitch()
  self.mapSetTogGroup = self.panel.cont_content.layout_setting_group2.layout_map_setting3.togs_group.TogGroup
  self.lockTogGroup = self.panel.cont_content.layout_setting_group2.layout_map_setting4.layout_group.TogGroup
  self.ratio1 = self.panel.cont_content.layout_setting_group2.layout_map_setting3.cont_ratio_setting
  self.ratio2 = self.panel.cont_content.layout_setting_group2.layout_map_setting3.cont_ratio_setting2
  self.ratio3 = self.panel.cont_content.layout_setting_group2.layout_map_setting3.cont_ratio_setting3
  self.lock1 = self.panel.cont_content.layout_setting_group2.layout_map_setting4.cont_com_toggle.tog_item
  self.lock2 = self.panel.cont_content.layout_setting_group2.layout_map_setting4.cont_com_toggle02.tog_item
  self.ratio1.tog_scale.Tog.group = self.mapSetTogGroup
  self.ratio2.tog_scale.Tog.group = self.mapSetTogGroup
  self.ratio3.tog_scale.Tog.group = self.mapSetTogGroup
  self.lock1.Tog.group = self.lockTogGroup
  self.lock2.Tog.group = self.lockTogGroup
  self:initToggle()
  self.ratio1.tog_scale.Tog:AddListener(function(isOn)
    if isOn then
      self.mapData_:SetShowProportion(E.ShowProportionType.Low)
      self.isMiniMapSettingChange_ = true
      self.ratio1.anim.TweenContainer:Restart(Z.DOTweenAnimType.Open)
    else
      self.ratio1.anim.TweenContainer:Restart(Z.DOTweenAnimType.Close)
    end
  end)
  self.ratio2.tog_scale.Tog:AddListener(function(isOn)
    if isOn then
      self.mapData_:SetShowProportion(E.ShowProportionType.Middle)
      self.isMiniMapSettingChange_ = true
      self.ratio2.anim.TweenContainer:Restart(Z.DOTweenAnimType.Open)
    else
      self.ratio2.anim.TweenContainer:Restart(Z.DOTweenAnimType.Close)
    end
  end)
  self.ratio3.tog_scale.Tog:AddListener(function(isOn)
    if isOn then
      self.mapData_:SetShowProportion(E.ShowProportionType.High)
      self.isMiniMapSettingChange_ = true
      self.ratio3.anim.TweenContainer:Restart(Z.DOTweenAnimType.Open)
    else
      self.ratio3.anim.TweenContainer:Restart(Z.DOTweenAnimType.Close)
    end
  end)
  self.lock1.Tog:AddListener(function(isOn)
    if isOn then
      self.mapData_:SetViewFocus(E.ViewFocusType.focusDir)
      self.isMiniMapSettingChange_ = true
    end
  end)
  self.lock2.Tog:AddListener(function(isOn)
    if isOn then
      self.mapData_:SetViewFocus(E.ViewFocusType.focusPlayer)
      self.isMiniMapSettingChange_ = true
    end
  end)
end

function Map_custom_subView:initToggle()
  local proportion = self.mapData_:GetShowProportion()
  if proportion == E.ShowProportionType.High then
    self.ratio3.tog_scale.Tog.isOn = true
    self.ratio3.anim.TweenContainer:Restart(Z.DOTweenAnimType.Open)
  elseif proportion == E.ShowProportionType.Middle then
    self.ratio2.tog_scale.Tog.isOn = true
    self.ratio2.anim.TweenContainer:Restart(Z.DOTweenAnimType.Open)
  elseif proportion == E.ShowProportionType.Low then
    self.ratio1.tog_scale.Tog.isOn = true
    self.ratio1.anim.TweenContainer:Restart(Z.DOTweenAnimType.Open)
  end
  local focus = self.mapData_:GetViewFocus()
  if focus == E.ViewFocusType.focusDir then
    self.lock1.Tog.isOn = true
    self.lock2.Tog.isOn = false
  else
    self.lock1.Tog.isOn = false
    self.lock2.Tog.isOn = true
  end
end

function Map_custom_subView:startAnimatedShow()
  self.panel.anim.TweenContainer:Restart(Z.DOTweenAnimType.Open)
end

function Map_custom_subView:startAnimatedHide()
  if self.closeByBtn_ then
    local coro = Z.CoroUtil.async_to_sync(self.panel.anim.TweenContainer.CoroPlay)
    coro(self.panel.anim.TweenContainer, Z.DOTweenAnimType.Close)
  end
end

function Map_custom_subView:OnDeActive()
  self.ratio1.anim.TweenContainer:Restart(Z.DOTweenAnimType.Close)
  self.ratio2.anim.TweenContainer:Restart(Z.DOTweenAnimType.Close)
  self.ratio3.anim.TweenContainer:Restart(Z.DOTweenAnimType.Close)
  self.modifiableFlagTypeList_ = nil
  if self.isMiniMapSettingChange_ then
    Z.EventMgr:Dispatch(Z.ConstValue.MiniMapSettingChange)
    self.isMiniMapSettingChange_ = false
  end
end

function Map_custom_subView:initSwitch()
  self.modifiableFlagTypeList_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    for typeId, row in pairs(Z.TableMgr.GetTable("SceneTagTableMgr").GetDatas()) do
      if row.Show == 1 then
        table.insert(self.modifiableFlagTypeList_, typeId)
        self:createSingleSwitch(row)
      end
    end
    self.panel.cont_content.layout_content.ZLayout:ForceRebuildLayoutImmediate()
  end)()
  self:refreshMainSwitchIsOnWithoutNotify()
  self.mainSwitchCont_.switch.Switch:AddListener(function(isOn)
    for _, typeId in ipairs(self.modifiableFlagTypeList_) do
      self.mapData_:SetMapFlagVisibleSettingByTypeId(typeId, isOn)
      Z.EventMgr:Dispatch(Z.ConstValue.MapSettingChange, typeId)
      local switchUnit = self.units[SWITCH_UNIT_NAME .. typeId]
      if switchUnit then
        switchUnit.cont_switch.switch.Switch:SetIsOnWithoutNotify(isOn)
      end
    end
  end)
end

function Map_custom_subView:refreshMainSwitchIsOnWithoutNotify()
  local count = 0
  for _, typeId in ipairs(self.modifiableFlagTypeList_) do
    local isShow = self.mapData_:GetMapFlagVisibleSettingByTypeId(typeId)
    if isShow then
      count = count + 1
    end
  end
  local isAllShow = count == #self.modifiableFlagTypeList_
  self.mainSwitchCont_.switch.Switch:SetIsOnWithoutNotify(isAllShow)
end

function Map_custom_subView:createSingleSwitch(tagRow)
  local typeId = tagRow.Id
  local parent
  if typeId == E.MapFlagTypeId.CustomTag1 or typeId == E.MapFlagTypeId.CustomTag2 or typeId == E.MapFlagTypeId.CustomTag3 then
    parent = self.panel.cont_content.layout_setting_group1.layout_map_setting2.layout_group.Trans
  else
    parent = self.panel.cont_content.layout_setting_group1.layout_map_setting.layout_group.Trans
  end
  local unit = self:AsyncLoadUiUnit(SWITCH_PATH, SWITCH_UNIT_NAME .. typeId, parent)
  if not unit then
    return
  end
  unit.img_icon.Img:SetImage(tagRow.Icon1)
  local isShow = self.mapData_:GetMapFlagVisibleSettingByTypeId(typeId)
  unit.cont_switch.img_status_normal.Ref:SetVisible(not isShow)
  unit.cont_switch.img_status_active.Ref:SetVisible(isShow)
  unit.cont_switch.switch.Switch.IsOn = isShow
  unit.cont_switch.switch.Switch:AddListener(function(isOn)
    self.mapData_:SetMapFlagVisibleSettingByTypeId(typeId, isOn)
    Z.EventMgr:Dispatch(Z.ConstValue.MapSettingChange, typeId)
    self:refreshMainSwitchIsOnWithoutNotify()
  end)
end

return Map_custom_subView
