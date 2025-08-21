local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_show_sub_pcView = class("Camera_menu_container_show_sub_pcView", super)

function Camera_menu_container_show_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_show_sub_pc", "photograph_pc/camera_menu_container_show_sub_pc", UI.ECacheLv.None)
  self.parent_ = parent
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
end

function Camera_menu_container_show_sub_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:BindEvents()
  self.entityTempTab_ = nil
end

function Camera_menu_container_show_sub_pcView:OnDeActive()
  self:UnBindEvents()
  self.entityTempTab_ = nil
end

function Camera_menu_container_show_sub_pcView:OnRefresh()
  self:updateListItem()
  self.cameraData_.MenuContainerShowDirty = false
end

function Camera_menu_container_show_sub_pcView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.PatternTypeChange, self.camerasysPatternTypeChange, self)
end

function Camera_menu_container_show_sub_pcView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Camera.PatternTypeChange, self.camerasysPatternTypeChange, self)
end

function Camera_menu_container_show_sub_pcView:camerasysPatternTypeChange(valueData)
  if valueData.nowType ~= valueData.targetType then
    for key, item in pairs(self.units) do
      if item ~= nil then
        item.tog_camera_setting.isOn = true
      end
    end
    if valueData.targetType == E.TakePhotoSate.Default then
      self.entityTempTab_ = self.cameraData_:GetShowEntityData()
    elseif valueData.targetType == E.TakePhotoSate.AR then
      self.entityTempTab_ = self.cameraData_:GetShowEntityARData()
    elseif valueData.targetType == E.TakePhotoSate.SelfPhoto then
      self.entityTempTab_ = self.cameraData_:GetShowEntitySelfPhotoData()
    end
  end
end

function Camera_menu_container_show_sub_pcView:updateListItem()
  local cameraPatternType = E.TakePhotoSate.Default
  if self.cameraData_.CameraPatternType then
    cameraPatternType = self.cameraData_.CameraPatternType
  end
  if cameraPatternType == E.TakePhotoSate.AR then
    self.entityTempTab_ = self.cameraData_:GetShowEntityARData()
  elseif cameraPatternType == E.TakePhotoSate.SelfPhoto then
    self.entityTempTab_ = self.cameraData_:GetShowEntitySelfPhotoData()
  else
    self.entityTempTab_ = self.cameraData_:GetShowEntityData()
  end
  local uiTempTab = self.cameraData_:GetShowUIData()
  self:removeUnit()
  Z.CoroUtil.create_coro_xpcall(function()
    self:setItemData(self.entityTempTab_, uiTempTab)
  end)()
end

function Camera_menu_container_show_sub_pcView:removeUnit()
  if not self.units or not next(self.units) then
    return
  end
  for k, v in pairs(self.units) do
    self:RemoveUiUnit(k)
  end
end

function Camera_menu_container_show_sub_pcView:setItemData(entityDates, uiDates)
  local path = self.uiBinder.prefab_cache:GetString("camera_setting_toggle_item_tpl_pc")
  if entityDates and next(entityDates) then
    for k, v in pairs(entityDates) do
      local name = string.format("entity_%s", v.name)
      local item = self:AsyncLoadUiUnit(path, name, self.uiBinder.node_camera_setting_entity)
      item.tog_camera_setting:RemoveAllListeners()
      item.tog_camera_setting:AddListener(function(isOn)
        self:setTogFunc(v.type, isOn)
      end)
      item.tog_camera_setting:SetIsOnWithoutCallBack(v.state)
      item.lab_title.text = v.txt
      item.lab_name.text = v.txt
    end
  end
  if uiDates and next(uiDates) then
    for _, v in pairs(uiDates) do
      local name = string.format("uiShow%s", v.name)
      local item = self:AsyncLoadUiUnit(path, name, self.uiBinder.node_camera_setting_ui)
      item.tog_camera_setting:RemoveAllListeners()
      item.tog_camera_setting:AddListener(function(isOn)
        self.cameraData_:SetIsSchemeParamUpdated(true)
        Z.LuaBridge.SetHudSwitch(isOn)
        self.cameraVM_.SetShowState(v.type, isOn, E.CamerasysContrShowType.UI)
      end)
      item.tog_camera_setting:SetIsOnWithoutCallBack(v.state)
      item.lab_title.text = v.txt
      item.lab_name.text = v.txt
    end
  end
  self.uiBinder.layout_camera_setting_entity:ForceRebuildLayoutImmediate()
  self.uiBinder.layout_camera_setting_ui:ForceRebuildLayoutImmediate()
end

function Camera_menu_container_show_sub_pcView:setEntityShow(type, value)
  Z.CameraFrameCtrl:SetEntityShow(type, value)
end

function Camera_menu_container_show_sub_pcView:setTogFunc(type, isOn)
  self.cameraData_.CameraEntityVisible[type] = not isOn
  self:setEntityShow(type, isOn)
  if type == E.CameraSystemShowEntityType.Oneself then
    self.cameraData_.IsHideSelfModel = not isOn
  end
  local cameraPatternType = E.TakePhotoSate.Default
  if self.cameraData_.CameraPatternType then
    cameraPatternType = self.cameraData_.CameraPatternType
  end
  self.cameraVM_.SetShowState(type, isOn, E.CamerasysContrShowType.Entity, cameraPatternType)
end

return Camera_menu_container_show_sub_pcView
