local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_showView = class("Camera_menu_container_showView", super)

function Camera_menu_container_showView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_show_sub", "photograph/camera_menu_container_show_sub", UI.ECacheLv.None)
  self.parent_ = parent
end

function Camera_menu_container_showView:OnActive()
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self:BindEvents()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.entityTempTab_ = nil
end

function Camera_menu_container_showView:OnDeActive()
  self.entityTempTab_ = nil
  Z.EventMgr:Remove(Z.ConstValue.Camera.PatternTypeChange, self.camerasysPatternTypeChange, self)
end

function Camera_menu_container_showView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.PatternTypeChange, self.camerasysPatternTypeChange, self)
end

function Camera_menu_container_showView:camerasysPatternTypeChange(valueData)
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

function Camera_menu_container_showView:OnRefresh()
  self:updateListItem()
  self.cameraData_.MenuContainerShowDirty = false
end

function Camera_menu_container_showView:updateListItem()
  local cameraPatternType
  if not self.cameraData_.CameraPatternType then
    cameraPatternType = E.TakePhotoSate.Default
  else
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

function Camera_menu_container_showView:removeUnit()
  if not self.units or not next(self.units) then
    return
  end
  for k, v in pairs(self.units) do
    self:RemoveUiUnit(k)
  end
end

function Camera_menu_container_showView:setItemData(entityDates, uiDates)
  if entityDates and next(entityDates) then
    for k, v in pairs(entityDates) do
      local name = string.format("entity_%s", v.name)
      local item = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Camera.Setting_Toggle_Item), name, self.uiBinder.node_camera_setting_entity)
      item.tog_camera_setting:RemoveAllListeners()
      item.tog_camera_setting:AddListener(function(isOn)
        self:setTogFunc(v.type, isOn)
      end)
      item.tog_camera_setting:SetIsOnWithoutCallBack(v.state)
      item.lab_title.text = v.txt
    end
  end
  self.uiBinder.layout_camera_setting_entity:ForceRebuildLayoutImmediate()
  if uiDates and next(uiDates) then
    for k, v in pairs(uiDates) do
      local name = string.format("uiShow%s", v.name)
      local item = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Camera.Setting_Toggle_Item), name, self.uiBinder.node_camera_setting_ui)
      item.tog_camera_setting:RemoveAllListeners()
      item.tog_camera_setting:AddListener(function(isOn)
        self.cameraData_:SetIsSchemeParamUpdated(true)
        Z.LuaBridge.SetHudSwitch(isOn)
        self.cameraVM_.SetShowState(v.type, isOn, E.CamerasysContrShowType.UI)
      end)
      item.tog_camera_setting:SetIsOnWithoutCallBack(v.state)
      item.lab_title.text = v.txt
    end
  end
  self.uiBinder.layout_camera_setting_ui:ForceRebuildLayoutImmediate()
end

function Camera_menu_container_showView:setEntityShow(type, value)
  Z.CameraFrameCtrl:SetEntityShow(type, value)
end

function Camera_menu_container_showView:setTogFunc(type, isOn)
  self.cameraData_.CameraEntityVisible[type] = not isOn
  self:setEntityShow(type, isOn)
  if type == E.CameraSystemShowEntityType.Oneself then
    self.cameraData_.IsHideSelfModel = not isOn
  end
  local cameraPatternType
  if not self.cameraData_.CameraPatternType then
    cameraPatternType = E.TakePhotoSate.Default
  else
    cameraPatternType = self.cameraData_.CameraPatternType
  end
  self.cameraVM_.SetShowState(type, isOn, E.CamerasysContrShowType.Entity, cameraPatternType)
end

return Camera_menu_container_showView
