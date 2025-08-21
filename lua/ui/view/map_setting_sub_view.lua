local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_setting_subView = class("Map_setting_subView", super)
local MAP_SCALE_TEXTURE_PATH = {
  [1] = "ui/textures/map/minimap_8",
  [2] = "ui/textures/map/minimap_10",
  [3] = "ui/textures/map/minimap_12"
}

function Map_setting_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "map_setting_sub", "map/map_setting_sub", UI.ECacheLv.None)
  self.mapData_ = Z.DataMgr.Get("map_data")
end

function Map_setting_subView:OnActive()
  self:initData()
  self:initComp()
end

function Map_setting_subView:OnDeActive()
  if self.isMiniMapSettingChange_ then
    Z.EventMgr:Dispatch(Z.ConstValue.MiniMapSettingChange)
    self.isMiniMapSettingChange_ = false
  end
end

function Map_setting_subView:OnRefresh()
end

function Map_setting_subView:initData()
  self.isMiniMapSettingChange_ = false
end

function Map_setting_subView:initComp()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.tog_scale_1.group = self.uiBinder.tog_group_scale
  self.uiBinder.tog_scale_2.group = self.uiBinder.tog_group_scale
  self.uiBinder.tog_scale_3.group = self.uiBinder.tog_group_scale
  self.uiBinder.tog_lock_1.group = self.uiBinder.tog_group_lock
  self.uiBinder.tog_lock_2.group = self.uiBinder.tog_group_lock
  local proportion = self.mapData_:GetShowProportion()
  if proportion == E.ShowProportionType.High then
    self.uiBinder.tog_scale_3.isOn = true
    self.uiBinder.comp_dotween_scale_3:Restart(Z.DOTweenAnimType.Open)
    self.uiBinder.rimg_mini:SetImage(MAP_SCALE_TEXTURE_PATH[3])
  elseif proportion == E.ShowProportionType.Middle then
    self.uiBinder.tog_scale_2.isOn = true
    self.uiBinder.comp_dotween_scale_2:Restart(Z.DOTweenAnimType.Open)
    self.uiBinder.rimg_mini:SetImage(MAP_SCALE_TEXTURE_PATH[2])
  elseif proportion == E.ShowProportionType.Low then
    self.uiBinder.tog_scale_1.isOn = true
    self.uiBinder.comp_dotween_scale_1:Restart(Z.DOTweenAnimType.Open)
    self.uiBinder.rimg_mini:SetImage(MAP_SCALE_TEXTURE_PATH[1])
  end
  local curFocus = self.mapData_:GetViewFocus()
  local isFocusDirection = curFocus == E.ViewFocusType.focusDir
  self.uiBinder.tog_lock_1.isOn = isFocusDirection
  self.uiBinder.tog_lock_2.isOn = not isFocusDirection
  self.uiBinder.tog_scale_1:AddListener(function(isOn)
    if isOn then
      self.mapData_:SetShowProportion(E.ShowProportionType.Low)
      self.isMiniMapSettingChange_ = true
      self.uiBinder.comp_dotween_scale_1:Restart(Z.DOTweenAnimType.Open)
      self.uiBinder.rimg_mini:SetImage(MAP_SCALE_TEXTURE_PATH[1])
    else
      self.uiBinder.comp_dotween_scale_1:Restart(Z.DOTweenAnimType.Close)
    end
  end)
  self.uiBinder.tog_scale_2:AddListener(function(isOn)
    if isOn then
      self.mapData_:SetShowProportion(E.ShowProportionType.Middle)
      self.isMiniMapSettingChange_ = true
      self.uiBinder.comp_dotween_scale_2:Restart(Z.DOTweenAnimType.Open)
      self.uiBinder.rimg_mini:SetImage(MAP_SCALE_TEXTURE_PATH[2])
    else
      self.uiBinder.comp_dotween_scale_2:Restart(Z.DOTweenAnimType.Close)
    end
  end)
  self.uiBinder.tog_scale_3:AddListener(function(isOn)
    if isOn then
      self.mapData_:SetShowProportion(E.ShowProportionType.High)
      self.isMiniMapSettingChange_ = true
      self.uiBinder.comp_dotween_scale_3:Restart(Z.DOTweenAnimType.Open)
      self.uiBinder.rimg_mini:SetImage(MAP_SCALE_TEXTURE_PATH[3])
    else
      self.uiBinder.comp_dotween_scale_3:Restart(Z.DOTweenAnimType.Close)
    end
  end)
  self.uiBinder.tog_lock_1:AddListener(function(isOn)
    if isOn then
      self.mapData_:SetViewFocus(E.ViewFocusType.focusDir)
      self.isMiniMapSettingChange_ = true
    end
  end)
  self.uiBinder.tog_lock_2:AddListener(function(isOn)
    if isOn then
      self.mapData_:SetViewFocus(E.ViewFocusType.focusPlayer)
      self.isMiniMapSettingChange_ = true
    end
  end)
end

return Map_setting_subView
